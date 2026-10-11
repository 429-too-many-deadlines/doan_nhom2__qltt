# BTTH2 – Xử lý thông tin (CSDL Quản lý đề tài) – Thiết kế

**Ngày:** 2026-10-11
**Đề bài:** `NoiDungHoc/6BTTH.md/BTTH2 - Xử lý thông tin.md`

## 1. Mục tiêu và phạm vi

Làm trọn BTTH2 theo cùng khuôn với BTTH5/BTTH6 đã có trong repo:

- `BTTH2/MSSV_HoTen_BTTH2.sql` – một file duy nhất, chạy trọn vẹn từ đầu đến cuối trên SQL Server 2022.
- `BTTH2/MSSV_HoTen_BTTH2.md` – báo cáo: mỗi câu gồm đề, code SQL, lệnh chạy thử, kết quả thực tế và giải thích.
- `BTTH2/MSSV_HoTen_BTTH2.pdf` – xuất từ `.md` (Markdown → HTML → headless Edge/Chrome, giống BTTH6).

Giữ nguyên placeholder `MSSV`/`HoTen` như các bài trước.

**Tiêu chí hoàn thành:**
- Chạy toàn bộ file `.sql` trên container `quanlythuvien_sqlserver` không có lỗi ngoài ý muốn. Những lỗi cố ý gây ra để chạy thử các trường hợp lỗi phải được bắt bằng `TRY…CATCH` hoặc ghi chú rõ.
- Mọi kết quả ghi trong báo cáo đều được chép lại từ lần chạy thật.
- Trả lời bằng chữ các câu hỏi lý thuyết B3, B5, C3, C4, mỗi câu có lệnh minh chứng.

## 2. Phần 1 – Tạo CSDL và dữ liệu

- `DROP` (nếu đã có) rồi `CREATE DATABASE QLDT`, tạo 14 bảng đúng kiểu dữ liệu của bảng 1.1. Tái sử dụng Câu 0 của `BTTH6/MSSV_HoTen_BTTH6.sql`.
- Nạp dữ liệu từ 1.2a đến 1.2n. Đề ghi `MSGV` dạng `00201`, nhưng kiểu dữ liệu là `INT` nên giá trị thực lưu là `201`. Báo cáo ghi chú điều này.
- **Dữ liệu bổ sung** (ghi rõ trong báo cáo là dữ liệu thêm vào so với đề): dữ liệu gốc không có GV nào học vị Tiến sĩ, khiến 3 GV có học hàm PGS (201, 202, 203) vi phạm ràng buộc C5. Thêm các dòng GV_HV_CN giống BTTH6: (201,4,1,2016), (202,4,2,2017), (203,4,4,2018), (204,4,2,2019), (205,3,3,2015).
- **Dữ liệu ngày giờ HOIDONG:** `TGBD` ghi theo dạng `'07:00'` và `NGAYHD` theo định dạng ISO `'2014-11-29'` để không phụ thuộc thiết lập ngôn ngữ của server.

## 3. Quy ước chung

- **Điểm trung bình đề tài** = trung bình mọi điểm của đề tài trong GV_HDDT ∪ GV_PBDT ∪ GV_UVDT (`UNION ALL`). B2, B4, D1, D2 và E đều dùng định nghĩa này.
- **Phần A** trả kết quả 0/1 bằng `RETURN`, gọi bằng `DECLARE @kq INT; EXEC @kq = sp_...; SELECT @kq`.
- **Phần B** dùng tham số `OUTPUT`.
- **Chạy thử:** mỗi object có ít nhất 1 trường hợp đúng và 1 trường hợp lỗi/không tìm thấy. Các lệnh làm thay đổi dữ liệu được bọc trong `BEGIN TRAN … ROLLBACK`, để các phần sau vẫn chạy trên dữ liệu gốc.
- Mỗi object có `DROP … IF EXISTS` trước khi `CREATE`, để file chạy lại được nhiều lần.

## 4. Phần 2A – Stored procedure tham số vào

| Câu | Tên | Logic |
|---|---|---|
| A1 | `sp_ThemGV_KiemTraHH` | MSHH không có trong HOCHAM → `RETURN 0`; ngược lại INSERT và `RETURN 1`. |
| A2 | `sp_ThemGV_KiemTraMSGV` | MSGV đã tồn tại → `RETURN 0`; ngược lại INSERT và `RETURN 1`. |
| A3 | `sp_ThemGV` | MSGV trùng → `RETURN 0`; MSHH không tồn tại → `RETURN 1`; ngược lại INSERT và `RETURN 2`. Đề không nói giá trị khi thành công nên chọn 2 để phân biệt, báo cáo ghi rõ. |
| A4 | `sp_CapNhatTenDT` | Không tìm thấy MSDT → `RETURN 0`; ngược lại UPDATE TENDT và `RETURN 1`. |
| A5 | `sp_CapNhatSV` | Không tìm thấy MSSV → `RETURN 0`; ngược lại UPDATE TENSV, DIACHI và `RETURN 1`. |

