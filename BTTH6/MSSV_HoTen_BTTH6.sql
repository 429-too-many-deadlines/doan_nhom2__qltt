/* =====================================================================
   IE103 - Quản lý Thông tin
   Bài tập thực hành tuần 6: BÀI TẬP TỔNG HỢP (CSDL Quản lý đề tài - QLDT)
   Sinh viên: MSSV - Họ tên
   Môi trường: Microsoft SQL Server 2022
   ===================================================================== */

/* =====================================================================
   CÂU 0. TẠO LẠI CSDL QLDT (lược đồ và dữ liệu theo BTTH2)
   ===================================================================== */
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

-- Dữ liệu BỔ SUNG (không có trong BTTH2): dữ liệu gốc chưa có GV nào đạt học vị
-- Tiến sĩ, trong khi ràng buộc 2.3 yêu cầu chủ tịch hội đồng (GV 201, 202, 203)
-- phải là tiến sĩ, và mẫu report 4.1 ghi Trần Trung, Nguyễn Thị Loan là TS.
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

/* =====================================================================
   CÂU 2. XỬ LÝ THÔNG TIN
   ===================================================================== */

/* ---------------------------------------------------------------------
   2.1. Một sinh viên chỉ được tham gia một đề tài.
   Bảng tầm ảnh hưởng:  SV_DETAI | Thêm: + | Xóa: - | Sửa: + (MSSV)
   Hiện thực: ràng buộc UNIQUE trên cột MSSV của SV_DETAI.
   --------------------------------------------------------------------- */
ALTER TABLE SV_DETAI ADD CONSTRAINT UQ_SVDETAI_MSSV UNIQUE (MSSV)
GO

PRINT N'=== 2.1 - thu vi pham ==='
BEGIN TRY
    INSERT INTO SV_DETAI VALUES ('13520001', '97001')   -- SV 13520001 đã làm đề tài 97004
END TRY
BEGIN CATCH
    PRINT N'Bị chặn: ' + ERROR_MESSAGE()
END CATCH
GO

/* ---------------------------------------------------------------------
   2.2. Điểm của đề tài trong thang điểm từ 0 đến 10.
   Bảng tầm ảnh hưởng:  GV_HDDT, GV_PBDT, GV_UVDT | Thêm: + | Xóa: - | Sửa: + (DIEM)
   Hiện thực: ràng buộc CHECK trên cột DIEM của 3 bảng.
   --------------------------------------------------------------------- */
ALTER TABLE GV_HDDT ADD CONSTRAINT CK_GVHDDT_DIEM CHECK (DIEM BETWEEN 0 AND 10)
ALTER TABLE GV_PBDT ADD CONSTRAINT CK_GVPBDT_DIEM CHECK (DIEM BETWEEN 0 AND 10)
ALTER TABLE GV_UVDT ADD CONSTRAINT CK_GVUVDT_DIEM CHECK (DIEM BETWEEN 0 AND 10)
GO

PRINT N'=== 2.2 - thu vi pham ==='
BEGIN TRY
    INSERT INTO GV_HDDT VALUES (204, '97006', 11)
END TRY
BEGIN CATCH
    PRINT N'Bị chặn: ' + ERROR_MESSAGE()
END CATCH
BEGIN TRY
    UPDATE GV_UVDT SET DIEM = -1 WHERE MSGV = 201 AND MSDT = '97006'
END TRY
BEGIN CATCH
    PRINT N'Bị chặn: ' + ERROR_MESSAGE()
END CATCH
GO

/* ---------------------------------------------------------------------
   2.3. GV là chủ tịch hội đồng phải có học vị tiến sĩ.
   Bảng tầm ảnh hưởng:
       HOIDONG  | Thêm: + | Xóa: - | Sửa: + (MSGV)
       GV_HV_CN | Thêm: - | Xóa: + | Sửa: + (MSGV, MSHV)
       HOCVI    | Thêm: - | Xóa: - (*) | Sửa: + (TENHV)
       (*) Xóa HOCVI đã bị khóa ngoại từ GV_HV_CN chặn.
   Hiện thực: 3 trigger. "Tiến sĩ" gồm cả "Tiến sĩ Khoa học" (TENHV LIKE N'Tiến sĩ%').
   --------------------------------------------------------------------- */
