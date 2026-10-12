# BÀI TẬP THỰC HÀNH TUẦN 5: XPATH, XQUERY

**Môn học:** IE103 – Quản lý Thông tin
**Sinh viên:** Họ tên – MSSV
**Môi trường thực hiện:** Microsoft SQL Server 2022
**File mã nguồn kèm theo:** `MSSV_HoTen_BTTH5.sql` (chạy được trọn vẹn từ đầu đến cuối)

---

## A. Chuẩn bị

CSDL `TEST_XML` được tạo đúng theo script của đề, gồm các bảng `KhoaHoc`, `SinhVien`, `MonHoc`, `KhoaHocMonHoc`, `Diem` và bảng `QuanLySV`. Cột `ChiTietSV` của bảng `QuanLySV` có kiểu `XML`. Bảng này có 2 dòng:

| MSDH | TenDH | ChiTietSV |
|---|---|---|
| 1 | DH CNTT | `<THONGTINSV>` gồm 3 sinh viên: Nam (ID 10), An (ID 11), Thanh (ID 12) |
| 2 | DH KHTN | `<THONGTINSV>` gồm 3 sinh viên: Khang (ID 10), Vinh (ID 11), Hoa (ID 12) |

Bài làm dùng các phương thức của kiểu dữ liệu XML trong SQL Server:

| Phương thức | Công dụng |
|---|---|
| `query('XQuery')` | Trả về một đoạn XML là kết quả của biểu thức XPath/XQuery |
| `value('XQuery', 'SqlType')` | Trả về một giá trị vô hướng (chuyển sang kiểu SQL) |
| `exist('XQuery')` | Trả về 1 nếu biểu thức có kết quả, 0 nếu không |
| `modify('XML DML')` | Sửa dữ liệu XML: `insert`, `delete`, `replace value of` |
| `nodes('XQuery')` | Tách mỗi nút thỏa biểu thức thành một dòng (dùng với `CROSS APPLY`) |

Các câu được chạy **theo đúng thứ tự** trong file `.sql`, nên các câu sau thấy được thay đổi do câu 6, 8, 10 tạo ra.

---

## B. Thực hành

### Câu 1. Lấy sinh viên có ID = 10 và sinh viên ở vị trí cuối cùng ở trường CNTT

```sql
-- a) Sinh viên có ID = 10 (ở cả hai trường)
SELECT MSDH, TenDH,
       ChiTietSV.query('/THONGTINSV/sinhvien[@ID = 10]') AS SinhVien_ID10
FROM QuanLySV

-- b) Sinh viên ở vị trí cuối cùng của trường DH CNTT
SELECT MSDH, TenDH,
       ChiTietSV.query('/THONGTINSV/sinhvien[last()]') AS SinhVien_CuoiCung
FROM QuanLySV
WHERE TenDH = 'DH CNTT'
```

**Kết quả a):**

| MSDH | TenDH | SinhVien_ID10 |
|---|---|---|
| 1 | DH CNTT | `<sinhvien ID="10" Ten="Nam"><monhoc ID="1" Ten="Co So Du Lieu"/><monhoc ID="2" Ten="Cau Truc Du Lieu"/><monhoc ID="3" Ten="Lap Trinh Mobile"/></sinhvien>` |
| 2 | DH KHTN | `<sinhvien ID="10" Ten="Khang"><monhoc ID="1" Ten="Co So Du Lieu"/><monhoc ID="2" Ten="Cau Truc Du Lieu"/><monhoc ID="3" Ten="Lap Trinh Mobile"/></sinhvien>` |

**Kết quả b):**

```xml
<!-- MSDH = 1, DH CNTT -->
<sinhvien ID="12" Ten="Thanh">
  <monhoc ID="7" Ten="Anh Van"/>
  <monhoc ID="8" Ten="Thiet Ke Web"/>
  <monhoc ID="9" Ten="An Toan Thong Tin"/>
</sinhvien>
```

**Giải thích:** `[@ID = 10]` là điều kiện lọc (predicate) trên thuộc tính `ID`. Hàm `last()` trả về vị trí của nút cuối cùng trong tập nút `sinhvien`. Vì vậy `sinhvien[last()]` lấy được sinh viên cuối cùng.

---

### Câu 2. Trả về tất cả các nút từ nút gốc là THONGTINSV

