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
            try
            {
                var exists = await db.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM CTPHIEUMUON WHERE MACS = @MaCS", new { MaCS = macs });
                if (exists > 0)
                {
                    return Results.BadRequest(new MessageResponse("Cuốn sách đã có lịch sử mượn, không thể xoá."));
                }
                
                await db.ExecuteAsync("DELETE FROM CUONSACH WHERE MACS = @MaCS", new { MaCS = macs });
                return Results.Ok(new MessageResponse("Xoá cuốn sách thành công"));
            }
            catch (Exception ex)
            {
                return Results.BadRequest(new MessageResponse(ex.Message));
            }
        })
        .WithName("DeleteBookCopy")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Books");
    }
}
