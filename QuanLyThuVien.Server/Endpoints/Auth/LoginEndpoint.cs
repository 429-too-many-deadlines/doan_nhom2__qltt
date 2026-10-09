using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using QuanLyThuVien.Server.Shared;
using System;
using System.Data;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace QuanLyThuVien.Server.Endpoints.Auth;

public class LoginEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("/api/auth/login", HandleAsync)
           .WithTags("Auth")
           .AllowAnonymous()
           .WithSummary("Đăng nhập")
           .WithDescription("Gọi SP_DANGNHAP. Trả về JWT token nếu thành công.");
    }

    private static async Task<IResult> HandleAsync(
        LoginRequest req,
        IDbConnection db,
        IConfiguration config)
    {
        try
        {
            var parameters = new DynamicParameters();
            parameters.Add("@TENDANGNHAP", req.Username);
            parameters.Add("@MATKHAU", req.Password);
            parameters.Add("@KETQUA", dbType: DbType.Int32, direction: ParameterDirection.Output);

            var user = await db.QueryFirstOrDefaultAsync<UserResult>(
                "SP_DANGNHAP", parameters, commandType: CommandType.StoredProcedure);

            var ketQua = parameters.Get<int>("@KETQUA");

            if (ketQua == 0)
            {
                return Results.BadRequest(new MessageResponse("Sai tên đăng nhập hoặc mật khẩu"));
            }
            if (ketQua == 1)
            {
                return Results.BadRequest(new MessageResponse("Tài khoản đã bị khóa"));
            }
            if (ketQua == 2 && user != null)
            {
                // Generate JWT
                var tokenHandler = new JwtSecurityTokenHandler();
                var key = Encoding.UTF8.GetBytes(config["Jwt:Key"]!);

                var claims = new List<Claim>
                {
                    new Claim(ClaimTypes.Name, user.TENDANGNHAP),
                    new Claim(ClaimTypes.Role, "Admin"),
                    new Claim("FullName", user.HOTEN ?? "Admin")
                };

                var tokenDescriptor = new SecurityTokenDescriptor
                {
                    Subject = new ClaimsIdentity(claims),
                    Expires = DateTime.UtcNow.AddHours(24),
                    Issuer = config["Jwt:Issuer"],
                    Audience = config["Jwt:Audience"],
                    SigningCredentials = new SigningCredentials(
                        new SymmetricSecurityKey(key),
                        SecurityAlgorithms.HmacSha256Signature)
                };

                var token = tokenHandler.CreateToken(tokenDescriptor);
                var tokenString = tokenHandler.WriteToken(token);

                return Results.Ok(new
                {
                    token = tokenString,
                    user = new
                    {
                        username = user.TENDANGNHAP,
                        role = "Admin",
                        fullName = user.HOTEN
                    }
                });
            }

            return Results.BadRequest(new MessageResponse("Đăng nhập thất bại"));
        }
        catch (Exception ex)
        {
            return Results.BadRequest(new MessageResponse(ex.Message));
        }
    }
}

public record LoginRequest(string Username, string Password);

public class UserResult
{
    public string TENDANGNHAP { get; set; } = null!;
    public string? HOTEN { get; set; }
}
