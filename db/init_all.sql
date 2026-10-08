

/* ==================== CONTENT OF 1_TaoBang.sql ==================== */

/* =====================================================================
   DO AN MON HOC IE103 - QUAN LY THONG TIN
   De tai : QUAN LY THU VIEN
   File   : 01_TaoBang.sql
   Noi dung: Tao CSDL, tao bang, khoa chinh, khoa ngoai, rang buoc
   ===================================================================== */

GO

IF DB_ID('QUANLYTHUVIEN') IS NOT NULL
BEGIN
	ALTER DATABASE QUANLYTHUVIEN SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE QUANLYTHUVIEN
END
GO

CREATE DATABASE QUANLYTHUVIEN COLLATE Vietnamese_CI_AS
GO

USE QUANLYTHUVIEN
GO

/* ---------------------------------------------------------------------
   1. THELOAI(MATL, TENTL)
   --------------------------------------------------------------------- */
CREATE TABLE THELOAI
(
	MATL	CHAR(4)			PRIMARY KEY,
	TENTL	NVARCHAR(50)	NOT NULL UNIQUE
)

/* ---------------------------------------------------------------------
   2. TACGIA(MATG, TENTG, NAMSINH, QUOCTICH)
   --------------------------------------------------------------------- */
CREATE TABLE TACGIA
(
	MATG		CHAR(5)			PRIMARY KEY,
	TENTG		NVARCHAR(50)	NOT NULL,
	NAMSINH		INT				NULL,
	QUOCTICH	NVARCHAR(30)	NULL,
	CONSTRAINT CK_TACGIA_NAMSINH CHECK (NAMSINH IS NULL OR NAMSINH BETWEEN 1000 AND YEAR(GETDATE()))
)

/* ---------------------------------------------------------------------
   3. NHAXUATBAN(MANXB, TENNXB, DIACHI, SODT)
   --------------------------------------------------------------------- */
CREATE TABLE NHAXUATBAN
(
	MANXB	CHAR(5)			PRIMARY KEY,
	TENNXB	NVARCHAR(60)	NOT NULL UNIQUE,
	DIACHI	NVARCHAR(100)	NULL,
	SODT	VARCHAR(15)		NULL
)

/* ---------------------------------------------------------------------
   4. DAUSACH(MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA, SOLUONG, SLCON)
      SOLUONG, SLCON la thuoc tinh dan xuat, duoc trigger cap nhat tu CUONSACH
   --------------------------------------------------------------------- */
CREATE TABLE DAUSACH
(
	MADS	CHAR(5)			PRIMARY KEY,
	TENDS	NVARCHAR(100)	NOT NULL,
	MATL	CHAR(4)			NOT NULL FOREIGN KEY REFERENCES THELOAI (MATL),
	MANXB	CHAR(5)			NOT NULL FOREIGN KEY REFERENCES NHAXUATBAN (MANXB),
	NAMXB	INT				NOT NULL,
	SOTRANG	INT				NOT NULL,
	GIA		MONEY			NOT NULL,
	SOLUONG	INT				NOT NULL DEFAULT 0,
	SLCON	INT				NOT NULL DEFAULT 0,
	CONSTRAINT CK_DAUSACH_NAMXB		CHECK (NAMXB BETWEEN 1900 AND YEAR(GETDATE())),
	CONSTRAINT CK_DAUSACH_SOTRANG	CHECK (SOTRANG > 0),
	CONSTRAINT CK_DAUSACH_GIA		CHECK (GIA > 0),
	CONSTRAINT CK_DAUSACH_SL		CHECK (SOLUONG >= 0 AND SLCON BETWEEN 0 AND SOLUONG)
)

/* ---------------------------------------------------------------------
   5. DAUSACH_TACGIA(MADS, MATG, VAITRO)
   --------------------------------------------------------------------- */
CREATE TABLE DAUSACH_TACGIA
(
	MADS	CHAR(5)			FOREIGN KEY REFERENCES DAUSACH (MADS),
	MATG	CHAR(5)			FOREIGN KEY REFERENCES TACGIA (MATG),
	VAITRO	NVARCHAR(20)	NOT NULL DEFAULT N'Tác giả',
	PRIMARY KEY (MADS, MATG),
	CONSTRAINT CK_DSTG_VAITRO CHECK (VAITRO IN (N'Tác giả', N'Đồng tác giả', N'Dịch giả'))
)

/* ---------------------------------------------------------------------
   6. CUONSACH(MACS, MADS, NGAYNHAP, VITRI, TINHTRANG)
   --------------------------------------------------------------------- */
CREATE TABLE CUONSACH
(
	MACS		CHAR(5)			PRIMARY KEY,
	MADS		CHAR(5)			NOT NULL FOREIGN KEY REFERENCES DAUSACH (MADS),
	NGAYNHAP	DATE			NOT NULL DEFAULT GETDATE(),
	VITRI		NVARCHAR(20)	NULL,
	TINHTRANG	NVARCHAR(20)	NOT NULL DEFAULT N'Có sẵn',
	CONSTRAINT CK_CUONSACH_TINHTRANG CHECK (TINHTRANG IN (N'Có sẵn', N'Đang mượn', N'Hư hỏng', N'Mất'))
)

/* ---------------------------------------------------------------------
   8. DOCGIA(MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL
             NGAYLAPTHE, NGAYHETHAN, TONGNO)
      TONGNO la thuoc tinh dan xuat (tong tien phat chua thanh toan)
   --------------------------------------------------------------------- */
CREATE TABLE DOCGIA
(
	MADG		CHAR(5)			PRIMARY KEY,
	HOTEN		NVARCHAR(40)	NOT NULL,
	NGSINH		DATE			NOT NULL,
	GIOITINH	NVARCHAR(3)		NOT NULL,
	DIACHI		NVARCHAR(100)	NULL,
	SODT		VARCHAR(15)		NOT NULL,
	EMAIL		VARCHAR(50)		NULL,
	
	NGAYLAPTHE	DATE			NOT NULL DEFAULT GETDATE(),
	NGAYHETHAN	DATE			NOT NULL,
	TONGNO		MONEY			NOT NULL DEFAULT 0,
	CONSTRAINT CK_DOCGIA_GIOITINH	CHECK (GIOITINH IN (N'Nam', N'Nữ')),
	CONSTRAINT CK_DOCGIA_NGAYTHE	CHECK (NGAYHETHAN > NGAYLAPTHE),
	CONSTRAINT CK_DOCGIA_TUOI		CHECK (DATEADD(YEAR, 16, NGSINH) <= NGAYLAPTHE),
	CONSTRAINT CK_DOCGIA_TONGNO		CHECK (TONGNO >= 0),
	CONSTRAINT CK_DOCGIA_EMAIL		CHECK (EMAIL IS NULL OR EMAIL LIKE '%_@_%._%')
)

/* ---------------------------------------------------------------------
   9. NHANVIEN(MANV, HOTEN, NGSINH, SODT, CHUCVU, NGVL)
   --------------------------------------------------------------------- */
CREATE TABLE NHANVIEN
(
	MANV	CHAR(4)			PRIMARY KEY,
	HOTEN	NVARCHAR(40)	NOT NULL,
	NGSINH	DATE			NOT NULL,
	SODT	VARCHAR(15)		NOT NULL,
	CHUCVU	NVARCHAR(20)	NOT NULL,
	NGVL	DATE			NOT NULL,
	CONSTRAINT CK_NHANVIEN_CHUCVU	CHECK (CHUCVU IN (N'Quản lý', N'Thủ thư', N'Kỹ thuật viên')),
	CONSTRAINT CK_NHANVIEN_NGVL		CHECK (DATEADD(YEAR, 18, NGSINH) <= NGVL)
)

/* ---------------------------------------------------------------------
   10. PHIEUMUON(MAPM, MADG, MANV, NGAYMUON, HANTRA, TINHTRANG)
   --------------------------------------------------------------------- */
CREATE TABLE PHIEUMUON
(
	MAPM		CHAR(6)			PRIMARY KEY,
	MADG		CHAR(5)			NOT NULL FOREIGN KEY REFERENCES DOCGIA (MADG),
	MANV		CHAR(4)			NOT NULL FOREIGN KEY REFERENCES NHANVIEN (MANV),
	NGAYMUON	DATE			NOT NULL DEFAULT GETDATE(),
	HANTRA		DATE			NOT NULL,
	TINHTRANG	NVARCHAR(20)	NOT NULL DEFAULT N'Đang mượn',
	CONSTRAINT CK_PHIEUMUON_HANTRA		CHECK (HANTRA > NGAYMUON),
	CONSTRAINT CK_PHIEUMUON_TINHTRANG	CHECK (TINHTRANG IN (N'Đang mượn', N'Đã trả'))
)

/* ---------------------------------------------------------------------
   11. CTPHIEUMUON(MAPM, MACS, NGAYTRA, TINHTRANGTRA)
   --------------------------------------------------------------------- */
CREATE TABLE CTPHIEUMUON
(
	MAPM			CHAR(6)			FOREIGN KEY REFERENCES PHIEUMUON (MAPM),
	MACS			CHAR(5)			FOREIGN KEY REFERENCES CUONSACH (MACS),
	NGAYTRA			DATE			NULL,
	TINHTRANGTRA	NVARCHAR(20)	NULL,
	PRIMARY KEY (MAPM, MACS),
	CONSTRAINT CK_CTPM_TINHTRANGTRA CHECK (TINHTRANGTRA IN (N'Bình thường', N'Hư hỏng', N'Mất')),
	-- Da tra thi phai co tinh trang tra, chua tra thi khong co
	CONSTRAINT CK_CTPM_TRASACH CHECK ((NGAYTRA IS NULL AND TINHTRANGTRA IS NULL)
								   OR (NGAYTRA IS NOT NULL AND TINHTRANGTRA IS NOT NULL))
)

/* ---------------------------------------------------------------------
   12. PHIEUPHAT(MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN)
   --------------------------------------------------------------------- */
CREATE TABLE PHIEUPHAT
(
	MAPP		CHAR(6)			PRIMARY KEY,
	MAPM		CHAR(6)			NOT NULL,
	MACS		CHAR(5)			NOT NULL,
	NGAYLAP		DATE			NOT NULL DEFAULT GETDATE(),
	LYDO		NVARCHAR(20)	NOT NULL,
	SOTIEN		MONEY			NOT NULL,
	DATHANHTOAN	BIT				NOT NULL DEFAULT 0,
	FOREIGN KEY (MAPM, MACS) REFERENCES CTPHIEUMUON (MAPM, MACS),
	CONSTRAINT CK_PHIEUPHAT_LYDO	CHECK (LYDO IN (N'Trả trễ', N'Hư hỏng', N'Mất sách')),
	CONSTRAINT CK_PHIEUPHAT_SOTIEN	CHECK (SOTIEN > 0)
)

/* ---------------------------------------------------------------------
   13. TAIKHOAN(TENDANGNHAP, MATKHAU, VAITRO, MANV, MADG, TRANGTHAI)
       Dung cho chuc nang xac thuc cua ung dung. Mat khau duoc bam SHA2_256
       khong luu mat khau goc.
   --------------------------------------------------------------------- */
CREATE TABLE TAIKHOAN
(
	TENDANGNHAP	VARCHAR(30)			PRIMARY KEY,
	MATKHAU		VARBINARY(32)		NOT NULL,
	VAITRO		NVARCHAR(20)		NOT NULL,
	MANV		CHAR(4)				NULL FOREIGN KEY REFERENCES NHANVIEN (MANV),
	MADG		CHAR(5)				NULL FOREIGN KEY REFERENCES DOCGIA (MADG),
	TRANGTHAI	BIT					NOT NULL DEFAULT 1,
	CONSTRAINT CK_TAIKHOAN_VAITRO CHECK (VAITRO IN (N'Quản lý', N'Thủ thư', N'Độc giả')),
	CONSTRAINT CK_TAIKHOAN_CHUSOHUU CHECK (
		(VAITRO = N'Độc giả' AND MADG IS NOT NULL AND MANV IS NULL)
	 OR (VAITRO <> N'Độc giả' AND MANV IS NOT NULL AND MADG IS NULL))
)
GO

GO


/* ==================== CONTENT OF 2_DuLieuMau.sql ==================== */

/* =====================================================================
   File   : 02_DuLieuMau.sql
   Noi dung: Nhap du lieu mau (chay SAU 01_TaoBang.sql va TRUOC cac file
             tao Trigger, vi du lieu lich su da o trang thai cuoi cung)
   Moc thoi gian cua du lieu: ngay 26/09/2026
   ===================================================================== */

USE QUANLYTHUVIEN
GO

/*NHAP DU LIEU THELOAI*/
INSERT INTO THELOAI VALUES ('TL01', N'Công nghệ thông tin')
INSERT INTO THELOAI VALUES ('TL02', N'Toán học')
INSERT INTO THELOAI VALUES ('TL03', N'Kinh tế')
INSERT INTO THELOAI VALUES ('TL04', N'Văn học Việt Nam')
INSERT INTO THELOAI VALUES ('TL05', N'Văn học nước ngoài')
INSERT INTO THELOAI VALUES ('TL06', N'Kỹ năng sống')
INSERT INTO THELOAI VALUES ('TL07', N'Lịch sử - Văn hóa')
INSERT INTO THELOAI VALUES ('TL08', N'Ngoại ngữ')
INSERT INTO THELOAI VALUES ('TL09', N'Khoa học tự nhiên')
INSERT INTO THELOAI VALUES ('TL10', N'Thiếu nhi')

