# Thiết kế: Slide thuyết trình đồ án IE103 – Quản lý thư viện

Ngày: 2026-10-12

## Mục tiêu

Làm bộ slide HTML để nộp (file `01 Slides_NhomX.pdf`) và dùng khi quay video
thuyết trình 15–20 phút cho đồ án Quản lý thư viện (CSDL `QUANLYTHUVIEN`).
Slide đi theo cấu trúc của `BaoCao_NhomX_khung.pdf`: bìa, tóm tắt, Chương 1–5,
tài liệu tham khảo.

## Ràng buộc

- Tổng cộng **19 slide**, nằm trong mức 15–20 slide mà `FinalProject_Note_2026.md` yêu cầu.
- Nội dung và số liệu lấy từ `docs/baocao/BaoCao_NhomX.md` (bản sao CSDL chụp ngày
  11/10/2026), để slide khớp với báo cáo nộp kèm. Không truy vấn lại CSDL.
- Tên bảng, cột, SP, trigger, function, cursor, view phải khớp với thư mục `db/`.
  Bản kiểm tra ngày 12/10 cho kết quả: commit `071729c` chỉ sửa chú thích và đánh số,
  tên các đối tượng không đổi.
- Họ tên, MSSV, số nhóm và link video để dạng `[...]` như báo cáo.
  Giảng viên: ThS. Nguyễn Thành Luân.
- Một file HTML tự chứa: CSS và JS viết trong file, không dùng thư viện JS hay CDN.
  Ngoại lệ duy nhất là Google Fonts, có font hệ thống dự phòng khi không có mạng.

## Đầu ra

Thư mục `docs/slide/`:

- `Slides_NhomX.html`: bộ slide.
- `Slides_NhomX.pdf`: in từ file HTML bằng Chrome/Chromium headless, mỗi slide một trang 1280×720.

## Dàn ý

Không có slide ngăn cách chương. Mỗi slide hiển thị nhãn chương và thanh tiến độ.

| # | Khung | Nội dung |
|---|---|---|
| 1 | Bìa | ĐHQG-HCM / UIT / Khoa KH&KTTT; "BÁO CÁO ĐỒ ÁN QUẢN LÝ THÔNG TIN"; "XÂY DỰNG HỆ THỐNG QUẢN LÝ THƯ VIỆN"; 4 thành viên `[...]`; GV; TP.HCM, 10/2026 |
| 2 | Tóm tắt | Bảng thành viên (MSSV, họ tên, ghi chú) và phân công, theo báo cáo |
| 3 | Mục lục | 5 chương dạng thẻ đánh số, mỗi thẻ ghi các mục con chính |
| 4 | 1.1–1.3 | 4 khó khăn khi quản lý thủ công → 5 mục tiêu → 3 đối tượng sử dụng, mỗi đối tượng ứng với một role R_QUANLY, R_THUTHU, R_DOCGIA |
| 5 | 1.4 | Sơ đồ quy trình SVG theo Hình 1.1 và các quy tắc: đủ 16 tuổi, thẻ có hạn 2 năm, hạn trả 14 ngày, phạt 5.000đ/ngày, hư 50% giá, mất 100% giá |
| 6 | 2.1 | 8 nhóm chức năng dạng lưới có icon: xác thực, danh mục, kho sách, độc giả, mượn–trả, nhắc nhở và xếp loại, báo cáo, quản trị CSDL |
| 7 | 2.2 + 2.4 | ERD SVG gồm 11 thực thể theo Hình 2.1 (TAIKHOAN đứng riêng), có ghi bản số |
| 8 | 2.3 | 17 ràng buộc: cột trái là RB 1–12 (18 CHECK, 2 UNIQUE), cột phải là RB 13–17 (5 trigger) |
| 9 | 2.5 | 11 lược đồ quan hệ: khóa chính gạch chân, khóa ngoại in nghiêng, mỗi lược đồ kèm tân từ một dòng |
| 10 | 3.1–3.2 | SQL Server 2022 trên Docker, collation `Vietnamese_CI_AS`; chuỗi script 1→8; trích `CREATE TABLE DAUSACH`; Bảng 3.1 (số dòng); các tình huống dữ liệu biên (DG006, DG009, CS015, DS016...) |
| 11 | 4.1.1 | Bảng 5 SP nghiệp vụ (tên, loại tham số, mã trả về); code lõi `SP_LAPPHIEUMUON`; kết quả trước/sau (PM0329, SLCON 2→0); ghi chú tổng cộng 38 SP |
| 12 | 4.1.2 | Bảng 5 trigger (bảng và sự kiện, tầm ảnh hưởng); code lõi `TRG_CTPM_TRASACH`; kết quả trả CS003: PP0012 55.000đ, PP0013 35.000đ, TONGNO của DG014 = 90.000 |
| 13 | 4.1.3–4.1.4 | 5 thẻ: FN_SOSACHDANGMUON, FN_TIENPHATTRE, FN_LICHSUMUON, SP_CURSOR_XEPLOAIDOCGIA (119 độc giả: 101/6/5/5/2), SP_CURSOR_NHACNHOQUAHAN (4 nhắc nhở, DG004 trễ 17 ngày); mỗi thẻ có mục đích, chữ ký hàm hoặc đoạn code ngắn, kết quả |
| 14 | 4.2 | 4 ô: Xác thực (login SQL, SHA2-256, SP_DANGNHAP 0/1/2), Phân quyền (Bảng 4.2 rút gọn và kết quả permission denied), Import/Export (BULK INSERT, bcp), Backup/Restore (FULL + DIFF, NORECOVERY → RECOVERY, 818 trang, khoảng 6,46 MB) |
| 15 | 4.3 | 5 report, mỗi report gồm biểu đồ SVG nhỏ vẽ từ số liệu báo cáo, tên view và một dòng nhận xét: kho 13/10/2/1 (donut); top sách Mắt biếc 5, ba đầu sách 4 (cột ngang); lượt mượn T4–T9 3,3,7,7,7,11 (đường); phạt 498.000đ, đã thu 233.000đ, chưa thu 265.000đ (cột); quá hạn 6 cuốn / 5 độc giả, DG001 26 ngày (bảng) |
| 16 | 5.1 | Sơ đồ kiến trúc React 19 + Vite → ASP.NET Core (.NET 10, Dapper) → SQL Server 2022, điều phối bằng .NET Aspire; luồng demo B1–B5; 4 khung `[Chèn ảnh màn hình ...]` (đăng nhập, sách, mượn–trả, báo cáo) |
| 17 | 5.2–5.4 | 3 cột Kết quả, Hạn chế, Hướng phát triển, rút gọn từ báo cáo |
| 18 | 5.5 + TLTK | Link video `[Dán link Google Drive]`; 7 tài liệu tham khảo theo chuẩn IEEE |
| 19 | – | Cảm ơn / Hỏi đáp |

