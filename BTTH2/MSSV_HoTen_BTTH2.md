# BÀI TẬP THỰC HÀNH TUẦN 2: XỬ LÝ THÔNG TIN

**Môn học:** IE103 – Quản lý Thông tin  
**Sinh viên:** Họ tên – MSSV  
**Môi trường thực hiện:** Microsoft SQL Server 2022  
**File mã nguồn kèm theo:** `MSSV_HoTen_BTTH2.sql` (chạy được trọn vẹn từ đầu đến cuối)

**Quy ước trình bày.** Mỗi câu gồm: yêu cầu, mã SQL, lệnh chạy thử và kết quả thực tế khi chạy trên SQL Server 2022. Các lệnh chạy thử làm thay đổi dữ liệu đều đặt trong `BEGIN TRAN … ROLLBACK`, nên các câu sau vẫn dùng dữ liệu gốc. **Điểm trung bình của một đề tài** được hiểu là trung bình mọi điểm của đề tài đó trong GV_HDDT, GV_PBDT và GV_UVDT; định nghĩa này dùng chung cho B2, B4, D1, D2 và phần E. Các mẫu báo lỗi trong trigger đều theo cùng một cách: `ROLLBACK TRANSACTION` rồi `RAISERROR`.

---

## PHẦN 1

### 1.1. Tạo các quan hệ

CSDL QLDT gồm 14 quan hệ:

| Quan hệ | Khóa chính | Khóa ngoại |
|---|---|---|
| SINHVIEN | MSSV | |
| DETAI | MSDT | |
| SV_DETAI | (không có) | MSSV → SINHVIEN, MSDT → DETAI |
| GIAOVIEN | MSGV | MSHH → HOCHAM |
| HOCVI | MSHV | |
| CHUYENNGANH | MSCN | |
| GV_HV_CN | MSGV, MSHV, MSCN | MSGV → GIAOVIEN, MSHV → HOCVI, MSCN → CHUYENNGANH |
| HOCHAM | MSHH | |
| GV_HDDT | MSGV, MSDT | MSGV → GIAOVIEN, MSDT → DETAI |
| GV_PBDT | MSGV, MSDT | MSGV → GIAOVIEN, MSDT → DETAI |
| GV_UVDT | MSGV, MSDT | MSGV → GIAOVIEN, MSDT → DETAI |
| HOIDONG | MSHD | MSGV → GIAOVIEN (chủ tịch hội đồng) |
| HOIDONG_GV | MSHD, MSGV | MSHD → HOIDONG, MSGV → GIAOVIEN |
| HOIDONG_DT | MSHD, MSDT | MSHD → HOIDONG, MSDT → DETAI |

Theo bảng mô tả của đề, SV_DETAI chỉ có hai khóa ngoại và không có khóa chính.

```sql
USE master
GO
IF DB_ID('QLDT') IS NOT NULL
BEGIN
    ALTER DATABASE QLDT SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE QLDT
END
GO
CREATE DATABASE QLDT
GO
USE QLDT
GO

CREATE TABLE SINHVIEN (
    MSSV   CHAR(8)      PRIMARY KEY,
    TENSV  NVARCHAR(30) NOT NULL,
    SODT   VARCHAR(10),
    LOP    CHAR(10)     NOT NULL,
    DIACHI NCHAR(50)    NOT NULL
)
CREATE TABLE DETAI (
    MSDT  CHAR(6)      PRIMARY KEY,
    TENDT NVARCHAR(30) NOT NULL
)
CREATE TABLE SV_DETAI (
    MSSV CHAR(8) FOREIGN KEY REFERENCES SINHVIEN(MSSV),
    MSDT CHAR(6) FOREIGN KEY REFERENCES DETAI(MSDT)
)
CREATE TABLE HOCHAM (
    MSHH  INT          PRIMARY KEY,
    TENHH NVARCHAR(20) NOT NULL
)
CREATE TABLE GIAOVIEN (
    MSGV   INT          PRIMARY KEY,
    TENGV  NVARCHAR(30) NOT NULL,
    DIACHI NVARCHAR(50) NOT NULL,
    SODT   VARCHAR(10)  NOT NULL,
    MSHH   INT          FOREIGN KEY REFERENCES HOCHAM(MSHH),
    NAMHH  SMALLDATETIME NOT NULL
)
CREATE TABLE HOCVI (
    MSHV  INT          PRIMARY KEY,
    TENHV NVARCHAR(20) NOT NULL
)
CREATE TABLE CHUYENNGANH (
    MSCN  INT          PRIMARY KEY,
    TENCN NVARCHAR(30) NOT NULL
)
CREATE TABLE GV_HV_CN (
    MSGV INT FOREIGN KEY REFERENCES GIAOVIEN(MSGV),
    MSHV INT FOREIGN KEY REFERENCES HOCVI(MSHV),
    MSCN INT FOREIGN KEY REFERENCES CHUYENNGANH(MSCN),
    NAM  SMALLDATETIME NOT NULL,
    PRIMARY KEY (MSGV, MSHV, MSCN)
)
CREATE TABLE GV_HDDT (
    MSGV INT     FOREIGN KEY REFERENCES GIAOVIEN(MSGV),
    MSDT CHAR(6) FOREIGN KEY REFERENCES DETAI(MSDT),
    DIEM FLOAT   NOT NULL,
    PRIMARY KEY (MSGV, MSDT)
)
CREATE TABLE GV_PBDT (
    MSGV INT     FOREIGN KEY REFERENCES GIAOVIEN(MSGV),
    MSDT CHAR(6) FOREIGN KEY REFERENCES DETAI(MSDT),
    DIEM FLOAT   NOT NULL,
    PRIMARY KEY (MSGV, MSDT)
)
CREATE TABLE GV_UVDT (
    MSGV INT     FOREIGN KEY REFERENCES GIAOVIEN(MSGV),
    MSDT CHAR(6) FOREIGN KEY REFERENCES DETAI(MSDT),
    DIEM FLOAT   NOT NULL,
    PRIMARY KEY (MSGV, MSDT)
)
CREATE TABLE HOIDONG (
    MSHD      INT           PRIMARY KEY,
    PHONG     INT,
    TGBD      SMALLDATETIME,
    NGAYHD    SMALLDATETIME NOT NULL,
    TINHTRANG NVARCHAR(30)  NOT NULL,
    MSGV      INT           FOREIGN KEY REFERENCES GIAOVIEN(MSGV)  -- chủ tịch hội đồng
)
CREATE TABLE HOIDONG_GV (
    MSHD INT FOREIGN KEY REFERENCES HOIDONG(MSHD),
    MSGV INT FOREIGN KEY REFERENCES GIAOVIEN(MSGV),
    PRIMARY KEY (MSHD, MSGV)
)
CREATE TABLE HOIDONG_DT (
    MSHD      INT       FOREIGN KEY REFERENCES HOIDONG(MSHD),
    MSDT      CHAR(6)   FOREIGN KEY REFERENCES DETAI(MSDT),
    QUYETDINH NCHAR(10),
    PRIMARY KEY (MSHD, MSDT)
)
GO
```

### 1.2. Nhập dữ liệu

Ghi chú về dữ liệu:

- MSGV có kiểu `INT` nên giá trị `00201` trong đề được lưu là `201` (tương tự 202–205). PHONG có kiểu `INT` nên phòng `002` được lưu là `2`.
- `TGBD` và `NGAYHD` được nhập theo dạng `'07:00'` và `'2014-11-29'` (ISO) để không phụ thuộc thiết lập ngôn ngữ của server.
- **Dữ liệu bổ sung so với đề.** Dữ liệu gốc **không có giáo viên nào đạt học vị Tiến sĩ** (GV_HV_CN chỉ có MSHV 1, 2, 3), trong khi 3 giáo viên 201, 202, 203 có học hàm Phó giáo sư. Như vậy toàn bộ dữ liệu gốc vi phạm ràng buộc ở câu C5. Bài làm thêm 5 dòng vào GV_HV_CN:

| MSGV | MSHV | MSCN | NAM | Ý nghĩa |
|---|---|---|---|---|
| 201 | 4 | 1 | 2016 | Trần Trung – Tiến sĩ Công nghệ Web |
| 202 | 4 | 2 | 2017 | Nguyễn Văn An – Tiến sĩ Mạng xã hội |
| 203 | 4 | 4 | 2018 | Trần Thu Trang – Tiến sĩ GIS |
| 204 | 4 | 2 | 2019 | Nguyễn Thị Loan – Tiến sĩ Mạng xã hội |
| 205 | 3 | 3 | 2015 | Chu Tiến – Thạc sĩ Quản lý CNTT |

