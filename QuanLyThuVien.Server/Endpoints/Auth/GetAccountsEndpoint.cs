using Dapper;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Auth;

public class GetAccountsEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("/api/auth/accounts", HandleAsync)
           .RequireAuthorization("QuanLyOnly")
           .WithTags("Auth")
           .WithSummary("Lấy danh sách tài khoản")
           .WithDescription("Lấy toàn bộ tài khoản kèm tên nhân viên hoặc độc giả sở hữu.");
    }

    private static async Task<IResult> HandleAsync(IDbConnection db)
    {
        const string sql = @"
            SELECT 
                tk.TENDANGNHAP AS Username,
                tk.VAITRO AS Role,
                tk.MANV AS MaNV,
                tk.MADG AS MaDG,
                COALESCE(nv.HOTEN, dg.HOTEN, N'Chưa liên kết') AS OwnerName,
                tk.TRANGTHAI AS Status
            FROM TAIKHOAN tk
            LEFT JOIN NHANVIEN nv ON tk.MANV = nv.MANV
            LEFT JOIN DOCGIA dg ON tk.MADG = dg.MADG
            ORDER BY tk.TENDANGNHAP";

        var accounts = await db.QueryAsync<AccountResponse>(sql);
        return Results.Ok(accounts);
    }

    public record AccountResponse(string Username, string Role, string? MaNV, string? MaDG, string OwnerName, bool Status);
}
