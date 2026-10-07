using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;
using System;

namespace QuanLyThuVien.Server.Endpoints.Employees;

public class UpdateEmployeeEndpoint : IEndpoint
{
    public record UpdateEmployeeRequest(string HoTen, DateTime NgSinh, string SoDT, string ChucVu, DateTime NgVL);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("api/employees/{id}", async (IDbConnection db, string id, [FromBody] UpdateEmployeeRequest req) =>
        {
            if (req.NgVL < req.NgSinh.AddYears(18))
            {
                return Results.BadRequest(new MessageResponse("Ngày vào làm không hợp lệ: Nhân viên phải đủ 18 tuổi."));
            }

            try
            {
                var sql = "UPDATE NHANVIEN SET HOTEN = @HoTen, NGSINH = @NgSinh, SODT = @SoDT, CHUCVU = @ChucVu, NGVL = @NgVL WHERE MANV = @MaNV";
                var result = await db.ExecuteAsync(sql, new { HoTen = req.HoTen, NgSinh = req.NgSinh, SoDT = req.SoDT, ChucVu = req.ChucVu, NgVL = req.NgVL, MaNV = id });
                
                if (result == 0) return Results.NotFound(new MessageResponse("Không tìm thấy nhân viên"));
                return Results.Ok(new MessageResponse("Cập nhật nhân viên thành công"));
            }
            catch (System.Exception ex)
            {
                return Results.BadRequest(new MessageResponse(ex.Message));
            }
        })
        .WithName("UpdateEmployee")
        .RequireAuthorization("QuanLyOnly")
        .WithTags("Employees")
        .WithSummary("Cập nhật nhân viên");
    }
}
