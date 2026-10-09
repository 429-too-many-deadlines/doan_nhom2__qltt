# Bài tập thực hành môn Quản lý thông tin tuần 3

**Bài tập 1.** Tìm hiểu các vấn đề sau trên HQT CSDL SQLServer:

## A. TỔ CHỨC DỮ LIỆU

1. Các kiểu dữ liệu (data type) dùng cho các trường (field) và cách sử dụng nó.
2. Dung lượng (KB) tối đa của 1 row trong 1 table mà SQL Server.
3. Dung lượng (KB) tối đa của 1 table mà SQL Server cho phép.
4. Tìm hiểu ý nghĩa các table hệ thống (System tables) trong CSDL Master như: Sysusers; Syssserver; Sysxlogin.
5. Khi người dùng tạo 1 CSDL, SQL Server yêu cầu tạo ra tối thiểu bao nhiêu file? Ý nghĩa mỗi file? Chú ý câu lệnh: `CREATE DATABASE AAA`.
6. Số user có thể connect cùng 1 thời điểm là bao nhiêu?

## B. AN TOÀN DỮ LIỆU

7. Hãy backup CSDL AAA thành 1 file `AAA.BAK`, sau đó xóa CSDL AAA và hãy khôi phục AAA nhờ vào `AAA.BAK`.

**Thực hiện bằng 2 cách:**
- **Cách 1:** Dùng giao diện. Yêu cầu: Chụp màn hình các bước thực hiện (Chụp đúng phần cần thiết và rõ nét, có thể dùng công cụ Snipping Tool).
- **Cách 2:** Dùng câu lệnh. Yêu cầu: Dùng các lệnh SQL để thực hiện.

**Chú ý:** Thực hiện bằng cả 2 cách **CHO MỖI THAO TÁC**: Backup (Sao lưu), Delete (Xóa) và Restore (Phục hồi).

8. Hãy đọc SQL Server Log trong phần SQL Enterprice -> Management -> SQL Server Log. Trình bày màn hình các bước thực hiện và ý nghĩa của mỗi trường thông tin trong bảng Log.

9. Cho bảng **Employees** có cấu trúc như sau:
```sql
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    BirthDate DATE NOT NULL,
    HireDate DATE NOT NULL
)
GO
```

Giả sử tạo 1 View tên là **EmployeeNames** như sau:
```sql
CREATE VIEW EmployeeNames
AS
    SELECT FirstName, LastName
    FROM Employees
```

Hỏi câu lệnh Insert dưới đây có thực hiện được hay không? Tại sao?
```sql
INSERT INTO EmployeeNames (FirstName, LastName)
VALUES ('QuanLyThongTin', 'IE103')
```

10. Cho hình bên dưới.

*(Hình ảnh mô tả mã hóa dữ liệu với Application, ADO.NET, Database và các Parameters)*

Hỏi hình trên đang mô tả mã hóa dữ liệu ở trạng thái nào? Vì sao? Biết dữ liệu có 3 trạng thái là: Data at rest (trạng thái nghỉ), Data in use (trạng thái đang sử dụng), Data in motion/transit (trạng thái lưu chuyển).

---

# Bài tập 2:

## A. IMPORT VÀ EXPORT.
- Chọn 1 file dữ liệu (SV) từ excel, và import vào SQLServer.
- Chọn 1 table trong SQL Server, và export tới file Excel.

**Ghi chú:** Thực hiện bằng cách dùng giao diện và chụp lại các bước thực hiện.

## B. XÁC THỰC NGƯỜI DÙNG
- Tạo 6 user từ u1 đến u6
- Tạo 3 role từ r1 đến r3
- Tạo nhóm: u1 thuộc r1; u2, u3 thuộc r2; u4, u5, u6 thuộc r3
- Thực hiện:
  - [ ] r1 thành viên của SysAdmin
  - [ ] r2 thành viên của db_owner, db_accessadmin
  - [ ] r3 thành viên của SysAdmin, db_owner, db_accessadmin

## C. PHÂN QUYỀN NGƯỜI DÙNG
Tập làm các phát biểu grant, deny, revoke trên một CSDL Quản lý đề tài gồm các table T1, T2, T3. Tạo các user U1, U2, U3.
- U1 có quyền select, delete trên T1, T3
- U2 có quyền update, delete trên T2
- U3 có quyền insert trên T1, T2, T3
- U1 bị từ chối quyền insert trên T1, T2
- U2 bị từ chối quyền delete trên T3
- Thu hồi các quyền của U1 trên T1
- Thu hồi các quyền của U3 trên T2

**Ghi chú:** T1, T2 và T3 là các bảng trong CSDL Quản lý đề tài, và được chọn theo quy tắc sau.

| SỐ CUỐI MSSV | T1 | T2 | T3 |
|---|---|---|---|
| 0 | SINHVIEN | HOCHAM | GV_PBDT |
| 1 | GV_HV_CN | HOIDONG_GV | HOCVI |
| 2 | DETAI | HOIDONG | GV_HDDT |
| 3 | GV_UVDT | GV_HV_CN | CHUYENNGANH |
| 4 | HOIDONG | HOCVI | GV_UVDT |
| 5 | HOIDONG_DT | GV_HDDT | CHUYENNGANH |
| 6 | GV_HDDT | HOIDONG_GV | HOCHAM |
| 7 | GV_UVDT | DETAI | HOIDONG |
| 8 | CHUYENNGANH | GV_PBDT | HOCHAM |
| 9 | HOIDONG_GV | SINHVIEN | GV_HV_CN |

---

### Hướng dẫn nộp bài:
- Nộp file PDF. Đặt tên file: **MSSV_HoTen_BTTH3.pdf**.
- Trong file trình bày các câu trả lời. Đối với các câu hỏi yêu cầu thao tác (VD: Backup / Restore, …) thì các bạn chụp màn hình theo từng bước, có tiêu đề cho mỗi bước và paste vào file báo cáo.
- Tương tự, các câu có yêu cầu code SQL cũng sẽ paste code vào file báo cáo. Nộp file sql. Đặt tên file: **MSSV_HoTen_BTTH3.sql**.
- Lưu ý: Các câu lý thuyết cần trình bày lại theo ý hiểu, không sao chép. Cuối bài bổ sung phần tài liệu tham khảo.
- Nộp qua hệ thống courses.uit.edu.vn. Lưu ý: **KHÔNG NÉN FILE**.

