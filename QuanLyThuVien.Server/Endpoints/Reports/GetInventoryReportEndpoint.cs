using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace QuanLyThuVien.Server.Endpoints.Reports;

public class GetInventoryReportEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/reports/inventory", async (System.Data.IDbConnection db) =>
        {
            var data = await db.QueryAsync("SELECT * FROM VW_BC_TINHTRANGKHO ORDER BY STT");
            return Results.Ok(data);
        })
        .WithName("GetInventoryReport")
        .RequireAuthorization("QuanLyOnly")
           .WithTags("Reports")
        .WithGroupName("v1")
        .WithSummary("Tình trạng kho sách theo đầu sách");
    }
}