Thứ tự trong file: A → B → C → D → E. File luôn tạo lại CSDL từ đầu, nên khi chạy thử phần A thì trigger C5 chưa tồn tại. Dù vậy, chạy thử phần A vẫn dùng MSHH = 2 (GS) để dữ liệu không mâu thuẫn với ràng buộc C5.

## 5. Phần 2B – Stored procedure tham số vào/ra

| Câu | Tên | Tham số ra | Ghi chú |
|---|---|---|---|
| B1 | `sp_DemGV_TheoHV` | `@SoGV INT` | Đếm `DISTINCT MSGV` trong GV_HV_CN theo TENHV; không có thì 0. |
| B2 | `sp_DiemTB_DeTai` | `@DiemTB FLOAT` | Không có điểm/không có MSDT → 0. |
| B3 | `sp_SDT_TheoTenGV` | `@SoDT VARCHAR(10)` | Không có → `'0'`. Trùng tên: `SELECT @x = …` **không báo lỗi**, chỉ lấy giá trị dòng cuối cùng. Bản cải tiến `sp_SDT_TheoTenGV_V2` thêm `@SoLuong INT OUTPUT` và trả result set liệt kê tất cả SĐT. Chạy thử bằng cách thêm 1 GV trùng tên trong `BEGIN TRAN … ROLLBACK`. |
| B4 | `sp_DiemTB_HoiDong` | `@DiemTB FLOAT` | Trung bình của các điểm trung bình đề tài thuộc HOIDONG_DT của MSHD; không có → 0. |
| B5 | `sp_SoDT_TheoTenGV` | `@SoHD INT`, `@SoPB INT` | Join theo TENGV → nếu trùng tên, hệ thống **không báo lỗi** mà cộng dồn đề tài của mọi GV cùng tên. Minh chứng bằng GV trùng tên trong transaction. |

## 6. Phần 2C – Trigger

| Câu | Tên / bảng / loại | Logic |
|---|---|---|
| C1 | `trg_XoaDeTai` – DETAI – INSTEAD OF DELETE | Xóa các dòng có MSDT ∈ `deleted` ở SV_DETAI, GV_HDDT, GV_PBDT, GV_UVDT, HOIDONG_DT, sau đó xóa DETAI. Phải dùng INSTEAD OF vì khóa ngoại được kiểm tra trước khi trigger AFTER chạy. |
| C2 | `trg_DoiMSGV` – GIAOVIEN – INSTEAD OF UPDATE | Không `UPDATE(MSGV)` → cập nhật các cột khác (join `inserted`–`deleted` theo MSGV). Có đổi MSGV mà >1 dòng → `RAISERROR` + `ROLLBACK`. Mã mới đã tồn tại → lỗi. Đổi đúng 1 dòng: (1) INSERT GV mã mới với `MSHH = NULL`; (2) UPDATE MSGV ở GV_HV_CN, GV_HDDT, GV_PBDT, GV_UVDT, HOIDONG, HOIDONG_GV; (3) UPDATE MSHH của GV mới; (4) DELETE GV mã cũ. Thứ tự này để trigger C5 không chặn ở bước (1). |
| C3 | `trg_HoiDong_Max10DT` – HOIDONG_DT – AFTER INSERT, UPDATE | `GROUP BY MSHD HAVING COUNT(*) > 10` trên toàn bảng, chỉ xét những MSHD có trong `inserted` → lỗi + `ROLLBACK`. |
| C4 | `trg_DeTai_Max2SV` – SV_DETAI – AFTER INSERT, UPDATE | Tương tự, `GROUP BY MSDT HAVING COUNT(*) > 2`. |
| C5 | `trg_PGS_PhaiTS_GV` – GIAOVIEN – AFTER INSERT, UPDATE; `trg_PGS_PhaiTS_HV` – GV_HV_CN – AFTER UPDATE, DELETE | Mọi GV bị ảnh hưởng có học hàm `TENHH = N'PHÓ GIÁO SƯ'` phải có ít nhất 1 dòng GV_HV_CN với `TENHV LIKE N'Tiến sĩ%'` (Tiến sĩ, Tiến sĩ Khoa học); nếu không → lỗi + `ROLLBACK`. |

**Trả lời "dùng GROUP BY được không" (C3, C4):** được, với điều kiện gom nhóm trên toàn bảng và lọc theo khóa có trong `inserted`. Nếu chỉ gom nhóm trên `inserted` thì sẽ bỏ sót những dòng đã có sẵn. Báo cáo chạy thử cả bản sai lẫn bản đúng.

