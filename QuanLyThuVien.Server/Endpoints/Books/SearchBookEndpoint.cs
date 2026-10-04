using Dapper;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Books;

public class SearchBookEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/books/search", async (IDbConnection db, [FromQuery] string query) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@TUKHOA", query);

            var books = await db.QueryAsync("SP_TIMSACH", parameters, commandType: CommandType.StoredProcedure);
            return Results.Ok(books);
        })
        .WithName("SearchBooks")
        .WithTags("Books")
        .WithGroupName("v1")
        .WithSummary("Tìm kiếm sách theo từ khóa");
    }
}
