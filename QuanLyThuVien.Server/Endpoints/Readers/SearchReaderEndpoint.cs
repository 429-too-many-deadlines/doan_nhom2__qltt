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
        app.MapGet("api/readers/search", async (IDbConnection db, [FromQuery] string query = "", [FromQuery] int page = 1, [FromQuery] int pageSize = 10) =>
        {
            var parameters = new DynamicParameters();
            parameters.Add("@TUKHOA", query);
            parameters.Add("@PageNumber", page);
            parameters.Add("@PageSize", pageSize);

            var readers = (await db.QueryAsync<dynamic>("SP_TIMDOCGIA", parameters, commandType: CommandType.StoredProcedure)).ToList();

            // Gắn số sách đang mượn (FN_SOSACHDANGMUON) cho cả trang bằng một truy vấn
            var rows = readers.Cast<IDictionary<string, object>>().ToList();
            if (rows.Count > 0)
            {
                var counts = (await db.QueryAsync<(string MaDg, int SoSach)>(
                        "SELECT MADG, dbo.FN_SOSACHDANGMUON(MADG) FROM DOCGIA WHERE MADG IN @Ids",
                        new { Ids = rows.Select(r => (string)r["MADG"]).ToArray() }))
                    .ToDictionary(c => c.MaDg.Trim(), c => c.SoSach);

                foreach (var row in rows)
                    row["SOSACHDANGMUON"] = counts.GetValueOrDefault(((string)row["MADG"]).Trim());
            }

            int totalCount = 0;
            var firstRow = readers.FirstOrDefault();
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
                Items = readers,
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };
            return Results.Ok(result);
        })
        .WithName("SearchReaders")
        .RequireAuthorization()
           .WithTags("Readers")
        .WithGroupName("v1")
        .WithSummary("Tìm kiếm độc giả theo từ khóa");
    }
}
