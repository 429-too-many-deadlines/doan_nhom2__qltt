using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using QuanLyThuVien.Server.Shared;
using System.Data;
using System.Security.Claims;
using System.Threading.Tasks;

namespace QuanLyThuVien.Server.Endpoints.Auth;

public class ChangePasswordEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("/api/auth/change-password", HandleAsync)
           .WithTags("Auth")
           .RequireAuthorization()
           .WithSummary("Đổi mật khẩu")
           .WithDescription("Gọi SP_DOIMATKHAU. Trả về thành công hoặc thất bại.");
    }

    private static async Task<IResult> HandleAsync(
        ChangePasswordRequest req,
        HttpContext context,
        IDbConnection db)
    {
        var username = context.User.Identity?.Name;
        if (string.IsNullOrEmpty(username))
        {
            return Results.Unauthorized();
        }

        var parameters = new DynamicParameters();
        parameters.Add("@TENDANGNHAP", username);
        parameters.Add("@MATKHAUCU", req.OldPassword);
        parameters.Add("@MATKHAUMOI", req.NewPassword);
        parameters.Add("@return_value", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

        await db.ExecuteAsync("SP_DOIMATKHAU", parameters, commandType: CommandType.StoredProcedure);

        var result = parameters.Get<int>("@return_value");

        if (result == 1)
        {
            return Results.Ok(new MessageResponse("Đổi mật khẩu thành công"));
        }

        return Results.BadRequest(new MessageResponse("Sai mật khẩu cũ"));
    }
}

public record ChangePasswordRequest(string OldPassword, string NewPassword);
