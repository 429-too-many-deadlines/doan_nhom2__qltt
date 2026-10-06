using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using QuanLyThuVien.Server.Shared;
using System.Data;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;

namespace QuanLyThuVien.Server.Endpoints.Reports;

public class RunReminderCursorEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("/api/reports/reminders", HandleAsync)
           .RequireAuthorization("QuanLyHoacThuThu")
           .WithTags("Reports")
           .WithSummary("Chạy cursor nhắc nhở quá hạn")
           .WithDescription("Gọi SP_CURSOR_NHACNHOQUAHAN và trả về danh sách nhắc nhở.");
    }

    private static async Task<IResult> HandleAsync(
        [FromBody] ReminderRequest req,
        IDbConnection db)
    {
        var parameters = new DynamicParameters();
        parameters.Add("@NGAYKIEMTRA", req.NgayKiemTra ?? DateTime.Now.Date);

        var result = await db.QueryAsync<ReminderResult>(
            "SP_CURSOR_NHACNHOQUAHAN",
            parameters,
            commandType: CommandType.StoredProcedure);

        return Results.Ok(result);
    }
}

public class ReminderRequest
{
    public DateTime? NgayKiemTra { get; set; }
}

public class ReminderResult
{
    public int MANN { get; set; }
    public string MAPM { get; set; } = null!;
    public string MACS { get; set; } = null!;
    public string MADG { get; set; } = null!;
    public string HOTEN { get; set; } = null!;
    public string SODT { get; set; } = null!;
    public string TENDS { get; set; } = null!;
    public DateTime HANTRA { get; set; }
    public int SONGAYTRE { get; set; }
    public decimal TIENPHATTAMTINH { get; set; }
    public string NOIDUNG { get; set; } = null!;
    public DateTime NGAYLAP { get; set; }
}
