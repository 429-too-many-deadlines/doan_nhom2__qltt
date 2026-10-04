using Dapper;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace QuanLyThuVien.Server.Endpoints.Reports;

public class GetLibrarianPerformanceEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/reports/librarian-performance", async (System.Data.IDbConnection db) =>
        {
            var data = await db.QueryAsync("SELECT * FROM VW_BC_HIEUSUAT_NHANVIEN ORDER BY NAM, THANG, MANV");
            return Results.Ok(data);
        })
        .WithName("GetLibrarianPerformance")
        .WithTags("Reports")
        .WithGroupName("v1")
        .WithSummary("Hiệu suất nhân viên theo tháng");
    }
}
