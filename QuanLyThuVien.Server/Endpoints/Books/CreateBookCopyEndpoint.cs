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
            new DbValidator()
                .Required("MaDS", id, DbRules.MaDs)
                .Required("MaCS", req.MaCS, DbRules.MaCs)
                .MaxLength("ViTri", req.ViTri, DbRules.ViTri)
                .MaxLength("TinhTrang", req.TinhTrang, DbRules.TinhTrang)
                .ThrowIfInvalid();

            var parameters = new DynamicParameters();
            parameters.Add("@MACS", req.MaCS);
            parameters.Add("@MADS", id);
            parameters.Add("@VITRI", req.ViTri);
            parameters.Add("@TINHTRANG", req.TinhTrang ?? "Có sẵn");
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_THEMCUONSACH", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => ApiProblem.BadRequest("Mã cuốn sách đã tồn tại."),
                1 => ApiProblem.BadRequest("Mã đầu sách không tồn tại."),
                3 => Results.Ok(new MessageResponse("Thêm cuốn sách thành công")),
                _ => ApiProblem.Unexpected("SP_THEMCUONSACH", result)
            };
        })
        .WithName("CreateBookCopy")
        .RequireAuthorization()
        .WithTags("Books");
    }
}