/*NHAP DU LIEU NHAXUATBAN*/
INSERT INTO NHAXUATBAN VALUES ('NXB01', N'NXB Trẻ', N'161B Lý Chính Thắng, Q3, TpHCM', '02839316289')
INSERT INTO NHAXUATBAN VALUES ('NXB02', N'NXB Kim Đồng', N'55 Quang Trung, Hai Bà Trưng, Hà Nội', '02439434730')
INSERT INTO NHAXUATBAN VALUES ('NXB03', N'NXB Giáo dục Việt Nam', N'81 Trần Hưng Đạo, Hoàn Kiếm, Hà Nội', '02438220801')
INSERT INTO NHAXUATBAN VALUES ('NXB04', N'NXB Đại học Quốc gia TpHCM', N'Khu phố 6, Linh Trung, Thủ Đức, TpHCM', '02837242181')
INSERT INTO NHAXUATBAN VALUES ('NXB05', N'NXB Tổng hợp TpHCM', N'62 Nguyễn Thị Minh Khai, Q1, TpHCM', '02838225340')
INSERT INTO NHAXUATBAN VALUES ('NXB06', N'NXB Hội Nhà văn', N'65 Nguyễn Du, Hai Bà Trưng, Hà Nội', '02438222135')
INSERT INTO NHAXUATBAN VALUES ('NXB07', N'NXB Lao động', N'175 Giảng Võ, Đống Đa, Hà Nội', '02438515380')
INSERT INTO NHAXUATBAN VALUES ('NXB08', N'NXB Thế giới', N'46 Trần Hưng Đạo, Hoàn Kiếm, Hà Nội', '02438253841')
INSERT INTO NHAXUATBAN VALUES ('NXB09', N'NXB Khoa học và Kỹ thuật', N'70 Trần Hưng Đạo, Hoàn Kiếm, Hà Nội', '02439423172')
INSERT INTO NHAXUATBAN VALUES ('NXB10', N'NXB Chính trị Quốc gia Sự thật', NULL, NULL)

/*NHAP DU LIEU TACGIA*/
INSERT INTO TACGIA VALUES ('TG001', N'Nguyễn Nhật Ánh', 1955, N'Việt Nam')
INSERT INTO TACGIA VALUES ('TG002', N'Tô Hoài', 1920, N'Việt Nam')
INSERT INTO TACGIA VALUES ('TG003', N'Nam Cao', 1915, N'Việt Nam')
INSERT INTO TACGIA VALUES ('TG004', N'Vũ Trọng Phụng', 1912, N'Việt Nam')
INSERT INTO TACGIA VALUES ('TG005', N'Paulo Coelho', 1947, N'Brazil')
INSERT INTO TACGIA VALUES ('TG006', N'Dale Carnegie', 1888, N'Mỹ')
INSERT INTO TACGIA VALUES ('TG007', N'Yuval Noah Harari', 1976, N'Israel')
INSERT INTO TACGIA VALUES ('TG008', N'Robert C. Martin', 1952, N'Mỹ')
INSERT INTO TACGIA VALUES ('TG009', N'Abraham Silberschatz', 1952, N'Mỹ')
INSERT INTO TACGIA VALUES ('TG010', N'Henry F. Korth', NULL, N'Mỹ')
INSERT INTO TACGIA VALUES ('TG011', N'Thomas H. Cormen', 1956, N'Mỹ')
INSERT INTO TACGIA VALUES ('TG012', N'Charles E. Leiserson', 1953, N'Mỹ')
INSERT INTO TACGIA VALUES ('TG013', N'Haruki Murakami', 1949, N'Nhật Bản')
INSERT INTO TACGIA VALUES ('TG014', N'J.K. Rowling', 1965, N'Anh')
INSERT INTO TACGIA VALUES ('TG015', N'N. Gregory Mankiw', 1958, N'Mỹ')
INSERT INTO TACGIA VALUES ('TG016', N'Trần Quốc Vượng', 1934, N'Việt Nam')

/*NHAP DU LIEU DAUSACH (SOLUONG, SLCON duoc tinh lai o cuoi file)*/
INSERT INTO DAUSACH (MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA) VALUES ('DS001', N'Mắt biếc', 'TL04', 'NXB01', 2019, 300, 110000)
INSERT INTO DAUSACH (MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA) VALUES ('DS002', N'Cho tôi xin một vé đi tuổi thơ', 'TL04', 'NXB01', 2018, 220, 80000)
INSERT INTO DAUSACH (MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA) VALUES ('DS003', N'Dế Mèn phiêu lưu ký', 'TL10', 'NXB02', 2020, 150, 50000)
INSERT INTO DAUSACH (MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA) VALUES ('DS004', N'Chí Phèo', 'TL04', 'NXB06', 2017, 180, 60000)
INSERT INTO DAUSACH (MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA) VALUES ('DS005', N'Số đỏ', 'TL04', 'NXB06', 2016, 250, 75000)
INSERT INTO DAUSACH (MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA) VALUES ('DS006', N'Nhà giả kim', 'TL05', 'NXB06', 2020, 230, 79000)
INSERT INTO DAUSACH (MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA) VALUES ('DS007', N'Đắc nhân tâm', 'TL06', 'NXB05', 2021, 320, 86000)
INSERT INTO DAUSACH (MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA) VALUES ('DS008', N'Sapiens: Lược sử loài người', 'TL07', 'NXB08', 2019, 560, 250000)
INSERT INTO DAUSACH (MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA) VALUES ('DS009', N'Clean Code', 'TL01', 'NXB09', 2022, 460, 199000)
INSERT INTO DAUSACH (MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA) VALUES ('DS010', N'Database System Concepts', 'TL01', 'NXB09', 2019, 1370, 450000)
INSERT INTO DAUSACH (MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA) VALUES ('DS011', N'Introduction to Algorithms', 'TL01', 'NXB09', 2022, 1310, 520000)
INSERT INTO DAUSACH (MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA) VALUES ('DS012', N'Rừng Na Uy', 'TL05', 'NXB06', 2018, 550, 150000)
INSERT INTO DAUSACH (MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA) VALUES ('DS013', N'Harry Potter và Hòn đá Phù thủy', 'TL10', 'NXB01', 2017, 370, 150000)
INSERT INTO DAUSACH (MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA) VALUES ('DS014', N'Nguyên lý kinh tế học', 'TL03', 'NXB05', 2020, 700, 320000)
INSERT INTO DAUSACH (MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA) VALUES ('DS015', N'Cơ sở văn hóa Việt Nam', 'TL07', 'NXB03', 2018, 320, 70000)
INSERT INTO DAUSACH (MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA) VALUES ('DS016', N'Giáo trình Giải tích 1', 'TL02', 'NXB04', 2021, 280, 65000)

/*NHAP DU LIEU DAUSACH_TACGIA (DS016 la giao trinh noi bo, khong ghi tac gia)*/
INSERT INTO DAUSACH_TACGIA VALUES ('DS001', 'TG001', N'Tác giả')
INSERT INTO DAUSACH_TACGIA VALUES ('DS002', 'TG001', N'Tác giả')
INSERT INTO DAUSACH_TACGIA VALUES ('DS003', 'TG002', N'Tác giả')
INSERT INTO DAUSACH_TACGIA VALUES ('DS004', 'TG003', N'Tác giả')
INSERT INTO DAUSACH_TACGIA VALUES ('DS005', 'TG004', N'Tác giả')
INSERT INTO DAUSACH_TACGIA VALUES ('DS006', 'TG005', N'Tác giả')
INSERT INTO DAUSACH_TACGIA VALUES ('DS007', 'TG006', N'Tác giả')
INSERT INTO DAUSACH_TACGIA VALUES ('DS008', 'TG007', N'Tác giả')
INSERT INTO DAUSACH_TACGIA VALUES ('DS009', 'TG008', N'Tác giả')
INSERT INTO DAUSACH_TACGIA VALUES ('DS010', 'TG009', N'Tác giả')
INSERT INTO DAUSACH_TACGIA VALUES ('DS010', 'TG010', N'Đồng tác giả')
INSERT INTO DAUSACH_TACGIA VALUES ('DS011', 'TG011', N'Tác giả')
INSERT INTO DAUSACH_TACGIA VALUES ('DS011', 'TG012', N'Đồng tác giả')
INSERT INTO DAUSACH_TACGIA VALUES ('DS012', 'TG013', N'Tác giả')
INSERT INTO DAUSACH_TACGIA VALUES ('DS013', 'TG014', N'Tác giả')
INSERT INTO DAUSACH_TACGIA VALUES ('DS014', 'TG015', N'Tác giả')
INSERT INTO DAUSACH_TACGIA VALUES ('DS015', 'TG016', N'Tác giả')

/*NHAP DU LIEU CUONSACH (tinh trang cuoi cung sau cac luot muon ben duoi)*/
INSERT INTO CUONSACH VALUES ('CS001', 'DS001', '2025-08-15', N'Kệ A1', N'Có sẵn')
INSERT INTO CUONSACH VALUES ('CS002', 'DS001', '2025-08-15', N'Kệ A1', N'Có sẵn')
INSERT INTO CUONSACH VALUES ('CS003', 'DS001', '2026-01-10', N'Kệ A1', N'Đang mượn')
INSERT INTO CUONSACH VALUES ('CS004', 'DS002', '2025-08-15', N'Kệ A1', N'Có sẵn')
INSERT INTO CUONSACH VALUES ('CS005', 'DS002', '2025-08-15', N'Kệ A1', N'Có sẵn')
INSERT INTO CUONSACH VALUES ('CS006', 'DS003', '2025-09-01', N'Kệ E1', N'Hư hỏng')
INSERT INTO CUONSACH VALUES ('CS007', 'DS003', '2025-09-01', N'Kệ E1', N'Đang mượn')
INSERT INTO CUONSACH VALUES ('CS008', 'DS004', '2025-09-01', N'Kệ A2', N'Có sẵn')
INSERT INTO CUONSACH VALUES ('CS009', 'DS005', '2025-09-01', N'Kệ A2', N'Có sẵn')
INSERT INTO CUONSACH VALUES ('CS010', 'DS006', '2025-10-05', N'Kệ B1', N'Có sẵn')
INSERT INTO CUONSACH VALUES ('CS011', 'DS006', '2025-10-05', N'Kệ B1', N'Đang mượn')
INSERT INTO CUONSACH VALUES ('CS012', 'DS007', '2025-10-05', N'Kệ C1', N'Hư hỏng')
INSERT INTO CUONSACH VALUES ('CS013', 'DS007', '2025-10-05', N'Kệ C1', N'Có sẵn')
INSERT INTO CUONSACH VALUES ('CS014', 'DS007', '2026-02-20', N'Kệ C1', N'Đang mượn')
INSERT INTO CUONSACH VALUES ('CS015', 'DS008', '2025-11-12', N'Kệ C2', N'Mất')
INSERT INTO CUONSACH VALUES ('CS016', 'DS009', '2025-11-12', N'Kệ D1', N'Đang mượn')
INSERT INTO CUONSACH VALUES ('CS017', 'DS009', '2026-03-03', N'Kệ D1', N'Đang mượn')
INSERT INTO CUONSACH VALUES ('CS018', 'DS010', '2025-11-12', N'Kệ D1', N'Có sẵn')
INSERT INTO CUONSACH VALUES ('CS019', 'DS010', '2025-11-12', N'Kệ D1', N'Có sẵn')
INSERT INTO CUONSACH VALUES ('CS020', 'DS011', '2025-12-01', N'Kệ D2', N'Đang mượn')
INSERT INTO CUONSACH VALUES ('CS021', 'DS012', '2025-12-01', N'Kệ B1', N'Có sẵn')
INSERT INTO CUONSACH VALUES ('CS022', 'DS013', '2025-12-01', N'Kệ E1', N'Có sẵn')
INSERT INTO CUONSACH VALUES ('CS023', 'DS013', '2026-03-03', N'Kệ E1', N'Đang mượn')
INSERT INTO CUONSACH VALUES ('CS024', 'DS014', '2026-01-10', N'Kệ D3', N'Có sẵn')
INSERT INTO CUONSACH VALUES ('CS025', 'DS015', '2026-01-10', N'Kệ C2', N'Đang mượn')
INSERT INTO CUONSACH VALUES ('CS026', 'DS016', '2026-03-03', N'Kệ D3', N'Đang mượn')

/*NHAP DU LIEU LOAIDOCGIA*/

/*NHAP DU LIEU DOCGIA (TONGNO duoc tinh lai o cuoi file)*/
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG001', N'Nguyễn Minh Anh', '2004-03-15', N'Nữ', N'Linh Trung, Thủ Đức, TpHCM', '0901234561', 'minhanh.dg001@gmail.com', '2025-09-01', '2027-09-01')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG002', N'Trần Quốc Bảo', '2003-11-02', N'Nam', N'Dĩ An, Bình Dương', '0901234562', 'quocbao.dg002@gmail.com', '2025-09-01', '2027-09-01')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG003', N'Lê Thị Cẩm Tú', '2005-06-20', N'Nữ', N'Linh Xuân, Thủ Đức, TpHCM', '0901234563', 'camtu.dg003@gmail.com', '2025-09-05', '2027-09-05')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG004', N'Phạm Đức Duy', '2004-01-09', N'Nam', N'Q9, TpHCM', '0901234564', 'ducduy.dg004@gmail.com', '2025-09-05', '2027-09-05')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG005', N'Hoàng Gia Huy', '2000-08-30', N'Nam', N'Q10, TpHCM', '0901234565', 'giahuy.dg005@gmail.com', '2025-10-01', '2027-10-01')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG006', N'Võ Ngọc Hân', '2003-12-12', N'Nữ', N'Q5, TpHCM', '0901234566', 'ngochan.dg006@gmail.com', '2024-09-01', '2026-08-31')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG007', N'Đặng Thanh Long', '1985-04-18', N'Nam', N'Q3, TpHCM', '0901234567', 'thanhlong.dg007@gmail.com', '2025-06-01', '2028-06-01')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG008', N'Bùi Thị Mai', '1990-07-25', N'Nữ', N'Bình Thạnh, TpHCM', '0901234568', 'thimai.dg008@gmail.com', '2025-06-01', '2028-06-01')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG009', N'Ngô Văn Nam', '2004-05-05', N'Nam', N'Thủ Đức, TpHCM', '0901234569', 'vannam.dg009@gmail.com', '2025-09-10', '2027-09-10')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG010', N'Huỳnh Kim Ngân', '2005-02-14', N'Nữ', N'Tân Bình, TpHCM', '0901234570', 'kimngan.dg010@gmail.com', '2025-09-10', '2027-09-10')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG011', N'Trịnh Công Phúc', '1998-10-10', N'Nam', N'Gò Vấp, TpHCM', '0901234571', 'congphuc.dg011@gmail.com', '2025-10-01', '2027-10-01')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG012', N'Đỗ Bảo Quyên', '2006-09-01', N'Nữ', N'Dĩ An, Bình Dương', '0901234572', 'baoquyen.dg012@gmail.com', '2026-09-15', '2028-09-15')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG013', N'Lý Minh Tâm', '1975-03-03', N'Nam', N'Q1, TpHCM', '0901234573', NULL, '2026-09-01', '2027-03-01')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG014', N'Mai Anh Thư', '2004-12-24', N'Nữ', N'Linh Trung, Thủ Đức, TpHCM', '0901234574', 'anhthu.dg014@gmail.com', '2025-09-15', '2027-09-15')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG015', N'Phan Hoàng Vũ', '2003-06-06', N'Nam', NULL, '0901234575', NULL, '2025-09-15', '2027-09-15')

