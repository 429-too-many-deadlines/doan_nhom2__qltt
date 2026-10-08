# Sửa Lỗi Tính Nhất Quán Hệ Thống (DB - Backend - Frontend) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Khắc phục toàn bộ các điểm sai lệch tính nhất quán giữa CSDL, Backend và Frontend (gồm 2 endpoint tài khoản bị rỗng, crash dialog sửa sách, 30 lỗi build TypeScript, mất dữ liệu ngày sinh độc giả, và lệch casing thống kê Dashboard).

**Architecture:** Bổ sung triển khai 2 Minimal API endpoints (`GetAccounts`, `UpdateAccountStatus`) trong Backend sử dụng Dapper kết nối SQL Server. Chuẩn hóa interface TypeScript, xử lý đồng bộ casing giữa JSON response và React component trong Frontend, sửa các lỗi cú pháp catch block và unused imports để `npm run build` thành công 100%.

**Tech Stack:** ASP.NET Core 10 / Minimal APIs, Dapper, SQL Server 2022, React 19, TypeScript, Vite, Tailwind CSS.

**Spec:** [consistency_audit_report.md](/home/fullstuck_developer/.gemini/antigravity/brain/cc00fc3a-923c-46e4-9b00-6af0569a65c4/consistency_audit_report.md)

## Global Constraints

- Không làm thay đổi schema của 14 bảng và các stored procedure đang chạy ổn định trong CSDL.
- Giữ nguyên các chính sách phân quyền authorization (`QuanLyOnly`, `QuanLyHoacThuThu`, `ThuThuOnly`).
- Tuân thủ quy tắc Minimal API của dự án: mỗi endpoint là 1 class kế thừa `IEndpoint`.
- Đảm bảo `dotnet build` và `npm run build` đều pass không có lỗi hoặc cảnh báo.

## Review Focus

1. `GET /api/auth/accounts`: Tài khoản không liên kết với `MANV` hoặc `MADG` (admin độc lập) không được gây lỗi NULL exception khi JOIN lấy tên chủ sở hữu.
2. `PUT /api/auth/accounts/{username}/status`: Truyền username không tồn tại trong DB phải trả về HTTP 404 thay vì 500.
3. `UpdateBookDialog`: Phải xử lý an toàn mảng danh mục / NXB (`res.items || res.Items || []`) để tránh crash bất kể backend trả về casing nào.
4. `Dashboard` Top 5 sách: Phải hiển thị đầy đủ tên sách, mã sách và số lượt mượn khi có dữ liệu từ `SP_THONGKETHANG`.
5. `UpdateReaderDialog`: Khi mở modal sửa độc giả, ngày sinh phải luôn hiển thị đúng ngày đã lưu trong DB (format `YYYY-MM-DD`).

---

### Task 1: Backend - Hiện thực hóa `GetAccountsEndpoint`

**Files:**
- Modify: `QuanLyThuVien.Server/Endpoints/Auth/GetAccountsEndpoint.cs`
- Test: `QuanLyThuVien.Server` build & HTTP test

**Interfaces:**
- Consumes: Bảng `TAIKHOAN`, `NHANVIEN`, `DOCGIA`
- Produces: `GET /api/auth/accounts` trả về `IEnumerable<AccountDto>`:
  `{ username, role, manv, madg, ownerName, status }`

- [ ] **Step 1: Viết mã triển khai `GetAccountsEndpoint.cs`**

