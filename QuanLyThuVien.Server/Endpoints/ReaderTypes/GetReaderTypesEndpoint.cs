using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.ReaderTypes;

public class GetReaderTypesEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/readertypes", async (IDbConnection db) =>
        {
            var items = await db.QueryAsync("SELECT * FROM LOAIDOCGIA");
            return Results.Ok(items);
        })
        .WithName("GetReaderTypes")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("ReaderTypes")
        .WithSummary("Lấy danh sách loại độc giả");
    }
}
