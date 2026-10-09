# Bài tập thực hành môn Quản lý thông tin tuần 2

**CSDL về Quản Lý Đề Tài. Cho lược đồ quan hệ sau:**

- **SINHVIEN**(MSSV, TENSV, SODT, LOP, DIACHI)
- **DETAI**(MSDT, TENDT)
- **SV_DETAI**(MSSV, MSDT)
- **GIAOVIEN**(MSGV, TENGV, DIACHI, SODT, MSHH, NAMHH)
- **HOCVI**(MSHV, TENHV)
- **CHUYENNGANH**(MSCN, TENCN)
- **GV_HV_CN**(MSGV, MSHV, MSCN, NAM)
- **HOCHAM**(MSHH, TENHH)
- **GV_HDDT**(MSGV, MSDT, DIEM)
- **GV_PBDT**(MSGV, MSDT, DIEM)
- **GV_UVDT**(MSGV, MSDT, DIEM)
- **HOIDONG**(MSHD, PHONG, TGBD, NGAYHD, TINHTRANG, MSGV)
- **HOIDONG_GV**(MSHD, MSGV)
- **HOIDONG_DT**(MSHD, MSDT, QUYETDINH)

---

## PHẦN 1:

**1.1: Viết các câu lệnh SQL tạo các quan hệ trên với các kiểu dữ liệu mô tả trong bảng sau (tạo các ràng buộc khóa chính, khóa ngoại tương ứng):**

| Quan hệ | Thuộc tính | Kiểu dữ liệu | Diễn giải |
| --- | --- | --- | --- |
| **SINHVIEN** | MSSV | char(8) | Khóa chính |
| | TENSV | nvarchar(30) | Not null |
| | SODT | varchar(10) | |
| | LOP | char(10) | Not null |
| | DIACHI | nchar(50) | Not null |
| **DETAI** | MSDT | char(6) | Khóa chính |
| | TENDT | nvarchar(30) | Not null |
| **SV_DETAI** | MSSV | char(8) | tc SINHVIEN |
| | MSDT | char(6) | tc DETAI |
| **GIAOVIEN** | MSGV | int | Khóa chính |
| | TENGV | nvarchar(30) | Not null |
| | DIACHI | nvarchar(50) | Not null |
| | SODT | varchar(10) | Not null |
| | MSHH | int | tc HOCHAM |
| | NAMHH | smalldatetime | Not null |
| **HOCVI** | MSHV | int | Khóa chính |
| | TENHV | nvarchar(20) | Not null |
| **CHUYENNGANH** | MSCN | int | Khóa chính |
| | TENCN | nvarchar(30) | Not null |
| **GV_HV_CN** | MSGV | int | Khóa chính, tc GIAOVIEN |
| | MSHV | int | Khóa chính, tc HỌCVI |
| | MSCN | int | Khóa chính, tc CHUYENNGANH |
| | NAM | smalldatetime | Not null |
| **HOCHAM** | MSHH | int | Khóa chính |
| | TENHH | nvarchar(20) | Not null |
| **GV_HDDT** | MSGV | int | Khóa chính, tc GIAOVIEN |
| | MSDT | char(6) | Khóa chính, tc DETAI |
| | DIEM | float | Not null |
| **GV_PBDT** | MSGV | int | Khóa chính, tc GIAOVIEN |
| | MSDT | char(6) | Khóa chính, tc DETAI |
| | DIEM | float | Not null |
| **GV_UVDT** | MSGV | int | Khóa chính, tc GIAOVIEN |
| | MSDT | char(6) | Khóa chính, tc DETAI |
| | DIEM | float | Not null |
| **HOIDONG** | MSHD | int | Khóa chính |
| | PHONG | int | |
| | TGBD | smalldatetime | |
| | NGAYHD | smalldatetime | Not null |
| | TINHTRANG | nvarchar(30) | Not null |
| | MSGV | int | tc GIÁO VIÊN |
| **HOIDONG_GV** | MSHD | int | Khóa chính, tc HOIDONG |
| | MSGV | int | Khóa chính, tc GIAOVIEN |
| **HOIDONG_DT** | MSHD | int | Khóa chính, tc HOIDONG |
| | MSDT | char(6) | Khóa chính, tc DETAI |
| | QUYETDINH | nchar(10) | |

