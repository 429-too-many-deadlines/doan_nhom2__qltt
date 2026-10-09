
/* ==================== CONTENT OF 1_TaoBang.sql ==================== */

/* =====================================================================
   DO AN MON HOC IE103 - QUAN LY THONG TIN
   De tai : QUAN LY THU VIEN
   File   : 01_TaoBang.sql
   Noi dung: Tao CSDL, tao bang, khoa chinh, khoa ngoai, rang buoc
   ===================================================================== */

USE master
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
   10. PHIEUMUON(MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG)
   --------------------------------------------------------------------- */
CREATE TABLE PHIEUMUON
(
	MAPM		CHAR(6)			PRIMARY KEY,
	MADG		CHAR(5)			NOT NULL FOREIGN KEY REFERENCES DOCGIA (MADG),
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
   13. TAIKHOAN(TENDANGNHAP, MATKHAU, TRANGTHAI)
       Dung cho chuc nang xac thuc cua ung dung. Mat khau duoc bam SHA2_256
       khong luu mat khau goc.
   --------------------------------------------------------------------- */
CREATE TABLE TAIKHOAN
(
	TENDANGNHAP	VARCHAR(30)			PRIMARY KEY,
	MATKHAU		VARBINARY(32)		NOT NULL,
	TRANGTHAI	BIT					NOT NULL DEFAULT 1
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

/*NHAP DU LIEU PHIEUMUON*/
INSERT INTO PHIEUMUON VALUES ('PM0001', 'DG001', '2026-06-15', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0002', 'DG002', '2026-06-19', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0003', 'DG007', '2026-07-10', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0004', 'DG003', '2026-07-04', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0005', 'DG009', '2026-07-15', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0006', 'DG005', '2026-07-31', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0007', 'DG008', '2026-08-14', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0008', 'DG010', '2026-08-15', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0009', 'DG006', '2026-08-19', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0010', 'DG011', '2026-09-10', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0011', 'DG001', '2026-09-15', N'Đang mượn')
INSERT INTO PHIEUMUON VALUES ('PM0012', 'DG004', '2026-09-24', N'Đang mượn')
INSERT INTO PHIEUMUON VALUES ('PM0013', 'DG007', '2026-10-15', N'Đang mượn')
INSERT INTO PHIEUMUON VALUES ('PM0014', 'DG014', '2026-10-04', N'Đang mượn')
INSERT INTO PHIEUMUON VALUES ('PM0015', 'DG013', '2026-09-29', N'Đang mượn')
INSERT INTO PHIEUMUON VALUES ('PM0016', 'DG002', '2026-10-08', N'Đang mượn')
INSERT INTO PHIEUMUON VALUES ('PM0017', 'DG003', '2026-07-24', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0018', 'DG010', '2026-07-15', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0019', 'DG015', '2026-08-24', N'Đã trả')
INSERT INTO PHIEUMUON VALUES ('PM0020', 'DG011', '2026-07-06', N'Đã trả')

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
CREATE OR ALTER PROCEDURE SP_THEMDOCGIA
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
CREATE OR ALTER PROCEDURE SP_TIMSACH
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
   Tham so vao : MADG, danh sach ma cuon sach cach nhau boi dau phay
                 (VD: 'CS001,CS010').
   Tham so ra  : MAPM vua tao.
   - Ma phieu tu tang, han tra = ngay muon + so ngay muon cua loai doc gia.
   - Cac rang buoc (the con han, khong no, so sach toi da, sach co san)
     do TRG_PHIEUMUON_KIEMTRA va TRG_CTPM_MUONSACH kiem tra.
   - Tat ca trong 1 transaction: loi o bat ky cuon nao thi huy toan bo.
   Tra ve: 1 thanh cong, 0 that bai.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE SP_LAPPHIEUMUON
@MADG CHAR (5), @DSMACS VARCHAR (200), @MAPM CHAR (6) OUTPUT
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
			NGAYMUON,
			HANTRA,
			TINHTRANG
		)
		VALUES                 (@MAPM, @MADG, CAST (GETDATE() AS DATE), DATEADD(DAY, @SONGAY, CAST (GETDATE() AS DATE)), N'Đang mượn');
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
CREATE OR ALTER PROCEDURE SP_TRASACH
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
CREATE OR ALTER PROCEDURE SP_THANHTOANPHAT
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
CREATE OR ALTER PROCEDURE SP_THONGKETHANG
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
CREATE OR ALTER PROCEDURE SP_SUADOCGIA
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
CREATE OR ALTER PROCEDURE SP_SUADAUSACH
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
CREATE OR ALTER PROCEDURE SP_THEMDAUSACH
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
CREATE OR ALTER PROCEDURE SP_TIMDOCGIA
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
CREATE OR ALTER PROCEDURE SP_XOADAUSACH
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
CREATE OR ALTER PROCEDURE SP_XOADOCGIA
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
	DELETE FROM DOCGIA WHERE MADG = @MADG

	PRINT N'Xóa độc giả thành công.'
	RETURN 2
END
GO

/* =====================================================================
   STORED PROCEDURES CRUD BO SUNG CHO BACKEND API
   ===================================================================== */

/* ---------------------------------------------------------------------
   SP 13. Them the loai.
   Tham so vao: MATL, TENTL.
   - MATL da ton tai  -> tra ve 0
   - TENTL da ton tai -> tra ve 1
   - Nguoc lai insert -> tra ve 2
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE SP_THEMTHELOAI
	@MATL CHAR(4),
	@TENTL NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS (SELECT 1 FROM THELOAI WHERE MATL = @MATL)
	BEGIN
		PRINT N'Mã thể loại đã tồn tại.';
		RETURN 0;
	END
	IF EXISTS (SELECT 1 FROM THELOAI WHERE TENTL = @TENTL)
	BEGIN
		PRINT N'Tên thể loại đã tồn tại.';
		RETURN 1;
	END
	INSERT INTO THELOAI (MATL, TENTL) VALUES (@MATL, @TENTL);
	PRINT N'Thêm thể loại thành công.';
	RETURN 2;
END
GO

/* ---------------------------------------------------------------------
   SP 14. Sua the loai.
   Tham so vao: MATL, TENTL.
   - MATL khong ton tai                -> tra ve 0
   - TENTL bi trung voi the loai khac  -> tra ve 1
   - Nguoc lai update                  -> tra ve 2
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE SP_SUATHELOAI
	@MATL CHAR(4),
	@TENTL NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	IF NOT EXISTS (SELECT 1 FROM THELOAI WHERE MATL = @MATL)
	BEGIN
		PRINT N'Mã thể loại không tồn tại.';
		RETURN 0;
	END
	IF EXISTS (SELECT 1 FROM THELOAI WHERE TENTL = @TENTL AND MATL <> @MATL)
	BEGIN
		PRINT N'Tên thể loại đã tồn tại.';
		RETURN 1;
	END
	UPDATE THELOAI SET TENTL = @TENTL WHERE MATL = @MATL;
	PRINT N'Cập nhật thể loại thành công.';
	RETURN 2;
END
GO

/* ---------------------------------------------------------------------
   SP 15. Xoa the loai.
   Tham so vao: MATL.
   - MATL khong ton tai       -> tra ve 0
   - Dang co dau sach su dung -> tra ve 1
   - Nguoc lai xoa            -> tra ve 2
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE SP_XOATHELOAI
	@MATL CHAR(4)
AS
BEGIN
	SET NOCOUNT ON;
	IF NOT EXISTS (SELECT 1 FROM THELOAI WHERE MATL = @MATL)
	BEGIN
		PRINT N'Mã thể loại không tồn tại.';
		RETURN 0;
	END
	IF EXISTS (SELECT 1 FROM DAUSACH WHERE MATL = @MATL)
	BEGIN
		PRINT N'Không thể xóa thể loại đang có sách.';
		RETURN 1;
	END
	DELETE FROM THELOAI WHERE MATL = @MATL;
	PRINT N'Xóa thể loại thành công.';
	RETURN 2;
END
GO

/* ---------------------------------------------------------------------
   SP 16. Lay danh sach the loai (ho tro tim kiem va phan trang).
   Tham so vao: TUKHOA, PageNumber, PageSize.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE SP_LAYDANHSACHTHELOAI
	@TUKHOA NVARCHAR(50) = NULL,
	@PageNumber INT = 1,
	@PageSize INT = 10
AS
BEGIN
	SET NOCOUNT ON;
	SELECT MATL, TENTL, COUNT(*) OVER() AS TotalRecord
	FROM THELOAI
	WHERE @TUKHOA IS NULL OR @TUKHOA = ''
	   OR MATL LIKE '%' + @TUKHOA + '%'
	   OR TENTL LIKE N'%' + @TUKHOA + N'%'
	ORDER BY MATL
	OFFSET (@PageNumber - 1) * @PageSize ROWS
	FETCH NEXT @PageSize ROWS ONLY;
END
GO

/* ---------------------------------------------------------------------
   SP 36. Lay danh sach phieu muon kem thong tin (phan trang).
   Tham so vao: PageNumber, PageSize.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE SP_LAYDANHSACHPHIEUMUON
	@PageNumber INT = 1,
	@PageSize INT = 10
AS
BEGIN
	SET NOCOUNT ON;
	SELECT PM.MAPM, PM.MADG, DG.HOTEN AS TENDG, PM.NGAYMUON, PM.HANTRA, PM.TINHTRANG,
	       CT.MACS, CT.NGAYTRA, CT.TINHTRANGTRA,
	       COUNT(*) OVER() AS TotalRecord
	FROM PHIEUMUON PM
	LEFT JOIN DOCGIA DG ON PM.MADG = DG.MADG
	LEFT JOIN CTPHIEUMUON CT ON PM.MAPM = CT.MAPM
	ORDER BY PM.NGAYMUON DESC, PM.MAPM DESC
	OFFSET (@PageNumber - 1) * @PageSize ROWS
	FETCH NEXT @PageSize ROWS ONLY;
END
GO

/* ---------------------------------------------------------------------
   SP 37. Lay danh sach phieu phat kem thong tin doc gia (phan trang).
   Tham so vao: PageNumber, PageSize.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE SP_LAYDANHSACHPHIEUPHAT
	@PageNumber INT = 1,
	@PageSize INT = 10
AS
BEGIN
	SET NOCOUNT ON;
	SELECT PP.MAPP, PP.MAPM, PM.MADG, DG.HOTEN AS TENDG, PP.MACS, PP.NGAYLAP, PP.LYDO, PP.SOTIEN, PP.DATHANHTOAN,
	       COUNT(*) OVER() AS TotalRecord
	FROM PHIEUPHAT PP
	INNER JOIN CTPHIEUMUON CT ON PP.MAPM = CT.MAPM AND PP.MACS = CT.MACS
	INNER JOIN PHIEUMUON PM ON CT.MAPM = PM.MAPM
	LEFT JOIN DOCGIA DG ON PM.MADG = DG.MADG
	ORDER BY PP.NGAYLAP DESC, PP.MAPP DESC
	OFFSET (@PageNumber - 1) * @PageSize ROWS
	FETCH NEXT @PageSize ROWS ONLY;
END
GO
/* ---------------------------------------------------------------------
   SP 38. Lay danh sach nha xuat ban (phan trang).
   Tham so vao: TUKHOA, PageNumber, PageSize.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE SP_LAYDANHSACHNHAXUATBAN
	@TUKHOA NVARCHAR(100) = NULL,
	@PageNumber INT = 1,
	@PageSize INT = 10
AS
BEGIN
	SET NOCOUNT ON;
	SELECT MANXB, TENNXB, DIACHI, SODT, COUNT(*) OVER() AS TotalRecord
	FROM NHAXUATBAN
	WHERE @TUKHOA IS NULL OR @TUKHOA = ''
	   OR MANXB LIKE '%' + @TUKHOA + '%'
	   OR TENNXB LIKE N'%' + @TUKHOA + N'%'
	ORDER BY MANXB
	OFFSET (@PageNumber - 1) * @PageSize ROWS
	FETCH NEXT @PageSize ROWS ONLY;
END
GO

/* ---------------------------------------------------------------------
   SP 39. Lay danh sach tac gia (phan trang).
   Tham so vao: TUKHOA, PageNumber, PageSize.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE SP_LAYDANHSACHTACGIA
	@TUKHOA NVARCHAR(100) = NULL,
	@PageNumber INT = 1,
	@PageSize INT = 10
AS
BEGIN
	SET NOCOUNT ON;
	SELECT MATG, TENTG, NAMSINH, QUOCTICH, COUNT(*) OVER() AS TotalRecord
	FROM TACGIA
	WHERE @TUKHOA IS NULL OR @TUKHOA = ''
	   OR MATG LIKE '%' + @TUKHOA + '%'
	   OR TENTG LIKE N'%' + @TUKHOA + N'%'
	ORDER BY MATG
	OFFSET (@PageNumber - 1) * @PageSize ROWS
	FETCH NEXT @PageSize ROWS ONLY;
END
GO

/* ---------------------------------------------------------------------
   SP 40. Them nha xuat ban.
   Tham so vao: MANXB, TENNXB, DIACHI, SODT.
   - MANXB da ton tai       -> tra ve 0
   - TENNXB da ton tai      -> tra ve 1
   - Nguoc lai insert       -> tra ve 2
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE SP_THEMNHAXUATBAN
	@MANXB CHAR(5),
	@TENNXB NVARCHAR(100),
	@DIACHI NVARCHAR(200) = NULL,
	@SODT VARCHAR(15) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS (SELECT 1 FROM NHAXUATBAN WHERE MANXB = @MANXB)
	BEGIN
		PRINT N'Mã nhà xuất bản đã tồn tại.';
		RETURN 0;
	END
	IF EXISTS (SELECT 1 FROM NHAXUATBAN WHERE TENNXB = @TENNXB)
	BEGIN
		PRINT N'Tên nhà xuất bản đã tồn tại.';
		RETURN 1;
	END

	INSERT INTO NHAXUATBAN (MANXB, TENNXB, DIACHI, SODT) 
	VALUES (@MANXB, @TENNXB, @DIACHI, @SODT);

	PRINT N'Thêm nhà xuất bản thành công.';
	RETURN 2;
END
GO


/* ---------------------------------------------------------------------
   SP 41. Sua nha xuat ban.
   Tham so vao: MANXB, TENNXB, DIACHI, SODT.
   - MANXB khong ton tai                -> tra ve 0
   - TENNXB bi trung voi nxb khac       -> tra ve 1
   - Nguoc lai update                   -> tra ve 2
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE SP_SUANHAXUATBAN
	@MANXB CHAR(5),
	@TENNXB NVARCHAR(100),
	@DIACHI NVARCHAR(200) = NULL,
	@SODT VARCHAR(15) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	IF NOT EXISTS (SELECT 1 FROM NHAXUATBAN WHERE MANXB = @MANXB)
	BEGIN
		PRINT N'Mã nhà xuất bản không tồn tại.';
		RETURN 0;
	END
	IF EXISTS (SELECT 1 FROM NHAXUATBAN WHERE TENNXB = @TENNXB AND MANXB != @MANXB)
	BEGIN
		PRINT N'Tên nhà xuất bản đã tồn tại.';
		RETURN 1;
	END

	UPDATE NHAXUATBAN
	SET TENNXB = @TENNXB,
	    DIACHI = @DIACHI,
	    SODT = @SODT
	WHERE MANXB = @MANXB;

	PRINT N'Sửa nhà xuất bản thành công.';
	RETURN 2;
END
GO

/* ---------------------------------------------------------------------
   SP 42. Xoa nha xuat ban.
   Tham so vao: MANXB.
   - MANXB khong ton tai                -> tra ve 0
   - MANXB da co DAUSACH                -> tra ve 1
   - Nguoc lai xoa                      -> tra ve 2
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE SP_XOANHAXUATBAN
	@MANXB CHAR(5)
AS
BEGIN
	SET NOCOUNT ON;
	IF NOT EXISTS (SELECT 1 FROM NHAXUATBAN WHERE MANXB = @MANXB)
	BEGIN
		PRINT N'Mã nhà xuất bản không tồn tại.';
		RETURN 0;
	END
	IF EXISTS (SELECT 1 FROM DAUSACH WHERE MANXB = @MANXB)
	BEGIN
		PRINT N'Nhà xuất bản đã có đầu sách, không thể xoá.';
		RETURN 1;
	END

	DELETE FROM NHAXUATBAN WHERE MANXB = @MANXB;

	PRINT N'Xoá nhà xuất bản thành công.';
	RETURN 2;
END
GO

CREATE OR ALTER PROCEDURE SP_THEMTACGIA
	@MATG CHAR(5),
	@TENTG NVARCHAR(50),
	@NAMSINH INT,
	@QUOCTICH NVARCHAR(30)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM TACGIA WHERE MATG = @MATG)
		RETURN 0
	IF @NAMSINH IS NOT NULL AND @NAMSINH > YEAR(GETDATE())
		RETURN 1
	INSERT INTO TACGIA (MATG, TENTG, NAMSINH, QUOCTICH) VALUES (@MATG, @TENTG, @NAMSINH, @QUOCTICH)
	RETURN 2
END
GO

CREATE OR ALTER PROCEDURE SP_SUATACGIA
	@MATG CHAR(5),
	@TENTG NVARCHAR(50),
	@NAMSINH INT,
	@QUOCTICH NVARCHAR(30)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM TACGIA WHERE MATG = @MATG)
		RETURN 0
	IF @NAMSINH IS NOT NULL AND @NAMSINH > YEAR(GETDATE())
		RETURN 1
	UPDATE TACGIA SET TENTG = @TENTG, NAMSINH = @NAMSINH, QUOCTICH = @QUOCTICH WHERE MATG = @MATG
	RETURN 2
END
GO

CREATE OR ALTER PROCEDURE SP_XOATACGIA
	@MATG CHAR(5)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM TACGIA WHERE MATG = @MATG)
		RETURN 0
	IF EXISTS (SELECT 1 FROM DAUSACH_TACGIA WHERE MATG = @MATG)
		RETURN 1
	DELETE FROM TACGIA WHERE MATG = @MATG
	RETURN 2
END
GO

CREATE OR ALTER PROCEDURE SP_THEMCUONSACH
	@MACS CHAR(5),
	@MADS CHAR(5),
	@VITRI NVARCHAR(20),
	@TINHTRANG NVARCHAR(20)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM CUONSACH WHERE MACS = @MACS)
		RETURN 0
	IF NOT EXISTS (SELECT 1 FROM DAUSACH WHERE MADS = @MADS)
		RETURN 1
	INSERT INTO CUONSACH (MACS, MADS, VITRI, TINHTRANG, NGAYNHAP) VALUES (@MACS, @MADS, @VITRI, @TINHTRANG, GETDATE())
	RETURN 3
END
GO

CREATE OR ALTER PROCEDURE SP_SUACUONSACH
	@MACS CHAR(5),
	@VITRI NVARCHAR(20),
	@TINHTRANG NVARCHAR(20)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM CUONSACH WHERE MACS = @MACS)
		RETURN 0
	UPDATE CUONSACH SET VITRI = @VITRI, TINHTRANG = @TINHTRANG WHERE MACS = @MACS
	RETURN 2
END
GO

CREATE OR ALTER PROCEDURE SP_XOACUONSACH
	@MACS CHAR(5)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM CUONSACH WHERE MACS = @MACS)
		RETURN 0
	IF EXISTS (SELECT 1 FROM CTPHIEUMUON WHERE MACS = @MACS)
		RETURN 1
	DELETE FROM CUONSACH WHERE MACS = @MACS
	RETURN 2
END
GO

CREATE OR ALTER PROCEDURE SP_LAYCUONSACHTHEODAUSACH
	@MADS CHAR(5)
AS
BEGIN
	SET NOCOUNT ON
	SELECT MACS, MADS, NGAYNHAP, VITRI, TINHTRANG FROM CUONSACH WHERE MADS = @MADS ORDER BY MACS
END
GO

CREATE OR ALTER PROCEDURE SP_LAYTACGIATHEODAUSACH
	@MADS CHAR(5)
AS
BEGIN
	SET NOCOUNT ON
	SELECT DT.MATG, T.TENTG, DT.VAITRO FROM DAUSACH_TACGIA DT JOIN TACGIA T ON DT.MATG = T.MATG WHERE DT.MADS = @MADS
END
GO

CREATE OR ALTER PROCEDURE SP_THEMTACGIADAUSACH
	@MADS CHAR(5),
	@MATG CHAR(5),
	@VAITRO NVARCHAR(20)
AS
BEGIN
	INSERT INTO DAUSACH_TACGIA (MADS, MATG, VAITRO) VALUES (@MADS, @MATG, @VAITRO)
END
GO

CREATE OR ALTER PROCEDURE SP_XOATACGIADAUSACH
	@MADS CHAR(5)
AS
BEGIN
	DELETE FROM DAUSACH_TACGIA WHERE MADS = @MADS
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


/* SP dang nhap. Tra ve thong tin tai khoan neu dung, nguoc lai bang rong.
   Tham so ra @KETQUA: 0 sai ten/mat khau, 1 tai khoan bi khoa, 2 thanh cong */
CREATE OR ALTER PROCEDURE SP_DANGNHAP
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
		SELECT TOP 0 TENDANGNHAP FROM TAIKHOAN
		RETURN
	END

	IF EXISTS (SELECT * FROM TAIKHOAN WHERE TENDANGNHAP = @TENDANGNHAP AND TRANGTHAI = 0)
	BEGIN
		SET @KETQUA = 1
		SELECT TOP 0 TENDANGNHAP FROM TAIKHOAN
		RETURN
	END

	SET @KETQUA = 2
	SELECT TENDANGNHAP, 'Admin' AS HOTEN 
	FROM TAIKHOAN 
	WHERE TENDANGNHAP = @TENDANGNHAP
END
GO

/* SP doi mat khau. Tra ve 0: sai mat khau cu, 1: thanh cong */
CREATE OR ALTER PROCEDURE SP_DOIMATKHAU
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



INSERT INTO TAIKHOAN (TENDANGNHAP, MATKHAU) VALUES ('admin', HASHBYTES('SHA2_256', '123456'))










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
SELECT MADG, HOTEN, NGSINH, GIOITINH, NULLIF(DIACHI, ''), SODT, NULLIF(EMAIL, ''),
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
CREATE OR ALTER PROCEDURE SP_SAOLUU
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

GRANT SELECT ON VW_BC_TINHTRANGKHO		TO R_QUANLY, R_THUTHU
GRANT SELECT ON VW_BC_SACHMUONNHIEU		TO R_QUANLY, R_THUTHU, R_DOCGIA
GRANT SELECT ON VW_BC_LUOTMUON_THANG	TO R_QUANLY, R_THUTHU
GRANT SELECT ON VW_BC_TIENPHAT_THANG	TO R_QUANLY
GRANT SELECT ON VW_BC_DOCGIA_QUAHAN		TO R_QUANLY, R_THUTHU
GO

/* ---------------------- VI DU SU DUNG ------------------------------
SELECT * FROM VW_BC_TINHTRANGKHO ORDER BY STT
SELECT * FROM VW_BC_SACHMUONNHIEU ORDER BY HANG
SELECT * FROM VW_BC_LUOTMUON_THANG ORDER BY NAM, THANG, TENTL
SELECT * FROM VW_BC_TIENPHAT_THANG ORDER BY NAM, THANG, LYDO
SELECT * FROM VW_BC_DOCGIA_QUAHAN ORDER BY STT
--------------------------------------------------------------------- */

GO

/* ==================== CONTENT OF 9_DuLieuThem2026.sql ==================== */

/* =====================================================================
   File   : 9_DuLieuThem2026.sql
   Noi dung: Nhap them du lieu mau tu 01/01/2026 den 10/2026 (SO LUONG LON)
   ===================================================================== */
USE QUANLYTHUVIEN
GO

/* TAM THOI TAT CAC TRIGGER DE NHAP DU LIEU LICH SU */
ALTER TABLE PHIEUMUON DISABLE TRIGGER ALL;
ALTER TABLE CTPHIEUMUON DISABLE TRIGGER ALL;
ALTER TABLE PHIEUPHAT DISABLE TRIGGER ALL;
ALTER TABLE DOCGIA DISABLE TRIGGER ALL;
ALTER TABLE CUONSACH DISABLE TRIGGER ALL;
ALTER TABLE DAUSACH DISABLE TRIGGER ALL;
GO

/* XOA DU LIEU RAC CUA DOT 3 (NEU CO) */
DELETE FROM PHIEUPHAT WHERE MAPP >= 'PP1000'
DELETE FROM CTPHIEUMUON WHERE MAPM >= 'PM0321'
DELETE FROM PHIEUMUON WHERE MAPM >= 'PM0321'
DELETE FROM DOCGIA WHERE MADG >= 'DG216'
GO

/* 1. THEM 100 DOC GIA MOI DOT 3 */
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG216', N'Lê Kim Nghĩa', '2005-08-20', N'Nam', N'Bình Tân, TpHCM', '0911258976', 'nghĩa.dg216@gmail.com', '2026-06-25', '2028-06-24')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG217', N'Đặng Minh Cường', '1997-12-01', N'Nữ', N'Q7, TpHCM', '0919604492', 'cường.dg217@gmail.com', '2025-12-15', '2027-12-15')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG218', N'Ngô Ngọc Phong', '1975-12-24', N'Nữ', N'Tân Bình, TpHCM', '0914562631', 'phong.dg218@gmail.com', '2025-05-30', '2027-05-30')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG219', N'Hoàng Thị Xuân', '1985-03-13', N'Nữ', N'Q7, TpHCM', '0913168613', 'xuân.dg219@gmail.com', '2026-06-09', '2028-06-08')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG220', N'Huỳnh Ngọc Oanh', '2001-12-07', N'Nam', N'Q9, TpHCM', '0915657467', 'oanh.dg220@gmail.com', '2025-05-09', '2027-05-09')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG221', N'Trần Quang Uyên', '1984-01-30', N'Nam', N'Thủ Đức, TpHCM', '0917894737', 'uyên.dg221@gmail.com', '2026-09-22', '2028-09-21')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG222', N'Võ Đức Hiếu', '2005-11-30', N'Nữ', N'Thủ Đức, TpHCM', '0912547843', 'hiếu.dg222@gmail.com', '2025-02-24', '2027-02-24')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG223', N'Lê Quốc Phúc', '1978-12-21', N'Nam', N'Thủ Đức, TpHCM', '0915713191', 'phúc.dg223@gmail.com', '2026-05-06', '2028-05-05')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG224', N'Lý Hữu Xuân', '1976-01-29', N'Nữ', N'Gò Vấp, TpHCM', '0913322235', 'xuân.dg224@gmail.com', '2026-07-12', '2028-07-11')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG225', N'Nguyễn Ngọc Phúc', '2000-04-09', N'Nữ', N'Q7, TpHCM', '0911763592', 'phúc.dg225@gmail.com', '2026-07-12', '2028-07-11')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG226', N'Hoàng Bảo Phong', '1980-08-16', N'Nữ', N'Q10, TpHCM', '0917411644', 'phong.dg226@gmail.com', '2026-06-01', '2028-05-31')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG227', N'Đỗ Đức Bình', '1983-07-31', N'Nữ', N'Q5, TpHCM', '0917655025', 'bình.dg227@gmail.com', '2025-10-19', '2027-10-19')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG228', N'Phan Văn Linh', '2003-01-28', N'Nam', N'Tân Bình, TpHCM', '0912529016', 'linh.dg228@gmail.com', '2025-02-16', '2027-02-16')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG229', N'Nguyễn Kim Dung', '1995-11-23', N'Nữ', N'Q7, TpHCM', '0916393755', 'dung.dg229@gmail.com', '2025-05-17', '2027-05-17')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG230', N'Vũ Mỹ Tuấn', '1985-02-26', N'Nam', N'Thủ Đức, TpHCM', '0913537877', 'tuấn.dg230@gmail.com', '2025-02-27', '2027-02-27')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG231', N'Phạm Thanh Yến', '1983-03-20', N'Nam', N'Tân Bình, TpHCM', '0916928949', 'yến.dg231@gmail.com', '2026-06-21', '2028-06-20')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG232', N'Hoàng Kim Anh', '1977-11-04', N'Nữ', N'Q9, TpHCM', '0916406497', 'anh.dg232@gmail.com', '2025-04-05', '2027-04-05')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG233', N'Phạm Bảo Yến', '2001-04-07', N'Nữ', N'Q3, TpHCM', '0917065828', 'yến.dg233@gmail.com', '2025-07-03', '2027-07-03')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG234', N'Phạm Minh Nghĩa', '1982-07-01', N'Nữ', N'Q10, TpHCM', '0913529117', 'nghĩa.dg234@gmail.com', '2026-08-31', '2028-08-30')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG235', N'Đặng Văn Nhung', '2005-05-04', N'Nữ', N'Gò Vấp, TpHCM', '0913872849', 'nhung.dg235@gmail.com', '2026-08-18', '2028-08-17')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG236', N'Huỳnh Minh Xuân', '1998-01-16', N'Nữ', N'Q9, TpHCM', '0918489075', 'xuân.dg236@gmail.com', '2026-08-08', '2028-08-07')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG237', N'Đỗ Quốc Dung', '2001-06-26', N'Nữ', N'Q3, TpHCM', '0917100046', 'dung.dg237@gmail.com', '2026-08-29', '2028-08-28')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG238', N'Bùi Quang Đức', '1991-03-01', N'Nữ', N'Q3, TpHCM', '0919794832', 'đức.dg238@gmail.com', '2026-05-25', '2028-05-24')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG239', N'Huỳnh Đức Khang', '1988-08-10', N'Nữ', N'Q7, TpHCM', '0912111109', 'khang.dg239@gmail.com', '2026-07-03', '2028-07-02')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG240', N'Hồ Đức Mai', '1993-08-28', N'Nam', N'Tân Bình, TpHCM', '0916287524', 'mai.dg240@gmail.com', '2026-04-28', '2028-04-27')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG241', N'Vũ Minh Em', '1977-12-14', N'Nữ', N'Tân Bình, TpHCM', '0916149396', 'em.dg241@gmail.com', '2026-07-01', '2028-06-30')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG242', N'Lý Kim Nhung', '1996-10-02', N'Nam', N'Bình Tân, TpHCM', '0919241930', 'nhung.dg242@gmail.com', '2026-05-08', '2028-05-07')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG243', N'Ngô Thanh Tuấn', '2006-06-23', N'Nữ', N'Q9, TpHCM', '0911880800', 'tuấn.dg243@gmail.com', '2026-01-06', '2028-01-06')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG244', N'Bùi Gia Tâm', '1983-07-24', N'Nam', N'Q3, TpHCM', '0918075254', 'tâm.dg244@gmail.com', '2025-10-09', '2027-10-09')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG245', N'Đỗ Đình Cường', '1989-10-07', N'Nam', N'Q9, TpHCM', '0914126294', 'cường.dg245@gmail.com', '2026-09-28', '2028-09-27')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG246', N'Lý Hữu Cường', '2002-06-15', N'Nữ', N'Q9, TpHCM', '0912461467', 'cường.dg246@gmail.com', '2026-05-29', '2028-05-28')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG247', N'Dương Quốc Giang', '2003-09-30', N'Nữ', N'Q9, TpHCM', '0912523604', 'giang.dg247@gmail.com', '2026-07-18', '2028-07-17')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG248', N'Hoàng Hữu Bình', '1997-07-30', N'Nữ', N'Q7, TpHCM', '0918481219', 'bình.dg248@gmail.com', '2025-08-01', '2027-08-01')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG249', N'Đỗ Đức Anh', '2007-09-27', N'Nam', N'Q10, TpHCM', '0912969993', 'anh.dg249@gmail.com', '2025-07-07', '2027-07-07')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG250', N'Võ Hữu Vinh', '1978-03-28', N'Nữ', N'Bình Thạnh, TpHCM', '0919942532', 'vinh.dg250@gmail.com', '2025-04-25', '2027-04-25')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG251', N'Lý Gia Đạt', '1983-04-17', N'Nam', N'Bình Thạnh, TpHCM', '0911516881', 'đạt.dg251@gmail.com', '2025-10-23', '2027-10-23')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG252', N'Hồ Minh Phong', '1981-02-13', N'Nữ', N'Bình Thạnh, TpHCM', '0915869118', 'phong.dg252@gmail.com', '2025-03-30', '2027-03-30')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG253', N'Trần Gia Uyên', '1995-10-06', N'Nữ', N'Gò Vấp, TpHCM', '0911442283', 'uyên.dg253@gmail.com', '2025-04-09', '2027-04-09')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG254', N'Đặng Mỹ Đức', '1975-11-15', N'Nam', N'Tân Bình, TpHCM', '0918783569', 'đức.dg254@gmail.com', '2026-03-19', '2028-03-18')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG255', N'Dương Hữu Tâm', '1980-01-31', N'Nam', N'Tân Bình, TpHCM', '0911725337', 'tâm.dg255@gmail.com', '2026-01-11', '2028-01-11')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG256', N'Bùi Quốc Trang', '1993-07-15', N'Nam', N'Q3, TpHCM', '0911154776', 'trang.dg256@gmail.com', '2026-05-27', '2028-05-26')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG257', N'Dương Tuyết Trang', '1982-08-03', N'Nữ', N'Tân Bình, TpHCM', '0912688926', 'trang.dg257@gmail.com', '2026-08-09', '2028-08-08')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG258', N'Bùi Ngọc Hải', '1993-09-23', N'Nữ', N'Q1, TpHCM', '0914313355', 'hải.dg258@gmail.com', '2026-01-15', '2028-01-15')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG259', N'Nguyễn Bảo Bình', '1985-08-26', N'Nữ', N'Gò Vấp, TpHCM', '0916020901', 'bình.dg259@gmail.com', '2025-11-17', '2027-11-17')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG260', N'Bùi Hữu Khang', '1999-12-09', N'Nam', N'Tân Bình, TpHCM', '0914401682', 'khang.dg260@gmail.com', '2025-10-22', '2027-10-22')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG261', N'Vũ Gia Bình', '1979-12-01', N'Nam', N'Q5, TpHCM', '0912451346', 'bình.dg261@gmail.com', '2026-09-09', '2028-09-08')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG262', N'Võ Văn Dung', '2003-02-24', N'Nam', N'Gò Vấp, TpHCM', '0915765034', 'dung.dg262@gmail.com', '2025-08-18', '2027-08-18')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG263', N'Lê Thị Trí', '1993-02-20', N'Nữ', N'Q7, TpHCM', '0915322469', 'trí.dg263@gmail.com', '2026-07-29', '2028-07-28')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG264', N'Ngô Quang Kiên', '1978-06-16', N'Nữ', N'Q10, TpHCM', '0916327756', 'kiên.dg264@gmail.com', '2026-02-27', '2028-02-27')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG265', N'Ngô Thị Uyên', '2001-02-04', N'Nữ', N'Thủ Đức, TpHCM', '0919503022', 'uyên.dg265@gmail.com', '2026-04-04', '2028-04-03')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG266', N'Bùi Văn Oanh', '2000-06-26', N'Nữ', N'Thủ Đức, TpHCM', '0916650815', 'oanh.dg266@gmail.com', '2025-10-30', '2027-10-30')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG267', N'Ngô Gia Phúc', '2003-03-17', N'Nữ', N'Gò Vấp, TpHCM', '0913321864', 'phúc.dg267@gmail.com', '2025-08-23', '2027-08-23')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG268', N'Nguyễn Đình Trí', '1992-02-03', N'Nữ', N'Thủ Đức, TpHCM', '0914575223', 'trí.dg268@gmail.com', '2026-04-04', '2028-04-03')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG269', N'Phạm Bảo Phong', '1992-03-30', N'Nam', N'Gò Vấp, TpHCM', '0918688455', 'phong.dg269@gmail.com', '2026-01-14', '2028-01-14')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG270', N'Đặng Bảo Tài', '1988-05-30', N'Nam', N'Q1, TpHCM', '0918522611', 'tài.dg270@gmail.com', '2025-02-23', '2027-02-23')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG271', N'Hoàng Ngọc Hải', '1985-05-28', N'Nữ', N'Q9, TpHCM', '0916658871', 'hải.dg271@gmail.com', '2025-02-11', '2027-02-11')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG272', N'Đặng Tuyết Khang', '2002-09-13', N'Nam', N'Gò Vấp, TpHCM', '0915289991', 'khang.dg272@gmail.com', '2026-02-26', '2028-02-26')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG273', N'Ngô Kim Yến', '2007-10-12', N'Nam', N'Q1, TpHCM', '0911505460', 'yến.dg273@gmail.com', '2025-01-21', '2027-01-21')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG274', N'Nguyễn Kim Nghĩa', '1984-01-22', N'Nam', N'Q5, TpHCM', '0919492969', 'nghĩa.dg274@gmail.com', '2026-05-03', '2028-05-02')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG275', N'Trần Mỹ Phong', '1979-02-20', N'Nam', N'Thủ Đức, TpHCM', '0919496604', 'phong.dg275@gmail.com', '2025-11-15', '2027-11-15')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG276', N'Lê Hoài Trí', '1980-06-04', N'Nữ', N'Q10, TpHCM', '0915398284', 'trí.dg276@gmail.com', '2026-02-06', '2028-02-06')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG277', N'Phạm Mỹ Em', '1996-05-23', N'Nữ', N'Q7, TpHCM', '0919506584', 'em.dg277@gmail.com', '2025-12-26', '2027-12-26')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG278', N'Võ Quốc Mai', '1986-10-11', N'Nam', N'Q5, TpHCM', '0916327843', 'mai.dg278@gmail.com', '2026-02-08', '2028-02-08')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG279', N'Huỳnh Đình Dung', '1990-03-19', N'Nam', N'Tân Bình, TpHCM', '0911109782', 'dung.dg279@gmail.com', '2025-09-11', '2027-09-11')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG280', N'Võ Đức Yến', '1987-12-26', N'Nam', N'Q9, TpHCM', '0916105697', 'yến.dg280@gmail.com', '2026-09-02', '2028-09-01')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG281', N'Phạm Bảo Giang', '1987-06-17', N'Nữ', N'Q9, TpHCM', '0915234752', 'giang.dg281@gmail.com', '2026-04-13', '2028-04-12')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG282', N'Hoàng Hoài Xuân', '2006-06-09', N'Nam', N'Q1, TpHCM', '0919305099', 'xuân.dg282@gmail.com', '2026-03-05', '2028-03-04')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG283', N'Ngô Mỹ Kiên', '1999-08-11', N'Nam', N'Q5, TpHCM', '0915169271', 'kiên.dg283@gmail.com', '2025-12-12', '2027-12-12')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG284', N'Trần Đức Anh', '1980-05-31', N'Nữ', N'Gò Vấp, TpHCM', '0913087274', 'anh.dg284@gmail.com', '2025-01-11', '2027-01-11')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG285', N'Hồ Thị Đạt', '1988-01-09', N'Nam', N'Q5, TpHCM', '0916550410', 'đạt.dg285@gmail.com', '2025-06-08', '2027-06-08')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG286', N'Hoàng Quốc Tuấn', '2003-09-21', N'Nam', N'Bình Thạnh, TpHCM', '0914376713', 'tuấn.dg286@gmail.com', '2026-07-10', '2028-07-09')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG287', N'Đặng Hoài Xuân', '1992-04-25', N'Nữ', N'Bình Thạnh, TpHCM', '0919084832', 'xuân.dg287@gmail.com', '2025-03-15', '2027-03-15')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG288', N'Lý Kim Đức', '2002-04-15', N'Nam', N'Bình Thạnh, TpHCM', '0918415981', 'đức.dg288@gmail.com', '2025-07-11', '2027-07-11')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG289', N'Phạm Bảo Uyên', '1991-01-19', N'Nam', N'Bình Tân, TpHCM', '0917330674', 'uyên.dg289@gmail.com', '2026-02-24', '2028-02-24')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG290', N'Phan Bảo Kiên', '1989-02-18', N'Nam', N'Thủ Đức, TpHCM', '0914677621', 'kiên.dg290@gmail.com', '2025-04-07', '2027-04-07')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG291', N'Hoàng Ngọc Em', '1993-05-04', N'Nam', N'Q7, TpHCM', '0911254750', 'em.dg291@gmail.com', '2026-09-26', '2028-09-25')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG292', N'Võ Thanh Uyên', '1985-05-11', N'Nữ', N'Q9, TpHCM', '0917381402', 'uyên.dg292@gmail.com', '2025-07-31', '2027-07-31')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG293', N'Hồ Gia Tài', '2004-09-08', N'Nữ', N'Tân Bình, TpHCM', '0911992391', 'tài.dg293@gmail.com', '2025-06-25', '2027-06-25')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG294', N'Phan Quốc Tuấn', '2006-11-04', N'Nữ', N'Thủ Đức, TpHCM', '0914904602', 'tuấn.dg294@gmail.com', '2025-05-28', '2027-05-28')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG295', N'Ngô Văn Nhung', '1989-10-16', N'Nam', N'Q5, TpHCM', '0916847146', 'nhung.dg295@gmail.com', '2026-02-02', '2028-02-02')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG296', N'Ngô Văn Hiếu', '2001-03-31', N'Nam', N'Bình Thạnh, TpHCM', '0912600737', 'hiếu.dg296@gmail.com', '2025-12-12', '2027-12-12')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG297', N'Vũ Ngọc Dung', '1986-03-02', N'Nữ', N'Q7, TpHCM', '0919754334', 'dung.dg297@gmail.com', '2025-01-09', '2027-01-09')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG298', N'Hoàng Quốc Em', '1993-11-26', N'Nữ', N'Bình Tân, TpHCM', '0919558892', 'em.dg298@gmail.com', '2026-03-08', '2028-03-07')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG299', N'Đặng Gia Khang', '2003-07-09', N'Nữ', N'Q9, TpHCM', '0916089498', 'khang.dg299@gmail.com', '2025-01-12', '2027-01-12')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG300', N'Phạm Thanh Nghĩa', '2004-12-28', N'Nam', N'Thủ Đức, TpHCM', '0918326885', 'nghĩa.dg300@gmail.com', '2025-01-28', '2027-01-28')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG301', N'Hồ Gia Phong', '2001-09-02', N'Nữ', N'Q7, TpHCM', '0916873521', 'phong.dg301@gmail.com', '2026-08-18', '2028-08-17')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG302', N'Đỗ Minh Khang', '1976-05-01', N'Nữ', N'Q1, TpHCM', '0914298644', 'khang.dg302@gmail.com', '2025-06-14', '2027-06-14')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG303', N'Phan Đình Uyên', '1984-04-22', N'Nam', N'Gò Vấp, TpHCM', '0919111200', 'uyên.dg303@gmail.com', '2026-01-25', '2028-01-25')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG304', N'Phan Đức Em', '1983-05-28', N'Nam', N'Thủ Đức, TpHCM', '0919472453', 'em.dg304@gmail.com', '2026-03-29', '2028-03-28')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG305', N'Võ Hoài Kiên', '1991-01-02', N'Nam', N'Q1, TpHCM', '0917053650', 'kiên.dg305@gmail.com', '2025-06-20', '2027-06-20')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG306', N'Hoàng Hoài Đức', '2001-05-01', N'Nam', N'Q10, TpHCM', '0917777736', 'đức.dg306@gmail.com', '2025-10-23', '2027-10-23')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG307', N'Phạm Quang Phúc', '1977-05-30', N'Nữ', N'Q3, TpHCM', '0911383016', 'phúc.dg307@gmail.com', '2026-05-08', '2028-05-07')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG308', N'Nguyễn Minh Em', '2002-08-19', N'Nam', N'Bình Thạnh, TpHCM', '0911401823', 'em.dg308@gmail.com', '2025-09-16', '2027-09-16')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG309', N'Vũ Bảo Anh', '1986-10-19', N'Nữ', N'Q3, TpHCM', '0917446190', 'anh.dg309@gmail.com', '2025-04-11', '2027-04-11')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG310', N'Huỳnh Kim Linh', '1986-01-15', N'Nữ', N'Q7, TpHCM', '0914227155', 'linh.dg310@gmail.com', '2025-07-17', '2027-07-17')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG311', N'Bùi Minh Khang', '1989-04-04', N'Nữ', N'Q3, TpHCM', '0914580048', 'khang.dg311@gmail.com', '2025-03-01', '2027-03-01')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG312', N'Dương Hoài Yến', '1989-04-16', N'Nữ', N'Q1, TpHCM', '0915569198', 'yến.dg312@gmail.com', '2026-03-16', '2028-03-15')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG313', N'Dương Đình Tuấn', '2000-05-07', N'Nam', N'Q7, TpHCM', '0911010632', 'tuấn.dg313@gmail.com', '2025-12-24', '2027-12-24')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG314', N'Bùi Ngọc Vinh', '1984-10-18', N'Nữ', N'Q1, TpHCM', '0919879517', 'vinh.dg314@gmail.com', '2025-01-27', '2027-01-27')
INSERT INTO DOCGIA (MADG, HOTEN, NGSINH, GIOITINH, DIACHI, SODT, EMAIL, NGAYLAPTHE, NGAYHETHAN) VALUES ('DG315', N'Đỗ Đình Xuân', '1990-01-06', N'Nam', N'Bình Thạnh, TpHCM', '0915642960', 'xuân.dg315@gmail.com', '2025-10-17', '2027-10-17')
GO

