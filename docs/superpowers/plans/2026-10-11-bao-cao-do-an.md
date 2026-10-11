# Báo cáo đồ án IE103 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Viết báo cáo đồ án Quản lý thư viện dài 20 trang nội dung chính, theo khung `BaoCao_NhomX_khung.pdf`, gồm hai bản Markdown và LaTeX cùng file PDF biên dịch từ bản LaTeX.

**Architecture:** Đầu tiên tạo bản sao CSDL `QUANLYTHUVIEN_BAOCAO`, chạy các script lấy kết quả trên bản sao và lưu output dạng text vào `docs/baocao/ketqua/`. Sau đó viết báo cáo theo từng chương, mỗi chương viết song song hai bản `.md` và `.tex`. Bản `.tex` được biên dịch bằng lualatex; kết thúc mỗi task phải biên dịch được và số trang không vượt ngân sách.

**Tech Stack:** SQL Server 2022 (Docker container `quanlythuvien_sqlserver`, chạy `sqlcmd` bên trong container), LuaLaTeX (fontspec, polyglossia tiếng Việt, TeX Gyre Termes, listings, tikz), `pdfinfo` và `pdftotext` để kiểm tra.

**Spec:** `docs/superpowers/specs/2026-10-11-bao-cao-do-an-design.md`

## Global Constraints

- Nội dung chính (Chương 1 đến hết Tài liệu tham khảo) dài 19–20 trang PDF; bìa, tóm tắt, phân công, mục lục, danh mục bảng/hình không tính.
- Phân bổ trang: Ch1 khoảng 2, Ch2 khoảng 4,5, Ch3 khoảng 1,5, Ch4 khoảng 10, Ch5 khoảng 1,5, TLTK khoảng 0,5.
- Không chạy bất kỳ lệnh ghi nào trên CSDL `QUANLYTHUVIEN`. Mọi EXEC/INSERT/UPDATE chỉ chạy trên `QUANLYTHUVIEN_BAOCAO`.
- Backup để tạo bản sao phải dùng `COPY_ONLY`, để không làm hỏng chuỗi differential backup của CSDL gốc.
- Bám theo code đang chạy: 11 bảng (`THELOAI, TACGIA, NHAXUATBAN, DAUSACH, DAUSACH_TACGIA, CUONSACH, DOCGIA, PHIEUMUON, CTPHIEUMUON, PHIEUPHAT, TAIKHOAN`), không có `NHANVIEN`. Hai bảng kết quả của Cursor (`DOCGIA_XEPLOAI`, `NHACNHO_QUAHAN`) được nhắc riêng.
- Thông tin nhóm và link video để khung giữ chỗ `[Họ tên SV1]`, `[MSSV 1]`, `[Link video]`. Giảng viên ghi: ThS. Nguyễn Thành Luân. Tên đề tài: XÂY DỰNG HỆ THỐNG QUẢN LÝ THƯ VIỆN.
- Diễn đạt lại bằng lời của nhóm, không chép nguyên văn slide hay README (Turnitin, ngưỡng 25%).
- Code trích dẫn trong báo cáo: font Courier cỡ 11 và chỉ lấy phần lõi.
- Mỗi mục trong 4.1 có đủ 4 phần: **Bài toán / Code / Kết quả / Giải thích**. Kết quả là bảng số liệu thật kèm dòng `[Chèn ảnh chụp ...]`.

## Review Focus