```csharp
using Dapper;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Auth;

public class GetAccountsEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("/api/auth/accounts", HandleAsync)
           .RequireAuthorization("QuanLyOnly")
           .WithTags("Auth")
           .WithSummary("Lấy danh sách tài khoản")
           .WithDescription("Lấy toàn bộ tài khoản kèm tên nhân viên hoặc độc giả sở hữu.");
    }

    private static async Task<IResult> HandleAsync(IDbConnection db)
    {
        const string sql = @"
            SELECT 
                tk.TENDANGNHAP AS Username,
                tk.VAITRO AS Role,
                tk.MANV AS MaNV,
                tk.MADG AS MaDG,
                COALESCE(nv.HOTEN, dg.HOTEN, N'Chưa liên kết') AS OwnerName,
                tk.TRANGTHAI AS Status
            FROM TAIKHOAN tk
            LEFT JOIN NHANVIEN nv ON tk.MANV = nv.MANV
            LEFT JOIN DOCGIA dg ON tk.MADG = dg.MADG
            ORDER BY tk.TENDANGNHAP";

        var accounts = await db.QueryAsync<AccountResponse>(sql);
        return Results.Ok(accounts);
    }

    public record AccountResponse(string Username, string Role, string? MaNV, string? MaDG, string OwnerName, bool Status);
}
```

- [ ] **Step 2: Chạy kiểm tra biên dịch backend**

Run: `dotnet build QuanLyThuVien.Server/QuanLyThuVien.Server.csproj`
Expected: `Build succeeded. 0 Error(s)`

- [ ] **Step 3: Commit**

```bash
git add QuanLyThuVien.Server/Endpoints/Auth/GetAccountsEndpoint.cs
git commit -m "feat(auth): implement GetAccountsEndpoint"
```

---

### Task 2: Backend - Hiện thực hóa `UpdateAccountStatusEndpoint`

**Files:**
- Modify: `QuanLyThuVien.Server/Endpoints/Auth/UpdateAccountStatusEndpoint.cs`
- Test: `QuanLyThuVien.Server` build

**Interfaces:**
- Consumes: Bảng `TAIKHOAN`
- Produces: `PUT /api/auth/accounts/{username}/status` nhận body `{ status: bool }`, trả về `MessageResponse`

- [ ] **Step 1: Viết mã triển khai `UpdateAccountStatusEndpoint.cs`**

```csharp
using Dapper;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Auth;

public class UpdateAccountStatusEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("/api/auth/accounts/{username}/status", HandleAsync)
           .RequireAuthorization("QuanLyOnly")
           .WithTags("Auth")
           .WithSummary("Cập nhật trạng thái khóa/mở tài khoản")
           .WithDescription("Thay đổi cột TRANGTHAI (1/0) của bảng TAIKHOAN.");
    }

    private static async Task<IResult> HandleAsync(
        string username,
        [FromBody] UpdateAccountStatusRequest req,
        IDbConnection db)
    {
        const string checkSql = "SELECT COUNT(*) FROM TAIKHOAN WHERE TENDANGNHAP = @Username";
        var count = await db.ExecuteScalarAsync<int>(checkSql, new { Username = username });
        if (count == 0)
        {
            return Results.NotFound(new MessageResponse("Tài khoản không tồn tại."));
        }

        const string updateSql = "UPDATE TAIKHOAN SET TRANGTHAI = @Status WHERE TENDANGNHAP = @Username";
        await db.ExecuteAsync(updateSql, new { Status = req.Status ? 1 : 0, Username = username });

        string msg = req.Status ? "Mở khóa tài khoản thành công." : "Khóa tài khoản thành công.";
        return Results.Ok(new MessageResponse(msg));
    }

    public record UpdateAccountStatusRequest(bool Status);
}
```

- [ ] **Step 2: Chạy kiểm tra biên dịch backend**

Run: `dotnet build QuanLyThuVien.Server/QuanLyThuVien.Server.csproj`
Expected: `Build succeeded. 0 Error(s)`

- [ ] **Step 3: Commit**

```bash
git add QuanLyThuVien.Server/Endpoints/Auth/UpdateAccountStatusEndpoint.cs
git commit -m "feat(auth): implement UpdateAccountStatusEndpoint"
```

---

### Task 3: Frontend - Sửa lỗi Crash trong `UpdateBookDialog`

