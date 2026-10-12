namespace QuanLyThuVien.Server.Shared;

/// <summary>
/// Phản hồi lỗi dạng ProblemDetails (RFC 9110), cùng title/status với GlobalExceptionHandler
/// để frontend chỉ phải xử lý một định dạng lỗi.
/// </summary>
public static class ApiProblem
{
    public static IResult BadRequest(string detail) =>
        Results.Problem(detail: detail, statusCode: StatusCodes.Status400BadRequest, title: "Bad Request");

    public static IResult NotFound(string detail) =>
        Results.Problem(detail: detail, statusCode: StatusCodes.Status404NotFound, title: "Not Found");

    public static IResult Unauthorized(string detail) =>
        Results.Problem(detail: detail, statusCode: StatusCodes.Status401Unauthorized, title: "Unauthorized");

    /// <summary>SP trả về mã kết quả không có trong đặc tả.</summary>
    public static IResult Unexpected(string storedProcedure, int returnValue) =>
        Results.Problem(
            detail: $"{storedProcedure} trả về mã kết quả không mong đợi: {returnValue}.",
            statusCode: StatusCodes.Status500InternalServerError,
            title: "Internal Server Error");
}
