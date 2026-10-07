using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Employees;

public class DeleteEmployeeEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapDelete("api/employees/{id}", async (IDbConnection db, string id) =>
        {
            var count = await db.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM PHIEUMUON WHERE MANV = @MaNV", new { MaNV = id });
            if (count > 0)
            {
                return Results.BadRequest(new MessageResponse("Không thể xoá nhân viên đã lập phiếu mượn"));
            }

            var sql = "DELETE FROM NHANVIEN WHERE MANV = @MaNV";
            var result = await db.ExecuteAsync(sql, new { MaNV = id });
            
            if (result == 0) return Results.NotFound(new MessageResponse("Không tìm thấy nhân viên"));
            return Results.Ok(new MessageResponse("Xoá nhân viên thành công"));
        })
        .WithName("DeleteEmployee")
        .RequireAuthorization("QuanLyOnly")
        .WithTags("Employees")
        .WithSummary("Xóa nhân viên");
    }
}
