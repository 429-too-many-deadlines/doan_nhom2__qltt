using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace QuanLyThuVien.Server.Endpoints.Reports;

public class GetTopBorrowedBooksEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/reports/top-borrowed-books", async (System.Data.IDbConnection db) =>
        {
            var data = await db.QueryAsync("SELECT * FROM VW_BC_SACHMUONNHIEU ORDER BY HANG");
            return Results.Ok(data);
        })
        .WithName("GetTopBorrowedBooks")
        .RequireAuthorization()
           .WithTags("Reports")
        .WithGroupName("v1")
        .WithSummary("Xếp hạng đầu sách được mượn nhiều nhất");
    }
}
