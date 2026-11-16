#!/bin/bash
# Installs ffmpeg 9 (from the PyPI package imageio-ffmpeg) in cloud sessions.
# The library's tools need ffmpeg 7+; the system ffmpeg is 6.x.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

ffv=$(ffmpeg -version 2>/dev/null | sed -n '1s/^ffmpeg version n\{0,1\}\([0-9][0-9]*\)\..*/\1/p' || true)
if [ -n "$ffv" ] && [ "$ffv" -ge 7 ]; then
  exit 0
fi

[ -x /opt/ffmpeg-venv/bin/python ] || python3 -m venv /opt/ffmpeg-venv
/opt/ffmpeg-venv/bin/pip install -q --disable-pip-version-check imageio-ffmpeg
ln -sf "$(/opt/ffmpeg-venv/bin/python -c 'import imageio_ffmpeg as i; print(i.get_ffmpeg_exe())')" /usr/local/bin/ffmpeg
ffmpeg -version | head -1 >&2
