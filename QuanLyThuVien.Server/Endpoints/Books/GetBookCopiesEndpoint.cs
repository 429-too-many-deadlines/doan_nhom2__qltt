using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Books;

public class GetBookCopiesEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/books/{id}/copies", async (IDbConnection db, string id) =>
        {
            var copies = await db.QueryAsync("SELECT MACS as MaCS, MADS as MaDS, NGAYNHAP as NgayNhap, VITRI as ViTri, TINHTRANG as TinhTrang FROM CUONSACH WHERE MADS = @Id", new { Id = id });
            return Results.Ok(copies);
        })
        .WithName("GetBookCopies")
        .RequireAuthorization()
        .WithTags("Books");
    }
}