```sql
-- Cách 1: trả về nguyên cây XML bắt đầu từ nút gốc THONGTINSV
SELECT MSDH, ChiTietSV.query('/THONGTINSV') AS TatCaCacNut
FROM QuanLySV

-- Cách 2: liệt kê từng nút con cháu của THONGTINSV (mỗi nút một dòng)
SELECT Q.MSDH,
       N.c.value('local-name(.)', 'VARCHAR(20)')  AS TenNut,
       N.c.value('local-name(..)', 'VARCHAR(20)') AS NutCha,
       N.c.value('@ID', 'INT')                    AS ID,
       N.c.value('@Ten', 'VARCHAR(50)')           AS Ten
FROM QuanLySV Q
CROSS APPLY Q.ChiTietSV.nodes('/THONGTINSV//*') AS N(c)
```

**Kết quả cách 1** (dòng MSDH = 1, dòng MSDH = 2 có cấu trúc tương tự):

```xml
<THONGTINSV>
  <sinhvien ID="10" Ten="Nam">
    <monhoc ID="1" Ten="Co So Du Lieu"/>
    <monhoc ID="2" Ten="Cau Truc Du Lieu"/>
    <monhoc ID="3" Ten="Lap Trinh Mobile"/>
  </sinhvien>
  <sinhvien ID="11" Ten="An">
    <monhoc ID="4" Ten="Toan Giai Tich"/>
    <monhoc ID="5" Ten="Lap Trinh Java"/>
    <monhoc ID="6" Ten="He Quan Tri CSDL"/>
  </sinhvien>
  <sinhvien ID="12" Ten="Thanh">
    <monhoc ID="7" Ten="Anh Van"/>
    <monhoc ID="8" Ten="Thiet Ke Web"/>
    <monhoc ID="9" Ten="An Toan Thong Tin"/>
  </sinhvien>
</THONGTINSV>
```

**Kết quả cách 2** (24 dòng, trích 12 dòng của MSDH = 1):

| MSDH | TenNut | NutCha | ID | Ten |
|---|---|---|---|---|
| 1 | sinhvien | THONGTINSV | 10 | Nam |
| 1 | monhoc | sinhvien | 1 | Co So Du Lieu |
| 1 | monhoc | sinhvien | 2 | Cau Truc Du Lieu |
| 1 | monhoc | sinhvien | 3 | Lap Trinh Mobile |
| 1 | sinhvien | THONGTINSV | 11 | An |
| 1 | monhoc | sinhvien | 4 | Toan Giai Tich |
| 1 | monhoc | sinhvien | 5 | Lap Trinh Java |
| 1 | monhoc | sinhvien | 6 | He Quan Tri CSDL |
| 1 | sinhvien | THONGTINSV | 12 | Thanh |
| 1 | monhoc | sinhvien | 7 | Anh Van |
| 1 | monhoc | sinhvien | 8 | Thiet Ke Web |
| 1 | monhoc | sinhvien | 9 | An Toan Thong Tin |

**Giải thích:** `//*` chọn mọi phần tử con cháu ở mọi cấp bên dưới `THONGTINSV`. `nodes()` tách mỗi nút thành một dòng, sau đó `value()` đọc tên nút (`local-name`), tên nút cha và các thuộc tính của nút đó.

---

### Câu 3. Danh sách sinh viên có ID < 12 với MSDH = 1

```sql
SELECT MSDH, TenDH,
       ChiTietSV.query('
           for $sv in /THONGTINSV/sinhvien
           where $sv/@ID < 12
           return $sv
       ') AS SinhVien_ID_Nho_Hon_12
FROM QuanLySV
WHERE MSDH = 1
```

**Kết quả:**

```xml
<!-- MSDH = 1, DH CNTT -->
<sinhvien ID="10" Ten="Nam">
  <monhoc ID="1" Ten="Co So Du Lieu"/>
  <monhoc ID="2" Ten="Cau Truc Du Lieu"/>
  <monhoc ID="3" Ten="Lap Trinh Mobile"/>
</sinhvien>
<sinhvien ID="11" Ten="An">
  <monhoc ID="4" Ten="Toan Giai Tich"/>
  <monhoc ID="5" Ten="Lap Trinh Java"/>
  <monhoc ID="6" Ten="He Quan Tri CSDL"/>
</sinhvien>
```

