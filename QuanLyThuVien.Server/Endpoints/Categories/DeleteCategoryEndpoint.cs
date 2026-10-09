using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Categories;

public class DeleteCategoryEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapDelete("api/categories/{id}", async (IDbConnection db, string id) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@MATL", id);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_XOATHELOAI", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => Results.NotFound(new MessageResponse("Không tìm thấy thể loại")),
                1 => Results.BadRequest(new MessageResponse("Không thể xoá thể loại đang có sách")),
                2 => Results.Ok(new MessageResponse("Xoá thể loại thành công")),
                _ => Results.StatusCode(500)
            };
        })
        .WithName("DeleteCategory")
        .RequireAuthorization()
        .WithTags("Categories")
        .WithSummary("Xóa thể loại");
    }
}
