# IE103 – Quản lý Thông tin

## Bài tập thực hành môn Quản lý thông tin tuần 4

### Bài 1.

**A. Tạo một Crystal Report từ một bảng tùy chọn trong CSDL QLDT. Yêu cầu:**
- Đầy đủ cấu trúc của 1 Report.
- Thêm cột số thứ tự cho mỗi sinh viên bằng SQL.
- Tô nền vàng cho phần Page Header.
- Ngăn cách phần Details với Report Footer bằng 1 đường kẻ.
- Trình bày từng bước để tạo được Crystal Report.

*Ví dụ minh họa:* (Xem hình ảnh trong file PDF gốc)

**B. Tạo một View cho biết thông tin đề tài, thông tin giáo viên là ủy viên đề tài và điểm số của các giáo viên ủy viên này cho từng đề tài. Sau đó tạo một Crystal Report từ View vừa tạo. Yêu cầu:**
- Đầy đủ cấu trúc của 1 Report.
- Thêm cột số thứ tự cho mỗi đề tài bằng Crystal Report.
- Sắp xếp điểm giảm dần theo từng đề tài.
- Page Header có 2 đường kẻ trên cùng và 1 đường kẻ dưới cùng, Report Footer có 2 đường kẻ. Tô nền vàng cho Page Header và Report Footer.
- Ngăn cách phần mỗi đề tài trong phần Details bằng 1 đường kẻ trước mỗi đề tài.

*Ví dụ minh họa:* (Xem hình ảnh trong file PDF gốc)

**C. Cho CSDL Quản lý bán hàng đính kèm bên dưới.**
Hãy dùng Crystal Report để thiết kế một báo cáo cho biết Doanh thu theo tháng của từng nhân viên trong năm 2006. Yêu cầu gồm có 2 phần sau:
- **Phần Biểu đồ đường (Line Chart):** Cho biết sự biến động về doanh số bán được của từng nhân viên qua các tháng trong năm 2006.
    - Trục X là các tháng trong năm 2006, trục Y là doanh số bán được.
    - Mỗi đường biểu thị một nhân viên tương ứng.
- **Phần Bảng số liệu chi tiết:** Cho biết doanh thu cụ thể của tháng đó với từng nhân viên. Trong đó có:
    - Tổng doanh thu theo từng nhân viên.
    - Tổng doanh thu của tất cả nhân viên trong năm 2006.
    - Lưu ý: Một số tháng không được hiển thị là do bảng HOADON không có số liệu bán hàng của tháng đó.

*Ví dụ minh họa:* (Xem hình ảnh trong file PDF gốc)

**D. Cho CSDL Quản lý bán hàng đính kèm bên dưới.**
Hãy dùng Crystal Report để thiết kế một báo cáo cho biết Tổng doanh thu theo từng sản phẩm trong năm 2006 + 2007. Yêu cầu gồm có 2 phần sau:
- **Phần Biểu đồ tròn (Pie Chart):** Cho biết tỷ lệ phần trăm doanh số bán được của từng sản phẩm trong năm 2006 + 2007.
    - Sử dụng MASP (mã sản phẩm) để phân biệt các sản phẩm với nhau (Vì sản phẩm có thể trùng tên).
    - Gán nhãn (MASP) cho từng phần trong biểu đồ.
    - Thông tin phần trăm của từng sản phẩm để bên phải của biểu đồ.
    - Lưu ý: Thông tin phần trăm trong biểu đồ là tổng doanh thu của từng sản phẩm trong năm 2006 + 2007, tức cột cuối cùng trong phần Bảng số liệu chi tiết bên dưới.
- **Phần Bảng số liệu chi tiết:** Cho biết doanh thu cụ thể của từng sản phẩm trong năm 2006, năm 2007 và năm (2006 + 2007). Cụ thể:
    - Tổng doanh thu theo từng sản phẩm trong năm 2006.
    - Tổng doanh thu theo từng sản phẩm trong năm 2007.
    - Tổng doanh thu theo từng sản phẩm trong năm 2006 + 2007.
    - Phần Page Header tô nền vàng và có Border xung quanh.
    - Phần Detail có Border xung quanh.

*Ví dụ minh họa:* (Xem hình ảnh trong file PDF gốc)

---

### Một số màn hình minh họa Report trên Tableau cho MacOS (Tham khảo tương đối)

- **1A.** (Xem hình ảnh minh họa trong file PDF gốc)
- **1B.** (Xem hình ảnh minh họa trong file PDF gốc)
- **1C.** (Xem hình ảnh minh họa trong file PDF gốc)
- **1D.** (Xem hình ảnh minh họa trong file PDF gốc)

---

### Bài 2.

Tìm hiểu ngoài Crystal Report, còn có những loại Report nào mà Visual Studio hỗ trợ? Hiện tại, loại Report nào phổ biến và hay được dùng nhất? Ngoài ra, nếu không dùng Visual Studio thì có cách nào tạo Report không?

---

### Hướng dẫn làm bài:
- **Đối với Windows OS:** Sử dụng phần mềm Crystal Report tương ứng với phiên bản của Visual Studio đang dùng.
- **Đối với MacOS:** Sử dụng phần mềm Tableau Desktop.

### Hướng dẫn nộp bài: 
- Nộp file PDF. Đặt tên file: `MSSV_HoTen_BTTH4.pdf`.
- Trình bày các câu hỏi theo yêu cầu.
- Đối với mỗi câu Report, yêu cầu có các phần sau:
    - Màn hình thiết kế Report (Design).
    - Màn hình xem Report (Preview).
    - Các đối tượng được sử dụng để tạo Report:
        - Database Fields: Dùng Table, View, Field nào.
        - Formula Fields: Chỉ rõ các công thức đã dùng.
        - Group Name Fields, Running Total Fields.
        - Code SQL cho View/Command/Stored Procedure, v.v.
        - Các đối tượng khác nếu có.
    - Export các file Report ra dưới dạng file PDF (4 files), sau đó merge lại vào trong file bài làm.
- Ngoài ra, **Bài 1A** có yêu cầu chụp **màn hình từng bước**, các bài còn lại không yêu cầu.
- Nộp qua hệ thống courses.uit.edu.vn. Lưu ý: **KHÔNG NÉN FILE**.

---

### Mẫu trình bày:
**(Tên file: MSSV_HoTen_BTTH4.pdf)**

**// Các tiêu đề**

**Bài 1A:**
- Màn hình các bước làm
- Màn hình Design
- Màn hình Preview
- Màn hình các đối tượng sử dụng

**Bài 1B:**
- Màn hình Design
- Màn hình Preview
- Màn hình các đối tượng sử dụng

**Bài 1C và 1D:** 
- Tương tự như 1B.

**Bài 2:**
- Các câu trả lời

**Các file Report đã Export:**
- Merge 4 files Report đã xuất PDF của 4 câu trong bài 1 vào dưới cùng của bài làm