CREATE TRIGGER trg_HOIDONG_ChuTichTienSi
ON HOIDONG AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON
    IF EXISTS (SELECT 1 FROM inserted i
               WHERE i.MSGV IS NOT NULL
                 AND NOT EXISTS (SELECT 1 FROM GV_HV_CN g JOIN HOCVI h ON g.MSHV = h.MSHV
                                 WHERE g.MSGV = i.MSGV AND h.TENHV LIKE N'Tiến sĩ%'))
    BEGIN
        RAISERROR (N'Chủ tịch hội đồng phải có học vị tiến sĩ!', 16, 1)
        ROLLBACK TRANSACTION
    END
END
GO

CREATE TRIGGER trg_GVHVCN_ChuTichTienSi
ON GV_HV_CN AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON
    IF EXISTS (SELECT 1 FROM HOIDONG hd
               WHERE hd.MSGV IN (SELECT MSGV FROM deleted)
                 AND NOT EXISTS (SELECT 1 FROM GV_HV_CN g JOIN HOCVI h ON g.MSHV = h.MSHV
                                 WHERE g.MSGV = hd.MSGV AND h.TENHV LIKE N'Tiến sĩ%'))
    BEGIN
        RAISERROR (N'Giáo viên đang là chủ tịch hội đồng, không thể mất học vị tiến sĩ!', 16, 1)
        ROLLBACK TRANSACTION
    END
END
GO

CREATE TRIGGER trg_HOCVI_ChuTichTienSi
ON HOCVI AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON
    IF UPDATE(TENHV)
       AND EXISTS (SELECT 1 FROM HOIDONG hd
                   WHERE hd.MSGV IS NOT NULL
                     AND NOT EXISTS (SELECT 1 FROM GV_HV_CN g JOIN HOCVI h ON g.MSHV = h.MSHV
                                     WHERE g.MSGV = hd.MSGV AND h.TENHV LIKE N'Tiến sĩ%'))
    BEGIN
        RAISERROR (N'Đổi tên học vị làm chủ tịch hội đồng không còn là tiến sĩ!', 16, 1)
        ROLLBACK TRANSACTION
    END
END
GO

PRINT N'=== 2.3 - thu vi pham ==='
BEGIN TRY
    -- GV 205 (Chu Tiến) chỉ có học vị Thạc sĩ
    INSERT INTO HOIDONG VALUES (4, 4, '08:00', '2014-12-10', N'Thật', 205)
END TRY
BEGIN CATCH
    PRINT N'Bị chặn (thêm HĐ, chủ tịch 205): ' + ERROR_MESSAGE()
END CATCH
BEGIN TRY
    UPDATE HOIDONG SET MSGV = 205 WHERE MSHD = 1
END TRY
BEGIN CATCH
    PRINT N'Bị chặn (đổi chủ tịch HĐ1 thành 205): ' + ERROR_MESSAGE()
END CATCH
BEGIN TRY
    -- GV 201 đang là chủ tịch HĐ1, HĐ3
    DELETE FROM GV_HV_CN WHERE MSGV = 201 AND MSHV = 4
END TRY
BEGIN CATCH
    PRINT N'Bị chặn (xóa học vị TS của GV 201): ' + ERROR_MESSAGE()
END CATCH
BEGIN TRY
    UPDATE HOCVI SET TENHV = N'Doctor' WHERE MSHV = 4
END TRY
BEGIN CATCH
    PRINT N'Bị chặn (đổi tên học vị Tiến sĩ): ' + ERROR_MESSAGE()
END CATCH
GO

PRINT N'=== 2.3 - truong hop hop le ==='
-- GV 204 (Nguyễn Thị Loan) là tiến sĩ -> được phép làm chủ tịch
INSERT INTO HOIDONG VALUES (4, 4, '08:00', '2014-12-10', N'Thật', 204)
SELECT MSHD, PHONG, NGAYHD, MSGV AS CHUTICH FROM HOIDONG WHERE MSHD = 4
DELETE FROM HOIDONG WHERE MSHD = 4   -- dọn dữ liệu thử
GO

