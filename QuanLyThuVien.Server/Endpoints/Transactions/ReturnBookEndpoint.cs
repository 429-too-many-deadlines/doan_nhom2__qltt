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
            var parameters = new DynamicParameters();
            parameters.Add("@MAPM", req.MaPm);
            parameters.Add("@MACS", req.MaCs);
            parameters.Add("@TINHTRANGTRA", req.TinhTrangTra ?? "Bình thường");
            parameters.Add("@TIENPHAT", dbType: DbType.Decimal, direction: ParameterDirection.Output);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_TRASACH", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => Results.NotFound(new MessageResponse("Không tìm thấy sách trong phiếu mượn.")),
                1 => Results.BadRequest(new MessageResponse("Sách này đã được trả trước đó.")),
                2 => Results.Ok(new 
                { 
                    Message = "Trả sách thành công.", 
                    TienPhat = parameters.Get<decimal>("@TIENPHAT") 
                }),
                _ => Results.StatusCode(500)
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
