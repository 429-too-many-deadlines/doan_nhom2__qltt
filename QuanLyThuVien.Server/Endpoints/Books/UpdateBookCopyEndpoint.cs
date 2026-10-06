using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Books;

public class UpdateBookCopyEndpoint : IEndpoint
{
    public record UpdateBookCopyRequest(string ViTri, string TinhTrang);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("api/books/copies/{macs}", async (IDbConnection db, string macs, [FromBody] UpdateBookCopyRequest req) =>
        {
            try
            {
                await db.ExecuteAsync(
                    "UPDATE CUONSACH SET VITRI = @ViTri, TINHTRANG = @TinhTrang WHERE MACS = @MaCS",
                    new { MaCS = macs, ViTri = req.ViTri, TinhTrang = req.TinhTrang }
                );
                return Results.Ok(new MessageResponse("Cập nhật cuốn sách thành công"));
            }
            catch (Exception ex)
            {
                return Results.BadRequest(new MessageResponse(ex.Message));
            }
        })
        .WithName("UpdateBookCopy")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Books");
    }
}
