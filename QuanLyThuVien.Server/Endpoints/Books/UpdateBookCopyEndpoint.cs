using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Books;

public class UpdateBookCopyEndpoint : IEndpoint
{
    public record UpdateBookCopyRequest(string ViTri, string TinhTrang);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("api/books/copies/{macs}", async (IDbConnection db, string macs, [FromBody] UpdateBookCopyRequest req) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@MACS", macs);
            parameters.Add("@VITRI", req.ViTri);
            parameters.Add("@TINHTRANG", req.TinhTrang);
            parameters.Add("@ReturnValue", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

            await db.ExecuteAsync("SP_SUACUONSACH", parameters, commandType: CommandType.StoredProcedure);
            var result = parameters.Get<int>("@ReturnValue");

            return result switch
            {
                0 => Results.NotFound(new MessageResponse("Không tìm thấy cuốn sách")),
                1 => Results.BadRequest(new MessageResponse("Tình trạng cuốn sách không hợp lệ.")),
                2 => Results.Ok(new MessageResponse("Cập nhật cuốn sách thành công")),
                _ => Results.StatusCode(500)
            };
        })
        .WithName("UpdateBookCopy")
        .RequireAuthorization()
        .WithTags("Books");
    }
}
