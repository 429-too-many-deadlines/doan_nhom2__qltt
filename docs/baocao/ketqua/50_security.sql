-- Ket qua AN TOAN THONG TIN (tren ban sao)
USE QUANLYTHUVIEN_BAOCAO
SET NOCOUNT ON
PRINT '=== S1 Xac thuc: mat khau luu dang bam ==='
SELECT TENDANGNHAP, CONVERT(VARCHAR(20), MATKHAU, 1) + '...' AS MATKHAU_BAM, TRANGTHAI FROM TAIKHOAN
DECLARE @kq INT
EXEC SP_DANGNHAP 'admin', N'123456', @kq OUTPUT
SELECT @kq AS DANGNHAP_DUNG
EXEC SP_DANGNHAP 'admin', N'sai_mat_khau', @kq OUTPUT
SELECT @kq AS DANGNHAP_SAI
SELECT name, type_desc, default_database_name FROM sys.server_principals WHERE name LIKE 'LG[_]%'

PRINT '=== S2 Phan quyen: role va thanh vien ==='
SELECT r.name AS ROLE_NAME, m.name AS THANHVIEN
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
WHERE m.name LIKE 'U[_]%' OR m.name LIKE 'R[_]%' ORDER BY r.name
SELECT pr.name AS ROLE_NAME, pe.state_desc, pe.permission_name,
       ISNULL(OBJECT_NAME(pe.major_id), pe.class_desc) AS DOITUONG
FROM sys.database_permissions pe JOIN sys.database_principals pr ON pe.grantee_principal_id = pr.principal_id
WHERE pr.name IN ('R_QUANLY', 'R_THUTHU', 'R_DOCGIA') AND pe.permission_name <> 'CONNECT'
ORDER BY pr.name, pe.state_desc, DOITUONG

PRINT '=== S3 EXECUTE AS U_THUTHU ==='
EXECUTE AS USER = 'U_THUTHU'
  SELECT COUNT(*) AS THUTHU_XEM_DOCGIA FROM DOCGIA
  BEGIN TRY DELETE FROM PHIEUPHAT WHERE MAPP = 'PP0001' END TRY
  BEGIN CATCH SELECT 'U_THUTHU DELETE PHIEUPHAT' AS THAOTAC, ERROR_MESSAGE() AS THONGBAO END CATCH
  BEGIN TRY SELECT * FROM TAIKHOAN END TRY
  BEGIN CATCH SELECT 'U_THUTHU SELECT TAIKHOAN' AS THAOTAC, ERROR_MESSAGE() AS THONGBAO END CATCH
REVERT

PRINT '=== S4 EXECUTE AS U_DOCGIA ==='
EXECUTE AS USER = 'U_DOCGIA'
  SELECT COUNT(*) AS DOCGIA_XEM_DAUSACH FROM DAUSACH
  BEGIN TRY SELECT TOP 1 * FROM DOCGIA END TRY
  BEGIN CATCH SELECT 'U_DOCGIA SELECT DOCGIA' AS THAOTAC, ERROR_MESSAGE() AS THONGBAO END CATCH
  BEGIN TRY UPDATE DAUSACH SET GIA = 1 WHERE MADS = 'DS001' END TRY
  BEGIN CATCH SELECT 'U_DOCGIA UPDATE DAUSACH' AS THAOTAC, ERROR_MESSAGE() AS THONGBAO END CATCH
  BEGIN TRY SELECT TOP 1 * FROM PHIEUPHAT END TRY
  BEGIN CATCH SELECT 'U_DOCGIA SELECT PHIEUPHAT (da REVOKE)' AS THAOTAC, ERROR_MESSAGE() AS THONGBAO END CATCH
REVERT

PRINT '=== S5 Backup ==='
SELECT name, recovery_model_desc FROM sys.databases WHERE name = 'QUANLYTHUVIEN_BAOCAO'
-- KHONG goi SP_SAOLUU o day: SP ghi cung ten CSDL goc QUANLYTHUVIEN (lan chay dau da tao /var/opt/mssql/data/QLTV_BAOCAO_FULL.bak)
SELECT TOP 3 bs.backup_start_date, CASE bs.type WHEN 'D' THEN 'FULL' WHEN 'I' THEN 'DIFF' END AS LOAI, bmf.physical_device_name, CAST(bs.backup_size/1024.0/1024 AS DECIMAL(10,2)) AS MB FROM msdb.dbo.backupset bs JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id WHERE bs.database_name = 'QUANLYTHUVIEN' AND bmf.physical_device_name LIKE '%QUANLYTHUVIEN_FULL_%' ORDER BY bs.backup_start_date DESC
