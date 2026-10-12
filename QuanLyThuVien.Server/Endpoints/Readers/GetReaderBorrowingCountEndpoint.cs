using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Readers;

public class GetReaderBorrowingCountEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/readers/{maDg}/borrowing-count", async (IDbConnection db, string maDg) =>
        {
            new DbValidator()
                .Required("MaDG", maDg, DbRules.MaDg)
                .ThrowIfInvalid();

            // FN_SOSACHDANGMUON trả về -1 khi độc giả không tồn tại
            var soSach = await db.ExecuteScalarAsync<int>(
                "SELECT dbo.FN_SOSACHDANGMUON(@MADG)", new { MADG = maDg });

            if (soSach < 0)
                return ApiProblem.NotFound("Mã độc giả không tồn tại.");

            return Results.Ok(new ReaderBorrowingCountResponse(maDg, soSach));
        })
        .WithName("GetReaderBorrowingCount")
        .RequireAuthorization()
        .WithTags("Readers")
        .WithGroupName("v1")
        .WithSummary("Số sách độc giả đang mượn (chưa trả)")
        .WithDescription("Gọi FN_SOSACHDANGMUON.");
    }
}

public record ReaderBorrowingCountResponse(string MaDg, int SoSachDangMuon);
