# Quản trị CSDL và an toàn thông tin

---

### CHƯƠNG 3:
### XỬ LÝ THÔNG TIN TRÊN MÁY TÍNH:
### AN NINH DỮ LIỆU
### Khoa Khoa học và kỹ thuật thông tin
### Bộ môn Thiết bị di động và Công nghệ Web

---

## NỘI DUNG

1. Quản trị CSDL.
2. Phân quyền.
3. View.
4. Backup / Restore.
5. Import / Export.

---

## Quản trị CSDL


---

## Quản trị CSDL

- Quản trị dữ liệu là dùng các kỹ năng và thiết bị để tổ chức, làm an
toàn, lưu trữ và rút trích thông tin từ CSDL.
- Hệ quản trị CSDL:
  - Hệ quản trị CSDL là một chương trình máy tính mà tạo ra các
danh mục, chỉ mục, nắm bắt, và lưu trữ dữ liệu, duy trì tính
toàn vẹn của nó, và kết xuất kết quả ở dạng mong muốn của
người dùng.
  - Mục đích chung của nó là để tổ chức và quản lý dữ liệu, và làm
cho nó có sẵn theo yêu cầu.
https://itviec.com/blog/database-administrator-la-gi/

---

## Quản trị CSDL

1. Cài đặt, cấu
hình hệ thống
CSDL
Cài đặt các hệ quản
trị CSDL như SQL
Server, Oracle,
MySQL...
Cấu hình tham số
hệ thống
2. Thiết kế,
xây dựng
CSDL
Tạo và quản lý cấu
trúc bảng, chỉ mục,
quan hệ, trigger,
stored procedure…
Xây dựng, cập nhật
lược đồ dữ liệu
(schema)
3. Quản lý dữ
liệu
Nhập/xuất dữ liệu
(Import/Export)
Sao lưu (backup)
và phục hồi
(restore) dữ liệu khi
xảy ra sự cố
Kiểm tra tính toàn
vẹn và nhất quán
của dữ liệu
4. Quản lý
bảo mật
Phân quyền người
dùng, quản lý
quyền truy cập
Giám sát bảo mật
và phát hiện các
truy cập trái phép
vào hệ thống dữ
liệu
Mã hóa dữ liệu
quan trọng

---

## Quản trị CSDL

5. Giám sát và
tối ưu hóa
hiệu suất
Theo dõi tình trạng
hoạt động của
CSDL
Phân tích và tối ưu
hóa truy vấn, cấu
hình server
Quản lý tài nguyên
như CPU, bộ nhớ,
ổ cứng…
6. Xử lý lỗi và
sự cố
Phát hiện sớm các
lỗi tiềm ẩn, xử lý
nhanh chóng các
vấn đề phát sinh
Lên kế hoạch dự
phòng, xây dựng
các kịch bản khôi
phục thảm họa
(Disaster Recovery)
7. Hỗ trợ phát
triển ứng
dụng
Tư vấn, hỗ trợ các
lập trình viên về
thiết kế và tối ưu
hóa câu truy vấn
Phối hợp triển khai
các bản cập nhật
và nâng cấp CSDL

---

## Quản trị CSDL


---

## Mục tiêu chính của quản trị CSDL

- Đảm bảo an toàn, toàn vẹn và tính sẵn sàng của dữ liệu.
- Phân quyền truy cập đúng người, đúng nhiệm vụ.
- Giám sát hoạt động và bảo trì hệ thống CSDL.

---

## Các công việc chính

của người quản trị CSDL
- Tạo tài khoản người dùng (Account).
- Phân quyền người người dùng (Permission).
- Sao lưu-Khôi phục dữ liệu (Backup-Restore).
- Nhập-Xuất dữ liệu (Import-Export).
- Giám sát CSDL.

---

## Phân quyền Database


---

## Các mức truy xuất của người dùng

- Quyền truy xuất đến Server chứa CSDL.
VD: truy xuất đến MySQL, SQL server cần đăng nhập bằng tài khoản
- Truy xuất đến CSDL nào trên Server.
VD: một server có nhiều db như: QLBH, QLGV, ... è có quyền truy cập đối với
database nào.
- Truy xuất đến đối tượng nào trên mỗi CSDL (tables, views,
procedures. . .).
VD: chỉ xem được bảng, không được xoá. Có thể tạo View.
- Có hành động gì trên đối tượng đó (create, alter, select, insert, ...)
VD: chỉ được select trên bảng KETQUA, không được sửa/xóa (update, delete)