/* 2. THEM 150 PHIEU MUON VA CHI TIET */
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0321', 'DG178', '2026-09-19', '2026-10-03', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0321', 'CS008', '2026-10-01', N'Hư hỏng')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0321', 'CS024', '2026-10-02', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0322', 'DG050', '2026-05-02', '2026-05-16', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0322', 'CS008', '2026-05-10', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0323', 'DG300', '2026-04-27', '2026-05-11', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0323', 'CS022', '2026-05-05', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0323', 'CS008', '2026-05-02', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0323', 'CS019', '2026-05-10', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0324', 'DG061', '2026-03-14', '2026-03-28', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0324', 'CS022', '2026-03-21', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0325', 'DG272', '2026-05-25', '2026-06-08', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0325', 'CS008', '2026-06-10', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0325', 'CS002', '2026-06-14', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0325', 'CS018', '2026-06-12', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0326', 'DG050', '2026-02-04', '2026-02-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0326', 'CS008', '2026-02-21', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0326', 'CS010', '2026-02-18', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0327', 'DG059', '2026-09-19', '2026-10-03', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0327', 'CS009', '2026-09-29', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0328', 'DG303', '2026-08-19', '2026-09-02', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0328', 'CS001', '2026-09-05', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0328', 'CS019', '2026-09-05', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0328', 'CS021', '2026-08-25', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0329', 'DG001', '2026-02-27', '2026-03-13', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0329', 'CS008', '2026-03-06', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0329', 'CS009', '2026-03-09', N'Hư hỏng')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0329', 'CS004', '2026-03-18', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0330', 'DG014', '2026-09-20', '2026-10-04', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0330', 'CS021', '2026-09-28', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0330', 'CS022', '2026-10-08', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0330', 'CS005', '2026-10-03', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0331', 'DG232', '2026-07-13', '2026-07-27', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0331', 'CS010', '2026-07-18', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0331', 'CS011', '2026-07-30', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0331', 'CS002', '2026-07-20', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0332', 'DG174', '2026-07-25', '2026-08-08', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0332', 'CS004', '2026-08-07', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0332', 'CS010', '2026-08-04', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0333', 'DG168', '2026-03-28', '2026-04-11', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0333', 'CS002', '2026-04-05', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0333', 'CS022', '2026-04-15', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0334', 'DG184', '2026-09-16', '2026-09-30', N'Đang mượn')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0334', 'CS010', NULL, NULL)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0334', 'CS009', NULL, NULL)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0334', 'CS019', NULL, NULL)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0335', 'DG017', '2026-06-30', '2026-07-14', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0335', 'CS021', '2026-07-07', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0336', 'DG252', '2026-07-16', '2026-07-30', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0336', 'CS013', '2026-07-30', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0336', 'CS008', '2026-07-29', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0336', 'CS002', '2026-07-23', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0337', 'DG264', '2026-02-09', '2026-02-23', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0337', 'CS009', '2026-02-17', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0338', 'DG182', '2026-08-27', '2026-09-10', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0338', 'CS019', '2026-09-01', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0338', 'CS013', '2026-09-08', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0339', 'DG118', '2026-03-23', '2026-04-06', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0339', 'CS022', '2026-03-30', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0340', 'DG133', '2026-08-28', '2026-09-11', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0340', 'CS013', '2026-09-02', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0341', 'DG031', '2026-02-08', '2026-02-22', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0341', 'CS011', '2026-02-24', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0342', 'DG253', '2026-07-19', '2026-08-02', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0342', 'CS022', '2026-08-04', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0342', 'CS008', '2026-08-03', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0342', 'CS005', '2026-07-26', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0343', 'DG114', '2026-02-19', '2026-03-05', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0343', 'CS004', '2026-03-10', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0343', 'CS002', '2026-03-09', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0343', 'CS019', '2026-03-03', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0344', 'DG151', '2026-02-10', '2026-02-24', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0344', 'CS010', '2026-02-20', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0344', 'CS019', '2026-03-01', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0344', 'CS005', '2026-02-22', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0345', 'DG170', '2026-08-30', '2026-09-13', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0345', 'CS008', '2026-09-11', N'Hư hỏng')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0345', 'CS013', '2026-09-13', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0345', 'CS018', '2026-09-09', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0346', 'DG097', '2026-03-04', '2026-03-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0346', 'CS010', '2026-03-14', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0346', 'CS002', '2026-03-12', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0347', 'DG305', '2026-01-20', '2026-02-03', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0347', 'CS008', '2026-02-01', N'Hư hỏng')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0347', 'CS019', '2026-01-29', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0348', 'DG263', '2026-04-05', '2026-04-19', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0348', 'CS009', '2026-04-25', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0348', 'CS008', '2026-04-12', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0348', 'CS002', '2026-04-13', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0349', 'DG022', '2026-09-22', '2026-10-06', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0349', 'CS001', '2026-10-09', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0349', 'CS022', '2026-10-01', N'Hư hỏng')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0350', 'DG285', '2026-07-17', '2026-07-31', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0350', 'CS004', '2026-08-03', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0350', 'CS021', '2026-08-05', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0351', 'DG187', '2026-08-21', '2026-09-04', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0351', 'CS010', '2026-08-28', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0351', 'CS001', '2026-09-10', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0351', 'CS019', '2026-09-10', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0352', 'DG230', '2026-09-30', '2026-10-14', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0352', 'CS019', '2026-10-17', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0352', 'CS024', '2026-10-12', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0352', 'CS002', '2026-10-15', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0353', 'DG223', '2026-05-11', '2026-05-25', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0353', 'CS002', '2026-05-31', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0353', 'CS021', '2026-05-25', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0353', 'CS013', '2026-05-29', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0354', 'DG121', '2026-08-14', '2026-08-28', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0354', 'CS009', '2026-08-27', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0354', 'CS010', '2026-08-23', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0354', 'CS004', '2026-08-23', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0355', 'DG178', '2026-01-16', '2026-01-30', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0355', 'CS021', '2026-02-05', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0355', 'CS001', '2026-01-30', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0356', 'DG124', '2026-04-22', '2026-05-06', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0356', 'CS010', '2026-05-11', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0357', 'DG220', '2026-02-19', '2026-03-05', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0357', 'CS019', '2026-03-05', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0358', 'DG024', '2026-06-20', '2026-07-04', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0358', 'CS021', '2026-07-01', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0358', 'CS005', '2026-07-09', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0359', 'DG177', '2026-07-24', '2026-08-07', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0359', 'CS022', '2026-08-11', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0359', 'CS008', '2026-08-10', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0359', 'CS019', '2026-08-06', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0360', 'DG086', '2026-04-06', '2026-04-20', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0360', 'CS013', '2026-04-18', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0360', 'CS009', '2026-04-25', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0360', 'CS022', '2026-04-16', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0361', 'DG007', '2026-04-29', '2026-05-13', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0361', 'CS008', '2026-05-08', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0362', 'DG178', '2026-04-18', '2026-05-02', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0362', 'CS008', '2026-04-28', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0362', 'CS005', '2026-04-30', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0363', 'DG160', '2026-05-09', '2026-05-23', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0363', 'CS008', '2026-05-25', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0363', 'CS004', '2026-05-27', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0363', 'CS002', '2026-05-27', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0364', 'DG071', '2026-03-22', '2026-04-05', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0364', 'CS009', '2026-03-31', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0364', 'CS011', '2026-04-09', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0365', 'DG113', '2026-07-20', '2026-08-03', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0365', 'CS002', '2026-08-04', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0366', 'DG069', '2026-06-14', '2026-06-28', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0366', 'CS011', '2026-06-26', N'Hư hỏng')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0366', 'CS008', '2026-06-20', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0367', 'DG187', '2026-02-12', '2026-02-26', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0367', 'CS024', '2026-02-20', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0367', 'CS008', '2026-03-01', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0368', 'DG215', '2026-07-13', '2026-07-27', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0368', 'CS013', '2026-08-02', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0368', 'CS022', '2026-07-22', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0369', 'DG293', '2026-03-13', '2026-03-27', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0369', 'CS001', '2026-03-27', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0369', 'CS022', '2026-04-02', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0370', 'DG070', '2026-09-09', '2026-09-23', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0370', 'CS021', '2026-09-16', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0370', 'CS005', '2026-09-22', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0371', 'DG265', '2026-01-08', '2026-01-22', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0371', 'CS009', '2026-01-19', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0371', 'CS011', '2026-01-25', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0371', 'CS013', '2026-01-16', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0372', 'DG080', '2026-03-17', '2026-03-31', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0372', 'CS005', '2026-04-02', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0373', 'DG296', '2026-06-06', '2026-06-20', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0373', 'CS011', '2026-06-19', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0373', 'CS010', '2026-06-25', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0374', 'DG058', '2026-03-21', '2026-04-04', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0374', 'CS002', '2026-03-30', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0375', 'DG299', '2026-05-14', '2026-05-28', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0375', 'CS004', '2026-05-29', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0375', 'CS022', '2026-05-29', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0375', 'CS008', '2026-06-03', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0376', 'DG065', '2026-03-12', '2026-03-26', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0376', 'CS010', '2026-03-25', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0377', 'DG010', '2026-05-27', '2026-06-10', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0377', 'CS005', '2026-06-14', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0378', 'DG265', '2026-03-19', '2026-04-02', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0378', 'CS009', '2026-04-07', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0378', 'CS008', '2026-04-01', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0379', 'DG226', '2026-09-18', '2026-10-02', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0379', 'CS022', '2026-10-04', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0379', 'CS005', '2026-10-08', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0380', 'DG024', '2026-05-18', '2026-06-01', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0380', 'CS002', '2026-06-03', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0380', 'CS024', '2026-05-30', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0380', 'CS010', '2026-05-24', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0381', 'DG224', '2026-06-19', '2026-07-03', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0381', 'CS019', '2026-06-25', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0381', 'CS018', '2026-06-24', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0382', 'DG175', '2026-06-28', '2026-07-12', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0382', 'CS018', '2026-07-16', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0382', 'CS024', '2026-07-13', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0382', 'CS019', '2026-07-07', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0383', 'DG046', '2026-09-30', '2026-10-14', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0383', 'CS001', '2026-10-18', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0383', 'CS013', '2026-10-18', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0383', 'CS004', '2026-10-07', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0384', 'DG230', '2026-07-04', '2026-07-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0384', 'CS002', '2026-07-12', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0384', 'CS013', '2026-07-24', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0385', 'DG060', '2026-09-04', '2026-09-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0385', 'CS004', '2026-09-23', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0385', 'CS022', '2026-09-09', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0385', 'CS002', '2026-09-10', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0386', 'DG044', '2026-03-18', '2026-04-01', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0386', 'CS024', '2026-04-03', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0387', 'DG163', '2026-09-16', '2026-09-30', N'Đang mượn')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0387', 'CS024', NULL, NULL)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0387', 'CS001', NULL, NULL)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0387', 'CS009', NULL, NULL)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0388', 'DG118', '2026-09-28', '2026-10-12', N'Đang mượn')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0388', 'CS009', NULL, NULL)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0388', 'CS024', NULL, NULL)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0389', 'DG192', '2026-01-22', '2026-02-05', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0389', 'CS024', '2026-01-28', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0389', 'CS013', '2026-01-29', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0389', 'CS021', '2026-02-03', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0390', 'DG038', '2026-07-06', '2026-07-20', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0390', 'CS008', '2026-07-16', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0391', 'DG150', '2026-05-26', '2026-06-09', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0391', 'CS005', '2026-06-07', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0392', 'DG129', '2026-04-27', '2026-05-11', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0392', 'CS024', '2026-05-15', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0392', 'CS001', '2026-05-13', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0392', 'CS021', '2026-05-14', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0393', 'DG125', '2026-05-10', '2026-05-24', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0393', 'CS021', '2026-05-16', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0394', 'DG283', '2026-09-03', '2026-09-17', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0394', 'CS004', '2026-09-11', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0395', 'DG064', '2026-02-14', '2026-02-28', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0395', 'CS001', '2026-02-19', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0396', 'DG246', '2026-05-05', '2026-05-19', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0396', 'CS001', '2026-05-17', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0397', 'DG036', '2026-04-30', '2026-05-14', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0397', 'CS009', '2026-05-06', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0398', 'DG138', '2026-07-30', '2026-08-13', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0398', 'CS005', '2026-08-10', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0399', 'DG135', '2026-08-02', '2026-08-16', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0399', 'CS010', '2026-08-20', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0399', 'CS005', '2026-08-21', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0399', 'CS001', '2026-08-18', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0400', 'DG008', '2026-05-04', '2026-05-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0400', 'CS002', '2026-05-11', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0400', 'CS011', '2026-05-21', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0401', 'DG052', '2026-05-20', '2026-06-03', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0401', 'CS005', '2026-05-26', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0402', 'DG136', '2026-03-11', '2026-03-25', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0402', 'CS013', '2026-03-31', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0402', 'CS021', '2026-03-26', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0403', 'DG292', '2026-08-23', '2026-09-06', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0403', 'CS024', '2026-08-29', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0403', 'CS002', '2026-09-04', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0404', 'DG037', '2026-09-08', '2026-09-22', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0404', 'CS004', '2026-09-20', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0404', 'CS024', '2026-09-20', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0405', 'DG075', '2026-04-18', '2026-05-02', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0405', 'CS001', '2026-04-29', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0405', 'CS019', '2026-05-02', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0406', 'DG108', '2026-08-24', '2026-09-07', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0406', 'CS010', '2026-09-02', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0407', 'DG003', '2026-06-08', '2026-06-22', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0407', 'CS021', '2026-06-14', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0408', 'DG214', '2026-05-14', '2026-05-28', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0408', 'CS021', '2026-05-22', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0409', 'DG199', '2026-02-04', '2026-02-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0409', 'CS005', '2026-02-13', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0410', 'DG112', '2026-09-26', '2026-10-10', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0410', 'CS013', '2026-10-16', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0410', 'CS001', '2026-10-03', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0411', 'DG296', '2026-01-13', '2026-01-27', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0411', 'CS019', '2026-01-30', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0411', 'CS010', '2026-02-01', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0411', 'CS011', '2026-02-02', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0412', 'DG221', '2026-08-11', '2026-08-25', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0412', 'CS021', '2026-08-27', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0413', 'DG023', '2026-07-14', '2026-07-28', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0413', 'CS001', '2026-07-25', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0413', 'CS010', '2026-07-20', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0413', 'CS024', '2026-07-29', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0414', 'DG213', '2026-03-20', '2026-04-03', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0414', 'CS002', '2026-04-07', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0415', 'DG016', '2026-04-03', '2026-04-17', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0415', 'CS019', '2026-04-11', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0415', 'CS008', '2026-04-14', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0415', 'CS013', '2026-04-13', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0416', 'DG271', '2026-09-10', '2026-09-24', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0416', 'CS004', '2026-09-30', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0416', 'CS013', '2026-09-23', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0417', 'DG234', '2026-01-12', '2026-01-26', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0417', 'CS009', '2026-01-22', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0418', 'DG215', '2026-03-19', '2026-04-02', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0418', 'CS022', '2026-03-31', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0418', 'CS021', '2026-04-06', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0418', 'CS011', '2026-04-03', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0419', 'DG016', '2026-07-26', '2026-08-09', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0419', 'CS021', '2026-08-01', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0419', 'CS004', '2026-08-04', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0420', 'DG230', '2026-05-03', '2026-05-17', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0420', 'CS024', '2026-05-13', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0421', 'DG257', '2026-02-18', '2026-03-04', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0421', 'CS010', '2026-02-28', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0421', 'CS021', '2026-02-25', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0422', 'DG145', '2026-05-20', '2026-06-03', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0422', 'CS018', '2026-06-09', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0422', 'CS010', '2026-05-29', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0423', 'DG011', '2026-05-20', '2026-06-03', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0423', 'CS022', '2026-06-07', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0423', 'CS024', '2026-06-04', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0423', 'CS011', '2026-05-26', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0424', 'DG031', '2026-01-29', '2026-02-12', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0424', 'CS009', '2026-02-03', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0424', 'CS019', '2026-02-09', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0425', 'DG140', '2026-05-05', '2026-05-19', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0425', 'CS008', '2026-05-16', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0425', 'CS011', '2026-05-13', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0425', 'CS002', '2026-05-15', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0426', 'DG087', '2026-05-29', '2026-06-12', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0426', 'CS013', '2026-06-14', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0426', 'CS024', '2026-06-17', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0427', 'DG107', '2026-06-19', '2026-07-03', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0427', 'CS004', '2026-06-26', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0427', 'CS021', '2026-06-25', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0427', 'CS011', '2026-06-29', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0428', 'DG016', '2026-05-29', '2026-06-12', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0428', 'CS024', '2026-06-10', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0428', 'CS010', '2026-06-07', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0429', 'DG311', '2026-06-02', '2026-06-16', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0429', 'CS001', '2026-06-15', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0429', 'CS008', '2026-06-20', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0430', 'DG027', '2026-08-21', '2026-09-04', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0430', 'CS002', '2026-09-03', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0430', 'CS001', '2026-09-02', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0431', 'DG298', '2026-07-07', '2026-07-21', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0431', 'CS013', '2026-07-15', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0432', 'DG206', '2026-04-27', '2026-05-11', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0432', 'CS021', '2026-05-09', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0433', 'DG249', '2026-01-13', '2026-01-27', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0433', 'CS024', '2026-01-29', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0433', 'CS018', '2026-02-02', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0433', 'CS010', '2026-01-20', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0434', 'DG309', '2026-09-14', '2026-09-28', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0434', 'CS009', '2026-10-03', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0434', 'CS005', '2026-09-27', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0435', 'DG268', '2026-04-23', '2026-05-07', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0435', 'CS019', '2026-05-04', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0435', 'CS024', '2026-05-08', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0436', 'DG045', '2026-01-11', '2026-01-25', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0436', 'CS002', '2026-01-16', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0436', 'CS001', '2026-01-27', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0437', 'DG267', '2026-04-22', '2026-05-06', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0437', 'CS010', '2026-05-12', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0437', 'CS024', '2026-04-30', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0438', 'DG190', '2026-04-03', '2026-04-17', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0438', 'CS019', '2026-04-08', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0438', 'CS004', '2026-04-16', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0439', 'DG275', '2026-03-05', '2026-03-19', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0439', 'CS011', '2026-03-15', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0439', 'CS013', '2026-03-10', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0439', 'CS019', '2026-03-13', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0440', 'DG141', '2026-01-03', '2026-01-17', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0440', 'CS024', '2026-01-16', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0440', 'CS010', '2026-01-09', N'Hư hỏng')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0440', 'CS004', '2026-01-12', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0441', 'DG131', '2026-07-02', '2026-07-16', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0441', 'CS022', '2026-07-19', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0442', 'DG016', '2026-03-17', '2026-03-31', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0442', 'CS018', '2026-03-31', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0442', 'CS011', '2026-04-04', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0443', 'DG025', '2026-05-19', '2026-06-02', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0443', 'CS024', '2026-06-08', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0443', 'CS005', '2026-05-26', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0443', 'CS001', '2026-06-08', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0444', 'DG122', '2026-01-09', '2026-01-23', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0444', 'CS024', '2026-01-14', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0444', 'CS013', '2026-01-27', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0445', 'DG214', '2026-08-13', '2026-08-27', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0445', 'CS013', '2026-09-01', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0445', 'CS011', '2026-08-22', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0446', 'DG094', '2026-07-27', '2026-08-10', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0446', 'CS002', '2026-08-15', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0446', 'CS001', '2026-08-14', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0447', 'DG157', '2026-04-20', '2026-05-04', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0447', 'CS001', '2026-05-04', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0447', 'CS024', '2026-05-03', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0447', 'CS011', '2026-05-01', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0448', 'DG072', '2026-02-11', '2026-02-25', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0448', 'CS024', '2026-03-03', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0449', 'DG065', '2026-07-09', '2026-07-23', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0449', 'CS024', '2026-07-23', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0449', 'CS018', '2026-07-14', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0450', 'DG192', '2026-05-31', '2026-06-14', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0450', 'CS019', '2026-06-13', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0451', 'DG219', '2026-05-04', '2026-05-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0451', 'CS004', '2026-05-16', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0452', 'DG073', '2026-08-10', '2026-08-24', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0452', 'CS010', '2026-08-28', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0452', 'CS009', '2026-08-28', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0452', 'CS019', '2026-08-22', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0453', 'DG210', '2026-01-04', '2026-01-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0453', 'CS024', '2026-01-21', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0454', 'DG312', '2026-01-09', '2026-01-23', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0454', 'CS022', '2026-01-21', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0454', 'CS019', '2026-01-23', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0455', 'DG077', '2026-05-10', '2026-05-24', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0455', 'CS011', '2026-05-29', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0456', 'DG057', '2026-02-20', '2026-03-06', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0456', 'CS008', '2026-03-04', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0456', 'CS009', '2026-02-28', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0457', 'DG117', '2026-08-19', '2026-09-02', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0457', 'CS011', '2026-09-04', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0457', 'CS022', '2026-08-25', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0458', 'DG272', '2026-01-06', '2026-01-20', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0458', 'CS005', '2026-01-23', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0458', 'CS008', '2026-01-19', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0458', 'CS002', '2026-01-15', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0459', 'DG262', '2026-01-07', '2026-01-21', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0459', 'CS022', '2026-01-25', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0459', 'CS018', '2026-01-17', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0459', 'CS002', '2026-01-20', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0460', 'DG277', '2026-05-25', '2026-06-08', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0460', 'CS001', '2026-06-07', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0460', 'CS008', '2026-06-14', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0461', 'DG252', '2026-08-02', '2026-08-16', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0461', 'CS019', '2026-08-14', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0462', 'DG140', '2026-09-11', '2026-09-25', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0462', 'CS001', '2026-09-23', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0462', 'CS021', '2026-09-17', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0462', 'CS002', '2026-09-18', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0463', 'DG284', '2026-09-09', '2026-09-23', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0463', 'CS019', '2026-09-16', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0463', 'CS009', '2026-09-20', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0463', 'CS011', '2026-09-19', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0464', 'DG118', '2026-07-04', '2026-07-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0464', 'CS021', '2026-07-18', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0464', 'CS013', '2026-07-14', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0464', 'CS018', '2026-07-13', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0465', 'DG135', '2026-03-08', '2026-03-22', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0465', 'CS011', '2026-03-28', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0465', 'CS004', '2026-03-18', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0466', 'DG302', '2026-02-26', '2026-03-12', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0466', 'CS002', '2026-03-12', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0466', 'CS011', '2026-03-06', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0466', 'CS001', '2026-03-17', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0467', 'DG095', '2026-06-29', '2026-07-13', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0467', 'CS002', '2026-07-13', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0467', 'CS013', '2026-07-17', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0467', 'CS024', '2026-07-13', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0468', 'DG157', '2026-05-16', '2026-05-30', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0468', 'CS021', '2026-05-29', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0469', 'DG192', '2026-03-09', '2026-03-23', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0469', 'CS008', '2026-03-25', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0469', 'CS005', '2026-03-22', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0470', 'DG181', '2026-08-18', '2026-09-01', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0470', 'CS009', '2026-09-03', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0470', 'CS004', '2026-08-30', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0470', 'CS008', '2026-08-26', N'Bình thường')
GO

