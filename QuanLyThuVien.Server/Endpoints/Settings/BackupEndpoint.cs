using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using QuanLyThuVien.Server.Shared;
using System.Data;
using System.Threading.Tasks;
using System;
using Microsoft.AspNetCore.Mvc;

namespace QuanLyThuVien.Server.Endpoints.Settings;

public class BackupEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("/api/settings/backup", HandleAsync)
           .RequireAuthorization()
           .WithTags("Settings")
           .WithSummary("Sao lưu cơ sở dữ liệu")
           .WithDescription("Gọi SP_SAOLUU. Tham số type = 'FULL' hoặc 'DIFF'.");
    }

    private static async Task<IResult> HandleAsync(
        [FromBody] BackupRequest req,
        IDbConnection db)
    {
        var parameters = new DynamicParameters();
        // Mặc định lưu vào thư mục data của docker mssql
        string fileName = $"QUANLYTHUVIEN_{req.Type}_{DateTime.Now:yyyyMMdd_HHmmss}.bak";
        string filePath = $"/var/opt/mssql/data/{fileName}";

        parameters.Add("@DUONGDAN", filePath);
        parameters.Add("@LOAI", req.Type);

        var result = await db.QueryAsync<BackupHistory>(
            "SP_SAOLUU",
            parameters,
            commandType: CommandType.StoredProcedure);

        return Results.Ok(new BackupResponse($"Đã sao lưu thành công tại {filePath}", result));
    }
}

public record BackupResponse(string Message, IEnumerable<BackupHistory> History);

public class BackupRequest
{
    public string Type { get; set; } = "FULL"; // FULL or DIFF
}

public class BackupHistory
{
    public DateTime backup_start_date { get; set; }
    public DateTime backup_finish_date { get; set; }
    public string LOAI { get; set; } = null!;
    public string DUONGDAN { get; set; } = null!;
    public decimal DUNGLUONG_MB { get; set; }
}
