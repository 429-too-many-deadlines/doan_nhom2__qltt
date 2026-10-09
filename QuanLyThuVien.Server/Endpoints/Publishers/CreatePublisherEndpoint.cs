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
            var parameters = new DynamicParameters();
            parameters.Add("@MANXB", req.MaNXB);
            parameters.Add("@TENNXB", req.TenNXB);
            parameters.Add("@DIACHI", req.DiaChi);
            parameters.Add("@SODT", req.SoDT);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_THEMNHAXUATBAN", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => Results.BadRequest(new MessageResponse("Mã nhà xuất bản đã tồn tại.")),
                1 => Results.BadRequest(new MessageResponse("Tên nhà xuất bản đã tồn tại.")),
                2 => Results.Ok(new MessageResponse("Thêm nhà xuất bản thành công")),
                _ => Results.StatusCode(500)
            };
        })
        .WithName("CreatePublisher")
        .RequireAuthorization()
        .WithTags("Publishers")
        .WithSummary("Thêm nhà xuất bản");
    }
}
