using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.Publishers;

public class GetPublishersEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/publishers", async (IDbConnection db, string? query, int page = 1, int pageSize = 10) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@TUKHOA", string.IsNullOrWhiteSpace(query) ? null : query);
            parameters.Add("@PageNumber", page);
            parameters.Add("@PageSize", pageSize);

            var items = await db.QueryAsync<dynamic>("SP_LAYDANHSACHNHAXUATBAN", parameters, commandType: CommandType.StoredProcedure);

            int totalCount = 0;
            var firstRow = items.FirstOrDefault();
            if (firstRow != null)
            {
                var rowDict = (IDictionary<string, object>)firstRow;
                if (rowDict.TryGetValue("TotalRecord", out var tr) && tr != null)
                {
                    totalCount = Convert.ToInt32(tr);
                }
            }

            return Results.Ok(new PagedResult<dynamic>
            {
                Items = items,
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            });
        })
        .WithName("GetPublishers")
        .RequireAuthorization()
        .WithTags("Publishers")
        .WithSummary("Lấy danh sách nhà xuất bản");
    }
}
