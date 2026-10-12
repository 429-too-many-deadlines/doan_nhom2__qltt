/* =====================================================================
   IE103 - Quản lý Thông tin
   Bài tập thực hành tuần 5: XPATH, XQUERY
   Sinh viên: MSSV - Họ tên
   Môi trường: Microsoft SQL Server 2022
   ===================================================================== */

/* =====================================================================
   A. CHUẨN BỊ: tạo CSDL TEST_XML (theo đề)
   ===================================================================== */
USE master
GO
IF DB_ID('TEST_XML') IS NOT NULL
BEGIN
    ALTER DATABASE TEST_XML SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE TEST_XML
END
GO
CREATE DATABASE TEST_XML
GO
USE TEST_XML
GO

-- KhoaHoc
CREATE TABLE KhoaHoc
(
    MaKhoaHoc INT IDENTITY(1,1) NOT NULL,
    TenKhoaHoc VARCHAR(200) NOT NULL,
    CONSTRAINT PK_KhoaHoc PRIMARY KEY(MaKhoaHoc)
)

INSERT INTO KhoaHoc (TenKhoaHoc) SELECT 'Mang May Tinh Truyen Thong'
INSERT INTO KhoaHoc (TenKhoaHoc) SELECT 'Khoa Hoc May Tinh'
INSERT INTO KhoaHoc (TenKhoaHoc) SELECT 'Ky Thuat May Tinh'

-- SinhVien
CREATE TABLE SinhVien
(
    MSSV BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_SinhVien PRIMARY KEY(MSSV),
    TenSV VARCHAR(200) NOT NULL,
    MaKhoaHoc INT NOT NULL CONSTRAINT FK_SinhVien_MaKhoaHoc FOREIGN KEY REFERENCES KhoaHoc(MaKhoaHoc)
)

INSERT INTO SinhVien SELECT 'Anh',1
INSERT INTO SinhVien SELECT 'Son',2
INSERT INTO SinhVien SELECT 'Thuy',3

-- MonHoc
CREATE TABLE MonHoc
(
    MaMonHoc INT IDENTITY NOT NULL CONSTRAINT PK_MonHoc PRIMARY KEY(MaMonHoc),
    TenMonHoc VARCHAR(200)
)

INSERT INTO MonHoc (TenMonHoc) SELECT ('Co So Du Lieu')
INSERT INTO MonHoc (TenMonHoc) SELECT ('Cau Truc Du Lieu')
INSERT INTO MonHoc (TenMonHoc) SELECT ('Lap Trinh Di Dong')
INSERT INTO MonHoc (TenMonHoc) SELECT ('Toan Giai Tich')
INSERT INTO MonHoc (TenMonHoc) SELECT ('Lap Trinh Java')
INSERT INTO MonHoc (TenMonHoc) SELECT ('He Quan Tri CSDL')
INSERT INTO MonHoc (TenMonHoc) SELECT ('Anh Van')
INSERT INTO MonHoc (TenMonHoc) SELECT ('Thiet Ke Web ')
INSERT INTO MonHoc (TenMonHoc) SELECT ('An Toan Thong Tin')

-- KhoaHocMonHoc
CREATE TABLE KhoaHocMonHoc
(
    MaKhoaHoc INT CONSTRAINT FK_KhoaHocMonHoc_MaKhoaHoc FOREIGN KEY REFERENCES KhoaHoc(MaKhoaHoc),
    MaMonHoc INT CONSTRAINT FK_KhoaHocMonHoc_MaMonHoc FOREIGN KEY REFERENCES MonHoc(MaMonHoc)
)

INSERT INTO KhoaHocMonHoc (MaKhoaHoc,MaMonHoc) SELECT 1,1
INSERT INTO KhoaHocMonHoc (MaKhoaHoc,MaMonHoc) SELECT 1,2
INSERT INTO KhoaHocMonHoc (MaKhoaHoc,MaMonHoc) SELECT 1,3
INSERT INTO KhoaHocMonHoc (MaKhoaHoc,MaMonHoc) SELECT 2,4
INSERT INTO KhoaHocMonHoc (MaKhoaHoc,MaMonHoc) SELECT 2,5
INSERT INTO KhoaHocMonHoc (MaKhoaHoc,MaMonHoc) SELECT 2,6
INSERT INTO KhoaHocMonHoc (MaKhoaHoc,MaMonHoc) SELECT 3,7
INSERT INTO KhoaHocMonHoc (MaKhoaHoc,MaMonHoc) SELECT 3,8
INSERT INTO KhoaHocMonHoc (MaKhoaHoc,MaMonHoc) SELECT 3,9

