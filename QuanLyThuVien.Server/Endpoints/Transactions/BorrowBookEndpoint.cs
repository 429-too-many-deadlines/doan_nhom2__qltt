using Dapper;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Transactions;

public class BorrowBookEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("api/transactions/borrow", async (IDbConnection db, [FromBody] BorrowRequest req) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@MADG", req.MaDg);
            parameters.Add("@MANV", req.MaNv);
            parameters.Add("@DSMACS", string.Join(",", req.DsMaCs));
            parameters.Add("@MAPM", dbType: DbType.String, size: 6, direction: ParameterDirection.Output);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            try
            {
                await db.ExecuteAsync("SP_LAPPHIEUMUON", parameters, commandType: CommandType.StoredProcedure);
                var result = parameters.Get<int>("@ReturnValue");

                if (result == 1)
                {
                    var mapm = parameters.Get<string>("@MAPM");
                    return Results.Ok(new { Message = $"Lập phiếu mượn {mapm} thành công.", MaPm = mapm });
                }
                
                return Results.BadRequest(new { Message = "Lập phiếu mượn thất bại." });
            }
            catch (Exception ex)
            {
                return Results.BadRequest(new { Message = ex.Message });
            }
        })
        .WithName("BorrowBooks")
        .WithTags("Transactions")
        .WithGroupName("v1")
        .WithSummary("Lập phiếu mượn sách");
    }
}

public record BorrowRequest(string MaDg, string MaNv, string[] DsMaCs);
