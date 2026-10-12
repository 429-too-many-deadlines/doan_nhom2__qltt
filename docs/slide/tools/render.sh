#!/usr/bin/env bash
# Dung Microsoft Edge (Windows) o che do headless tu WSL de:
#   check : do tran chu (mo ?check, doc thuoc tinh data-overflow)
#   shots : chup anh tung slide vao docs/slide/.shots/ (tuy chon kich thuoc WxH)
#   pdf   : in ra docs/slide/Slides_NhomX.pdf
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
HTML="$DIR/Slides_NhomX.html"
EDGE="${EDGE:-/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe}"

win() { wslpath -w "$1"; }
url() { echo "file:///$(win "$HTML" | sed 's#\\#/#g')"; }
edge() {
  timeout 120 "$EDGE" --headless=new --disable-gpu --hide-scrollbars \
    --run-all-compositor-stages-before-draw --virtual-time-budget=8000 "$@" 2>/dev/null
}

case "${1:-}" in
  check)
    out="$(edge --window-size=1280,720 --dump-dom "$(url)?check")"
    res="$(grep -o 'data-overflow="[^"]*"' <<<"$out" | head -1 || true)"
    echo "${res:-data-overflow chua duoc ghi}"
    grep -o 'data-overflow-detail="[^"]*"' <<<"$out" | head -1 || true
    [[ "$res" == 'data-overflow="none"' ]]
    ;;
  shots)
    size="${2:-1280,720}"
    dest="$DIR/.shots"
    mkdir -p "$dest"
    n="$(grep -c '<section class="slide' "$HTML")"
    for i in $(seq 1 "$n"); do
      edge --window-size="$size" \
        --screenshot="$(win "$dest")\\slide-$(printf %02d "$i").png" "$(url)#$i" >/dev/null
    done
    ls "$dest"
    ;;
  pdf)
    edge --no-pdf-header-footer --print-to-pdf="$(win "$DIR/Slides_NhomX.pdf")" "$(url)" >/dev/null
    pdfinfo "$DIR/Slides_NhomX.pdf" | grep -E 'Pages|Page size'
    ;;
  *)
    echo "Dung: render.sh check | shots [W,H] | pdf"
    exit 2
    ;;
esac
