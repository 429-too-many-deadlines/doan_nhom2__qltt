using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
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
            var dsMaCs = (req.DsMaCs ?? []).Select(m => m?.Trim()).Where(m => !string.IsNullOrEmpty(m)).ToArray();
            if (dsMaCs.Length == 0)
                return ApiProblem.BadRequest("Phiếu mượn phải có ít nhất một cuốn sách.");

            var validator = new DbValidator().Required("MaDG", req.MaDg, DbRules.MaDg);
            foreach (var maCs in dsMaCs)
                validator.MaxLength("MaCS", maCs, DbRules.MaCs);
            validator.MaxLength("DsMaCS", string.Join(",", dsMaCs), DbRules.DsMaCs).ThrowIfInvalid();

            var parameters = new DynamicParameters();
            parameters.Add("@MADG", req.MaDg);
            parameters.Add("@DSMACS", string.Join(",", dsMaCs));
            parameters.Add("@MAPM", dbType: DbType.String, size: 6, direction: ParameterDirection.Output);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            // Lỗi từ trigger / ràng buộc (sách đang được mượn, mã không tồn tại...) do GlobalExceptionHandler trả về 400
            await db.ExecuteAsync("SP_LAPPHIEUMUON", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            if (result == 1)
            {
                var mapm = parameters.Get<string>("@MAPM");
                return Results.Ok(new BorrowResponse($"Lập phiếu mượn {mapm} thành công.", mapm));
            }

            // SP trả 0 khi độc giả không tồn tại (danh sách sách rỗng đã được chặn ở trên)
            return ApiProblem.NotFound("Độc giả không tồn tại.");
        })
        .WithName("BorrowBooks")
        .RequireAuthorization()
           .WithTags("Transactions")
        .WithGroupName("v1")
        .WithSummary("Lập phiếu mượn sách");
    }
}

public record BorrowRequest(string MaDg, string[] DsMaCs);
public record BorrowResponse(string Message, string MaPm);
