using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
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
        app.MapGet("api/categories", async (IDbConnection db, string? query, int page = 1, int pageSize = 10) =>
        {
            var offset = (page - 1) * pageSize;
            var sqlCount = "SELECT COUNT(*) FROM THELOAI";
            var sqlData = "SELECT * FROM THELOAI";

            if (!string.IsNullOrEmpty(query))
            {
                sqlCount += " WHERE TENTL LIKE @Query OR MATL LIKE @Query";
                sqlData += " WHERE TENTL LIKE @Query OR MATL LIKE @Query";
            }

            sqlData += " ORDER BY MATL OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

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
        .WithName("GetCategories")
        .RequireAuthorization()
           .WithTags("Categories");
    }
}
