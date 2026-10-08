# Thiết Kế Kiến Trúc: Trang Báo Cáo Thống Kê Sử Dụng Biểu Đồ (Reports Chart Dashboard)

## 1. Tóm tắt Mục tiêu
Nâng cấp toàn diện trang **Báo cáo thống kê (`src/pages/Reports.tsx`)** của Hệ thống Quản lý Thư viện từ dạng hiển thị bảng số liệu thô và danh sách nút bấm rời rạc sang kiến trúc **Modular Tabbed Dashboard**. Hệ thống sử dụng thư viện `Recharts` kết hợp component UI của `shadcn/ui` để trực quan hóa dữ liệu theo 5 nhóm nghiệp vụ chuyên biệt, kèm bảng dữ liệu chi tiết và bộ lọc thời gian.

## 2. Kiến trúc & Cấu trúc Thư mục
Thay vì nhồi nhét tất cả logic và markup vào một file `Reports.tsx` duy nhất, thiết kế chia tách thành các component theo từng tab nghiệp vụ độc lập:

```
frontend/src/
├── pages/
│   └── Reports.tsx                           # Container trang chính: Điều phối Tabs và Bộ lọc thời gian dùng chung
└── components/features/reports/
    ├── MonthlyOverviewTab.tsx                # Tab 1: Tổng quan tháng (KPI Cards + Top 5 sách bar chart)
    ├── BorrowStatsTab.tsx                    # Tab 2: Thống kê mượn trả theo tháng và thể loại (Line/Area Chart + Table)
    ├── InventoryStatsTab.tsx                 # Tab 3: Tình trạng kho & Top sách mượn nhiều (Stacked Bar + Horizontal Bar)
    ├── FineStatsTab.tsx                      # Tab 4: Phạt & Độc giả quá hạn (Donut Chart lý do + Bar thu tiền + Bảng quá hạn)
    └── StaffStatsTab.tsx                     # Tab 5: Hiệu suất nhân viên & Cursor nghiệp vụ (Grouped Bar + Actions)
```

## 3. Chi tiết Các Tab Nghiệp vụ & Loại Biểu đồ (Visualizations)

### Tab 1: Tổng quan tháng (`MonthlyOverviewTab.tsx`)
- **Dữ liệu nguồn**: `reportsService.getMonthlyStats(month, year)`
- **Thành phần giao diện**:
  - **KPI Cards**:
    - Số phiếu mượn trong tháng
    - Số lượt mượn sách trong tháng
    - Tổng tiền phạt thu được (VNĐ)
  - **Biểu đồ (BarChart)**: Top 5 sách mượn nhiều nhất trong tháng (Trục X: Tên sách cắt ngắn / tooltip chi tiết, Trục Y: Số lượt mượn).
  - **Bảng dữ liệu**: Bảng chi tiết Top 5 sách kèm mã đầu sách, tên sách, số lượt mượn.

### Tab 2: Mượn - Trả (`BorrowStatsTab.tsx`)
- **Dữ liệu nguồn**: `reportsService.getBorrowsByMonth()` (View `VW_BC_LUOTMUON_THANG`: `NAM`, `THANG`, `TENTL`, `SOLUOTMUON`).
- **Thành phần giao diện**:
  - **Bộ lọc Năm**: Dropdown/Select chọn Năm để lọc dữ liệu hiển thị (ví dụ 2026, 2025,...).
  - **Biểu đồ (AreaChart / Multi-LineChart)**:
    - Trục X: 12 tháng (Tháng 1 -> Tháng 12).
    - Trục Y: Số lượt mượn.
    - Các đường/vùng màu biểu diễn các thể loại sách khác nhau (Khoa học, Văn học, CNTT, v.v.).
  - **Bảng chi tiết**: Danh sách mượn theo tháng và thể loại kèm `DataTablePagination`.

### Tab 3: Kho & Đầu sách (`InventoryStatsTab.tsx`)
- **Dữ liệu nguồn**:
  - `reportsService.getTopBorrowedBooks()` (View `VW_BC_SACHMUONNHIEU`: `MADS`, `TENDS`, `TENTL`, `SOLUOTMUON`, `SODOCGIA`).
  - `reportsService.getInventoryReport()` (View `VW_BC_TINHTRANGKHO`: `MADS`, `TENDS`, `TENTL`, `TONGSO`, `COSAN`, `DANGMUON`, `HUHONG`, `MAT`).
- **Thành phần giao diện**:
  - **Biểu đồ 1 (Horizontal BarChart)**: Top 10 sách mượn nhiều nhất toàn hệ thống (so sánh số lượt mượn và số độc giả mượn).
  - **Biểu đồ 2 (Stacked BarChart hoặc PieChart tổng hợp)**: Phân bố tình trạng kho sách (Có sẵn, Đang mượn, Hư hỏng, Mất) theo từng thể loại hoặc toàn thư viện.
  - **Bảng dữ liệu**: Bảng tồn kho chi tiết từng đầu sách kèm phân trang.

