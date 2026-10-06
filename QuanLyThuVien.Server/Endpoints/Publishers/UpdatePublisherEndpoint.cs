using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Publishers;

public class UpdatePublisherEndpoint : IEndpoint
{
    public record UpdatePublisherRequest(string TenNXB, string? DiaChi, string? SoDT);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("api/publishers/{id}", async (IDbConnection db, string id, [FromBody] UpdatePublisherRequest req) =>
        {
            try
            {
                var sql = "UPDATE NHAXUATBAN SET TENNXB = @TenNXB, DIACHI = @DiaChi, SODT = @SoDT WHERE MANXB = @MaNXB";
                var result = await db.ExecuteAsync(sql, new { TenNXB = req.TenNXB, DiaChi = req.DiaChi, SoDT = req.SoDT, MaNXB = id });
                
                if (result == 0) return Results.NotFound(new MessageResponse("Không tìm thấy nhà xuất bản"));
                return Results.Ok(new MessageResponse("Cập nhật nhà xuất bản thành công"));
            }
            catch (System.Exception ex)
            {
                return Results.BadRequest(new MessageResponse(ex.Message));
            }
        })
        .WithName("UpdatePublisher")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Publishers")
        .WithSummary("Cập nhật nhà xuất bản");
    }
}