---

## Tài khoản mặc định trong SQL Server

- Tài khoản login mặc định là các tài khoản do nhà sản xuất đã tạo
ra sẵn trên các hệ quản trị CSDL.
- Có 2 tài khoản login mặc định trong SQL Server:
  - Sa.
  - Built-in\Administrators.
- Sa (System Admin) là tài khoản đặc biệt có tất cả quyền trên
SQL Server và Database.
- Built-in\Administrators là tài khoản mặc định cho tất cả admin
của WinNT, có tất cả quyền trên SQL Server và Database.

---

## Tài khoản mặc định trong SQL Server

- Dùng sp_addlogin:
  - Cú pháp: sp_addlogin ‘login’, ‘password’, ’Database’.
  - Ví dụ: sp_addlogin ‘anh’, ‘nothing’, ’congchung’.
  - Tên: anh; mật khẩu: nothing; CSDL mặc định: congchung.
- Thông tin trên được giữ trong table syslogins của csdl master.
- Để dùng CSDL trên SQL Server, người dùng phải kết nối với SQL
Server thông qua 1 tài khoản login :
- Tài khoản login có thể là:
  - Tài khoản WinNT.
  - Tài khoản mặc định.
  - Tài khoản login SQL Server do User tạo ra.

---

## CSDL mặc định và TK mặc định

- CSDL mặc định là gì?
  - Khi thêm 1 tài khoản (account) thường được gán tới 1 CSDL
mặc định, nhưng chưa cấp cụ thể các quyền hạn. Nếu không
gán CSDL mặc định thì CSDL master là CSDL mặc định.
- Tài khoản người dùng mặc định trong CSDL:
  - Mỗi CSDL trong SQL Server có 2 tài khoản CSDL mặc định:
dbo và guest.

---

## Thêm 1 tài khoản Login

Windows authentication
- Cú pháp:
`CREATE LOGIN`
[ten_mien\ten_dangnhap]
FROM WINDOWS
[ WITH DEFAULT_DATABASE =
ten_cosodulieu
| DEFAULT_LANGUAGE = ten_ngonngu];
SQL authentication
- Cú pháp:
`CREATE LOGIN ten_dangnhap`
WITH PASSWORD = { ‘matkhau’ |
matkhau_bam HASHED } [
MUST_CHANGE]
[ , SID = giatri_duynhat
| DEFAULT_DATABASE =
ten_cosodulieu
| DEFAULT_LANGUAGE = ten_ngonngu
| CHECK_EXPIRATION = { ON | OFF }
| CHECK_POLICY = { ON | OFF }
| CREDENTIAL = ten_chungthuc];

---

## Thêm 1 tài khoản Login

Windows authentication
- Ví dụ
`CREATE LOGIN`
[test_tenmien\quantrimang]
FROM WINDOWS;
SQL authentication
- Ví dụ:
`CREATE LOGIN quantrimang`
WITH PASSWORD = ‘mk123’;

---

## Thêm 1 tài khoản user DB

- Cú pháp:
`CREATE USER user_name FOR LOGIN login_name;`
Trong đó:
user_name: Tên của database user mà bạn muốn tạo.
login_name: Tên Login được sử dụng để kết nối đến SQL
Server cụ thể.
Lưu ý: phải tạo tài khoản login trước đó.
VD:
`CREATE USER DB_qtm FOR LOGIN quantrimang;`

---

## Ý nghĩa

- Tài khoản Login trong SQL Server là danh tính được sử dụng để
kết nối và xác thực với SQL Server. Nó cho phép người dùng
hoặc ứng dụng truy cập SQL Server. Sau khi xác thực, thông tin
login có thể truy CSDL tùy thuộc vào quyền được chỉ định.
- Tóm lại:
  - Tài khoản login là thông tin xác thực để xác thực với SQL
Server.
  - Login phải được ánh xạ tới người dùng (User) CSDL để có
được các quyền cụ thể trong CSDL.

---

## DBO là gì ?