Code trên slide chỉ lấy phần lõi, mỗi đoạn 10–14 dòng. Kết quả trình bày bằng thẻ số liệu
hoặc bảng trước/sau. Chỉ slide 16 có khung chèn ảnh.

## Giao diện

- **Màu** (CSS variables trên `:root`):
  - Nền `#F8FAFC`, thẻ trắng có viền `#E2E8F0` và bóng mềm.
  - Màu chính `#2563EB`; màu phụ `#0EA5E9`, `#10B981`.
  - Nhấn và cảnh báo `#F59E0B`; lỗi `#EF4444` ở dạng nhạt; chữ `#0F172A` / `#475569`.
- **Trang trí:** lưới chấm mờ ở nền; vệt gradient xanh ở một góc; icon kiểu Lucide vẽ bằng SVG inline.
- **Font:** Be Vietnam Pro cho chữ thường, JetBrains Mono cho code, cả hai lấy từ Google Fonts;
  dự phòng Segoe UI / system-ui và Consolas / monospace.
- **Code SQL:** nền `#F1F5F9`; từ khóa, chuỗi, chú thích và tên đối tượng được tô màu bằng
  `<span class>` viết tay.
- **Bố cục:**
  - Khung 1280×720, co giãn theo cửa sổ bằng `transform: scale` và luôn nằm giữa màn hình.
  - Header: nhãn chương và tiêu đề. Footer: "Nhóm X · IE103 – Quản lý thông tin", số trang `n / 19`
    và thanh tiến độ.
  - Slide bìa và slide cảm ơn có bố cục riêng, dùng khối gradient lớn.

## Điều hướng và in

- **Phím:** ←/→, Space, PageUp/PageDown, Home/End; `F` bật toàn màn hình. Hash `#n` mở thẳng
  slide n và được cập nhật khi chuyển slide.
- **In:** `@media print` với `@page { size: 1280px 720px; margin: 0 }`; hiện mọi slide, bỏ phần co
  giãn, mỗi slide ngắt sang trang mới, đặt `print-color-adjust: exact`.

## Tiêu chí hoàn thành

- Mở `Slides_NhomX.html` trong trình duyệt: điều hướng bằng phím hoạt động; không có slide nào
  bị tràn chữ hay nội dung đè lên nhau (kiểm tra bằng ảnh chụp từng slide qua Chrome headless).
- `Slides_NhomX.pdf` có đúng 19 trang, khổ 1280×720, giữ nguyên màu nền.
- Mọi tên đối tượng và số liệu trên slide khớp với `docs/baocao/BaoCao_NhomX.md` và `db/`.
- Không chạy lệnh ghi nào trên CSDL.
