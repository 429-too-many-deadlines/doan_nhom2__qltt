using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Publishers;

public class GetPublishersEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/publishers", async (IDbConnection db, string? query) =>
        {
            var sql = "SELECT * FROM NHAXUATBAN";
            if (!string.IsNullOrEmpty(query))
            {
                sql += " WHERE TENNXB LIKE @Query OR MANXB LIKE @Query";
                var items = await db.QueryAsync(sql, new { Query = $"%{query}%" });
                return Results.Ok(items);
            }
            else
            {
                var items = await db.QueryAsync(sql);
                return Results.Ok(items);
            }
        })
        .WithName("GetPublishers")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Publishers")
        .WithSummary("Lấy danh sách nhà xuất bản");
    }
}
