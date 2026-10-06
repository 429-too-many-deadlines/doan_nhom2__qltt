import { useState, useEffect } from 'react';
import { authService } from '../services/auth.service';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { Input } from '../components/ui/input';
import { Button } from '../components/ui/button';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '../components/ui/table';
import { toast } from 'sonner';


export interface Account {
  tendangnhap: string;
  vaitro: string;
  manv?: string;
  madg?: string;
  trangthai: boolean;
}

export default function Accounts() {
  const [createData, setCreateData] = useState({ username: '', password: '', role: 'Thủ thư', maNV: '', maDG: '' });
  const [changePwdData, setChangePwdData] = useState({ oldPassword: '', newPassword: '' });
  const [accounts, setAccounts] = useState<Account[]>([]);

  useEffect(() => {
    fetchAccounts();
  }, []);

  const fetchAccounts = async () => {
    try {
      const data = await authService.getAccounts();
      setAccounts(data);
    } catch {
      toast.error('Lỗi khi tải danh sách tài khoản');
    }
  };

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await authService.createAccount(createData);
      toast.success('Tạo tài khoản thành công');
      setCreateData({ username: '', password: '', role: 'Thủ thư', maNV: '', maDG: '' });
      fetchAccounts();
    } catch (error) {
      const err = error as { response?: { data?: { message?: string } } };
      toast.error(err.response?.data?.message || 'Lỗi khi tạo tài khoản');
    }
  };

  const handleChangePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await authService.changePassword(changePwdData);
      toast.success('Đổi mật khẩu thành công');
      setChangePwdData({ oldPassword: '', newPassword: '' });
    } catch (error) {
      const err = error as { response?: { data?: { message?: string } } };
      toast.error(err.response?.data?.message || 'Lỗi khi đổi mật khẩu');
    }
  };

  const handleToggleStatus = async (username: string, currentStatus: boolean) => {
    try {
      await authService.updateAccountStatus(username, !currentStatus);
      toast.success(`Đã ${!currentStatus ? 'mở khóa' : 'khóa'} tài khoản ${username}`);
      fetchAccounts();
    } catch (error) {
      const err = error as { response?: { data?: { message?: string } } };
      toast.error(err.response?.data?.message || 'Lỗi khi cập nhật trạng thái');
    }
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Tài khoản & Bảo mật</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Tạo Tài Khoản (Quản lý)</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleCreate} className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">Tên đăng nhập</label>
                <Input value={createData.username} onChange={(e) => setCreateData({...createData, username: e.target.value})} required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Mật khẩu</label>
                <Input type="password" value={createData.password} onChange={(e) => setCreateData({...createData, password: e.target.value})} required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Vai trò</label>
                <select className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                  value={createData.role} onChange={(e) => setCreateData({...createData, role: e.target.value})}>
                  <option value="Quản lý">Quản lý</option>
                  <option value="Thủ thư">Thủ thư</option>
                  <option value="Độc giả">Độc giả</option>
                </select>
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Mã Nhân Viên (Nếu có)</label>
                <Input value={createData.maNV} onChange={(e) => setCreateData({...createData, maNV: e.target.value})} />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Mã Độc Giả (Nếu có)</label>
                <Input value={createData.maDG} onChange={(e) => setCreateData({...createData, maDG: e.target.value})} />
              </div>
              <Button type="submit" className="w-full">Xác nhận tạo</Button>
            </form>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Đổi Mật Khẩu</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleChangePassword} className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">Mật khẩu cũ</label>
                <Input type="password" value={changePwdData.oldPassword} onChange={(e) => setChangePwdData({...changePwdData, oldPassword: e.target.value})} required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Mật khẩu mới</label>
                <Input type="password" value={changePwdData.newPassword} onChange={(e) => setChangePwdData({...changePwdData, newPassword: e.target.value})} required />
              </div>
              <Button type="submit" className="w-full">Xác nhận đổi</Button>
            </form>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Danh Sách Tài Khoản</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="rounded-md border overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Tên đăng nhập</TableHead>
                  <TableHead>Vai trò</TableHead>
                  <TableHead>Mã NV</TableHead>
                  <TableHead>Mã ĐG</TableHead>
                  <TableHead>Trạng thái</TableHead>
                  <TableHead className="text-right">Hành động</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {accounts.map((acc) => (
                  <TableRow key={acc.tendangnhap}>
                    <TableCell className="font-medium">{acc.tendangnhap}</TableCell>
                    <TableCell>{acc.vaitro}</TableCell>
                    <TableCell>{acc.manv || '-'}</TableCell>
                    <TableCell>{acc.madg || '-'}</TableCell>
                    <TableCell>
                      {acc.trangthai ? (
                        <span className="inline-flex items-center rounded-full bg-green-100 px-2.5 py-0.5 text-xs font-medium text-green-800">Hoạt động</span>
                      ) : (
                        <span className="inline-flex items-center rounded-full bg-red-100 px-2.5 py-0.5 text-xs font-medium text-red-800">Bị khóa</span>
                      )}
                    </TableCell>
                    <TableCell className="text-right">
                      <Button
                        variant={acc.trangthai ? "destructive" : "default"}
                        size="sm"
                        onClick={() => handleToggleStatus(acc.tendangnhap, acc.trangthai)}
                      >
                        {acc.trangthai ? 'Khóa' : 'Mở khóa'}
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
                {accounts.length === 0 && (
                  <TableRow>
                    <TableCell colSpan={6} className="h-24 text-center">
                      Không có dữ liệu
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
