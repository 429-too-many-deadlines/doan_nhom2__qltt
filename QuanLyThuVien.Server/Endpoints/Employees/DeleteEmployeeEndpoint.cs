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
            var parameters = new DynamicParameters();
            parameters.Add("@MANV", id);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_XOANHANVIEN", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => Results.NotFound(new MessageResponse("Không tìm thấy nhân viên")),
                1 => Results.BadRequest(new MessageResponse("Không thể xoá nhân viên đã lập phiếu mượn")),
                2 => Results.Ok(new MessageResponse("Xoá nhân viên thành công")),
                _ => Results.StatusCode(500)
            };
        })
        .WithName("DeleteEmployee")
        .RequireAuthorization()
        .WithTags("Employees")
        .WithSummary("Xóa nhân viên");
    }
}
