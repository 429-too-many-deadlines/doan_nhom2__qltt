using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Books;

public class GetBookCopiesEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/books/{id}/copies", async (IDbConnection db, string id) =>
        {
            var copies = await db.QueryAsync(
                "SP_LAYCUONSACHTHEODAUSACH",
                new { MADS = id },
                commandType: CommandType.StoredProcedure
            );
            return Results.Ok(copies);
        })
        .WithName("GetBookCopies")
        .RequireAuthorization()
        .WithTags("Books");
    }
}
