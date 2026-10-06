namespace QuanLyThuVien.Server.Exceptions;

public class NotFoundException : AppException
{
    public NotFoundException(string message) : base(message)
    {
    }
}