/* ---------------------------------------------------------------------
   Hàm dùng chung: điểm trung bình của một đề tài.
   Điểm TB = trung bình cộng của các thành phần hiện có:
             AVG(điểm hướng dẫn), AVG(điểm phản biện), AVG(điểm ủy viên).
   (Khớp với mẫu report 4.2: Xử lý ảnh = (9 + 8 + 8) / 3 = 8.33)
   --------------------------------------------------------------------- */
CREATE FUNCTION fn_DiemTBDeTai (@MSDT CHAR(6))
RETURNS FLOAT
AS
BEGIN
    DECLARE @kq FLOAT
    SELECT @kq = AVG(TP.Diem)
    FROM (SELECT AVG(DIEM) AS Diem FROM GV_HDDT WHERE MSDT = @MSDT
          UNION ALL
          SELECT AVG(DIEM) FROM GV_PBDT WHERE MSDT = @MSDT
          UNION ALL
          SELECT AVG(DIEM) FROM GV_UVDT WHERE MSDT = @MSDT) AS TP
    WHERE TP.Diem IS NOT NULL   -- bỏ thành phần đề tài chưa có điểm
    RETURN @kq
END
GO

/* ---------------------------------------------------------------------
   2.4. Số lượng đề tài làm phản biện và số lượng đề tài làm ủy viên của từng GV.
   Hiện thực: Inline Table-valued Function.
   --------------------------------------------------------------------- */
CREATE FUNCTION fn_SoDeTaiPBvaUV ()
RETURNS TABLE
AS
RETURN
(
    SELECT GV.MSGV, GV.TENGV,
           (SELECT COUNT(*) FROM GV_PBDT PB WHERE PB.MSGV = GV.MSGV) AS SoDeTaiPhanBien,
           (SELECT COUNT(*) FROM GV_UVDT UV WHERE UV.MSGV = GV.MSGV) AS SoDeTaiUyVien
    FROM GIAOVIEN GV
)
GO

PRINT N'=== 2.4 ==='
SELECT * FROM dbo.fn_SoDeTaiPBvaUV() ORDER BY MSGV
GO

/* ---------------------------------------------------------------------
   2.5. In ra danh sách tên các sinh viên có điểm trung bình đề tài cao nhất.
   Hiện thực: Stored Procedure dùng hàm fn_DiemTBDeTai.
   --------------------------------------------------------------------- */
CREATE PROCEDURE sp_SVDiemTBDeTaiCaoNhat
AS
BEGIN
    SET NOCOUNT ON
    -- so sánh sau khi làm tròn 2 chữ số để tránh sai số của kiểu FLOAT
    DECLARE @Max FLOAT = (SELECT MAX(ROUND(dbo.fn_DiemTBDeTai(MSDT), 2)) FROM DETAI)

    SELECT SV.MSSV, SV.TENSV, DT.MSDT, DT.TENDT,
           CAST(dbo.fn_DiemTBDeTai(DT.MSDT) AS DECIMAL(4,2)) AS DiemTB
    FROM SINHVIEN SV
    JOIN SV_DETAI SD ON SV.MSSV = SD.MSSV
    JOIN DETAI DT    ON SD.MSDT = DT.MSDT
    WHERE ROUND(dbo.fn_DiemTBDeTai(DT.MSDT), 2) = @Max
END
GO

PRINT N'=== 2.5 - diem TB cua tung de tai ==='
SELECT MSDT, TENDT, CAST(dbo.fn_DiemTBDeTai(MSDT) AS DECIMAL(4,2)) AS DiemTB
FROM DETAI ORDER BY DiemTB DESC

PRINT N'=== 2.5 - ket qua ==='
EXEC sp_SVDiemTBDeTaiCaoNhat
GO

/* =====================================================================
   CÂU 3. AN NINH THÔNG TIN
   ===================================================================== */

/* 3.1. Tạo 3 login (cấp server) và 3 user (cấp CSDL QLDT) */
USE master
GO
IF SUSER_ID('GIANGVIEN') IS NOT NULL DROP LOGIN GIANGVIEN
IF SUSER_ID('GIAOVU')    IS NOT NULL DROP LOGIN GIAOVU
IF SUSER_ID('SINHVIEN')  IS NOT NULL DROP LOGIN SINHVIEN
GO
CREATE LOGIN GIANGVIEN WITH PASSWORD = 'Qldt#Gv2026', DEFAULT_DATABASE = QLDT
CREATE LOGIN GIAOVU    WITH PASSWORD = 'Qldt#Gvu2026',   DEFAULT_DATABASE = QLDT
CREATE LOGIN SINHVIEN  WITH PASSWORD = 'Qldt#Sv2026',    DEFAULT_DATABASE = QLDT
GO
USE QLDT
GO
CREATE USER GIANGVIEN FOR LOGIN GIANGVIEN
CREATE USER GIAOVU    FOR LOGIN GIAOVU
CREATE USER SINHVIEN  FOR LOGIN SINHVIEN
GO

