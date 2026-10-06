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
        app.MapGet("api/transactions/fines", async (IDbConnection db, int page = 1, int pageSize = 10) =>
        {
            var offset = (page - 1) * pageSize;
            var queryCount = "SELECT COUNT(*) FROM PHIEUPHAT";
            var totalCount = await db.ExecuteScalarAsync<int>(queryCount);

            var query = @"
                SELECT PP.MAPP, PP.MAPM, PM.MADG, DG.HOTEN AS TENDG, PP.MACS, PP.NGAYLAP, PP.LYDO, PP.SOTIEN, PP.DATHANHTOAN
                FROM PHIEUPHAT PP
                INNER JOIN CTPHIEUMUON CT ON PP.MAPM = CT.MAPM AND PP.MACS = CT.MACS
                INNER JOIN PHIEUMUON PM ON CT.MAPM = PM.MAPM
                LEFT JOIN DOCGIA DG ON PM.MADG = DG.MADG
                ORDER BY PP.NGAYLAP DESC, PP.MAPP DESC
                OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";
            
            var items = await db.QueryAsync<dynamic>(query, new { Offset = offset, PageSize = pageSize });
            
            return Results.Ok(new PagedResult<dynamic>
            {
                Items = items,
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            });
        })
        .WithName("GetFineSlips")
        .RequireAuthorization()
        .WithTags("Transactions")
        .WithGroupName("v1")
        .WithSummary("Lấy danh sách phiếu phạt");
    }
}
