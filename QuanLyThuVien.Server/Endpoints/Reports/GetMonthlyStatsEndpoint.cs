using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Reports;

public class GetMonthlyStatsEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/reports/monthly-stats", async (IDbConnection db, [FromQuery] int month, [FromQuery] int year) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@THANG", month);
            parameters.Add("@NAM", year);
            parameters.Add("@SOPHIEU", dbType: DbType.Int32, direction: ParameterDirection.Output);
            parameters.Add("@SOLUOTSACH", dbType: DbType.Int32, direction: ParameterDirection.Output);
            parameters.Add("@TIENPHAT", dbType: DbType.Decimal, direction: ParameterDirection.Output);

            var topBooks = await db.QueryAsync("SP_THONGKETHANG", parameters, commandType: CommandType.StoredProcedure);
            
            return Results.Ok(new MonthlyStatsResponse(
                parameters.Get<int>("@SOPHIEU"),
                parameters.Get<int>("@SOLUOTSACH"),
                parameters.Get<decimal?>("@TIENPHAT") ?? 0,
                topBooks
            ));
        })
        .WithName("GetMonthlyStats")
        .RequireAuthorization("QuanLyOnly")
        .WithTags("Reports")
        .WithGroupName("v1")
        .WithSummary("Thống kê hoạt động thư viện theo tháng");
    }

    public record MonthlyStatsResponse(int SoPhieu, int SoLuotSach, decimal TienPhat, IEnumerable<dynamic> Top5Books);
}
