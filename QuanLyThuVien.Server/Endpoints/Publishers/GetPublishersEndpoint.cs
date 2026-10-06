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
        app.MapGet("api/publishers", async (IDbConnection db, string? query, int page = 1, int pageSize = 10) =>
        {
            var offset = (page - 1) * pageSize;
            var sqlCount = "SELECT COUNT(*) FROM NHAXUATBAN";
            var sqlData = "SELECT * FROM NHAXUATBAN";
            
            if (!string.IsNullOrEmpty(query))
            {
                sqlCount += " WHERE TENNXB LIKE @Query OR MANXB LIKE @Query";
                sqlData += " WHERE TENNXB LIKE @Query OR MANXB LIKE @Query";
            }

            sqlData += " ORDER BY MANXB OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

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
        .WithName("GetPublishers")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Publishers")
        .WithSummary("Lấy danh sách nhà xuất bản");
    }
}
