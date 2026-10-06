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
        app.MapGet("api/transactions/borrows", async (IDbConnection db) =>
        {
            var query = @"
                SELECT PM.MAPM, PM.MADG, DG.HOTEN AS TENDG, PM.MANV, PM.NGAYMUON, PM.HANTRA, PM.TINHTRANG,
                       CT.MACS, CT.NGAYTRA, CT.TINHTRANGTRA
                FROM PHIEUMUON PM
                LEFT JOIN DOCGIA DG ON PM.MADG = DG.MADG
                LEFT JOIN CTPHIEUMUON CT ON PM.MAPM = CT.MAPM
                ORDER BY PM.NGAYMUON DESC, PM.MAPM DESC";
            
            var result = await db.QueryAsync<BorrowSlip>(query);
            return Results.Ok(result);
        })
        .WithName("GetBorrowSlips")
        .RequireAuthorization()
        .WithTags("Transactions")
        .WithGroupName("v1")
        .WithSummary("Lấy danh sách phiếu mượn");
    }
}

public record BorrowSlip(
    string MAPM, 
    string MADG, 
    string TENDG, 
    string MANV, 
    System.DateTime NGAYMUON, 
    System.DateTime HANTRA, 
    string TINHTRANG, 
    string MACS, 
    System.DateTime? NGAYTRA, 
    string TINHTRANGTRA
);
