using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using QuanLyThuVien.Server.Shared;
using System.Data;
using System.Threading.Tasks;

namespace QuanLyThuVien.Server.Endpoints.Transactions;

public class GetBorrowSlipsEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("api/transactions/borrows", async (IDbConnection db, int page = 1, int pageSize = 10) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@PageNumber", page);
            parameters.Add("@PageSize", pageSize);

            var items = await db.QueryAsync<dynamic>("SP_LAYDANHSACHPHIEUMUON", parameters, commandType: CommandType.StoredProcedure);

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
        .WithName("GetBorrowSlips")
        .RequireAuthorization()
        .WithTags("Transactions")
        .WithGroupName("v1")
        .WithSummary("Lấy danh sách phiếu mượn");
    }
}
