using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Authors;

public class UpdateAuthorEndpoint : IEndpoint
{
    public record UpdateAuthorRequest(string TenTG, int? NamSinh, string? QuocTich);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("api/authors/{id}", async (IDbConnection db, string id, [FromBody] UpdateAuthorRequest req) =>
        {
            var sql = "UPDATE TACGIA SET TENTG = @TenTG, NAMSINH = @NamSinh, QUOCTICH = @QuocTich WHERE MATG = @MaTG";
            var result = await db.ExecuteAsync(sql, new { TenTG = req.TenTG, NamSinh = req.NamSinh, QuocTich = req.QuocTich, MaTG = id });
            
            if (result == 0) return Results.NotFound(new MessageResponse("Không tìm thấy tác giả"));
            return Results.Ok(new MessageResponse("Cập nhật tác giả thành công"));
        })
        .WithName("UpdateAuthor")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Authors")
        .WithSummary("Cập nhật tác giả");
    }
}