```sql
INSERT INTO SINHVIEN VALUES
('13520001', N'Nguyễn Văn An',   '0906762255', 'SE103.U32', N'THỦ ĐỨC'),
('13520002', N'Phan Tấn Đạt',    '0975672350', 'IE204.T21', N'QUẬN 1'),
('13520003', N'Nguyễn Anh Hải',  '0947578688', 'IE205.R12', N'QUẬN 9'),
('13520004', N'Phạm Tài',        '0956757869', 'IE202.A22', N'QUẬN 1'),
('13520005', N'Lê Thúy Hằng',    '0976668688', 'SE304.E22', N'THỦ ĐỨC'),
('13520006', N'Ưng Hồng Ân',     '0957475898', 'IE208.F33', N'QUẬN 2')

INSERT INTO DETAI VALUES
('97001', N'Quản lý thư viện'),
('97002', N'Nhận dạng vân tay'),
('97003', N'Bán đấu giá trên mạng'),
('97004', N'Quản lý siêu thị'),
('97005', N'Xử lý ảnh'),
('97006', N'Hệ giải toán thông minh')

INSERT INTO SV_DETAI VALUES
('13520001', '97004'), ('13520002', '97005'), ('13520003', '97001'),
('13520004', '97002'), ('13520005', '97003'), ('13520006', '97005')

INSERT INTO HOCHAM VALUES (1, N'PHÓ GIÁO SƯ'), (2, N'GIÁO SƯ')

INSERT INTO GIAOVIEN VALUES
(201, N'Trần Trung',      N'Bến Tre',     '35353535', 1, '1996'),
(202, N'Nguyễn Văn An',   N'Tiền Giang',  '67868688', 1, '1996'),
(203, N'Trần Thu Trang',  N'Cần Thơ',     '74758687', 1, '1996'),
(204, N'Nguyễn Thị Loan', N'TP. HCM',     '56575868', 2, '2005'),
(205, N'Chu Tiến',        N'Hà Nội',      '46466646', 2, '2005')

INSERT INTO HOCVI VALUES
(1, N'Kỹ sư'), (2, N'Cử nhân'), (3, N'Thạc sĩ'), (4, N'Tiến sĩ'), (5, N'Tiến sĩ Khoa học')

INSERT INTO CHUYENNGANH VALUES
(1, N'Công nghệ Web'), (2, N'Mạng xã hội'), (3, N'Quản lý CNTT'), (4, N'GIS')

INSERT INTO GV_HV_CN VALUES
(201, 1, 1, '2013'), (201, 1, 2, '2013'), (201, 2, 1, '2014'),
(202, 3, 2, '2013'), (203, 2, 4, '2014'), (204, 3, 2, '2014')

-- Dữ liệu BỔ SUNG (không có trong đề BTTH2): dữ liệu gốc chưa có GV nào đạt học vị
-- Tiến sĩ, trong khi ràng buộc ở câu C5 yêu cầu GV có học hàm PGS (201, 202, 203)
-- phải là tiến sĩ. Thêm học vị Tiến sĩ cho GV 201-204 và Thạc sĩ cho GV 205.
INSERT INTO GV_HV_CN VALUES
(201, 4, 1, '2016'), (202, 4, 2, '2017'), (203, 4, 4, '2018'),
(204, 4, 2, '2019'), (205, 3, 3, '2015')

INSERT INTO GV_HDDT VALUES
(201, '97001', 8), (202, '97002', 7), (205, '97001', 9), (204, '97004', 7), (203, '97005', 9)

INSERT INTO GV_PBDT VALUES
(201, '97005', 8), (202, '97001', 7), (205, '97004', 9), (204, '97003', 7), (203, '97002', 9)

INSERT INTO GV_UVDT VALUES
(205, '97005', 8), (202, '97005', 7), (204, '97005', 9), (203, '97001', 7), (204, '97001', 9),
(205, '97001', 8), (203, '97003', 7), (201, '97003', 9), (202, '97003', 7), (201, '97004', 9),
(202, '97004', 8), (203, '97004', 7), (201, '97002', 9), (204, '97002', 7), (205, '97002', 9),
(201, '97006', 9), (202, '97006', 7), (204, '97006', 9)

INSERT INTO HOIDONG VALUES
(1, 2,   '07:00', '2014-11-29', N'Thật', 201),
(2, 102, '07:00', '2014-12-05', N'Thật', 202),
(3, 3,   '08:00', '2014-12-06', N'Thật', 203)

INSERT INTO HOIDONG_GV VALUES
(1, 201), (1, 202), (1, 203), (1, 204),
(2, 203), (2, 202), (2, 205), (2, 204),
(3, 201), (3, 202), (3, 203), (3, 204)

INSERT INTO HOIDONG_DT VALUES
(1, '97001', N'Được'), (1, '97002', N'Được'), (2, '97001', N'Không'), (2, '97004', N'Không'),
(1, '97005', N'Được'), (3, '97001', N'Không'), (3, '97002', N'Được')
GO
```

---

## PHẦN 2

### A. Stored procedure với tham số vào

Các thủ tục trả kết quả 0/1 (hoặc 2) bằng lệnh `RETURN`. **Lưu ý:** sau khi đã tạo trigger C5, thêm giáo viên với MSHH = 1 (Phó giáo sư) bằng các thủ tục A1–A3 sẽ bị trigger chặn (báo lỗi thay vì trả về mã), vì giáo viên mới chưa thể có học vị Tiến sĩ; quy trình thêm một Phó giáo sư hợp lệ được trình bày ở câu C5, trường hợp (c). Các lệnh chạy thử dưới đây vì vậy dùng MSHH = 2 (Giáo sư).

#### Câu A1
**Yêu cầu:** Tham số vào là MSGV, TENGV, SODT, DIACHI, MSHH, NAMHH. Trước khi insert dữ liệu cần kiểm tra MSHH đã tồn tại trong table HOCHAM chưa, nếu chưa thì trả về giá trị 0.

**Mã SQL:**

```sql
/* A1. Thêm giáo viên; nếu MSHH chưa tồn tại trong HOCHAM thì trả về 0. */
DROP PROCEDURE IF EXISTS sp_ThemGV_KiemTraHH
GO
CREATE PROCEDURE sp_ThemGV_KiemTraHH
    @MSGV INT, @TENGV NVARCHAR(30), @SODT VARCHAR(10), @DIACHI NVARCHAR(50),
    @MSHH INT, @NAMHH SMALLDATETIME
AS
BEGIN
    SET NOCOUNT ON
    IF NOT EXISTS (SELECT 1 FROM HOCHAM WHERE MSHH = @MSHH)
        RETURN 0
    INSERT INTO GIAOVIEN (MSGV, TENGV, DIACHI, SODT, MSHH, NAMHH)
    VALUES (@MSGV, @TENGV, @DIACHI, @SODT, @MSHH, @NAMHH)
    RETURN 1
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== A1 ==='
BEGIN TRAN
DECLARE @kq INT
EXEC @kq = sp_ThemGV_KiemTraHH 206, N'Lê Văn Bình', '0909000001', N'Đồng Nai', 3, '2020'
SELECT N'MSHH = 3 (không tồn tại)' AS TruongHop, @kq AS KetQua
EXEC @kq = sp_ThemGV_KiemTraHH 206, N'Lê Văn Bình', '0909000001', N'Đồng Nai', 2, '2020'
SELECT N'MSHH = 2 (Giáo sư)' AS TruongHop, @kq AS KetQua
SELECT * FROM GIAOVIEN WHERE MSGV = 206
ROLLBACK
GO
```

**Kết quả:**

| TruongHop | KetQua |
|---|---|
| MSHH = 3 (không tồn tại) | 0 |

| TruongHop | KetQua |
|---|---|
| MSHH = 2 (Giáo sư) | 1 |

| MSGV | TENGV | DIACHI | SODT | MSHH | NAMHH |
|---|---|---|---|---|---|
| 206 | Lê Văn Bình | Đồng Nai | 0909000001 | 2 | 2020-01-01 00:00:00 |

**Giải thích:**

Thủ tục kiểm tra MSHH trong bảng HOCHAM; nếu không có thì `RETURN 0` và không thêm gì. Ngược lại thêm giáo viên và `RETURN 1`. Giá trị trả về được lấy bằng `EXEC @kq = sp_...`.

#### Câu A2
**Yêu cầu:** Tham số vào là MSGV, TENGV, SODT, DIACHI, MSHH, NAMHH. Trước khi insert dữ liệu cần kiểm tra MSGV trong table GIAOVIEN có trùng không, nếu trùng thì trả về giá trị 0.

**Mã SQL:**

```sql
/* A2. Thêm giáo viên; nếu MSGV đã có trong GIAOVIEN thì trả về 0. */
DROP PROCEDURE IF EXISTS sp_ThemGV_KiemTraMSGV
GO
CREATE PROCEDURE sp_ThemGV_KiemTraMSGV
    @MSGV INT, @TENGV NVARCHAR(30), @SODT VARCHAR(10), @DIACHI NVARCHAR(50),
    @MSHH INT, @NAMHH SMALLDATETIME
AS
BEGIN
    SET NOCOUNT ON
    IF EXISTS (SELECT 1 FROM GIAOVIEN WHERE MSGV = @MSGV)
        RETURN 0
    INSERT INTO GIAOVIEN (MSGV, TENGV, DIACHI, SODT, MSHH, NAMHH)
    VALUES (@MSGV, @TENGV, @DIACHI, @SODT, @MSHH, @NAMHH)
    RETURN 1
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== A2 ==='
BEGIN TRAN
DECLARE @kq INT
EXEC @kq = sp_ThemGV_KiemTraMSGV 201, N'Trùng mã', '0909000002', N'Huế', 2, '2020'
SELECT N'MSGV = 201 (đã tồn tại)' AS TruongHop, @kq AS KetQua
EXEC @kq = sp_ThemGV_KiemTraMSGV 207, N'Mai Thị Hoa', '0909000003', N'Huế', 2, '2020'
SELECT N'MSGV = 207 (mới)' AS TruongHop, @kq AS KetQua
SELECT * FROM GIAOVIEN WHERE MSGV IN (201, 207)
ROLLBACK
GO
```

**Kết quả:**

| TruongHop | KetQua |
|---|---|
| MSGV = 201 (đã tồn tại) | 0 |

| TruongHop | KetQua |
|---|---|
| MSGV = 207 (mới) | 1 |

| MSGV | TENGV | DIACHI | SODT | MSHH | NAMHH |
|---|---|---|---|---|---|
| 201 | Trần Trung | Bến Tre | 35353535 | 1 | 1996-01-01 00:00:00 |
| 207 | Mai Thị Hoa | Huế | 0909000003 | 2 | 2020-01-01 00:00:00 |

**Giải thích:**

Kiểm tra trùng khóa chính trước khi INSERT để trả về 0 thay vì để SQL Server báo lỗi vi phạm khóa chính.

#### Câu A3
**Yêu cầu:** Giống (1) và (2) kiểm tra xem MSGV có trùng không? MSHH có tồn tại chưa? Nếu MSGV trùng thì trả về 0. Nếu MSHH chưa tồn tại trả về 1, ngược lại cho insert dữ liệu.

**Mã SQL:**

