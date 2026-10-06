using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Publishers;

public class CreatePublisherEndpoint : IEndpoint
{
    public record CreatePublisherRequest(string MaNXB, string TenNXB, string? DiaChi, string? SoDT);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("api/publishers", async (IDbConnection db, [FromBody] CreatePublisherRequest req) =>
        {
            try
            {
                var sql = "INSERT INTO NHAXUATBAN(MANXB, TENNXB, DIACHI, SODT) VALUES(@MaNXB, @TenNXB, @DiaChi, @SoDT)";
                await db.ExecuteAsync(sql, req);
                return Results.Ok(new MessageResponse("Thêm nhà xuất bản thành công"));
            }
            catch (System.Exception ex)
            {
                return Results.BadRequest(new MessageResponse(ex.Message));
            }
        })
        .WithName("CreatePublisher")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Publishers")
        .WithSummary("Thêm nhà xuất bản");
    }
}
