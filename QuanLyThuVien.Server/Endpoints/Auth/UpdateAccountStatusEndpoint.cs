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
           .RequireAuthorization()
           .WithTags("Auth")
           .WithSummary("Cập nhật trạng thái khóa/mở tài khoản")
           .WithDescription("Thay đổi cột TRANGTHAI (1/0) của bảng TAIKHOAN.");
    }

    private static async Task<IResult> HandleAsync(
        string username,
        [FromBody] UpdateAccountStatusRequest req,
        IDbConnection db)
    {
        var parameters = new DynamicParameters();
        parameters.Add("@TENDANGNHAP", username);
        parameters.Add("@TRANGTHAI", req.Status);
        parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

        await db.ExecuteAsync("SP_CAPNHATTRANGTHAITAIKHOAN", parameters, commandType: CommandType.StoredProcedure);
        var result = parameters.Get<int>("@ReturnValue");

        if (result == 0)
        {
            return Results.NotFound(new MessageResponse("Tài khoản không tồn tại."));
        }

        string msg = req.Status ? "Mở khóa tài khoản thành công." : "Khóa tài khoản thành công.";
        return Results.Ok(new MessageResponse(msg));
    }

    public record UpdateAccountStatusRequest(bool Status);
}
