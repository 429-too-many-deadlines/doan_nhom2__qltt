using Microsoft.Data.SqlClient;

namespace QuanLyThuVien.Server.Infrastructure.ErrorHandling;

/// <summary>
/// Dịch lỗi do CSDL chặn (CHECK, FK, UNIQUE, RAISERROR trong trigger/SP) thành thông báo 400.
/// Trả về null nếu không phải lỗi dữ liệu (lỗi kết nối, cú pháp...) để giữ nguyên 500.
/// </summary>
public static class SqlErrorTranslator
{
    // Tên CHECK constraint trong db/1_TaoBang.sql
    private static readonly Dictionary<string, string> CheckMessages = new(StringComparer.OrdinalIgnoreCase)
    {
        ["CK_TACGIA_NAMSINH"] = "Năm sinh tác giả phải từ 1000 đến năm hiện tại.",
        ["CK_DAUSACH_NAMXB"] = "Năm xuất bản phải từ 1900 đến năm hiện tại.",
        ["CK_DAUSACH_SOTRANG"] = "Số trang phải lớn hơn 0.",
        ["CK_DAUSACH_GIA"] = "Giá sách phải lớn hơn 0.",
        ["CK_DAUSACH_SL"] = "Số lượng sách còn không hợp lệ.",
        ["CK_DSTG_VAITRO"] = "Vai trò phải là 'Tác giả', 'Đồng tác giả' hoặc 'Dịch giả'.",
        ["CK_CUONSACH_TINHTRANG"] = "Tình trạng cuốn sách phải là 'Có sẵn', 'Đang mượn', 'Hư hỏng' hoặc 'Mất'.",
        ["CK_DOCGIA_GIOITINH"] = "Giới tính phải là 'Nam' hoặc 'Nữ'.",
        ["CK_DOCGIA_NGAYTHE"] = "Ngày hết hạn thẻ phải sau ngày lập thẻ.",
        ["CK_DOCGIA_TUOI"] = "Độc giả phải từ 16 tuổi trở lên.",
        ["CK_DOCGIA_TONGNO"] = "Tổng nợ không được âm.",
        ["CK_DOCGIA_EMAIL"] = "Email không đúng định dạng.",
        ["CK_PHIEUMUON_HANTRA"] = "Hạn trả phải sau ngày mượn.",
        ["CK_PHIEUMUON_TINHTRANG"] = "Tình trạng phiếu mượn không hợp lệ.",
        ["CK_CTPM_TINHTRANGTRA"] = "Tình trạng trả phải là 'Bình thường', 'Hư hỏng' hoặc 'Mất'.",
        ["CK_CTPM_TRASACH"] = "Ngày trả và tình trạng trả phải cùng có hoặc cùng trống.",
        ["CK_PHIEUPHAT_LYDO"] = "Lý do phạt không hợp lệ.",
        ["CK_PHIEUPHAT_SOTIEN"] = "Số tiền phạt phải lớn hơn 0.",
    };

    public static string? Translate(SqlException ex)
    {
        foreach (var (name, message) in CheckMessages)
        {
            if (ex.Message.Contains(name, StringComparison.OrdinalIgnoreCase))
                return message;
        }

        // Kiểm tra theo nội dung vì SP_LAPPHIEUMUON bắt lỗi rồi RAISERROR lại (số lỗi thành 50000)
        if (ex.Message.Contains("FOREIGN KEY", StringComparison.OrdinalIgnoreCase))
            return "Mã tham chiếu không tồn tại hoặc dữ liệu đang được sử dụng.";
        if (ex.Message.Contains("duplicate key", StringComparison.OrdinalIgnoreCase))
            return "Dữ liệu bị trùng với bản ghi đã có.";
        if (ex.Message.Contains("would be truncated", StringComparison.OrdinalIgnoreCase))
            return "Dữ liệu vượt quá độ dài cho phép.";

        // RAISERROR/THROW từ trigger, SP - thông báo đã viết sẵn bằng tiếng Việt
        foreach (SqlError error in ex.Errors)
        {
            if (error.Number == 50000)
                return error.Message;
        }

        return null;
    }
}