/* 3. THEM PHIEU PHAT */
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1000', 'PM0321', 'CS008', '2026-10-01', N'Hư hỏng', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1001', 'PM0325', 'CS008', '2026-06-10', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1002', 'PM0325', 'CS002', '2026-06-14', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1003', 'PM0325', 'CS018', '2026-06-12', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1004', 'PM0326', 'CS008', '2026-02-21', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1005', 'PM0328', 'CS001', '2026-09-05', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1006', 'PM0328', 'CS019', '2026-09-05', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1007', 'PM0329', 'CS009', '2026-03-09', N'Hư hỏng', 80000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1008', 'PM0329', 'CS004', '2026-03-18', N'Trả trễ', 25000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1009', 'PM0330', 'CS022', '2026-10-08', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1010', 'PM0331', 'CS011', '2026-07-30', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1011', 'PM0333', 'CS022', '2026-04-15', N'Trả trễ', 20000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1012', 'PM0341', 'CS011', '2026-02-24', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1013', 'PM0342', 'CS022', '2026-08-04', N'Trả trễ', 10000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1014', 'PM0342', 'CS008', '2026-08-03', N'Trả trễ', 5000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1015', 'PM0343', 'CS004', '2026-03-10', N'Trả trễ', 25000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1016', 'PM0343', 'CS002', '2026-03-09', N'Trả trễ', 20000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1017', 'PM0344', 'CS019', '2026-03-01', N'Trả trễ', 25000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1018', 'PM0345', 'CS008', '2026-09-11', N'Hư hỏng', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1019', 'PM0347', 'CS008', '2026-02-01', N'Hư hỏng', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1020', 'PM0348', 'CS009', '2026-04-25', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1021', 'PM0349', 'CS001', '2026-10-09', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1022', 'PM0349', 'CS022', '2026-10-01', N'Hư hỏng', 40000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1023', 'PM0350', 'CS004', '2026-08-03', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1024', 'PM0350', 'CS021', '2026-08-05', N'Trả trễ', 25000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1025', 'PM0351', 'CS001', '2026-09-10', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1026', 'PM0351', 'CS019', '2026-09-10', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1027', 'PM0352', 'CS019', '2026-10-17', N'Trả trễ', 15000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1028', 'PM0352', 'CS002', '2026-10-15', N'Trả trễ', 5000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1029', 'PM0353', 'CS002', '2026-05-31', N'Trả trễ', 30000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1030', 'PM0353', 'CS013', '2026-05-29', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1031', 'PM0355', 'CS021', '2026-02-05', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1032', 'PM0356', 'CS010', '2026-05-11', N'Trả trễ', 25000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1033', 'PM0358', 'CS005', '2026-07-09', N'Trả trễ', 25000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1034', 'PM0359', 'CS022', '2026-08-11', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1035', 'PM0359', 'CS008', '2026-08-10', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1036', 'PM0360', 'CS009', '2026-04-25', N'Trả trễ', 25000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1037', 'PM0363', 'CS008', '2026-05-25', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1038', 'PM0363', 'CS004', '2026-05-27', N'Trả trễ', 20000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1039', 'PM0363', 'CS002', '2026-05-27', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1040', 'PM0364', 'CS011', '2026-04-09', N'Trả trễ', 20000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1041', 'PM0365', 'CS002', '2026-08-04', N'Trả trễ', 5000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1042', 'PM0366', 'CS011', '2026-06-26', N'Hư hỏng', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1043', 'PM0367', 'CS008', '2026-03-01', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1044', 'PM0368', 'CS013', '2026-08-02', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1045', 'PM0369', 'CS022', '2026-04-02', N'Trả trễ', 30000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1046', 'PM0371', 'CS011', '2026-01-25', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1047', 'PM0372', 'CS005', '2026-04-02', N'Trả trễ', 10000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1048', 'PM0373', 'CS010', '2026-06-25', N'Trả trễ', 25000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1049', 'PM0375', 'CS004', '2026-05-29', N'Trả trễ', 5000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1050', 'PM0375', 'CS022', '2026-05-29', N'Trả trễ', 5000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1051', 'PM0375', 'CS008', '2026-06-03', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1052', 'PM0377', 'CS005', '2026-06-14', N'Trả trễ', 20000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1053', 'PM0378', 'CS009', '2026-04-07', N'Trả trễ', 25000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1054', 'PM0379', 'CS022', '2026-10-04', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1055', 'PM0379', 'CS005', '2026-10-08', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1056', 'PM0380', 'CS002', '2026-06-03', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1057', 'PM0382', 'CS018', '2026-07-16', N'Trả trễ', 20000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1058', 'PM0382', 'CS024', '2026-07-13', N'Trả trễ', 5000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1059', 'PM0383', 'CS001', '2026-10-18', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1060', 'PM0383', 'CS013', '2026-10-18', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1061', 'PM0384', 'CS013', '2026-07-24', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1062', 'PM0385', 'CS004', '2026-09-23', N'Trả trễ', 25000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1063', 'PM0386', 'CS024', '2026-04-03', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1064', 'PM0392', 'CS024', '2026-05-15', N'Trả trễ', 20000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1065', 'PM0392', 'CS001', '2026-05-13', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1066', 'PM0392', 'CS021', '2026-05-14', N'Trả trễ', 15000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1067', 'PM0399', 'CS010', '2026-08-20', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1068', 'PM0399', 'CS005', '2026-08-21', N'Trả trễ', 25000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1069', 'PM0399', 'CS001', '2026-08-18', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1070', 'PM0400', 'CS011', '2026-05-21', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1071', 'PM0402', 'CS013', '2026-03-31', N'Trả trễ', 30000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1072', 'PM0402', 'CS021', '2026-03-26', N'Trả trễ', 5000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1073', 'PM0410', 'CS013', '2026-10-16', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1074', 'PM0411', 'CS019', '2026-01-30', N'Trả trễ', 15000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1075', 'PM0411', 'CS010', '2026-02-01', N'Trả trễ', 25000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1076', 'PM0411', 'CS011', '2026-02-02', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1077', 'PM0412', 'CS021', '2026-08-27', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1078', 'PM0413', 'CS024', '2026-07-29', N'Trả trễ', 5000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1079', 'PM0414', 'CS002', '2026-04-07', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1080', 'PM0416', 'CS004', '2026-09-30', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1081', 'PM0418', 'CS021', '2026-04-06', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1082', 'PM0418', 'CS011', '2026-04-03', N'Trả trễ', 5000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1083', 'PM0422', 'CS018', '2026-06-09', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1084', 'PM0423', 'CS022', '2026-06-07', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1085', 'PM0423', 'CS024', '2026-06-04', N'Trả trễ', 5000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1086', 'PM0426', 'CS013', '2026-06-14', N'Trả trễ', 10000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1087', 'PM0426', 'CS024', '2026-06-17', N'Trả trễ', 25000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1088', 'PM0429', 'CS008', '2026-06-20', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1089', 'PM0433', 'CS024', '2026-01-29', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1090', 'PM0433', 'CS018', '2026-02-02', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1091', 'PM0434', 'CS009', '2026-10-03', N'Trả trễ', 25000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1092', 'PM0435', 'CS024', '2026-05-08', N'Trả trễ', 5000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1093', 'PM0436', 'CS001', '2026-01-27', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1094', 'PM0437', 'CS010', '2026-05-12', N'Trả trễ', 30000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1095', 'PM0440', 'CS010', '2026-01-09', N'Hư hỏng', 60000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1096', 'PM0441', 'CS022', '2026-07-19', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1097', 'PM0442', 'CS011', '2026-04-04', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1098', 'PM0443', 'CS024', '2026-06-08', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1099', 'PM0443', 'CS001', '2026-06-08', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1100', 'PM0444', 'CS013', '2026-01-27', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1101', 'PM0445', 'CS013', '2026-09-01', N'Trả trễ', 25000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1102', 'PM0446', 'CS002', '2026-08-15', N'Trả trễ', 25000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1103', 'PM0446', 'CS001', '2026-08-14', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1104', 'PM0448', 'CS024', '2026-03-03', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1105', 'PM0452', 'CS010', '2026-08-28', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1106', 'PM0452', 'CS009', '2026-08-28', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1107', 'PM0453', 'CS024', '2026-01-21', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1108', 'PM0455', 'CS011', '2026-05-29', N'Trả trễ', 25000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1109', 'PM0457', 'CS011', '2026-09-04', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1110', 'PM0458', 'CS005', '2026-01-23', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1111', 'PM0459', 'CS022', '2026-01-25', N'Trả trễ', 20000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1112', 'PM0460', 'CS008', '2026-06-14', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1113', 'PM0465', 'CS011', '2026-03-28', N'Trả trễ', 30000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1114', 'PM0466', 'CS001', '2026-03-17', N'Trả trễ', 25000, 0)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1115', 'PM0467', 'CS013', '2026-07-17', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1116', 'PM0469', 'CS008', '2026-03-25', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1117', 'PM0470', 'CS009', '2026-09-03', N'Trả trễ', 10000, 0)
GO