/* 3.2. Phân quyền */

-- GIAOVU: xem và cập nhật trên tất cả các bảng (cấp trên toàn schema dbo)
GRANT SELECT, UPDATE ON SCHEMA::dbo TO GIAOVU

-- GIANGVIEN: xem các bảng liên quan đến GV, đề tài HD/PB/UV, hội đồng, danh sách đề tài
GRANT SELECT ON GIAOVIEN    TO GIANGVIEN
GRANT SELECT ON HOCHAM      TO GIANGVIEN
GRANT SELECT ON HOCVI       TO GIANGVIEN
GRANT SELECT ON CHUYENNGANH TO GIANGVIEN
GRANT SELECT ON GV_HV_CN    TO GIANGVIEN
GRANT SELECT ON GV_HDDT     TO GIANGVIEN
GRANT SELECT ON GV_PBDT     TO GIANGVIEN
GRANT SELECT ON GV_UVDT     TO GIANGVIEN
GRANT SELECT ON HOIDONG     TO GIANGVIEN
GRANT SELECT ON HOIDONG_GV  TO GIANGVIEN
GRANT SELECT ON HOIDONG_DT  TO GIANGVIEN
GRANT SELECT ON DETAI       TO GIANGVIEN
-- GIANGVIEN: cập nhật thông tin cá nhân (chỉ các cột thông tin liên lạc, không đổi mã/học hàm)
GRANT UPDATE (TENGV, DIACHI, SODT) ON GIAOVIEN TO GIANGVIEN

-- SINHVIEN: xem thông tin sinh viên, hội đồng và danh sách đề tài
GRANT SELECT ON SINHVIEN   TO SINHVIEN
GRANT SELECT ON SV_DETAI   TO SINHVIEN
GRANT SELECT ON HOIDONG    TO SINHVIEN
GRANT SELECT ON HOIDONG_GV TO SINHVIEN
GRANT SELECT ON HOIDONG_DT TO SINHVIEN
GRANT SELECT ON DETAI      TO SINHVIEN

-- Tất cả người dùng trên đều không có quyền xóa
DENY DELETE ON SCHEMA::dbo TO GIAOVU, GIANGVIEN, SINHVIEN
GO

PRINT N'=== 3 - kiem tra quyen ==='
-- Kiểm tra bằng EXECUTE AS USER (giả lập đăng nhập bằng từng user)
EXECUTE AS USER = 'GIAOVU'
    BEGIN TRY UPDATE HOIDONG SET TINHTRANG = N'Thật' WHERE MSHD = 1;  PRINT N'GIAOVU    UPDATE HOIDONG        : OK' END TRY
    BEGIN CATCH PRINT N'GIAOVU    UPDATE HOIDONG        : ' + ERROR_MESSAGE() END CATCH
    BEGIN TRY DELETE FROM HOIDONG_DT WHERE MSHD = 99;                  PRINT N'GIAOVU    DELETE HOIDONG_DT     : OK' END TRY
    BEGIN CATCH PRINT N'GIAOVU    DELETE HOIDONG_DT     : ' + ERROR_MESSAGE() END CATCH
REVERT

