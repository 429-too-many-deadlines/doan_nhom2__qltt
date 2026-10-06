using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Categories;

public class UpdateCategoryEndpoint : IEndpoint
{
    public record UpdateCategoryRequest(string TenTL);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("api/categories/{id}", async (IDbConnection db, string id, [FromBody] UpdateCategoryRequest req) =>
        {
            try
            {
                var sql = "UPDATE THELOAI SET TENTL = @TenTL WHERE MATL = @MaTL";
                var result = await db.ExecuteAsync(sql, new { TenTL = req.TenTL, MaTL = id });
                
                if (result == 0) return Results.NotFound(new MessageResponse("Không tìm thấy thể loại"));
                return Results.Ok(new MessageResponse("Cập nhật thể loại thành công"));
            }
            catch (System.Exception ex)
            {
                return Results.BadRequest(new MessageResponse(ex.Message));
            }
        })
        .WithName("UpdateCategory")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Categories")
        .WithSummary("Cập nhật thể loại");
    }
}
