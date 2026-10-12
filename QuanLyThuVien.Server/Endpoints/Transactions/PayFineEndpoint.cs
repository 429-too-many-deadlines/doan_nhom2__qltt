using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Transactions;

public class PayFineEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("api/transactions/pay-fine", async (IDbConnection db, [FromBody] PayFineRequest req) =>
        {
            new DbValidator()
                .Required("MaDG", req.MaDg, DbRules.MaDg)
                .ThrowIfInvalid();

            var parameters = new DynamicParameters();
            parameters.Add("@MADG", req.MaDg);
            parameters.Add("@SOTIEN", dbType: DbType.Decimal, direction: ParameterDirection.Output, precision: 19, scale: 4);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_THANHTOANPHAT", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => ApiProblem.NotFound("Độc giả không tồn tại."),
                1 => Results.Ok(new MessageResponse("Độc giả không có khoản phạt nào chưa thanh toán.")),
                2 => Results.Ok(new 
                { 
                    Message = "Thanh toán thành công.", 
                    SoTien = parameters.Get<decimal>("@SOTIEN") 
                }),
                _ => ApiProblem.Unexpected("SP_THANHTOANPHAT", result)
            };
        })
        .WithName("PayFine")
        .RequireAuthorization()
           .WithTags("Transactions")
        .WithGroupName("v1")
        .WithSummary("Thanh toán tiền phạt");
    }
}

public record PayFineRequest(string MaDg);
