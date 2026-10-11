-- Ket qua minh hoa SP ho tro website (chay tren ban sao QUANLYTHUVIEN_BAOCAO)
USE QUANLYTHUVIEN_BAOCAO
SET NOCOUNT ON
PRINT '=== SP_TIMSACH (tim theo ten tac gia, phan trang) ==='
EXEC SP_TIMSACH N'Nguyễn Nhật Ánh', 1, 10
PRINT '=== SP_TIMDOCGIA (trang 1, 3 dong) ==='
EXEC SP_TIMDOCGIA N'Nguyễn', 1, 3
PRINT '=== SP_XOATHELOAI: the loai dang co sach / chua co sach ==='
DECLARE @kq INT
EXEC @kq = SP_XOATHELOAI 'TL01'
SELECT 'TL01' AS MATL, @kq AS KETQUA
EXEC @kq = SP_XOATHELOAI 'TL08'
SELECT 'TL08' AS MATL, @kq AS KETQUA
PRINT '=== SP_DOIMATKHAU ==='
EXEC @kq = SP_DOIMATKHAU 'admin', N'sai', N'MoiMoi@1'
SELECT @kq AS SAI_MATKHAU_CU
EXEC @kq = SP_DOIMATKHAU 'admin', N'123456', N'MoiMoi@1'
SELECT @kq AS DUNG_MATKHAU_CU
