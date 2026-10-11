#!/usr/bin/env bash
# Bien dich BaoCao_NhomX.tex bang pdfLaTeX va in so trang
set -uo pipefail
cd "$(dirname "$0")"
latexmk -pdf -interaction=nonstopmode -halt-on-error BaoCao_NhomX.tex >/dev/null 2>&1
rc=$?
echo "Errors: $(grep -a -c '^!' BaoCao_NhomX.log 2>/dev/null)  Overfull: $(grep -a -c 'Overfull' BaoCao_NhomX.log 2>/dev/null)"
[ -f BaoCao_NhomX.pdf ] && pdfinfo BaoCao_NhomX.pdf | grep Pages
# Trang so (dem tu Chuong 1 = trang 1) cua tung chuong / muc lon
python3 - <<'PY' 2>/dev/null
import re
for l in open('BaoCao_NhomX.toc',encoding='utf-8'):
    m=re.match(r'\\contentsline \{(chapter|section)\}\{(.*)\}\{(\w+)\}',l)
    if m:
        t=re.sub(r'\\numberline \{([^}]*)\}',r'\1 ',m.group(2))
        t=re.sub(r'\\[a-zA-Z]+|[{}]','',t)
        print(f"{'  ' if m.group(1)=='section' else ''}{t[:60]} ... {m.group(3)}")
PY
exit $rc
