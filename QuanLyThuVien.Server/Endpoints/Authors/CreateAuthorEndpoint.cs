using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Authors;

public class CreateAuthorEndpoint : IEndpoint
{
    public record CreateAuthorRequest(string MaTG, string TenTG, int? NamSinh, string? QuocTich);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("api/authors", async (IDbConnection db, [FromBody] CreateAuthorRequest req) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@MATG", req.MaTG);
            parameters.Add("@TENTG", req.TenTG);
            parameters.Add("@NAMSINH", req.NamSinh);
            parameters.Add("@QUOCTICH", req.QuocTich);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_THEMTACGIA", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => Results.BadRequest(new MessageResponse("Mã tác giả đã tồn tại.")),
                1 => Results.BadRequest(new MessageResponse("Năm sinh tác giả không hợp lệ.")),
                2 => Results.Ok(new MessageResponse("Thêm tác giả thành công")),
                _ => Results.StatusCode(500)
            };
        })
        .WithName("CreateAuthor")
        .RequireAuthorization()
        .WithTags("Authors")
        .WithSummary("Thêm tác giả");
    }
}
