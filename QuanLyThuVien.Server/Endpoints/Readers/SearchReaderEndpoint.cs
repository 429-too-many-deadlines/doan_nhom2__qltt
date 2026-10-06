using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Readers;

public class SearchReaderEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/readers/search", async (IDbConnection db, [FromQuery] string query = "") =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@TUKHOA", query);

            var readers = await db.QueryAsync("SP_TIMDOCGIA", parameters, commandType: CommandType.StoredProcedure);
            return Results.Ok(readers);
        })
        .WithName("SearchReaders")
        .RequireAuthorization()
           .WithTags("Readers")
        .WithGroupName("v1")
        .WithSummary("Tìm kiếm độc giả theo từ khóa");
    }
}
