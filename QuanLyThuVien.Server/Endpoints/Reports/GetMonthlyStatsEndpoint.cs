using Dapper;
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
            
            return Results.Ok(new
            {
                SoPhieu = parameters.Get<int>("@SOPHIEU"),
                SoLuotSach = parameters.Get<int>("@SOLUOTSACH"),
                TienPhat = parameters.Get<decimal?>("@TIENPHAT") ?? 0,
                Top5Books = topBooks
            });
        })
        .WithName("GetMonthlyStats")
        .WithTags("Reports")
        .WithGroupName("v1")
        .WithSummary("Thống kê hoạt động thư viện theo tháng");
    }
}