**1.2: Insert dữ liệu vào CSDL:**

**a) Table SINHVIEN**

| MSSV | TENSV | SODT | LOP | DIACHI |
| --- | --- | --- | --- | --- |
| 13520001 | Nguyễn Văn An | 0906762255 | SE103.U32 | THỦ ĐỨC |
| 13520002 | Phan Tấn Đạt | 0975672350 | IE204.T21 | QUẬN 1 |
| 13520003 | Nguyễn Anh Hải | 0947578688 | IE205.R12 | QUẬN 9 |
| 13520004 | Phạm Tài | 0956757869 | IE202.A22 | QUẬN 1 |
| 13520005 | Lê Thúy Hằng | 0976668688 | SE304.E22 | THỦ ĐỨC |
| 13520006 | Ưng Hồng Ân | 0957475898 | IE208.F33 | QUẬN 2 |

**b) Table DETAI**

| MSDT | TENDT |
| --- | --- |
| 97001 | Quản lý thư viện |
| 97002 | Nhận dạng vân tay |
| 97003 | Bán đấu giá trên mạng |
| 97004 | Quản lý siêu thị |
| 97005 | Xử lý ảnh |
| 97006 | Hệ giải toán thông minh |

**c) Table SV_DETAI**

| MSSV | MSDT |
| --- | --- |
| 13520001 | 97004 |
| 13520002 | 97005 |
| 13520003 | 97001 |
| 13520004 | 97002 |
| 13520005 | 97003 |
| 13520006 | 97005 |

**d) Table HOCHAM**

| MSHH | TENHH |
| --- | --- |
| 1 | PHÓ GIÁO SƯ |
| 2 | GIÁO SƯ |

**e) Table GIAOVIEN**

| MSGV | TENGV | DIACHI | SODT | MSHH | NAMHH |
| --- | --- | --- | --- | --- | --- |
| 00201 | Trần Trung | Bến Tre | 35353535 | 1 | 1996 |
| 00202 | Nguyễn Văn An | Tiềng Giang | 67868688 | 1 | 1996 |
| 00203 | Trần Thu Trang | Cần Thơ | 74758687 | 1 | 1996 |
| 00204 | Nguyễn Thị Loan | TP. HCM | 56575868 | 2 | 2005 |
| 00205 | Chu Tiến | Hà Nội | 46466646 | 2 | 2005 |

**f) Table HOCVI**

| MSHV | TÊNHV |
| --- | --- |
| 1 | Kỹ sư |
| 2 | Cử nhân |
| 3 | Thạc sĩ |
| 4 | Tiến sĩ |
| 5 | Tiến sĩ Khoa học |

**g) Table CHUYENNGANH**

| MSCN | TENCN |
| --- | --- |
| 1 | Công nghệ Web |
| 2 | Mạng xã hội |
| 3 | Quản lý CNTT |
| 4 | GIS |

**h) Table GV_HV_CN**

| MSGV | MSHV | MSCN | NAM |
| --- | --- | --- | --- |
| 00201 | 1 | 1 | 2013 |
| 00201 | 1 | 2 | 2013 |
| 00201 | 2 | 1 | 2014 |
| 00202 | 3 | 2 | 2013 |
| 00203 | 2 | 4 | 2014 |
| 00204 | 3 | 2 | 2014 |

**i) Table GV_HDDT**

| MSGV | MSDT | DIEM |
| --- | --- | --- |
| 00201 | 97001 | 8 |
| 00202 | 97002 | 7 |
| 00205 | 97001 | 9 |
| 00204 | 97004 | 7 |
| 00203 | 97005 | 9 |

