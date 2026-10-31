# Security policy

## Supported deployment

This project exposes a complete Linux desktop through a browser. The underlying webtop session includes a terminal and passwordless `sudo` inside the container. It must not be exposed to the public Internet without authentication, HTTPS, and an appropriately configured reverse proxy.

The production Compose file requires `WEBTOP_USER` and `WEBTOP_PASSWORD`. Keep these values in Railway Variables, Docker secrets, or a local `.env` file that is never committed. Use `docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build` only for local development.

## Hardening

The terminal is intentionally kept available because a desktop without a terminal is not very useful, so webtop's `HARDEN_DESKTOP` is not used (it disables both `sudo` and terminals). Instead:

- File transfer, session sharing, the Apps panel, command messages, audio, microphone and gamepad are disabled and locked by default.
- `docker-compose.hardened.yml` is an opt-in overlay that sets `DISABLE_SUDO=true`.
- If you build with `INSTALL_CLAUDE_DESKTOP=true`, do not enable `DISABLE_OPEN_TOOLS` before signing in to Claude, since sign-in uses `xdg-open`.
- When installed, Claude Desktop runs with `--no-sandbox` inside the container (build arg `CLAUDE_NO_SANDBOX`). This is a deliberate trade-off for Docker's default seccomp profile; the container boundary is the main isolation layer.
- Never mount `/var/run/docker.sock` or run with `--privileged`/`seccomp=unconfined` unless you accept that anyone who can log in gains control of the host.

## GitHub Codespaces

The `.devcontainer` setup forwards port 3000 through Codespaces' HTTPS tunnel. Forwarded ports are private by default, so only the signed-in owner of the codespace can open them, and webtop's own basic auth is not configured there. Never change the port visibility to Public: anyone with the URL would get a desktop with passwordless `sudo`.

## Architectures

The image builds for `linux/amd64` and `linux/arm64`; CI builds both. The optional Claude Desktop package (Linux beta) is published for the same two architectures.

## Reporting a vulnerability

Do not publish credentials, tokens, private URLs, or a working exploit in a public issue. Contact the repository owner privately through GitHub with reproduction steps, affected commit, impact, and a suggested mitigation.
