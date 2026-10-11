-- Tao ban sao QUANLYTHUVIEN_BAOCAO tu CSDL goc (COPY_ONLY: khong anh huong chuoi backup)
USE master
SET NOCOUNT ON
BACKUP DATABASE QUANLYTHUVIEN TO DISK = N'/var/opt/mssql/data/QLTV_baocao_src.bak'
  WITH COPY_ONLY, INIT, NAME = N'Ban sao phuc vu bao cao'
IF DB_ID('QUANLYTHUVIEN_BAOCAO') IS NOT NULL
BEGIN
  ALTER DATABASE QUANLYTHUVIEN_BAOCAO SET SINGLE_USER WITH ROLLBACK IMMEDIATE
  DROP DATABASE QUANLYTHUVIEN_BAOCAO
END
DECLARE @d NVARCHAR(128), @l NVARCHAR(128)
SELECT @d = name FROM sys.master_files WHERE database_id = DB_ID('QUANLYTHUVIEN') AND type = 0
SELECT @l = name FROM sys.master_files WHERE database_id = DB_ID('QUANLYTHUVIEN') AND type = 1
RESTORE DATABASE QUANLYTHUVIEN_BAOCAO FROM DISK = N'/var/opt/mssql/data/QLTV_baocao_src.bak'
  WITH MOVE @d TO N'/var/opt/mssql/data/QLTV_BAOCAO.mdf',
       MOVE @l TO N'/var/opt/mssql/data/QLTV_BAOCAO_log.ldf', RECOVERY
GO
-- CSDL goc dang co 5 trigger bi DISABLE (file du lieu 9 dung giua chung, chua chay lenh ENABLE).
-- Chi bat lai tren BAN SAO de minh hoa dung hanh vi thiet ke cua trigger.
USE QUANLYTHUVIEN_BAOCAO
EXEC sp_MSforeachtable 'ALTER TABLE ? ENABLE TRIGGER ALL'
SELECT name, is_disabled FROM sys.triggers