**Giải thích:** Câu này dùng biểu thức FLWOR. `for` duyệt qua từng sinh viên, `where` lọc theo điều kiện `@ID < 12`, `return` trả về nút thỏa điều kiện. Điều kiện `MSDH = 1` đặt ở mệnh đề `WHERE` của SQL.

---

### Câu 4. Danh sách sinh viên sắp xếp theo tên với MSDH = 2

```sql
SELECT MSDH, TenDH,
       ChiTietSV.query('
           for $sv in /THONGTINSV/sinhvien
           order by string($sv/@Ten) ascending
           return <sinhvien ID="{data($sv/@ID)}" Ten="{data($sv/@Ten)}" />
       ') AS SinhVien_SapXepTheoTen
FROM QuanLySV
WHERE MSDH = 2
```

**Kết quả:**

```xml
<!-- MSDH = 2, DH KHTN -->
<sinhvien ID="12" Ten="Hoa"/>
<sinhvien ID="10" Ten="Khang"/>
<sinhvien ID="11" Ten="Vinh"/>
```

**Giải thích:** XPath không sắp xếp được kết quả, đó là lý do câu này phải dùng XQuery với mệnh đề `order by`. `string()` chuyển thuộc tính thành chuỗi để so sánh. Phần `return` tạo phần tử mới bằng constructor `{...}` để kết quả gọn hơn.

---

### Câu 5. Trả về MSDH và TenDH theo định dạng `<QuanLySV><ChiTietSV>1 DH CNTT</ChiTietSV></QuanLySV>`

```sql
SELECT ChiTietSV.query('
           <QuanLySV>
               <ChiTietSV>{ concat(string(sql:column("MSDH")), " ", sql:column("TenDH")) }</ChiTietSV>
           </QuanLySV>
       ') AS KetQua
FROM QuanLySV
```

**Kết quả:**

| KetQua |
|---|
| `<QuanLySV><ChiTietSV>1 DH CNTT</ChiTietSV></QuanLySV>` |
| `<QuanLySV><ChiTietSV>2 DH KHTN</ChiTietSV></QuanLySV>` |

**Giải thích:** `sql:column("TenCot")` đưa giá trị của cột quan hệ trên dòng hiện tại vào biểu thức XQuery. `concat()` ghép MSDH, một khoảng trắng và TenDH, rồi đặt kết quả vào phần tử `ChiTietSV`.

---

### Câu 6. Xóa tên các sinh viên trường DH KHTN

```sql
UPDATE QuanLySV
SET ChiTietSV.modify('delete /THONGTINSV/sinhvien/@Ten')
WHERE TenDH = 'DH KHTN'
```

**Trước khi xóa:**

```xml
<sinhvien ID="10" Ten="Khang"> ... </sinhvien>
<sinhvien ID="11" Ten="Vinh"> ... </sinhvien>
<sinhvien ID="12" Ten="Hoa"> ... </sinhvien>
```

**Sau khi xóa:**

```xml
<sinhvien ID="10">
  <monhoc ID="1" Ten="Co So Du Lieu"/>
  <monhoc ID="2" Ten="Cau Truc Du Lieu"/>
  <monhoc ID="3" Ten="Lap Trinh Mobile"/>
</sinhvien>
<sinhvien ID="11">
  <monhoc ID="4" Ten="Toan Giai Tich"/>
  <monhoc ID="5" Ten="Lap Trinh Java"/>
  <monhoc ID="6" Ten="He Quan Tri CSDL"/>
</sinhvien>
<sinhvien ID="12">
  <monhoc ID="7" Ten="Anh Van"/>
  <monhoc ID="8" Ten="Thiet Ke Web"/>
  <monhoc ID="9" Ten="An Toan Thong Tin"/>
</sinhvien>
```

**Giải thích:** Phương thức `modify()` dùng lệnh `delete` của XML DML để xóa thuộc tính `Ten` của **mọi** nút `sinhvien` trong trường DH KHTN. Thuộc tính `Ten` của các nút `monhoc` vẫn giữ nguyên, vì đường dẫn chỉ trỏ tới `sinhvien/@Ten`.

---

### Câu 7. Thông tin các sinh viên có tên là 'Nam' hoặc 'Thanh'

