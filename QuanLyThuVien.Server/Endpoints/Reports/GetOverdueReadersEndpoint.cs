using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace QuanLyThuVien.Server.Endpoints.Reports;

public class GetOverdueReadersEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/reports/overdue-readers", async (System.Data.IDbConnection db) =>
        {
            var data = await db.QueryAsync("SELECT * FROM VW_BC_DOCGIA_QUAHAN ORDER BY STT");
            return Results.Ok(data);
        })
        .WithName("GetOverdueReaders")
        .RequireAuthorization("QuanLyOnly")
           .WithTags("Reports")
        .WithGroupName("v1")
        .WithSummary("Danh sách độc giả đang giữ sách quá hạn");
    }
}