- Tài khoản login sa và các thành viên sysadmin được ánh xạ tới 1
tài khoản đặc biệt trong tất cả CSDL là DBO (database owner).
- Bất cứ 1 đối tượng nào mà người quản trị tạo ra tự động thuộc về
dbo.

---

## Role là gì

- Role cung cấp con đường để tập hợp các người dùng vào 1 đơn
thể mà những quyền hạn trên Server được áp dụng.
- Role trong SQL Server
  - SQL Server cung cấp một số role cố định trên server và CSDL
để dễ dàng cho việc phân chia.
  - Với các CSDL phức tạp các role cố định không phản ánh hết
SQL Server cho phép tạo các role đại diện cho 1 lớp người.
- Có 2 loại role chính:
  - Role trên server (server role).
  - Role trên database (database role).

---

## Server role

Các server role cố định thông thường trên SQLServer
Role Mô tả
SysAdmin Thực hiện mọi hoạt động trên Server
ServerAdmin Có thể tạo Cấu hình
SetupAdmin Có thể Install bản sao
SecurityAdmin Quản lí các Login
ProcessAdmin Quản lí các tiến trình trong Server
DbCreator Tạo và thay đổi CSDL
DiskAdmin Quản lí các File trên đĩa
Quyền Sysadmin bao trùm tất cả quyền còn lại, login với sa.
Các quyền trên quản lí độc lập với CSDL và lưu giữ trong Master
Không thể thêm các role trên server.

---

## Thêm login vào server role

- Sử dụng hàm: sp_addsrvrolemember
- Cú pháp:
sp_addsrvrolemember ‘login_name’, ‘role_name’
- Ví dụ: Thêm user “loc” vào role “securityadmin”
sp_addsrvrolemember ‘loc’, ‘securityadmin’

---

## Lưu ý về server role

- Khi một login được thêm vào một server role cố định, nó sẽ có
được các quyền liên quan đến vai trò đó.
- sp_addsrvrolemember không thể được thực hiện trong các
Transaction do người dùng tự định nghĩa.
- Cần phải có tư cách thành viên trong role mà thành viên mới
được thêm vào.

---

## Database role

Các role cố định thông thường trên SQLServer
db_owner Thực hiện mọi hoạt động của mọi role CSDL.
db_accessadmin Thêm, xoá người dùng NT, SQL Server và nhóm người dùng NT.
db_datareader Đọc mọi dữ liệu của các table người dùng trong CSDL.
db_writer Thêm, đổi, xoá dữ liệu của các table người dùng trong CSDL.
db_ddladmin Thêm, đổi, xoá các đối tượng.
db_securityadmin Quản lý các role và các thành viên của role CSDL, quản lý quyền
hạn trên các đối tượng.
db_backupoperator Backup database.
db_denydatawriter Không thể thay đổi bất kỳ DL nào.

---

## Thêm role cho database

- Hàm: sp_addRoleMember.
- Cú pháp:
Exec sp_addRoleMember ‘TenUser’, ‘Kiểu Role’
(server role: Exec sp_addsrvrolemember ‘login’, ‘role’)
- Vd: Thêm role đọc mọi dữ liệu trên database cho user “TuanAnh”
Exec sp_addRoleMember ‘TuanAnh’, ‘db_dataReader’
- Chú ý
  - Các role cố định trên CSDL không thể xóa, sửa.
  - Bất cứ thành viên của 1 role nào đều có thể cấp cho 1 login
vào role đó.

---

## Tạo 1 database role mới

- Cú pháp:
`CREATE ROLE role_name [ AUTHORIZATION owner_name ]`
role_name: Là tên của vai trò (role) sẽ được tạo.
AUTHORIZATION owner_name
Là người dùng CSDL hoặc vai trò (role) sẽ sở hữu vai trò mới được
tạo ra. Nếu không chỉ định người dùng nào, vai trò mới sẽ thuộc sở
hữu của người dùng thực hiện câu lệnh CREATE ROLE. Chủ sở
hữu của vai trò hoặc bất kỳ thành viên nào của vai trò sở hữu đều
có thể thêm hoặc xóa thành viên của vai trò này.

---

## Tạo 1 database role mới