**Chạy thử:**
- C1: xóa đề tài 97005 trong transaction, đếm dòng ở các bảng con trước/sau, rồi `ROLLBACK`.
- C2: đổi 201 → 210, xem các bảng con; thử đổi nhiều dòng để thấy lỗi.
- C3: thêm 5 DETAI giả, gán 11 đề tài cho HD 1 → lỗi.
- C4: thêm SV thứ 3 vào 97005 → lỗi.
- C5: (a) UPDATE GV 205 (Thạc sĩ) lên MSHH = 1 → lỗi; (b) xóa dòng tiến sĩ của 201 → lỗi; (c) quy trình hợp lệ để thêm một GV mới là PGS: thêm GV với MSHH NULL → thêm học vị TS → cập nhật MSHH = 1. Ghi chú: không thể INSERT trực tiếp một GV mới đã là PGS (khóa ngoại GV_HV_CN cần GV tồn tại trước).

## 7. Phần 2D – Function

| Câu | Tên | Loại | Logic |
|---|---|---|---|
| D1 | `fn_DiemTB_DeTai(@MSDT)` | Scalar, `FLOAT` | Theo định nghĩa ở mục 3; không có điểm → `NULL`. |
| D2 | `fn_KetQua_DeTai(@MSDT)` | Scalar, `NVARCHAR(10)` | Gọi D1: ≥ 5 → `N'DAT'`, < 5 → `N'KHONGDAT'`, `NULL` → `NULL`. |
| D3 | `fn_SV_DeTai(@MSDT)` | Inline TVF | `SELECT SV.MSSV, SV.TENSV FROM SV_DETAI JOIN SINHVIEN`. |

Chạy thử: `SELECT MSDT, dbo.fn_DiemTB_DeTai(MSDT), dbo.fn_KetQua_DeTai(MSDT) FROM DETAI`, `SELECT * FROM dbo.fn_SV_DeTai('97005')`.

## 8. Phần 2E – Cursor

- **E0:** `CREATE TABLE DETAI_DIEM (MSDT CHAR(6) PRIMARY KEY REFERENCES DETAI(MSDT), DIEMTB FLOAT)`.
- **E1:** đoạn script có cursor `cur_DeTai` duyệt `SELECT MSDT FROM DETAI`; với mỗi đề tài tính điểm trung bình và INSERT. `DELETE DETAI_DIEM` trước để chạy lại nhiều lần không bị trùng. Có `CLOSE` và `DEALLOCATE`.
- **E2:** `sp_TinhDiemTB_DeTai` gói logic E1; chạy bằng `EXEC`.
- **E3:** `ALTER TABLE DETAI_DIEM ADD XEPLOAI NVARCHAR(20)`, chạy trong batch riêng trước khi cursor dùng đến cột này. Cursor `FOR UPDATE OF XEPLOAI` cập nhật bằng `WHERE CURRENT OF`. Đề có khoảng điểm trùng nhau ở hai đầu mút nên chốt quy tắc: ≥ 9 Xuất sắc; ≥ 8 Giỏi; ≥ 7 Khá; ≥ 6 Trung bình khá; ≥ 5 Trung bình; ≥ 4 Yếu; < 4 Kém.

DETAI_DIEM có khóa ngoại tới DETAI nhưng được tạo sau trigger C1. Vì vậy C1 có thêm bước `IF OBJECT_ID('DETAI_DIEM') IS NOT NULL DELETE FROM DETAI_DIEM WHERE MSDT IN (SELECT MSDT FROM deleted)`. SQL Server cho phép tham chiếu bảng chưa tồn tại lúc tạo trigger (deferred name resolution). Khi cài đặt sẽ chạy thử lại C1 sau phần E để xác nhận bước này hoạt động.

## 9. Báo cáo và xuất PDF

- Bố cục báo cáo theo thứ tự đề: Phần 1 (1.1, 1.2) → Phần 2 (A1–A5, B1–B5, C1–C5, D1–D3, E1–E3). Mỗi câu gồm: đề → code → lệnh chạy thử → kết quả (bảng Markdown) → giải thích ngắn.
- Kết quả lấy từ `sqlcmd` trong container (`docker exec quanlythuvien_sqlserver /opt/mssql-tools18/bin/sqlcmd …`), chép vào `.md`.
- Xuất PDF cùng cách với BTTH6 (HTML + headless Edge/Chrome).

## 10. Ngoài phạm vi

- Không đụng tới code QuanLyThuVien hay báo cáo đồ án.
- Không tạo dữ liệu ngoài những dòng bổ sung đã nêu và dữ liệu tạm trong transaction khi chạy thử.
