using QuanLyThuVien.Server.Exceptions;

namespace QuanLyThuVien.Server.Shared;

/// <summary>
/// Giới hạn độ dài lấy theo schema CSDL (db/1_TaoBang.sql) - CSDL là nguồn sự thật.
/// SQL Server tự cắt ngắn chuỗi truyền vào tham số SP mà không báo lỗi
/// (VD: '@MADG = DG0019' thành 'DG001'), nên phải chặn ở API trước khi gọi SP.
/// </summary>
public static class DbRules
{
    // Khóa chính
    public const int MaDg = 5;
    public const int MaDs = 5;
    public const int MaCs = 5;
    public const int MaTg = 5;
    public const int MaNxb = 5;
    public const int MaTl = 4;
    public const int MaPm = 6;

    // Các cột chuỗi khác (lấy theo cột của bảng, không theo tham số SP)
    public const int HoTenDg = 40;
    public const int GioiTinh = 3;
    public const int DiaChiDg = 100;
    public const int SoDt = 15;
    public const int Email = 50;
    public const int TenDs = 100;
    public const int TenTl = 50;
    public const int TenTg = 50;
    public const int QuocTich = 30;
    public const int TenNxb = 60;
    public const int DiaChiNxb = 100;
    public const int ViTri = 20;
    public const int TinhTrang = 20;
    public const int VaiTro = 20;
    public const int TenDangNhap = 30;
    public const int MatKhau = 100;
    public const int DsMaCs = 200;
}

/// <summary>Gom lỗi kiểm tra đầu vào rồi ném ValidationException (400).</summary>
public class DbValidator
{
    private readonly Dictionary<string, string[]> _errors = new();

    public DbValidator Required(string field, string? value, int maxLength)
    {
        if (string.IsNullOrWhiteSpace(value))
            _errors[field] = [$"{field} không được để trống."];
        else
            MaxLength(field, value, maxLength);
        return this;
    }

    public DbValidator MaxLength(string field, string? value, int maxLength)
    {
        if (value != null && value.Length > maxLength)
            _errors[field] = [$"{field} tối đa {maxLength} ký tự."];
        return this;
    }

    public void ThrowIfInvalid()
    {
        if (_errors.Count > 0)
            throw new ValidationException(string.Join(" ", _errors.Values.SelectMany(e => e)), _errors);
    }
}
