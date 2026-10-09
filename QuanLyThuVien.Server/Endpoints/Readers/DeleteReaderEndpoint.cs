using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Readers;

public class DeleteReaderEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapDelete("api/readers/{maDg}", async (IDbConnection db, string maDg) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@MADG", maDg);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_XOADOCGIA", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => Results.NotFound(new MessageResponse("Mã độc giả không tồn tại.")),
                1 => Results.BadRequest(new MessageResponse("Độc giả đã có lịch sử mượn trả, không thể xóa.")),
                2 => Results.Ok(new MessageResponse("Xóa độc giả thành công.")),
                _ => Results.StatusCode(500)
            };
        })
        .WithName("DeleteReader")
        .RequireAuthorization()
           .WithTags("Readers")
        .WithGroupName("v1")
        .WithSummary("Xóa độc giả");
    }
}
