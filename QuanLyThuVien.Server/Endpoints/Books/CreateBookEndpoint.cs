using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
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
            new DbValidator()
                .Required("MaDS", req.MaDS, DbRules.MaDs)
                .Required("TenDS", req.TenDS, DbRules.TenDs)
                .Required("MaTL", req.MaTL, DbRules.MaTl)
                .Required("MaNXB", req.MaNXB, DbRules.MaNxb)
                .ThrowIfInvalid();

            var parameters = new DynamicParameters();
            parameters.Add("@MADS", req.MaDS);
            parameters.Add("@TENDS", req.TenDS);
            parameters.Add("@MATL", req.MaTL);
            parameters.Add("@MANXB", req.MaNXB);
            parameters.Add("@NAMXB", req.NamXB);
            parameters.Add("@SOTRANG", req.SoTrang);
            parameters.Add("@GIA", req.Gia);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_THEMDAUSACH", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => ApiProblem.BadRequest("Mã đầu sách đã tồn tại."),
                1 => ApiProblem.BadRequest("Mã thể loại không tồn tại."),
                2 => ApiProblem.BadRequest("Mã nhà xuất bản không tồn tại."),
                3 => Results.Ok(new MessageResponse("Thêm đầu sách thành công")),
                _ => ApiProblem.Unexpected("SP_THEMDAUSACH", result)
            };
        })
        .WithName("CreateBook")
        .RequireAuthorization()
           .WithTags("Books")
        .WithSummary("Thêm mới đầu sách");
    }
}
