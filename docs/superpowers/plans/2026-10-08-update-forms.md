# Update Forms Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rà soát và sửa lỗi binding dữ liệu cho tất cả các form update, đồng thời thay thế các dropdown gọi API bằng component hỗ trợ tìm kiếm server-side.

**Architecture:** 
- **Backend**: Bổ sung tham số `query` vào các API GET list chưa hỗ trợ (ví dụ: `GetCategoriesEndpoint`).
- **Frontend Component**: Tạo một `AsyncCombobox` tái sử dụng (hoặc wrapper `Command` của shadcn) hỗ trợ tìm kiếm bất đồng bộ (debounce search).
- **Frontend Forms**: Sửa `useEffect` ở các `Update*Dialog` để binding đầy đủ `formData` từ props, và áp dụng `AsyncCombobox` vào `UpdateBookDialog` (Categories, Publishers).

**Tech Stack:** ASP.NET Core Minimal APIs, React, Tailwind CSS, shadcn/ui.

**Spec:** N/A (Based on chat bounded requirement).

## Global Constraints

- Không làm thay đổi signature của các entity có sẵn nếu không cần thiết.
- Đảm bảo form vẫn hoạt động mượt mà và gọi API hiệu quả (debounce).
- Sử dụng các UI components có sẵn trong `frontend/src/components/ui` để xây dựng `AsyncCombobox`.

## Review Focus

- API GetCategories trả về kết quả rỗng khi tìm kiếm bằng từ khóa không tồn tại -> Kiểm tra list rỗng trong dropdown hiển thị đúng thông báo "Không tìm thấy".
- Gõ liên tục vào ô tìm kiếm -> Gửi quá nhiều request -> Phải có debounce logic.
- Khởi tạo form update: dropdown phải hiển thị sẵn item đã được chọn thay vì phải tìm lại.

---

### Task 1: Bổ sung tham số tìm kiếm cho Categories API

**Files:**
- Modify: `QuanLyThuVien.Server/Endpoints/Categories/GetCategoriesEndpoint.cs`

**Interfaces:**
- Produces: API `GET /api/categories?query={string}` hỗ trợ tìm theo `TENTL`.

- [ ] **Step 1: Cập nhật hàm MapEndpoint nhận thêm `string? query`**

```csharp
app.MapGet("api/categories", async (IDbConnection db, string? query, int page = 1, int pageSize = 10) =>
```

- [ ] **Step 2: Cập nhật câu SQL để thêm `WHERE` clause**

Thêm logic filter:
```csharp
var sqlCount = "SELECT COUNT(*) FROM THELOAI";
var sqlData = "SELECT * FROM THELOAI";

if (!string.IsNullOrEmpty(query))
{
    sqlCount += " WHERE TENTL LIKE @Query OR MATL LIKE @Query";
    sqlData += " WHERE TENTL LIKE @Query OR MATL LIKE @Query";
}
sqlData += " ORDER BY MATL OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";
var parameters = new { Query = $"%{query}%", Offset = offset, PageSize = pageSize };
```

- [ ] **Step 3: Dùng biến `sqlCount` và `sqlData` thay vì chuỗi tĩnh**

- [ ] **Step 4: Cập nhật `categoriesService.ts` ở Frontend để truyền param `query`**

Modify `frontend/src/services/categories.service.ts`:
```typescript
getCategories: async (query?: string, page = 1, pageSize = 10) => {
  const response = await apiClient.get('/api/categories', { params: { query, page, pageSize } });
  return response.data;
}
```

- [ ] **Step 5: Commit**

---

### Task 2: Tạo component AsyncCombobox

**Files:**
- Create: `frontend/src/components/ui/async-combobox.tsx`

**Interfaces:**
- Consumes: `Combobox` / `Command` UI components.
- Produces: `<AsyncCombobox fetcher={...} value={...} onChange={...} placeholder={...} />`

- [ ] **Step 1: Tạo file `async-combobox.tsx` sử dụng Popover + Command của shadcn để làm Async Search**

Sử dụng `Command` và `Popover` của shadcn để xây dựng:
```tsx
import * as React from "react"
import { Check, ChevronsUpDown } from "lucide-react"
import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover"
import { useDebounce } from "@/hooks/use-debounce" // Hoặc tự viết inline debounce
```

- [ ] **Step 2: Viết logic Component `AsyncCombobox`**

Props:
- `value: string`
- `onChange: (val: string) => void`
- `fetcher: (query: string) => Promise<{value: string, label: string}[]>`
- `defaultOptions?: {value: string, label: string}[]`
- `placeholder?: string`

- [ ] **Step 3: Commit**

---

### Task 3: Sửa UpdateBookDialog để dùng AsyncCombobox và fill đầy đủ dữ liệu

**Files:**
- Modify: `frontend/src/components/features/books/UpdateBookDialog.tsx`

**Interfaces:**
- Consumes: `categoriesService`, `publishersService`, `AsyncCombobox`

- [ ] **Step 1: Sửa lại `useEffect` để điền đầy đủ dữ liệu sách**

```typescript
useEffect(() => {
  if (book && open) {
    setFormData({
      MADS: book.MADS || '',
      TENDS: book.TENDS || '',
      MATL: book.MATL || '',
      MANXB: book.MANXB || '',
      NAMXB: book.NAMXB?.toString() || '',
      SOTRANG: book.SOTRANG?.toString() || '',
      GIA: book.GIA?.toString() || ''
    });
  }
}, [book, open]);
```

- [ ] **Step 2: Viết fetcher cho Category và Publisher**

```typescript
const fetchCategories = async (query: string) => {
  const res = await categoriesService.getCategories(query);
  return res.Items.map((c: any) => ({ value: c.MATL, label: c.TENTL }));
};
const fetchPublishers = async (query: string) => {
  const res = await publishersService.getPublishers(query);
  return res.Items.map((p: any) => ({ value: p.MANXB, label: p.TENNXB }));
};
```

- [ ] **Step 3: Thay thẻ `<select>` bằng `<AsyncCombobox>`**

Thay cho `MATL` và `MANXB`. Truyền `defaultOptions` lấy từ `categories` và `publishers` props cũ (nếu cần) hoặc rely hoàn toàn vào async.

- [ ] **Step 4: Commit**

---

### Task 4: Fix Update Dialogs Khác (Reader, Employee, Author)

**Files:**
- Modify: `frontend/src/components/features/readers/UpdateReaderDialog.tsx`
- Modify: `frontend/src/components/features/employees/UpdateEmployeeDialog.tsx`
- Modify: `frontend/src/components/features/authors/UpdateAuthorDialog.tsx`
- Modify: `frontend/src/components/features/transactions/UpdateTransactionDialog.tsx`

- [ ] **Step 1: Rà soát và sửa `useEffect` trong từng form để đảm bảo load hết thông tin.**
Ví dụ, `UpdateReaderDialog` đã gán khá đầy đủ nhưng kiểm tra lại các key.
Trong `UpdateEmployeeDialog` (và các component tương tự), chắc chắn lấy đúng giá trị (kể cả foreign keys).

- [ ] **Step 2: Đảm bảo các `select` static (như `CHUCVU`, `TINHTRANGTRA`) nhận đúng `value` từ backend lúc mở form**

- [ ] **Step 3: Commit**

