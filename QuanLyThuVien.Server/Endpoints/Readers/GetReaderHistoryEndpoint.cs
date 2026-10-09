using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace QuanLyThuVien.Server.Endpoints.Readers;

public class GetReaderHistoryEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/readers/{maDg}/history", async (System.Data.IDbConnection db, string maDg) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@MADG", maDg);

            var history = await db.QueryAsync("SELECT * FROM dbo.FN_LICHSUMUON(@MADG) ORDER BY NGAYMUON", parameters);
            return Results.Ok(history);
        })
        .WithName("GetReaderHistory")
        .RequireAuthorization()
           .WithTags("Readers")
        .WithGroupName("v1")
        .WithSummary("Xem lịch sử mượn sách của độc giả");
    }
}
