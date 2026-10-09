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
        app.MapGet("api/authors", async (IDbConnection db, string? query, int page = 1, int pageSize = 10) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@TUKHOA", string.IsNullOrWhiteSpace(query) ? null : query);
            parameters.Add("@PageNumber", page);
            parameters.Add("@PageSize", pageSize);

            var authors = await db.QueryAsync<dynamic>("SP_LAYDANHSACHTACGIA", parameters, commandType: CommandType.StoredProcedure);

            int totalCount = 0;
            var firstRow = authors.FirstOrDefault();
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
                Items = authors,
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            });
        })
        .WithName("GetAuthors")
        .RequireAuthorization()
        .WithTags("Authors")
        .WithSummary("Lấy danh sách tác giả");
    }
}
