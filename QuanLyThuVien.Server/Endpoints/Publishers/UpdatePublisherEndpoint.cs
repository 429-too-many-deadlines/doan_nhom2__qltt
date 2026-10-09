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
            var parameters = new DynamicParameters();
            parameters.Add("@MANXB", id);
            parameters.Add("@TENNXB", req.TenNXB);
            parameters.Add("@DIACHI", req.DiaChi);
            parameters.Add("@SODT", req.SoDT);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_SUANHAXUATBAN", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => Results.NotFound(new MessageResponse("Không tìm thấy nhà xuất bản")),
                1 => Results.BadRequest(new MessageResponse("Tên nhà xuất bản đã tồn tại.")),
                2 => Results.Ok(new MessageResponse("Cập nhật nhà xuất bản thành công")),
                _ => Results.StatusCode(500)
            };
        })
        .WithName("UpdatePublisher")
        .RequireAuthorization()
        .WithTags("Publishers")
        .WithSummary("Cập nhật nhà xuất bản");
    }
}
