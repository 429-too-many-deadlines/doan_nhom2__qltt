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
        app.MapGet("api/employees", async (IDbConnection db, string? query, int page = 1, int pageSize = 10) =>
        {
            var offset = (page - 1) * pageSize;
            var sqlCount = "SELECT COUNT(*) FROM NHANVIEN";
            var sqlData = "SELECT * FROM NHANVIEN";
            
            if (!string.IsNullOrEmpty(query))
            {
                sqlCount += " WHERE HOTEN LIKE @Query OR MANV LIKE @Query";
                sqlData += " WHERE HOTEN LIKE @Query OR MANV LIKE @Query";
            }

            sqlData += " ORDER BY MANV OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

            var parameters = new { Query = $"%{query}%", Offset = offset, PageSize = pageSize };
            
            var totalCount = await db.ExecuteScalarAsync<int>(sqlCount, parameters);
            var items = await db.QueryAsync<dynamic>(sqlData, parameters);

            return Results.Ok(new PagedResult<dynamic>
            {
                Items = items,
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            });
        })
        .WithName("GetEmployees")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Employees")
        .WithSummary("Lấy danh sách nhân viên");
    }
}
