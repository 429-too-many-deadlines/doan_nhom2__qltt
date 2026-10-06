using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
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
        app.MapGet("api/books/search", async (IDbConnection db, [FromQuery] string query, [FromQuery] int page = 1, [FromQuery] int pageSize = 10) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@TUKHOA", query);
            parameters.Add("@PageNumber", page);
            parameters.Add("@PageSize", pageSize);

            var books = await db.QueryAsync<dynamic>("SP_TIMSACH", parameters, commandType: CommandType.StoredProcedure);
            
            int totalCount = 0;
            var firstRow = books.FirstOrDefault();
            if (firstRow != null)
            {
                var rowDict = (IDictionary<string, object>)firstRow;
                if (rowDict.TryGetValue("TotalRecord", out var tr) && tr != null)
                {
                    totalCount = Convert.ToInt32(tr);
                }
            }

            var result = new PagedResult<dynamic>
            {
                Items = books,
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };
            return Results.Ok(result);
        })
        .WithName("SearchBooks")
        .RequireAuthorization()
           .WithTags("Books")
        .WithGroupName("v1")
        .WithSummary("Tìm kiếm sách theo từ khóa");
    }
}
