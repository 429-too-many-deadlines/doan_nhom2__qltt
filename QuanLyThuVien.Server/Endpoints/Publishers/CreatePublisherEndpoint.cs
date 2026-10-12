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
            new DbValidator()
                .Required("MaNXB", req.MaNXB, DbRules.MaNxb)
                .Required("TenNXB", req.TenNXB, DbRules.TenNxb)
                .MaxLength("DiaChi", req.DiaChi, DbRules.DiaChiNxb)
                .MaxLength("SoDT", req.SoDT, DbRules.SoDt)
                .ThrowIfInvalid();

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
                0 => ApiProblem.BadRequest("Mã nhà xuất bản đã tồn tại."),
                1 => ApiProblem.BadRequest("Tên nhà xuất bản đã tồn tại."),
                2 => Results.Ok(new MessageResponse("Thêm nhà xuất bản thành công")),
                _ => ApiProblem.Unexpected("SP_THEMNHAXUATBAN", result)
            };
        })
        .WithName("CreatePublisher")
        .RequireAuthorization()
        .WithTags("Publishers")
        .WithSummary("Thêm nhà xuất bản");
    }
}