- VD1: Tạo một vai trò CSDL tên là buyers, vai trò này được sở hữu
bởi người dùng có tên BenMiller.
`CREATE ROLE buyers AUTHORIZATION BenMiller;`
- VD2: Tạo một vai trò CSDL tên là auditors, vai trò này được sở hữu
bởi vai trò CSDL cố định db_securityadmin.
`CREATE ROLE auditors AUTHORIZATION db_securityadmin;`

---

## Lưu ý

`CREATE ROLE auditors AUTHORIZATION db_securityadmin;`
- Vai trò (role) auditors được tạo ra và thuộc quyền sở hữu
(ownership) bởi vai trò db_securityadmin.
- Chủ sở hữu (owner) của một role có quyền:
  - Thêm/xóa thành viên trong role.
  - Xóa role hoặc thay đổi quyền hạn, quản lý role đó.
- Tuy nhiên, điều này KHÔNG CÓ nghĩa là role mới được tạo sẽ kế
thừa tự động các quyền từ chủ sở hữu của nó.

---

## Lưu ý

- Giả sử ta có role db_securityadmin:
  - Quyền: Quản lý các quyền hạn bảo mật trong CSDL (cấp phép
hoặc hủy quyền).
- Khi tạo role mới auditors sở hữu bởi db_securityadmin:
  - Role auditors lúc này chưa được cấp bất kỳ quyền cụ thể nào.
  - Role db_securityadmin (và các thành viên của nó) chỉ đơn giản
là có quyền quản lý role auditors, như:
• Thêm/xóa thành viên trong role auditors.
• Xóa hoặc quản lý các thuộc tính của role auditors.

---

## Lưu ý

- Muốn auditors có quyền cụ thể (ví dụ SELECT, UPDATE,
INSERT), ta phải sử dụng thêm câu lệnh cấp quyền riêng:
- VD: GRANT SELECT ON dbo.Employees TO auditors;
- Tóm lại:
  - Sở hữu (ownership) ≠ Kế thừa quyền (permission inheritance).
  - Trong SQL Server, vai trò không tự động kế thừa quyền từ vai trò
sở hữu nó. Muốn có quyền cụ thể, ta phải gán quyền trực tiếp
bằng các câu lệnh GRANT, DENY, REVOKE.

---

## Tóm lại

Login User Role
Ý nghĩa
Được tạo ở cấp độ SQL
Server (Có thể là SQL Server
/ Windows Authentication)
- Login phải ánh xạ với user trong
từng CSDL để truy cập được
- Mỗi CSDL cần tạo riêng 1 user
cho login đó
- Tập hợp các quyền có thể gán
cho nhiều user
- Giúp quản lý quyền dễ dàng và
linh hoạt hơn
Ví dụ
`CREATE LOGIN NgDungA`
WITH PASSWORD =
'123456'
USE QUANLYBANHANG
`CREATE USER NgDungA FOR`
LOGIN NgDungA
`CREATE ROLE XemBaoCao`
`GRANT SELECT ON HOADON`
TO XemBaoCao
EXEC sp_addrolemember
'XemBaoCao', ‘NgDungA'

---

## Các nhóm quyền hạn

- Vấn đề:
  - Để cho phép người dùng truy xuất hay tạo ra các đối tượng
trên Server, người dùng phải được gán quyền hạn trên các
đối tượng.
- Có 3 nhóm quyền hạn:
  - Phát biểu.
  - Đối tượng.
  - Mặc định.

---

## Các thao tác phân quyền

- Có 3 thao tác chính khi phân quyền trên database:
  - Cấp quyền.
  - Từ chối quyền.
  - Thu hồi quyền.
- Để thực hiện các thao tác phân quyền, ta sử dụng các nhóm lệnh
trong nhóm DCL (Data Control Language) của ngôn ngữ SQL.
  - GRANT: cấp quyền.
  - DENY: từ chối quyền.
  - REVOKE: thu hồi quyền.

---

## Cấp quyền (Grant)

- Đang ở DB nào thì cấp quyền trên DB đó.
- Quyền để cấp quyền hạn cho các role và user mặc định là các
thành viên của : sysadmin, db_owner, db_security.
- Quyền phát biểu Create database chỉ có thể cấp cho User và role
trong Master DB.
- Cú pháp:
`GRANT { các quyền hạn , . . .`
On các đối tượng ,
To các role, user }
Ví dụ :
`GRANT insert , update, delete On KhachHang to KETOAN`