/* 4. CAP NHAT THUOC TINH DAN XUAT */
UPDATE DAUSACH
SET SOLUONG = (SELECT COUNT(*) FROM CUONSACH CS WHERE CS.MADS = DAUSACH.MADS),
	SLCON	= (SELECT COUNT(*) FROM CUONSACH CS WHERE CS.MADS = DAUSACH.MADS AND CS.TINHTRANG = N'Có sẵn')
GO

UPDATE DOCGIA
SET TONGNO = ISNULL((SELECT SUM(PP.SOTIEN)
					 FROM PHIEUPHAT PP JOIN PHIEUMUON PM ON PP.MAPM = PM.MAPM
					 WHERE PM.MADG = DOCGIA.MADG AND PP.DATHANHTOAN = 0), 0)
GO
/* 5. BAT LAI CAC TRIGGER */
ALTER TABLE PHIEUMUON ENABLE TRIGGER ALL;
ALTER TABLE CTPHIEUMUON ENABLE TRIGGER ALL;
ALTER TABLE PHIEUPHAT ENABLE TRIGGER ALL;
ALTER TABLE DOCGIA ENABLE TRIGGER ALL;
ALTER TABLE CUONSACH ENABLE TRIGGER ALL;
ALTER TABLE DAUSACH ENABLE TRIGGER ALL;
GO

