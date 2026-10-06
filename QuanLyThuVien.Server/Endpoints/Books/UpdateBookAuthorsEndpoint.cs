using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Books;

public class UpdateBookAuthorsEndpoint : IEndpoint
{
    public record AuthorRoleRequest(string MaTG, string VaiTro);
    public record UpdateBookAuthorsRequest(List<AuthorRoleRequest> Authors);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("api/books/{id}/authors", async (IDbConnection db, string id, [FromBody] UpdateBookAuthorsRequest req) =>
        {
            if (db.State != ConnectionState.Open) db.Open();
            using var transaction = db.BeginTransaction();
            try
            {
                await db.ExecuteAsync("DELETE FROM DAUSACH_TACGIA WHERE MADS = @Id", new { Id = id }, transaction);
                foreach (var author in req.Authors)
                {
                    await db.ExecuteAsync(
                        "INSERT INTO DAUSACH_TACGIA (MADS, MATG, VAITRO) VALUES (@MaDS, @MaTG, @VaiTro)",
                        new { MaDS = id, MaTG = author.MaTG, VaiTro = author.VaiTro ?? "Tác giả" },
                        transaction
                    );
                }
                transaction.Commit();
                return Results.Ok(new MessageResponse("Cập nhật tác giả thành công"));
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                return Results.BadRequest(new MessageResponse(ex.Message));
            }
        })
        .WithName("UpdateBookAuthors")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Books");
    }
}
