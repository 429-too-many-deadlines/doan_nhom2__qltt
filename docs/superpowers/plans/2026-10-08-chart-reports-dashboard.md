# Chart Reports Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Nâng cấp toàn diện trang Báo cáo thống kê (`src/pages/Reports.tsx`) thành Dashboard báo cáo trực quan với biểu đồ Recharts theo 5 nhóm nghiệp vụ (Tổng quan, Mượn trả, Tồn kho, Tiền phạt, Hiệu suất nhân viên).

**Architecture:** Tách biệt trách nhiệm thành kiến trúc Modular Tabbed Dashboard. Trang `Reports.tsx` đóng vai trò container điều phối navigation Tabs và bộ lọc thời gian; mỗi tab nghiệp vụ được đóng gói thành một sub-component độc lập trong `src/components/features/reports/` tự quản lý dữ liệu, biểu đồ Recharts và bảng chi tiết.

**Tech Stack:** React 19, TypeScript, Vite, Tailwind CSS v4, Recharts, Lucide React, shadcn/ui (Card, Tabs, Table, Button, Input, Badge).

**Spec:** [docs/superpowers/specs/2026-10-08-chart-reports-dashboard-design.md](file:///mnt/d/CITD/HocHanh/QuanLyThongTin/doan_nhom2__qltt/docs/superpowers/specs/2026-10-08-chart-reports-dashboard-design.md)

## Global Constraints

- Không làm thay đổi giao diện các trang khác trong hệ thống.
- Sử dụng các API sẵn có từ `reportsService` trong `frontend/src/services/reports.service.ts` mà không làm vỡ tương thích backend.
- Đảm bảo biểu đồ hiển thị responsive trên các kích thước màn hình bằng `ResponsiveContainer` của Recharts.
- Định dạng số và tiền tệ tiếng Việt chuẩn: `.toLocaleString('vi-VN')` + ' đ' / ' VNĐ'.
- Mọi câu lệnh build kiểm thử TypeScript (`npm run build`) trong thư mục `frontend/` phải hoàn thành không có lỗi lint/compile.

## Review Focus

1. Dữ liệu trả về từ API rỗng hoặc null: Các component biểu đồ và bảng phải render fallback thông báo "Không có dữ liệu" một cách nhã nhặn, không gây crash ứng dụng.
2. Dữ liệu tháng/năm không có bản ghi nào: Bộ lọc tháng/năm phải cập nhật lại state của biểu đồ về mảng rỗng thay vì giữ dữ liệu cũ hoặc render lỗi NaN.
3. Phím bấm chuyển đổi giữa các tab: Khi chuyển tab, tab mới phải kích hoạt fetch dữ liệu của tab đó (nếu chưa có) và hiển thị loading state rõ ràng.
4. Trục X của biểu đồ có nhãn quá dài (ví dụ tên sách): Phải cắt ngắn nhãn (truncate) hoặc hiển thị tooltip đầy đủ để không bị tràn vỡ giao diện.
5. Thao tác chạy Cursor (Xếp loại, Nhắc nhở): Phải có trạng thái loading/disabled khi đang xử lý để tránh spam click gọi API nhiều lần.

---

### Task 1: Sub-component MonthlyOverviewTab (Tab 1: Tổng quan tháng)

**Files:**
- Create: `frontend/src/components/features/reports/MonthlyOverviewTab.tsx`

**Interfaces:**
- Consumes: `reportsService.getMonthlyStats(month: number, year: number): Promise<MonthlyStatsResponse>`
- Produces: `MonthlyOverviewTab: React.FC<{ month: number; year: number }>`

- [ ] **Step 1: Tạo file `frontend/src/components/features/reports/MonthlyOverviewTab.tsx`**
  - Quản lý state: `stats: MonthlyStatsResponse | null`, `loading: boolean`.
  - Fetch dữ liệu qua `reportsService.getMonthlyStats(month, year)` mỗi khi props `month` hoặc `year` thay đổi.
  - Render 3 KPI Cards:
    - Số phiếu mượn (`stats.soPhieu ?? stats.SOPHIEU ?? 0`)
    - Số lượt sách mượn (`stats.soLuotSach ?? stats.SOLUOTSACH ?? 0`)
    - Tiền phạt thu được (`stats.tienPhat ?? stats.TIENPHAT ?? 0`)
  - Render Recharts `BarChart` cho Top 5 sách mượn nhiều nhất:
    - `ResponsiveContainer width="100%" height={300}`
    - `BarChart data={stats.top5Books}`
    - `XAxis dataKey="tenSach" tickFormatter={(v) => v.length > 20 ? v.slice(0, 20) + '...' : v}`
    - `YAxis`
    - `Tooltip`
    - `Bar dataKey="SOLUOTMUON" fill="#3b82f6" radius={[4, 4, 0, 0]}`
  - Render bảng chi tiết Top 5 sách.

- [ ] **Step 2: Kiểm tra biên dịch TypeScript**
  - Chạy lệnh: `npm run build` trong thư mục `frontend/`
  - Kết quả mong đợi: Build thành công không có lỗi type.

- [ ] **Step 3: Commit**
  - `git add frontend/src/components/features/reports/MonthlyOverviewTab.tsx`
  - `git commit -m "feat(reports): add MonthlyOverviewTab component with KPI cards and top books chart"`

---

### Task 2: Sub-component BorrowStatsTab (Tab 2: Mượn - Trả theo tháng và thể loại)

**Files:**
- Create: `frontend/src/components/features/reports/BorrowStatsTab.tsx`

**Interfaces:**
- Consumes: `reportsService.getBorrowsByMonth(): Promise<GenericApiResponse[]>`
- Produces: `BorrowStatsTab: React.FC`

- [ ] **Step 1: Tạo file `frontend/src/components/features/reports/BorrowStatsTab.tsx`**
  - Quản lý state: `rawBorrows: GenericApiResponse[]`, `selectedYear: number`, `loading: boolean`, `page: number`.
  - Fetch dữ liệu `reportsService.getBorrowsByMonth()` khi mount.
  - Trích xuất danh sách năm duy nhất (`years`) từ dữ liệu để làm dropdown chọn năm lọc.
  - Chuẩn hóa dữ liệu cho biểu đồ 12 tháng:
    - Lọc theo `selectedYear`.
    - Pivot dữ liệu theo trục X: `tháng 1` -> `tháng 12`, mỗi thể loại (`TENTL`) là một dataKey.
  - Render Recharts `AreaChart` hoặc `LineChart`:
    - `ResponsiveContainer width="100%" height={350}`
    - `CartesianGrid strokeDasharray="3 3"`
    - `XAxis dataKey="thang" tickFormatter={(m) => \`Tháng \${m}\`}`
    - `YAxis`
    - `Tooltip`
    - `Legend`
    - Các đường/vùng màu động cho từng thể loại sách (`stroke` màu hài hòa).
  - Render bảng dữ liệu chi tiết kèm phân trang `DataTablePagination`.

- [ ] **Step 2: Kiểm tra biên dịch TypeScript**
  - Chạy lệnh: `npm run build` trong thư mục `frontend/`
  - Kết quả mong đợi: Build thành công.

- [ ] **Step 3: Commit**
  - `git add frontend/src/components/features/reports/BorrowStatsTab.tsx`
  - `git commit -m "feat(reports): add BorrowStatsTab component with monthly category borrow chart"`

---

### Task 3: Sub-component InventoryStatsTab (Tab 3: Tình trạng kho & Top sách mượn nhiều)

**Files:**
- Create: `frontend/src/components/features/reports/InventoryStatsTab.tsx`

**Interfaces:**
- Consumes:
  - `reportsService.getTopBorrowedBooks(): Promise<GenericApiResponse[]>`
  - `reportsService.getInventoryReport(): Promise<GenericApiResponse[]>`
- Produces: `InventoryStatsTab: React.FC`

- [ ] **Step 1: Tạo file `frontend/src/components/features/reports/InventoryStatsTab.tsx`**
  - Quản lý state: `topBooks: GenericApiResponse[]`, `inventory: GenericApiResponse[]`, `loading: boolean`, `page: number`.
  - Fetch song song `getTopBorrowedBooks()` và `getInventoryReport()` khi mount.
  - Tính tổng các trạng thái kho toàn thư viện: `Tổng có sẵn`, `Tổng đang mượn`, `Tổng hư hỏng`, `Tổng mất`.
  - Render Biểu đồ 1 (Pie/Donut Chart) tỷ lệ trạng thái sách trong kho:
    - 4 phần tử: Có sẵn (xanh lá `#10b981`), Đang mượn (xanh dương `#3b82f6`), Hư hỏng (vàng `#f59e0b`), Mất (đỏ `#ef4444`).
  - Render Biểu đồ 2 (Horizontal BarChart) Top 10 sách mượn nhiều nhất toàn thư viện:
    - `BarChart layout="vertical"`
    - `YAxis dataKey="TENDS" type="category" width={140} tickFormatter={(v) => v.length > 18 ? v.slice(0, 18) + '...' : v}`
    - `XAxis type="number"`
    - `Bar dataKey="SOLUOTMUON" name="Lượt mượn" fill="#6366f1"`
    - `Bar dataKey="SODOCGIA" name="Số độc giả" fill="#8b5cf6"`
  - Render bảng chi tiết tồn kho từng đầu sách kèm phân trang `DataTablePagination`.

- [ ] **Step 2: Kiểm tra biên dịch TypeScript**
  - Chạy lệnh: `npm run build` trong thư mục `frontend/`
  - Kết quả mong đợi: Build thành công.

- [ ] **Step 3: Commit**
  - `git add frontend/src/components/features/reports/InventoryStatsTab.tsx`
  - `git commit -m "feat(reports): add InventoryStatsTab component with warehouse status and top books charts"`

---

### Task 4: Sub-component FineStatsTab (Tab 4: Tiền phạt & Độc giả quá hạn)

**Files:**
- Create: `frontend/src/components/features/reports/FineStatsTab.tsx`

**Interfaces:**
- Consumes:
  - `reportsService.getFinesByMonth(): Promise<GenericApiResponse[]>`
  - `reportsService.getOverdueReaders(): Promise<GenericApiResponse[]>`
- Produces: `FineStatsTab: React.FC`

- [ ] **Step 1: Tạo file `frontend/src/components/features/reports/FineStatsTab.tsx`**
  - Quản lý state: `finesData: GenericApiResponse[]`, `overdueReaders: GenericApiResponse[]`, `loading: boolean`, `page: number`, `selectedYear: number`.
  - Fetch song song `getFinesByMonth()` và `getOverdueReaders()` khi mount.
  - Tách và gom nhóm:
    - Cơ cấu tiền phạt theo `LYDO` (Trễ hạn, Hư hỏng, Mất sách) -> Recharts `PieChart`.
    - So sánh `DATHU` và `CHUATHU` theo từng tháng trong năm đã chọn -> Recharts `BarChart` (`Bar dataKey="DATHU" fill="#10b981"`, `Bar dataKey="CHUATHU" fill="#ef4444"`).
  - Render Bảng danh sách độc giả quá hạn:
    - Hiển thị Mã ĐG, Tên độc giả, SĐT, Tên sách đang mượn, Số ngày trễ (Badge màu đỏ cảnh báo), Tiền phạt tạm tính.
    - Phân trang bằng `DataTablePagination`.

- [ ] **Step 2: Kiểm tra biên dịch TypeScript**
  - Chạy lệnh: `npm run build` trong thư mục `frontend/`
  - Kết quả mong đợi: Build thành công.

- [ ] **Step 3: Commit**
  - `git add frontend/src/components/features/reports/FineStatsTab.tsx`
  - `git commit -m "feat(reports): add FineStatsTab component with fines chart and overdue readers table"`

---

### Task 5: Sub-component StaffStatsTab (Tab 5: Hiệu suất & Cursor nghiệp vụ)

**Files:**
- Create: `frontend/src/components/features/reports/StaffStatsTab.tsx`

**Interfaces:**
- Consumes:
  - `reportsService.getLibrarianPerformance(): Promise<GenericApiResponse[]>`
  - `reportsService.runRankingCursor(): Promise<GenericApiResponse[]>`
  - `reportsService.runReminderCursor(ngayKiemTra?: string): Promise<GenericApiResponse[]>`
- Produces: `StaffStatsTab: React.FC<{ month: number; year: number }>`

- [ ] **Step 1: Tạo file `frontend/src/components/features/reports/StaffStatsTab.tsx`**
  - Quản lý state: `staffData: GenericApiResponse[]`, `rankingData: GenericApiResponse[]`, `reminderData: GenericApiResponse[]`, `loadingStaff: boolean`, `runningCursor: boolean`.
  - Fetch `getLibrarianPerformance()` khi `month` hoặc `year` thay đổi.
  - Render Grouped `BarChart`:
    - Trục X: Họ tên nhân viên (`HOTEN`)
    - Cột 1: Số phiếu mượn đã lập (`SOPHIEU`, màu `#3b82f6`)
    - Cột 2: Số sách đã xử lý (`SOSACH`, màu `#10b981`)
  - Khối chức năng tự động hóa (Automated Business Procedures):
    - Khối 1: Nút "Chạy Xếp Loại Độc Giả" -> gọi `runRankingCursor()` -> hiển thị bảng kết quả phân loại (Tích cực, Bình thường, Vi phạm).
    - Khối 2: Input ngày kiểm tra + Nút "Quét & Nhắc Nhở Quá Hạn" -> gọi `runReminderCursor(date)` -> hiển thị danh sách độc giả được gửi nhắc nhở.

- [ ] **Step 2: Kiểm tra biên dịch TypeScript**
  - Chạy lệnh: `npm run build` trong thư mục `frontend/`
  - Kết quả mong đợi: Build thành công.

- [ ] **Step 3: Commit**
  - `git add frontend/src/components/features/reports/StaffStatsTab.tsx`
  - `git commit -m "feat(reports): add StaffStatsTab component with staff performance chart and cursor actions"`

---

### Task 6: Tái cấu trúc Container trang Reports (`src/pages/Reports.tsx`)

**Files:**
- Modify: `frontend/src/pages/Reports.tsx`

**Interfaces:**
- Consumes:
  - `MonthlyOverviewTab`, `BorrowStatsTab`, `InventoryStatsTab`, `FineStatsTab`, `StaffStatsTab`
  - `Tabs`, `TabsList`, `TabsTrigger`, `TabsContent` từ `../components/ui/tabs`

- [ ] **Step 1: Cập nhật `frontend/src/pages/Reports.tsx`**
  - Quản lý state `activeTab` (mặc định `'monthly'`), `month` (tháng hiện tại), `year` (năm hiện tại).
  - Render header trang: Tiêu đề "Báo Cáo & Thống Kê Thư Viện", kèm mô tả ngắn.
  - Render bộ điều khiển thời gian (Tháng/Năm) hiển thị ngữ cảnh khi đang ở tab "Tổng quan tháng" hoặc "Hiệu suất nhân viên".
  - Render `Tabs` với 5 `TabsTrigger`:
    - `monthly`: "Tổng quan tháng"
    - `borrows`: "Mượn - Trả"
    - `inventory`: "Kho & Đầu sách"
    - `fines`: "Tiền phạt & Quá hạn"
    - `staff`: "Hiệu suất nhân viên"
  - Render các `TabsContent` tương ứng nạp các sub-component đã tạo ở Task 1 -> Task 5.

- [ ] **Step 2: Kiểm tra toàn diện bản dựng**
  - Chạy lệnh: `npm run build` trong thư mục `frontend/`
  - Kết quả mong đợi: Build toàn dự án thành công không có lỗi type hay lint.

- [ ] **Step 3: Commit**
  - `git add frontend/src/pages/Reports.tsx`
  - `git commit -m "feat(reports): refactor Reports page to modular tabbed dashboard layout"`
