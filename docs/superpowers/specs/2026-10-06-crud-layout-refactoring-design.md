# Cấu trúc Kiến trúc Mới cho Các Màn hình Quản lý Dữ liệu

## Tóm tắt Mục tiêu
Tái cấu trúc các màn hình quản lý dữ liệu (CRUD) từ dạng Form song song Table sang dạng Full-width Data Table. Các thao tác Thêm/Sửa sẽ được đưa vào các Component Dialog riêng biệt. Thay đổi này bắt đầu với trang `Categories` làm mẫu, sau đó có thể áp dụng cho các trang khác.

## Kiến trúc và Cấu trúc Thư mục
Mỗi màn hình quản lý (ví dụ: Categories) sẽ tuân theo cấu trúc phân tách trách nhiệm như sau:

- **Màn hình chính (`src/pages/Categories.tsx`)**:
  - Chịu trách nhiệm quản lý state chính (`page`, `searchKeyword`, danh sách data).
  - Gọi API fetch dữ liệu (`getCategories`).
  - Render thanh công cụ (Toolbar) và Data Table.
  - Xử lý việc hiển thị Pagination.

- **Dialog Components (`src/components/features/categories/...`)**:
  - `CreateCategoryDialog.tsx`: Modal chứa Form thêm mới. Tự quản lý state của form, gọi API Create, và trigger callback `onSuccess` để trang chính fetch lại data.
  - `UpdateCategoryDialog.tsx`: Modal chứa Form cập nhật. Nhận data ban đầu (ID hoặc object) qua props, tự quản lý state sửa, gọi API Update, trigger callback `onSuccess`.

## Thiết kế Giao diện (UI Components)
- **Top Toolbar**: 
  - Khung tìm kiếm (Input) cho phép filter dữ liệu.
  - Nút **Thêm mới** mở `CreateCategoryDialog`.
- **Data Table**: 
  - Render dưới dạng lưới chiếm toàn bộ chiều ngang khả dụng (`full-width`).
  - Cột cuối cùng (Hành động) chứa 2 icon buttons: **Sửa** (mở `UpdateCategoryDialog`) và **Xoá**.
- **Xác nhận Xóa**: 
  - Sử dụng component `AlertDialog` từ thư viện `shadcn/ui` để bọc nút Xóa, tránh việc người dùng bấm nhầm. Chỉ gọi API Delete khi đã xác nhận.
- **Phân trang**: 
  - Component `DataTablePagination` đặt ở footer của bảng.

## Luồng Dữ liệu (Data Flow)
1. **Lấy dữ liệu (Read)**: `Categories.tsx` gọi `fetchCategories()` khi mount hoặc khi `page`/`searchKeyword` thay đổi -> truyền data vào `Table`.
2. **Thêm mới (Create)**: User điền form trong `CreateCategoryDialog` -> Bấm Lưu -> Gọi API Create -> Thành công -> Báo toast -> Đóng Dialog -> Gọi props `onSuccess()` -> `Categories.tsx` chạy lại `fetchCategories()`.
3. **Cập nhật (Update)**: User bấm Sửa trên row -> Mở `UpdateCategoryDialog` với data của row đó -> Bấm Lưu -> Gọi API Update -> Thành công -> Báo toast -> Đóng Dialog -> Gọi props `onSuccess()` -> `Categories.tsx` chạy lại `fetchCategories()`.
4. **Xóa (Delete)**: User bấm Xóa trên row -> Bật `AlertDialog` -> User chọn Xác nhận -> `Categories.tsx` gọi API Delete -> Thành công -> Báo toast -> `Categories.tsx` chạy lại `fetchCategories()`.

## Phạm vi triển khai
1. Tạo các file component cho `Categories` (`CreateCategoryDialog`, `UpdateCategoryDialog`, `DeleteCategoryDialog` hoặc dùng trực tiếp AlertDialog).
2. Refactor `Categories.tsx` theo kiến trúc mới.
3. Test các chức năng (CRUD + Pagination + Filter).

