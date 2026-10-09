using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Categories;

public class UpdateCategoryEndpoint : IEndpoint
{
    public record UpdateCategoryRequest(string TenTL);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("api/categories/{id}", async (IDbConnection db, string id, [FromBody] UpdateCategoryRequest req) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@MATL", id);
            parameters.Add("@TENTL", req.TenTL);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_SUATHELOAI", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => Results.NotFound(new MessageResponse("Không tìm thấy thể loại")),
                1 => Results.BadRequest(new MessageResponse("Tên thể loại đã tồn tại.")),
                2 => Results.Ok(new MessageResponse("Cập nhật thể loại thành công")),
                _ => Results.StatusCode(500)
            };
        })
        .WithName("UpdateCategory")
        .RequireAuthorization()
        .WithTags("Categories")
        .WithSummary("Cập nhật thể loại");
    }
}