**Files:**
- Modify: `frontend/src/components/features/books/UpdateBookDialog.tsx:75-90`

**Interfaces:**
- Consumes: `categoriesService.getCategories`, `publishersService.getPublishers`
- Produces: Safe mapping combobox options không bị crash khi `res.items` trả về

- [ ] **Step 1: Sửa hàm `fetchCategories` và `fetchPublishers` trong `UpdateBookDialog.tsx`**

Đổi:
```ts
const fetchCategories = async (query: string) => {
  const res = await categoriesService.getCategories(query);
  const items = res.items || (res as any).Items || [];
  return items.map((c: any) => ({ value: c.MATL, label: c.TENTL }));
};

const fetchPublishers = async (query: string) => {
  const res = await publishersService.getPublishers(query);
  const items = res.items || (res as any).Items || [];
  return items.map((p: any) => ({ value: p.MANXB, label: p.TENNXB }));
};
```

- [ ] **Step 2: Xác nhận không còn lỗi `.Items` trong source FE**

Run: `grep -rn "\.Items" frontend/src/`
Expected: Không tìm thấy kết quả nào.

- [ ] **Step 3: Commit**

```bash
git add frontend/src/components/features/books/UpdateBookDialog.tsx
git commit -m "fix(books): fix casing crash on res.items in UpdateBookDialog"
```

---

### Task 4: Frontend - Khắc phục 30 lỗi TypeScript & Lint Build

**Files:**
- Modify: `frontend/src/contexts/AuthContext.tsx`
- Modify: `frontend/src/types/api.types.ts`
- Modify: `frontend/src/pages/Accounts.tsx`
- Modify: `frontend/src/pages/BookDetails.tsx`
- Modify: `frontend/src/pages/Books.tsx`
- Modify: `frontend/src/pages/Dashboard.tsx`
- Modify: `frontend/src/pages/Readers.tsx`
- Modify: `frontend/src/pages/Reports.tsx`
- Modify: `frontend/src/pages/Settings.tsx`
- Modify: `frontend/src/services/authors.service.ts`
- Modify: `frontend/src/services/publishers.service.ts`

**Interfaces:**
- Produces: `npm run build` (`tsc -b && vite build`) hoàn thành thành công với exit code 0.

- [ ] **Step 1: Xóa unused import `useEffect` trong `AuthContext.tsx`**
- [ ] **Step 2: Xóa unused import `PagedResult` trong `authors.service.ts` và `publishers.service.ts`**
- [ ] **Step 3: Sửa các biến trong catch clause**
  - Trong `Accounts.tsx`, `BookDetails.tsx`, `Settings.tsx`: đổi `catch (_error)` hoặc `catch` thành `catch (error)` để `err = error as ...` hợp lệ.
  - Trong `Books.tsx`, `Dashboard.tsx`, `Readers.tsx`, `Reports.tsx`: đổi `catch (_error)` thành `catch (error)` hoặc log `_error`.
- [ ] **Step 4: Cập nhật type `TopBookResponse` và sửa `Dashboard.tsx`**
  - Trong `api.types.ts`:
  ```ts
  export interface TopBookResponse {
    MADS?: string;
    TENDS?: string;
    maSach?: string;
    tenSach?: string;
    SOLUOTMUON?: number;
  }
  ```
  - Trong `Dashboard.tsx`: chuẩn hóa đọc cả `book.TENDS || book.tenSach` và `book.MADS || book.maSach`.
- [ ] **Step 5: Chạy kiểm tra TypeScript build**

Run: `npm run build --prefix frontend`
Expected: Exit code 0, không còn lỗi TypeScript.

- [ ] **Step 6: Commit**

```bash
git add frontend/src/
git commit -m "fix(frontend): resolve all typescript and lint build errors"
```

---

### Task 5: Frontend & Backend - Đồng bộ Casing Dashboard & Báo cáo Tháng