/*NHAP DU LIEU NHANVIEN*/
INSERT INTO NHANVIEN VALUES ('NV01', N'Trần Thị Hồng', '1980-02-10', '0912000001', N'Quản lý', '2015-03-01')
INSERT INTO NHANVIEN VALUES ('NV02', N'Nguyễn Văn Khoa', '1990-05-21', '0912000002', N'Thủ thư', '2018-07-15')
INSERT INTO NHANVIEN VALUES ('NV03', N'Lê Hoàng Yến', '1993-09-09', '0912000003', N'Thủ thư', '2019-09-01')
INSERT INTO NHANVIEN VALUES ('NV04', N'Phạm Minh Trí', '1995-12-30', '0912000004', N'Thủ thư', '2021-02-01')
INSERT INTO NHANVIEN VALUES ('NV05', N'Võ Thị Lan', '1997-04-17', '0912000005', N'Thủ thư', '2022-08-01')
INSERT INTO NHANVIEN VALUES ('NV06', N'Đinh Quang Hải', '1988-11-11', '0912000006', N'Kỹ thuật viên', '2017-05-20')
INSERT INTO NHANVIEN VALUES ('NV07', N'Châu Mỹ Linh', '1999-01-25', '0912000007', N'Thủ thư', '2023-03-01')
INSERT INTO NHANVIEN VALUES ('NV08', N'Tạ Quang Minh', '1985-06-06', '0912000008', N'Quản lý', '2016-01-04')
INSERT INTO NHANVIEN VALUES ('NV09', N'Lâm Thảo Vy', '2000-10-02', '0912000009', N'Thủ thư', '2024-06-10')
INSERT INTO NHANVIEN VALUES ('NV10', N'Kiều Văn Sang', '1992-03-14', '0912000010', N'Kỹ thuật viên', '2020-11-16')

