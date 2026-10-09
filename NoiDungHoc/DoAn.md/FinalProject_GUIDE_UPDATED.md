# ĐỒ ÁN MÔN HỌC QUẢN LÝ THÔNG TIN

**IE103 – Quản lý Thông tin**

Phân tích, thiết kế CSDL cho một bài toán quản lý.
Bài toán quản lý do sinh viên tự chọn.

## Yêu cầu:

### 1. Mô tả bài toán
* Phát biểu bài toán, mục tiêu, đối tượng sử dụng.
* Mô tả quy trình trong thực tế liên quan đến bài toán (mô tả theo từng bước, và vẽ sơ đồ nếu có. Có thể tham khảo các quy trình có sẵn trong thực tế để xây dựng).

### 2. Phân tích và thiết kế (Mô hình dữ liệu)
* Liệt kê và mô tả các chức năng của hệ thống.
* Các đối tượng nào cần quản lý, mối quan hệ giữa các đối tượng (Tức chi tiết các thực thể cần quản lý, các thuộc tính cần có và mối quan hệ giữa chúng).
* Trình bày các ràng buộc trên các đối tượng (nếu có).
* Vẽ mô hình mức quan niệm cho mối quan hệ giữa các thực thể tương ứng với loại mô hình dữ liệu lựa chọn (Sơ đồ ERD cho Mô hình quan hệ).
* Thiết kế CSDL cho bài toán tương ứng với loại mô hình dữ liệu lựa chọn (Tức chuyển sang mô hình mức logic). Lưu ý kèm theo các giải thích cho các bảng trong CSDL (Tân từ).

### 3. Cài đặt
* Cài đặt mô hình dữ liệu trên một hệ quản trị CSDL (Trong loại mô hình dữ liệu đã lựa chọn) gồm: tạo bảng, tạo khoá chính, khoá ngoại, các ràng buộc (nếu có).
* Tạo dữ liệu mẫu hoặc thu thập dữ liệu trong thực tế (10-20 dòng cho 1 quan hệ; đảm bảo dữ liệu bao quát nhiều trường hợp).

### 4. Quản lý thông tin
* Xử lý thông tin (Stored Procedure (5), Trigger (5), Function (3), Cursor (2)).
* An toàn thông tin (Xác thực, Phân quyền, Import, Export, Backup, Restore).
* Trình bày thông tin (Report) (5).
* Các chức năng của hệ thống (Từ phần phân tích) (chỉ mô tả)
* **Lưu ý:** Demo cho các chức năng (Trên nền tảng Web, Desktop, Mobile, ...)

## HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU:
Sinh viên sử dụng SQLServer hoặc MySQL.

## MỘT SỐ BÀI TOÁN QUẢN LÝ GỢI Ý:
* Quản lý khu cách ly y tế (Theo dõi, cập nhật tình trạng cách ly, công suất sử dụng giường, phân bổ nguồn lực, …).
* Quản lý truy vết F0 (Thông tin tiếp xúc, thời gian tiếp xúc, lịch cách ly, xét nghiệm, người đã nhiễm, F1, F2, …).
* Quản lý di chuyển nội địa/chuyến xe (Lịch trình xe, bán vé, quy hoạch tuyến đường, phân bổ nguồn lực xe, tình trạng tài xế, …).
* Quản lý khai báo tiếp xúc (Thông tin tờ khai, nhập cảnh, biểu hiện, tiền sử, …).
* Quản lý tiêm chủng vaccine (Phân phối vắc xin, lịch tiêm, theo dõi liều vắc xin, ...).
* Quản lý điểm thi đại học (Điểm các môn thi, khối thi, sinh viên, ngành đăng ký, trường đăng ký, …).
* Quản lý lớp học trực tuyến (Đăng ký, tài liệu khóa học, điểm danh, chấm điểm, ...).
* Quản lý hồ sơ bệnh án (Tiền sử bệnh, đơn thuốc, cuộc hẹn, …).
* Quản lý các chuyến bay (Lịch bay, đặt chỗ, thông tin hành khách, hành lý, …).
* Quản lý thư viện (Danh mục sách, hồ sơ người mượn, tình trạng sách, tiền phạt, …).
* Quản lý phân phối xăng dầu (Đơn đặt hàng, lịch trình giao hàng, lượng phân bố, …).
* Quản lý thiết bị trong các phòng ban của công ty (Phân bổ thiết bị, lịch bảo trì, nhật ký sử dụng, …).
* Quản lý chuỗi cung ứng (Nhà cung cấp, mức tồn kho, thông tin đơn hàng, …).
* Quản lý nhân sự (Hồ sơ nhân viên, bảng lương, đánh giá hiệu suất, …).
* Quản lý hàng tồn kho (Mức tồn kho, doanh số bán hàng, xử lý việc nhập kho, …).
* Quản lý thông tin địa chính (Địa giới hành chính).
* Quản lý nội dung (Văn bản, hình ảnh, video, … của 1 hệ thống).
* Quản lý đặt phòng hội nghị/trung tâm/khách sạn (Thông tin khách, phòng trống, nhiều loại phòng, thanh toán, …).
* Quản lý phòng trưng bày nghệ thuật trực tuyến (Tác phẩm nghệ thuật, hồ sơ nghệ sĩ, giao dịch bán hàng, …).
* Quản lý bãi đậu xe thành phố (Giấy phép đậu xe, tỷ lệ đầy chỗ, biên bản phạt, …).
* Quản lý sự kiện thể thao (Đội, lịch thi đấu, bán vé, …).
* Quản lý trò truyện trực tuyến (Chat Room, Messaging).
* Quản lý bảng xếp hạng theo thời gian thực (Realtime Leaderboard).
* Quản lý truyền phát đa phương tiện trực tuyến (Media Streaming).
* Quản lý nhật ký thời gian thực (Phân tích và giám sát dữ liệu nhật ký).
* Quản lý tài liệu/mạng xã hội/sản phẩm (Tìm kiếm văn bản và truy xuất thông tin).
* Quản lý cơ sở tri thức của 1 tổ chức (Knowledge Base).
* Quản lý năng lượng cho các tòa nhà (Giám sát mức tiêu thụ năng lượng).
* Quản lý mạng viễn thông (Độ trễ, mất gói, mức sử dụng băng thông, phân tích lỗi, lưu lượng mạng, lỗ hổng bảo mật, bộ định tuyến, …).
* Quản lý sức khỏe (Đo từ xa từ các thiết bị chăm sóc sức khỏe, thiết bị đeo, …).
* Quản lý thông tin thời tiết (Điều kiện thời tiết, nhiệt độ, độ ẩm, các yếu tố khí tượng, …).
* ...

## QUY ĐỊNH BÁO CÁO
* Báo cáo trình bày theo mẫu cung cấp sẵn. Có mục lục, trang bìa.
* Tiêu đề cụ thể, phù hợp với báo cáo.
* Trình bày ngắn gọn, súc tích. **Tối đa 20 trang (Không tính mục lục và tài liệu tham khảo)**. Chỉ nên lấy các hình ảnh về cấu trúc bảng, kết quả thực nghiệm, demo. Không nên đưa vào các hình ảnh như logo công nghệ, lịch sử hình thành, v.v.
* Cuối phần trình bày cần đưa link video clip demo trực tiếp vào (có thể upload lên google drive hoặc youtube, sau đó đưa link vào file báo cáo).
* Không sao chép nội dung trên mạng. Các đề tài sẽ được kiểm tra độ trùng lặp về nội dung (bằng turnitin), nếu nội dung trùng lặp trên 25% thì SV sẽ nhận điểm 0.

