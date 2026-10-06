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
        app.MapGet("api/categories", async (IDbConnection db) =>
        {
            var categories = await db.QueryAsync("SELECT * FROM THELOAI");
            return Results.Ok(categories);
        })
        .WithName("GetCategories")
        .RequireAuthorization()
           .WithTags("Categories");
    }
}