-- Diem
CREATE TABLE Diem
(
    MSSV BIGINT CONSTRAINT FK_Diem_MSSV FOREIGN KEY REFERENCES SinhVien(MSSV),
    MaMonHoc INT CONSTRAINT FK_Diem_MaMonHoc FOREIGN KEY REFERENCES MonHoc(MaMonHoc),
    Diem INT
)

INSERT INTO Diem (MSSV,MaMonHoc,Diem) SELECT 1,1,75
INSERT INTO Diem (MSSV,MaMonHoc,Diem) SELECT 1,2,80
INSERT INTO Diem (MSSV,MaMonHoc,Diem) SELECT 1,3,70
INSERT INTO Diem (MSSV,MaMonHoc,Diem) SELECT 2,4,80
INSERT INTO Diem (MSSV,MaMonHoc,Diem) SELECT 2,5,80
INSERT INTO Diem (MSSV,MaMonHoc,Diem) SELECT 2,6,90
INSERT INTO Diem (MSSV,MaMonHoc,Diem) SELECT 3,7,80
INSERT INTO Diem (MSSV,MaMonHoc,Diem) SELECT 3,8,80
INSERT INTO Diem (MSSV,MaMonHoc,Diem) SELECT 3,9,90

-- QuanLySV
CREATE TABLE QuanLySV
(
    MSDH INT NOT NULL,
    TenDH VARCHAR(20),
    ChiTietSV XML
)

