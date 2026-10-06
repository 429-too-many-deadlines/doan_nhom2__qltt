using Dapper;
using QuanLyThuVien.Server.Endpoints.Shared;
using QuanLyThuVien.Server.Shared;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace QuanLyThuVien.Server.Endpoints.ReaderTypes;

public class CreateReaderTypeEndpoint : IEndpoint
{
    public record CreateReaderTypeRequest(string MaLDG, string TenLDG, int SoSachToiDa, int SoNgayMuon);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("api/readertypes", async (IDbConnection db, [FromBody] CreateReaderTypeRequest req) =>
        {
            try
            {
                var sql = "INSERT INTO LOAIDOCGIA(MALDG, TENLDG, SOSACHTOIDA, SONGAYMUON) VALUES(@MaLDG, @TenLDG, @SoSachToiDa, @SoNgayMuon)";
                await db.ExecuteAsync(sql, req);
                return Results.Ok(new MessageResponse("Thêm loại độc giả thành công"));
            }
            catch (System.Exception ex)
            {
                return Results.BadRequest(new MessageResponse(ex.Message));
            }
        })
        .WithName("CreateReaderType")
        .RequireAuthorization("QuanLyHoacThuThu")
        .WithTags("ReaderTypes")
        .WithSummary("Thêm loại độc giả");
    }
}