**j) Table GV_PBDT**

| MSGV | MSDT | DIEM |
| --- | --- | --- |
| 00201 | 97005 | 8 |
| 00202 | 97001 | 7 |
| 00205 | 97004 | 9 |
| 00204 | 97003 | 7 |
| 00203 | 97002 | 9 |

**k) Table GV_UVDT**

| MSGV | MSDT | DIEM |
| --- | --- | --- |
| 00205 | 97005 | 8 |
| 00202 | 97005 | 7 |
| 00204 | 97005 | 9 |
| 00203 | 97001 | 7 |
| 00204 | 97001 | 9 |
| 00205 | 97001 | 8 |
| 00203 | 97003 | 7 |
| 00201 | 97003 | 9 |
| 00202 | 97003 | 7 |
| 00201 | 97004 | 9 |
| 00202 | 97004 | 8 |
| 00203 | 97004 | 7 |
| 00201 | 97002 | 9 |
| 00204 | 97002 | 7 |
| 00205 | 97002 | 9 |
| 00201 | 97006 | 9 |
| 00202 | 97006 | 7 |
| 00204 | 97006 | 9 |

**l) Table HOIDONG**

| MSHD | PHONG | TGBD | NGAYHD | TINHTRANG | MSGV |
| --- | --- | --- | --- | --- | --- |
| 1 | 002 | 7:00 | 29/11/2014 | Thật | 00201 |
| 2 | 102 | 7:00 | 5/12/2014 | Thật | 00202 |
| 3 | 003 | 8:00 | 6/12/2014 | Thật | 00203 |

**m) HOIDONG_GV**

| MSHD | MSGV |
| --- | --- |
| 1 | 00201 |
| 1 | 00202 |
| 1 | 00203 |
| 1 | 00204 |
| 2 | 00203 |
| 2 | 00202 |
| 2 | 00205 |
| 2 | 00204 |
| 3 | 00201 |
| 3 | 00202 |
| 3 | 00203 |
| 3 | 00204 |

**n) HOIDONG_DT**

| MSHD | MSDT | QUYETDINH |
| --- | --- | --- |
| 1 | 97001 | Được |
| 1 | 97002 | Được |
| 2 | 97001 | Không |
| 2 | 97004 | Không |
| 1 | 97005 | Được |
| 3 | 97001 | Không |
| 3 | 97002 | Được |

---

## PHẦN 2:

### A. STORED PROCEDURES VỚI THAM SỐ VÀO

1. Tham số vào là MSGV, TENGV, SODT, DIACHI, MSHH, NAMHH. Trước khi insert dữ liệu cần kiểm tra MSHH đã tồn tại trong table HOCHAM chưa, nếu chưa thì trả về giá trị 0.
2. Tham số vào là MSGV, TENGV, SODT, DIACHI, MSHH, NAMHH. Trước khi insert dữ liệu cần kiểm tra MSGV trong table GIAOVIEN có trùng không, nếu trùng thì trả về giá trị 0.
3. Giống (1) và (2) kiểm tra xem MSGV có trùng không? MSHH có tồn tại chưa? Nếu MSGV trùng thì trả về 0. Nếu MSHH chưa tồn tại trả về 1, ngược lại cho insert dữ liệu.
4. Đưa vào MSDT cũ, TENDT mới. Hãy cập nhật tên đề tài mới với mã đề tài cũ không đổi nếu không tìm thấy trả về 0, ngược lại cập nhật và trả về 1.
5. Tham số đưa vào MSSV, TENSV mới, DIACHI mới. Hãy cập nhật sinh viên trên với MSSV không đổi, nếu không tìm thấy trả về 0, ngược lại cập nhật và trả về 1.

### B. STORED PROCEDURES VỚI THAM SỐ VÀO VÀ RA

