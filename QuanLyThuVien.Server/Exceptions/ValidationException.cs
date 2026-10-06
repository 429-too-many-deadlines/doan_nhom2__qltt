namespace QuanLyThuVien.Server.Exceptions;

public class ValidationException : BadRequestException
{
    public IDictionary<string, string[]> Errors { get; }

    public ValidationException(string message, IDictionary<string, string[]>? errors = null) 
        : base(message)
    {
        Errors = errors ?? new Dictionary<string, string[]>();
    }
}
