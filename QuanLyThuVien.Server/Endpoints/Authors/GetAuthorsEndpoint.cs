using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Authors;

public class GetAuthorsEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/authors", async (IDbConnection db, string? query) =>
        {
            var sql = "SELECT * FROM TACGIA";
            if (!string.IsNullOrEmpty(query))
            {
                sql += " WHERE TENTG LIKE @Query OR MATG LIKE @Query";
                var authors = await db.QueryAsync(sql, new { Query = $"%{query}%" });
                return Results.Ok(authors);
            }
            else
            {
                var authors = await db.QueryAsync(sql);
                return Results.Ok(authors);
            }
        })
        .WithName("GetAuthors")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("Authors")
        .WithSummary("Lấy danh sách tác giả");
    }
}