### Tab 4: Tiền phạt & Quá hạn (`FineStatsTab.tsx`)
- **Dữ liệu nguồn**:
  - `reportsService.getFinesByMonth()` (View `VW_BC_TIENPHAT_THANG`: `NAM`, `THANG`, `LYDO`, `SOPHIEU`, `TONGTIEN`, `DATHU`, `CHUATHU`).
  - `reportsService.getOverdueReaders()` (View `VW_BC_DOCGIA_QUAHAN`: `MADG`, `HOTEN`, `SODT`, `TENDS`, `SONGAYTRE`, `TIENPHATTAMTINH`).
- **Thành phần giao diện**:
  - **Biểu đồ 1 (Pie/Donut Chart)**: Cơ cấu tiền phạt theo lý do (Quá hạn, Làm rách/hỏng, Mất sách).
  - **Biểu đồ 2 (BarChart kép)**: So sánh tiền phạt Đã thu vs Chưa thu theo từng tháng trong năm.
  - **Bảng cảnh báo độc giả quá hạn**: Bảng danh sách độc giả giữ sách trễ hạn (Highlight badge số ngày trễ màu đỏ/vàng, tiền phạt tạm tính).

### Tab 5: Hiệu suất & Vận hành (`StaffStatsTab.tsx`)
- **Dữ liệu nguồn**:
  - `reportsService.getLibrarianPerformance()` (View `VW_BC_HIEUSUAT_NHANVIEN`: `MANV`, `HOTEN`, `NAM`, `THANG`, `SOPHIEU`, `SOSACH`).
  - `reportsService.runRankingCursor()` (Stored procedure xếp loại độc giả).
  - `reportsService.runReminderCursor()` (Stored procedure nhắc nhở quá hạn).
- **Thành phần giao diện**:
  - **Biểu đồ (Grouped BarChart)**: So sánh số phiếu mượn lập và số sách xử lý của từng nhân viên theo tháng.
  - **Khu vực thao tác tự động (Automated Tasks / Procedures)**:
    - Nút chạy "Xếp loại độc giả" kèm hiển thị kết quả phân loại (Tích cực, Bình thường, Vi phạm).
    - Nút chạy "Quét & Nhắc nhở quá hạn" kèm input ngày kiểm tra và hiển thị danh sách đã gửi nhắc nhở.

## 4. Luồng Dữ liệu & Quản lý Trạng thái (Data Flow & State Management)
1. **Quản lý Active Tab**: `Reports.tsx` giữ state `activeTab` (mặc định `'monthly'`).
2. **Bộ lọc Năm/Tháng dùng chung**:
   - `month` (mặc định tháng hiện tại), `year` (mặc định năm hiện tại).
   - Truyền qua props xuống các Tab có nhu cầu lọc theo thời gian (`MonthlyOverviewTab`, `StaffStatsTab`, `FineStatsTab`).
3. **Cơ chế tải dữ liệu (Lazy Loading)**:
   - Mỗi sub-component Tab tự quản lý việc fetch dữ liệu khi được mount (`useEffect`).
   - Có trạng thái `loading` (spinner / placeholder) và `error` (thông báo lỗi thân thiện).
   - Khi chuyển tab, tab đó mới kích hoạt gọi API, tránh nghẽn mạng do gọi đồng loạt 6-7 APIs.

## 5. UI/UX & Design System Constraints
- Sử dụng shadcn `Tabs`, `Card`, `Button`, `Input`, `Badge`, `Table`, `DataTablePagination`.
- Biểu đồ dùng `Recharts` bọc trong `ResponsiveContainer` để co giãn mượt mà theo kích thước màn hình (responsive trên cả tablet và desktop).
- Bảng màu biểu đồ (Chart Colors) sử dụng các biến CSS HSL / Tailwind semantic tokens (hoặc palette chuyên biệt rõ ràng: Primary Blue, Emerald Green, Amber Yellow, Rose Red, Indigo Purple) đảm bảo độ tương phản tốt ở cả Dark và Light theme.
- Tooltip hiển thị tiếng Việt có dấu, định dạng số hàng nghìn (`1,000,000 VNĐ`) bằng `toLocaleString('vi-VN')`.

## 6. Phạm vi triển khai & Kế hoạch
1. Tạo thư mục `frontend/src/components/features/reports/`.
2. Lần lượt hiện thực 5 tab component:
   - `MonthlyOverviewTab.tsx`
   - `BorrowStatsTab.tsx`
   - `InventoryStatsTab.tsx`
   - `FineStatsTab.tsx`
   - `StaffStatsTab.tsx`
3. Cập nhật `frontend/src/pages/Reports.tsx` tích hợp thanh điều hướng Tabs và bộ lọc thời gian.
4. Kiểm thử giao diện và build TypeScript (`npm run build` / `vite build`).
