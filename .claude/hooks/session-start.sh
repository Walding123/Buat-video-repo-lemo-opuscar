#!/bin/bash
# Cloud sessions only: make the machine ready to render films (ffmpeg 7+, core packages).
set -euo pipefail
[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0
cd "${CLAUDE_PROJECT_DIR:-.}"

# ffmpeg 7+ and ffprobe: Ubuntu 24.04 only ships 6.1, which mux.sh rejects. Install a static build if needed.
major=$(ffmpeg -version 2>/dev/null | sed -n '1s/^ffmpeg version n\{0,1\}\([0-9][0-9]*\)\..*/\1/p' || true)
if [ -z "$major" ] || [ "$major" -lt 7 ] || ! command -v ffprobe >/dev/null; then
  tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/ff.tar.xz" https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
  tar xf "$tmp/ff.tar.xz" -C "$tmp"
  install -m 755 "$tmp"/ffmpeg-*-static/ffmpeg "$tmp"/ffmpeg-*-static/ffprobe /usr/local/bin/
  rm -rf "$tmp"
fi

# Core packages (Node, headless browser, Python core tier): only when not installed yet.
if [ ! -f node_modules/.lemo-ok ] || [ ! -f .venv/.lemo-core ]; then
  sh plugin/skills/lemo-opuscar/scripts/setup.sh deps
fi
