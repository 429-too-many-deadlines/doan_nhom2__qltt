# Bài tập thực hành môn Quản lý Thông tin tuần 6

**Môn học:** IE103 – Quản lý Thông tin

Dựa vào CSDL đã thiết kế ở **BTTH số 2 (QLĐT)**, hãy thực hiện các yêu cầu sau:

## Câu 1: Tổ chức/Biểu diễn thông tin
**1.1.** Vẽ sơ đồ ERD cho các quan hệ trong CSDL QLDT.

## Câu 2: Xử lý thông tin
Hiện thực các ràng buộc như sau. Vẽ bảng tầm ảnh hưởng và hiện thực trong SQL Server (Check, Constraints, Trigger).

**2.1.** Một sinh viên chỉ được tham gia một đề tài.  
**2.2.** Điểm của đề tài trong thang điểm từ 0 đến 10.  
**2.3.** GV là chủ tịch hội đồng phải có học vị tiến sĩ.  

Viết các truy vấn xử lý thông tin như dưới đây (tùy ý sử dụng Function, Stored Procedure hoặc Cursor):

**2.4.** Tính số lượng đề tài làm phản biện và số lượng đề tài làm ủy viên của từng GV.  
**2.5.** In ra danh sách tên các sinh viên có điểm trung bình đề tài cao nhất.  

## Câu 3: An ninh thông tin
**3.1.** Tạo ra 3 users: `GIANGVIEN`, `GIAOVU` và `SINHVIEN`, đặt mật khẩu tuỳ ý.  
**3.2.** Phân quyền cho các users trên database như sau:
- **`GIAOVU`** có quyền xem và chỉnh sửa (cập nhật) trên tất cả các bảng.
- **`GIANGVIEN`**:
  + Có quyền xem trên các bảng có liên quan đến thông tin GV, các đề tài mà GV hướng dẫn, phản biện hay làm uỷ viên, xem thông tin hội đồng và danh sách các đề tài hiện có.
  + Có quyền cập nhật thông tin của mình.
- **`SINHVIEN`** có quyền xem thông tin của sinh viên, thông tin của hội đồng và danh sách các đề tài hiện có.
- Tất cả người dùng trên đều không có quyền xoá thông tin.

## Câu 4: Trình bày thông tin
Dùng Crystal Report (Trên Windows) hoặc Tableau (Trên MAC) để thiết kế các Reports như sau:

**4.1.** Thông tin GV phản biện

**TRƯỜNG ĐẠI HỌC CÔNG NGHỆ THÔNG TIN**  
**KHOA KHOA HỌC VÀ KỸ THUẬT THÔNG TIN**

**THÔNG TIN GIẢNG VIÊN PHẢN BIỆN**

| STT | HỌ TÊN | HỌC VỊ | HỌC HÀM | SỐ ĐIỆN THOẠI | ĐỊA CHỈ |
| :---: | :--- | :---: | :---: | :---: | :--- |
| 1 | Trần Trung | TS | PGS | 35353535 | Bến Tre |
| 2 | Nguyễn Thị Loan | TS | GS | 56575868 | TP. HCM |
| ... | | | | | |

*Tp. Hồ Chí Minh, ngày <ngày hiện tại>*  
**Người lập**  
*Họ tên SV*

**4.2.** Thông tin hội đồng đánh giá đề tài

**TRƯỜNG ĐẠI HỌC CÔNG NGHỆ THÔNG TIN**  
**KHOA KHOA HỌC VÀ KỸ THUẬT THÔNG TIN**

**THÔNG TIN HỘI ĐỒNG ĐÁNH GIÁ ĐỀ TÀI**

| STT | MÃ SỐ HỘI ĐỒNG | TÊN ĐỀ TÀI | PHÒNG | NGÀY HỘI ĐỒNG | CHỦ TỊCH HỘI ĐỒNG | ĐIỂM TB |
| :---: | :---: | :--- | :---: | :---: | :--- | :---: |
| 1 | HD01 | Xử lý ảnh | 002 | 29/11/2014 | Trần Trung | 8.33 |
| ... | | | | | | |

*Tp. Hồ Chí Minh, ngày <ngày hiện tại>*  
**Người lập**  
*Họ tên SV*

## Câu 5: Các mô hình CSDL Tiên tiến
**5.1.** Giả sử cần chuyển bài toán QLDT sang một mô hình CSDL khác. Bạn sẽ lựa chọn mô hình nào (Phân tán, NoSQL, HĐT, Di động). Tại sao?  
**5.2.** Cho ví dụ chuyển đổi sang mô hình đã chọn (Chọn 2 bảng bất kỳ khi chuyển, không cần chuyển hết tất cả các bảng).

---

### Hướng dẫn nộp bài:
- Nộp file PDF và SQL. Đặt tên file: **`MSSV_HoTen_BTTH6.pdf`** và **`MSSV_HoTen_BTTH6.sql`**.
- Trình bày ngắn gọn các câu trả lời.
- Đối với các câu hỏi liên quan đến thực thi code SQL, thực hiện dán code SQL vào file báo cáo tương ứng với câu hỏi.
- Đối với các Crystal Report/Tableau, chụp Màn hình Design và Màn hình Preview của từng câu.
- Nộp qua hệ thống `courses.uit.edu.vn`. Lưu ý: **KHÔNG NÉN FILE**.

