using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
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
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_SUADAUSACH", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => Results.BadRequest(new MessageResponse("Mã đầu sách không tồn tại.")),
                1 => Results.Ok(new MessageResponse("Cập nhật đầu sách thành công")),
                _ => Results.StatusCode(500)
            };
        })
        .WithName("UpdateBook")
        .RequireAuthorization()
           .WithTags("Books")
        .WithSummary("Cập nhật đầu sách");
    }
}
