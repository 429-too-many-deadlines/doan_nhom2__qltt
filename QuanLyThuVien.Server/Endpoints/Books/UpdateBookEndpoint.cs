using Dapper;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Books;

public class UpdateBookEndpoint : IEndpoint
{
    public record UpdateBookRequest(string TenDS, string MaTL, string MaNXB, int NamXB, int SoTrang, decimal Gia);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("api/books/{id}", async (IDbConnection db, string id, [FromBody] UpdateBookRequest req) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@MADS", id);
            parameters.Add("@TENDS", req.TenDS);
            parameters.Add("@MATL", req.MaTL);
            parameters.Add("@MANXB", req.MaNXB);
            parameters.Add("@NAMXB", req.NamXB);
            parameters.Add("@SOTRANG", req.SoTrang);
            parameters.Add("@GIA", req.Gia);

            var result = await db.ExecuteAsync("SP_SUADAUSACH", parameters, commandType: CommandType.StoredProcedure);
            return Results.Ok(new { message = "Cập nhật đầu sách thành công" });
        })
        .WithName("UpdateBook")
        .WithTags("Books")
        .WithSummary("Cập nhật đầu sách");
    }
}