```sql
/* A3. Kết hợp A1 và A2: MSGV trùng -> 0; MSHH chưa tồn tại -> 1;
   ngược lại thêm giáo viên và trả về 2 (đề không quy định giá trị khi
   thêm thành công, chọn 2 để phân biệt với hai trường hợp lỗi). */
DROP PROCEDURE IF EXISTS sp_ThemGV
GO
CREATE PROCEDURE sp_ThemGV
    @MSGV INT, @TENGV NVARCHAR(30), @SODT VARCHAR(10), @DIACHI NVARCHAR(50),
    @MSHH INT, @NAMHH SMALLDATETIME
AS
BEGIN
    SET NOCOUNT ON
    IF EXISTS (SELECT 1 FROM GIAOVIEN WHERE MSGV = @MSGV)
        RETURN 0
    IF NOT EXISTS (SELECT 1 FROM HOCHAM WHERE MSHH = @MSHH)
        RETURN 1
    INSERT INTO GIAOVIEN (MSGV, TENGV, DIACHI, SODT, MSHH, NAMHH)
    VALUES (@MSGV, @TENGV, @DIACHI, @SODT, @MSHH, @NAMHH)
    RETURN 2
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== A3 ==='
BEGIN TRAN
DECLARE @kq INT
EXEC @kq = sp_ThemGV 201, N'Trùng mã', '0909000004', N'Huế', 9, '2020'
SELECT N'MSGV = 201 trùng' AS TruongHop, @kq AS KetQua
EXEC @kq = sp_ThemGV 208, N'Đỗ Minh Khoa', '0909000004', N'Huế', 9, '2020'
SELECT N'MSHH = 9 không tồn tại' AS TruongHop, @kq AS KetQua
EXEC @kq = sp_ThemGV 208, N'Đỗ Minh Khoa', '0909000004', N'Huế', 2, '2020'
SELECT N'Hợp lệ' AS TruongHop, @kq AS KetQua
SELECT * FROM GIAOVIEN WHERE MSGV = 208
ROLLBACK
GO
```

**Kết quả:**

| TruongHop | KetQua |
|---|---|
| MSGV = 201 trùng | 0 |

| TruongHop | KetQua |
|---|---|
| MSHH = 9 không tồn tại | 1 |

| TruongHop | KetQua |
|---|---|
| Hợp lệ | 2 |

| MSGV | TENGV | DIACHI | SODT | MSHH | NAMHH |
|---|---|---|---|---|---|
| 208 | Đỗ Minh Khoa | Huế | 0909000004 | 2 | 2020-01-01 00:00:00 |

**Giải thích:**

Thứ tự kiểm tra đúng như đề: MSGV trùng trước (trả về 0), sau đó MSHH (trả về 1). Đề không quy định giá trị khi thêm thành công nên bài làm chọn **2** để phân biệt với hai trường hợp lỗi.

#### Câu A4
**Yêu cầu:** Đưa vào MSDT cũ, TENDT mới. Hãy cập nhật tên đề tài mới với mã đề tài cũ không đổi nếu không tìm thấy trả về 0, ngược lại cập nhật và trả về 1.

**Mã SQL:**

```sql
/* A4. Cập nhật tên đề tài theo MSDT; không tìm thấy -> 0, cập nhật -> 1. */
DROP PROCEDURE IF EXISTS sp_CapNhatTenDT
GO
CREATE PROCEDURE sp_CapNhatTenDT
    @MSDT CHAR(6), @TENDT NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON
    IF NOT EXISTS (SELECT 1 FROM DETAI WHERE MSDT = @MSDT)
        RETURN 0
    UPDATE DETAI SET TENDT = @TENDT WHERE MSDT = @MSDT
    RETURN 1
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== A4 ==='
BEGIN TRAN
DECLARE @kq INT
EXEC @kq = sp_CapNhatTenDT '99999', N'Không có'
SELECT N'MSDT = 99999' AS TruongHop, @kq AS KetQua
EXEC @kq = sp_CapNhatTenDT '97001', N'Quản lý thư viện số'
SELECT N'MSDT = 97001' AS TruongHop, @kq AS KetQua
SELECT * FROM DETAI WHERE MSDT = '97001'
ROLLBACK
GO
```

**Kết quả:**

| TruongHop | KetQua |
|---|---|
| MSDT = 99999 | 0 |

| TruongHop | KetQua |
|---|---|
| MSDT = 97001 | 1 |

| MSDT | TENDT |
|---|---|
| 97001 | Quản lý thư viện số |

**Giải thích:**

MSDT giữ nguyên, chỉ cập nhật TENDT. Kết quả thay đổi chỉ nằm trong giao tác demo và được ROLLBACK.

#### Câu A5
**Yêu cầu:** Tham số đưa vào MSSV, TENSV mới, DIACHI mới. Hãy cập nhật sinh viên trên với MSSV không đổi, nếu không tìm thấy trả về 0, ngược lại cập nhật và trả về 1.

**Mã SQL:**

```sql
/* A5. Cập nhật tên và địa chỉ sinh viên theo MSSV; không tìm thấy -> 0. */
DROP PROCEDURE IF EXISTS sp_CapNhatSV
GO
CREATE PROCEDURE sp_CapNhatSV
    @MSSV CHAR(8), @TENSV NVARCHAR(30), @DIACHI NCHAR(50)
AS
BEGIN
    SET NOCOUNT ON
    IF NOT EXISTS (SELECT 1 FROM SINHVIEN WHERE MSSV = @MSSV)
        RETURN 0
    UPDATE SINHVIEN SET TENSV = @TENSV, DIACHI = @DIACHI WHERE MSSV = @MSSV
    RETURN 1
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== A5 ==='
BEGIN TRAN
DECLARE @kq INT
EXEC @kq = sp_CapNhatSV '99999999', N'Không có', N'Không có'
SELECT N'MSSV = 99999999' AS TruongHop, @kq AS KetQua
EXEC @kq = sp_CapNhatSV '13520001', N'Nguyễn Văn Ân', N'QUẬN 7'
SELECT N'MSSV = 13520001' AS TruongHop, @kq AS KetQua
SELECT * FROM SINHVIEN WHERE MSSV = '13520001'
ROLLBACK
GO
```

**Kết quả:**

| TruongHop | KetQua |
|---|---|
| MSSV = 99999999 | 0 |

| TruongHop | KetQua |
|---|---|
| MSSV = 13520001 | 1 |

| MSSV | TENSV | SODT | LOP | DIACHI |
|---|---|---|---|---|
| 13520001 | Nguyễn Văn Ân | 0906762255 | SE103.U32 | QUẬN 7 |

**Giải thích:**

MSSV giữ nguyên, chỉ cập nhật TENSV và DIACHI. Cột DIACHI có kiểu `NCHAR(50)` nên giá trị được đệm khoảng trắng bên phải.


### B. Stored procedure với tham số vào và ra

Kết quả được trả qua tham số `OUTPUT`.

#### Câu B1
**Yêu cầu:** Đưa vào TENHV trả ra: Số GV thỏa học vị, nếu không tìm thấy trả về 0.

**Mã SQL:**

```sql
/* B1. Đưa vào TENHV, trả ra số GV đạt học vị đó (không có -> 0). */
DROP PROCEDURE IF EXISTS sp_DemGV_TheoHV
GO
CREATE PROCEDURE sp_DemGV_TheoHV
    @TENHV NVARCHAR(20), @SoGV INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    SELECT @SoGV = COUNT(DISTINCT G.MSGV)
    FROM GV_HV_CN G JOIN HOCVI H ON G.MSHV = H.MSHV
    WHERE H.TENHV = @TENHV
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== B1 ==='
DECLARE @SoGV INT
EXEC sp_DemGV_TheoHV N'Thạc sĩ', @SoGV OUTPUT
SELECT N'Thạc sĩ' AS TENHV, @SoGV AS SoGV
EXEC sp_DemGV_TheoHV N'Tiến sĩ', @SoGV OUTPUT
SELECT N'Tiến sĩ' AS TENHV, @SoGV AS SoGV
EXEC sp_DemGV_TheoHV N'Giáo sư', @SoGV OUTPUT
SELECT N'Giáo sư (không phải học vị)' AS TENHV, @SoGV AS SoGV
GO
```

**Kết quả:**

| TENHV | SoGV |
|---|---|
| Thạc sĩ | 3 |

| TENHV | SoGV |
|---|---|
| Tiến sĩ | 4 |

| TENHV | SoGV |
|---|---|
| Giáo sư (không phải học vị) | 0 |

**Giải thích:**

Đếm `DISTINCT MSGV` vì một giáo viên có thể có cùng học vị ở nhiều chuyên ngành (bảng GV_HV_CN có khóa gồm MSGV, MSHV, MSCN). `COUNT` trả về 0 khi không có dòng nào nên tự động đáp ứng yêu cầu "không tìm thấy trả về 0".

#### Câu B2
**Yêu cầu:** Đưa vào MSDT cho biết: Điểm trung bình của đề tài, nếu không tìm thấy trả về 0.

**Mã SQL:**

```sql
/* B2. Đưa vào MSDT, trả ra điểm trung bình của đề tài (không có -> 0). */
DROP PROCEDURE IF EXISTS sp_DiemTB_DeTai
GO
CREATE PROCEDURE sp_DiemTB_DeTai
    @MSDT CHAR(6), @DiemTB FLOAT OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    SELECT @DiemTB = ISNULL(AVG(DIEM), 0)
    FROM (SELECT DIEM FROM GV_HDDT WHERE MSDT = @MSDT
          UNION ALL
          SELECT DIEM FROM GV_PBDT WHERE MSDT = @MSDT
          UNION ALL
          SELECT DIEM FROM GV_UVDT WHERE MSDT = @MSDT) AS T
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== B2 ==='
DECLARE @DiemTB FLOAT
EXEC sp_DiemTB_DeTai '97001', @DiemTB OUTPUT
SELECT '97001' AS MSDT, CAST(@DiemTB AS DECIMAL(5, 2)) AS DiemTB
EXEC sp_DiemTB_DeTai '97006', @DiemTB OUTPUT
SELECT '97006' AS MSDT, CAST(@DiemTB AS DECIMAL(5, 2)) AS DiemTB
EXEC sp_DiemTB_DeTai '99999', @DiemTB OUTPUT
SELECT '99999' AS MSDT, CAST(@DiemTB AS DECIMAL(5, 2)) AS DiemTB
GO
```