```sql
SELECT MSDH, TenDH,
       ChiTietSV.query('
           for $sv in /THONGTINSV/sinhvien
           where $sv/@Ten = "Nam" or $sv/@Ten = "Thanh"
           return $sv
       ') AS SinhVien_Nam_Thanh
FROM QuanLySV
WHERE ChiTietSV.exist('/THONGTINSV/sinhvien[@Ten = "Nam" or @Ten = "Thanh"]') = 1
```

**Kết quả:**

```xml
<!-- MSDH = 1, DH CNTT -->
<sinhvien ID="10" Ten="Nam">
  <monhoc ID="1" Ten="Co So Du Lieu"/>
  <monhoc ID="2" Ten="Cau Truc Du Lieu"/>
  <monhoc ID="3" Ten="Lap Trinh Mobile"/>
</sinhvien>
<sinhvien ID="12" Ten="Thanh">
  <monhoc ID="7" Ten="Anh Van"/>
  <monhoc ID="8" Ten="Thiet Ke Web"/>
  <monhoc ID="9" Ten="An Toan Thong Tin"/>
</sinhvien>
```

**Giải thích:** Mệnh đề `where` của FLWOR dùng toán tử `or`. Điều kiện `exist(...) = 1` trong mệnh đề `WHERE` của SQL bỏ những dòng không có sinh viên thỏa điều kiện, ở đây là trường DH KHTN.

---

### Câu 8. Đổi tên sinh viên thứ 2 thành 'Binh' trong trường CNTT

```sql
UPDATE QuanLySV
SET ChiTietSV.modify('replace value of (/THONGTINSV/sinhvien[2]/@Ten)[1] with "Binh"')
WHERE TenDH = 'DH CNTT'
```

**Kết quả:**

| | MSDH | TenDH | Tên sinh viên thứ 2 |
|---|---|---|---|
| Trước | 1 | DH CNTT | An |
| Sau | 1 | DH CNTT | Binh |

```xml
<sinhvien ID="11" Ten="Binh">
  <monhoc ID="4" Ten="Toan Giai Tich"/>
  <monhoc ID="5" Ten="Lap Trinh Java"/>
  <monhoc ID="6" Ten="He Quan Tri CSDL"/>
</sinhvien>
```

**Giải thích:** `replace value of` yêu cầu biểu thức đích trả về **đúng một** nút, vì vậy phải bọc đường dẫn trong `(...)[1]`. `sinhvien[2]` là sinh viên ở vị trí thứ 2.

---

### Câu 9. Kiểm tra có sinh viên ID = 12 trong trường KHTN không (có: 1, không: 0)

```sql
SELECT MSDH, TenDH,
       ChiTietSV.exist('/THONGTINSV/sinhvien[@ID = 12]') AS TonTai_ID12
FROM QuanLySV
WHERE TenDH = 'DH KHTN'
```

**Kết quả:**

| MSDH | TenDH | TonTai_ID12 |
|---|---|---|
| 2 | DH KHTN | 1 |

**Giải thích:** `exist()` trả về `1` vì trường KHTN vẫn có nút `<sinhvien ID="12">`. Câu 6 chỉ xóa thuộc tính `Ten`, còn thuộc tính `ID` vẫn giữ nguyên.

---

### Câu 10. Kiểm tra sinh viên 'Lan' trong trường CNTT, sau đó INSERT thêm sinh viên Lan

```sql
-- Kiểm tra
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
```

**Kết quả:**

| | MSDH | TenDH | TonTai_Lan |
|---|---|---|---|
| Trước khi INSERT | 1 | DH CNTT | 0 |
| Sau khi INSERT | 1 | DH CNTT | 1 |

```xml
<sinhvien ID="15" Ten="Lan">
  <monhoc ID="10" Ten="Toan Roi Rac"/>
  <monhoc ID="11" Ten="Lap Trinh C#"/>
  <monhoc ID="12" Ten="CSDL Nang Cao"/>
</sinhvien>
```

**Giải thích:** Lần kiểm tra đầu trả về `0`, nên lệnh `insert ... as last into` thêm nút mới vào cuối `THONGTINSV`. Câu lệnh `IF NOT EXISTS` bảo đảm không thêm trùng khi chạy lại. Đích của `into` phải là một nút duy nhất nên phải viết `(/THONGTINSV)[1]`.