- Kết quả phụ thuộc ngày chạy: các SP dùng `GETDATE()` (ngày chạy là 2026-10-11), nên số ngày trễ, tiền phạt tạm tính và hạn thẻ trong báo cáo phải lấy từ output thật, không lấy từ comment mẫu trong code (comment ghi mốc 26/09/2026). Task 1 lưu ngày chạy vào `ketqua/00_ngaychay.txt`; Task 6 grep để chắc chắn không còn ngày giả định nào khác.
- Comment ví dụ trong `5_StoredProcedure.sql` và `4_Trigger.sql` dùng chữ ký cũ (`'NV02'`, 6 cột cho `PHIEUMUON`). Script lấy kết quả phải dùng chữ ký hiện tại. Task 1 có bước chạy và kiểm tra không có `Msg ... Level 16` ngoài các lỗi chủ ý do trigger chặn.
- Ký tự đặc biệt của LaTeX (`_`, `%`, `&`, `#`) có trong tên bảng, cột và số liệu. Mỗi task biên dịch phải không có lỗi (`grep -c '^!' BaoCao_NhomX.log` bằng 0).
- Tiếng Việt có dấu trong listings: listings không hỗ trợ UTF-8 nhiều byte. Phải bật `literate`/`extendedchars` hoặc chỉ dùng code không dấu. Task 2 kiểm tra bằng `pdftotext` rằng chuỗi `Độc giả` hiển thị đúng.
- Vượt ngân sách trang: mỗi task kiểm tra số trang lũy kế; Task 6 cắt bớt nếu vượt 20 trang.

---

## File Structure

```
docs/baocao/
  ketqua/
    00_ngaychay.txt          ngày chạy và số dòng từng bảng (bản sao)
    01_clone.sql             tạo bản sao (chỉ đọc gốc + COPY_ONLY backup)
    02_checksum.sql          checksum từng bảng của CSDL gốc
    10_sp.sql   / 10_sp.txt          5 SP: trước / chạy / sau
    20_trigger.sql / 20_trigger.txt  5 trigger
    30_function.sql / 30_function.txt
    40_cursor.sql / 40_cursor.txt
    50_security.sql / 50_security.txt
    60_report.sql / 60_report.txt    5 view
  BaoCao_NhomX.md
  BaoCao_NhomX.tex
  BaoCao_NhomX.pdf
  build.sh                   biên dịch + in số trang
```

Mọi file `.sql` trong `ketqua/` bắt đầu bằng `USE QUANLYTHUVIEN_BAOCAO` (trừ `01_clone.sql` và `02_checksum.sql`). Chạy bằng helper:

```bash
# docs/baocao/ketqua/run.sh <file.sql>  -> in kết quả ra stdout
#!/usr/bin/env bash
set -euo pipefail
f="$1"
docker cp "$f" quanlythuvien_sqlserver:/tmp/run.sql
docker exec quanlythuvien_sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P 'StrongPassword123!' -C -f 65001 -W -s ' | ' -i /tmp/run.sql
```

---

### Task 1: Bản sao CSDL và thu thập kết quả

**Files:**
- Create: `docs/baocao/ketqua/run.sh`, `01_clone.sql`, `02_checksum.sql`, `10_sp.sql`, `20_trigger.sql`, `30_function.sql`, `40_cursor.sql`, `50_security.sql`, `60_report.sql` và các file `.txt` output tương ứng, `00_ngaychay.txt`

**Interfaces:**
- Produces: các file `ketqua/*.txt`, là nguồn số liệu duy nhất cho các mục "Kết quả" ở Task 3–5.

- [ ] **Step 1: Ghi checksum của CSDL gốc (trước)**

`02_checksum.sql`:
```sql
USE QUANLYTHUVIEN
SET NOCOUNT ON
SELECT 'THELOAI' T, COUNT(*) N, CHECKSUM_AGG(BINARY_CHECKSUM(*)) C FROM THELOAI UNION ALL
SELECT 'TACGIA', COUNT(*), CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM TACGIA UNION ALL
SELECT 'NHAXUATBAN', COUNT(*), CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM NHAXUATBAN UNION ALL
SELECT 'DAUSACH', COUNT(*), CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM DAUSACH UNION ALL
SELECT 'DAUSACH_TACGIA', COUNT(*), CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM DAUSACH_TACGIA UNION ALL
SELECT 'CUONSACH', COUNT(*), CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM CUONSACH UNION ALL
SELECT 'DOCGIA', COUNT(*), CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM DOCGIA UNION ALL
SELECT 'PHIEUMUON', COUNT(*), CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM PHIEUMUON UNION ALL
SELECT 'CTPHIEUMUON', COUNT(*), CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM CTPHIEUMUON UNION ALL
SELECT 'PHIEUPHAT', COUNT(*), CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM PHIEUPHAT UNION ALL
SELECT 'TAIKHOAN', COUNT(*), CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM TAIKHOAN
```
Run: `bash docs/baocao/ketqua/run.sh docs/baocao/ketqua/02_checksum.sql > $SCRATCH/checksum_before.txt`
Expected: 11 dòng, không lỗi.

