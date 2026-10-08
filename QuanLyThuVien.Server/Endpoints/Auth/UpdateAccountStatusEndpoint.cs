using Dapper;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Auth;

public class UpdateAccountStatusEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("/api/auth/accounts/{username}/status", HandleAsync)
           .RequireAuthorization("QuanLyOnly")
           .WithTags("Auth")
           .WithSummary("Cập nhật trạng thái khóa/mở tài khoản")
           .WithDescription("Thay đổi cột TRANGTHAI (1/0) của bảng TAIKHOAN.");
    }

    private static async Task<IResult> HandleAsync(
        string username,
        [FromBody] UpdateAccountStatusRequest req,
        IDbConnection db)
    {
        const string checkSql = "SELECT COUNT(*) FROM TAIKHOAN WHERE TENDANGNHAP = @Username";
        var count = await db.ExecuteScalarAsync<int>(checkSql, new { Username = username });
        if (count == 0)
        {
            return Results.NotFound(new MessageResponse("Tài khoản không tồn tại."));
        }

        const string updateSql = "UPDATE TAIKHOAN SET TRANGTHAI = @Status WHERE TENDANGNHAP = @Username";
        await db.ExecuteAsync(updateSql, new { Status = req.Status ? 1 : 0, Username = username });

        string msg = req.Status ? "Mở khóa tài khoản thành công." : "Khóa tài khoản thành công.";
        return Results.Ok(new MessageResponse(msg));
    }

    public record UpdateAccountStatusRequest(bool Status);
}