---

## Từ chối quyền (Deny)

- Đang ở DB nào thì cấp quyền trên DB đó.
- Quyền để từ chối quyền hạn cho các role và user mặc định là
các thành viên của : sysadmin, db_owner, db_security.
- Cú pháp :
`DENY { các quyền hạn , . . .`
On các đối tượng ,
To các role, user }
- Ví dụ:
`DENY insert , update, delete On KhachHang to GIAMDOC`

---

## Thu hồi quyền (Revoke)

- Đang ở DB nào thì cấp quyền trên DB đó.
- Quyền để thu hồi quyền hạn cho các role và user mặc định là các
thành viên của : sysadmin, db_owner, db_security.
- Cú pháp:
`REVOKE {các quyền hạn , . . .`
On các đối tượng ,
From các role, user }
- Ví dụ:
`REVOKE insert , update On KhachHang From DIEUHANH`

---

## CSDL QUẢN LÝ BÁN HÀNG

KHACHHANG (MAKH, HOTEN, DCHI, SODT, NGSINH, DOANHSO, NGDK)
NHANVIEN (MANV, HOTEN, NGVL, SODT)
SANPHAM (MASP, TENSP, DVT, NUOCSX, GIA)
HOADON (SOHD, NGHD, MAKH, MANV, TRIGIA)
CTHD (SOHD, MASP, SL)

---

## CSDL QUẢN LÝ BÁN HÀNG

`CREATE LOGIN NVBanHang WITH PASSWORD = ‘Sale2025!’`
USE QUANLYBANHANG
`CREATE USER NVBanHang FOR LOGIN NVBanHang`

---

## CSDL QUẢN LÝ BÁN HÀNG

- Cho phép xem bảng sản phẩm
`GRANT SELECT ON SANPHAM TO NVBanHang`
- Cho phép thêm, xem hóa đơn
`GRANT SELECT, INSERT ON HOADON TO NVBanHang`
`GRANT SELECT, INSERT ON CTHD TO NVBanHang`
- Cho phép xem thông tin khách hàng (từ bảng KHÁCH HÀNG)
`GRANT SELECT ON KHACHHANG TO NVBanHang`

---

## CSDL QUẢN LÝ BÁN HÀNG

- Nếu muốn dễ dàng quản lý hơn, có thể tạo một ROLE chung trước, rồi sau đó
thêm user vào role này:
`CREATE ROLE RoleBanHang`
- Cấp quyền cho role
  - GRANT SELECT ON SANPHAM TO RoleBanHang
  - GRANT SELECT, INSERT ON HOADON TO RoleBanHang
  - GRANT SELECT, INSERT ON CTHD TO RoleBanHang
  - GRANT SELECT ON KHACHHANG TO RoleBanHang
- Thêm user vào role:
  - ALTER ROLE RoleBanHang ADD MEMBER NVBanHang
  - Hoặc: SP_ADDROLEMEMBER ‘RoleBanHang’, ‘NVBanHang’

---

## Khung nhìn (View)


---

## Giới thiệu

- Bảng (Table) là một quan hệ được tổ chức lưu trữ vật lý trong
CSDL.
- Khung nhìn (View) cũng là một quan hệ:
  - Là bảng ảo (không được lưu trữ vật lý).
  - Không chứa dữ liệu.
  - Được định nghĩa từ những bảng khác.
  - Có thể truy vấn hay cập nhật thông qua View.

---

## MỤC ĐÍCH

- Che dấu tính phức tạp của dữ liệu.
- Đơn giản hóa các câu truy vấn.
- Hiển thị dữ liệu dưới dạng tiện dụng nhất.
- An toàn dữ liệu.

---

## Định nghĩa View

- Cú pháp
  - Tạo View:
  - Xóa View:
- Bảng ảo này có:
  - Danh sách thuộc tính trùng với các thuộc tính trong mệnh đề SELECT.
  - Số dòng phụ thuộc vào điều kiện ở mệnh đề WHERE.
  - Dữ liệu được lấy từ các bảng ở mệnh đề FROM.
`CREATE VIEW <tên khung nhìn> AS`
<câu truy vấn>
DROP VIEW <tên khung nhìn>

