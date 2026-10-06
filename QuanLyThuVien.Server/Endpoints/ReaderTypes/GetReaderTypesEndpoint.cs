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
        app.MapGet("api/readertypes", async (IDbConnection db, int page = 1, int pageSize = 10) =>
        {
            var offset = (page - 1) * pageSize;
            var totalCount = await db.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM LOAIDOCGIA");
            var items = await db.QueryAsync<dynamic>("SELECT * FROM LOAIDOCGIA ORDER BY MALDG OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY", new { Offset = offset, PageSize = pageSize });
            return Results.Ok(new PagedResult<dynamic>
            {
                Items = items,
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            });
        })
        .WithName("GetReaderTypes")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("ReaderTypes")
        .WithSummary("Lấy danh sách loại độc giả");
    }
}
