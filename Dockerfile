FROM lscr.io/linuxserver/webtop:ubuntu-xfce

# Node.js major version used for Claude Code (npm).
ARG NODE_MAJOR=24
# Electron's sandbox needs user namespaces, which Docker's default seccomp
# profile blocks. Set to "false" if Claude Desktop starts fine without it.
ARG CLAUDE_NO_SANDBOX=true

LABEL org.opencontainers.image.title="Claude Remote Desktop" \
      org.opencontainers.image.description="Browser-accessible Ubuntu XFCE desktop with Claude Desktop and Claude Code preinstalled" \
      org.opencontainers.image.licenses="MIT"

# ---- Prerequisites ----
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl gnupg ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# ---- Claude Desktop (official Anthropic apt repo; amd64 + arm64) ----
RUN curl -fsSLo /usr/share/keyrings/claude-desktop-archive-keyring.asc \
      https://downloads.claude.ai/claude-desktop/key.asc && \
    echo "deb [signed-by=/usr/share/keyrings/claude-desktop-archive-keyring.asc] https://downloads.claude.ai/claude-desktop/apt/stable stable main" \
      > /etc/apt/sources.list.d/claude-desktop.list && \
    apt-get update && \
    apt-get install -y claude-desktop && \
    rm -rf /var/lib/apt/lists/*

# ---- Run Claude Desktop with --no-sandbox inside the container ----
RUN if [ "$CLAUDE_NO_SANDBOX" = "true" ]; then \
      for f in /usr/share/applications/claude*.desktop; do \
        if [ -f "$f" ]; then sed -i -E 's|^(Exec=[^ ]*claude-desktop)|\1 --no-sandbox|' "$f"; fi; \
      done; \
      printf '#!/bin/sh\nexec /usr/bin/claude-desktop --no-sandbox "$@"\n' > /usr/local/bin/claude-desktop; \
      chmod +x /usr/local/bin/claude-desktop; \
    fi

# ---- Node.js + Claude Code (CLI) ----
RUN curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g @anthropic-ai/claude-code && \
    npm cache clean --force && \
    rm -rf /var/lib/apt/lists/*

# ---- Android perf tweaks (disable compositing/animations via autostart) ----
COPY bin/android-perf.sh /usr/local/bin/android-perf.sh
COPY autostart/android-perf.desktop /etc/xdg/autostart/android-perf.desktop
RUN chmod +x /usr/local/bin/android-perf.sh

# ---- Baked-in defaults: single source of truth ----
# Used as-is on Railway (which builds this Dockerfile and ignores Compose).
# docker-compose.yml only re-exposes the tuning knobs so .env can override them.
#
# NOTE: HARDEN_DESKTOP is intentionally NOT used. It bundles DISABLE_SUDO and
# DISABLE_TERMINALS, which would break Claude Code. For opt-in sudo lockdown
# see docker-compose.hardened.yml.

# Base + stream tuning (balanced mobile profile)
ENV PUID=1000 \
    PGID=1000 \
    TZ=Asia/Tehran \
    PIXELFLUX_WAYLAND=false \
    MAX_RES=1280x720 \
    SELKIES_ENCODER=x264enc-striped \
    SELKIES_FRAMERATE=24 \
    SELKIES_H264_CRF=30

# Android-friendly input / rendering
ENV SELKIES_USE_BROWSER_CURSORS="true|locked" \
    SELKIES_USE_CSS_SCALING="true" \
    SELKIES_SCALING_DPI="96|locked" \
    SELKIES_USE_PAINT_OVER_QUALITY="true|locked" \
    SELKIES_CLIPBOARD_ENABLED="true"

# Features off by default (bandwidth, clutter, attack surface)
ENV SELKIES_AUDIO_ENABLED="false|locked" \
    SELKIES_MICROPHONE_ENABLED="false|locked" \
    SELKIES_GAMEPAD_ENABLED="false|locked" \
    SELKIES_ENABLE_BINARY_CLIPBOARD="false|locked" \
    SELKIES_FILE_TRANSFERS="none|locked" \
    SELKIES_ENABLE_SHARING="false|locked" \
    SELKIES_SECOND_SCREEN="false|locked" \
    SELKIES_COMMAND_ENABLED="false|locked"

# Sidebar: keep only what a phone needs
ENV SELKIES_UI_SHOW_CORE_BUTTONS="false|locked" \
    SELKIES_UI_SIDEBAR_SHOW_AUDIO_SETTINGS="false|locked" \
    SELKIES_UI_SIDEBAR_SHOW_FILES="false|locked" \
    SELKIES_UI_SIDEBAR_SHOW_APPS="false|locked" \
    SELKIES_UI_SIDEBAR_SHOW_SHARING="false|locked" \
    SELKIES_UI_SIDEBAR_SHOW_GAMEPADS="false|locked" \
    SELKIES_UI_SIDEBAR_SHOW_STATS="false|locked" \
    SELKIES_UI_SIDEBAR_SHOW_GAMING_MODE="false|locked" \
    SELKIES_UI_SIDEBAR_SHOW_SCREEN_SETTINGS="true" \
    SELKIES_UI_SIDEBAR_SHOW_VIDEO_SETTINGS="true" \
    SELKIES_UI_SIDEBAR_SHOW_CLIPBOARD="true" \
    SELKIES_UI_SIDEBAR_SHOW_TRACKPAD="true" \
    SELKIES_UI_SIDEBAR_SHOW_FULLSCREEN="true" \
    SELKIES_UI_SIDEBAR_SHOW_KEYBOARD_BUTTON="true"

# webtop's base image already exposes:
#   3000 -> HTTP  (must be proxied)
#   3001 -> HTTPS