**Files:**
- Modify: `QuanLyThuVien.Server/Endpoints/Reports/GetMonthlyStatsEndpoint.cs`
- Modify: `frontend/src/pages/Dashboard.tsx`
- Modify: `frontend/src/pages/Reports.tsx`
- Modify: `frontend/src/types/api.types.ts`

**Interfaces:**
- Consumes: `SP_THONGKETHANG`
- Produces: Thẻ thống kê Dashboard hiển thị đúng số liệu thay vì số 0 / trống.

- [ ] **Step 1: Cập nhật `MonthlyStatsResponse` trong `api.types.ts` hỗ trợ cả camelCase và UPPERCASE**

```ts
export interface MonthlyStatsResponse {
  soPhieu?: number;
  soLuotSach?: number;
  tienPhat?: number;
  SOPHIEU?: number;
  SOLUOTSACH?: number;
  TIENPHAT?: number;
  top5Books: TopBookResponse[];
}
```

- [ ] **Step 2: Cập nhật hiển thị trong `Dashboard.tsx` và `Reports.tsx`**

Đổi:
- Số phiếu: `stats.soPhieu ?? stats.SOPHIEU ?? 0`
- Số lượt sách: `stats.soLuotSach ?? stats.SOLUOTSACH ?? 0`
- Tiền phạt: `(stats.tienPhat ?? stats.TIENPHAT ?? 0).toLocaleString()`

- [ ] **Step 3: Kiểm tra biên dịch**

Run: `npm run build --prefix frontend`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add frontend/src/types/api.types.ts frontend/src/pages/Dashboard.tsx frontend/src/pages/Reports.tsx
git commit -m "fix(reports): align casing for monthly stats cards and top books"
```

---

### Task 6: Frontend - Sửa trường Ngày sinh Độc giả (`NGSINH` vs `ngaySinh`)

**Files:**
- Modify: `frontend/src/types/api.types.ts:116-125`
- Modify: `frontend/src/components/features/readers/UpdateReaderDialog.tsx:32-35`

**Interfaces:**
- Consumes: Response từ `SP_TIMDOCGIA`
- Produces: Ô ngày sinh hiển thị đúng ngày sinh của độc giả khi mở dialog cập nhật

- [ ] **Step 1: Cập nhật interface `Reader` trong `frontend/src/types/api.types.ts`**

```ts
export interface Reader {
    MADG: string;
    HOTEN: string;
    NGSINH?: string;
    ngaySinh?: string;
    GIOITINH: string;
    DIACHI?: string;
    SODT: string;
    EMAIL?: string;
    TONGNO?: number;
}
```

- [ ] **Step 2: Cập nhật `UpdateReaderDialog.tsx` để lấy `reader.NGSINH || reader.ngaySinh`**

```ts
const birthDate = reader.NGSINH || reader.ngaySinh;
NGSINH: birthDate ? new Date(birthDate).toISOString().split('T')[0] : '',
```

- [ ] **Step 3: Kiểm tra biên dịch frontend**

Run: `npm run build --prefix frontend`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add frontend/src/types/api.types.ts frontend/src/components/features/readers/UpdateReaderDialog.tsx
git commit -m "fix(readers): support NGSINH field in reader update form"
```

---

### Task 7: Kiểm thử Tích hợp & Nghiệm thu Hệ thống

**Files:**
- Test toàn bộ: BE build, FE build, Live API endpoints

- [ ] **Step 1: Chạy toàn bộ build Backend**
Run: `dotnet build QuanLyThuVien.Server/QuanLyThuVien.Server.csproj`
Expected: 0 Error(s), 0 Warning(s)

- [ ] **Step 2: Chạy toàn bộ build Frontend**
Run: `npm run build --prefix frontend`
Expected: `vite build` completed successfully

- [ ] **Step 3: Kiểm tra git status và dọn dẹp các file rác (`.orig`, patch cũ)**
Run: `git status`
Expected: Code sạch sẽ, sẵn sàng triển khai.

