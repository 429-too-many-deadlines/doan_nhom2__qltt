using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Books;

public class CreateBookCopyEndpoint : IEndpoint
{
    public record CreateBookCopyRequest(string MaCS, string ViTri, string TinhTrang);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("api/books/{id}/copies", async (IDbConnection db, string id, [FromBody] CreateBookCopyRequest req) =>
        {
            try
            {
                await db.ExecuteAsync(
                    "INSERT INTO CUONSACH (MACS, MADS, NGAYNHAP, VITRI, TINHTRANG) VALUES (@MaCS, @MaDS, GETDATE(), @ViTri, @TinhTrang)",
                    new { MaCS = req.MaCS, MaDS = id, ViTri = req.ViTri, TinhTrang = req.TinhTrang ?? "Có sẵn" }
                );
                return Results.Ok(new MessageResponse("Thêm cuốn sách thành công"));
            }
            catch (Exception ex)
            {
                return Results.BadRequest(new MessageResponse(ex.Message));
            }
        })
        .WithName("CreateBookCopy")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Books");
    }
}