- [ ] **Step 2: Tạo bản sao**

`01_clone.sql`:
```sql
USE master
BACKUP DATABASE QUANLYTHUVIEN TO DISK = N'/var/opt/mssql/data/QLTV_baocao_src.bak'
  WITH COPY_ONLY, INIT, NAME = N'Ban sao phuc vu bao cao'
IF DB_ID('QUANLYTHUVIEN_BAOCAO') IS NOT NULL
BEGIN
  ALTER DATABASE QUANLYTHUVIEN_BAOCAO SET SINGLE_USER WITH ROLLBACK IMMEDIATE
  DROP DATABASE QUANLYTHUVIEN_BAOCAO
END
DECLARE @d NVARCHAR(128), @l NVARCHAR(128)
SELECT @d = name FROM sys.master_files WHERE database_id = DB_ID('QUANLYTHUVIEN') AND type = 0
SELECT @l = name FROM sys.master_files WHERE database_id = DB_ID('QUANLYTHUVIEN') AND type = 1
RESTORE DATABASE QUANLYTHUVIEN_BAOCAO FROM DISK = N'/var/opt/mssql/data/QLTV_baocao_src.bak'
  WITH MOVE @d TO N'/var/opt/mssql/data/QLTV_BAOCAO.mdf',
       MOVE @l TO N'/var/opt/mssql/data/QLTV_BAOCAO_log.ldf', RECOVERY
```
Run: `bash docs/baocao/ketqua/run.sh docs/baocao/ketqua/01_clone.sql`
Expected: `RESTORE DATABASE successfully processed`.

Ghi `00_ngaychay.txt`: kết quả của `SELECT CAST(GETDATE() AS DATE)` cùng số dòng 11 bảng trên bản sao (dùng lại truy vấn ở Step 1 nhưng đổi `USE QUANLYTHUVIEN_BAOCAO`).

- [ ] **Step 3: Viết và chạy các script lấy kết quả**

Mỗi script có cấu trúc: `PRINT '=== <tên mục> ==='`, rồi các SELECT trước, lệnh chạy, rồi các SELECT sau. Chọn đối tượng dữ liệu từ output của truy vấn chọn mẫu ở đầu mỗi script, không hard-code theo comment cũ.

`10_sp.sql`:
- SP_THEMDOCGIA: chạy `EXEC @kq = SP_THEMDOCGIA 'DG999', N'Trần Thị Mai', '2004-03-15', N'Nữ', N'Thủ Đức, TpHCM', '0909123456', NULL`, sau đó chạy lại lần hai để có `@kq = 0`. In dòng DG999.
- SP_LAPPHIEUMUON: chọn mẫu `SELECT TOP 1 MADG FROM DOCGIA WHERE TONGNO = 0 AND NGAYHETHAN >= CAST(GETDATE() AS DATE) ORDER BY MADG` và `SELECT TOP 2 MACS FROM CUONSACH WHERE TINHTRANG = N'Có sẵn' ORDER BY MACS`; in tình trạng hai cuốn trước; EXEC với `@MAPM OUTPUT`; in PHIEUMUON, CTPHIEUMUON và tình trạng hai cuốn sau.
- SP_TRASACH: chọn một dòng CTPHIEUMUON chưa trả và đã quá hạn (`PM.HANTRA < GETDATE()`); in trước; EXEC `N'Bình thường'` với `@TIENPHAT OUTPUT`; in PHIEUPHAT mới, tình trạng cuốn và TONGNO.
- SP_THANHTOANPHAT: chọn độc giả có `TONGNO > 0` ít phiếu nhất; in phiếu phạt chưa thanh toán và TONGNO trước; EXEC; in sau.
- SP_THONGKETHANG: `EXEC SP_THONGKETHANG 9, 2026, ...`, in 3 tham số ra và top 5.