**Kết quả:**

| MSDT | DiemTB |
|---|---|
| 97001 | 8.00 |

| MSDT | DiemTB |
|---|---|
| 97006 | 8.33 |

| MSDT | DiemTB |
|---|---|
| 99999 | .00 |

**Giải thích:**

Điểm trung bình của đề tài là trung bình mọi điểm của đề tài trong GV_HDDT, GV_PBDT và GV_UVDT (gộp bằng `UNION ALL` để không mất các điểm trùng giá trị). `AVG` trên tập rỗng cho `NULL` nên dùng `ISNULL(..., 0)`.

#### Câu B3
**Yêu cầu:** Đưa vào TENGV trả ra: SDT của giáo viên đó, nếu không tìm thấy trả về 0. Nếu trùng tên thì có báo lỗi không? Tại sao? Làm sao để hiện thông báo có bao nhiêu giáo viên trùng tên và trả về các SDT.

**Mã SQL:**

```sql
/* B3. Đưa vào TENGV, trả ra SĐT của giáo viên (không có -> '0').
   Nếu trùng tên: lệnh SELECT @bien = ... KHÔNG báo lỗi; biến chỉ giữ giá
   trị của dòng được đọc sau cùng nên kết quả không xác định được là của
   giáo viên nào. Bản cải tiến V2 đếm số GV trùng tên và trả về mọi SĐT. */
DROP PROCEDURE IF EXISTS sp_SDT_TheoTenGV
GO
CREATE PROCEDURE sp_SDT_TheoTenGV
    @TENGV NVARCHAR(30), @SoDT VARCHAR(10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    SET @SoDT = '0'
    SELECT @SoDT = SODT FROM GIAOVIEN WHERE TENGV = @TENGV
END
GO

DROP PROCEDURE IF EXISTS sp_SDT_TheoTenGV_V2
GO
CREATE PROCEDURE sp_SDT_TheoTenGV_V2
    @TENGV NVARCHAR(30), @SoLuong INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    SELECT @SoLuong = COUNT(*) FROM GIAOVIEN WHERE TENGV = @TENGV
    IF @SoLuong = 0
    BEGIN
        PRINT N'Không tìm thấy giáo viên ' + @TENGV
        RETURN
    END
    IF @SoLuong > 1
        PRINT N'Có ' + CAST(@SoLuong AS NVARCHAR(10)) + N' giáo viên trùng tên ' + @TENGV
    SELECT MSGV, TENGV, SODT FROM GIAOVIEN WHERE TENGV = @TENGV
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== B3 ==='
DECLARE @SoDT VARCHAR(10), @SoLuong INT
EXEC sp_SDT_TheoTenGV N'Chu Tiến', @SoDT OUTPUT
SELECT N'Chu Tiến' AS TENGV, @SoDT AS SODT
EXEC sp_SDT_TheoTenGV N'Lê Văn Tám', @SoDT OUTPUT
SELECT N'Lê Văn Tám' AS TENGV, @SoDT AS SODT
BEGIN TRAN
INSERT INTO GIAOVIEN VALUES (206, N'Trần Trung', N'Long An', '0909123456', 2, '2020')
EXEC sp_SDT_TheoTenGV N'Trần Trung', @SoDT OUTPUT
SELECT N'Trần Trung (2 GV trùng tên)' AS TENGV, @SoDT AS SODT
EXEC sp_SDT_TheoTenGV_V2 N'Trần Trung', @SoLuong OUTPUT
SELECT @SoLuong AS SoGVTrungTen
ROLLBACK
GO
```

**Kết quả:**

| TENGV | SODT |
|---|---|
| Chu Tiến | 46466646 |

| TENGV | SODT |
|---|---|
| Lê Văn Tám | 0 |

| TENGV | SODT |
|---|---|
| Trần Trung (2 GV trùng tên) | 0909123456 |

```text
Có 2 giáo viên trùng tên Trần Trung
```

| MSGV | TENGV | SODT |
|---|---|---|
| 201 | Trần Trung | 35353535 |
| 206 | Trần Trung | 0909123456 |

| SoGVTrungTen |
|---|
| 2 |

**Giải thích:**

**Nếu trùng tên thì có báo lỗi không? Tại sao?** Không báo lỗi. Lệnh `SELECT @SoDT = SODT FROM GIAOVIEN WHERE TENGV = @TENGV` gán biến lần lượt theo từng dòng thỏa điều kiện, nên sau cùng biến chỉ giữ giá trị của dòng được đọc **sau cùng**. Kết quả vì vậy không xác định được là SĐT của giáo viên nào (trong demo, thêm GV 206 cùng tên "Trần Trung" thì thủ tục trả về SĐT của GV 206 và bỏ mất SĐT của GV 201). Ngược lại, nếu gán bằng một truy vấn con vô hướng, ví dụ `SET @SoDT = (SELECT SODT FROM ...)`, thì SQL Server báo lỗi 512 khi truy vấn con trả về nhiều dòng.

**Cách hiện số giáo viên trùng tên và trả về các SĐT:** thủ tục `sp_SDT_TheoTenGV_V2` đếm số giáo viên có tên đó vào tham số ra `@SoLuong`, in thông báo khi có từ 2 giáo viên trở lên, và trả về danh sách MSGV, TENGV, SODT của tất cả các giáo viên đó.

#### Câu B4
**Yêu cầu:** Đưa vào MSHD cho biết: Điểm trung bình các đề tài của hội đồng đó.

**Mã SQL:**

```sql
/* B4. Đưa vào MSHD, cho biết điểm trung bình các đề tài của hội đồng
   (trung bình của các điểm trung bình đề tài; không có -> 0). */
DROP PROCEDURE IF EXISTS sp_DiemTB_HoiDong
GO
CREATE PROCEDURE sp_DiemTB_HoiDong
    @MSHD INT, @DiemTB FLOAT OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    SELECT @DiemTB = ISNULL(AVG(T.DTB), 0)
    FROM (SELECT HDT.MSDT, AVG(D.DIEM) AS DTB
          FROM HOIDONG_DT HDT
          JOIN (SELECT MSDT, DIEM FROM GV_HDDT
                UNION ALL
                SELECT MSDT, DIEM FROM GV_PBDT
                UNION ALL
                SELECT MSDT, DIEM FROM GV_UVDT) AS D ON D.MSDT = HDT.MSDT
          WHERE HDT.MSHD = @MSHD
          GROUP BY HDT.MSDT) AS T
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== B4 ==='
DECLARE @DiemTB FLOAT
EXEC sp_DiemTB_HoiDong 1, @DiemTB OUTPUT
SELECT 1 AS MSHD, CAST(@DiemTB AS DECIMAL(5, 2)) AS DiemTB
EXEC sp_DiemTB_HoiDong 2, @DiemTB OUTPUT
SELECT 2 AS MSHD, CAST(@DiemTB AS DECIMAL(5, 2)) AS DiemTB
EXEC sp_DiemTB_HoiDong 9, @DiemTB OUTPUT
SELECT 9 AS MSHD, CAST(@DiemTB AS DECIMAL(5, 2)) AS DiemTB
GO
```

**Kết quả:**

| MSHD | DiemTB |
|---|---|
| 1 | 8.13 |

| MSHD | DiemTB |
|---|---|
| 2 | 8.00 |

| MSHD | DiemTB |
|---|---|
| 9 | .00 |

**Giải thích:**

Điểm trung bình của hội đồng được tính là trung bình của các điểm trung bình đề tài thuộc hội đồng (bảng HOIDONG_DT), để đề tài có nhiều giáo viên chấm không "nặng ký" hơn đề tài có ít giáo viên chấm. Hội đồng 1 có các đề tài 97001 (8.0), 97002 (8.2), 97005 (8.2) nên điểm trung bình là 8.13. Hội đồng không tồn tại trả về 0.

#### Câu B5
**Yêu cầu:** Đưa vào TENGV cho biết: Số đề tài hướng dẫn, số đề tài phản biện do giáo viên đó phụ trách. Nếu trùng tên thì có báo lỗi không hay hệ thống sẽ đếm tất cả các đề tài của những giáo viên trùng tên đó?

**Mã SQL:**

```sql
/* B5. Đưa vào TENGV, cho biết số đề tài hướng dẫn và số đề tài phản biện.
   Nếu trùng tên: KHÔNG báo lỗi, phép kết theo TENGV đếm gộp đề tài của
   mọi giáo viên cùng tên. */
DROP PROCEDURE IF EXISTS sp_SoDT_TheoTenGV
GO
CREATE PROCEDURE sp_SoDT_TheoTenGV
    @TENGV NVARCHAR(30), @SoHD INT OUTPUT, @SoPB INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    SELECT @SoHD = COUNT(*)
    FROM GV_HDDT H JOIN GIAOVIEN G ON H.MSGV = G.MSGV
    WHERE G.TENGV = @TENGV
    SELECT @SoPB = COUNT(*)
    FROM GV_PBDT P JOIN GIAOVIEN G ON P.MSGV = G.MSGV
    WHERE G.TENGV = @TENGV
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== B5 ==='
DECLARE @SoHD INT, @SoPB INT
EXEC sp_SoDT_TheoTenGV N'Trần Trung', @SoHD OUTPUT, @SoPB OUTPUT
SELECT N'Trần Trung' AS TENGV, @SoHD AS SoDTHuongDan, @SoPB AS SoDTPhanBien
BEGIN TRAN
INSERT INTO GIAOVIEN VALUES (206, N'Trần Trung', N'Long An', '0909123456', 2, '2020')
INSERT INTO GV_HDDT VALUES (206, '97003', 8)
EXEC sp_SoDT_TheoTenGV N'Trần Trung', @SoHD OUTPUT, @SoPB OUTPUT
SELECT N'Trần Trung (thêm GV 206 trùng tên)' AS TENGV, @SoHD AS SoDTHuongDan, @SoPB AS SoDTPhanBien
ROLLBACK
GO
```

