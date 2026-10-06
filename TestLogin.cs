using Dapper;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using System;

class Program
{
    static async Task Main()
    {
        string connStr = "Server=localhost,1433;Database=QUANLYTHUVIEN;User Id=sa;Password=StrongPassword123!;TrustServerCertificate=True;";
        using var db = new SqlConnection(connStr);
        var parameters = new DynamicParameters();
        parameters.Add("@TENDANGNHAP", "admin");
        parameters.Add("@MATKHAU", "123456");
        parameters.Add("@KETQUA", dbType: DbType.Int32, direction: ParameterDirection.Output);
        
        await db.ExecuteAsync("SP_DANGNHAP", parameters, commandType: CommandType.StoredProcedure);
        Console.WriteLine("KetQua: " + parameters.Get<int>("@KETQUA"));
    }
}