`20_trigger.sql`, dùng `BEGIN TRY ... END TRY BEGIN CATCH SELECT ERROR_MESSAGE() END CATCH` cho các lệnh bị chặn:
- T1: in SOLUONG/SLCON của một đầu sách, `INSERT CUONSACH` một cuốn mới (`CS999`), in lại.
- T2: lập phiếu cho một độc giả thẻ hết hạn và một độc giả đang nợ, cả hai bị chặn, in thông báo lỗi.
- T3: thêm một cuốn có tình trạng `Hư hỏng` hoặc `Mất` vào phiếu, bị chặn, in thông báo lỗi.
- T4: lấy kết quả của SP_TRASACH ở trên, cộng thêm một lần trả "Hư hỏng" cho một cuốn khác chưa trả, để thấy phiếu phạt 50% giá.
- T5: in TONGNO trước/sau khi `UPDATE PHIEUPHAT SET DATHANHTOAN = 1` cho một phiếu.

`30_function.sql`: gọi 3 function với một độc giả đang mượn sách; `FN_TIENPHATTRE('2026-09-15','2026-09-26')` và `('2026-09-15','2026-09-10')`.

`40_cursor.sql`: `EXEC SP_CURSOR_XEPLOAIDOCGIA`, in thống kê `SELECT XEPLOAI, COUNT(*) FROM DOCGIA_XEPLOAI GROUP BY XEPLOAI` và 5 dòng mẫu; `EXEC SP_CURSOR_NHACNHOQUAHAN` (mặc định hôm nay), in số dòng và 3 dòng mẫu, rồi chạy lại lần hai để thấy 0 nhắc nhở mới.

`50_security.sql`: tạo login/user/role chỉ trên bản sao nếu chưa ánh xạ (login dùng chung server, đã tồn tại); thực hiện `ALTER USER U_THUTHU WITH LOGIN = LG_THUTHU` trên bản sao; `EXECUTE AS USER='U_THUTHU'` SELECT DOCGIA (được phép) và DELETE PHIEUPHAT (bị từ chối); `EXECUTE AS USER='U_DOCGIA'` SELECT DOCGIA (bị từ chối) và `EXEC SP_TIMSACH N'a'` (được phép); in bảng quyền từ `sys.database_permissions`; in `SELECT TENDANGNHAP, MATKHAU FROM TAIKHOAN` để thấy mật khẩu đã băm.

`60_report.sql`: `SELECT TOP 5 ...` của từng view `VW_BC_*`, cùng các tổng hợp dùng trong phần nhận xét (tổng số cuốn theo tình trạng, tháng có nhiều lượt mượn nhất, tỉ lệ tiền phạt theo lý do, số độc giả quá hạn).

Run từng file: `bash docs/baocao/ketqua/run.sh docs/baocao/ketqua/10_sp.sql > docs/baocao/ketqua/10_sp.txt` (tương tự cho các file còn lại).
Expected: không có `Msg` nào ngoại trừ các lỗi chặn có chủ ý của trigger và quyền; các lỗi đó phải xuất hiện đúng ở vị trí mong đợi.

- [ ] **Step 4: Xác minh CSDL gốc không đổi**

Run: `bash docs/baocao/ketqua/run.sh docs/baocao/ketqua/02_checksum.sql > $SCRATCH/checksum_after.txt && diff $SCRATCH/checksum_before.txt $SCRATCH/checksum_after.txt && echo UNCHANGED`
Expected: `UNCHANGED`.

- [ ] **Step 5: Commit**

```bash
git add docs/baocao/ketqua
git commit -m "docs(baocao): add result-collection scripts and outputs on DB copy"
```

### Task 2: Khung LaTeX, khung Markdown và phần đầu

**Files:**
- Create: `docs/baocao/BaoCao_NhomX.tex`, `docs/baocao/BaoCao_NhomX.md`, `docs/baocao/build.sh`

**Interfaces:**
- Produces: các macro trong `.tex`: `\anhgiucho{<mô tả>}` (khung chữ nhật xám có dòng `[Chèn ảnh chụp <mô tả>]`), môi trường listings style `sql`, `\muc{<nhãn>}` (in đậm "Bài toán:", "Code:"...). Màu heading `\definecolor{xanh}{HTML}{1F3864}`.