**Kết quả:**

| TENGV | SoDTHuongDan | SoDTPhanBien |
|---|---|---|
| Trần Trung | 1 | 1 |

| TENGV | SoDTHuongDan | SoDTPhanBien |
|---|---|---|
| Trần Trung (thêm GV 206 trùng tên) | 2 | 1 |

**Giải thích:**

**Nếu trùng tên thì có báo lỗi không?** Không báo lỗi. Phép kết `GV_HDDT JOIN GIAOVIEN ... WHERE TENGV = @TENGV` khớp với mọi giáo viên cùng tên, nên hệ thống **đếm gộp** các đề tài của tất cả giáo viên trùng tên. Trong demo, thêm GV 206 cùng tên "Trần Trung" và cho GV này hướng dẫn đề tài 97003 thì số đề tài hướng dẫn tăng từ 1 lên 2. Muốn đếm riêng từng người thì phải truyền MSGV thay cho TENGV.


### C. Trigger

#### Câu C1
**Yêu cầu:** Tạo Trigger thỏa mãn điều kiện khi xóa một đề tài sẽ xóa các thông tin liên quan.

**Mã SQL:**

```sql
/* C1. Xóa một đề tài thì xóa các thông tin liên quan.
   Phải dùng INSTEAD OF: khóa ngoại được kiểm tra TRƯỚC khi trigger AFTER
   chạy, nên lệnh DELETE trên DETAI sẽ bị khóa ngoại chặn ngay. */
DROP TRIGGER IF EXISTS trg_XoaDeTai
GO
CREATE TRIGGER trg_XoaDeTai ON DETAI
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON
    DELETE FROM SV_DETAI   WHERE MSDT IN (SELECT MSDT FROM deleted)
    DELETE FROM GV_HDDT    WHERE MSDT IN (SELECT MSDT FROM deleted)
    DELETE FROM GV_PBDT    WHERE MSDT IN (SELECT MSDT FROM deleted)
    DELETE FROM GV_UVDT    WHERE MSDT IN (SELECT MSDT FROM deleted)
    DELETE FROM HOIDONG_DT WHERE MSDT IN (SELECT MSDT FROM deleted)
    -- Bảng DETAI_DIEM (phần E) được tạo sau trigger này
    IF OBJECT_ID('DETAI_DIEM') IS NOT NULL
        DELETE FROM DETAI_DIEM WHERE MSDT IN (SELECT MSDT FROM deleted)
    DELETE FROM DETAI WHERE MSDT IN (SELECT MSDT FROM deleted)
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== C1 ==='
BEGIN TRAN
SELECT N'Trước' AS ThoiDiem,
       (SELECT COUNT(*) FROM SV_DETAI   WHERE MSDT = '97005') AS SV_DETAI,
       (SELECT COUNT(*) FROM GV_HDDT    WHERE MSDT = '97005') AS GV_HDDT,
       (SELECT COUNT(*) FROM GV_PBDT    WHERE MSDT = '97005') AS GV_PBDT,
       (SELECT COUNT(*) FROM GV_UVDT    WHERE MSDT = '97005') AS GV_UVDT,
       (SELECT COUNT(*) FROM HOIDONG_DT WHERE MSDT = '97005') AS HOIDONG_DT
DELETE FROM DETAI WHERE MSDT = '97005'
SELECT N'Sau' AS ThoiDiem,
       (SELECT COUNT(*) FROM SV_DETAI   WHERE MSDT = '97005') AS SV_DETAI,
       (SELECT COUNT(*) FROM GV_HDDT    WHERE MSDT = '97005') AS GV_HDDT,
       (SELECT COUNT(*) FROM GV_PBDT    WHERE MSDT = '97005') AS GV_PBDT,
       (SELECT COUNT(*) FROM GV_UVDT    WHERE MSDT = '97005') AS GV_UVDT,
       (SELECT COUNT(*) FROM HOIDONG_DT WHERE MSDT = '97005') AS HOIDONG_DT
ROLLBACK
GO
```

**Kết quả:**

| ThoiDiem | SV_DETAI | GV_HDDT | GV_PBDT | GV_UVDT | HOIDONG_DT |
|---|---|---|---|---|---|
| Trước | 2 | 1 | 1 | 3 | 1 |

| ThoiDiem | SV_DETAI | GV_HDDT | GV_PBDT | GV_UVDT | HOIDONG_DT |
|---|---|---|---|---|---|
| Sau | 0 | 0 | 0 | 0 | 0 |

**Giải thích:**

- Phải dùng trigger **INSTEAD OF DELETE**. Với trigger AFTER, SQL Server kiểm tra khóa ngoại **trước** khi trigger chạy, nên lệnh `DELETE FROM DETAI` bị khóa ngoại của SV_DETAI, GV_HDDT, … chặn ngay và trigger không bao giờ được gọi.
- Trigger xóa các bảng con (SV_DETAI, GV_HDDT, GV_PBDT, GV_UVDT, HOIDONG_DT) trước, sau đó mới xóa đề tài trong DETAI.
- Bảng DETAI_DIEM của phần E cũng tham chiếu DETAI nhưng được tạo sau trigger, nên trigger kiểm tra `OBJECT_ID('DETAI_DIEM')` trước khi xóa. Phần "C1 sau khi có DETAI_DIEM" ở cuối bài cho thấy đề tài 97006 bị xóa ở cả DETAI và DETAI_DIEM (6 → 5 dòng).

#### Câu C2
**Yêu cầu:** Tạo Trigger thỏa mãn ràng buộc là khi đổi 1 mã số giáo viên (MSGV) thì sẽ thay đổi các thông tin liên quan.

**Mã SQL:**

```sql
/* C2. Đổi MSGV thì cập nhật các thông tin liên quan.
   MSGV là khóa chính được 6 bảng tham chiếu nên không thể UPDATE trực tiếp.
   INSTEAD OF UPDATE thực hiện: (0) bỏ học hàm của mã cũ, (1) thêm GV mã mới
   (chưa gán học hàm), (2) chuyển các bảng con sang mã mới, (3) gán lại học
   hàm, (4) xóa mã cũ. Thứ tự này giúp không vi phạm ràng buộc C5 ở giữa chừng.
   Giới hạn: khi đổi khóa chính, inserted và deleted không còn cột chung để
   ghép cặp, nên mỗi lần chỉ được đổi mã của MỘT giáo viên. */
DROP TRIGGER IF EXISTS trg_DoiMSGV
GO
CREATE TRIGGER trg_DoiMSGV ON GIAOVIEN
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @Cu INT, @Moi INT, @MSHH INT

    IF UPDATE(MSGV)
    BEGIN
        IF (SELECT COUNT(*) FROM deleted) > 1
        BEGIN
            ROLLBACK TRANSACTION
            RAISERROR(N'Mỗi lần chỉ được đổi mã số của một giáo viên.', 16, 1)
            RETURN
        END
        SELECT @Cu = MSGV FROM deleted
        SELECT @Moi = MSGV, @MSHH = MSHH FROM inserted
    END

    -- Không đổi mã (hoặc gán lại đúng mã cũ): cập nhật các cột còn lại
    IF @Cu IS NULL OR @Cu = @Moi
    BEGIN
        UPDATE G
        SET TENGV = i.TENGV, DIACHI = i.DIACHI, SODT = i.SODT,
            MSHH = i.MSHH, NAMHH = i.NAMHH
        FROM GIAOVIEN G JOIN inserted i ON G.MSGV = i.MSGV
        RETURN
    END

    IF EXISTS (SELECT 1 FROM GIAOVIEN WHERE MSGV = @Moi)
    BEGIN
        ROLLBACK TRANSACTION
        RAISERROR(N'Mã số giáo viên mới đã tồn tại.', 16, 1)
        RETURN
    END

    UPDATE GIAOVIEN SET MSHH = NULL WHERE MSGV = @Cu                     -- (0)
    INSERT INTO GIAOVIEN (MSGV, TENGV, DIACHI, SODT, MSHH, NAMHH)        -- (1)
    SELECT MSGV, TENGV, DIACHI, SODT, NULL, NAMHH FROM inserted
    UPDATE GV_HV_CN   SET MSGV = @Moi WHERE MSGV = @Cu                   -- (2)
    UPDATE GV_HDDT    SET MSGV = @Moi WHERE MSGV = @Cu
    UPDATE GV_PBDT    SET MSGV = @Moi WHERE MSGV = @Cu
    UPDATE GV_UVDT    SET MSGV = @Moi WHERE MSGV = @Cu
    UPDATE HOIDONG    SET MSGV = @Moi WHERE MSGV = @Cu
    UPDATE HOIDONG_GV SET MSGV = @Moi WHERE MSGV = @Cu
    UPDATE GIAOVIEN SET MSHH = @MSHH WHERE MSGV = @Moi                   -- (3)
    DELETE FROM GIAOVIEN WHERE MSGV = @Cu                                -- (4)
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== C2 ==='
BEGIN TRAN
UPDATE GIAOVIEN SET MSGV = 210 WHERE MSGV = 201
SELECT * FROM GIAOVIEN WHERE MSGV IN (201, 210)
SELECT 'GV_HV_CN' AS Bang, COUNT(*) AS SoDong_210 FROM GV_HV_CN WHERE MSGV = 210
UNION ALL SELECT 'GV_HDDT', COUNT(*) FROM GV_HDDT WHERE MSGV = 210
UNION ALL SELECT 'GV_PBDT', COUNT(*) FROM GV_PBDT WHERE MSGV = 210
UNION ALL SELECT 'GV_UVDT', COUNT(*) FROM GV_UVDT WHERE MSGV = 210
UNION ALL SELECT 'HOIDONG', COUNT(*) FROM HOIDONG WHERE MSGV = 210
UNION ALL SELECT 'HOIDONG_GV', COUNT(*) FROM HOIDONG_GV WHERE MSGV = 210
ROLLBACK
BEGIN TRY
    BEGIN TRAN
    UPDATE GIAOVIEN SET MSGV = MSGV + 100 WHERE MSGV IN (204, 205)
    ROLLBACK
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK
    PRINT N'Bị chặn: ' + ERROR_MESSAGE()
END CATCH
GO
```

