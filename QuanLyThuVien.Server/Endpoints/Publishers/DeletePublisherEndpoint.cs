using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Publishers;

public class DeletePublisherEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapDelete("api/publishers/{id}", async (IDbConnection db, string id) =>
        {
            var count = await db.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM DAUSACH WHERE MANXB = @MaNXB", new { MaNXB = id });
            if (count > 0)
            {
                return Results.BadRequest(new MessageResponse("Không thể xoá NXB đã có đầu sách"));
            }

            var sql = "DELETE FROM NHAXUATBAN WHERE MANXB = @MaNXB";
            var result = await db.ExecuteAsync(sql, new { MaNXB = id });
            
            if (result == 0) return Results.NotFound(new MessageResponse("Không tìm thấy nhà xuất bản"));
            return Results.Ok(new MessageResponse("Xoá nhà xuất bản thành công"));
        })
        .WithName("DeletePublisher")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Publishers")
        .WithSummary("Xóa nhà xuất bản");
    }
}
