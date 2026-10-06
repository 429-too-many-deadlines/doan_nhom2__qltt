using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Authors;

public class CreateAuthorEndpoint : IEndpoint
{
    public record CreateAuthorRequest(string MaTG, string TenTG, int? NamSinh, string? QuocTich);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("api/authors", async (IDbConnection db, [FromBody] CreateAuthorRequest req) =>
        {
            try
            {
                var sql = "INSERT INTO TACGIA(MATG, TENTG, NAMSINH, QUOCTICH) VALUES(@MaTG, @TenTG, @NamSinh, @QuocTich)";
                await db.ExecuteAsync(sql, req);
                return Results.Ok(new MessageResponse("Thêm tác giả thành công"));
            }
            catch (System.Exception ex)
            {
                return Results.BadRequest(new MessageResponse(ex.Message));
            }
        })
        .WithName("CreateAuthor")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Authors")
        .WithSummary("Thêm tác giả");
    }
}