/*NHAP DU LIEU PHIEUMUON*/
INSERT INTO PHIEUMUON VALUES ('PM0001', 'DG001', 'NV02', '2026-06-01', '2026-06-15', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0002', 'DG002', 'NV03', '2026-06-05', '2026-06-19', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0003', 'DG007', 'NV02', '2026-06-10', '2026-07-10', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0004', 'DG003', 'NV04', '2026-06-20', '2026-07-04', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0005', 'DG009', 'NV03', '2026-07-01', '2026-07-15', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0006', 'DG005', 'NV05', '2026-07-10', '2026-07-31', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0007', 'DG008', 'NV02', '2026-07-15', '2026-08-14', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0008', 'DG010', 'NV04', '2026-08-01', '2026-08-15', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0009', 'DG006', 'NV03', '2026-08-05', '2026-08-19', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0010', 'DG011', 'NV05', '2026-08-20', '2026-09-10', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0011', 'DG001', 'NV02', '2026-09-01', '2026-09-15', N'Đang mượn')
INSERT INTO PHIEUMUON VALUES ('PM0012', 'DG004', 'NV03', '2026-09-10', '2026-09-24', N'Đang mượn')
INSERT INTO PHIEUMUON VALUES ('PM0013', 'DG007', 'NV04', '2026-09-15', '2026-10-15', N'Đang mượn')
INSERT INTO PHIEUMUON VALUES ('PM0014', 'DG014', 'NV02', '2026-09-20', '2026-10-04', N'Đang mượn')
INSERT INTO PHIEUMUON VALUES ('PM0015', 'DG013', 'NV05', '2026-09-22', '2026-09-29', N'Đang mượn')
INSERT INTO PHIEUMUON VALUES ('PM0016', 'DG002', 'NV03', '2026-09-24', '2026-10-08', N'Đang mượn')
INSERT INTO PHIEUMUON VALUES ('PM0017', 'DG003', 'NV02', '2026-07-10', '2026-07-24', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0018', 'DG010', 'NV05', '2026-07-01', '2026-07-15', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0019', 'DG015', 'NV04', '2026-08-10', '2026-08-24', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0020', 'DG011', 'NV03', '2026-06-15', '2026-07-06', N'Đã trả')

/*NHAP DU LIEU CTPHIEUMUON*/
INSERT INTO CTPHIEUMUON VALUES ('PM0001', 'CS001', '2026-06-10', N'Bình thường')
INSERT INTO CTPHIEUMUON VALUES ('PM0001', 'CS010', '2026-06-10', N'Bình thường')
INSERT INTO CTPHIEUMUON VALUES ('PM0002', 'CS012', '2026-06-25', N'Bình thường')	-- tra tre 6 ngay
INSERT INTO CTPHIEUMUON VALUES ('PM0003', 'CS018', '2026-07-05', N'Bình thường')
INSERT INTO CTPHIEUMUON VALUES ('PM0003', 'CS020', '2026-07-05', N'Bình thường')
INSERT INTO CTPHIEUMUON VALUES ('PM0004', 'CS006', '2026-07-03', N'Hư hỏng')		-- lam hu sach
INSERT INTO CTPHIEUMUON VALUES ('PM0005', 'CS015', '2026-07-14', N'Mất')			-- lam mat sach
INSERT INTO CTPHIEUMUON VALUES ('PM0005', 'CS016', '2026-07-14', N'Bình thường')
INSERT INTO CTPHIEUMUON VALUES ('PM0006', 'CS021', '2026-07-28', N'Bình thường')
INSERT INTO CTPHIEUMUON VALUES ('PM0006', 'CS009', '2026-07-28', N'Bình thường')
INSERT INTO CTPHIEUMUON VALUES ('PM0007', 'CS024', '2026-08-20', N'Bình thường')	-- tra tre 6 ngay
INSERT INTO CTPHIEUMUON VALUES ('PM0008', 'CS022', '2026-08-14', N'Bình thường')
INSERT INTO CTPHIEUMUON VALUES ('PM0008', 'CS002', '2026-08-18', N'Bình thường')	-- tra tre 3 ngay
INSERT INTO CTPHIEUMUON VALUES ('PM0009', 'CS013', '2026-08-19', N'Bình thường')
INSERT INTO CTPHIEUMUON VALUES ('PM0010', 'CS004', '2026-09-08', N'Bình thường')
INSERT INTO CTPHIEUMUON VALUES ('PM0011', 'CS011', NULL, NULL)						-- dang qua han
INSERT INTO CTPHIEUMUON VALUES ('PM0012', 'CS019', '2026-09-20', N'Bình thường')
INSERT INTO CTPHIEUMUON VALUES ('PM0012', 'CS025', NULL, NULL)						-- dang qua han
INSERT INTO CTPHIEUMUON VALUES ('PM0013', 'CS020', NULL, NULL)
INSERT INTO CTPHIEUMUON VALUES ('PM0013', 'CS016', NULL, NULL)
INSERT INTO CTPHIEUMUON VALUES ('PM0013', 'CS023', NULL, NULL)
INSERT INTO CTPHIEUMUON VALUES ('PM0014', 'CS003', NULL, NULL)
INSERT INTO CTPHIEUMUON VALUES ('PM0014', 'CS007', NULL, NULL)
INSERT INTO CTPHIEUMUON VALUES ('PM0015', 'CS014', NULL, NULL)
INSERT INTO CTPHIEUMUON VALUES ('PM0016', 'CS017', NULL, NULL)
INSERT INTO CTPHIEUMUON VALUES ('PM0016', 'CS026', NULL, NULL)
INSERT INTO CTPHIEUMUON VALUES ('PM0017', 'CS008', '2026-07-30', N'Bình thường')	-- tra tre 6 ngay
INSERT INTO CTPHIEUMUON VALUES ('PM0018', 'CS005', '2026-07-20', N'Bình thường')	-- tra tre 5 ngay
INSERT INTO CTPHIEUMUON VALUES ('PM0019', 'CS021', '2026-08-30', N'Bình thường')	-- tra tre 6 ngay
INSERT INTO CTPHIEUMUON VALUES ('PM0019', 'CS012', '2026-08-24', N'Hư hỏng')		-- lam hu sach
INSERT INTO CTPHIEUMUON VALUES ('PM0020', 'CS022', '2026-07-10', N'Bình thường')	-- tra tre 4 ngay

/*NHAP DU LIEU PHIEUPHAT
  Quy dinh: tra tre 5.000d/ngay; hu hong 50% gia sach; mat sach 100% gia sach*/
INSERT INTO PHIEUPHAT VALUES ('PP0001', 'PM0002', 'CS012', '2026-06-25', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT VALUES ('PP0002', 'PM0004', 'CS006', '2026-07-03', N'Hư hỏng', 25000, 1)
INSERT INTO PHIEUPHAT VALUES ('PP0003', 'PM0005', 'CS015', '2026-07-14', N'Mất sách', 250000, 0)
INSERT INTO PHIEUPHAT VALUES ('PP0004', 'PM0020', 'CS022', '2026-07-10', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT VALUES ('PP0005', 'PM0018', 'CS005', '2026-07-20', N'Trả trễ', 25000, 1)
INSERT INTO PHIEUPHAT VALUES ('PP0006', 'PM0017', 'CS008', '2026-07-30', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT VALUES ('PP0007', 'PM0007', 'CS024', '2026-08-20', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT VALUES ('PP0008', 'PM0008', 'CS002', '2026-08-18', N'Trả trễ', 15000, 0)
INSERT INTO PHIEUPHAT VALUES ('PP0009', 'PM0019', 'CS012', '2026-08-24', N'Hư hỏng', 43000, 1)
INSERT INTO PHIEUPHAT VALUES ('PP0010', 'PM0019', 'CS021', '2026-08-30', N'Trả trễ', 30000, 0)
GO

/*CAP NHAT CAC THUOC TINH DAN XUAT*/
UPDATE DAUSACH
SET SOLUONG = (SELECT COUNT(*) FROM CUONSACH CS WHERE CS.MADS = DAUSACH.MADS),
	SLCON	= (SELECT COUNT(*) FROM CUONSACH CS WHERE CS.MADS = DAUSACH.MADS AND CS.TINHTRANG = N'Có sẵn')

UPDATE DOCGIA
SET TONGNO = ISNULL((SELECT SUM(PP.SOTIEN)
					 FROM PHIEUPHAT PP JOIN PHIEUMUON PM ON PP.MAPM = PM.MAPM
					 WHERE PM.MADG = DOCGIA.MADG AND PP.DATHANHTOAN = 0), 0)
GO

GO


/* ==================== CONTENT OF 3_Function.sql ==================== */

/* =====================================================================
   File   : 03_Function.sql
   Noi dung: 3 FUNCTION (2 ham tra ve gia tri vo huong, 1 ham tra ve bang)
   ===================================================================== */

USE QUANLYTHUVIEN
GO

/* ---------------------------------------------------------------------
   FUNCTION 1. Dua vao MADG, tra ve so cuon sach doc gia do dang muon
   (chua tra). Neu khong tim thay doc gia thi tra ve -1.
   --------------------------------------------------------------------- */
CREATE FUNCTION FN_SOSACHDANGMUON (@MADG CHAR(5))
RETURNS INT
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM DOCGIA WHERE MADG = @MADG)
		RETURN -1

	DECLARE @SOSACH INT
	SELECT @SOSACH = COUNT(*)
	FROM CTPHIEUMUON CT JOIN PHIEUMUON PM ON CT.MAPM = PM.MAPM
	WHERE PM.MADG = @MADG AND CT.NGAYTRA IS NULL

	RETURN @SOSACH
END
GO

/* ---------------------------------------------------------------------
   FUNCTION 2. Dua vao han tra va ngay tra, tra ve tien phat tra tre.
   Quy dinh: 5.000d cho moi ngay tre. Tra dung han thi tien phat = 0.
   --------------------------------------------------------------------- */
CREATE FUNCTION FN_TIENPHATTRE (@HANTRA DATE, @NGAYTRA DATE)
RETURNS MONEY
AS
BEGIN
	DECLARE @SONGAYTRE INT = DATEDIFF(DAY, @HANTRA, @NGAYTRA)

	IF @SONGAYTRE <= 0
		RETURN 0

	RETURN @SONGAYTRE * 5000
END
GO

/* ---------------------------------------------------------------------
   FUNCTION 3. Dua vao MADG, tra ve bang lich su muon sach cua doc gia:
   ma phieu, ten sach, ngay muon, han tra, ngay tra, so ngay tre,
   trang thai tung cuon.
   --------------------------------------------------------------------- */
CREATE FUNCTION FN_LICHSUMUON (@MADG CHAR(5))
RETURNS TABLE
AS
RETURN
(
	SELECT	PM.MAPM, CS.MACS, DS.TENDS, PM.NGAYMUON, PM.HANTRA, CT.NGAYTRA,
			CASE
				WHEN CT.NGAYTRA IS NULL AND PM.HANTRA < CAST(GETDATE() AS DATE)
					THEN DATEDIFF(DAY, PM.HANTRA, GETDATE())
				WHEN CT.NGAYTRA > PM.HANTRA
					THEN DATEDIFF(DAY, PM.HANTRA, CT.NGAYTRA)
				ELSE 0
			END AS SONGAYTRE,
			CASE
				WHEN CT.NGAYTRA IS NOT NULL THEN N'Đã trả (' + CT.TINHTRANGTRA + N')'
				WHEN PM.HANTRA < CAST(GETDATE() AS DATE) THEN N'Quá hạn'
				ELSE N'Đang mượn'
			END AS TRANGTHAI
	FROM PHIEUMUON PM
		JOIN CTPHIEUMUON CT ON PM.MAPM = CT.MAPM
		JOIN CUONSACH CS ON CT.MACS = CS.MACS
		JOIN DAUSACH DS ON CS.MADS = DS.MADS
	WHERE PM.MADG = @MADG
)
GO

/* ---------------------- VI DU SU DUNG ------------------------------
SELECT dbo.FN_SOSACHDANGMUON('DG007') AS SOSACHDANGMUON
SELECT dbo.FN_TIENPHATTRE('2026-09-15', '2026-09-26') AS TIENPHAT
SELECT * FROM dbo.FN_LICHSUMUON('DG001') ORDER BY NGAYMUON
--------------------------------------------------------------------- */

GO


/* ==================== CONTENT OF 4_Trigger.sql ==================== */

/* =====================================================================
   File   : 04_Trigger.sql
   Noi dung: 5 TRIGGER hien thuc cac rang buoc toan ven va nghiep vu
   Luu y  : chay SAU 02_DuLieuMau.sql va 03_Function.sql
   ===================================================================== */

USE QUANLYTHUVIEN
GO

/* ---------------------------------------------------------------------
   TRIGGER 1. Rang buoc thuoc tinh dan xuat:
     DAUSACH.SOLUONG = so cuon sach cua dau sach
     DAUSACH.SLCON   = so cuon sach dang o tinh trang 'Có sẵn'
   Bang tam anh huong:
     | Bang     | Them | Xoa | Sua              |
     | CUONSACH |  +   |  +  | + (MADS, TINHTRANG)|
     | DAUSACH  |  -   |  -  | + (SOLUONG, SLCON) -> khong cho sua tay (CHECK)|
   --------------------------------------------------------------------- */
CREATE TRIGGER TRG_CUONSACH_CAPNHATSL
ON CUONSACH
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON

	UPDATE DAUSACH
	SET SOLUONG = (SELECT COUNT(*) FROM CUONSACH CS WHERE CS.MADS = DAUSACH.MADS),
		SLCON	= (SELECT COUNT(*) FROM CUONSACH CS WHERE CS.MADS = DAUSACH.MADS AND CS.TINHTRANG = N'Có sẵn')
	WHERE MADS IN (SELECT MADS FROM inserted UNION SELECT MADS FROM deleted)
END
GO

/* ---------------------------------------------------------------------
   TRIGGER 2. Dieu kien lap phieu muon:
     - The doc gia phai con han vao ngay muon.
     - Doc gia khong con no tien phat.
   Bang tam anh huong:
     | Bang       | Them | Xoa | Sua                        |
     | PHIEUMUON  |  +   |  -  | + (MADG, NGAYMUON, HANTRA) |
     | DOCGIA     |  -   |  -  | + (NGAYHETHAN, TONGNO) (*) |
     (*) chi kiem tra tai thoi diem lap phieu, khong ap dung hoi to.
   --------------------------------------------------------------------- */
CREATE TRIGGER TRG_PHIEUMUON_KIEMTRA
ON PHIEUMUON
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON

	-- Chi kiem tra khi them phieu hoac sua cac cot lien quan
	IF NOT (UPDATE(MADG) OR UPDATE(NGAYMUON) OR UPDATE(HANTRA))
		RETURN

	IF EXISTS (SELECT * FROM inserted I JOIN DOCGIA DG ON I.MADG = DG.MADG
			   WHERE I.NGAYMUON > DG.NGAYHETHAN)
	BEGIN
		RAISERROR (N'Thẻ độc giả đã hết hạn, không thể lập phiếu mượn.', 16, 1)
		ROLLBACK TRANSACTION
		RETURN
	END

	IF EXISTS (SELECT * FROM inserted I JOIN DOCGIA DG ON I.MADG = DG.MADG
			   WHERE DG.TONGNO > 0)
	BEGIN
		RAISERROR (N'Độc giả còn nợ tiền phạt, phải thanh toán trước khi mượn.', 16, 1)
		ROLLBACK TRANSACTION
		RETURN
	END


END
GO

/* ---------------------------------------------------------------------
   TRIGGER 3. Muon sach (them chi tiet phieu muon):
     - Cuon sach phai dang o tinh trang 'Có sẵn'.
     - Phieu muon phai o tinh trang 'Đang mượn'.
     - Sau khi muon: cap nhat tinh trang cuon sach thanh 'Đang mượn'.
   Bang tam anh huong:
     | Bang        | Them | Xoa | Sua             |
     | CTPHIEUMUON |  +   |  -  | + (MAPM, MACS)  |
     | CUONSACH    |  -   |  -  | + (TINHTRANG)   |
   --------------------------------------------------------------------- */
CREATE TRIGGER TRG_CTPM_MUONSACH
ON CTPHIEUMUON
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON

	IF EXISTS (SELECT * FROM inserted I JOIN CUONSACH CS ON I.MACS = CS.MACS
			   WHERE I.NGAYTRA IS NULL AND CS.TINHTRANG <> N'Có sẵn')
	BEGIN
		RAISERROR (N'Có cuốn sách không ở tình trạng "Có sẵn", không thể cho mượn.', 16, 1)
		ROLLBACK TRANSACTION
		RETURN
	END

	-- Mot cuon sach khong duoc nam trong 2 dong chi tiet chua tra
	IF EXISTS (SELECT CT.MACS FROM CTPHIEUMUON CT
			   WHERE CT.NGAYTRA IS NULL AND CT.MACS IN (SELECT MACS FROM inserted)
			   GROUP BY CT.MACS HAVING COUNT(*) > 1)
	BEGIN
		RAISERROR (N'Một cuốn sách không thể được mượn đồng thời trên nhiều phiếu.', 16, 1)
		ROLLBACK TRANSACTION
		RETURN
	END

	IF EXISTS (SELECT * FROM inserted I JOIN PHIEUMUON PM ON I.MAPM = PM.MAPM
			   WHERE PM.TINHTRANG <> N'Đang mượn')
	BEGIN
		RAISERROR (N'Phiếu mượn đã đóng, không thể thêm sách.', 16, 1)
		ROLLBACK TRANSACTION
		RETURN
	END



	UPDATE CUONSACH
	SET TINHTRANG = N'Đang mượn'
	WHERE MACS IN (SELECT MACS FROM inserted WHERE NGAYTRA IS NULL)
END
GO

/* ---------------------------------------------------------------------
   TRIGGER 4. Tra sach (cap nhat NGAYTRA trong chi tiet phieu muon):
     - Ngay tra khong duoc truoc ngay muon; sach da tra thi khong sua lai.
     - Cap nhat tinh trang cuon sach theo tinh trang khi tra:
         Bình thường -> Có sẵn | Hư hỏng -> Hư hỏng | Mất -> Mất
     - Tu dong lap phieu phat:
         Tra tre : FN_TIENPHATTRE (5.000d/ngay)
         Hu hong : 50% gia sach
         Mat     : 100% gia sach
     - Phieu muon tra het sach -> tinh trang 'Đã trả'.
   Bang tam anh huong:
     | Bang        | Them | Xoa | Sua                     |
     | CTPHIEUMUON |  -   |  -  | + (NGAYTRA, TINHTRANGTRA) |
     | CUONSACH    |  -   |  -  | + (TINHTRANG)           |
     | PHIEUMUON   |  -   |  -  | + (TINHTRANG)           |
     | PHIEUPHAT   |  +   |  -  | -                       |
   --------------------------------------------------------------------- */
CREATE TRIGGER TRG_CTPM_TRASACH
ON CTPHIEUMUON
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON

	IF NOT (UPDATE(NGAYTRA) OR UPDATE(TINHTRANGTRA))
		RETURN

	IF EXISTS (SELECT * FROM inserted I JOIN deleted D ON I.MAPM = D.MAPM AND I.MACS = D.MACS
			   WHERE D.NGAYTRA IS NOT NULL)
	BEGIN
		RAISERROR (N'Sách đã được trả, không thể cập nhật lại thông tin trả.', 16, 1)
		ROLLBACK TRANSACTION
		RETURN
	END

	IF EXISTS (SELECT * FROM inserted I JOIN PHIEUMUON PM ON I.MAPM = PM.MAPM
			   WHERE I.NGAYTRA < PM.NGAYMUON)
	BEGIN
		RAISERROR (N'Ngày trả không được trước ngày mượn.', 16, 1)
		ROLLBACK TRANSACTION
		RETURN
	END

	-- Cap nhat tinh trang cuon sach
	UPDATE CS
	SET TINHTRANG = CASE I.TINHTRANGTRA
						WHEN N'Bình thường' THEN N'Có sẵn'
						ELSE I.TINHTRANGTRA
					END
	FROM CUONSACH CS JOIN inserted I ON CS.MACS = I.MACS
	WHERE I.NGAYTRA IS NOT NULL

	-- Lap phieu phat tu dong
	DECLARE @MAX INT
	SELECT @MAX = ISNULL(MAX(CAST(SUBSTRING(MAPP, 3, 4) AS INT)), 0) FROM PHIEUPHAT

	;WITH TRA AS
	(
		SELECT I.MAPM, I.MACS, I.NGAYTRA, I.TINHTRANGTRA, PM.HANTRA, DS.GIA
		FROM inserted I
			JOIN PHIEUMUON PM ON I.MAPM = PM.MAPM
			JOIN CUONSACH CS ON I.MACS = CS.MACS
			JOIN DAUSACH DS ON CS.MADS = DS.MADS
		WHERE I.NGAYTRA IS NOT NULL
	),
	PHAT AS
	(
		SELECT MAPM, MACS, NGAYTRA, N'Trả trễ' AS LYDO, dbo.FN_TIENPHATTRE(HANTRA, NGAYTRA) AS SOTIEN
		FROM TRA WHERE NGAYTRA > HANTRA
		UNION ALL
		SELECT MAPM, MACS, NGAYTRA, N'Hư hỏng', GIA * 0.5
		FROM TRA WHERE TINHTRANGTRA = N'Hư hỏng'
		UNION ALL
		SELECT MAPM, MACS, NGAYTRA, N'Mất sách', GIA
		FROM TRA WHERE TINHTRANGTRA = N'Mất'
	)
	INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN)
	SELECT 'PP' + RIGHT('0000' + CAST(@MAX + ROW_NUMBER() OVER (ORDER BY MAPM, MACS, LYDO) AS VARCHAR(4)), 4),
		   MAPM, MACS, NGAYTRA, LYDO, SOTIEN, 0
	FROM PHAT

	-- Dong phieu muon neu da tra het sach
	UPDATE PHIEUMUON
	SET TINHTRANG = N'Đã trả'
	WHERE MAPM IN (SELECT MAPM FROM inserted)
	  AND NOT EXISTS (SELECT * FROM CTPHIEUMUON CT
					  WHERE CT.MAPM = PHIEUMUON.MAPM AND CT.NGAYTRA IS NULL)
END
GO

/* ---------------------------------------------------------------------
   TRIGGER 5. Rang buoc thuoc tinh dan xuat:
     DOCGIA.TONGNO = tong SOTIEN cac phieu phat chua thanh toan cua doc gia
   Bang tam anh huong:
     | Bang      | Them | Xoa | Sua                         |
     | PHIEUPHAT |  +   |  +  | + (SOTIEN, DATHANHTOAN, MAPM) |
     | DOCGIA    |  -   |  -  | + (TONGNO)                  |
   --------------------------------------------------------------------- */
CREATE TRIGGER TRG_PHIEUPHAT_TONGNO
ON PHIEUPHAT
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON

	UPDATE DOCGIA
	SET TONGNO = ISNULL((SELECT SUM(PP.SOTIEN)
						 FROM PHIEUPHAT PP JOIN PHIEUMUON PM ON PP.MAPM = PM.MAPM
						 WHERE PM.MADG = DOCGIA.MADG AND PP.DATHANHTOAN = 0), 0)
	WHERE MADG IN (SELECT PM.MADG FROM PHIEUMUON PM
				   WHERE PM.MAPM IN (SELECT MAPM FROM inserted UNION SELECT MAPM FROM deleted))
END
GO

/* ---------------------- VI DU KIEM TRA -----------------------------
-- (T2) DG006 the het han 31/08/2026 -> bao loi
INSERT INTO PHIEUMUON VALUES ('PM0099', 'DG006', 'NV02', '2026-09-26', '2026-10-05', N'Đang mượn')
-- (T2) DG009 con no 250.000d -> bao loi
INSERT INTO PHIEUMUON VALUES ('PM0099', 'DG009', 'NV02', '2026-09-26', '2026-10-05', N'Đang mượn')
-- (T3) CS015 da mat -> bao loi
INSERT INTO PHIEUMUON VALUES ('PM0099', 'DG012', 'NV02', '2026-09-26', '2026-10-05', N'Đang mượn')
INSERT INTO CTPHIEUMUON (MAPM, MACS) VALUES ('PM0099', 'CS015')
-- (T4) Tra tre CS011 cua PM0011 -> tu dong lap phieu phat, TONGNO cua DG001 tang
UPDATE CTPHIEUMUON SET NGAYTRA = '2026-09-26', TINHTRANGTRA = N'Bình thường'
WHERE MAPM = 'PM0011' AND MACS = 'CS011'
SELECT * FROM PHIEUPHAT WHERE MAPM = 'PM0011'
SELECT MADG, TONGNO FROM DOCGIA WHERE MADG = 'DG001'
--------------------------------------------------------------------- */

GO


/* ==================== CONTENT OF 5_StoredProcedure.sql ==================== */

/* =====================================================================
   File   : 05_StoredProcedure.sql
   Noi dung: STORED PROCEDURE
     A. Tham so vao          : SP_THEMDOCGIA, SP_TIMSACH
     B. Tham so vao va ra    : SP_LAPPHIEUMUON, SP_TRASACH,
                               SP_THANHTOANPHAT, SP_THONGKETHANG
   ===================================================================== */
USE QUANLYTHUVIEN;


GO
/* ---------------------------------------------------------------------
   SP 1. Them doc gia moi.
   Tham so vao: MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL.
   - MADG da ton tai          -> tra ve 0
   
   - Nguoc lai insert, ngay lap the = hom nay, han the: khach ngoai 6 thang,
     cac loai khac 2 nam      -> tra ve 2
   --------------------------------------------------------------------- */
CREATE PROCEDURE SP_THEMDOCGIA
@MADG CHAR (5), @HOTEN NVARCHAR (40), @NGSINH DATE, @GIOITINH NVARCHAR (3), @DIACHI NVARCHAR (100), @SODT VARCHAR (15), @EMAIL VARCHAR (50)
AS
BEGIN
	IF EXISTS (SELECT	*
				FROM		DOCGIA
				WHERE	MADG = @MADG)
		BEGIN
			PRINT N'Mã độc giả đã tồn tại.';
			RETURN 0;
		END
	DECLARE @NGAYLAP AS DATE = GETDATE();
	DECLARE @HETHAN AS DATE = DATEADD(YEAR, 2, @NGAYLAP);
	INSERT	INTO DOCGIA (
		MADG,
		HOTEN,
		NGSINH,
		GIOITINH,
		DIACHI,
		SODT,
		EMAIL,
		NGAYLAPTHE,
		NGAYHETHAN
	)
	VALUES              (@MADG, @HOTEN, @NGSINH, @GIOITINH, @DIACHI, @SODT, @EMAIL, @NGAYLAP, @HETHAN);
	PRINT N'Thêm độc giả thành công.';
	RETURN 2;
END


GO
/* ---------------------------------------------------------------------
   SP 2. Tim sach theo tu khoa (ten sach, ten tac gia hoac ten the loai).
   Tham so vao: TUKHOA. Tra ve danh sach dau sach va so cuon con san.
   --------------------------------------------------------------------- */
CREATE PROCEDURE SP_TIMSACH
@TUKHOA NVARCHAR (100),
@PageNumber INT = 1,
@PageSize INT = 10
AS
BEGIN
	SELECT		DS.MADS,
				DS.TENDS,
				TL.TENTL,
				NXB.TENNXB,
				DS.NAMXB,
				DS.MATL,
				DS.MANXB,
				DS.SOTRANG,
				DS.GIA,
				STUFF((SELECT		N', ' + TG.TENTG
					FROM		DAUSACH_TACGIA AS DT
							INNER JOIN
							TACGIA AS TG
							ON DT.MATG = TG.MATG
					WHERE		DT.MADS = DS.MADS
					FOR			XML PATH ('')), 1, 2, '') AS TACGIA,
				DS.SOLUONG,
				DS.SLCON,
				COUNT(*) OVER() AS TotalRecord
	FROM		DAUSACH AS DS
				INNER JOIN
				THELOAI AS TL
				ON DS.MATL = TL.MATL
				INNER JOIN
				NHAXUATBAN AS NXB
				ON DS.MANXB = NXB.MANXB
	WHERE		DS.TENDS LIKE N'%' + @TUKHOA + N'%'
				OR TL.TENTL LIKE N'%' + @TUKHOA + N'%'
				OR EXISTS (SELECT		*
						FROM		DAUSACH_TACGIA AS DT
								INNER JOIN
								TACGIA AS TG
								ON DT.MATG = TG.MATG
						WHERE		DT.MADS = DS.MADS
								AND TG.TENTG LIKE N'%' + @TUKHOA + N'%')
	ORDER BY	DS.TENDS
	OFFSET (@PageNumber - 1) * @PageSize ROWS
	FETCH NEXT @PageSize ROWS ONLY;
END


GO
/* ---------------------------------------------------------------------
   SP 3. Lap phieu muon.
   Tham so vao : MADG, MANV, danh sach ma cuon sach cach nhau boi dau phay
                 (VD: 'CS001,CS010').
   Tham so ra  : MAPM vua tao.
   - Ma phieu tu tang, han tra = ngay muon + so ngay muon cua loai doc gia.
   - Cac rang buoc (the con han, khong no, so sach toi da, sach co san)
     do TRG_PHIEUMUON_KIEMTRA va TRG_CTPM_MUONSACH kiem tra.
   - Tat ca trong 1 transaction: loi o bat ky cuon nao thi huy toan bo.
   Tra ve: 1 thanh cong, 0 that bai.
   --------------------------------------------------------------------- */
CREATE PROCEDURE SP_LAPPHIEUMUON
@MADG CHAR (5), @MANV CHAR (4), @DSMACS VARCHAR (200), @MAPM CHAR (6) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @MAPM = NULL;
	IF NOT EXISTS (SELECT	*
					FROM		DOCGIA
					WHERE	MADG = @MADG)
		BEGIN
			PRINT N'Độc giả không tồn tại.';
			RETURN 0;
		END
	IF NOT EXISTS (SELECT	*
					FROM		STRING_SPLIT (@DSMACS, ',')
					WHERE	LTRIM(RTRIM(value)) <> '')
		BEGIN
			PRINT N'Phiếu mượn phải có ít nhất một cuốn sách.';
			RETURN 0;
		END
	DECLARE @SONGAY AS INT = 14; -- Mặc định 14 ngày
	BEGIN TRY
		BEGIN TRANSACTION;
		DECLARE @MAX AS INT;
		SELECT	@MAX = ISNULL(MAX(CAST (SUBSTRING(MAPM, 3, 4) AS INT)), 0)
		FROM	PHIEUMUON WITH (UPDLOCK, HOLDLOCK);
		SET @MAPM = 'PM' + RIGHT('0000' + CAST (@MAX + 1 AS VARCHAR (4)), 4);
		INSERT	INTO PHIEUMUON (
			MAPM,
			MADG,
			MANV,
			NGAYMUON,
			HANTRA,
			TINHTRANG
		)
		VALUES                 (@MAPM, @MADG, @MANV, CAST (GETDATE() AS DATE), DATEADD(DAY, @SONGAY, CAST (GETDATE() AS DATE)), N'Đang mượn');
		INSERT	INTO CTPHIEUMUON (
			MAPM,
			MACS
		)
		SELECT	DISTINCT @MAPM,
						LTRIM(RTRIM(value))
		FROM	STRING_SPLIT (@DSMACS, ',')
		WHERE	LTRIM(RTRIM(value)) <> '';
		COMMIT TRANSACTION;
		PRINT N'Lập phiếu mượn ' + @MAPM + N' thành công.';
		RETURN 1;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		SET @MAPM = NULL;
		DECLARE @LOI AS NVARCHAR (4000) = ERROR_MESSAGE();
		RAISERROR (@LOI, 16, 1);
		RETURN 0;
	END CATCH
END


GO
/* ---------------------------------------------------------------------
   SP 4. Tra sach.
   Tham so vao : MAPM, MACS, tinh trang khi tra (mac dinh 'Bình thường').
   Tham so ra  : TIENPHAT - tong tien phat phat sinh cho lan tra nay.
   - Khong tim thay chi tiet phieu muon -> tra ve 0
   - Sach da tra truoc do             -> tra ve 1
   - Nguoc lai cap nhat ngay tra = hom nay (trigger TRG_CTPM_TRASACH tu
     cap nhat tinh trang sach, lap phieu phat)  -> tra ve 2
   --------------------------------------------------------------------- */
CREATE PROCEDURE SP_TRASACH
@MAPM CHAR (6), @MACS CHAR (5), @TINHTRANGTRA NVARCHAR (20)=N'Bình thường', @TIENPHAT MONEY OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @TIENPHAT = 0;
	IF NOT EXISTS (SELECT	*
					FROM		CTPHIEUMUON
					WHERE	MAPM = @MAPM
							AND MACS = @MACS)
		BEGIN
			PRINT N'Không tìm thấy sách trong phiếu mượn.';
			RETURN 0;
		END
	IF EXISTS (SELECT	*
				FROM		CTPHIEUMUON
				WHERE	MAPM = @MAPM
						AND MACS = @MACS
						AND NGAYTRA IS NOT NULL)
		BEGIN
			PRINT N'Sách này đã được trả trước đó.';
			RETURN 1;
		END
	UPDATE	CTPHIEUMUON
	SET		NGAYTRA			= CAST (GETDATE() AS DATE),
			TINHTRANGTRA		= @TINHTRANGTRA
	WHERE	MAPM = @MAPM
			AND MACS = @MACS;
	SELECT	@TIENPHAT = ISNULL(SUM(SOTIEN), 0)
	FROM	PHIEUPHAT
	WHERE	MAPM = @MAPM
			AND MACS = @MACS
			AND DATHANHTOAN = 0;
	PRINT N'Trả sách thành công. Tiền phạt: ' + FORMAT(@TIENPHAT, 'N0') + N' đ';
	RETURN 2;
END


GO
/* ---------------------------------------------------------------------
   SP 5. Thanh toan toan bo tien phat cua doc gia.
   Tham so vao : MADG.   Tham so ra: SOTIEN da thanh toan.
   - Doc gia khong ton tai -> tra ve 0
   - Doc gia khong co no   -> tra ve 1
   - Nguoc lai danh dau cac phieu phat da thanh toan
     (TRG_PHIEUPHAT_TONGNO cap nhat lai TONGNO) -> tra ve 2
   --------------------------------------------------------------------- */
CREATE PROCEDURE SP_THANHTOANPHAT
@MADG CHAR (5), @SOTIEN MONEY OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @SOTIEN = 0;
	IF NOT EXISTS (SELECT	*
					FROM		DOCGIA
					WHERE	MADG = @MADG)
		BEGIN
			PRINT N'Độc giả không tồn tại.';
			RETURN 0;
		END
	SELECT	@SOTIEN = ISNULL(SUM(PP.SOTIEN), 0)
	FROM	PHIEUPHAT AS PP
			INNER JOIN
			PHIEUMUON AS PM
			ON PP.MAPM = PM.MAPM
	WHERE	PM.MADG = @MADG
			AND PP.DATHANHTOAN = 0;
	IF @SOTIEN = 0
		BEGIN
			PRINT N'Độc giả không có khoản phạt nào chưa thanh toán.';
			RETURN 1;
		END
	UPDATE	PHIEUPHAT
	SET		DATHANHTOAN	= 1
	WHERE	DATHANHTOAN = 0
			AND MAPM IN (SELECT	MAPM
						FROM	PHIEUMUON
						WHERE	MADG = @MADG);
	PRINT N'Đã thanh toán ' + FORMAT(@SOTIEN, 'N0') + N' đ.';
	RETURN 2;
END


GO
/* ---------------------------------------------------------------------
   SP 6. Thong ke hoat dong thu vien theo thang.
   Tham so vao : THANG, NAM.
   Tham so ra  : so phieu muon, so luot sach duoc muon, tong tien phat
                 phat sinh trong thang.
   Dong thoi tra ve bang top 5 dau sach duoc muon nhieu nhat trong thang.
   --------------------------------------------------------------------- */
CREATE PROCEDURE SP_THONGKETHANG
@THANG INT, @NAM INT, @SOPHIEU INT OUTPUT, @SOLUOTSACH INT OUTPUT, @TIENPHAT MONEY OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT	@SOPHIEU = COUNT(*)
	FROM	PHIEUMUON
	WHERE	MONTH(NGAYMUON) = @THANG
			AND YEAR(NGAYMUON) = @NAM;
	SELECT	@SOLUOTSACH = COUNT(*)
	FROM	CTPHIEUMUON AS CT
			INNER JOIN
			PHIEUMUON AS PM
			ON CT.MAPM = PM.MAPM
	WHERE	MONTH(PM.NGAYMUON) = @THANG
			AND YEAR(PM.NGAYMUON) = @NAM;
	SELECT	@TIENPHAT = ISNULL(SUM(SOTIEN), 0)
	FROM	PHIEUPHAT
	WHERE	MONTH(NGAYLAP) = @THANG
			AND YEAR(NGAYLAP) = @NAM;
	SELECT		TOP 5 DS.MADS,
					DS.TENDS,
					COUNT(*) AS SOLUOTMUON
	FROM		CTPHIEUMUON AS CT
				INNER JOIN
				PHIEUMUON AS PM
				ON CT.MAPM = PM.MAPM
				INNER JOIN
				CUONSACH AS CS
				ON CT.MACS = CS.MACS
				INNER JOIN
				DAUSACH AS DS
				ON CS.MADS = DS.MADS
	WHERE		MONTH(PM.NGAYMUON) = @THANG
				AND YEAR(PM.NGAYMUON) = @NAM
	GROUP BY	DS.MADS, DS.TENDS
	ORDER BY	SOLUOTMUON DESC, DS.MADS;
END


GO
/* ---------------------- VI DU SU DUNG ------------------------------
DECLARE @KQ INT
EXEC @KQ = SP_THEMDOCGIA 'DG016', N'Trương Thị Hoa', '2005-05-05', N'Nữ', N'Thủ Đức, TpHCM', '0901234576', NULL, 'SV'
SELECT @KQ AS KETQUA

EXEC SP_TIMSACH N'Nguyễn Nhật Ánh'

DECLARE @MAPM CHAR(6), @KQ2 INT
EXEC @KQ2 = SP_LAPPHIEUMUON 'DG012', 'NV02', 'CS001,CS010', @MAPM OUTPUT
SELECT @KQ2 AS KETQUA, @MAPM AS MAPM

DECLARE @PHAT MONEY
EXEC SP_TRASACH 'PM0012', 'CS025', N'Bình thường', @PHAT OUTPUT
SELECT @PHAT AS TIENPHAT

DECLARE @TIEN MONEY
EXEC SP_THANHTOANPHAT 'DG009', @TIEN OUTPUT
SELECT @TIEN AS DATHANHTOAN

DECLARE @SP INT, @SL INT, @TP MONEY
EXEC SP_THONGKETHANG 7, 2026, @SP OUTPUT, @SL OUTPUT, @TP OUTPUT
SELECT @SP AS SOPHIEU, @SL AS SOLUOTSACH, @TP AS TIENPHAT
--------------------------------------------------------------------- */
/* ---------------------------------------------------------------------
   SP 7. Sua doc gia.
   Tham so vao: MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL.
   - MADG khong ton tai       -> tra ve 0
   
   - Nguoc lai cap nhat      -> tra ve 2
   --------------------------------------------------------------------- */
CREATE PROCEDURE SP_SUADOCGIA
@MADG CHAR (5), @HOTEN NVARCHAR (40), @NGSINH DATE, @GIOITINH NVARCHAR (3), @DIACHI NVARCHAR (100), @SODT VARCHAR (15), @EMAIL VARCHAR (50)
AS
BEGIN
	IF NOT EXISTS (SELECT	*
					FROM		DOCGIA
					WHERE	MADG = @MADG)
		BEGIN
			PRINT N'Mã độc giả không tồn tại.';
			RETURN 0;
		END
	UPDATE	DOCGIA
	SET		HOTEN		= @HOTEN,
			NGSINH		= @NGSINH,
			GIOITINH		= @GIOITINH,
			DIACHI		= @DIACHI,
			SODT			= @SODT,
			EMAIL		= @EMAIL
	WHERE	MADG = @MADG;
	PRINT N'Cập nhật độc giả thành công.';
	RETURN 2;
END


GO
/* ---------------------------------------------------------------------
   SP 8. Sua dau sach.
   Tham so vao: MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA
   - MADS khong ton tai       -> tra ve 0
   - Nguoc lai cap nhat       -> tra ve 1
   --------------------------------------------------------------------- */
CREATE PROCEDURE SP_SUADAUSACH
@MADS CHAR (5), @TENDS NVARCHAR (100), @MATL CHAR (4), @MANXB CHAR (5), @NAMXB INT, @SOTRANG INT, @GIA MONEY
AS
BEGIN
	IF NOT EXISTS (SELECT	*
					FROM		DAUSACH
					WHERE	MADS = @MADS)
		BEGIN
			PRINT N'Mã đầu sách không tồn tại.';
			RETURN 0;
		END
	UPDATE	DAUSACH
	SET		TENDS	= @TENDS,
			MATL		= @MATL,
			MANXB	= @MANXB,
			NAMXB	= @NAMXB,
			SOTRANG	= @SOTRANG,
			GIA		= @GIA
	WHERE	MADS = @MADS;
	PRINT N'Cập nhật đầu sách thành công.';
	RETURN 1;
END


GO
/* ---------------------------------------------------------------------
   SP 9. Them dau sach.
   Tham so vao: MADS, TENDS, MATL, MANXB, NAMXB, SOTRANG, GIA
   - MADS da ton tai       -> tra ve 0
   - MATL khong ton tai    -> tra ve 1
   - MANXB khong ton tai   -> tra ve 2
   - Nguoc lai insert      -> tra ve 3
   --------------------------------------------------------------------- */
CREATE PROCEDURE SP_THEMDAUSACH
@MADS CHAR (5), @TENDS NVARCHAR (100), @MATL CHAR (4), @MANXB CHAR (5), @NAMXB INT, @SOTRANG INT, @GIA MONEY
AS
BEGIN
	IF EXISTS (SELECT	*
				FROM		DAUSACH
				WHERE	MADS = @MADS)
		BEGIN
			PRINT N'Mã đầu sách đã tồn tại.';
			RETURN 0;
		END
	IF NOT EXISTS (SELECT	*
					FROM		THELOAI
					WHERE	MATL = @MATL)
		BEGIN
			PRINT N'Mã thể loại không tồn tại.';
			RETURN 1;
		END
	IF NOT EXISTS (SELECT	*
					FROM		NHAXUATBAN
					WHERE	MANXB = @MANXB)
		BEGIN
			PRINT N'Mã nhà xuất bản không tồn tại.';
			RETURN 2;
		END
	INSERT	INTO DAUSACH (
		MADS,
		TENDS,
		MATL,
		MANXB,
		NAMXB,
		SOTRANG,
		GIA
	)
	VALUES               (@MADS, @TENDS, @MATL, @MANXB, @NAMXB, @SOTRANG, @GIA);
	PRINT N'Thêm đầu sách thành công.';
	RETURN 3;
END
GO

/* ---------------------------------------------------------------------
   SP 10. Tim doc gia.
   Tham so vao: TUKHOA (tim theo MADG hoac HOTEN). 
   Tra ve: Danh sach doc gia.
   --------------------------------------------------------------------- */
CREATE PROCEDURE SP_TIMDOCGIA
	@TUKHOA NVARCHAR(100),
	@PageNumber INT = 1,
	@PageSize INT = 10
AS
BEGIN
	SELECT DG.MADG, DG.HOTEN, DG.NGSINH, DG.GIOITINH, DG.DIACHI, DG.SODT, DG.EMAIL, DG.NGAYLAPTHE, DG.NGAYHETHAN, DG.TONGNO,
	       COUNT(*) OVER() AS TotalRecord
	FROM DOCGIA DG
	WHERE DG.MADG LIKE '%' + @TUKHOA + '%'
	   OR DG.HOTEN LIKE N'%' + @TUKHOA + N'%'
	ORDER BY DG.MADG
	OFFSET (@PageNumber - 1) * @PageSize ROWS
	FETCH NEXT @PageSize ROWS ONLY;
END
GO

/* ---------------------------------------------------------------------
   SP 11. Xoa dau sach.
   Tham so vao: MADS.
   - MADS khong ton tai -> tra ve 0
   - Dau sach dang co cuon sach -> tra ve 1 (Khong the xoa)
   - Nguoc lai xoa -> tra ve 2
   --------------------------------------------------------------------- */
CREATE PROCEDURE SP_XOADAUSACH
	@MADS CHAR(5)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM DAUSACH WHERE MADS = @MADS)
	BEGIN
		PRINT N'Mã đầu sách không tồn tại.'
		RETURN 0
	END

	IF EXISTS (SELECT * FROM CUONSACH WHERE MADS = @MADS)
	BEGIN
		PRINT N'Đầu sách này vẫn còn các cuốn sách. Không thể xóa.'
		RETURN 1
	END

    -- Xoa khoa ngoai DAUSACH_TACGIA truoc
    DELETE FROM DAUSACH_TACGIA WHERE MADS = @MADS
	DELETE FROM DAUSACH WHERE MADS = @MADS

	PRINT N'Xóa đầu sách thành công.'
	RETURN 2
END
GO

/* ---------------------------------------------------------------------
   SP 12. Xoa doc gia.
   Tham so vao: MADG.
   - MADG khong ton tai -> tra ve 0
   - Doc gia co lich su muon sach -> tra ve 1 (Khong the xoa)
   - Nguoc lai xoa -> tra ve 2
   --------------------------------------------------------------------- */
CREATE PROCEDURE SP_XOADOCGIA
	@MADG CHAR(5)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM DOCGIA WHERE MADG = @MADG)
	BEGIN
		PRINT N'Mã độc giả không tồn tại.'
		RETURN 0
	END

    IF EXISTS (SELECT * FROM PHIEUMUON WHERE MADG = @MADG)
    BEGIN
        PRINT N'Độc giả đã có lịch sử mượn trả. Không thể xóa để giữ toàn vẹn dữ liệu.'
        RETURN 1
    END

	-- Xóa các bản ghi tham chiếu ở các bảng khác
	IF OBJECT_ID('DOCGIA_XEPLOAI') IS NOT NULL
	BEGIN
		EXEC('DELETE FROM DOCGIA_XEPLOAI WHERE MADG = ''' + @MADG + '''')
	END
	
	DELETE FROM TAIKHOAN WHERE MADG = @MADG
	DELETE FROM DOCGIA WHERE MADG = @MADG

	PRINT N'Xóa độc giả thành công.'
	RETURN 2
END
GO
GO


/* ==================== CONTENT OF 6_Cursor.sql ==================== */

/* =====================================================================
   File   : 06_Cursor.sql
   Noi dung: 2 CURSOR (moi cursor duoc gom vao 1 Stored Procedure de
             goi lai tu ung dung)
   ===================================================================== */

USE QUANLYTHUVIEN
GO

/* ---------------------------------------------------------------------
   CURSOR 1. Xep loai muc do uy tin cua doc gia.
   Tao bang DOCGIA_XEPLOAI(MADG, SOLUOTMUON, SOLANTRE, SOLANHUMAT,
                           TONGTIENPHAT, XEPLOAI).
   Duyet tung doc gia, tinh cac chi so va xep loai:
     + "Uy tín"     : co muon sach, khong tre / hu / mat lan nao
     + "Bình thường": tre toi da 1 lan, khong hu / mat
     + "Cảnh báo"   : tre tu 2 lan tro len hoac co lam hu sach
     + "Hạn chế"    : co lam mat sach hoac dang no tren 100.000d
     + "Chưa mượn"  : chua muon lan nao
   --------------------------------------------------------------------- */
IF OBJECT_ID('DOCGIA_XEPLOAI') IS NOT NULL
	DROP TABLE DOCGIA_XEPLOAI
GO

CREATE TABLE DOCGIA_XEPLOAI
(
	MADG			CHAR(5)			PRIMARY KEY FOREIGN KEY REFERENCES DOCGIA (MADG),
	SOLUOTMUON		INT				NOT NULL,
	SOLANTRE		INT				NOT NULL,
	SOLANHUMAT		INT				NOT NULL,
	TONGTIENPHAT	MONEY			NOT NULL,
	XEPLOAI			NVARCHAR(20)	NOT NULL,
	NGAYCAPNHAT		DATETIME		NOT NULL DEFAULT GETDATE()
)
GO

CREATE PROCEDURE SP_CURSOR_XEPLOAIDOCGIA
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM DOCGIA_XEPLOAI

	DECLARE @MADG CHAR(5), @TONGNO MONEY
	DECLARE @SOLUOT INT, @SOTRE INT, @SOHUMAT INT, @SOMAT INT, @TIENPHAT MONEY
	DECLARE @XEPLOAI NVARCHAR(20)

	DECLARE CUR_DOCGIA CURSOR FOR
		SELECT MADG, TONGNO FROM DOCGIA

	OPEN CUR_DOCGIA
	FETCH NEXT FROM CUR_DOCGIA INTO @MADG, @TONGNO

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- So luot sach da muon
		SELECT @SOLUOT = COUNT(*)
		FROM CTPHIEUMUON CT JOIN PHIEUMUON PM ON CT.MAPM = PM.MAPM
		WHERE PM.MADG = @MADG

		-- So lan tra tre (da tra tre hoac dang giu qua han)
		SELECT @SOTRE = COUNT(*)
		FROM CTPHIEUMUON CT JOIN PHIEUMUON PM ON CT.MAPM = PM.MAPM
		WHERE PM.MADG = @MADG
		  AND ((CT.NGAYTRA IS NOT NULL AND CT.NGAYTRA > PM.HANTRA)
			OR (CT.NGAYTRA IS NULL AND PM.HANTRA < CAST(GETDATE() AS DATE)))

		-- So lan lam hu / mat sach
		SELECT @SOHUMAT = COUNT(*),
			   @SOMAT = ISNULL(SUM(CASE WHEN CT.TINHTRANGTRA = N'Mất' THEN 1 ELSE 0 END), 0)
		FROM CTPHIEUMUON CT JOIN PHIEUMUON PM ON CT.MAPM = PM.MAPM
		WHERE PM.MADG = @MADG AND CT.TINHTRANGTRA IN (N'Hư hỏng', N'Mất')

		-- Tong tien phat (ca da va chua thanh toan)
		SELECT @TIENPHAT = ISNULL(SUM(PP.SOTIEN), 0)
		FROM PHIEUPHAT PP JOIN PHIEUMUON PM ON PP.MAPM = PM.MAPM
		WHERE PM.MADG = @MADG

		SET @XEPLOAI = CASE
			WHEN @SOLUOT = 0							THEN N'Chưa mượn'
			WHEN @SOMAT > 0 OR @TONGNO > 100000			THEN N'Hạn chế'
			WHEN @SOTRE >= 2 OR @SOHUMAT > 0			THEN N'Cảnh báo'
			WHEN @SOTRE = 1								THEN N'Bình thường'
			ELSE N'Uy tín'
		END

		INSERT INTO DOCGIA_XEPLOAI (MADG, SOLUOTMUON, SOLANTRE, SOLANHUMAT, TONGTIENPHAT, XEPLOAI)
		VALUES (@MADG, @SOLUOT, @SOTRE, @SOHUMAT, @TIENPHAT, @XEPLOAI)

		FETCH NEXT FROM CUR_DOCGIA INTO @MADG, @TONGNO
	END

	CLOSE CUR_DOCGIA
	DEALLOCATE CUR_DOCGIA

	SELECT XL.MADG, DG.HOTEN, XL.SOLUOTMUON, XL.SOLANTRE, XL.SOLANHUMAT, XL.TONGTIENPHAT, XL.XEPLOAI
	FROM DOCGIA_XEPLOAI XL JOIN DOCGIA DG ON XL.MADG = DG.MADG
	ORDER BY XL.MADG
END
GO

/* ---------------------------------------------------------------------
   CURSOR 2. Lap danh sach nhac nho doc gia giu sach qua han.
   Tao bang NHACNHO_QUAHAN(MANN, MAPM, MACS, MADG, HOTEN, SODT, TENDS,
                           HANTRA, SONGAYTRE, TIENPHATTAMTINH, NOIDUNG, NGAYLAP).
   Tham so vao: ngay kiem tra (mac dinh hom nay).
   Duyet tung cuon sach chua tra va da qua han, tinh so ngay tre, tien
   phat tam tinh (FN_TIENPHATTRE) va soan noi dung tin nhan nhac nho.
   Cuon sach da duoc nhac trong cung ngay thi khong them lai.
   --------------------------------------------------------------------- */
IF OBJECT_ID('NHACNHO_QUAHAN') IS NOT NULL
	DROP TABLE NHACNHO_QUAHAN
GO

CREATE TABLE NHACNHO_QUAHAN
(
	MANN			INT				IDENTITY(1,1) PRIMARY KEY,
	MAPM			CHAR(6)			NOT NULL,
	MACS			CHAR(5)			NOT NULL,
	MADG			CHAR(5)			NOT NULL FOREIGN KEY REFERENCES DOCGIA (MADG),
	HOTEN			NVARCHAR(40)	NOT NULL,
	SODT			VARCHAR(15)		NOT NULL,
	TENDS			NVARCHAR(100)	NOT NULL,
	HANTRA			DATE			NOT NULL,
	SONGAYTRE		INT				NOT NULL,
	TIENPHATTAMTINH	MONEY			NOT NULL,
	NOIDUNG			NVARCHAR(300)	NOT NULL,
	NGAYLAP			DATE			NOT NULL,
	FOREIGN KEY (MAPM, MACS) REFERENCES CTPHIEUMUON (MAPM, MACS)
)
GO

CREATE PROCEDURE SP_CURSOR_NHACNHOQUAHAN
	@NGAYKIEMTRA DATE = NULL
AS
BEGIN
	SET NOCOUNT ON
	IF @NGAYKIEMTRA IS NULL
		SET @NGAYKIEMTRA = CAST(GETDATE() AS DATE)

	DECLARE @MAPM CHAR(6), @MACS CHAR(5), @MADG CHAR(5), @HOTEN NVARCHAR(40),
			@SODT VARCHAR(15), @TENDS NVARCHAR(100), @HANTRA DATE
	DECLARE @SONGAYTRE INT, @TIENPHAT MONEY, @NOIDUNG NVARCHAR(300)
	DECLARE @SODONG INT = 0

	DECLARE CUR_QUAHAN CURSOR FOR
		SELECT PM.MAPM, CT.MACS, DG.MADG, DG.HOTEN, DG.SODT, DS.TENDS, PM.HANTRA
		FROM CTPHIEUMUON CT
			JOIN PHIEUMUON PM ON CT.MAPM = PM.MAPM
			JOIN DOCGIA DG ON PM.MADG = DG.MADG
			JOIN CUONSACH CS ON CT.MACS = CS.MACS
			JOIN DAUSACH DS ON CS.MADS = DS.MADS
		WHERE CT.NGAYTRA IS NULL AND PM.HANTRA < @NGAYKIEMTRA
		ORDER BY PM.HANTRA

	OPEN CUR_QUAHAN
	FETCH NEXT FROM CUR_QUAHAN INTO @MAPM, @MACS, @MADG, @HOTEN, @SODT, @TENDS, @HANTRA

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF NOT EXISTS (SELECT * FROM NHACNHO_QUAHAN
					   WHERE MAPM = @MAPM AND MACS = @MACS AND NGAYLAP = @NGAYKIEMTRA)
		BEGIN
			SET @SONGAYTRE = DATEDIFF(DAY, @HANTRA, @NGAYKIEMTRA)
			SET @TIENPHAT = dbo.FN_TIENPHATTRE(@HANTRA, @NGAYKIEMTRA)
			SET @NOIDUNG = N'Thư viện thông báo: bạn ' + @HOTEN + N' đang giữ sách "' + @TENDS
						 + N'" quá hạn ' + CAST(@SONGAYTRE AS NVARCHAR(10)) + N' ngày (hạn trả '
						 + CONVERT(NVARCHAR(10), @HANTRA, 103) + N'). Tiền phạt tạm tính: '
						 + FORMAT(@TIENPHAT, 'N0') + N'đ. Vui lòng trả sách sớm.'

			INSERT INTO NHACNHO_QUAHAN (MAPM, MACS, MADG, HOTEN, SODT, TENDS, HANTRA,
										SONGAYTRE, TIENPHATTAMTINH, NOIDUNG, NGAYLAP)
			VALUES (@MAPM, @MACS, @MADG, @HOTEN, @SODT, @TENDS, @HANTRA,
					@SONGAYTRE, @TIENPHAT, @NOIDUNG, @NGAYKIEMTRA)

			SET @SODONG = @SODONG + 1
		END

		FETCH NEXT FROM CUR_QUAHAN INTO @MAPM, @MACS, @MADG, @HOTEN, @SODT, @TENDS, @HANTRA
	END

	CLOSE CUR_QUAHAN
	DEALLOCATE CUR_QUAHAN

	PRINT N'Đã tạo ' + CAST(@SODONG AS NVARCHAR(10)) + N' nhắc nhở mới.'

	SELECT * FROM NHACNHO_QUAHAN WHERE NGAYLAP = @NGAYKIEMTRA ORDER BY SONGAYTRE DESC
END
GO

/* ---------------------- VI DU SU DUNG ------------------------------
EXEC SP_CURSOR_XEPLOAIDOCGIA
EXEC SP_CURSOR_NHACNHOQUAHAN '2026-09-26'
--------------------------------------------------------------------- */

GO


/* ==================== CONTENT OF 7_AnToanThongTin.sql ==================== */

/* =====================================================================
   File   : 07_AnToanThongTin.sql
   Noi dung: AN TOAN THONG TIN
     A. Xac thuc nguoi dung cua ung dung (bang TAIKHOAN, mat khau bam)
     B. Xac thuc & phan quyen tren SQL Server (LOGIN, USER, ROLE,
        GRANT / DENY / REVOKE)
     C. Import / Export du lieu
     D. Backup / Restore
   ===================================================================== */

USE QUANLYTHUVIEN
GO

/* =====================================================================
   A. XAC THUC NGUOI DUNG CUA UNG DUNG
   Mat khau khong luu dang ro: MATKHAU = SHA2_256(mat khau)
   ===================================================================== */

/* SP tao tai khoan. Tra ve 0: trung ten dang nhap, 1: thanh cong */
CREATE PROCEDURE SP_TAOTAIKHOAN
	@TENDANGNHAP	VARCHAR(30),
	@MATKHAU		NVARCHAR(100),
	@VAITRO			NVARCHAR(20),
	@MANV			CHAR(4) = NULL,
	@MADG			CHAR(5) = NULL
AS
BEGIN
	SET NOCOUNT ON
	IF EXISTS (SELECT * FROM TAIKHOAN WHERE TENDANGNHAP = @TENDANGNHAP)
	BEGIN
		PRINT N'Tên đăng nhập đã tồn tại.'
		RETURN 0
	END

	INSERT INTO TAIKHOAN (TENDANGNHAP, MATKHAU, VAITRO, MANV, MADG)
	VALUES (@TENDANGNHAP,
			HASHBYTES('SHA2_256', @MATKHAU),
			@VAITRO, @MANV, @MADG)
	RETURN 1
END
GO

/* SP dang nhap. Tra ve thong tin tai khoan neu dung, nguoc lai bang rong.
   Tham so ra @KETQUA: 0 sai ten/mat khau, 1 tai khoan bi khoa, 2 thanh cong */
CREATE PROCEDURE SP_DANGNHAP
	@TENDANGNHAP	VARCHAR(30),
	@MATKHAU		NVARCHAR(100),
	@KETQUA			INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET @KETQUA = 0

	IF NOT EXISTS (SELECT * FROM TAIKHOAN
				   WHERE TENDANGNHAP = @TENDANGNHAP
					 AND MATKHAU = HASHBYTES('SHA2_256', @MATKHAU))
	BEGIN
		SELECT TOP 0 TENDANGNHAP, VAITRO, MANV, MADG FROM TAIKHOAN
		RETURN
	END

	IF EXISTS (SELECT * FROM TAIKHOAN WHERE TENDANGNHAP = @TENDANGNHAP AND TRANGTHAI = 0)
	BEGIN
		SET @KETQUA = 1
		SELECT TOP 0 TENDANGNHAP, VAITRO, MANV, MADG FROM TAIKHOAN
		RETURN
	END

	SET @KETQUA = 2
	SELECT TK.TENDANGNHAP, TK.VAITRO, TK.MANV, TK.MADG,
		   ISNULL(NV.HOTEN, DG.HOTEN) AS HOTEN
	FROM TAIKHOAN TK
		LEFT JOIN NHANVIEN NV ON TK.MANV = NV.MANV
		LEFT JOIN DOCGIA DG ON TK.MADG = DG.MADG
	WHERE TK.TENDANGNHAP = @TENDANGNHAP
END
GO

/* SP doi mat khau. Tra ve 0: sai mat khau cu, 1: thanh cong */
CREATE PROCEDURE SP_DOIMATKHAU
	@TENDANGNHAP	VARCHAR(30),
	@MATKHAUCU		NVARCHAR(100),
	@MATKHAUMOI		NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON
	IF NOT EXISTS (SELECT * FROM TAIKHOAN
				   WHERE TENDANGNHAP = @TENDANGNHAP
					 AND MATKHAU = HASHBYTES('SHA2_256', @MATKHAUCU))
		RETURN 0

	UPDATE TAIKHOAN
	SET MATKHAU = HASHBYTES('SHA2_256', @MATKHAUMOI)
	WHERE TENDANGNHAP = @TENDANGNHAP
	RETURN 1
END
GO

/*NHAP DU LIEU TAIKHOAN (mat khau mau: 123456)*/
EXEC SP_TAOTAIKHOAN 'admin',	N'123456', N'Quản lý', 'NV01', NULL
EXEC SP_TAOTAIKHOAN 'qlminh',	N'123456', N'Quản lý', 'NV08', NULL
EXEC SP_TAOTAIKHOAN 'ttkhoa',	N'123456', N'Thủ thư', 'NV02', NULL
EXEC SP_TAOTAIKHOAN 'ttyen',	N'123456', N'Thủ thư', 'NV03', NULL
EXEC SP_TAOTAIKHOAN 'tttri',	N'123456', N'Thủ thư', 'NV04', NULL
EXEC SP_TAOTAIKHOAN 'ttlan',	N'123456', N'Thủ thư', 'NV05', NULL
EXEC SP_TAOTAIKHOAN 'dg001',	N'123456', N'Độc giả', NULL, 'DG001'
EXEC SP_TAOTAIKHOAN 'dg002',	N'123456', N'Độc giả', NULL, 'DG002'
EXEC SP_TAOTAIKHOAN 'dg007',	N'123456', N'Độc giả', NULL, 'DG007'
EXEC SP_TAOTAIKHOAN 'dg009',	N'123456', N'Độc giả', NULL, 'DG009'
UPDATE TAIKHOAN SET TRANGTHAI = 0 WHERE TENDANGNHAP = 'dg009'	-- tai khoan bi khoa
GO

/* =====================================================================
   B. XAC THUC & PHAN QUYEN TREN SQL SERVER
   3 nhom nguoi dung: Quan ly, Thu thu, Doc gia
   ===================================================================== */

/* B.1 Tao LOGIN (muc server) - xoa neu da ton tai de chay lai duoc */
USE master
GO
IF SUSER_ID('LG_QUANLY') IS NOT NULL DROP LOGIN LG_QUANLY
IF SUSER_ID('LG_THUTHU') IS NOT NULL DROP LOGIN LG_THUTHU
IF SUSER_ID('LG_DOCGIA') IS NOT NULL DROP LOGIN LG_DOCGIA
GO
CREATE LOGIN LG_QUANLY WITH PASSWORD = 'QuanLy@2026', DEFAULT_DATABASE = QUANLYTHUVIEN, CHECK_POLICY = ON
CREATE LOGIN LG_THUTHU WITH PASSWORD = 'ThuThu@2026', DEFAULT_DATABASE = QUANLYTHUVIEN, CHECK_POLICY = ON
CREATE LOGIN LG_DOCGIA WITH PASSWORD = 'DocGia@2026', DEFAULT_DATABASE = QUANLYTHUVIEN, CHECK_POLICY = ON
GO

/* B.2 Tao USER (muc CSDL) anh xa voi LOGIN */
USE QUANLYTHUVIEN
GO
CREATE USER U_QUANLY FOR LOGIN LG_QUANLY
CREATE USER U_THUTHU FOR LOGIN LG_THUTHU
CREATE USER U_DOCGIA FOR LOGIN LG_DOCGIA
GO

/* B.3 Tao ROLE va gan USER vao ROLE */
CREATE ROLE R_QUANLY
CREATE ROLE R_THUTHU
CREATE ROLE R_DOCGIA
GO
ALTER ROLE R_QUANLY ADD MEMBER U_QUANLY
ALTER ROLE R_THUTHU ADD MEMBER U_THUTHU
ALTER ROLE R_DOCGIA ADD MEMBER U_DOCGIA
GO

/* B.4 Phan quyen */
-- QUAN LY: toan quyen du lieu, thuc thi moi SP, duoc sao luu CSDL
ALTER ROLE db_datareader		ADD MEMBER R_QUANLY
ALTER ROLE db_datawriter		ADD MEMBER R_QUANLY
ALTER ROLE db_backupoperator	ADD MEMBER R_QUANLY
GRANT EXECUTE ON SCHEMA::dbo TO R_QUANLY
GO

-- THU THU: xem tat ca (tru tai khoan), them/sua nghiep vu muon tra,
--          KHONG duoc xoa bat ky du lieu nao, khong sua thong tin nhan vien
GRANT SELECT ON SCHEMA::dbo TO R_THUTHU
GRANT INSERT, UPDATE ON DOCGIA		TO R_THUTHU
GRANT INSERT, UPDATE ON PHIEUMUON	TO R_THUTHU
GRANT INSERT, UPDATE ON CTPHIEUMUON	TO R_THUTHU
GRANT INSERT, UPDATE ON PHIEUPHAT	TO R_THUTHU
GRANT INSERT, UPDATE ON CUONSACH	TO R_THUTHU
GRANT INSERT, UPDATE ON DAUSACH		TO R_THUTHU
GRANT EXECUTE ON SP_THEMDOCGIA		TO R_THUTHU
GRANT EXECUTE ON SP_TIMSACH			TO R_THUTHU
GRANT EXECUTE ON SP_LAPPHIEUMUON	TO R_THUTHU
GRANT EXECUTE ON SP_TRASACH			TO R_THUTHU
GRANT EXECUTE ON SP_THANHTOANPHAT	TO R_THUTHU
GRANT EXECUTE ON SP_CURSOR_NHACNHOQUAHAN TO R_THUTHU
DENY DELETE ON SCHEMA::dbo			TO R_THUTHU
DENY SELECT ON TAIKHOAN				TO R_THUTHU
DENY INSERT, UPDATE ON NHANVIEN		TO R_THUTHU
GO

-- DOC GIA: chi tra cuu danh muc sach, khong xem thong tin ca nhan nguoi khac,
--          khong duoc them / sua / xoa
GRANT SELECT ON DAUSACH			TO R_DOCGIA
GRANT SELECT ON THELOAI			TO R_DOCGIA
GRANT SELECT ON TACGIA			TO R_DOCGIA
GRANT SELECT ON DAUSACH_TACGIA	TO R_DOCGIA
GRANT SELECT ON NHAXUATBAN		TO R_DOCGIA
GRANT SELECT ON CUONSACH (MACS, MADS, VITRI, TINHTRANG) TO R_DOCGIA	-- phan quyen muc cot
GRANT EXECUTE ON SP_TIMSACH		TO R_DOCGIA
DENY SELECT ON DOCGIA			TO R_DOCGIA
DENY SELECT ON NHANVIEN			TO R_DOCGIA
DENY SELECT ON TAIKHOAN			TO R_DOCGIA
DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO R_DOCGIA
GO

-- Minh hoa REVOKE: cap roi thu hoi quyen xem phieu phat cua doc gia
GRANT SELECT ON PHIEUPHAT TO R_DOCGIA
REVOKE SELECT ON PHIEUPHAT FROM R_DOCGIA
GO

/* B.5 Kiem tra phan quyen (chay thu voi tu cach tung user)
EXECUTE AS USER = 'U_THUTHU'
	SELECT TOP 3 * FROM DOCGIA				-- duoc phep
	DELETE FROM PHIEUPHAT WHERE MAPP = 'PP0001'	-- bi tu choi (DENY DELETE)
REVERT

EXECUTE AS USER = 'U_DOCGIA'
	EXEC SP_TIMSACH N'Harry'				-- duoc phep
	SELECT * FROM DOCGIA					-- bi tu choi (DENY SELECT)
REVERT

-- Xem quyen hien tai cua cac role
SELECT pr.name AS ROLE_NAME, pe.permission_name, pe.state_desc,
	   OBJECT_NAME(pe.major_id) AS DOITUONG
FROM sys.database_permissions pe
	JOIN sys.database_principals pr ON pe.grantee_principal_id = pr.principal_id
WHERE pr.name IN ('R_QUANLY', 'R_THUTHU', 'R_DOCGIA')
ORDER BY pr.name, DOITUONG
*/

/* =====================================================================
   C. IMPORT / EXPORT
   ===================================================================== */

/* C.1 IMPORT danh sach doc gia moi tu file CSV
   File mau: database/data/DOCGIA_IMPORT.csv - ma hoa UTF-16 (Unicode), xuong
   dong CRLF, dong dau la tieu de. Day la dinh dang Excel xuat ra khi chon
   "Save As > Unicode Text" / "CSV UTF-16", giu duoc tieng Viet co dau tren
   ca SQL Server Windows lan Linux (DATAFILETYPE = 'widechar').
   Duong dan la duong dan TREN MAY CHAY SQL SERVER. Voi Docker:
     docker cp database/data/DOCGIA_IMPORT.csv <container>:/tmp/DOCGIA_IMPORT.csv

CREATE TABLE #DOCGIA_IMPORT
(
	MADG NVARCHAR(5), HOTEN NVARCHAR(40), NGSINH DATE, GIOITINH NVARCHAR(3),
	DIACHI NVARCHAR(100), SODT NVARCHAR(15), EMAIL NVARCHAR(50)
)

BULK INSERT #DOCGIA_IMPORT
FROM '/tmp/DOCGIA_IMPORT.csv'			-- Windows: 'C:\Data\DOCGIA_IMPORT.csv'
WITH (FORMAT = 'CSV', DATAFILETYPE = 'widechar', FIRSTROW = 2,
	  FIELDTERMINATOR = ',', ROWTERMINATOR = '\r\n')

-- Chi them nhung doc gia chua ton tai (rang buoc CHECK / FK van duoc kiem tra)
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN)
SELECT MADG, HOTEN, NGSINH, GIOITINH, NULLIF(DIACHI, ''), SODT, NULLIF(EMAIL, '')
	   CAST(GETDATE() AS DATE), DATEADD(YEAR, 2, CAST(GETDATE() AS DATE))
FROM #DOCGIA_IMPORT I
WHERE NOT EXISTS (SELECT * FROM DOCGIA DG WHERE DG.MADG = I.MADG COLLATE DATABASE_DEFAULT)

DROP TABLE #DOCGIA_IMPORT
*/

/* C.2 EXPORT du lieu ra file CSV bang cong cu bcp (chay tren command line):

bcp "SELECT MADS, TENDS, SOLUONG, SLCON FROM QUANLYTHUVIEN.dbo.DAUSACH" queryout DAUSACH.csv -c -C 65001 -t, -S localhost,1444 -U sa -P "<mat khau>"

   Hoac dung giao dien SSMS: chuot phai CSDL > Tasks > Export Data... > chon
   Destination = Microsoft Excel / Flat File.
*/

/* =====================================================================
   D. BACKUP / RESTORE
   ===================================================================== */

/* SP sao luu CSDL (goi tu ung dung). Loai: 'FULL' hoac 'DIFF' */
CREATE PROCEDURE SP_SAOLUU
	@DUONGDAN	NVARCHAR(260),
	@LOAI		VARCHAR(4) = 'FULL'
AS
BEGIN
	SET NOCOUNT ON
	IF @LOAI = 'DIFF'
		BACKUP DATABASE QUANLYTHUVIEN TO DISK = @DUONGDAN
		WITH DIFFERENTIAL, INIT, NAME = N'QUANLYTHUVIEN - Differential Backup'
	ELSE
		BACKUP DATABASE QUANLYTHUVIEN TO DISK = @DUONGDAN
		WITH INIT, NAME = N'QUANLYTHUVIEN - Full Backup'

	-- Lich su sao luu
	SELECT TOP 10 bs.backup_start_date, bs.backup_finish_date,
		   CASE bs.type WHEN 'D' THEN 'FULL' WHEN 'I' THEN 'DIFF' WHEN 'L' THEN 'LOG' END AS LOAI,
		   bmf.physical_device_name AS DUONGDAN,
		   CAST(bs.backup_size / 1024.0 / 1024 AS DECIMAL(10, 2)) AS DUNGLUONG_MB
	FROM msdb.dbo.backupset bs
		JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
	WHERE bs.database_name = 'QUANLYTHUVIEN'
	ORDER BY bs.backup_start_date DESC
END
GO
GRANT EXECUTE ON SP_SAOLUU TO R_QUANLY
GO

/* D.1 Sao luu bang cau lenh
   Windows: N'C:\Backup\QUANLYTHUVIEN_FULL.bak'
   Linux / Docker: N'/var/opt/mssql/data/QUANLYTHUVIEN_FULL.bak'

BACKUP DATABASE QUANLYTHUVIEN
TO DISK = N'/var/opt/mssql/data/QUANLYTHUVIEN_FULL.bak'
WITH INIT, NAME = N'QUANLYTHUVIEN - Full Backup'

BACKUP DATABASE QUANLYTHUVIEN
TO DISK = N'/var/opt/mssql/data/QUANLYTHUVIEN_DIFF.bak'
WITH DIFFERENTIAL, INIT, NAME = N'QUANLYTHUVIEN - Differential Backup'
*/

/* D.2 Xoa va phuc hoi CSDL tu file backup (FULL + DIFF)

USE master
GO
ALTER DATABASE QUANLYTHUVIEN SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE QUANLYTHUVIEN
GO

RESTORE DATABASE QUANLYTHUVIEN
FROM DISK = N'/var/opt/mssql/data/QUANLYTHUVIEN_FULL.bak'
WITH NORECOVERY, REPLACE

RESTORE DATABASE QUANLYTHUVIEN
FROM DISK = N'/var/opt/mssql/data/QUANLYTHUVIEN_DIFF.bak'
WITH RECOVERY
GO

-- Sau khi restore, USER trong CSDL can duoc noi lai voi LOGIN (neu restore sang server khac)
USE QUANLYTHUVIEN
GO
ALTER USER U_QUANLY WITH LOGIN = LG_QUANLY
ALTER USER U_THUTHU WITH LOGIN = LG_THUTHU
ALTER USER U_DOCGIA WITH LOGIN = LG_DOCGIA
*/

GO


/* ==================== CONTENT OF 8_Report.sql ==================== */

/* =====================================================================
   File   : 08_Report.sql
   Noi dung: Cac VIEW lam nguon du lieu cho REPORT (Power BI / Tableau /
             Web demo). Moi view tuong ung 1 report.
   ===================================================================== */

USE QUANLYTHUVIEN
GO

/* ---------------------------------------------------------------------
   REPORT 1. Tinh trang kho sach theo dau sach
   (Bang so lieu + bieu do cot chong: Co san / Dang muon / Hu hong / Mat)
   --------------------------------------------------------------------- */
CREATE VIEW VW_BC_TINHTRANGKHO
AS
SELECT	ROW_NUMBER() OVER (ORDER BY TL.TENTL, DS.TENDS) AS STT,
		DS.MADS, DS.TENDS, TL.TENTL,
		COUNT(CS.MACS) AS TONGSO,
		SUM(CASE WHEN CS.TINHTRANG = N'Có sẵn'		THEN 1 ELSE 0 END) AS COSAN,
		SUM(CASE WHEN CS.TINHTRANG = N'Đang mượn'	THEN 1 ELSE 0 END) AS DANGMUON,
		SUM(CASE WHEN CS.TINHTRANG = N'Hư hỏng'		THEN 1 ELSE 0 END) AS HUHONG,
		SUM(CASE WHEN CS.TINHTRANG = N'Mất'			THEN 1 ELSE 0 END) AS MAT
FROM DAUSACH DS
	JOIN THELOAI TL ON DS.MATL = TL.MATL
	LEFT JOIN CUONSACH CS ON DS.MADS = CS.MADS
GROUP BY DS.MADS, DS.TENDS, TL.TENTL
GO

/* ---------------------------------------------------------------------
   REPORT 2. Xep hang dau sach duoc muon nhieu nhat
   (Bieu do cot ngang top sach)
   --------------------------------------------------------------------- */
CREATE VIEW VW_BC_SACHMUONNHIEU
AS
SELECT	RANK() OVER (ORDER BY COUNT(CT.MAPM) DESC) AS HANG,
		DS.MADS, DS.TENDS, TL.TENTL,
		COUNT(CT.MAPM) AS SOLUOTMUON,
		COUNT(DISTINCT PM.MADG) AS SODOCGIA
FROM DAUSACH DS
	JOIN THELOAI TL ON DS.MATL = TL.MATL
	LEFT JOIN CUONSACH CS ON DS.MADS = CS.MADS
	LEFT JOIN CTPHIEUMUON CT ON CS.MACS = CT.MACS
	LEFT JOIN PHIEUMUON PM ON CT.MAPM = PM.MAPM
GROUP BY DS.MADS, DS.TENDS, TL.TENTL
GO

/* ---------------------------------------------------------------------
   REPORT 3. Luot muon theo thang va the loai
   (Bieu do duong: truc X = thang, truc Y = so luot, moi duong = 1 the loai)
   --------------------------------------------------------------------- */
CREATE VIEW VW_BC_LUOTMUON_THANG
AS
SELECT	YEAR(PM.NGAYMUON) AS NAM,
		MONTH(PM.NGAYMUON) AS THANG,
		TL.TENTL,
		COUNT(*) AS SOLUOTMUON
FROM CTPHIEUMUON CT
	JOIN PHIEUMUON PM ON CT.MAPM = PM.MAPM
	JOIN CUONSACH CS ON CT.MACS = CS.MACS
	JOIN DAUSACH DS ON CS.MADS = DS.MADS
	JOIN THELOAI TL ON DS.MATL = TL.MATL
GROUP BY YEAR(PM.NGAYMUON), MONTH(PM.NGAYMUON), TL.TENTL
GO

/* ---------------------------------------------------------------------
   REPORT 4. Tien phat theo thang va ly do
   (Bieu do tron ty le ly do phat + bang tong hop da thu / chua thu)
   --------------------------------------------------------------------- */
CREATE VIEW VW_BC_TIENPHAT_THANG
AS
SELECT	YEAR(NGAYLAP) AS NAM,
		MONTH(NGAYLAP) AS THANG,
		LYDO,
		COUNT(*) AS SOPHIEU,
		SUM(SOTIEN) AS TONGTIEN,
		SUM(CASE WHEN DATHANHTOAN = 1 THEN SOTIEN ELSE 0 END) AS DATHU,
		SUM(CASE WHEN DATHANHTOAN = 0 THEN SOTIEN ELSE 0 END) AS CHUATHU
FROM PHIEUPHAT
GROUP BY YEAR(NGAYLAP), MONTH(NGAYLAP), LYDO
GO

/* ---------------------------------------------------------------------
   REPORT 5. Danh sach doc gia dang giu sach qua han (tinh den hom nay)
   (Bang canh bao, sap xep theo so ngay tre giam dan)
   --------------------------------------------------------------------- */
CREATE VIEW VW_BC_DOCGIA_QUAHAN
AS
SELECT	ROW_NUMBER() OVER (ORDER BY DATEDIFF(DAY, PM.HANTRA, GETDATE()) DESC, DG.MADG) AS STT,
		DG.MADG, DG.HOTEN, DG.SODT,
		PM.MAPM, DS.TENDS, PM.NGAYMUON, PM.HANTRA,
		DATEDIFF(DAY, PM.HANTRA, GETDATE()) AS SONGAYTRE,
		dbo.FN_TIENPHATTRE(PM.HANTRA, CAST(GETDATE() AS DATE)) AS TIENPHATTAMTINH
FROM CTPHIEUMUON CT
	JOIN PHIEUMUON PM ON CT.MAPM = PM.MAPM
	JOIN DOCGIA DG ON PM.MADG = DG.MADG
	JOIN CUONSACH CS ON CT.MACS = CS.MACS
	JOIN DAUSACH DS ON CS.MADS = DS.MADS
WHERE CT.NGAYTRA IS NULL AND PM.HANTRA < CAST(GETDATE() AS DATE)
GO

/* ---------------------------------------------------------------------
   REPORT 6. Hieu suat nhan vien: so phieu muon va so sach da xu ly
   theo thang cua tung thu thu
   --------------------------------------------------------------------- */
CREATE VIEW VW_BC_HIEUSUAT_NHANVIEN
AS
SELECT	NV.MANV, NV.HOTEN,
		YEAR(PM.NGAYMUON) AS NAM,
		MONTH(PM.NGAYMUON) AS THANG,
		COUNT(DISTINCT PM.MAPM) AS SOPHIEU,
		COUNT(CT.MACS) AS SOSACH
FROM NHANVIEN NV
	JOIN PHIEUMUON PM ON NV.MANV = PM.MANV
	JOIN CTPHIEUMUON CT ON PM.MAPM = CT.MAPM
GROUP BY NV.MANV, NV.HOTEN, YEAR(PM.NGAYMUON), MONTH(PM.NGAYMUON)
GO

GRANT SELECT ON VW_BC_TINHTRANGKHO		TO R_QUANLY, R_THUTHU
GRANT SELECT ON VW_BC_SACHMUONNHIEU		TO R_QUANLY, R_THUTHU, R_DOCGIA
GRANT SELECT ON VW_BC_LUOTMUON_THANG	TO R_QUANLY, R_THUTHU
GRANT SELECT ON VW_BC_TIENPHAT_THANG	TO R_QUANLY
GRANT SELECT ON VW_BC_DOCGIA_QUAHAN		TO R_QUANLY, R_THUTHU
GRANT SELECT ON VW_BC_HIEUSUAT_NHANVIEN	TO R_QUANLY
GO

/* ---------------------- VI DU SU DUNG ------------------------------
SELECT * FROM VW_BC_TINHTRANGKHO ORDER BY STT
SELECT * FROM VW_BC_SACHMUONNHIEU ORDER BY HANG
SELECT * FROM VW_BC_LUOTMUON_THANG ORDER BY NAM, THANG, TENTL
SELECT * FROM VW_BC_TIENPHAT_THANG ORDER BY NAM, THANG, LYDO
SELECT * FROM VW_BC_DOCGIA_QUAHAN ORDER BY STT
SELECT * FROM VW_BC_HIEUSUAT_NHANVIEN ORDER BY NAM, THANG, MANV
--------------------------------------------------------------------- */

GO
