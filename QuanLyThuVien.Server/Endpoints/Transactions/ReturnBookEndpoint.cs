using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Transactions;

public class ReturnBookEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("api/transactions/return", async (IDbConnection db, [FromBody] ReturnRequest req) =>
        {
            new DbValidator()
                .Required("MaPM", req.MaPm, DbRules.MaPm)
                .Required("MaCS", req.MaCs, DbRules.MaCs)
                .ThrowIfInvalid();

            var parameters = new DynamicParameters();
            parameters.Add("@MAPM", req.MaPm);
            parameters.Add("@MACS", req.MaCs);
            parameters.Add("@TINHTRANGTRA", req.TinhTrangTra ?? "Bình thường");
            parameters.Add("@TIENPHAT", dbType: DbType.Decimal, direction: ParameterDirection.Output, precision: 19, scale: 4);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_TRASACH", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => ApiProblem.NotFound("Không tìm thấy sách trong phiếu mượn."),
                1 => ApiProblem.BadRequest("Sách này đã được trả trước đó."),
                2 => Results.Ok(new 
                { 
                    Message = "Trả sách thành công.", 
                    TienPhat = parameters.Get<decimal>("@TIENPHAT") 
                }),
                _ => ApiProblem.Unexpected("SP_TRASACH", result)
            };
        })
        .WithName("ReturnBook")
        .RequireAuthorization()
           .WithTags("Transactions")
        .WithGroupName("v1")
        .WithSummary("Trả sách");
    }
}

public record ReturnRequest(string MaPm, string MaCs, string? TinhTrangTra);