EXECUTE AS USER = 'GIANGVIEN'
    BEGIN TRY DECLARE @n INT = (SELECT COUNT(*) FROM GV_PBDT);         PRINT N'GIANGVIEN SELECT GV_PBDT        : OK' END TRY
    BEGIN CATCH PRINT N'GIANGVIEN SELECT GV_PBDT        : ' + ERROR_MESSAGE() END CATCH
    BEGIN TRY UPDATE GIAOVIEN SET SODT = '35353535' WHERE MSGV = 201;  PRINT N'GIANGVIEN UPDATE GIAOVIEN.SODT  : OK' END TRY
    BEGIN CATCH PRINT N'GIANGVIEN UPDATE GIAOVIEN.SODT  : ' + ERROR_MESSAGE() END CATCH
    BEGIN TRY UPDATE GIAOVIEN SET MSHH = 2 WHERE MSGV = 201;           PRINT N'GIANGVIEN UPDATE GIAOVIEN.MSHH  : OK' END TRY
    BEGIN CATCH PRINT N'GIANGVIEN UPDATE GIAOVIEN.MSHH  : ' + ERROR_MESSAGE() END CATCH
    BEGIN TRY DECLARE @m INT = (SELECT COUNT(*) FROM SINHVIEN);        PRINT N'GIANGVIEN SELECT SINHVIEN       : OK' END TRY
    BEGIN CATCH PRINT N'GIANGVIEN SELECT SINHVIEN       : ' + ERROR_MESSAGE() END CATCH
REVERT

EXECUTE AS USER = 'SINHVIEN'
    BEGIN TRY DECLARE @k INT = (SELECT COUNT(*) FROM DETAI);           PRINT N'SINHVIEN  SELECT DETAI          : OK' END TRY
    BEGIN CATCH PRINT N'SINHVIEN  SELECT DETAI          : ' + ERROR_MESSAGE() END CATCH
    BEGIN TRY DECLARE @h INT = (SELECT COUNT(*) FROM GV_HDDT);         PRINT N'SINHVIEN  SELECT GV_HDDT        : OK' END TRY
    BEGIN CATCH PRINT N'SINHVIEN  SELECT GV_HDDT        : ' + ERROR_MESSAGE() END CATCH
    BEGIN TRY UPDATE SINHVIEN SET SODT = SODT WHERE MSSV = '13520001'; PRINT N'SINHVIEN  UPDATE SINHVIEN       : OK' END TRY
    BEGIN CATCH PRINT N'SINHVIEN  UPDATE SINHVIEN       : ' + ERROR_MESSAGE() END CATCH
REVERT
GO

PRINT N'=== 3 - danh sach quyen ==='
SELECT pr.name AS NguoiDung, pe.state_desc AS TrangThai, pe.permission_name AS Quyen,
       COALESCE(OBJECT_NAME(pe.major_id), SCHEMA_NAME(pe.major_id)) AS DoiTuong,
       COL_NAME(pe.major_id, pe.minor_id) AS Cot
FROM sys.database_permissions pe
JOIN sys.database_principals pr ON pe.grantee_principal_id = pr.principal_id
WHERE pr.name IN ('GIAOVU', 'GIANGVIEN', 'SINHVIEN') AND pe.permission_name <> 'CONNECT'
ORDER BY pr.name, pe.state_desc, pe.permission_name, DoiTuong
GO

/* =====================================================================
   CÂU 4. TRÌNH BÀY THÔNG TIN - nguồn dữ liệu cho Crystal Report / Tableau
   ===================================================================== */

/* 4.1. Thông tin GV phản biện */
CREATE VIEW vw_BaoCao_GVPhanBien
AS
SELECT ROW_NUMBER() OVER (ORDER BY GV.MSGV) AS STT,
       GV.TENGV AS HOTEN,
       CASE HV.TENHV
            WHEN N'Kỹ sư'            THEN N'KS'
            WHEN N'Cử nhân'          THEN N'CN'
            WHEN N'Thạc sĩ'          THEN N'ThS'
            WHEN N'Tiến sĩ'          THEN N'TS'
            WHEN N'Tiến sĩ Khoa học' THEN N'TSKH'
       END AS HOCVI,
       CASE HH.TENHH WHEN N'PHÓ GIÁO SƯ' THEN N'PGS' WHEN N'GIÁO SƯ' THEN N'GS' END AS HOCHAM,
       GV.SODT AS SODIENTHOAI,
       GV.DIACHI
FROM GIAOVIEN GV
LEFT JOIN HOCHAM HH ON GV.MSHH = HH.MSHH
-- học vị cao nhất của GV (MSHV lớn hơn = học vị cao hơn)
OUTER APPLY (SELECT TOP 1 H.TENHV FROM GV_HV_CN G JOIN HOCVI H ON G.MSHV = H.MSHV
             WHERE G.MSGV = GV.MSGV ORDER BY G.MSHV DESC) HV
