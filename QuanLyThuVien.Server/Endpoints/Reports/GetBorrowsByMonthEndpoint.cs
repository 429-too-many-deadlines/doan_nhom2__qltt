using Dapper;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace QuanLyThuVien.Server.Endpoints.Reports;

public class GetBorrowsByMonthEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/reports/borrows-by-month", async (System.Data.IDbConnection db) =>
        {
            var data = await db.QueryAsync("SELECT * FROM VW_BC_LUOTMUON_THANG ORDER BY NAM, THANG, TENTL");
            return Results.Ok(data);
        })
        .WithName("GetBorrowsByMonth")
        .WithTags("Reports")
        .WithGroupName("v1")
        .WithSummary("Lượt mượn theo tháng và thể loại");
    }
}
