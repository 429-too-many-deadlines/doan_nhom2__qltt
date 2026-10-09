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
                await db.ExecuteAsync("SP_XOATACGIADAUSACH", new { MADS = id }, transaction, commandType: CommandType.StoredProcedure);
                foreach (var author in req.Authors)
                {
                    await db.ExecuteAsync(
                        "SP_THEMTACGIADAUSACH",
                        new { MADS = id, MATG = author.MaTG, VAITRO = author.VaiTro ?? "Tác giả" },
                        transaction,
                        commandType: CommandType.StoredProcedure
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
        .RequireAuthorization()
        .WithTags("Books");
    }
}
