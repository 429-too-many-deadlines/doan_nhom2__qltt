using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Authors;

public class DeleteAuthorEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapDelete("api/authors/{id}", async (IDbConnection db, string id) =>
        {
            new DbValidator()
                .Required("MaTG", id, DbRules.MaTg)
                .ThrowIfInvalid();

            var parameters = new DynamicParameters();
            parameters.Add("@MATG", id);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_XOATACGIA", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => ApiProblem.NotFound("Không tìm thấy tác giả"),
                1 => ApiProblem.BadRequest("Không thể xoá tác giả đã được gán cho đầu sách"),
                2 => Results.Ok(new MessageResponse("Xoá tác giả thành công")),
                _ => ApiProblem.Unexpected("SP_XOATACGIA", result)
            };
        })
        .WithName("DeleteAuthor")
        .RequireAuthorization()
        .WithTags("Authors")
        .WithSummary("Xóa tác giả");
    }
}