INSERT INTO QuanLySV VALUES (1,'DH CNTT',
'<THONGTINSV>
    <sinhvien ID="10" Ten="Nam">
        <monhoc ID="1" Ten="Co So Du Lieu" />
        <monhoc ID="2" Ten="Cau Truc Du Lieu" />
        <monhoc ID="3" Ten="Lap Trinh Mobile" />
    </sinhvien>
    <sinhvien ID="11" Ten="An">
        <monhoc ID="4" Ten="Toan Giai Tich" />
        <monhoc ID="5" Ten="Lap Trinh Java" />
        <monhoc ID="6" Ten="He Quan Tri CSDL" />
    </sinhvien>
    <sinhvien ID="12" Ten="Thanh">
        <monhoc ID="7" Ten="Anh Van" />
        <monhoc ID="8" Ten="Thiet Ke Web" />
        <monhoc ID="9" Ten="An Toan Thong Tin" />
    </sinhvien>
</THONGTINSV>')

INSERT INTO QuanLySV VALUES (2,'DH KHTN',
'<THONGTINSV>
    <sinhvien ID="10" Ten="Khang">
        <monhoc ID="1" Ten="Co So Du Lieu" />
        <monhoc ID="2" Ten="Cau Truc Du Lieu" />
        <monhoc ID="3" Ten="Lap Trinh Mobile" />
    </sinhvien>
    <sinhvien ID="11" Ten="Vinh">
        <monhoc ID="4" Ten="Toan Giai Tich" />
        <monhoc ID="5" Ten="Lap Trinh Java" />
        <monhoc ID="6" Ten="He Quan Tri CSDL" />
    </sinhvien>
    <sinhvien ID="12" Ten="Hoa">
        <monhoc ID="7" Ten="Anh Van" />
        <monhoc ID="8" Ten="Thiet Ke Web" />
        <monhoc ID="9" Ten="An Toan Thong Tin" />
    </sinhvien>
</THONGTINSV>')
GO

/* =====================================================================
   B. THỰC HÀNH
   ===================================================================== */

/* ---------------------------------------------------------------------
   Câu 1: Lệnh Xpath lấy sinh viên có ID = 10
          và lệnh Xpath lấy sinh viên ở vị trí cuối cùng ở trường CNTT.
   --------------------------------------------------------------------- */
PRINT N'=== Cau 1a ==='
-- Sinh viên có ID = 10 (ở cả hai trường)
SELECT MSDH, TenDH,
       ChiTietSV.query('/THONGTINSV/sinhvien[@ID = 10]') AS SinhVien_ID10
FROM QuanLySV
GO

PRINT N'=== Cau 1b ==='
-- Sinh viên ở vị trí cuối cùng của trường DH CNTT
SELECT MSDH, TenDH,
       ChiTietSV.query('/THONGTINSV/sinhvien[last()]') AS SinhVien_CuoiCung
FROM QuanLySV
WHERE TenDH = 'DH CNTT'
GO

/* ---------------------------------------------------------------------
   Câu 2: Trả về tất cả các nút từ nút gốc là THONGTINSV.
   --------------------------------------------------------------------- */
PRINT N'=== Cau 2a ==='
-- Cách 1: trả về nguyên cây XML bắt đầu từ nút gốc THONGTINSV
SELECT MSDH, ChiTietSV.query('/THONGTINSV') AS TatCaCacNut
FROM QuanLySV
GO

PRINT N'=== Cau 2b ==='
-- Cách 2: liệt kê từng nút con cháu của THONGTINSV (mỗi nút một dòng)
SELECT Q.MSDH,
       N.c.value('local-name(.)', 'VARCHAR(20)')            AS TenNut,
       N.c.value('local-name(..)', 'VARCHAR(20)')           AS NutCha,
       N.c.value('@ID', 'INT')                              AS ID,
       N.c.value('@Ten', 'VARCHAR(50)')                     AS Ten
FROM QuanLySV Q
CROSS APPLY Q.ChiTietSV.nodes('/THONGTINSV//*') AS N(c)
GO

/* ---------------------------------------------------------------------
   Câu 3: Xquery trả về danh sách sinh viên có ID < 12 với MSDH = 1.
   --------------------------------------------------------------------- */
PRINT N'=== Cau 3 ==='
SELECT MSDH, TenDH,
       ChiTietSV.query('
           for $sv in /THONGTINSV/sinhvien
           where $sv/@ID < 12
           return $sv
       ') AS SinhVien_ID_Nho_Hon_12
FROM QuanLySV
WHERE MSDH = 1
GO

/* ---------------------------------------------------------------------
   Câu 4: Xquery trả về danh sách sinh viên sắp xếp theo tên với MSDH = 2.
   --------------------------------------------------------------------- */
PRINT N'=== Cau 4 ==='
SELECT MSDH, TenDH,
       ChiTietSV.query('
           for $sv in /THONGTINSV/sinhvien
           order by string($sv/@Ten) ascending
           return <sinhvien ID="{data($sv/@ID)}" Ten="{data($sv/@Ten)}" />
       ') AS SinhVien_SapXepTheoTen
FROM QuanLySV
WHERE MSDH = 2
GO

/* ---------------------------------------------------------------------
   Câu 5: Xquery trả về MSDH và TenDH theo định dạng:
          <QuanLySV><ChiTietSV>1 DH CNTT</ChiTietSV></QuanLySV>
   --------------------------------------------------------------------- */
PRINT N'=== Cau 5 ==='
-- sql:column() đưa giá trị cột quan hệ vào biểu thức XQuery
SELECT ChiTietSV.query('
           <QuanLySV>
               <ChiTietSV>{ concat(string(sql:column("MSDH")), " ", sql:column("TenDH")) }</ChiTietSV>
           </QuanLySV>
       ') AS KetQua
FROM QuanLySV
GO

/* ---------------------------------------------------------------------
   Câu 6: Xquery xóa tên các sinh viên trường DH KHTN.
   --------------------------------------------------------------------- */
PRINT N'=== Cau 6 - truoc ==='
SELECT MSDH, TenDH, ChiTietSV.query('/THONGTINSV/sinhvien') AS TruocKhiXoa
FROM QuanLySV WHERE TenDH = 'DH KHTN'

UPDATE QuanLySV
SET ChiTietSV.modify('delete /THONGTINSV/sinhvien/@Ten')
WHERE TenDH = 'DH KHTN'

PRINT N'=== Cau 6 - sau ==='
SELECT MSDH, TenDH, ChiTietSV.query('/THONGTINSV/sinhvien') AS SauKhiXoa
FROM QuanLySV WHERE TenDH = 'DH KHTN'
GO

/* ---------------------------------------------------------------------
   Câu 7: Xquery trả về thông tin các sinh viên có tên là 'Nam' hoặc 'Thanh'.
   --------------------------------------------------------------------- */
PRINT N'=== Cau 7 ==='
SELECT MSDH, TenDH,
       ChiTietSV.query('
           for $sv in /THONGTINSV/sinhvien
           where $sv/@Ten = "Nam" or $sv/@Ten = "Thanh"
           return $sv
       ') AS SinhVien_Nam_Thanh
FROM QuanLySV
WHERE ChiTietSV.exist('/THONGTINSV/sinhvien[@Ten = "Nam" or @Ten = "Thanh"]') = 1
GO

/* ---------------------------------------------------------------------
   Câu 8: Xquery thay đổi tên sinh viên thứ 2 thành 'Binh' trong trường CNTT.
   --------------------------------------------------------------------- */
PRINT N'=== Cau 8 - truoc ==='
SELECT MSDH, TenDH, ChiTietSV.value('(/THONGTINSV/sinhvien[2]/@Ten)[1]', 'VARCHAR(50)') AS TenSV2_Truoc
FROM QuanLySV WHERE TenDH = 'DH CNTT'

UPDATE QuanLySV
SET ChiTietSV.modify('replace value of (/THONGTINSV/sinhvien[2]/@Ten)[1] with "Binh"')
WHERE TenDH = 'DH CNTT'

PRINT N'=== Cau 8 - sau ==='
SELECT MSDH, TenDH, ChiTietSV.value('(/THONGTINSV/sinhvien[2]/@Ten)[1]', 'VARCHAR(50)') AS TenSV2_Sau,
       ChiTietSV.query('/THONGTINSV/sinhvien[2]') AS SinhVienThu2
FROM QuanLySV WHERE TenDH = 'DH CNTT'
GO

/* ---------------------------------------------------------------------
   Câu 9: Kiểm tra có tồn tại sinh viên có ID = 12 trong trường KHTN không?
          (có: 1, không: 0)
   --------------------------------------------------------------------- */
PRINT N'=== Cau 9 ==='
SELECT MSDH, TenDH,
       ChiTietSV.exist('/THONGTINSV/sinhvien[@ID = 12]') AS TonTai_ID12
FROM QuanLySV
WHERE TenDH = 'DH KHTN'
GO

/* ---------------------------------------------------------------------
   Câu 10: Kiểm tra có tồn tại sinh viên tên 'Lan' trong trường CNTT không?
           (có: 1, không: 0). Và INSERT thêm sinh viên Lan vào THONGTINSV.
   --------------------------------------------------------------------- */
PRINT N'=== Cau 10 - kiem tra ==='
SELECT MSDH, TenDH,
       ChiTietSV.exist('/THONGTINSV/sinhvien[@Ten = "Lan"]') AS TonTai_Lan
FROM QuanLySV
WHERE TenDH = 'DH CNTT'

-- Chỉ thêm khi chưa có sinh viên tên Lan
IF NOT EXISTS (SELECT 1 FROM QuanLySV
               WHERE TenDH = 'DH CNTT'
                 AND ChiTietSV.exist('/THONGTINSV/sinhvien[@Ten = "Lan"]') = 1)
BEGIN
    UPDATE QuanLySV
    SET ChiTietSV.modify('
        insert <sinhvien ID="15" Ten="Lan">
                   <monhoc ID="10" Ten="Toan Roi Rac" />
                   <monhoc ID="11" Ten="Lap Trinh C#" />
                   <monhoc ID="12" Ten="CSDL Nang Cao" />
               </sinhvien>
        as last into (/THONGTINSV)[1]')
    WHERE TenDH = 'DH CNTT'
END

PRINT N'=== Cau 10 - sau khi insert ==='
SELECT MSDH, TenDH,
       ChiTietSV.exist('/THONGTINSV/sinhvien[@Ten = "Lan"]') AS TonTai_Lan,
       ChiTietSV.query('/THONGTINSV/sinhvien[@Ten = "Lan"]') AS SinhVien_Lan
FROM QuanLySV
WHERE TenDH = 'DH CNTT'
GO

/* ---------------------------------------------------------------------
   Câu 11*: Phép nối bằng Xquery: sinh viên nào học khóa học tên là gì,
            sinh viên nào học môn học gì?
   Ý tưởng: dùng FOR XML để đưa các bảng quan hệ về một tài liệu XML,
            sau đó dùng FLWOR (for ... where ...) để nối như JOIN trong SQL.
   --------------------------------------------------------------------- */
PRINT N'=== Cau 11 - tai lieu XML nguon ==='
DECLARE @x XML =
(
    SELECT
        (SELECT MSSV AS '@MSSV', TenSV AS '@TenSV', MaKhoaHoc AS '@MaKhoaHoc'
         FROM SinhVien FOR XML PATH('sinhvien'), ROOT('SinhVien'), TYPE),
        (SELECT MaKhoaHoc AS '@MaKhoaHoc', TenKhoaHoc AS '@TenKhoaHoc'
         FROM KhoaHoc FOR XML PATH('khoahoc'), ROOT('KhoaHoc'), TYPE),
        (SELECT MaMonHoc AS '@MaMonHoc', RTRIM(TenMonHoc) AS '@TenMonHoc'
         FROM MonHoc FOR XML PATH('monhoc'), ROOT('MonHoc'), TYPE),
        (SELECT MSSV AS '@MSSV', MaMonHoc AS '@MaMonHoc', Diem AS '@Diem'
         FROM Diem FOR XML PATH('diem'), ROOT('Diem'), TYPE)
    FOR XML PATH('QLSV'), TYPE
)
SELECT @x.query('/QLSV/SinhVien') AS SinhVien_XML, @x.query('/QLSV/KhoaHoc') AS KhoaHoc_XML

PRINT N'=== Cau 11a - sinh vien hoc khoa hoc nao ==='
-- Tương đương: SELECT ... FROM SinhVien JOIN KhoaHoc ON SinhVien.MaKhoaHoc = KhoaHoc.MaKhoaHoc
SELECT @x.query('
    <SinhVien_KhoaHoc>{
        for $sv in /QLSV/SinhVien/sinhvien,
            $kh in /QLSV/KhoaHoc/khoahoc
        where $sv/@MaKhoaHoc = $kh/@MaKhoaHoc
        order by number($sv/@MSSV)
        return <ketqua MSSV="{data($sv/@MSSV)}"
                       TenSV="{data($sv/@TenSV)}"
                       KhoaHoc="{data($kh/@TenKhoaHoc)}" />
    }</SinhVien_KhoaHoc>
') AS SinhVien_KhoaHoc

PRINT N'=== Cau 11b - sinh vien hoc mon hoc nao ==='
-- Tương đương: SinhVien JOIN Diem JOIN MonHoc
SELECT @x.query('
    <SinhVien_MonHoc>{
        for $sv in /QLSV/SinhVien/sinhvien,
            $d  in /QLSV/Diem/diem,
            $mh in /QLSV/MonHoc/monhoc
        where $sv/@MSSV = $d/@MSSV and $d/@MaMonHoc = $mh/@MaMonHoc
        order by number($sv/@MSSV), number($mh/@MaMonHoc)
        return <ketqua TenSV="{data($sv/@TenSV)}"
                       MonHoc="{data($mh/@TenMonHoc)}"
                       Diem="{data($d/@Diem)}" />
    }</SinhVien_MonHoc>
') AS SinhVien_MonHoc

PRINT N'=== Cau 11c - ket qua dang bang ==='
-- Trình bày kết quả nối dưới dạng bảng bằng nodes()/value()
SELECT K.r.value('@TenSV', 'VARCHAR(50)')  AS TenSV,
       K.r.value('@MonHoc', 'VARCHAR(50)') AS MonHoc,
       K.r.value('@Diem', 'INT')           AS Diem
FROM (SELECT @x.query('
        for $sv in /QLSV/SinhVien/sinhvien,
            $d  in /QLSV/Diem/diem,
            $mh in /QLSV/MonHoc/monhoc
        where $sv/@MSSV = $d/@MSSV and $d/@MaMonHoc = $mh/@MaMonHoc
        return <ketqua TenSV="{data($sv/@TenSV)}" MonHoc="{data($mh/@TenMonHoc)}" Diem="{data($d/@Diem)}" />
     ') AS kq) T
CROSS APPLY T.kq.nodes('/ketqua') AS K(r)
GO