---

## VÍ DỤ VIEW

`CREATE VIEW TONGTG_SLNV_DA AS`
`SELECT MADA, TENDA, COUNT(*) AS SLNV,`
SUM(THOIGIAN) AS TONGTG
FROM DEAN, PHANCONG
WHERE MADA=SODA
GROUP BY MADA, TENDA
`CREATE VIEW DEAN_P5 AS`
`SELECT MADA, TENDA, DDIEM_DA`
FROM DEAN
WHERE PHONG=5
Vd 32
Vd 33

---

## Truy vấn trên View

- Không chứa dữ liệu nhưng được truy xuất như một bảng
- Có thể viết câu truy vấn dữ liệu từ View và bảng
`SELECT * FROM DEAN_P5 WHERE DDIEM_DA=‘TP HCM’`
`SELECT MA_NVIEN FROM DEAN_P5, PHANCONG`
WHERE MADA=SODA

---

## Cập nhật trên View

- Đối với View đơn giản được xây dựng trên 1 bảng và có khóa
chính của bảng: có thể dùng các câu lệnh INSERT, DELETE và
UPDATE.
- Không thể cập nhật trên View nếu View:
  - dùng từ khóa DISTINCT.
  - sử dụng các hàm kết hợp.
  - có mệnh đề SELECT mở rộng.
  - được xây dựng từ bảng có ràng buộc trên cột.
  - được xây dựng từ nhiều bảng.

---

## Ví dụ

VD: Thống kê doanh thu theo khách hàng
`CREATE VIEW vw_ThongKeDoanhThuKH AS`
`SELECT KH.MAKH, KH.HOTEN,`
COUNT(HD.SOHD) AS SoHoaDon,
SUM(HD.TRIGIA) AS TongTienMua
FROM KHACHHANG KH
LEFT JOIN HOADON HD ON KH.MAKH = HD.MAKH
GROUP BY KH.MAKH, KH.HOTEN
è SELECT * FROM vw_ThongKeDoanhThuKH
không cần quan tâm các bảng liên quan
(JOIN thế nào, tính toán ra sao).

---

## Ví dụ

VD: Lấy thông tin chi tiết của một hóa đơn
`CREATE VIEW vw_ChiTietHoaDon AS`
`SELECT HD.SOHD, HD.NGHD, KH.HOTEN AS TenKH,`
NV.HOTEN AS TenNV, SP.MASP, SP.TENSP, CTHD.SOLUONG,
SP.GIA, (CT.SOLUONG * SP.GIA) AS THANHTIEN
FROM HOADON HD
JOIN KHACHHANG KH ON HD.MAKH = KH.MAKH
JOIN NHANVIEN NV ON HD.MANV = NV.MANV
JOIN CTHD ON HD.SOHD = CTHD.SOHD
JOIN SANPHAM SP ON CTHD.MASP = SP.MASP
`SELECT * FROM`
vw_ThongTinChiTietHoaDon
WHERE SOHD = 1001

---

## Ví dụ

VD: Lấy thông tin khách hàng nhưng không hiển thị Số điện thoại
và ngày sinh
`CREATE VIEW vw_ThongTinKhachHang`
AS
`SELECT MAKH, HOTEN, DCHI, NGDK`
FROM KHACHHANG
è SELECT * FROM vw_ThongTinKhachHang

---

## Ví dụ

VD: Ẩn thông tin lương trong bảng nhân viên
`CREATE VIEW vw_NhanVien_CongKhai`
AS
`SELECT MANV, HOTEN, SODT, NGAYSINH, DIACHI`
FROM NHANVIEN
Sau đó chỉ cấp quyền SELECT trên View, không cấp trên bảng
NHANVIEN
`GRANT SELECT ON vw_NhanVien_CongKhai TO NguoiDungA`

---

## Ví dụ

VD: Che 1 phần số điện thoại
`CREATE VIEW vw_KhachHang_AnSoDT AS`
`SELECT MAKH, HOTEN,`
STUFF(SODT, 4, 5, 'xxxxx') AS SODT,
NGDK
FROM KHACHHANG
è Kết quả ra: 038xxxxx92

---

## BACKUP/RESTORE


---

## GIỚI THIỆU

