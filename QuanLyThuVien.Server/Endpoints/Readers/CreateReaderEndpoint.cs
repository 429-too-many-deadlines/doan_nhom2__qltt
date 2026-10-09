using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Readers;

public class CreateReaderEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("api/readers", async (IDbConnection db, [FromBody] CreateReaderRequest req) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@MADG", req.MaDg);
            parameters.Add("@HOTEN", req.HoTen);
            parameters.Add("@NGSINH", req.NgSinh);
            parameters.Add("@GIOITINH", req.GioiTinh);
            parameters.Add("@DIACHI", req.DiaChi);
            parameters.Add("@SODT", req.SoDt);
            parameters.Add("@EMAIL", req.Email);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_THEMDOCGIA", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => Results.BadRequest(new MessageResponse("Mã độc giả đã tồn tại.")),
                1 => Results.BadRequest(new MessageResponse("Loại độc giả không tồn tại.")),
                2 => Results.Ok(new MessageResponse("Thêm độc giả thành công.")),
                _ => Results.StatusCode(500)
            };
        })
        .WithName("CreateReader")
        .RequireAuthorization()
           .WithTags("Readers")
        .WithGroupName("v1")
        .WithSummary("Thêm độc giả mới");
    }
}

public record CreateReaderRequest(
    string MaDg, 
    string HoTen, 
    DateTime NgSinh, 
    string GioiTinh, 
    string? DiaChi, 
    string SoDt, 
    string? Email
);
