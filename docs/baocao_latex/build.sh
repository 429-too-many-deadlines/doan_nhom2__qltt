#!/usr/bin/env bash
# Bien dich bao cao: lualatex 2 luot, -shell-escape cho minted (can python3-pygments). (luot 2 cap nhat muc luc, danh muc bang/hinh).
# Font Times New Roman / Courier New lay tu ./fonts/ hoac /mnt/c/Windows/Fonts/.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build
for i in 1 2; do
  lualatex -shell-escape -interaction=nonstopmode -halt-on-error -output-directory=build BaoCao_NhomX.tex >/dev/null \
    || { tail -40 build/BaoCao_NhomX.log; exit 1; }
done
cp build/BaoCao_NhomX.pdf BaoCao_NhomX.pdf
echo "OK: $(pdfinfo BaoCao_NhomX.pdf | awk '/^Pages/{print $2}') trang -> BaoCao_NhomX.pdf"
