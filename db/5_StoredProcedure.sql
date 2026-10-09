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