**Kết quả:**

| MSGV | TENGV | DIACHI | SODT | MSHH | NAMHH |
|---|---|---|---|---|---|
| 210 | Trần Trung | Bến Tre | 35353535 | 1 | 1996-01-01 00:00:00 |

| Bang | SoDong_210 |
|---|---|
| GV_HV_CN | 4 |
| GV_HDDT | 1 |
| GV_PBDT | 1 |
| GV_UVDT | 4 |
| HOIDONG | 1 |
| HOIDONG_GV | 2 |

```text
Bị chặn: Mỗi lần chỉ được đổi mã số của một giáo viên.
```

**Giải thích:**

- MSGV là khóa chính và được 6 bảng tham chiếu (GV_HV_CN, GV_HDDT, GV_PBDT, GV_UVDT, HOIDONG, HOIDONG_GV), nên lệnh `UPDATE GIAOVIEN SET MSGV = ...` bị khóa ngoại chặn. Vì vậy dùng trigger **INSTEAD OF UPDATE** để tự thực hiện thay lệnh gốc.
- Nếu không đổi MSGV, trigger cập nhật các cột còn lại theo `inserted`.
- Nếu đổi MSGV, trigger thực hiện: (0) bỏ học hàm của mã cũ; (1) thêm giáo viên với mã mới, chưa gán học hàm; (2) chuyển các bảng con sang mã mới; (3) gán lại học hàm cho mã mới; (4) xóa mã cũ. Thứ tự (0), (1), (3) giúp không vi phạm ràng buộc PGS phải là tiến sĩ (câu C5) ở bước trung gian.
- **Giới hạn:** khi khóa chính bị đổi, `inserted` và `deleted` không còn cột chung để ghép cặp dòng cũ với dòng mới, nên mỗi lần chỉ cho đổi mã của **một** giáo viên; đổi nhiều dòng cùng lúc sẽ bị báo lỗi. Mã mới trùng với mã đã có cũng bị báo lỗi.

#### Câu C3
**Yêu cầu:** Tạo Trigger thỏa mãn ràng buộc là một hội đồng không quá 10 đề tài. Dùng "Group by" có được không? Giải thích.

**Mã SQL:**

```sql
/* C3. Một hội đồng không quá 10 đề tài.
   Dùng GROUP BY được, nhưng phải gom nhóm trên TOÀN BẢNG HOIDONG_DT (chỉ
   xét các hội đồng có trong inserted). Nếu chỉ GROUP BY trên inserted thì
   chỉ đếm các dòng vừa thêm, bỏ sót đề tài đã có sẵn của hội đồng. */
DROP TRIGGER IF EXISTS trg_HoiDong_Max10DT
GO
CREATE TRIGGER trg_HoiDong_Max10DT ON HOIDONG_DT
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON
    IF EXISTS (SELECT HDT.MSHD
               FROM HOIDONG_DT HDT
               WHERE HDT.MSHD IN (SELECT MSHD FROM inserted)
               GROUP BY HDT.MSHD
               HAVING COUNT(*) > 10)
    BEGIN
        ROLLBACK TRANSACTION
        RAISERROR(N'Một hội đồng chỉ được đánh giá tối đa 10 đề tài.', 16, 1)
        RETURN
    END
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== C3 ==='
BEGIN TRY
    BEGIN TRAN
    INSERT INTO DETAI VALUES ('TD001', N'Đề tài tạm 1'), ('TD002', N'Đề tài tạm 2'),
        ('TD003', N'Đề tài tạm 3'), ('TD004', N'Đề tài tạm 4'), ('TD005', N'Đề tài tạm 5')
    -- Hội đồng 1 đang có 3 đề tài; thêm 8 đề tài -> 11
    INSERT INTO HOIDONG_DT VALUES (1, '97003', NULL), (1, '97004', NULL), (1, '97006', NULL),
        (1, 'TD001', NULL), (1, 'TD002', NULL), (1, 'TD003', NULL), (1, 'TD004', NULL), (1, 'TD005', NULL)
    ROLLBACK
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK
    PRINT N'Bị chặn: ' + ERROR_MESSAGE()
END CATCH
-- So sánh hai cách đếm khi thêm 1 đề tài vào hội đồng 1 (đang có 3 đề tài):
-- chỉ GROUP BY trên các dòng vừa thêm (sai) và trên toàn bảng (đúng)
BEGIN TRAN
INSERT INTO DETAI VALUES ('TD001', N'Đề tài tạm 1')
INSERT INTO HOIDONG_DT VALUES (1, 'TD001', NULL)
SELECT N'GROUP BY trên dòng vừa thêm (sai)' AS CachDem, MSHD, COUNT(*) AS SoDeTai
FROM HOIDONG_DT WHERE MSDT = 'TD001' GROUP BY MSHD
UNION ALL
SELECT N'GROUP BY trên toàn bảng (đúng)', MSHD, COUNT(*)
FROM HOIDONG_DT WHERE MSHD = 1 GROUP BY MSHD
ROLLBACK
GO
```

**Kết quả:**

```text
Bị chặn: Một hội đồng chỉ được đánh giá tối đa 10 đề tài.
```

| CachDem | MSHD | SoDeTai |
|---|---|---|
| GROUP BY trên dòng vừa thêm (sai) | 1 | 1 |
| GROUP BY trên toàn bảng (đúng) | 1 | 4 |

**Giải thích:**

**Dùng "Group by" có được không?** Được, nhưng phải gom nhóm trên **toàn bảng HOIDONG_DT** và chỉ xét các hội đồng có trong `inserted`. Trigger AFTER chạy khi các dòng mới đã nằm trong bảng, nên `GROUP BY MSHD HAVING COUNT(*) > 10` trên toàn bảng đếm đúng tổng số đề tài của hội đồng. Nếu chỉ `GROUP BY` trên `inserted` thì chỉ đếm các dòng vừa thêm và bỏ sót các đề tài đã có sẵn: bảng so sánh bên dưới cho thấy khi thêm 1 đề tài vào hội đồng 1, cách sai đếm được 1 trong khi thực tế hội đồng có 4 đề tài. Với cách sai, thêm 1 đề tài vào hội đồng đã có 10 đề tài vẫn lọt qua.

Demo: hội đồng 1 đang có 3 đề tài, thêm 5 đề tài tạm và gán 8 đề tài cho hội đồng 1 (tổng 11) thì bị chặn.

#### Câu C4
**Yêu cầu:** Tạo Trigger thỏa mãn ràng buộc là một đề tài không quá 2 sinh viên. Dùng "Group by" có được không? Giải thích.

**Mã SQL:**

```sql
/* C4. Một đề tài không quá 2 sinh viên. Lập luận về GROUP BY giống C3. */
DROP TRIGGER IF EXISTS trg_DeTai_Max2SV
GO
CREATE TRIGGER trg_DeTai_Max2SV ON SV_DETAI
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON
    IF EXISTS (SELECT S.MSDT
               FROM SV_DETAI S
               WHERE S.MSDT IN (SELECT MSDT FROM inserted)
               GROUP BY S.MSDT
               HAVING COUNT(*) > 2)
    BEGIN
        ROLLBACK TRANSACTION
        RAISERROR(N'Một đề tài chỉ được tối đa 2 sinh viên thực hiện.', 16, 1)
        RETURN
    END
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== C4 ==='
SELECT MSDT, COUNT(*) AS SoSV FROM SV_DETAI GROUP BY MSDT
BEGIN TRY
    BEGIN TRAN
    INSERT INTO SV_DETAI VALUES ('13520001', '97005')   -- 97005 đã có 2 SV
    ROLLBACK
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK
    PRINT N'Bị chặn: ' + ERROR_MESSAGE()
END CATCH
GO
```

**Kết quả:**

| MSDT | SoSV |
|---|---|
| 97001 | 1 |
| 97002 | 1 |
| 97003 | 1 |
| 97004 | 1 |
| 97005 | 2 |

```text
Bị chặn: Một đề tài chỉ được tối đa 2 sinh viên thực hiện.
```

**Giải thích:**

**Dùng "Group by" có được không?** Được, với cùng lập luận như C3: gom nhóm trên toàn bảng SV_DETAI theo MSDT, chỉ xét các đề tài có trong `inserted`, `HAVING COUNT(*) > 2`. Đề tài 97005 đã có 2 sinh viên nên thêm sinh viên thứ 3 bị chặn.

#### Câu C5
**Yêu cầu:** Tạo Trigger thỏa mãn ràng buộc là một giáo viên muốn có học hàm PGS phải là tiến sĩ.

**Mã SQL:**

