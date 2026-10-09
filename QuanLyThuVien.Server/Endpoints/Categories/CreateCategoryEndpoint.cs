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
            var parameters = new DynamicParameters();
            parameters.Add("@MATL", req.MaTL);
            parameters.Add("@TENTL", req.TenTL);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_THEMTHELOAI", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => Results.BadRequest(new MessageResponse("Mã thể loại đã tồn tại.")),
                1 => Results.BadRequest(new MessageResponse("Tên thể loại đã tồn tại.")),
                2 => Results.Ok(new MessageResponse("Thêm thể loại thành công")),
                _ => Results.StatusCode(500)
            };
        })
        .WithName("CreateCategory")
        .RequireAuthorization()
           .WithTags("Categories");
    }
}
