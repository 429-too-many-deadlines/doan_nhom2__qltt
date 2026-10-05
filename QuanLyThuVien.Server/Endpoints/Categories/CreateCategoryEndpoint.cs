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