WHERE EXISTS (SELECT 1 FROM GV_PBDT PB WHERE PB.MSGV = GV.MSGV)
GO

/* 4.2. Thông tin hội đồng đánh giá đề tài */
CREATE VIEW vw_BaoCao_HoiDongDanhGia
AS
SELECT ROW_NUMBER() OVER (ORDER BY HD.MSHD, DT.MSDT) AS STT,
       'HD' + RIGHT('0' + CAST(HD.MSHD AS VARCHAR(5)), 2) AS MASOHOIDONG,
       DT.TENDT AS TENDETAI,
       RIGHT('000' + CAST(HD.PHONG AS VARCHAR(5)), 3) AS PHONG,
       CONVERT(VARCHAR(10), HD.NGAYHD, 103) AS NGAYHOIDONG,
       GV.TENGV AS CHUTICHHOIDONG,
       CAST(dbo.fn_DiemTBDeTai(DT.MSDT) AS DECIMAL(4,2)) AS DIEMTB
FROM HOIDONG HD
JOIN HOIDONG_DT HDT ON HD.MSHD = HDT.MSHD
JOIN DETAI DT       ON HDT.MSDT = DT.MSDT
LEFT JOIN GIAOVIEN GV ON HD.MSGV = GV.MSGV
GO

PRINT N'=== 4.1 ==='
SELECT * FROM vw_BaoCao_GVPhanBien ORDER BY STT
PRINT N'=== 4.2 ==='
SELECT * FROM vw_BaoCao_HoiDongDanhGia ORDER BY STT
GO

/* =====================================================================
   CÂU 5. CÁC MÔ HÌNH CSDL TIÊN TIẾN
   Chọn mô hình NoSQL hướng tài liệu (MongoDB). Ví dụ chuyển đổi 2 bảng
   DETAI và GIAOVIEN thành document JSON (sinh trực tiếp từ dữ liệu QLDT).
   ===================================================================== */
PRINT N'=== 5 - collection detai ==='
SELECT RTRIM(DT.MSDT) AS _id,
       DT.TENDT AS tenDeTai,
       (SELECT SV.MSSV AS mssv, SV.TENSV AS ten
        FROM SV_DETAI SD JOIN SINHVIEN SV ON SD.MSSV = SV.MSSV
        WHERE SD.MSDT = DT.MSDT FOR JSON PATH) AS sinhVien,
       (SELECT MSGV AS msgv, CAST(DIEM AS DECIMAL(4,1)) AS diem FROM GV_HDDT WHERE MSDT = DT.MSDT FOR JSON PATH) AS huongDan,
       (SELECT MSGV AS msgv, CAST(DIEM AS DECIMAL(4,1)) AS diem FROM GV_PBDT WHERE MSDT = DT.MSDT FOR JSON PATH) AS phanBien,
       (SELECT MSGV AS msgv, CAST(DIEM AS DECIMAL(4,1)) AS diem FROM GV_UVDT WHERE MSDT = DT.MSDT FOR JSON PATH) AS uyVien,
       (SELECT MSHD AS mshd, RTRIM(QUYETDINH) AS quyetDinh
        FROM HOIDONG_DT WHERE MSDT = DT.MSDT FOR JSON PATH) AS hoiDong
FROM DETAI DT
WHERE DT.MSDT = '97005'
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

PRINT N'=== 5 - collection giaovien ==='
SELECT GV.MSGV AS _id,
       GV.TENGV AS ten,
       GV.DIACHI AS diaChi,
       GV.SODT AS soDT,
       HH.TENHH AS [hocHam.ten],
       YEAR(GV.NAMHH) AS [hocHam.nam],
       (SELECT H.TENHV AS hocVi, C.TENCN AS chuyenNganh, YEAR(G.NAM) AS nam
        FROM GV_HV_CN G JOIN HOCVI H ON G.MSHV = H.MSHV JOIN CHUYENNGANH C ON G.MSCN = C.MSCN
        WHERE G.MSGV = GV.MSGV ORDER BY G.NAM FOR JSON PATH) AS hocViChuyenNganh
FROM GIAOVIEN GV
LEFT JOIN HOCHAM HH ON GV.MSHH = HH.MSHH
WHERE GV.MSGV = 201
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
GO
