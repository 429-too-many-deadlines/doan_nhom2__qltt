using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using QuanLyThuVien.Server.Shared;
using System.Data;
using System.Threading.Tasks;

namespace QuanLyThuVien.Server.Endpoints.Transactions;

public class GetFineSlipsEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/transactions/fines", async (IDbConnection db) =>
        {
            var query = @"
                SELECT PP.MAPP, PP.MAPM, PM.MADG, DG.HOTEN AS TENDG, PP.MACS, PP.NGAYLAP, PP.LYDO, PP.SOTIEN, PP.DATHANHTOAN
                FROM PHIEUPHAT PP
                INNER JOIN CTPHIEUMUON CT ON PP.MAPM = CT.MAPM AND PP.MACS = CT.MACS
                INNER JOIN PHIEUMUON PM ON CT.MAPM = PM.MAPM
                LEFT JOIN DOCGIA DG ON PM.MADG = DG.MADG
                ORDER BY PP.NGAYLAP DESC, PP.MAPP DESC";
            
            var result = await db.QueryAsync(query);
            return Results.Ok(result);
        })
        .WithName("GetFineSlips")
        .RequireAuthorization()
        .WithTags("Transactions")
        .WithGroupName("v1")
        .WithSummary("Lấy danh sách phiếu phạt");
    }
}