GO

/* ==================== CONTENT OF 10_DuLieuPhatSinhMoi.sql ==================== */

USE QUANLYTHUVIEN;
GO
ALTER TABLE PHIEUMUON DISABLE TRIGGER ALL;
ALTER TABLE CTPHIEUMUON DISABLE TRIGGER ALL;
ALTER TABLE PHIEUPHAT DISABLE TRIGGER ALL;
GO
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0771', 'DG291', '2026-06-29', '2026-07-13', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0771', 'CS014', '2026-07-18', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1448', 'PM0771', 'CS014', '2026-07-18', N'Trả trễ', 10000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0771', 'CS026', '2026-07-23', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1449', 'PM0771', 'CS026', '2026-07-23', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0772', 'DG192', '2026-05-26', '2026-06-09', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0772', 'CS008', '2026-06-10', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1450', 'PM0772', 'CS008', '2026-06-10', N'Trả trễ', 10000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0772', 'CS018', '2026-06-19', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1451', 'PM0772', 'CS018', '2026-06-19', N'Trả trễ', 15000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0773', 'DG212', '2026-08-25', '2026-09-08', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0773', 'CS022', '2026-09-01', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0773', 'CS004', '2026-09-15', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1452', 'PM0773', 'CS004', '2026-09-15', N'Trả trễ', 10000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0774', 'DG032', '2026-09-03', '2026-09-17', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0774', 'CS023', '2026-09-09', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0774', 'CS012', '2026-09-25', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1453', 'PM0774', 'CS012', '2026-09-25', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0775', 'DG027', '2026-05-18', '2026-06-01', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0775', 'CS025', '2026-05-27', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0775', 'CS017', '2026-05-24', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0776', 'DG141', '2026-01-24', '2026-02-07', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0776', 'CS005', '2026-01-31', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0776', 'CS023', '2026-02-03', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0777', 'DG134', '2026-04-01', '2026-04-15', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0777', 'CS026', '2026-04-13', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0777', 'CS015', '2026-04-24', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1454', 'PM0777', 'CS015', '2026-04-24', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0778', 'DG306', '2026-10-05', '2026-10-19', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0778', 'CS002', '2026-10-09', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0779', 'DG076', '2026-09-29', '2026-10-13', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0779', 'CS013', '2026-10-09', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0780', 'DG122', '2026-05-28', '2026-06-11', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0780', 'CS005', '2026-06-17', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1455', 'PM0780', 'CS005', '2026-06-17', N'Trả trễ', 15000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0781', 'DG084', '2026-08-06', '2026-08-20', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0781', 'CS004', '2026-08-14', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0782', 'DG096', '2026-08-19', '2026-09-02', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0782', 'CS004', '2026-09-03', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1456', 'PM0782', 'CS004', '2026-09-03', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0783', 'DG264', '2026-05-25', '2026-06-08', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0783', 'CS013', '2026-06-07', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0783', 'CS007', '2026-06-17', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1457', 'PM0783', 'CS007', '2026-06-17', N'Trả trễ', 20000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0783', 'CS002', '2026-06-08', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0784', 'DG094', '2026-03-18', '2026-04-01', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0784', 'CS014', '2026-03-25', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0784', 'CS024', '2026-03-29', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0785', 'DG065', '2026-07-06', '2026-07-20', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0785', 'CS006', '2026-07-31', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1458', 'PM0785', 'CS006', '2026-07-31', N'Trả trễ', 20000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0785', 'CS024', '2026-07-17', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0785', 'CS019', '2026-07-31', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1459', 'PM0785', 'CS019', '2026-07-31', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0786', 'DG284', '2026-07-01', '2026-07-15', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0786', 'CS004', '2026-07-22', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1460', 'PM0786', 'CS004', '2026-07-22', N'Trả trễ', 10000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0786', 'CS012', '2026-07-17', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1461', 'PM0786', 'CS012', '2026-07-17', N'Trả trễ', 10000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0786', 'CS026', '2026-07-10', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0787', 'DG146', '2026-09-04', '2026-09-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0787', 'CS013', '2026-09-09', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0787', 'CS026', '2026-09-21', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1462', 'PM0787', 'CS026', '2026-09-21', N'Trả trễ', 15000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0788', 'DG098', '2026-06-03', '2026-06-17', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0788', 'CS001', '2026-06-10', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0788', 'CS016', '2026-06-19', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1463', 'PM0788', 'CS016', '2026-06-19', N'Trả trễ', 50000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0789', 'DG093', '2026-05-31', '2026-06-14', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0789', 'CS001', '2026-06-09', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0789', 'CS022', '2026-06-08', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0790', 'DG105', '2026-08-19', '2026-09-02', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0790', 'CS011', '2026-09-09', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1464', 'PM0790', 'CS011', '2026-09-09', N'Trả trễ', 5000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0790', 'CS022', '2026-09-11', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1465', 'PM0790', 'CS022', '2026-09-11', N'Trả trễ', 15000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0790', 'CS010', '2026-09-04', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1466', 'PM0790', 'CS010', '2026-09-04', N'Trả trễ', 10000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0791', 'DG305', '2026-08-17', '2026-08-31', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0791', 'CS016', '2026-09-06', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1467', 'PM0791', 'CS016', '2026-09-06', N'Trả trễ', 15000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0791', 'CS010', '2026-09-07', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1468', 'PM0791', 'CS010', '2026-09-07', N'Trả trễ', 10000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0792', 'DG030', '2026-02-04', '2026-02-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0792', 'CS019', '2026-02-14', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0792', 'CS008', '2026-03-01', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1469', 'PM0792', 'CS008', '2026-03-01', N'Trả trễ', 15000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0792', 'CS023', '2026-02-11', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0793', 'DG081', '2026-06-09', '2026-06-23', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0793', 'CS010', '2026-07-02', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1470', 'PM0793', 'CS010', '2026-07-02', N'Trả trễ', 5000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0794', 'DG224', '2026-09-03', '2026-09-17', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0794', 'CS022', '2026-09-24', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1471', 'PM0794', 'CS022', '2026-09-24', N'Trả trễ', 15000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0794', 'CS019', '2026-09-28', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1472', 'PM0794', 'CS019', '2026-09-28', N'Trả trễ', 5000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0795', 'DG037', '2026-09-06', '2026-09-20', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0795', 'CS002', '2026-09-20', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0795', 'CS006', '2026-09-23', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1473', 'PM0795', 'CS006', '2026-09-23', N'Trả trễ', 5000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0795', 'CS018', '2026-09-22', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1474', 'PM0795', 'CS018', '2026-09-22', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0796', 'DG214', '2026-05-21', '2026-06-04', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0796', 'CS010', '2026-05-30', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0797', 'DG018', '2026-04-05', '2026-04-19', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0797', 'CS003', '2026-04-11', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0797', 'CS020', '2026-04-20', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1475', 'PM0797', 'CS020', '2026-04-20', N'Trả trễ', 5000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0798', 'DG098', '2026-01-22', '2026-02-05', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0798', 'CS002', '2026-02-10', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1476', 'PM0798', 'CS002', '2026-02-10', N'Trả trễ', 15000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0798', 'CS026', '2026-01-30', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0798', 'CS010', '2026-02-10', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1477', 'PM0798', 'CS010', '2026-02-10', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0799', 'DG169', '2026-01-31', '2026-02-14', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0799', 'CS010', '2026-02-25', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1478', 'PM0799', 'CS010', '2026-02-25', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0800', 'DG094', '2026-08-23', '2026-09-06', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0800', 'CS006', '2026-09-06', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0800', 'CS002', '2026-09-03', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0801', 'DG222', '2026-07-26', '2026-08-09', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0801', 'CS025', '2026-07-31', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0801', 'CS008', '2026-08-07', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0802', 'DG069', '2026-03-10', '2026-03-24', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0802', 'CS012', '2026-03-24', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0802', 'CS010', '2026-04-04', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1479', 'PM0802', 'CS010', '2026-04-04', N'Trả trễ', 15000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0803', 'DG265', '2026-04-06', '2026-04-20', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0803', 'CS011', '2026-04-19', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0803', 'CS023', '2026-04-13', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0804', 'DG230', '2026-07-27', '2026-08-10', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0804', 'CS008', '2026-08-09', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0804', 'CS005', '2026-08-03', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0805', 'DG098', '2026-08-21', '2026-09-04', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0805', 'CS002', '2026-08-27', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1480', 'PM0805', 'CS002', '2026-08-27', N'Hư hỏng', 20000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0805', 'CS011', '2026-09-10', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1481', 'PM0805', 'CS011', '2026-09-10', N'Trả trễ', 15000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0805', 'CS003', '2026-09-10', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1482', 'PM0805', 'CS003', '2026-09-10', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0806', 'DG176', '2026-01-04', '2026-01-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0806', 'CS010', '2026-01-23', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1483', 'PM0806', 'CS010', '2026-01-23', N'Trả trễ', 5000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0807', 'DG292', '2026-05-27', '2026-06-10', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0807', 'CS023', '2026-06-05', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0807', 'CS014', '2026-06-06', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0807', 'CS017', '2026-06-04', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0808', 'DG183', '2026-07-22', '2026-08-05', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0808', 'CS022', '2026-08-08', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1484', 'PM0808', 'CS022', '2026-08-08', N'Trả trễ', 15000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0808', 'CS026', '2026-07-28', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0808', 'CS015', '2026-08-11', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1485', 'PM0808', 'CS015', '2026-08-11', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0809', 'DG189', '2026-08-10', '2026-08-24', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0809', 'CS012', '2026-08-21', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0809', 'CS004', '2026-08-27', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1486', 'PM0809', 'CS004', '2026-08-27', N'Trả trễ', 5000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0809', 'CS009', '2026-08-31', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1487', 'PM0809', 'CS009', '2026-08-31', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0810', 'DG009', '2026-02-17', '2026-03-03', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0810', 'CS021', '2026-02-23', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0810', 'CS008', '2026-03-02', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0811', 'DG246', '2026-07-03', '2026-07-17', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0811', 'CS004', '2026-07-22', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1488', 'PM0811', 'CS004', '2026-07-22', N'Trả trễ', 80000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0812', 'DG010', '2026-07-11', '2026-07-25', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0812', 'CS003', '2026-07-26', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1489', 'PM0812', 'CS003', '2026-07-26', N'Trả trễ', 15000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0812', 'CS025', '2026-07-18', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0812', 'CS011', '2026-07-21', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0813', 'DG155', '2026-08-06', '2026-08-20', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0813', 'CS022', '2026-08-30', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1490', 'PM0813', 'CS022', '2026-08-30', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0814', 'DG081', '2026-09-26', '2026-10-10', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0814', 'CS002', '2026-10-09', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0814', 'CS017', '2026-10-01', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1491', 'PM0814', 'CS017', '2026-10-01', N'Hư hỏng', 40000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0815', 'DG268', '2026-05-09', '2026-05-23', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0815', 'CS026', '2026-05-17', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0815', 'CS009', '2026-05-23', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1492', 'PM0815', 'CS009', '2026-05-23', N'Hư hỏng', 70000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0816', 'DG184', '2026-08-21', '2026-09-04', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0816', 'CS017', '2026-09-05', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1493', 'PM0816', 'CS017', '2026-09-05', N'Trả trễ', 20000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0817', 'DG218', '2026-02-25', '2026-03-11', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0817', 'CS025', '2026-03-10', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0817', 'CS016', '2026-03-03', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0817', 'CS014', '2026-03-05', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0818', 'DG232', '2026-04-12', '2026-04-26', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0818', 'CS006', '2026-05-02', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1494', 'PM0818', 'CS006', '2026-05-02', N'Trả trễ', 20000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0819', 'DG273', '2026-04-17', '2026-05-01', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0819', 'CS022', '2026-05-11', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1495', 'PM0819', 'CS022', '2026-05-11', N'Trả trễ', 20000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0819', 'CS021', '2026-04-27', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0820', 'DG210', '2026-09-20', '2026-10-04', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0820', 'CS006', '2026-10-09', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1496', 'PM0820', 'CS006', '2026-10-09', N'Trả trễ', 30000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0820', 'CS005', '2026-09-25', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0821', 'DG206', '2026-08-26', '2026-09-09', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0821', 'CS001', '2026-09-16', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1497', 'PM0821', 'CS001', '2026-09-16', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0822', 'DG179', '2026-08-23', '2026-09-06', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0822', 'CS022', '2026-09-01', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0823', 'DG050', '2026-09-20', '2026-10-04', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0823', 'CS009', '2026-09-30', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0823', 'CS004', '2026-10-06', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1498', 'PM0823', 'CS004', '2026-10-06', N'Trả trễ', 15000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0824', 'DG037', '2026-09-14', '2026-09-28', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0824', 'CS007', '2026-09-26', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0825', 'DG229', '2026-08-22', '2026-09-05', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0825', 'CS002', '2026-09-02', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0826', 'DG295', '2026-06-16', '2026-06-30', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0826', 'CS001', '2026-06-26', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0826', 'CS024', '2026-06-27', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0826', 'CS011', '2026-07-07', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1499', 'PM0826', 'CS011', '2026-07-07', N'Trả trễ', 5000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0827', 'DG055', '2026-03-04', '2026-03-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0827', 'CS009', '2026-03-28', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1500', 'PM0827', 'CS009', '2026-03-28', N'Trả trễ', 20000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0827', 'CS022', '2026-03-28', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1501', 'PM0827', 'CS022', '2026-03-28', N'Trả trễ', 15000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0827', 'CS008', '2026-03-11', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0828', 'DG140', '2026-01-25', '2026-02-08', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0828', 'CS003', '2026-02-03', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1502', 'PM0828', 'CS003', '2026-02-03', N'Hư hỏng', 40000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0828', 'CS014', '2026-02-16', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1503', 'PM0828', 'CS014', '2026-02-16', N'Trả trễ', 5000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0828', 'CS007', '2026-02-14', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1504', 'PM0828', 'CS007', '2026-02-14', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0829', 'DG179', '2026-09-22', '2026-10-06', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0829', 'CS009', '2026-10-09', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1505', 'PM0829', 'CS009', '2026-10-09', N'Trả trễ', 20000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0829', 'CS017', '2026-10-09', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1506', 'PM0829', 'CS017', '2026-10-09', N'Trả trễ', 20000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0829', 'CS016', '2026-10-06', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1507', 'PM0829', 'CS016', '2026-10-06', N'Hư hỏng', 20000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0830', 'DG249', '2026-02-08', '2026-02-22', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0830', 'CS017', '2026-02-25', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1508', 'PM0830', 'CS017', '2026-02-25', N'Trả trễ', 5000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0830', 'CS022', '2026-02-24', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1509', 'PM0830', 'CS022', '2026-02-24', N'Trả trễ', 10000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0831', 'DG102', '2026-05-16', '2026-05-30', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0831', 'CS019', '2026-06-08', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1510', 'PM0831', 'CS019', '2026-06-08', N'Trả trễ', 10000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0831', 'CS012', '2026-06-08', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1511', 'PM0831', 'CS012', '2026-06-08', N'Trả trễ', 15000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0831', 'CS023', '2026-05-24', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1512', 'PM0831', 'CS023', '2026-05-24', N'Hư hỏng', 70000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0832', 'DG160', '2026-04-26', '2026-05-10', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0832', 'CS002', '2026-05-16', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1513', 'PM0832', 'CS002', '2026-05-16', N'Hư hỏng', 30000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0832', 'CS019', '2026-05-06', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0832', 'CS012', '2026-05-01', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0833', 'DG074', '2026-07-16', '2026-07-30', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0833', 'CS003', '2026-08-02', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1514', 'PM0833', 'CS003', '2026-08-02', N'Trả trễ', 5000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0834', 'DG006', '2026-04-04', '2026-04-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0834', 'CS013', '2026-04-17', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0834', 'CS023', '2026-04-24', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1515', 'PM0834', 'CS023', '2026-04-24', N'Trả trễ', 5000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0835', 'DG257', '2026-09-16', '2026-09-30', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0835', 'CS016', '2026-09-25', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0835', 'CS022', '2026-10-05', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1516', 'PM0835', 'CS022', '2026-10-05', N'Trả trễ', 30000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0835', 'CS025', '2026-09-26', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0836', 'DG161', '2026-01-28', '2026-02-11', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0836', 'CS008', '2026-02-12', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1517', 'PM0836', 'CS008', '2026-02-12', N'Trả trễ', 5000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0837', 'DG148', '2026-06-20', '2026-07-04', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0837', 'CS019', '2026-06-27', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0837', 'CS005', '2026-07-09', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1518', 'PM0837', 'CS005', '2026-07-09', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0838', 'DG152', '2026-06-20', '2026-07-04', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0838', 'CS015', '2026-07-15', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1519', 'PM0838', 'CS015', '2026-07-15', N'Trả trễ', 10000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0838', 'CS017', '2026-06-25', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0838', 'CS005', '2026-07-06', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1520', 'PM0838', 'CS005', '2026-07-06', N'Trả trễ', 15000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0839', 'DG218', '2026-07-19', '2026-08-02', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0839', 'CS023', '2026-08-10', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1521', 'PM0839', 'CS023', '2026-08-10', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0840', 'DG311', '2026-08-03', '2026-08-17', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0840', 'CS007', '2026-08-27', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1522', 'PM0840', 'CS007', '2026-08-27', N'Trả trễ', 15000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0840', 'CS017', '2026-08-19', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1523', 'PM0840', 'CS017', '2026-08-19', N'Trả trễ', 5000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0841', 'DG168', '2026-05-24', '2026-06-07', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0841', 'CS008', '2026-06-01', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0841', 'CS019', '2026-06-16', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1524', 'PM0841', 'CS019', '2026-06-16', N'Trả trễ', 20000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0841', 'CS023', '2026-06-08', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1525', 'PM0841', 'CS023', '2026-06-08', N'Trả trễ', 15000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0842', 'DG303', '2026-04-28', '2026-05-12', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0842', 'CS022', '2026-05-19', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1526', 'PM0842', 'CS022', '2026-05-19', N'Trả trễ', 10000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0843', 'DG221', '2026-07-19', '2026-08-02', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0843', 'CS025', '2026-08-05', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1527', 'PM0843', 'CS025', '2026-08-05', N'Trả trễ', 15000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0843', 'CS003', '2026-08-06', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1528', 'PM0843', 'CS003', '2026-08-06', N'Trả trễ', 20000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0843', 'CS005', '2026-08-04', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1529', 'PM0843', 'CS005', '2026-08-04', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0844', 'DG299', '2026-09-18', '2026-10-02', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0844', 'CS012', '2026-10-02', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0844', 'CS001', '2026-10-06', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1530', 'PM0844', 'CS001', '2026-10-06', N'Trả trễ', 15000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0845', 'DG095', '2026-08-21', '2026-09-04', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0845', 'CS003', '2026-08-31', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0845', 'CS008', '2026-09-08', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1531', 'PM0845', 'CS008', '2026-09-08', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0846', 'DG045', '2026-06-13', '2026-06-27', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0846', 'CS008', '2026-06-24', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0847', 'DG298', '2026-09-23', '2026-10-07', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0847', 'CS014', '2026-10-05', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1532', 'PM0847', 'CS014', '2026-10-05', N'Hư hỏng', 40000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0847', 'CS004', '2026-10-01', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0847', 'CS003', '2026-10-09', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1533', 'PM0847', 'CS003', '2026-10-09', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0848', 'DG272', '2026-05-13', '2026-05-27', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0848', 'CS016', '2026-05-25', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0848', 'CS006', '2026-06-05', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1534', 'PM0848', 'CS006', '2026-06-05', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0849', 'DG261', '2026-05-02', '2026-05-16', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0849', 'CS010', '2026-05-19', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1535', 'PM0849', 'CS010', '2026-05-19', N'Trả trễ', 20000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0849', 'CS016', '2026-05-09', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0850', 'DG214', '2026-01-15', '2026-01-29', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0850', 'CS020', '2026-02-04', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1536', 'PM0850', 'CS020', '2026-02-04', N'Trả trễ', 15000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0850', 'CS011', '2026-01-20', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0850', 'CS015', '2026-01-31', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1537', 'PM0850', 'CS015', '2026-01-31', N'Trả trễ', 15000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0851', 'DG023', '2026-03-11', '2026-03-25', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0851', 'CS002', '2026-04-03', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1538', 'PM0851', 'CS002', '2026-04-03', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0852', 'DG069', '2026-06-25', '2026-07-09', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0852', 'CS009', '2026-07-12', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1539', 'PM0852', 'CS009', '2026-07-12', N'Trả trễ', 20000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0852', 'CS024', '2026-07-16', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1540', 'PM0852', 'CS024', '2026-07-16', N'Trả trễ', 5000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0853', 'DG088', '2026-05-17', '2026-05-31', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0853', 'CS019', '2026-06-02', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1541', 'PM0853', 'CS019', '2026-06-02', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0854', 'DG173', '2026-08-02', '2026-08-16', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0854', 'CS019', '2026-08-16', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0854', 'CS001', '2026-08-10', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0854', 'CS012', '2026-08-12', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0855', 'DG003', '2026-06-29', '2026-07-13', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0855', 'CS023', '2026-07-23', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1542', 'PM0855', 'CS023', '2026-07-23', N'Trả trễ', 15000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0855', 'CS008', '2026-07-21', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1543', 'PM0855', 'CS008', '2026-07-21', N'Trả trễ', 20000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0855', 'CS024', '2026-07-17', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1544', 'PM0855', 'CS024', '2026-07-17', N'Trả trễ', 5000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0856', 'DG289', '2026-05-01', '2026-05-15', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0856', 'CS008', '2026-05-10', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0856', 'CS018', '2026-05-20', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1545', 'PM0856', 'CS018', '2026-05-20', N'Trả trễ', 5000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0856', 'CS009', '2026-05-08', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0857', 'DG073', '2026-09-22', '2026-10-06', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0857', 'CS010', '2026-09-30', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0857', 'CS008', '2026-10-05', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0858', 'DG298', '2026-03-28', '2026-04-11', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0858', 'CS022', '2026-04-06', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0858', 'CS025', '2026-04-22', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1546', 'PM0858', 'CS025', '2026-04-22', N'Hư hỏng', 30000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0858', 'CS006', '2026-04-09', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0859', 'DG245', '2026-07-04', '2026-07-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0859', 'CS008', '2026-07-28', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1547', 'PM0859', 'CS008', '2026-07-28', N'Trả trễ', 20000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0859', 'CS016', '2026-07-18', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0859', 'CS011', '2026-07-28', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1548', 'PM0859', 'CS011', '2026-07-28', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0860', 'DG164', '2026-07-30', '2026-08-13', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0860', 'CS019', '2026-08-06', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0860', 'CS023', '2026-08-10', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0860', 'CS021', '2026-08-07', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0861', 'DG249', '2026-09-17', '2026-10-01', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0861', 'CS014', '2026-09-28', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1549', 'PM0861', 'CS014', '2026-09-28', N'Hư hỏng', 20000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0861', 'CS012', '2026-09-29', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1550', 'PM0861', 'CS012', '2026-09-29', N'Hư hỏng', 40000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0861', 'CS004', '2026-09-25', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0862', 'DG061', '2026-07-12', '2026-07-26', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0862', 'CS007', '2026-07-26', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0863', 'DG245', '2026-08-02', '2026-08-16', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0863', 'CS010', '2026-08-26', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1551', 'PM0863', 'CS010', '2026-08-26', N'Trả trễ', 5000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0864', 'DG124', '2026-04-04', '2026-04-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0864', 'CS009', '2026-04-16', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0865', 'DG024', '2026-04-22', '2026-05-06', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0865', 'CS004', '2026-05-02', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0865', 'CS013', '2026-05-14', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1552', 'PM0865', 'CS013', '2026-05-14', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0866', 'DG264', '2026-09-03', '2026-09-17', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0866', 'CS010', '2026-09-25', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1553', 'PM0866', 'CS010', '2026-09-25', N'Trả trễ', 20000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0866', 'CS019', '2026-09-17', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0866', 'CS021', '2026-09-23', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1554', 'PM0866', 'CS021', '2026-09-23', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0867', 'DG157', '2026-04-10', '2026-04-24', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0867', 'CS019', '2026-05-02', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1555', 'PM0867', 'CS019', '2026-05-02', N'Trả trễ', 5000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0867', 'CS022', '2026-04-25', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1556', 'PM0867', 'CS022', '2026-04-25', N'Trả trễ', 5000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0868', 'DG056', '2026-02-27', '2026-03-13', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0868', 'CS012', '2026-03-09', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0868', 'CS019', '2026-03-12', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1557', 'PM0868', 'CS019', '2026-03-12', N'Hư hỏng', 70000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0868', 'CS025', '2026-03-14', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1558', 'PM0868', 'CS025', '2026-03-14', N'Trả trễ', 10000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0869', 'DG174', '2026-01-14', '2026-01-28', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0869', 'CS021', '2026-01-19', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0869', 'CS008', '2026-01-22', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0869', 'CS020', '2026-01-22', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0870', 'DG139', '2026-09-04', '2026-09-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0870', 'CS014', '2026-09-22', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1559', 'PM0870', 'CS014', '2026-09-22', N'Trả trễ', 15000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0870', 'CS025', '2026-09-13', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0870', 'CS023', '2026-09-29', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1560', 'PM0870', 'CS023', '2026-09-29', N'Trả trễ', 5000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0871', 'DG312', '2026-07-15', '2026-07-29', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0871', 'CS022', '2026-08-09', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1561', 'PM0871', 'CS022', '2026-08-09', N'Hư hỏng', 80000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0871', 'CS014', '2026-08-06', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1562', 'PM0871', 'CS014', '2026-08-06', N'Trả trễ', 5000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0872', 'DG055', '2026-02-28', '2026-03-14', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0872', 'CS025', '2026-03-20', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1563', 'PM0872', 'CS025', '2026-03-20', N'Trả trễ', 5000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0872', 'CS019', '2026-03-18', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1564', 'PM0872', 'CS019', '2026-03-18', N'Trả trễ', 10000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0873', 'DG249', '2026-01-17', '2026-01-31', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0873', 'CS005', '2026-02-09', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1565', 'PM0873', 'CS005', '2026-02-09', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0874', 'DG034', '2026-04-21', '2026-05-05', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0874', 'CS011', '2026-05-11', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1566', 'PM0874', 'CS011', '2026-05-11', N'Trả trễ', 5000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0874', 'CS017', '2026-05-14', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1567', 'PM0874', 'CS017', '2026-05-14', N'Trả trễ', 20000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0875', 'DG104', '2026-03-28', '2026-04-11', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0875', 'CS010', '2026-04-02', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0876', 'DG201', '2026-03-06', '2026-03-20', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0876', 'CS017', '2026-03-21', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1568', 'PM0876', 'CS017', '2026-03-21', N'Trả trễ', 20000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0876', 'CS023', '2026-03-11', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0877', 'DG280', '2026-01-27', '2026-02-10', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0877', 'CS018', '2026-02-05', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1569', 'PM0877', 'CS018', '2026-02-05', N'Hư hỏng', 70000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0877', 'CS022', '2026-02-15', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1570', 'PM0877', 'CS022', '2026-02-15', N'Trả trễ', 10000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0878', 'DG040', '2026-09-22', '2026-10-06', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0878', 'CS015', '2026-10-09', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1571', 'PM0878', 'CS015', '2026-10-09', N'Trả trễ', 50000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0878', 'CS010', '2026-09-29', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0879', 'DG128', '2026-08-23', '2026-09-06', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0879', 'CS019', '2026-08-30', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0879', 'CS023', '2026-09-04', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0880', 'DG101', '2026-05-19', '2026-06-02', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0880', 'CS016', '2026-06-02', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0881', 'DG240', '2026-07-13', '2026-07-27', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0881', 'CS012', '2026-08-06', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1572', 'PM0881', 'CS012', '2026-08-06', N'Trả trễ', 20000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0881', 'CS023', '2026-07-29', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1573', 'PM0881', 'CS023', '2026-07-29', N'Trả trễ', 10000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0882', 'DG193', '2026-02-22', '2026-03-08', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0882', 'CS002', '2026-03-02', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0883', 'DG062', '2026-05-21', '2026-06-04', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0883', 'CS004', '2026-06-09', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1574', 'PM0883', 'CS004', '2026-06-09', N'Trả trễ', 15000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0883', 'CS016', '2026-06-11', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1575', 'PM0883', 'CS016', '2026-06-11', N'Trả trễ', 15000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0883', 'CS005', '2026-06-04', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0884', 'DG119', '2026-03-05', '2026-03-19', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0884', 'CS022', '2026-03-24', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1576', 'PM0884', 'CS022', '2026-03-24', N'Trả trễ', 30000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0884', 'CS009', '2026-03-19', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1577', 'PM0884', 'CS009', '2026-03-19', N'Hư hỏng', 20000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0885', 'DG286', '2026-07-07', '2026-07-21', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0885', 'CS019', '2026-07-25', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1578', 'PM0885', 'CS019', '2026-07-25', N'Trả trễ', 20000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0885', 'CS003', '2026-07-13', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0886', 'DG231', '2026-07-12', '2026-07-26', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0886', 'CS023', '2026-08-02', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1579', 'PM0886', 'CS023', '2026-08-02', N'Trả trễ', 15000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0886', 'CS010', '2026-07-22', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0886', 'CS006', '2026-07-19', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1580', 'PM0886', 'CS006', '2026-07-19', N'Hư hỏng', 40000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0887', 'DG023', '2026-02-11', '2026-02-25', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0887', 'CS002', '2026-02-22', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0888', 'DG125', '2026-04-25', '2026-05-09', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0888', 'CS007', '2026-05-19', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1581', 'PM0888', 'CS007', '2026-05-19', N'Trả trễ', 20000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0888', 'CS023', '2026-04-30', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0888', 'CS001', '2026-05-12', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1582', 'PM0888', 'CS001', '2026-05-12', N'Trả trễ', 5000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0889', 'DG058', '2026-04-21', '2026-05-05', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0889', 'CS012', '2026-04-27', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0889', 'CS025', '2026-05-07', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1583', 'PM0889', 'CS025', '2026-05-07', N'Trả trễ', 20000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0890', 'DG275', '2026-02-21', '2026-03-07', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0890', 'CS005', '2026-02-26', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0891', 'DG258', '2026-04-18', '2026-05-02', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0891', 'CS012', '2026-05-08', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1584', 'PM0891', 'CS012', '2026-05-08', N'Trả trễ', 10000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0891', 'CS022', '2026-05-03', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1585', 'PM0891', 'CS022', '2026-05-03', N'Trả trễ', 20000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0892', 'DG206', '2026-09-08', '2026-09-22', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0892', 'CS006', '2026-09-23', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1586', 'PM0892', 'CS006', '2026-09-23', N'Trả trễ', 10000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0892', 'CS022', '2026-09-27', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1587', 'PM0892', 'CS022', '2026-09-27', N'Trả trễ', 5000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0892', 'CS014', '2026-09-13', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0893', 'DG014', '2026-05-05', '2026-05-19', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0893', 'CS025', '2026-05-19', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0893', 'CS004', '2026-05-21', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1588', 'PM0893', 'CS004', '2026-05-21', N'Hư hỏng', 80000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0894', 'DG278', '2026-07-17', '2026-07-31', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0894', 'CS025', '2026-07-26', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0894', 'CS021', '2026-08-07', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1589', 'PM0894', 'CS021', '2026-08-07', N'Trả trễ', 20000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0895', 'DG306', '2026-08-28', '2026-09-11', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0895', 'CS025', '2026-09-20', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1590', 'PM0895', 'CS025', '2026-09-20', N'Trả trễ', 15000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0896', 'DG244', '2026-02-02', '2026-02-16', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0896', 'CS013', '2026-02-16', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1591', 'PM0896', 'CS013', '2026-02-16', N'Hư hỏng', 40000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0896', 'CS020', '2026-02-14', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0896', 'CS014', '2026-02-11', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0897', 'DG214', '2026-01-14', '2026-01-28', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0897', 'CS001', '2026-02-05', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1592', 'PM0897', 'CS001', '2026-02-05', N'Trả trễ', 15000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0897', 'CS024', '2026-01-26', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0897', 'CS003', '2026-01-20', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0898', 'DG042', '2026-03-22', '2026-04-05', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0898', 'CS012', '2026-04-05', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0899', 'DG204', '2026-08-16', '2026-08-30', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0899', 'CS010', '2026-09-10', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1593', 'PM0899', 'CS010', '2026-09-10', N'Trả trễ', 5000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0899', 'CS008', '2026-08-28', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0900', 'DG258', '2026-02-19', '2026-03-05', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0900', 'CS018', '2026-03-04', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0901', 'DG018', '2026-08-02', '2026-08-16', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0901', 'CS017', '2026-08-07', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0901', 'CS016', '2026-08-10', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0901', 'CS009', '2026-08-12', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0902', 'DG266', '2026-08-14', '2026-08-28', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0902', 'CS019', '2026-09-04', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1594', 'PM0902', 'CS019', '2026-09-04', N'Trả trễ', 5000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0903', 'DG025', '2026-07-17', '2026-07-31', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0903', 'CS010', '2026-07-27', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0903', 'CS013', '2026-08-04', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1595', 'PM0903', 'CS013', '2026-08-04', N'Trả trễ', 10000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0903', 'CS015', '2026-07-27', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0904', 'DG063', '2026-07-07', '2026-07-21', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0904', 'CS013', '2026-07-28', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1596', 'PM0904', 'CS013', '2026-07-28', N'Trả trễ', 30000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0904', 'CS015', '2026-07-19', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0904', 'CS008', '2026-07-24', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1597', 'PM0904', 'CS008', '2026-07-24', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0905', 'DG179', '2026-05-05', '2026-05-19', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0905', 'CS014', '2026-05-20', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1598', 'PM0905', 'CS014', '2026-05-20', N'Trả trễ', 5000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0905', 'CS021', '2026-05-23', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1599', 'PM0905', 'CS021', '2026-05-23', N'Trả trễ', 20000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0906', 'DG008', '2026-09-11', '2026-09-25', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0906', 'CS008', '2026-10-05', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1600', 'PM0906', 'CS008', '2026-10-05', N'Trả trễ', 5000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0907', 'DG029', '2026-09-09', '2026-09-23', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0907', 'CS018', '2026-09-24', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1601', 'PM0907', 'CS018', '2026-09-24', N'Trả trễ', 5000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0907', 'CS023', '2026-09-25', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1602', 'PM0907', 'CS023', '2026-09-25', N'Trả trễ', 10000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0907', 'CS012', '2026-09-22', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0908', 'DG109', '2026-08-11', '2026-08-25', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0908', 'CS003', '2026-09-04', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1603', 'PM0908', 'CS003', '2026-09-04', N'Trả trễ', 15000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0909', 'DG016', '2026-03-06', '2026-03-20', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0909', 'CS001', '2026-03-23', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1604', 'PM0909', 'CS001', '2026-03-23', N'Trả trễ', 15000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0909', 'CS016', '2026-03-25', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1605', 'PM0909', 'CS016', '2026-03-25', N'Trả trễ', 15000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0909', 'CS005', '2026-03-18', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0910', 'DG262', '2026-04-12', '2026-04-26', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0910', 'CS010', '2026-04-23', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0911', 'DG297', '2026-08-02', '2026-08-16', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0911', 'CS022', '2026-08-13', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1606', 'PM0911', 'CS022', '2026-08-13', N'Hư hỏng', 20000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0911', 'CS013', '2026-08-09', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0911', 'CS010', '2026-08-18', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1607', 'PM0911', 'CS010', '2026-08-18', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0912', 'DG157', '2026-02-14', '2026-02-28', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0912', 'CS004', '2026-02-28', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0913', 'DG109', '2026-09-11', '2026-09-25', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0913', 'CS005', '2026-10-02', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1608', 'PM0913', 'CS005', '2026-10-02', N'Trả trễ', 10000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0913', 'CS026', '2026-10-01', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1609', 'PM0913', 'CS026', '2026-10-01', N'Trả trễ', 50000, 0)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0913', 'CS018', '2026-09-26', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1610', 'PM0913', 'CS018', '2026-09-26', N'Trả trễ', 20000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0914', 'DG113', '2026-02-13', '2026-02-27', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0914', 'CS022', '2026-03-08', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1611', 'PM0914', 'CS022', '2026-03-08', N'Trả trễ', 15000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0915', 'DG094', '2026-02-20', '2026-03-06', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0915', 'CS004', '2026-03-14', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1612', 'PM0915', 'CS004', '2026-03-14', N'Trả trễ', 5000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0915', 'CS014', '2026-02-25', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1613', 'PM0915', 'CS014', '2026-02-25', N'Hư hỏng', 20000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0915', 'CS026', '2026-03-07', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1614', 'PM0915', 'CS026', '2026-03-07', N'Trả trễ', 10000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0916', 'DG262', '2026-03-17', '2026-03-31', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0916', 'CS010', '2026-04-11', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1615', 'PM0916', 'CS010', '2026-04-11', N'Trả trễ', 20000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0916', 'CS024', '2026-03-30', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0916', 'CS001', '2026-04-11', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1616', 'PM0916', 'CS001', '2026-04-11', N'Trả trễ', 20000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0917', 'DG065', '2026-03-31', '2026-04-14', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0917', 'CS022', '2026-04-18', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1617', 'PM0917', 'CS022', '2026-04-18', N'Trả trễ', 15000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0917', 'CS006', '2026-04-10', N'Hư hỏng')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1618', 'PM0917', 'CS006', '2026-04-10', N'Hư hỏng', 20000, 1)
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0917', 'CS003', '2026-04-20', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1619', 'PM0917', 'CS003', '2026-04-20', N'Trả trễ', 15000, 1)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0918', 'DG151', '2026-05-04', '2026-05-18', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0918', 'CS015', '2026-05-18', N'Bình thường')
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0919', 'DG205', '2026-08-28', '2026-09-11', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0919', 'CS026', '2026-09-06', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0919', 'CS016', '2026-09-21', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1620', 'PM0919', 'CS016', '2026-09-21', N'Trả trễ', 10000, 0)
INSERT INTO PHIEUMUON (MAPM, MADG, NGAYMUON, HANTRA, TINHTRANG) VALUES ('PM0920', 'DG074', '2026-09-19', '2026-10-03', N'Đã trả')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0920', 'CS003', '2026-10-01', N'Bình thường')
INSERT INTO CTPHIEUMUON (MAPM, MACS, NGAYTRA, TINHTRANGTRA) VALUES ('PM0920', 'CS019', '2026-10-09', N'Bình thường')
INSERT INTO PHIEUPHAT (MAPP, MAPM, MACS, NGAYLAP, LYDO, SOTIEN, DATHANHTOAN) VALUES ('PP1621', 'PM0920', 'CS019', '2026-10-09', N'Trả trễ', 15000, 0)
GO
UPDATE DAUSACH SET SOLUONG = (SELECT COUNT(*) FROM CUONSACH CS WHERE CS.MADS = DAUSACH.MADS), SLCON = (SELECT COUNT(*) FROM CUONSACH CS WHERE CS.MADS = DAUSACH.MADS AND CS.TINHTRANG = N'Có sẵn');
UPDATE DOCGIA SET TONGNO = ISNULL((SELECT SUM(PP.SOTIEN) FROM PHIEUPHAT PP JOIN PHIEUMUON PM ON PP.MAPM = PM.MAPM WHERE PM.MADG = DOCGIA.MADG AND PP.DATHANHTOAN = 0), 0);
GO
ALTER TABLE PHIEUMUON ENABLE TRIGGER ALL;
ALTER TABLE CTPHIEUMUON ENABLE TRIGGER ALL;
ALTER TABLE PHIEUPHAT ENABLE TRIGGER ALL;
GO
GO
