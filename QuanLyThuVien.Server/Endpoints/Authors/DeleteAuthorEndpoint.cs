using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Authors;

public class DeleteAuthorEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapDelete("api/authors/{id}", async (IDbConnection db, string id) =>
        {
            var count = await db.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM DAUSACH_TACGIA WHERE MATG = @MaTG", new { MaTG = id });
            if (count > 0)
            {
                return Results.BadRequest(new MessageResponse("Không thể xoá tác giả đã được gán cho đầu sách"));
            }

            var sql = "DELETE FROM TACGIA WHERE MATG = @MaTG";
            var result = await db.ExecuteAsync(sql, new { MaTG = id });
            
            if (result == 0) return Results.NotFound(new MessageResponse("Không tìm thấy tác giả"));
            return Results.Ok(new MessageResponse("Xoá tác giả thành công"));
        })
        .WithName("DeleteAuthor")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Authors")
        .WithSummary("Xóa tác giả");
    }
}
