# Thiết kế: Báo cáo đồ án IE103 – Quản lý thư viện

Ngày: 2026-10-11

## Mục tiêu

Viết báo cáo đồ án môn IE103 cho đề tài Quản lý thư viện (CSDL `QUANLYTHUVIEN`),
theo đúng cấu trúc `BaoCao_NhomX_khung.pdf`, dựa trên yêu cầu đồ án trong
`NoiDungHoc/DoAn.md/` và mã nguồn hiện tại (thư mục `db/`, frontend, backend).

## Ràng buộc

- Nội dung chính dài **20 trang**, tính từ Chương 1 đến hết Tài liệu tham khảo.
  Bìa, báo cáo tóm tắt, phân công, mục lục, danh mục bảng và danh mục hình không tính.
- Bài nộp bị kiểm tra trùng lặp (Turnitin, ngưỡng 25%), nên nội dung phải được
  diễn đạt lại, không chép nguyên văn slide hay README.
- Báo cáo bám theo **code đang chạy**, không theo README. README đã cũ: vẫn mô tả
  13 bảng và có `NHANVIEN`. Schema hiện tại có 11 bảng và chỉ một tài khoản quản trị.
- Họ tên, MSSV, số nhóm, phân công và link video để khung giữ chỗ dạng `[...]`.
  Giảng viên ghi: ThS. Nguyễn Thành Luân.

## Đầu ra

Thư mục `docs/baocao/`:

- `BaoCao_NhomX.md`: bản Markdown, ERD và sơ đồ quy trình vẽ bằng mermaid.
- `BaoCao_NhomX.tex`: bản LaTeX, biên dịch bằng lualatex với font TeX Gyre Termes;
  ERD và sơ đồ quy trình vẽ bằng TikZ; code dùng font Courier cỡ 11; caption
  "Bảng x.y" và "Hình x.y"; có mục lục, danh mục bảng, danh mục hình tự sinh.
- `BaoCao_NhomX.pdf`: biên dịch từ file `.tex`.

Hai bản được viết song song bằng tay, không cần giữ đồng bộ tuyệt đối.

## Nguồn số liệu "Kết quả"

- Restore một bản sao của CSDL đang chạy (container `quanlythuvien_sqlserver`)
  thành `QUANLYTHUVIEN_BAOCAO` trong cùng container, rồi chạy SP, Trigger, Function,
  Cursor và Report trên bản sao này. **Không chạy lệnh ghi nào trên CSDL gốc.**
- Kết quả thật được đưa vào báo cáo dưới dạng bảng nhỏ (trước/sau). Mỗi mục có
  thêm khung `[Chèn ảnh chụp ...]` để nhóm tự chèn ảnh.

## Cấu trúc và phân bổ trang

### Phần đầu (không tính trang)
Bìa (tên đề tài: XÂY DỰNG HỆ THỐNG QUẢN LÝ THƯ VIỆN); báo cáo tóm tắt (mỗi đề mục
tóm tắt một dòng, bảng thành viên); bảng phân công; mục lục; danh mục bảng; danh mục hình.

### Chương 1: Mô tả bài toán (khoảng 2 trang)
- 1.1 Phát biểu bài toán: bối cảnh, khó khăn khi quản lý thủ công, phạm vi hệ thống.
- 1.2 Mục tiêu.
- 1.3 Đối tượng sử dụng: ứng dụng web chỉ có một tài khoản quản trị; ở mức CSDL có
  3 role `R_QUANLY`, `R_THUTHU`, `R_DOCGIA`, mô tả theo đúng quyền đã cấp trong
  `7_AnToanThongTin.sql`.
- 1.4 Quy trình: lập thẻ (đủ 16 tuổi, thẻ có hạn 2 năm), mượn (thẻ còn hạn, không nợ,
  cuốn sách "Có sẵn", hạn trả 14 ngày), trả và xử lý phạt (5.000đ/ngày, hư 50%,
  mất 100%). Hình 1.1 là sơ đồ quy trình.

### Chương 2: Phân tích và thiết kế (khoảng 4,5 trang)
- 2.1 Chức năng, lấy theo các trang của frontend: đăng nhập và đổi mật khẩu; quản lý
  thể loại, tác giả, NXB, đầu sách, cuốn sách, độc giả; mượn, trả, thanh toán phạt;
  báo cáo; sao lưu.
