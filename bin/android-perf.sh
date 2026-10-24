#!/usr/bin/env bash
# android-perf: strip XFCE compositing/animation overhead for low-latency
# mobile streaming over Selkies. Runs once per desktop session via
# /etc/xdg/autostart/android-perf.desktop. Safe to re-run; every step is
# guarded so a missing binary never breaks login.
#
# Targets XFCE on X11 (PIXELFLUX_WAYLAND=false, the project default).
set -u

log() { echo "[android-perf] $*"; }

# xfset <channel> <property> <type> <value>
# --create is required: on a fresh profile most of these properties do not
# exist yet, and a plain `-s` silently fails on missing properties.
xfset() {
  xfconf-query -c "$1" -p "$2" --create -t "$3" -s "$4" >/dev/null 2>&1 \
    || log "could not set $1 $2"
}

if command -v xfconf-query >/dev/null 2>&1; then
  # The xfconf daemon may not be up yet when autostart fires; wait briefly.
  for _ in $(seq 1 30); do
    xfconf-query -c xfwm4 -l >/dev/null 2>&1 && break
    sleep 1
  done

  # 1. Window manager: no compositing, no shadows/previews/zoom.
  for p in use_compositing cycle_preview show_dock_shadow show_frame_shadow \
           show_popup_shadow zoom_desktop; do
    xfset xfwm4 "/general/$p" bool false
  done

  # 2. GTK animations off.
  xfset xsettings /Gtk/EnableAnimations bool false

  # 3. Solid-color desktop background: wallpaper scaling costs CPU on expose.
  found=0
  while read -r prop; do
    case "$prop" in
      */image-style|*/color-style) xfset xfce4-desktop "$prop" int 0; found=1 ;;
      */rgba1)
        xfconf-query -c xfce4-desktop -p "$prop" \
          -t double -s 0.10 -t double -s 0.12 -t double -s 0.16 -t double -s 1.0 \
          >/dev/null 2>&1 || log "could not set $prop"
        found=1 ;;
    esac
  done < <(xfconf-query -c xfce4-desktop -l 2>/dev/null)

  if [ "$found" -eq 0 ]; then
    # Fresh profile: xfdesktop has not written its keys yet.
    base=/backdrop/screen0/monitor0/workspace0
    xfset xfce4-desktop "$base/image-style" int 0
    xfset xfce4-desktop "$base/color-style" int 0
    xfconf-query -c xfce4-desktop -p "$base/rgba1" --create \
      -t double -s 0.10 -t double -s 0.12 -t double -s 0.16 -t double -s 1.0 \
      >/dev/null 2>&1 || log "could not create $base/rgba1"
  fi

  # 4. Panel never auto-hides (no slide animation).
  xfset xfce4-panel /panels/panel-1/autohide-behavior int 0

  # 5. Screensaver / power management: a blanked stream costs a keyframe
  #    storm on wake for mobile clients.
  xfset xfce4-screensaver /saver/enabled bool false
  xfset xfce4-screensaver /lock/enabled bool false
  xfset xfce4-power-manager /xfce4-power-manager/dpms-enabled bool false
fi

# 6. Kill any standalone compositor that snuck in.
if command -v pkill >/dev/null 2>&1; then
  for proc in picom compton xfce4-screensaver; do
    pkill -x "$proc" 2>/dev/null || true
  done
fi

# 7. X11-level blanking off (only meaningful with an X display).
if command -v xset >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
  xset s off 2>/dev/null || true
  xset -dpms 2>/dev/null || true
  xset s noblank 2>/dev/null || true
fi

exit 0