- [ ] **Step 1: build.sh**

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
latexmk -lualatex -interaction=nonstopmode -halt-on-error BaoCao_NhomX.tex >/dev/null
echo "Errors: $(grep -c '^!' BaoCao_NhomX.log || true)"
pdfinfo BaoCao_NhomX.pdf | grep Pages
# số trang nội dung chính = trang cuối - trang bắt đầu Chương 1 + 1
start=$(grep -oP '\\contentsline \{chapter\}\{.*?CHƯƠNG 1.*?\}\{\K[0-9]+' BaoCao_NhomX.toc | head -1)
echo "Chuong 1 bat dau trang so: $start"
```
Đánh số trang: phần đầu dùng số La Mã (`\pagenumbering{roman}`); từ Chương 1 chuyển sang số Ả Rập bắt đầu từ 1. Nhờ vậy, số trang của trang cuối chính là số trang nội dung chính.

- [ ] **Step 2: Preamble và phần đầu `.tex`**

```latex
\documentclass[13pt,a4paper,oneside]{extreport}
\usepackage[left=3cm,right=2cm,top=2cm,bottom=2cm]{geometry}
\usepackage{fontspec}\setmainfont{TeX Gyre Termes}\setmonofont{TeX Gyre Cursor}
\usepackage{polyglossia}\setmainlanguage{vietnamese}
\usepackage{xcolor,graphicx,tikz,array,tabularx,booktabs,longtable,caption,titlesec,setspace,enumitem,listings,hyperref}
\usetikzlibrary{positioning,arrows.meta,shapes}
\definecolor{xanh}{HTML}{1F3864}
\setstretch{1.2}
\titleformat{\chapter}[block]{\centering\bfseries\Large\color{xanh}}{CHƯƠNG \thechapter:}{0.5em}{\MakeUppercase}
\titlespacing*{\chapter}{0pt}{0pt}{12pt}
\titleformat{\section}{\bfseries\large\color{xanh}}{\thesection.}{0.5em}{}
\titleformat{\subsection}{\bfseries\itshape}{\thesubsection.}{0.5em}{}
\captionsetup[table]{name=Bảng,labelsep=colon,font=it}
\captionsetup[figure]{name=Hình,labelsep=colon,font=it}
\lstdefinestyle{sql}{language=SQL,basicstyle=\ttfamily\fontsize{11}{12}\selectfont,
  frame=single,breaklines=true,columns=fullflexible,keepspaces=true,
  extendedchars=true,inputencoding=utf8}
