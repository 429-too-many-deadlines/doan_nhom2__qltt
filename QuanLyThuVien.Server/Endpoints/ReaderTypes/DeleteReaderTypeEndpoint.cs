using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.ReaderTypes;

public class DeleteReaderTypeEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapDelete("api/readertypes/{id}", async (IDbConnection db, string id) =>
        {
            var count = await db.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM DOCGIA WHERE MALDG = @MaLDG", new { MaLDG = id });
            if (count > 0)
            {
                return Results.BadRequest(new MessageResponse("Không thể xoá loại độc giả đang có độc giả"));
            }

            var sql = "DELETE FROM LOAIDOCGIA WHERE MALDG = @MaLDG";
            var result = await db.ExecuteAsync(sql, new { MaLDG = id });
            
            if (result == 0) return Results.NotFound(new MessageResponse("Không tìm thấy loại độc giả"));
            return Results.Ok(new MessageResponse("Xoá loại độc giả thành công"));
        })
        .WithName("DeleteReaderType")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("ReaderTypes")
        .WithSummary("Xóa loại độc giả");
    }
}
