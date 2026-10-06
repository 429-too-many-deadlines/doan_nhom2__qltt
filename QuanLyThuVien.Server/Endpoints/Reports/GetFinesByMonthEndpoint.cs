using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace QuanLyThuVien.Server.Endpoints.Reports;

public class GetFinesByMonthEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/reports/fines-by-month", async (System.Data.IDbConnection db) =>
        {
            var data = await db.QueryAsync("SELECT * FROM VW_BC_TIENPHAT_THANG ORDER BY NAM, THANG, LYDO");
            return Results.Ok(data);
        })
        .WithName("GetFinesByMonth")
        .RequireAuthorization("QuanLyOnly")
           .WithTags("Reports")
        .WithGroupName("v1")
        .WithSummary("Tiền phạt theo tháng và lý do");
    }
}