- Vì sao cần Backup?
  - Dữ liệu mất mát và hư hỏng là đáng quan tâm. Server dùng cơ
chế Backup để làm giảm tối thiểu việc dữ liệu hư hỏng và mất mát
- Ngăn chặn dữ liệu mất mát:
  - Cần xây dựng chiến lược backup nhằm giảm tối thiểu DL mất và
có thể khôi phục dữ liệu mất .
  - Dữ liệu bị mất có thể do các lí do sau :
• Phát biểu Delete.
• Phát biểu Update.
• Virus.
• Trộm cắp, thiên tai.

---

## Các loại Backup chính

- Full Backup
  - Sao lưu toàn bộ cơ sở dữ liệu
  - Là loại cơ bản, nền tảng cho các loại khác
- Differential Backup
  - Sao lưu phần dữ liệu thay đổi kể từ lần full backup gần nhất
  - Tăng tốc backup, giảm dung lượng
- Transaction Log Backup
  - Sao lưu nhật ký giao dịch, giúp phục hồi đến thời điểm chính xác
  - Phục hồi chi tiết, dùng cho hệ thống quan trọng

---

## Full Backup

- Full Backup
`BACKUP DATABASE QuanLyDeTai`
TO DISK = 'D:\Backup\QuanLyDeTai_Full.bak'
WITH INIT, FORMAT

---

## Differential Backup

- Differential Backup
`BACKUP DATABASE QuanLyDeTai`
TO DISK = 'D:\Backup\QuanLyDeTai_Diff.bak'
WITH DIFFERENTIAL

---

## Transaction Log Backup

- Transaction Log Backup
`BACKUP DATABASE QuanLyDeTai`
TO DISK = 'D:\ Backup\QuanLyDeTai_Full.bak’
WITH INIT, FORMAT
`BACKUP LOG QuanLyDeTai`
TO DISK = 'D:\ Backup\QuanLyDeTai_Full.trn’
Lưu ý: CSDL phải ở FULL Recovery Model mới dùng được log backup.

---

## Recovery Model

Có thể dùng
Log Backup?
Ứng dụng
Simple Không
Hệ thống không quan trọng, không cần
phục hồi chi tiết
Full Có
Hệ thống quan trọng, cần phục hồi đến
từng phút
Bulk-logged Có (Hạn chế) Khi import dữ liệu lớn, giảm log tạm thời

---

## Recovery Model

- Kiểm tra Recovery Model
`SELECT name, recovery_model_desc FROM sys.databases`
- Đổi sang Full
ALTER DATABASE QuanLyDeTai SET RECOVERY FULL

---

## BACKUP TRONG SQL SERVER

Bước 1 Bước 2

---

## BACKUP TRONG SQL SERVER

Bước 3 Bước 4

---

## BACKUP TRONG SQL SERVER

Bước 5

---

## Restore

- Khôi phục dữ liệu là đưa dữ liệu từ trạng thái nhất quán sau cùng
về trạng thái bình thường.
- Khôi phục không nhất thiết được dùng khi CSDL hỏng.
- Đối với một người quản trị CSDL, thao tác backup/restore là thao
tác bắt buộc.
https://itviec.com/blog/database-administrator-la-gi/

---

## Restore Full

- Restore Full
`RESTORE DATABASE QuanLyDeTai`
FROM DISK = 'D:\Backup\QuanLyDeTai_Full.bak'
WITH REPLACE

---

## Restore Full + Differential

- Restore Full + Differential
`RESTORE DATABASE QuanLyDeTai`
FROM DISK = 'D:\Backup\QuanLyDeTai_Full.bak'
WITH NORECOVERY
`RESTORE DATABASE QuanLyDeTai`
FROM DISK = 'D:\Backup\QuanLyDeTai_Diff.bak'
WITH RECOVERY

---

## Restore Point-in-time

- Restore Point-in-time
`RESTORE DATABASE QuanLyDeTai`
FROM DISK = 'D:\Backup\QuanLyDeTai_Full.bak'
WITH NORECOVERY
`RESTORE LOG QuanLyDeTai`
FROM DISK = 'D:\Backup\ QuanLyDeTai_Full.trn'
WITH STOPAT = '2025-03-27 07:30:00', RECOVERY

