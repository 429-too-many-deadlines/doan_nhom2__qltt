import { DataTablePagination } from '../components/ui/data-table-pagination';
import { useState, useEffect } from 'react';
import { authService } from '../services/auth.service';

import { Input } from '../components/ui/input';
import { Button } from '../components/ui/button';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '../components/ui/table';


export interface Account {
  tendangnhap: string;
  vaitro: string;
  MANV?: string;
  MADG?: string;
  trangthai: boolean;
}

export default function Accounts() {
  const [createData, setCreateData] = useState({ username: '', password: '', role: 'Thủ thư', MANV: '', MADG: '' });
  const [changePwdData, setChangePwdData] = useState({ oldPassword: '', newPassword: '' });
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [page, setPage] = useState(1);
  
  const pageSize = 10;
  const totalPages = Math.ceil(accounts.length / pageSize) || 1;
  const paginatedAccounts = accounts.slice((page - 1) * pageSize, page * pageSize);

  useEffect(() => {
    fetchAccounts();
  }, []);

  const fetchAccounts = async () => {
    try {
      const data = await authService.getAccounts();
      setAccounts(data);
    } catch {
      // toast.error('Lỗi khi tải danh sách tài khoản');
    }
  };

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await authService.createAccount(createData);
      // toast.success('Tạo tài khoản thành công');
      setCreateData({ username: '', password: '', role: 'Thủ thư', MANV: '', MADG: '' });
      fetchAccounts();
    } catch (error) {
      console.error(error);
    }
  };

  const handleChangePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await authService.changePassword(changePwdData);
      // toast.success('Đổi mật khẩu thành công');
      setChangePwdData({ oldPassword: '', newPassword: '' });
    } catch (error) {
      console.error(error);
    }
  };

  const handleToggleStatus = async (username: string, currentStatus: boolean) => {
    try {
      await authService.updateAccountStatus(username, !currentStatus);
      // toast.success(`Đã ${!currentStatus ? 'mở khóa' : 'khóa'} tài khoản ${username}`);
      fetchAccounts();
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Tài khoản & Bảo mật</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="space-y-4">
          <div className="mb-4">
            <h2 className="text-xl font-semibold">Tạo Tài Khoản (Quản lý)</h2>
          </div>
          <div>
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
                <Input value={createData.MANV} onChange={(e) => setCreateData({...createData, MANV: e.target.value})} />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Mã Độc Giả (Nếu có)</label>
                <Input value={createData.MADG} onChange={(e) => setCreateData({...createData, MADG: e.target.value})} />
              </div>
              <Button type="submit" className="w-full">Xác nhận tạo</Button>
            </form>
          </div>
        </div>

        <div className="space-y-4">
          <div className="mb-4">
            <h2 className="text-xl font-semibold">Đổi Mật Khẩu</h2>
          </div>
          <div>
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
          </div>
        </div>
      </div>

      <div className="space-y-4">
        <div className="mb-4">
          <h2 className="text-xl font-semibold">Danh Sách Tài Khoản</h2>
        </div>
        <div>
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
                {paginatedAccounts.map((acc) => (
                  <TableRow key={acc.tendangnhap}>
                    <TableCell className="font-medium">{acc.tendangnhap}</TableCell>
                    <TableCell>{acc.vaitro}</TableCell>
                    <TableCell>{acc.MANV || '-'}</TableCell>
                    <TableCell>{acc.MADG || '-'}</TableCell>
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
          <DataTablePagination page={page} totalPages={totalPages} onPageChange={setPage} />
        </div>
      </div>
    </div>
  );
}
