using Dapper;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Books;

public class CreateBookEndpoint : IEndpoint
{
    public record CreateBookRequest(string MaDS, string TenDS, string MaTL, string MaNXB, int NamXB, int SoTrang, decimal Gia);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("api/books", async (IDbConnection db, [FromBody] CreateBookRequest req) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@MADS", req.MaDS);
            parameters.Add("@TENDS", req.TenDS);
            parameters.Add("@MATL", req.MaTL);
            parameters.Add("@MANXB", req.MaNXB);
            parameters.Add("@NAMXB", req.NamXB);
            parameters.Add("@SOTRANG", req.SoTrang);
            parameters.Add("@GIA", req.Gia);

            var result = await db.ExecuteAsync("SP_THEMDAUSACH", parameters, commandType: CommandType.StoredProcedure);
            return Results.Ok(new { message = "Thêm đầu sách thành công" });
        })
        .WithName("CreateBook")
        .WithTags("Books")
        .WithSummary("Thêm mới đầu sách");
    }
}
