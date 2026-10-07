using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using QuanLyThuVien.Server.Shared;
using System.Data;
using System.Threading.Tasks;

namespace QuanLyThuVien.Server.Endpoints.Transactions;

public class GetBorrowSlipsEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/transactions/borrows", async (IDbConnection db, int page = 1, int pageSize = 10) =>
        {
            var offset = (page - 1) * pageSize;
            var queryCount = @"
                SELECT COUNT(*)
                FROM PHIEUMUON PM
                LEFT JOIN CTPHIEUMUON CT ON PM.MAPM = CT.MAPM";

            var totalCount = await db.ExecuteScalarAsync<int>(queryCount);

            var query = @"
                SELECT PM.MAPM, PM.MADG, DG.HOTEN AS TENDG, PM.MANV, PM.NGAYMUON, PM.HANTRA, PM.TINHTRANG,
                       CT.MACS, CT.NGAYTRA, CT.TINHTRANGTRA
                FROM PHIEUMUON PM
                LEFT JOIN DOCGIA DG ON PM.MADG = DG.MADG
                LEFT JOIN CTPHIEUMUON CT ON PM.MAPM = CT.MAPM
                ORDER BY PM.NGAYMUON DESC, PM.MAPM DESC
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
        .WithName("GetBorrowSlips")
        .RequireAuthorization()
        .WithTags("Transactions")
        .WithGroupName("v1")
        .WithSummary("Lấy danh sách phiếu mượn");
    }
}