1. Đưa vào TENHV trả ra: Số GV thỏa học vị, nếu không tìm thấy trả về 0.
2. Đưa vào MSDT cho biết: Điểm trung bình của đề tài, nếu không tìm thấy trả về 0.
3. Đưa vào TENGV trả ra: SDT của giáo viên đó, nếu không tìm thấy trả về 0. Nếu trùng tên thì có báo lỗi không? Tại sao? Làm sao để hiện thông báo có bao nhiêu giáo viên trùng tên và trả về các SDT.
4. Đưa vào MSHD cho biết: Điểm trung bình các đề tài của hội đồng đó.
5. Đưa vào TENGV cho biết: Số đề tài hướng dẫn, số đề tài phản biện do giáo viên đó phụ trách. Nếu trùng tên thì có báo lỗi không hay hệ thống sẽ đếm tất cả các đề tài của những giáo viên trùng tên đó?

### C. TRIGGER

1. Tạo Trigger thỏa mãn điều kiện khi xóa một đề tài sẽ xóa các thông tin liên quan.
2. Tạo Trigger thỏa mãn ràng buộc là khi đổi 1 mã số giáo viên (MSGV) thì sẽ thay đổi các thông tin liên quan.
3. Tạo Trigger thỏa mãn ràng buộc là một hội đồng không quá 10 đề tài. Dùng "Group by" có được không? Giải thích.
4. Tạo Trigger thỏa mãn ràng buộc là một đề tài không quá 2 sinh viên. Dùng "Group by" có được không? Giải thích.
5. Tạo Trigger thỏa mãn ràng buộc là một giáo viên muốn có học hàm PGS phải là tiến sĩ.

### D. FUNCTION

1. Viết hàm tính điểm trung bình của một đề tài. Giá trị trả về là điểm trung bình ứng với mã số đề tài nhập vào.
2. Trả về kết quả của đề tài theo MSDT nhập vào. Kết quả là DAT nếu như điểm trung bình từ 5 trở lên, và KHONGDAT nếu như điểm trung bình dưới 5.
3. Đưa vào MSDT, trả về mã số và họ tên của các sinh viên thực hiện đề tài.

### E. CURSOR

Tạo một bảng tên là **DETAI_DIEM**. Cấu trúc bảng như sau:
**DETAI_DIEM(MSDT, DIEMTB)**

1. Viết Cursor tính điểm trung bình cho từng đề tài. Sau đó lưu kết quả vào bảng DETAI_DIEM.
2. Gom các bước xử lý của Cursor ở câu 1 vào một Stored Procedure.
3. Tạo thêm cột XEPLOAI có kiểu là NVARCCHAR(20) trong bảng DETAI_DIEM, viết Cursor cập nhật kết quả xếp loại cho mỗi đề tài như sau:
    + "Xuất sắc": điểm trung bình từ 9 đến 10.
    + "Giỏi": điểm trung bình từ 8 đến 9.
    + "Khá": điểm trung bình từ 7 đến 8.
    + "Trung bình khá": điểm trung bình từ 6 đến 7.
    + "Trung bình": điểm trung bình từ 5 đến 6.
    + "Yếu": điểm trung bình từ 4 đến 5.
    + "Kém": điểm trung bình dưới 4.

---

## Hướng dẫn nộp bài:

+ Nộp file PDF. Đặt tên file: **MSSV_HoTen_BTTH2.pdf**.
+ Ứng với mỗi câu hỏi, trình bày đoạn code bằng ngôn ngữ SQL trong file báo cáo. Có thể giải thích hoặc mô tả thêm về đoạn code (nếu có).
+ Nộp kèm theo file `.sql` tương ứng cùng với file pdf, đặt tên là: **MSSV_HoTen_BTTH2.sql**
+ Nộp qua hệ thống courses.uit.edu.vn. Lưu ý: **KHÔNG NÉN FILE**.

