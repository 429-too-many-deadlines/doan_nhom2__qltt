# Design Spec: Remove Employee Management & Simplify Auth

## 1. Overview
Hệ thống quản lý thư viện sẽ được đơn giản hóa bằng cách loại bỏ hoàn toàn thực thể "Nhân Viên" (Employee) và các luồng phân quyền dựa trên Role. Hệ thống sẽ chỉ giữ lại đúng 1 tài khoản Admin để sử dụng (nghĩa là cả Độc giả và Nhân viên đều không cần đăng nhập vào hệ thống). Mọi thao tác trên hệ thống đều được ngầm hiểu là do Admin thực hiện.

## 2. Database Changes
- **Xóa bảng và Ràng buộc:**
  - DROP các Check constraints (`CK_TAIKHOAN_VAITRO`, `CK_TAIKHOAN_CHUSOHUU`,...) và Foreign Keys liên quan đến `NHANVIEN` và `TAIKHOAN`.
  - Bảng `TAIKHOAN`: Xóa cột `MANV`, `MADG`, `VAITRO`. Cấu trúc mới chỉ còn: `TENDANGNHAP` (PK), `MATKHAU`, `TRANGTHAI`.
  - Bảng `PHIEUMUON`: Xóa cột `MANV` (Không còn lưu thông tin người lập phiếu).
  - Bảng `NHANVIEN`: DROP hoàn toàn.
- **Stored Procedures & Views:**
  - DROP các SP: `SP_THEMNHANVIEN`, `SP_SUANHANVIEN`, `SP_XOANHANVIEN`, `SP_LAYDANHSACHNHANVIEN`.
  - DROP View: `VW_BC_HIEUSUAT_NHANVIEN`.
  - Sửa SP: Loại bỏ tham số `@MANV` trong các SP liên quan đến `PHIEUMUON`. Cập nhật các câu lệnh phân quyền (GRANT/DENY) trong DB.
- **Khởi tạo và Live Database:**
  - Cập nhật các file `.sql` gốc. Bảng `TAIKHOAN` sẽ được seed 1 record duy nhất cho Admin.
  - Sẽ thực thi trực tiếp script migration để DROP/ALTER các thành phần trên Live Database thông qua Connection String đã cung cấp.

## 3. Backend (API) Changes
- **Endpoints:**
  - Xóa toàn bộ API trong `Endpoints/Employees`.
  - Sửa API `Endpoints/Auth`: Chỉ validate `TENDANGNHAP` và `MATKHAU`.
  - Sửa API `Endpoints/Transactions`: DTOs không còn property `Manv` (hoặc `NhanVienId`). Gọi SP tạo phiếu mượn không truyền `@MANV`.
  - Sửa API `Endpoints/Reports`: Gỡ endpoint báo cáo hiệu suất nhân viên.
  - Sửa API `Endpoints/Accounts`: Chuyển thành duy nhất một endpoint `UpdatePassword` cho tài khoản Admin đang login.
- **Authorization:** 
  - Gỡ bỏ kiểm tra phân quyền Role (`[Authorize(Roles="...")]`), đổi thành `[Authorize]` cơ bản.
  - JWT Token payload sẽ chỉ lưu thông tin tối thiểu (username) thay vì ôm cả Role và mã Nhân viên.

## 4. Frontend (React) Changes
- **Routing & Navigation (`app-sidebar.tsx`):**
  - Gỡ menu "Quản lý nhân viên".
  - Đổi tên/chức năng menu "Quản lý tài khoản" thành "Đổi mật khẩu" (hoặc gom chung vào Cài đặt).
  - Xóa mọi logic check Role để hiển thị giao diện.
- **Pages:**
  - Xóa hoàn toàn file `Employees.tsx`.
  - Sửa file `Accounts.tsx`: Thay vì hiển thị bảng danh sách, chuyển thành form Đổi mật khẩu cho Admin.
  - Sửa file `Transactions.tsx`: Xóa cột "Nhân viên lập" trên bảng dữ liệu, xóa trường chọn Nhân viên khi tạo/sửa phiếu mượn.
  - Sửa file `Reports.tsx`: Bỏ UI thống kê/biểu đồ liên quan đến hiệu suất nhân viên.
