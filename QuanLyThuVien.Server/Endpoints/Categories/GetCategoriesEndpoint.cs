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
        app.MapGet("api/categories", async (IDbConnection db, int page = 1, int pageSize = 10) =>
        {
            var offset = (page - 1) * pageSize;
            var totalCount = await db.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM THELOAI");
            var items = await db.QueryAsync<dynamic>("SELECT * FROM THELOAI ORDER BY MATL OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY", new { Offset = offset, PageSize = pageSize });
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