\lstset{style=sql}
\newcommand{\anhgiucho}[1]{\begin{center}\fbox{\parbox{0.8\textwidth}{\centering\color{gray}\itshape [Chèn ảnh chụp #1]}}\end{center}}
\newcommand{\muc}[1]{\textbf{#1:} }
\renewcommand{\contentsname}{\centering\color{xanh}MỤC LỤC}
\renewcommand{\listtablename}{\centering\color{xanh}DANH MỤC BẢNG}
\renewcommand{\listfigurename}{\centering\color{xanh}DANH MỤC HÌNH VẼ}
\renewcommand{\bibname}{TÀI LIỆU THAM KHẢO}
```
Phần thân: trang bìa theo trang 1 của khung (3 dòng tiêu đề trường, khung logo `\anhgiucho{logo trường}`, "BÁO CÁO ĐỒ ÁN QUẢN LÝ THÔNG TIN", tên đề tài, 4 dòng SV giữ chỗ, giảng viên ThS. Nguyễn Thành Luân, "Thành phố Hồ Chí Minh, tháng 10 năm 2026"); trang "BÁO CÁO TÓM TẮT" (mục 1–3, mỗi đề mục tóm tắt 1 dòng theo nội dung thật của từng chương); mục 4 "Phân công công việc" (bảng 4 dòng; cột nội dung gợi ý: SV1 Ch1, Ch2, 5.2–5.4; SV2 Ch3, 4.1.1–4.1.2; SV3 4.1.3–4.1.4, 4.2; SV4 4.3, Ch5); `\tableofcontents`, `\listoftables`, `\listoffigures`; sau đó `\pagenumbering{arabic}` và các `\chapter` rỗng cho Ch1–Ch5 cùng `\chapter*{TÀI LIỆU THAM KHẢO}` (dùng `\addcontentsline`).

- [ ] **Step 3: Kiểm tra tiếng Việt trong code và biên dịch**

Thêm tạm một listings có dòng `PRINT N'Độc giả không tồn tại.'`.
Run: `bash docs/baocao/build.sh && pdftotext docs/baocao/BaoCao_NhomX.pdf - | grep -c "Độc giả không tồn tại"`
Expected: `Errors: 0` và kết quả grep ≥ 1. Nếu kết quả bằng 0, thay listings bằng môi trường `Verbatim` của gói `fancyvrb` (`\begin{Verbatim}[frame=single,fontsize=\small]`). Với LuaLaTeX, môi trường này hiển thị UTF-8 trực tiếp. Biên dịch lại và grep lại. Chỉ xóa đoạn code thử sau khi đã thấy chữ hiển thị đúng.

- [ ] **Step 4: Khung `.md`**

Bản Markdown có cùng thứ tự: bìa (dạng text căn giữa bằng HTML `<div align="center">`), tóm tắt, phân công, mục lục viết tay (danh sách link anchor), danh mục bảng/hình, heading `# CHƯƠNG 1: MÔ TẢ BÀI TOÁN` ... Ảnh giữ chỗ dùng `> [Chèn ảnh chụp ...]`.

- [ ] **Step 5: Commit**

```bash
git add docs/baocao/BaoCao_NhomX.tex docs/baocao/BaoCao_NhomX.md docs/baocao/build.sh docs/baocao/BaoCao_NhomX.pdf
git commit -m "docs(baocao): add report skeleton with cover, summary and lists"
```

### Task 3: Chương 1 và Chương 2

**Files:**
- Modify: `docs/baocao/BaoCao_NhomX.tex`, `docs/baocao/BaoCao_NhomX.md`

**Interfaces:**
- Consumes: macro ở Task 2; `db/1_TaoBang.sql`, `db/4_Trigger.sql`, `db/7_AnToanThongTin.sql`, `frontend/src/App.tsx`.
- Produces: nhãn `\label{tab:thucthe}` (Bảng 2.1), `tab:rangbuoc` (Bảng 2.2), `fig:quytrinh` (Hình 1.1), `fig:erd` (Hình 2.1).

- [ ] **Step 1: Viết Chương 1 (cả hai bản)** theo đúng spec, mục 1.1–1.4. Các con số nghiệp vụ lấy từ code: tuổi tối thiểu 16 (`CK_DOCGIA_TUOI`), hạn thẻ 2 năm (`SP_THEMDOCGIA`), hạn trả 14 ngày (`SP_LAPPHIEUMUON`), 5.000đ/ngày (`FN_TIENPHATTRE`), hư 50%, mất 100% (`TRG_CTPM_TRASACH`). Hình 1.1 là flowchart TikZ gồm các bước: Độc giả yêu cầu mượn → Kiểm tra thẻ còn hạn và không nợ → Kiểm tra cuốn "Có sẵn" → Lập phiếu (hạn 14 ngày) → Trả sách → {Đúng hạn và bình thường: đóng phiếu | Trễ/Hư/Mất: lập phiếu phạt → Thanh toán}. Bản Markdown dùng `flowchart TD` mermaid có cùng các node.

- [ ] **Step 2: Viết Chương 2.** Bảng 2.1 có 11 dòng (Thực thể | Ý nghĩa | Thuộc tính chính). Bảng 2.2 có các ràng buộc lấy từ CHECK và trigger thật: `CK_DAUSACH_NAMXB/SOTRANG/GIA`, `CK_DAUSACH_SL`, `CK_CUONSACH_TINHTRANG`, `CK_DOCGIA_NGAYTHE`, `CK_DOCGIA_TUOI`, `CK_DOCGIA_EMAIL`, `CK_PHIEUMUON_HANTRA`, `CK_CTPM_TRASACH`, `CK_PHIEUPHAT_LYDO/SOTIEN`, các trigger T1–T5. ERD vẽ bằng TikZ: 11 hình chữ nhật (tên bảng và khóa chính), các đường nối có nhãn bản số (1,1)/(0,n) theo quan hệ trong `1_TaoBang.sql`; `TAIKHOAN` đứng riêng, không có khóa ngoại. Mục 2.5: 11 lược đồ, khóa chính dùng `\underline{}`, khóa ngoại dùng `\textit{}`, mỗi lược đồ một câu tân từ.

- [ ] **Step 3: Kiểm tra**

Run: `bash docs/baocao/build.sh && grep -c "NHANVIEN" docs/baocao/BaoCao_NhomX.tex docs/baocao/BaoCao_NhomX.md`
Expected: `Errors: 0`; grep cho kết quả 0 ở cả hai file; Chương 1 và 2 chiếm khoảng 6–7 trang (xem số trang bắt đầu Chương 3 trong `.toc`, phải ≤ 8).

- [ ] **Step 4: Commit**

```bash
git add docs/baocao/BaoCao_NhomX.*
git commit -m "docs(baocao): write chapters 1-2 (problem, analysis, ERD)"
```

### Task 4: Chương 3, mục 4.1.1 và 4.1.2

**Files:**
- Modify: `docs/baocao/BaoCao_NhomX.tex`, `docs/baocao/BaoCao_NhomX.md`

**Interfaces:**
- Consumes: `ketqua/00_ngaychay.txt`, `10_sp.txt`, `20_trigger.txt`; `db/1_TaoBang.sql`, `db/5_StoredProcedure.sql`, `db/4_Trigger.sql`.

- [ ] **Step 1: Chương 3.** Trích `CREATE TABLE DAUSACH` và `CTPHIEUMUON` (nguyên văn từ `1_TaoBang.sql`). Bảng số dòng (Bảng 3.1) lấy từ `00_ngaychay.txt`. Liệt kê các trường hợp dữ liệu bao quát. Hai `\anhgiucho` (Hình 3.1, 3.2).

- [ ] **Step 2: 4.1.1, 5 SP.** Mỗi SP gồm: **Bài toán** 1–2 câu; **Code** là phần lõi (bỏ PRINT thừa, giữ phần kiểm tra và câu lệnh chính, tối đa khoảng 15 dòng); **Kết quả** là bảng trước/sau lấy đúng giá trị trong `10_sp.txt` + `\anhgiucho{trước và sau khi chạy <tên SP>}`; **Giải thích** 2–3 câu.

- [ ] **Step 3: 4.1.2, 5 Trigger.** Cùng cấu trúc; thêm bảng tầm ảnh hưởng thu gọn (Bảng | Thêm | Xóa | Sửa) lấy từ comment trong `4_Trigger.sql`. Kết quả là thông báo lỗi thật hoặc số liệu trước/sau trong `20_trigger.txt`.

- [ ] **Step 4: Kiểm tra**

Run: `bash docs/baocao/build.sh` và đối chiếu ngẫu nhiên 3 số liệu trong báo cáo với `10_sp.txt` và `20_trigger.txt` bằng grep.
Expected: `Errors: 0`; các số liệu khớp; trang bắt đầu của mục 4.1.3 ≤ 14.

- [ ] **Step 5: Commit**

```bash
git add docs/baocao/BaoCao_NhomX.*
git commit -m "docs(baocao): write chapter 3 and stored procedures, triggers"
```

### Task 5: Mục 4.1.3, 4.1.4, 4.2 và 4.3

**Files:**
- Modify: `docs/baocao/BaoCao_NhomX.tex`, `docs/baocao/BaoCao_NhomX.md`

**Interfaces:**
- Consumes: `ketqua/30_function.txt`, `40_cursor.txt`, `50_security.txt`, `60_report.txt`; `db/3_Function.sql`, `db/6_Cursor.sql`, `db/7_AnToanThongTin.sql`, `db/8_Report.sql`; `frontend/src/components/features/reports/*.tsx`.

- [ ] **Step 1: 4.1.3 Function và 4.1.4 Cursor**, cùng cấu trúc 4 phần. Cursor chỉ trích phần DECLARE/FETCH/WHILE và phần xếp loại.
- [ ] **Step 2: 4.2.1–4.2.4.** Xác thực: LOGIN SQL và `TAIKHOAN` (mật khẩu băm, kèm kết quả cột MATKHAU dạng hex trong `50_security.txt`). Phân quyền: Bảng 4.x Role | Quyền được cấp | Quyền bị từ chối, cùng kết quả `EXECUTE AS`. Import/Export: lệnh `BULK INSERT` và `bcp` lấy từ code, `\anhgiucho`. Backup/Restore: `SP_SAOLUU`, thứ tự FULL rồi DIFF, NORECOVERY rồi RECOVERY, và lưu ý `ALTER USER ... WITH LOGIN`.
- [ ] **Step 3: 4.3, 5 report.** Đoạn mở đầu nêu công cụ (trang Báo cáo của website: React + Recharts, dữ liệu lấy qua API từ các view, không lưu sẵn dữ liệu). Mỗi report gồm tên, view nguồn, `\anhgiucho` (Hình 4.x) và 1–2 câu nhận xét có số liệu thật từ `60_report.txt`.
- [ ] **Step 4: Kiểm tra**

Run: `bash docs/baocao/build.sh`
Expected: `Errors: 0`; Chương 4 kết thúc trước trang 19 (trang bắt đầu Chương 5 trong `.toc` ≤ 19).

- [ ] **Step 5: Commit**

```bash
git add docs/baocao/BaoCao_NhomX.*
git commit -m "docs(baocao): write functions, cursors, security and reports"
```

### Task 6: Chương 5, tài liệu tham khảo và hoàn thiện

**Files:**
- Modify: `docs/baocao/BaoCao_NhomX.tex`, `docs/baocao/BaoCao_NhomX.md`, `docs/baocao/BaoCao_NhomX.pdf`

- [ ] **Step 1: Chương 5.** 5.1: công nghệ (React 19, Vite, Tailwind, shadcn/ui; ASP.NET Core; .NET Aspire; SQL Server 2022 Docker), cách chạy (lệnh trong README: `docker compose up -d`, `npm install`, `dotnet run --project QuanLyThuVien.AppHost`), `\anhgiucho` cho màn hình đăng nhập, sách, mượn/trả, báo cáo. 5.2 Kết quả đạt được (đủ số lượng SP/Trigger/Function/Cursor/Report theo yêu cầu). 5.3 Hạn chế (trung thực, như spec). 5.4 Hướng phát triển. 5.5 `Link video: [Link Google Drive]`.
- [ ] **Step 2: Tài liệu tham khảo (IEEE).** [1]–[4] là 4 giáo trình trong slide môn học (tác giả, tên, NXB, năm, đúng như trong `NoiDungHoc/Slide.md/00 - Gioi thieu.md`); [5] Microsoft, "SQL Server technical documentation", learn.microsoft.com; [6] Microsoft, "CREATE TRIGGER (Transact-SQL)"; [7] Khoa KH&KTTT, "Slide bài giảng IE103 – Quản lý thông tin", ĐH CNTT, 2026.
- [ ] **Step 3: Kiểm tra cuối**

Run:
```bash
bash docs/baocao/build.sh
grep -c "^!" docs/baocao/BaoCao_NhomX.log
pdftotext docs/baocao/BaoCao_NhomX.pdf - | grep -ciE "TODO|TBD"
grep -nE "NV02|26/09/2026 là hôm nay|NHANVIEN" docs/baocao/BaoCao_NhomX.tex docs/baocao/BaoCao_NhomX.md
```
Expected: `Errors: 0`; số trang của trang cuối (đánh số Ả Rập) nằm trong 19–20; grep TODO/TBD cho 0; grep cuối không ra dòng nào. Nếu vượt 20 trang: rút ngắn code của 4.1 (bỏ các dòng khai báo biến), thu nhỏ bảng trước/sau xuống còn 3 dòng, sau đó build lại. Nếu dưới 19 trang: bổ sung phần Giải thích cho các mục trong 4.2.

- [ ] **Step 4: Kiểm tra CSDL gốc lần cuối** bằng lệnh `diff` checksum như Task 1 Step 4. Expected: `UNCHANGED`.

- [ ] **Step 5: Commit**

```bash
git add docs/baocao
git commit -m "docs(baocao): write chapter 5, references; finalize 20-page report"
```
