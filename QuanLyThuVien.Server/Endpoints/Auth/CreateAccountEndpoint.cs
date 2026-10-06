using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using QuanLyThuVien.Server.Shared;
using System.Data;
using System.Threading.Tasks;

namespace QuanLyThuVien.Server.Endpoints.Auth;

public class CreateAccountEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("/api/auth/create-account", HandleAsync)
           .RequireAuthorization("QuanLyOnly")
           .WithTags("Auth")
           .WithSummary("Tạo tài khoản")
           .WithDescription("Gọi SP_TAOTAIKHOAN. Chỉ quản lý mới có quyền tạo.");
    }

    private static async Task<IResult> HandleAsync(
        CreateAccountRequest req,
        IDbConnection db)
    {
        var parameters = new DynamicParameters();
        parameters.Add("@TENDANGNHAP", req.Username);
        parameters.Add("@MATKHAU", req.Password);
        parameters.Add("@VAITRO", req.Role);
        parameters.Add("@MANV", string.IsNullOrEmpty(req.MaNV) ? null : req.MaNV);
        parameters.Add("@MADG", string.IsNullOrEmpty(req.MaDG) ? null : req.MaDG);
        parameters.Add("@return_value", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

        await db.ExecuteAsync("SP_TAOTAIKHOAN", parameters, commandType: CommandType.StoredProcedure);

        var result = parameters.Get<int>("@return_value");

        if (result == 1)
        {
            return Results.Ok(new MessageResponse("Tạo tài khoản thành công"));
        }

        return Results.BadRequest(new MessageResponse("Tên đăng nhập đã tồn tại hoặc tạo thất bại"));
    }
}

public record CreateAccountRequest(string Username, string Password, string Role, string? MaNV, string? MaDG);