```sql
/* C5. Giáo viên muốn có học hàm Phó giáo sư phải có học vị Tiến sĩ
   (Tiến sĩ hoặc Tiến sĩ Khoa học). Bảng tầm ảnh hưởng:
     GIAOVIEN : thêm (+), sửa MSHH (+)        -> trg_PGS_PhaiTS_GV
     GV_HV_CN : xóa (+), sửa MSHV/MSGV (+)    -> trg_PGS_PhaiTS_HV
   Lưu ý: không thể thêm mới trực tiếp một GV đã là PGS, vì dòng học vị trong
   GV_HV_CN cần GV tồn tại trước (khóa ngoại). Quy trình: thêm GV với MSHH
   NULL -> thêm học vị Tiến sĩ -> cập nhật MSHH. */
DROP TRIGGER IF EXISTS trg_PGS_PhaiTS_GV
GO
CREATE TRIGGER trg_PGS_PhaiTS_GV ON GIAOVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON
    IF EXISTS (SELECT 1
               FROM inserted i JOIN HOCHAM HH ON i.MSHH = HH.MSHH
               WHERE HH.TENHH = N'PHÓ GIÁO SƯ'
                 AND NOT EXISTS (SELECT 1
                                 FROM GV_HV_CN G JOIN HOCVI HV ON G.MSHV = HV.MSHV
                                 WHERE G.MSGV = i.MSGV AND HV.TENHV LIKE N'Tiến sĩ%'))
    BEGIN
        ROLLBACK TRANSACTION
        RAISERROR(N'Giáo viên có học hàm Phó giáo sư phải có học vị Tiến sĩ.', 16, 1)
        RETURN
    END
END
GO

DROP TRIGGER IF EXISTS trg_PGS_PhaiTS_HV
GO
CREATE TRIGGER trg_PGS_PhaiTS_HV ON GV_HV_CN
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON
    IF EXISTS (SELECT 1
               FROM GIAOVIEN GV JOIN HOCHAM HH ON GV.MSHH = HH.MSHH
               WHERE HH.TENHH = N'PHÓ GIÁO SƯ'
                 AND GV.MSGV IN (SELECT MSGV FROM deleted)
                 AND NOT EXISTS (SELECT 1
                                 FROM GV_HV_CN G JOIN HOCVI HV ON G.MSHV = HV.MSHV
                                 WHERE G.MSGV = GV.MSGV AND HV.TENHV LIKE N'Tiến sĩ%'))
    BEGIN
        ROLLBACK TRANSACTION
        RAISERROR(N'Giáo viên có học hàm Phó giáo sư phải có học vị Tiến sĩ.', 16, 1)
        RETURN
    END
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== C5 ==='
BEGIN TRY
    BEGIN TRAN
    UPDATE GIAOVIEN SET MSHH = 1 WHERE MSGV = 205      -- GV 205 chỉ là Thạc sĩ
    ROLLBACK
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK
    PRINT N'(a) Bị chặn: ' + ERROR_MESSAGE()
END CATCH
BEGIN TRY
    BEGIN TRAN
    DELETE FROM GV_HV_CN WHERE MSGV = 201 AND MSHV = 4 -- xóa học vị TS của PGS
    ROLLBACK
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK
    PRINT N'(b) Bị chặn: ' + ERROR_MESSAGE()
END CATCH
BEGIN TRAN
INSERT INTO GIAOVIEN VALUES (207, N'Mai Thị Hoa', N'Huế', '0909000003', NULL, '2021')
INSERT INTO GV_HV_CN VALUES (207, 4, 1, '2020')
UPDATE GIAOVIEN SET MSHH = 1 WHERE MSGV = 207
SELECT N'(c) Quy trình hợp lệ' AS TruongHop, MSGV, TENGV, MSHH FROM GIAOVIEN WHERE MSGV = 207
ROLLBACK
GO
```

**Kết quả:**

```text
(a) Bị chặn: Giáo viên có học hàm Phó giáo sư phải có học vị Tiến sĩ.
(b) Bị chặn: Giáo viên có học hàm Phó giáo sư phải có học vị Tiến sĩ.
```

| TruongHop | MSGV | TENGV | MSHH |
|---|---|---|---|
| (c) Quy trình hợp lệ | 207 | Mai Thị Hoa | 1 |

**Giải thích:**

**Bảng tầm ảnh hưởng:**

| Bảng | Thêm | Xóa | Sửa |
|---|---|---|---|
| GIAOVIEN | + | – | + (MSHH) |
| GV_HV_CN | – | + | + (MSGV, MSHV) |
| HOCHAM, HOCVI | – | – (khóa ngoại chặn) | – (không đổi mã) |

- `trg_PGS_PhaiTS_GV` (trên GIAOVIEN) kiểm tra giáo viên vừa thêm/sửa có học hàm Phó giáo sư (nhận diện qua `TENHH = N'PHÓ GIÁO SƯ'`, không gán cứng mã số) thì phải có học vị Tiến sĩ (`TENHV LIKE N'Tiến sĩ%'`, gồm Tiến sĩ và Tiến sĩ Khoa học).
- `trg_PGS_PhaiTS_HV` (trên GV_HV_CN) chặn việc xóa hoặc sửa làm mất học vị Tiến sĩ của một giáo viên đang là Phó giáo sư.
- **Lưu ý:** không thể thêm mới trực tiếp một giáo viên đã là PGS, vì dòng học vị trong GV_HV_CN đòi hỏi giáo viên tồn tại trước (khóa ngoại). Quy trình hợp lệ là: thêm giáo viên với MSHH = NULL → thêm học vị Tiến sĩ → cập nhật MSHH (demo trường hợp (c)).
- Dữ liệu gốc của đề không có giáo viên nào là tiến sĩ, nên bài làm đã bổ sung học vị Tiến sĩ cho GV 201–204 (xem Phần 1.2).


### D. Function

#### Câu D1
**Yêu cầu:** Viết hàm tính điểm trung bình của một đề tài. Giá trị trả về là điểm trung bình ứng với mã số đề tài nhập vào.

**Mã SQL:**

```sql
/* D1. Hàm (scalar) tính điểm trung bình của một đề tài; NULL nếu chưa có điểm. */
DROP FUNCTION IF EXISTS fn_DiemTB_DeTai
GO
CREATE FUNCTION fn_DiemTB_DeTai (@MSDT CHAR(6))
RETURNS FLOAT
AS
BEGIN
    DECLARE @DiemTB FLOAT
    SELECT @DiemTB = AVG(DIEM)
    FROM (SELECT DIEM FROM GV_HDDT WHERE MSDT = @MSDT
          UNION ALL
          SELECT DIEM FROM GV_PBDT WHERE MSDT = @MSDT
          UNION ALL
          SELECT DIEM FROM GV_UVDT WHERE MSDT = @MSDT) AS T
    RETURN @DiemTB
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== D1 ==='
SELECT MSDT, TENDT, CAST(dbo.fn_DiemTB_DeTai(MSDT) AS DECIMAL(5, 2)) AS DiemTB FROM DETAI
GO
```

**Kết quả:**

| MSDT | TENDT | DiemTB |
|---|---|---|
| 97001 | Quản lý thư viện | 8.00 |
| 97002 | Nhận dạng vân tay | 8.20 |
| 97003 | Bán đấu giá trên mạng | 7.50 |
| 97004 | Quản lý siêu thị | 8.00 |
| 97005 | Xử lý ảnh | 8.20 |
| 97006 | Hệ giải toán thông minh | 8.33 |

**Giải thích:**

Hàm scalar trả về `FLOAT`; đề tài chưa có điểm nào thì trả về `NULL` (khác với B2 trả về 0 theo yêu cầu riêng của câu B2).

#### Câu D2
**Yêu cầu:** Trả về kết quả của đề tài theo MSDT nhập vào. Kết quả là DAT nếu như điểm trung bình từ 5 trở lên, và KHONGDAT nếu như điểm trung bình dưới 5.

**Mã SQL:**

```sql
/* D2. Kết quả đề tài: DAT nếu điểm trung bình >= 5, KHONGDAT nếu < 5. */
DROP FUNCTION IF EXISTS fn_KetQua_DeTai
GO
CREATE FUNCTION fn_KetQua_DeTai (@MSDT CHAR(6))
RETURNS NVARCHAR(10)
AS
BEGIN
    DECLARE @DiemTB FLOAT = dbo.fn_DiemTB_DeTai(@MSDT)
    RETURN CASE WHEN @DiemTB IS NULL THEN NULL
                WHEN @DiemTB >= 5   THEN N'DAT'
                ELSE N'KHONGDAT' END
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== D2 ==='
SELECT MSDT, CAST(dbo.fn_DiemTB_DeTai(MSDT) AS DECIMAL(5, 2)) AS DiemTB, dbo.fn_KetQua_DeTai(MSDT) AS KetQua FROM DETAI
BEGIN TRAN
INSERT INTO DETAI VALUES ('TD009', N'Đề tài điểm thấp')
INSERT INTO GV_UVDT VALUES (201, 'TD009', 3), (202, 'TD009', 4)
SELECT 'TD009' AS MSDT, CAST(dbo.fn_DiemTB_DeTai('TD009') AS DECIMAL(5, 2)) AS DiemTB, dbo.fn_KetQua_DeTai('TD009') AS KetQua
ROLLBACK
GO
```

**Kết quả:**

| MSDT | DiemTB | KetQua |
|---|---|---|
| 97001 | 8.00 | DAT |
| 97002 | 8.20 | DAT |
| 97003 | 7.50 | DAT |
| 97004 | 8.00 | DAT |
| 97005 | 8.20 | DAT |
| 97006 | 8.33 | DAT |

| MSDT | DiemTB | KetQua |
|---|---|---|
| TD009 | 3.50 | KHONGDAT |

**Giải thích:**

Hàm gọi lại D1 để không lặp lại công thức tính điểm. Đề tài chưa có điểm thì trả về `NULL`. Dữ liệu gốc đều đạt, nên demo thêm một đề tài tạm có điểm 3 và 4 (trung bình 3.5) để thấy kết quả KHONGDAT.

#### Câu D3
**Yêu cầu:** Đưa vào MSDT, trả về mã số và họ tên của các sinh viên thực hiện đề tài.

**Mã SQL:**

```sql
/* D3. Đưa vào MSDT, trả về mã số và họ tên các sinh viên thực hiện đề tài
   (inline table-valued function). */
DROP FUNCTION IF EXISTS fn_SV_DeTai
GO
CREATE FUNCTION fn_SV_DeTai (@MSDT CHAR(6))
RETURNS TABLE
AS
RETURN (SELECT SV.MSSV, SV.TENSV
        FROM SV_DETAI SD JOIN SINHVIEN SV ON SD.MSSV = SV.MSSV
        WHERE SD.MSDT = @MSDT)
GO
```