---

## Restore trong SQL Server

Bước 1 Bước 2

---

## Import/Export


---

## Tổng quan

- Import dữ liệu trong một hệ QTCSDL: Là sao chép dữ liệu từ
nguồn A tới đích B, trong đó B là một hệ QTCSDL.
- Export dữ liệu trong một hệ QTCSDL: Là sao chép dữ liệu từ
nguồn A tới đích B, trong đó A là một hệ QTCSDL.
- Đây là một thao tác có thể gặp trong thực tế.
- A, B có thể khác hệ quản trị.
- Các định dạng mà các hệ quản trị thường hỗ trợ khi import/export:
  - Comma separated values (.csv).
  - Excel (.xls).
  - SQL script (.sql).

---

## Ví dụ 1

- Ví dụ 1 sẽ trình bày từng bước thực hiện import CSDL từ hệ quản
trị Microsoft Access sang hệ quản trị SQL Server.

---

## Import data từ MS Access sang SQL

Server
Bước 1 Bước 2

---

## Import data từ MS Access sang SQL

Server
Bước 3 Bước 4

---

## Import data từ MS Access sang SQL

Server
Bước 5 Bước 6

---

## Import data từ MS Access sang SQL

Server
Bước 7 Bước 8

---

## Import data từ MS Access sang SQL

Server
Bước 9: Kiểm tra

---

## Ví dụ 2

- Ví dụ 2 sẽ trình bày từng bước export dữ liệu từ hệ quản trị SQL
server sang hệ quản trị MS Access

---

## Export data từ SQL Server sang MS

Access
Bước 1 Bước 2

---

## Export data từ SQL Server sang MS

Access
Bước 3 Bước 4

---

## Export data từ SQL Server sang MS

Access
Bước 5 Bước 6

---

## Export data từ SQL Server sang MS

Access
Bước 7 Bước 8: Kiểm tra trong access

---

## Tổng kết

- Quản trị CSDL là dùng các kỹ năng và thiết bị để tổ chức, làm an
toàn, lưu trữ và rút trích thông tin từ CSDL.
- Các thao tác chính khi quản trị dữ liệu:
  - Phân quyền.
• Quyền trên server: server role.
• Quyền trên database: database role.
  - Backup/restore.
  - Import/export.

---

## TÀI LIỆU THAM KHẢO

1. Nguyễn Gia Tuấn Anh, Trương Châu Long, Bài tập và bài giải
SQL Server, NXB Thanh niên (2005).
2. Đỗ Phúc, Nguyễn Đăng Tỵ, Cơ sở dữ liệu, NXB Đại học quốc gia
TPHCM (2010).
3. Nguyễn Gia Tuấn Anh, Mai Văn Cường, Bùi Danh Hường, Cơ sở
dữ liệu nâng cao, NXB Đại học quốc gia TPHCM (2019).
4. Itzik Ben-Gan, Microsoft SQL Server 2012- TSQL Fundamentals.

---

## Bài tập

- Bài tập 1.
  - Chọn 1 file dữ liệu (SV) từ excel, và import vào SQLServer
  - Chọn 1 table trong SQL Server, và export tới file Excel.
- Bài tập 2
  - Backup 1 CSDL từ SQL server trên máy tính A vào đĩa USB,
đặt tên a.bak
  - Hãy restore file a.bak từ USB vào SQLServer trên máy tính B.

---

## Bài tập

- Bài tập 3
  - Tạo 6 user từ u1 đến u6
  - Tạo 3 role từ r1 đến r3
  - Tạo nhóm: u1, u2 thuộc r1; u3, u4 thuộc r2; u5, u6 thuộc r3
  - Phân quyền cho r1, r2, r3
• R1 thành viên của SysAdmin
• R2 thành viên của db_owner, db_accessadmin
• R3 thành viên của SysAdmin, db_owner, db_accessadmin

---

## Bài tập

- Bài tập 4
  - Tập làm các phát biểu grant, deny, revoke trên một CSDL gồm
các table 1, T2, T3. . .đã biết
  - U1 có quyền select, delete trên T1, T3
  - U2 có quyền update, delete trên T2
  - U3 có quyền insert trên T1, T2, T3
  - U1 bị từ chối quyền insert trên T1, T2

---
