using Dapper;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Readers;

public class UpdateReaderEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("api/readers/{maDg}", async (IDbConnection db, string maDg, [FromBody] UpdateReaderRequest req) =>
        {
            if (maDg != req.MaDg)
                return Results.BadRequest(new { Message = "Mã độc giả không khớp." });

            var parameters = new DynamicParameters();
            parameters.Add("@MADG", req.MaDg);
            parameters.Add("@HOTEN", req.HoTen);
            parameters.Add("@NGSINH", req.NgSinh);
            parameters.Add("@GIOITINH", req.GioiTinh);
            parameters.Add("@DIACHI", req.DiaChi);
            parameters.Add("@SODT", req.SoDt);
            parameters.Add("@EMAIL", req.Email);
            parameters.Add("@MALDG", req.MaLdg);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_SUADOCGIA", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => Results.NotFound(new { Message = "Mã độc giả không tồn tại." }),
                1 => Results.BadRequest(new { Message = "Loại độc giả không tồn tại." }),
                2 => Results.Ok(new { Message = "Cập nhật độc giả thành công." }),
                _ => Results.StatusCode(500)
            };
        })
        .WithName("UpdateReader")
        .WithTags("Readers")
        .WithGroupName("v1")
        .WithSummary("Cập nhật thông tin độc giả");
    }
}

public record UpdateReaderRequest(
    string MaDg, 
    string HoTen, 
    DateTime NgSinh, 
    string GioiTinh, 
    string? DiaChi, 
    string SoDt, 
    string? Email, 
    string MaLdg
);
