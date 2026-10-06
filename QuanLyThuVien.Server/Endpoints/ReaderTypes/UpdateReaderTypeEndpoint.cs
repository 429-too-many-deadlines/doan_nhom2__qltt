using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.ReaderTypes;

public class UpdateReaderTypeEndpoint : IEndpoint
{
    public record UpdateReaderTypeRequest(string TenLDG, int SoSachToiDa, int SoNgayMuon);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("api/readertypes/{id}", async (IDbConnection db, string id, [FromBody] UpdateReaderTypeRequest req) =>
        {
            var sql = "UPDATE LOAIDOCGIA SET TENLDG = @TenLDG, SOSACHTOIDA = @SoSachToiDa, SONGAYMUON = @SoNgayMuon WHERE MALDG = @MaLDG";
            var result = await db.ExecuteAsync(sql, new { TenLDG = req.TenLDG, SoSachToiDa = req.SoSachToiDa, SoNgayMuon = req.SoNgayMuon, MaLDG = id });
            
            if (result == 0) return Results.NotFound(new MessageResponse("Không tìm thấy loại độc giả"));
            return Results.Ok(new MessageResponse("Cập nhật loại độc giả thành công"));
        })
        .WithName("UpdateReaderType")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("ReaderTypes")
        .WithSummary("Cập nhật loại độc giả");
    }
}
