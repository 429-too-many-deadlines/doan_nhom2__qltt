using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Books;

public class DeleteBookEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapDelete("api/books/{maDs}", async (IDbConnection db, string maDs) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@MADS", maDs);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_XOADAUSACH", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => Results.NotFound(new MessageResponse("Mã đầu sách không tồn tại.")),
                1 => Results.BadRequest(new MessageResponse("Đầu sách này vẫn còn các cuốn sách, không thể xóa.")),
                2 => Results.Ok(new MessageResponse("Xóa đầu sách thành công.")),
                _ => Results.StatusCode(500)
            };
        })
        .WithName("DeleteBook")
        .RequireAuthorization("QuanLyHoacThuThu")
           .WithTags("Books")
        .WithGroupName("v1")
        .WithSummary("Xóa đầu sách");
    }
}
