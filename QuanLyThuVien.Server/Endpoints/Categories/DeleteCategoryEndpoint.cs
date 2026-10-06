using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Categories;

public class DeleteCategoryEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapDelete("api/categories/{id}", async (IDbConnection db, string id) =>
        {
            // Check if there are books using this category
            var count = await db.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM DAUSACH WHERE MATL = @MaTL", new { MaTL = id });
            if (count > 0)
            {
                return Results.BadRequest(new MessageResponse("Không thể xoá thể loại đang có sách"));
            }

            var sql = "DELETE FROM THELOAI WHERE MATL = @MaTL";
            var result = await db.ExecuteAsync(sql, new { MaTL = id });
            
            if (result == 0) return Results.NotFound(new MessageResponse("Không tìm thấy thể loại"));
            return Results.Ok(new MessageResponse("Xoá thể loại thành công"));
        })
        .WithName("DeleteCategory")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Categories")
        .WithSummary("Xóa thể loại");
    }
}
