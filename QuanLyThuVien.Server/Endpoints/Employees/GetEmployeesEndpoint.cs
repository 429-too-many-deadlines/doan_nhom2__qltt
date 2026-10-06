using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Employees;

public class GetEmployeesEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/employees", async (IDbConnection db, string? query) =>
        {
            var sql = "SELECT * FROM NHANVIEN";
            if (!string.IsNullOrEmpty(query))
            {
                sql += " WHERE HOTEN LIKE @Query OR MANV LIKE @Query";
                var items = await db.QueryAsync(sql, new { Query = $"%{query}%" });
                return Results.Ok(items);
            }
            else
            {
                var items = await db.QueryAsync(sql);
                return Results.Ok(items);
            }
        })
        .WithName("GetEmployees")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Employees")
        .WithSummary("Lấy danh sách nhân viên");
    }
}