- 2.2 Thực thể, thuộc tính và mối quan hệ. Bảng 2.1 gồm 11 thực thể; mô tả quan hệ và bản số.
- 2.3 Ràng buộc toàn vẹn. Bảng 2.2 gồm khoảng 12 ràng buộc (nội dung, bối cảnh, cách cài đặt).
- 2.4 ERD (Hình 2.1).
- 2.5 Mô hình logic và tân từ cho 11 quan hệ (khóa chính gạch chân, khóa ngoại in nghiêng).

### Chương 3: Cài đặt (khoảng 1,5 trang)
- 3.1 SQL Server 2022 trên Docker, collation `Vietnamese_CI_AS`; trích `CREATE TABLE`
  của `DAUSACH` và `CTPHIEUMUON`; Hình 3.1 là khung ảnh.
- 3.2 Số dòng thực tế từng bảng (đếm trên bản sao); các trường hợp dữ liệu bao quát;
  Hình 3.2 là khung ảnh.

### Chương 4: Quản lý thông tin (khoảng 10 trang)
Mỗi mục trong 4.1 gồm: Bài toán / Code (phần lõi) / Kết quả / Giải thích (2–3 câu).
- 4.1.1 Stored Procedure: `SP_THEMDOCGIA`, `SP_LAPPHIEUMUON`, `SP_TRASACH`,
  `SP_THANHTOANPHAT`, `SP_THONGKETHANG`.
- 4.1.2 Trigger: `TRG_CUONSACH_CAPNHATSL`, `TRG_PHIEUMUON_KIEMTRA`, `TRG_CTPM_MUONSACH`,
  `TRG_CTPM_TRASACH`, `TRG_PHIEUPHAT_TONGNO`, mỗi trigger kèm bảng tầm ảnh hưởng thu gọn.
- 4.1.3 Function: `FN_SOSACHDANGMUON`, `FN_TIENPHATTRE`, `FN_LICHSUMUON`.
- 4.1.4 Cursor: `SP_CURSOR_XEPLOAIDOCGIA`, `SP_CURSOR_NHACNHOQUAHAN`.
- 4.2.1 Xác thực: login SQL Server; bảng `TAIKHOAN` lưu mật khẩu băm SHA2-256; `SP_DANGNHAP`.
- 4.2.2 Phân quyền: 3 login, 3 user, 3 role, GRANT/DENY/REVOKE; kết quả thật khi chạy
  `EXECUTE AS` cho thấy thao tác bị từ chối.
- 4.2.3 Import (`BULK INSERT` từ CSV) và Export (`bcp`).
- 4.2.4 Backup (`SP_SAOLUU`, FULL và DIFF) và Restore (NORECOVERY rồi RECOVERY).
- 4.3 Report: trang Báo cáo của website (biểu đồ React) lấy dữ liệu qua API; nguồn dữ
  liệu là 5 view `VW_BC_*`; mỗi report có khung Hình 4.x và 1–2 câu nhận xét dựa trên số liệu thật.

### Chương 5: Demo và kết luận (khoảng 1,5 trang)
- 5.1 Website demo: React + Vite, ASP.NET Core, .NET Aspire, SQL Server; cách chạy;
  khung ảnh cho các màn hình chính.
- 5.2 Kết quả đạt được. 5.3 Hạn chế (ứng dụng chỉ có một tài khoản quản trị; vai trò
  độc giả mới được phân quyền ở mức CSDL, chưa có trên web). 5.4 Hướng phát triển.
- 5.5 Video demo: link để khung giữ chỗ.

### Tài liệu tham khảo (khoảng 0,5 trang)
Theo chuẩn IEEE: 4 giáo trình trong slide môn học và tài liệu Microsoft SQL Server.

## Tiêu chí hoàn thành

- PDF biên dịch không lỗi. Phần từ Chương 1 đến hết Tài liệu tham khảo dài 19–20 trang.
- Mọi tên bảng, cột, SP, trigger, view và mọi số liệu trong báo cáo khớp với code và
  với kết quả chạy trên bản sao CSDL.
- CSDL gốc `QUANLYTHUVIEN` không bị thay đổi.
