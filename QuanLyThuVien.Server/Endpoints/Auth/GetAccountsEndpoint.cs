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
           .RequireAuthorization()
           .WithTags("Auth")
           .WithSummary("Lấy danh sách tài khoản")
           .WithDescription("Lấy toàn bộ tài khoản kèm tên nhân viên hoặc độc giả sở hữu.");
    }

    private static async Task<IResult> HandleAsync(IDbConnection db)
    {
        var accounts = await db.QueryAsync<AccountResponse>(
            "SP_LAYDANHSACHTAIKHOAN",
            commandType: CommandType.StoredProcedure
        );
        return Results.Ok(accounts);
    }

    public record AccountResponse(string Username, string Role, string? MaNV, string? MaDG, string OwnerName, bool Status);
}
