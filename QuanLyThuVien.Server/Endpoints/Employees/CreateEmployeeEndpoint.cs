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

public class CreateEmployeeEndpoint : IEndpoint
{
    public record CreateEmployeeRequest(string MaNV, string HoTen, DateTime NgSinh, string SoDT, string ChucVu, DateTime NgVL);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("api/employees", async (IDbConnection db, [FromBody] CreateEmployeeRequest req) =>
        {
            try
            {
                var sql = "INSERT INTO NHANVIEN(MANV, HOTEN, NGSINH, SODT, CHUCVU, NGVL) VALUES(@MaNV, @HoTen, @NgSinh, @SoDT, @ChucVu, @NgVL)";
                await db.ExecuteAsync(sql, req);
                return Results.Ok(new MessageResponse("Thêm nhân viên thành công"));
            }
            catch (System.Exception ex)
            {
                return Results.BadRequest(new MessageResponse(ex.Message));
            }
        })
        .WithName("CreateEmployee")
        .RequireAuthorization("QuanLy")
        .WithTags("Employees")
        .WithSummary("Thêm nhân viên");
    }
}
