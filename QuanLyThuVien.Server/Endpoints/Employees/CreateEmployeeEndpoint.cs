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
            var parameters = new DynamicParameters();
            parameters.Add("@MANV", req.MaNV);
            parameters.Add("@HOTEN", req.HoTen);
            parameters.Add("@NGSINH", req.NgSinh);
            parameters.Add("@SODT", req.SoDT);
            parameters.Add("@CHUCVU", req.ChucVu);
            parameters.Add("@NGVL", req.NgVL);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_THEMNHANVIEN", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => Results.BadRequest(new MessageResponse("Mã nhân viên đã tồn tại.")),
                1 => Results.BadRequest(new MessageResponse("Chức vụ không hợp lệ.")),
                2 => Results.BadRequest(new MessageResponse("Ngày vào làm không hợp lệ: Nhân viên phải đủ 18 tuổi.")),
                3 => Results.Ok(new MessageResponse("Thêm nhân viên thành công")),
                _ => Results.StatusCode(500)
            };
        })
        .WithName("CreateEmployee")
        .RequireAuthorization()
        .WithTags("Employees")
        .WithSummary("Thêm nhân viên");
    }
}
