using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using QuanLyThuVien.Server.Shared;
using System.Data;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;

namespace QuanLyThuVien.Server.Endpoints.Reports;

public class RunRankingCursorEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("/api/reports/ranking", HandleAsync)
           .RequireAuthorization("QuanLyHoacThuThu")
           .WithTags("Reports")
           .WithSummary("Chạy cursor xếp loại độc giả")
           .WithDescription("Gọi SP_CURSOR_XEPLOAIDOCGIA và trả về danh sách xếp loại.");
    }

    private static async Task<IResult> HandleAsync(IDbConnection db)
    {
        var result = await db.QueryAsync<RankingResult>(
            "SP_CURSOR_XEPLOAIDOCGIA",
            commandType: CommandType.StoredProcedure);

        return Results.Ok(result);
    }
}

public class RankingResult
{
    public string MADG { get; set; } = null!;
    public string HOTEN { get; set; } = null!;
    public int SOLUOTMUON { get; set; }
    public int SOLANTRE { get; set; }
    public int SOLANHUMAT { get; set; }
    public decimal TONGTIENPHAT { get; set; }
    public string XEPLOAI { get; set; } = null!;
}
