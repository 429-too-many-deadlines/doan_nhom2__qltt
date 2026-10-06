using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Authors;

public class GetAuthorsEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/authors", async (IDbConnection db, string? query, int page = 1, int pageSize = 10) =>
        {
            var offset = (page - 1) * pageSize;
            var sqlCount = "SELECT COUNT(*) FROM TACGIA";
            var sqlData = "SELECT * FROM TACGIA";
            
            if (!string.IsNullOrEmpty(query))
            {
                sqlCount += " WHERE TENTG LIKE @Query OR MATG LIKE @Query";
                sqlData += " WHERE TENTG LIKE @Query OR MATG LIKE @Query";
            }

            sqlData += " ORDER BY MATG OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

            var parameters = new { Query = $"%{query}%", Offset = offset, PageSize = pageSize };
            
            var totalCount = await db.ExecuteScalarAsync<int>(sqlCount, parameters);
            var authors = await db.QueryAsync<dynamic>(sqlData, parameters);

            return Results.Ok(new PagedResult<dynamic>
            {
                Items = authors,
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            });
        })
        .WithName("GetAuthors")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Authors")
        .WithSummary("Lấy danh sách tác giả");
    }
}
