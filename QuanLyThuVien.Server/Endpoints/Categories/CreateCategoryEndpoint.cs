using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Categories;

public class CreateCategoryEndpoint : IEndpoint
{
    public record CreateCategoryReq(string MaTL, string TenTL);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("api/categories", async (IDbConnection db, [FromBody] CreateCategoryReq req) =>
        {
            try
            {
                var sql = "INSERT INTO THELOAI(MATL, TENTL) VALUES (@MaTL, @TenTL)";
                await db.ExecuteAsync(sql, req);
                return Results.Ok(new MessageResponse("Thêm thể loại thành công"));
            }
            catch (Microsoft.Data.SqlClient.SqlException ex)
            {
                return Results.BadRequest(new MessageResponse("Lỗi dữ liệu: " + ex.Message));
            }
        })
        .WithName("CreateCategory")
        .RequireAuthorization("QuanLyHoacThuThu")
           .WithTags("Categories");
    }
}
