# Backend CRUD Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Hoàn thiện các API CRUD cho Sách (DAUSACH) và tạo mới CRUD cho Thể loại (THELOAI) để chuẩn hóa danh mục.

**Architecture:** Sử dụng Minimal APIs trong ASP.NET Core với Dapper để gọi trực tiếp các Stored Procedure hoặc thực thi truy vấn SQL. Các endpoint được tổ chức theo tính năng (Feature-folder structure).

**Tech Stack:** ASP.NET Core 8/9 Minimal APIs, Dapper, SQL Server.

**Spec:** Không có Spec chi tiết (Bounded exploration task). 

## Global Constraints

- Tuân thủ cấu trúc thư mục hiện tại: `Endpoints/{Entity}/{Action}Endpoint.cs`.
- Mọi endpoint phải kế thừa interface `IEndpoint` và đăng ký qua `app.MapX()`.
- Trả về `Results.Ok()` cho thành công và `Results.BadRequest()` nếu lỗi.

## Review Focus

- Đầu vào rỗng (Empty/null request body): Endpoint Create/Update trả về 400 Bad Request.
- Lỗi từ Database (ví dụ trùng khóa chính): Bắt lỗi Exception hoặc dựa vào kết quả của Stored Procedure để trả về 400.

---

### Task 1: Thiết lập QuanLyThuVien.Server.http cho kiểm thử

Do dự án chưa có Unit Test project, chúng ta sẽ sử dụng file `.http` để kiểm thử (Integration Test) cho các API.

**Files:**
- Modify: `QuanLyThuVien.Server/QuanLyThuVien.Server.http:1-100`

**Interfaces:**
- Consumes: None
- Produces: REST API test requests.

- [ ] **Step 1: Thêm request kiểm thử Create Book**
```http
### Test Create Book - Missing fields
POST {{QuanLyThuVien.Server_HostAddress}}/api/books
Content-Type: application/json

{
  "mads": "DS099",
  "tends": ""
}
```

- [ ] **Step 2: Commit file test**
```bash
git add QuanLyThuVien.Server/QuanLyThuVien.Server.http
git commit -m "test: prepare test cases for CRUD APIs"
```

---

### Task 2: Hoàn thiện CreateBookEndpoint

**Files:**
- Modify: `QuanLyThuVien.Server/Endpoints/Books/CreateBookEndpoint.cs`

**Interfaces:**
- Consumes: Cần gọi `SP_THEMDAUSACH`.
- Produces: API `POST /api/books`.

- [ ] **Step 1: Implement mã cho CreateBookEndpoint**
```csharp
using Dapper;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Books;

public class CreateBookEndpoint : IEndpoint
{
    public record CreateBookRequest(string MaDS, string TenDS, string MaTL, string MaNXB, int NamXB, int SoTrang, decimal Gia);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("api/books", async (IDbConnection db, [FromBody] CreateBookRequest req) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@MADS", req.MaDS);
            parameters.Add("@TENDS", req.TenDS);
            parameters.Add("@MATL", req.MaTL);
            parameters.Add("@MANXB", req.MaNXB);
            parameters.Add("@NAMXB", req.NamXB);
            parameters.Add("@SOTRANG", req.SoTrang);
            parameters.Add("@GIA", req.Gia);

            var result = await db.ExecuteAsync("SP_THEMDAUSACH", parameters, commandType: CommandType.StoredProcedure);
            return Results.Ok(new { message = "Thêm đầu sách thành công" });
        })
        .WithName("CreateBook")
        .WithTags("Books")
        .WithSummary("Thêm mới đầu sách");
    }
}
```

- [ ] **Step 2: Test API qua file .http (Run)**
Run request "Test Create Book" trong file `.http`. Đảm bảo trả về 200 OK nếu dữ liệu đúng hoặc lỗi hợp lý nếu nhập sai.

- [ ] **Step 3: Commit**
```bash
git add QuanLyThuVien.Server/Endpoints/Books/CreateBookEndpoint.cs
git commit -m "feat: implement CreateBook endpoint"
```

---

### Task 3: Hoàn thiện UpdateBookEndpoint

**Files:**
- Modify: `QuanLyThuVien.Server/Endpoints/Books/UpdateBookEndpoint.cs`

**Interfaces:**
- Consumes: Cần gọi `SP_SUADAUSACH`.
- Produces: API `PUT /api/books/{id}`.

- [ ] **Step 1: Implement mã cho UpdateBookEndpoint**
```csharp
using Dapper;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Books;

public class UpdateBookEndpoint : IEndpoint
{
    public record UpdateBookRequest(string TenDS, string MaTL, string MaNXB, int NamXB, int SoTrang, decimal Gia);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("api/books/{id}", async (IDbConnection db, string id, [FromBody] UpdateBookRequest req) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@MADS", id);
            parameters.Add("@TENDS", req.TenDS);
            parameters.Add("@MATL", req.MaTL);
            parameters.Add("@MANXB", req.MaNXB);
            parameters.Add("@NAMXB", req.NamXB);
            parameters.Add("@SOTRANG", req.SoTrang);
            parameters.Add("@GIA", req.Gia);

            var result = await db.ExecuteAsync("SP_SUADAUSACH", parameters, commandType: CommandType.StoredProcedure);
            return Results.Ok(new { message = "Cập nhật đầu sách thành công" });
        })
        .WithName("UpdateBook")
        .WithTags("Books")
        .WithSummary("Cập nhật đầu sách");
    }
}
```

- [ ] **Step 2: Test API qua file .http**
Gửi request PUT để update đầu sách vừa tạo ở Task 2.

- [ ] **Step 3: Commit**
```bash
git add QuanLyThuVien.Server/Endpoints/Books/UpdateBookEndpoint.cs
git commit -m "feat: implement UpdateBook endpoint"
```

---

### Task 4: Tạo CRUD Endpoints cho Danh mục Thể loại (THELOAI)

**Files:**
- Create: `QuanLyThuVien.Server/Endpoints/Categories/GetCategoriesEndpoint.cs`
- Create: `QuanLyThuVien.Server/Endpoints/Categories/CreateCategoryEndpoint.cs`

**Interfaces:**
- Consumes: Bảng `THELOAI` trong DB.
- Produces: API `GET /api/categories`, `POST /api/categories`.

- [ ] **Step 1: Implement GetCategoriesEndpoint**
```csharp
using Dapper;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Categories;

public class GetCategoriesEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/categories", async (IDbConnection db) =>
        {
            var categories = await db.QueryAsync("SELECT * FROM THELOAI");
            return Results.Ok(categories);
        })
        .WithName("GetCategories")
        .WithTags("Categories");
    }
}
```

- [ ] **Step 2: Implement CreateCategoryEndpoint**
```csharp
using Dapper;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Categories;

public class CreateCategoryEndpoint : IEndpoint
{
    public record CreateCategoryReq(string MaTL, string TenTL);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("api/categories", async (IDbConnection db, [FromBody] CreateCategoryReq req) =>
        {
            var sql = "INSERT INTO THELOAI(MATL, TENTL) VALUES (@MaTL, @TenTL)";
            await db.ExecuteAsync(sql, req);
            return Results.Ok(new { message = "Thêm thể loại thành công" });
        })
        .WithName("CreateCategory")
        .WithTags("Categories");
    }
}
```

- [ ] **Step 3: Test API**
Sử dụng file `.http` hoặc Swagger (nếu có) để gọi `GET /api/categories`.

- [ ] **Step 4: Commit**
```bash
git add QuanLyThuVien.Server/Endpoints/Categories
git commit -m "feat: add CRUD for Categories"
```
