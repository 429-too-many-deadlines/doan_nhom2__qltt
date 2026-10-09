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
            var parameters = new DynamicParameters();
            parameters.Add("@MANXB", id);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_XOANHAXUATBAN", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => Results.NotFound(new MessageResponse("Không tìm thấy nhà xuất bản")),
                1 => Results.BadRequest(new MessageResponse("Không thể xoá NXB đã có đầu sách")),
                2 => Results.Ok(new MessageResponse("Xoá nhà xuất bản thành công")),
                _ => Results.StatusCode(500)
            };
        })
        .WithName("DeletePublisher")
        .RequireAuthorization()
        .WithTags("Publishers")
        .WithSummary("Xóa nhà xuất bản");
    }
}
