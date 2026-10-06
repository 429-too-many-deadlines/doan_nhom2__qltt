using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Books;

public class GetBookAuthorsEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/books/{id}/authors", async (IDbConnection db, string id) =>
        {
            var authors = await db.QueryAsync("SELECT MATG as MaTG, VAITRO as VaiTro FROM DAUSACH_TACGIA WHERE MADS = @Id", new { Id = id });
            return Results.Ok(authors);
        })
        .WithName("GetBookAuthors")
        .RequireAuthorization()
        .WithTags("Books");
    }
}
