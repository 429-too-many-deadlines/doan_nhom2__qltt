using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Books;

public class DeleteBookCopyEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapDelete("api/books/copies/{macs}", async (IDbConnection db, string macs) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@MACS", macs);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_XOACUONSACH", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => Results.NotFound(new MessageResponse("Không tìm thấy cuốn sách")),
                1 => Results.BadRequest(new MessageResponse("Cuốn sách đã có lịch sử mượn, không thể xoá.")),
                2 => Results.Ok(new MessageResponse("Xoá cuốn sách thành công")),
                _ => Results.StatusCode(500)
            };
        })
        .WithName("DeleteBookCopy")
        .RequireAuthorization()
        .WithTags("Books");
    }
}