**Chạy thử:**

```sql
PRINT N'=== D3 ==='
SELECT * FROM dbo.fn_SV_DeTai('97005')
GO
```

**Kết quả:**

| MSSV | TENSV |
|---|---|
| 13520002 | Phan Tấn Đạt |
| 13520006 | Ưng Hồng Ân |

**Giải thích:**

Hàm dạng inline table-valued, dùng được như một bảng trong `FROM`.


### E. Cursor

#### Câu E1
**Yêu cầu:** Viết Cursor tính điểm trung bình cho từng đề tài. Sau đó lưu kết quả vào bảng DETAI_DIEM.

**Mã SQL** (tạo bảng DETAI_DIEM và cursor):

```sql
DROP TABLE IF EXISTS DETAI_DIEM
GO
CREATE TABLE DETAI_DIEM (
    MSDT   CHAR(6) PRIMARY KEY FOREIGN KEY REFERENCES DETAI(MSDT),
    DIEMTB FLOAT
)
GO

/* E1. Cursor tính điểm trung bình cho từng đề tài, lưu vào DETAI_DIEM.
   Xóa dữ liệu cũ trước để chạy lại nhiều lần không bị trùng khóa. */
PRINT N'=== E1 ==='
DELETE FROM DETAI_DIEM
DECLARE @MSDT CHAR(6)
DECLARE cur_DeTai CURSOR FOR
    SELECT MSDT FROM DETAI
OPEN cur_DeTai
FETCH NEXT FROM cur_DeTai INTO @MSDT
WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO DETAI_DIEM (MSDT, DIEMTB)
    VALUES (@MSDT, dbo.fn_DiemTB_DeTai(@MSDT))
    FETCH NEXT FROM cur_DeTai INTO @MSDT
END
CLOSE cur_DeTai
DEALLOCATE cur_DeTai
SELECT MSDT, CAST(DIEMTB AS DECIMAL(5, 2)) AS DIEMTB FROM DETAI_DIEM
GO
```

**Kết quả:**

| MSDT | DIEMTB |
|---|---|
| 97001 | 8.00 |
| 97002 | 8.20 |
| 97003 | 7.50 |
| 97004 | 8.00 |
| 97005 | 8.20 |
| 97006 | 8.33 |

**Giải thích:**

Bảng DETAI_DIEM có khóa chính MSDT và khóa ngoại tới DETAI. Cursor `cur_DeTai` duyệt từng đề tài, gọi hàm D1 để tính điểm trung bình rồi thêm vào DETAI_DIEM. Dữ liệu cũ được xóa trước để chạy lại nhiều lần không bị trùng khóa. Cuối cùng đóng (`CLOSE`) và giải phóng (`DEALLOCATE`) cursor.

#### Câu E2
**Yêu cầu:** Gom các bước xử lý của Cursor ở câu 1 vào một Stored Procedure.

**Mã SQL:**

```sql
/* E2. Gom các bước xử lý của cursor ở E1 vào một stored procedure. */
DROP PROCEDURE IF EXISTS sp_TinhDiemTB_DeTai
GO
CREATE PROCEDURE sp_TinhDiemTB_DeTai
AS
BEGIN
    SET NOCOUNT ON
    DELETE FROM DETAI_DIEM
    DECLARE @MSDT CHAR(6)
    DECLARE cur_DeTai CURSOR LOCAL FOR
        SELECT MSDT FROM DETAI
    OPEN cur_DeTai
    FETCH NEXT FROM cur_DeTai INTO @MSDT
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO DETAI_DIEM (MSDT, DIEMTB)
        VALUES (@MSDT, dbo.fn_DiemTB_DeTai(@MSDT))
        FETCH NEXT FROM cur_DeTai INTO @MSDT
    END
    CLOSE cur_DeTai
    DEALLOCATE cur_DeTai
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== E2 ==='
EXEC sp_TinhDiemTB_DeTai
SELECT MSDT, CAST(DIEMTB AS DECIMAL(5, 2)) AS DIEMTB FROM DETAI_DIEM
GO
```

**Kết quả:**

| MSDT | DIEMTB |
|---|---|
| 97001 | 8.00 |
| 97002 | 8.20 |
| 97003 | 7.50 |
| 97004 | 8.00 |
| 97005 | 8.20 |
| 97006 | 8.33 |

**Giải thích:**

Thủ tục `sp_TinhDiemTB_DeTai` chứa đúng các bước của E1; cursor khai báo `LOCAL` để không xung đột tên với cursor toàn cục ở E1.

#### Câu E3
**Yêu cầu:** Tạo thêm cột XEPLOAI có kiểu là NVARCHAR(20) trong bảng DETAI_DIEM, viết Cursor cập nhật kết quả xếp loại cho mỗi đề tài như sau: "Xuất sắc": điểm trung bình từ 9 đến 10; "Giỏi": từ 8 đến 9; "Khá": từ 7 đến 8; "Trung bình khá": từ 6 đến 7; "Trung bình": từ 5 đến 6; "Yếu": từ 4 đến 5; "Kém": dưới 4.

**Mã SQL:**

```sql
/* E3. Thêm cột XEPLOAI và dùng cursor cập nhật xếp loại cho từng đề tài.
   Các khoảng điểm trong đề trùng nhau ở đầu mút (VD: 9 thuộc cả "9 đến 10"
   và "8 đến 9") nên quy ước cận dưới được tính vào loại cao hơn:
   >= 9 Xuất sắc; >= 8 Giỏi; >= 7 Khá; >= 6 Trung bình khá; >= 5 Trung bình;
   >= 4 Yếu; < 4 Kém. Cursor được đặt trong thủ tục để có thể chạy lại. */
ALTER TABLE DETAI_DIEM ADD XEPLOAI NVARCHAR(20)
GO

DROP PROCEDURE IF EXISTS sp_XepLoai_DeTai
GO
CREATE PROCEDURE sp_XepLoai_DeTai
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @DiemTB FLOAT
    DECLARE cur_XepLoai CURSOR LOCAL FOR
        SELECT DIEMTB FROM DETAI_DIEM
        FOR UPDATE OF XEPLOAI
    OPEN cur_XepLoai
    FETCH NEXT FROM cur_XepLoai INTO @DiemTB
    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE DETAI_DIEM
        SET XEPLOAI = CASE WHEN @DiemTB IS NULL THEN NULL
                           WHEN @DiemTB >= 9 THEN N'Xuất sắc'
                           WHEN @DiemTB >= 8 THEN N'Giỏi'
                           WHEN @DiemTB >= 7 THEN N'Khá'
                           WHEN @DiemTB >= 6 THEN N'Trung bình khá'
                           WHEN @DiemTB >= 5 THEN N'Trung bình'
                           WHEN @DiemTB >= 4 THEN N'Yếu'
                           ELSE N'Kém' END
        WHERE CURRENT OF cur_XepLoai
        FETCH NEXT FROM cur_XepLoai INTO @DiemTB
    END
    CLOSE cur_XepLoai
    DEALLOCATE cur_XepLoai
END
GO
```

**Chạy thử:**

```sql
PRINT N'=== E3 ==='
EXEC sp_XepLoai_DeTai
SELECT D.MSDT, T.TENDT, CAST(D.DIEMTB AS DECIMAL(5, 2)) AS DIEMTB, D.XEPLOAI
FROM DETAI_DIEM D JOIN DETAI T ON D.MSDT = T.MSDT
GO
```

**Kết quả:**

| MSDT | TENDT | DIEMTB | XEPLOAI |
|---|---|---|---|
| 97001 | Quản lý thư viện | 8.00 | Giỏi |
| 97002 | Nhận dạng vân tay | 8.20 | Giỏi |
| 97003 | Bán đấu giá trên mạng | 7.50 | Khá |
| 97004 | Quản lý siêu thị | 8.00 | Giỏi |
| 97005 | Xử lý ảnh | 8.20 | Giỏi |
| 97006 | Hệ giải toán thông minh | 8.33 | Giỏi |

**Giải thích:**

- Cột XEPLOAI được thêm bằng `ALTER TABLE` trong một batch riêng, trước khi tạo thủ tục dùng đến nó.
- Các khoảng điểm trong đề trùng nhau ở đầu mút (ví dụ 9 thuộc cả "từ 9 đến 10" và "từ 8 đến 9"), nên bài làm quy ước cận dưới thuộc loại cao hơn: ≥ 9 Xuất sắc; ≥ 8 Giỏi; ≥ 7 Khá; ≥ 6 Trung bình khá; ≥ 5 Trung bình; ≥ 4 Yếu; < 4 Kém.
- Cursor khai báo `FOR UPDATE OF XEPLOAI` và cập nhật bằng `WHERE CURRENT OF`, tức cập nhật đúng dòng cursor đang đứng. Cursor được đặt trong thủ tục `sp_XepLoai_DeTai` để có thể chạy lại mỗi khi điểm thay đổi.

#### Kiểm tra lại C1 sau khi có bảng DETAI_DIEM

```sql
/* Kiểm tra lại C1 sau khi đã có bảng DETAI_DIEM. */
PRINT N'=== C1 (sau khi có DETAI_DIEM) ==='
BEGIN TRAN
DELETE FROM DETAI WHERE MSDT = '97006'
SELECT (SELECT COUNT(*) FROM DETAI) AS SoDeTai, (SELECT COUNT(*) FROM DETAI_DIEM) AS SoDong_DETAI_DIEM
ROLLBACK
GO
```

**Kết quả:** đề tài 97006 bị xóa ở cả DETAI và DETAI_DIEM (mỗi bảng còn 5 dòng).

| SoDeTai | SoDong_DETAI_DIEM |
|---|---|
| 5 | 5 |
