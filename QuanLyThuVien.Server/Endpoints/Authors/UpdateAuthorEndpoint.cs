using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Authors;

public class UpdateAuthorEndpoint : IEndpoint
{
    public record UpdateAuthorRequest(string TenTG, int? NamSinh, string? QuocTich);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("api/authors/{id}", async (IDbConnection db, string id, [FromBody] UpdateAuthorRequest req) =>
        {
            new DbValidator()
                .Required("MaTG", id, DbRules.MaTg)
                .Required("TenTG", req.TenTG, DbRules.TenTg)
                .MaxLength("QuocTich", req.QuocTich, DbRules.QuocTich)
                .ThrowIfInvalid();

            var parameters = new DynamicParameters();
            parameters.Add("@MATG", id);
            parameters.Add("@TENTG", req.TenTG);
            parameters.Add("@NAMSINH", req.NamSinh);
            parameters.Add("@QUOCTICH", req.QuocTich);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_SUATACGIA", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => ApiProblem.NotFound("Không tìm thấy tác giả"),
                1 => ApiProblem.BadRequest("Năm sinh tác giả không hợp lệ."),
                2 => Results.Ok(new MessageResponse("Cập nhật tác giả thành công")),
                _ => ApiProblem.Unexpected("SP_SUATACGIA", result)
            };
        })
        .WithName("UpdateAuthor")
        .RequireAuthorization()
        .WithTags("Authors")
        .WithSummary("Cập nhật tác giả");
    }
}
