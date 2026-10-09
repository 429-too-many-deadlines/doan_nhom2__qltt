# Remove Employee Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove all Employee and Role-based management from the database, backend, and frontend, reducing the system to a single-admin architecture.

**Architecture:** We will first write and execute a live migration script to adapt the production database. Then we will update the repository's source SQL files. Following the data layer, we will remove and update Minimal APIs in the .NET backend to drop employee properties and role requirements. Finally, we will adapt the React frontend by deleting the employee page, removing employee fields from transaction forms, and simplifying the accounts page to a password change form.

**Tech Stack:** SQL Server (T-SQL), .NET Minimal APIs (C#), React (TypeScript).

**Spec:** `docs/superpowers/specs/2026-10-09-remove-employee-management-design.md`

## Global Constraints
- Database changes must be applied to the live database using the exact connection string provided.
- Do not add new dependencies; modify existing code where possible.
- All unused code relating to Employees and roles (including routing, navigation, state) must be completely removed.

## Review Focus
1. **Broken References in Transactions:** A transaction is created but fails because the API or SP still expects `Manv`. Add test/verification step in Task 4 to ensure transaction creation succeeds without `Manv`.
2. **Locked Out of Admin Account:** The login flow fails after removing role checks. Add verification in Task 3 to ensure successful login with the new single-admin structure.
3. **Frontend Routing Crash:** Navigating to a removed route (like `/employees`) crashes the app instead of redirecting. Add verification in Task 5 to ensure proper fallback/404.

---

### Task 1: Live DB Migration Script & Execution

**Files:**
- Create: `db/migration_remove_employee.sql`

**Interfaces:**
- Produces: The live DB schema updated to match the single-admin design.

- [ ] **Step 1: Write the migration script**
Create `db/migration_remove_employee.sql` containing T-SQL to:
1. Drop constraints `CK_TAIKHOAN_VAITRO`, `CK_TAIKHOAN_CHUSOHUU`, and FKs `FK_TAIKHOAN_NHANVIEN`, `FK_TAIKHOAN_DOCGIA`.
2. Alter `TAIKHOAN` to drop `MANV`, `MADG`, `VAITRO`.
3. Drop FK `FK_PHIEUMUON_NHANVIEN`.
4. Alter `PHIEUMUON` to drop `MANV`.
5. Drop `NHANVIEN` table.
6. Drop SPs: `SP_THEMNHANVIEN`, `SP_SUANHANVIEN`, `SP_XOANHANVIEN`, `SP_LAYDANHSACHNHANVIEN`.
7. Drop View: `VW_BC_HIEUSUAT_NHANVIEN`.
8. Alter SP `SP_THEMPHIEUMUON` (and related) to remove `@MANV`.

- [ ] **Step 2: Execute migration against Live DB**
Run the SQL script against the live database using the provided connection string:
`Data Source=localhost,1433;User ID=sa;Password=StrongPassword123!;Pooling=False;Connect Timeout=30;Encrypt=True;Trust Server Certificate=True;Authentication=SqlPassword;Application Name=vscode-mssql;Connect Retry Count=1;Connect Retry Interval=10;Command Timeout=30`
Expected: Command completes successfully.

- [ ] **Step 3: Commit**
```bash
git add db/migration_remove_employee.sql
git commit -m "db: create and run migration script for removing employees"
```

### Task 2: Source Code Database Updates

**Files:**
- Modify: `db/1_TaoBang.sql`
- Modify: `db/2_DuLieuMau.sql`
- Modify: `db/5_StoredProcedure.sql`
- Modify: `db/7_AnToanThongTin.sql`
- Modify: `db/8_Report.sql`
- Modify: `db/init_all.sql`

**Interfaces:**
- Consumes: The schema decisions from Task 1.

- [ ] **Step 1: Update schema scripts**
Update `1_TaoBang.sql` and `init_all.sql` to remove the `NHANVIEN` table creation, remove `MANV` from `PHIEUMUON`, and remove `MANV`, `MADG`, `VAITRO` from `TAIKHOAN`.

- [ ] **Step 2: Update mock data**
Update `2_DuLieuMau.sql` and `init_all.sql` to remove `NHANVIEN` inserts and ensure `TAIKHOAN` only inserts one admin account (e.g., `admin`). Remove `MANV` values from `PHIEUMUON` inserts.

- [ ] **Step 3: Update SPs, Security, and Reports**
Update `5_StoredProcedure.sql`, `7_AnToanThongTin.sql`, `8_Report.sql`, and `init_all.sql` to reflect the dropped SPs/Views and updated signatures.

- [ ] **Step 4: Commit**
```bash
git add db/
git commit -m "db: update source sql scripts to remove employee management"
```

### Task 3: Backend API - Remove Employees & Update Auth

**Files:**
- Delete: `QuanLyThuVien.Server/Endpoints/Employees/*` (and the directory itself)
- Modify: `QuanLyThuVien.Server/Endpoints/Auth/LoginEndpoint.cs` (or equivalent)
- Modify: `QuanLyThuVien.Server/Endpoints/Accounts/AccountEndpoints.cs` (or equivalent)
- Modify: Global Authorization configuration in `Program.cs` or `Extensions.cs`.

**Interfaces:**
- Produces: An Auth system that only requires username and issues a simple JWT, and an Accounts system that only updates passwords.

- [ ] **Step 1: Delete Employee Endpoints**
Delete the `Endpoints/Employees` directory completely.

- [ ] **Step 2: Simplify Auth & Accounts**
Update Auth logic to stop checking roles or employee links. Update the JWT generation payload to only include the username. 
Update Accounts endpoints to only expose an `UpdatePassword` endpoint for the logged-in admin.

- [ ] **Step 3: Remove Role Authorizations**
Search for `[Authorize(Roles = ...)]` or equivalent minimal API `.RequireAuthorization("...")` across all Endpoints and change them to simple `.RequireAuthorization()`.

- [ ] **Step 4: Verify build and endpoints**
Run: `dotnet build QuanLyThuVien.Server`
Expected: Build succeeds.

- [ ] **Step 5: Commit**
```bash
git add QuanLyThuVien.Server/
git commit -m "feat(api): remove employee endpoints and simplify auth"
```

### Task 4: Backend API - Update Transactions & Reports

**Files:**
- Modify: `QuanLyThuVien.Server/Endpoints/Transactions/*`
- Modify: `QuanLyThuVien.Server/Endpoints/Reports/*`

**Interfaces:**
- Consumes: The updated DB stored procedures.

- [ ] **Step 1: Update Transactions Endpoints**
Remove `Manv` / `NhanVienId` from `CreateTransactionRequest` and `UpdateTransactionRequest` DTOs. Ensure the database calls no longer pass this parameter.

- [ ] **Step 2: Update Reports Endpoints**
Remove the endpoint that fetches `VW_BC_HIEUSUAT_NHANVIEN` data.

- [ ] **Step 3: Verify build**
Run: `dotnet build QuanLyThuVien.Server`
Expected: Build succeeds.

- [ ] **Step 4: Commit**
```bash
git add QuanLyThuVien.Server/
git commit -m "feat(api): update transactions and reports to remove employee deps"
```

### Task 5: Frontend - Route & Sidebar Cleanup

**Files:**
- Modify: `frontend/src/components/layout/app-sidebar.tsx`
- Modify: `frontend/src/App.tsx` (or routing file)

**Interfaces:**
- Produces: A cleaner UI without Employee or role-based menus.

- [ ] **Step 1: Update Sidebar**
Remove the "Quản lý nhân viên" menu item from `app-sidebar.tsx`. Rename "Quản lý tài khoản" to "Đổi mật khẩu" (or similar). Remove any role-based conditional rendering for sidebar items.

- [ ] **Step 2: Update Routing**
Remove the route mapping for `/employees`. Ensure no route guards depend on specific roles.

- [ ] **Step 3: Verify types**
Run: `cd frontend && npm run typecheck` (or `npm run build` depending on setup) to ensure no broken imports.

- [ ] **Step 4: Commit**
```bash
git add frontend/
git commit -m "feat(ui): clean up routes and sidebar"
```

### Task 6: Frontend - Pages Update

**Files:**
- Delete: `frontend/src/pages/Employees.tsx`
- Modify: `frontend/src/pages/Accounts.tsx`
- Modify: `frontend/src/pages/Transactions.tsx`
- Modify: `frontend/src/pages/Reports.tsx`

**Interfaces:**
- Consumes: The simplified API.

- [ ] **Step 1: Delete Employees Page**
Delete `Employees.tsx`.

- [ ] **Step 2: Update Accounts Page**
Rewrite `Accounts.tsx` to be a simple "Change Password" form (Old Password, New Password, Confirm New Password) calling the updated Account API, removing the list view and creation forms.

- [ ] **Step 3: Update Transactions Page**
Remove the "Mã NV" column from the transaction data table. Remove the employee selection field from the create/edit transaction modal/form.

- [ ] **Step 4: Update Reports Page**
Remove the tab or chart that displayed employee performance.

- [ ] **Step 5: Verify build**
Run: `cd frontend && npm run build` (or similar build command).
Expected: Build succeeds.

- [ ] **Step 6: Commit**
```bash
git add frontend/
git commit -m "feat(ui): update pages for single admin architecture"
```
