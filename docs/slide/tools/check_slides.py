#!/usr/bin/env python3
"""Kiem tra tinh docs/slide/Slides_NhomX.html.

- So slide: dung 19 (hoac it nhat N khi dung --upto N).
- Moi slide 1..N chua cac chuoi bat buoc trong REQUIRED.
- Khong dung <script src>, chi cho phep <link> toi Google Fonts.
- Khong co the HTML nam ben trong <pre> (dau '<' trong code phai viet &lt;).
"""
import argparse
import re
import sys
from html.parser import HTMLParser
from pathlib import Path

HTML = Path(__file__).resolve().parent.parent / "Slides_NhomX.html"
TOTAL = 19
FONT_HOSTS = ("https://fonts.googleapis.com", "https://fonts.gstatic.com")

REQUIRED = {
    1: ["XÂY DỰNG HỆ THỐNG", "QUẢN LÝ THƯ VIỆN", "ThS. Nguyễn Thành Luân", "[MSSV 1]",
        "tháng 10 năm 2026", "TRƯỜNG ĐẠI HỌC CÔNG NGHỆ THÔNG TIN"],
    2: ["Nhóm trưởng", "Chương 1; Chương 2; mục 5.2 – 5.4", "Chương 3; mục 4.1.1 – 4.1.2",
        "Mục 4.1.3 – 4.1.4; mục 4.2", "Mục 4.3; mục 5.1, 5.5", "38"],
    3: ["Mô tả bài toán", "Phân tích và thiết kế", "Cài đặt", "Quản lý thông tin",
        "Demo và kết luận", "Tài liệu tham khảo"],
    4: ["R_QUANLY", "R_THUTHU", "R_DOCGIA", "admin"],
    5: ["16 tuổi", "2 năm", "14 ngày", "5.000đ", "50%", "100%", "Có sẵn"],
    6: ["Xác thực", "Quản lý danh mục", "Quản lý kho sách", "Quản lý độc giả", "Mượn – trả",
        "Nhắc nhở", "Báo cáo", "Quản trị CSDL"],
    7: ["THELOAI", "TACGIA", "NHAXUATBAN", "DAUSACH", "DAUSACH_TACGIA", "CUONSACH",
        "DOCGIA", "PHIEUMUON", "CTPHIEUMUON", "PHIEUPHAT", "TAIKHOAN"],
    8: ["18 CHECK", "2 UNIQUE", "TRG_CUONSACH_CAPNHATSL", "TRG_PHIEUMUON_KIEMTRA",
        "TRG_CTPM_MUONSACH", "TRG_CTPM_TRASACH", "TRG_PHIEUPHAT_TONGNO"],
    9: ["TENDANGNHAP", "SHA2-256", "NGAYHETHAN", "TINHTRANGTRA", "DATHANHTOAN"],
    10: ["Vietnamese_CI_AS", "SQL Server 2022", "CREATE TABLE DAUSACH", "118", "DG009", "CS015"],
    11: ["SP_THEMDOCGIA", "SP_LAPPHIEUMUON", "SP_TRASACH", "SP_THANHTOANPHAT",
         "SP_THONGKETHANG", "PM0329", "38"],
    12: ["TRG_CTPM_TRASACH", "TRG_PHIEUPHAT_TONGNO", "55.000", "35.000", "90.000", "DG006"],
    13: ["FN_SOSACHDANGMUON", "FN_TIENPHATTRE", "FN_LICHSUMUON", "SP_CURSOR_XEPLOAIDOCGIA",
         "SP_CURSOR_NHACNHOQUAHAN", "DOCGIA_XEPLOAI", "NHACNHO_QUAHAN", "119"],
    14: ["SHA2_256", "SP_DANGNHAP", "BULK INSERT", "bcp", "NORECOVERY", "SP_SAOLUU",
         "LG_THUTHU"],
    15: ["VW_BC_TINHTRANGKHO", "VW_BC_SACHMUONNHIEU", "VW_BC_LUOTMUON_THANG",
         "VW_BC_TIENPHAT_THANG", "VW_BC_DOCGIA_QUAHAN", "498.000", "Mắt biếc"],
    16: ["React", "ASP.NET Core", "Dapper", ".NET Aspire", "B1", "B5", "[Chèn ảnh"],
    17: ["Kết quả đạt được", "Hạn chế", "Hướng phát triển"],
    18: ["[Dán link Google Drive", "[1]", "[7]"],
    19: ["Cảm ơn"],
}


class SlideText(HTMLParser):
    def __init__(self):
        super().__init__()
        self.slides, self.links, self.scripts, self.pre_tags = [], [], [], []
        self.depth = 0
        self.in_pre = False

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag == "link":
            self.links.append(a.get("href") or "")
        if tag == "script" and a.get("src"):
            self.scripts.append(a["src"])
        if self.in_pre:
            self.pre_tags.append((len(self.slides), tag))
        if tag == "pre":
            self.in_pre = True
        if tag == "section":
            if self.depth:
                self.depth += 1
            elif "slide" in (a.get("class") or "").split():
                self.slides.append("")
                self.depth = 1

    def handle_endtag(self, tag):
        if tag == "pre":
            self.in_pre = False
        if tag == "section" and self.depth:
            self.depth -= 1

    def handle_data(self, data):
        if self.depth:
            self.slides[-1] += data + " "


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--upto", type=int, default=TOTAL)
    upto = ap.parse_args().upto
    if not HTML.exists():
        print(f"FAIL: khong tim thay {HTML}")
        sys.exit(1)
    p = SlideText()
    p.feed(HTML.read_text(encoding="utf-8"))
    errors = []
    count = len(p.slides)
    if upto == TOTAL and count != TOTAL:
        errors.append(f"can dung {TOTAL} slide, hien co {count}")
    if count < upto:
        errors.append(f"can it nhat {upto} slide, hien co {count}")
    for i in range(1, min(upto, count) + 1):
        text = re.sub(r"\s+", " ", p.slides[i - 1])
        for s in REQUIRED[i]:
            if s not in text:
                errors.append(f"slide {i}: thieu '{s}'")
    for src in p.scripts:
        errors.append(f"khong duoc dung script ngoai: {src}")
    for href in p.links:
        if not href.startswith(FONT_HOSTS):
            errors.append(f"link ngoai khong hop le: {href}")
    for slide_no, tag in p.pre_tags:
        errors.append(f"slide {slide_no}: co the <{tag}> trong <pre> (escape '<' thanh &lt;)")
    if errors:
        print("FAIL")
        for e in errors:
            print(" -", e)
        sys.exit(1)
    print(f"OK: {count} slide, da kiem tra noi dung slide 1-{min(upto, count)}")


if __name__ == "__main__":
    main()