---

### Câu 11*. Phép nối bằng XQuery: sinh viên nào học khóa học tên gì, sinh viên nào học môn học gì

**Ý tưởng:** Dữ liệu nằm trong các bảng quan hệ, nên trước hết dùng `FOR XML PATH` đưa 4 bảng `SinhVien`, `KhoaHoc`, `MonHoc`, `Diem` về chung một tài liệu XML. Sau đó dùng FLWOR với nhiều mệnh đề `for` và điều kiện nối trong `where`, tương tự `JOIN ... ON` của SQL.

```sql
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

-- a) Sinh viên học khóa học nào (tương đương SinhVien JOIN KhoaHoc)
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

-- b) Sinh viên học môn học nào (tương đương SinhVien JOIN Diem JOIN MonHoc)
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
```

**Tài liệu XML nguồn** (trích phần `SinhVien` và `KhoaHoc`):

```xml
<SinhVien>
  <sinhvien MSSV="1" TenSV="Anh" MaKhoaHoc="1"/>
  <sinhvien MSSV="2" TenSV="Son" MaKhoaHoc="2"/>
  <sinhvien MSSV="3" TenSV="Thuy" MaKhoaHoc="3"/>
</SinhVien>
<KhoaHoc>
  <khoahoc MaKhoaHoc="1" TenKhoaHoc="Mang May Tinh Truyen Thong"/>
  <khoahoc MaKhoaHoc="2" TenKhoaHoc="Khoa Hoc May Tinh"/>
  <khoahoc MaKhoaHoc="3" TenKhoaHoc="Ky Thuat May Tinh"/>
</KhoaHoc>
```

**Kết quả a) – sinh viên học khóa học nào:**

```xml
<SinhVien_KhoaHoc>
  <ketqua MSSV="1" TenSV="Anh" KhoaHoc="Mang May Tinh Truyen Thong"/>
  <ketqua MSSV="2" TenSV="Son" KhoaHoc="Khoa Hoc May Tinh"/>
  <ketqua MSSV="3" TenSV="Thuy" KhoaHoc="Ky Thuat May Tinh"/>
</SinhVien_KhoaHoc>
```

**Kết quả b) – sinh viên học môn học nào** (trình bày dạng bảng bằng `nodes()`/`value()`; câu lệnh đầy đủ có trong file `.sql`):

| TenSV | MonHoc | Diem |
|---|---|---|
| Anh | Co So Du Lieu | 75 |
| Anh | Cau Truc Du Lieu | 80 |
| Anh | Lap Trinh Di Dong | 70 |
| Son | Toan Giai Tich | 80 |
| Son | Lap Trinh Java | 80 |
| Son | He Quan Tri CSDL | 90 |
| Thuy | Anh Van | 80 |
| Thuy | Thiet Ke Web | 80 |
| Thuy | An Toan Thong Tin | 90 |

**Giải thích:** Nhiều mệnh đề `for` lồng nhau tạo ra tích Descartes giữa các tập nút. Mệnh đề `where $sv/@MaKhoaHoc = $kh/@MaKhoaHoc` giữ lại các cặp khớp khóa, giống phép kết bằng trong SQL. Câu b) nối ba tập nút qua bảng trung gian `Diem`, giống chuỗi `SinhVien JOIN Diem JOIN MonHoc`. Kết quả trùng với câu SQL tương đương:

```sql
SELECT SV.TenSV, MH.TenMonHoc, D.Diem
FROM SinhVien SV JOIN Diem D ON SV.MSSV = D.MSSV
                 JOIN MonHoc MH ON D.MaMonHoc = MH.MaMonHoc
```

---

## Tài liệu tham khảo

1. Bài giảng IE103 – Chương 3: Truy vấn thông tin (phần XPath/XQuery), Khoa KH&KT Thông tin, Trường ĐH CNTT – ĐHQG-HCM.
2. Tài liệu "Xquery, Xpath" kèm theo bài thực hành tuần 5.
3. Microsoft Learn, *xml Data Type Methods* (query, value, exist, modify, nodes) – SQL Server documentation.
4. W3C, *XQuery 3.1: An XML Query Language* – W3C Recommendation.
