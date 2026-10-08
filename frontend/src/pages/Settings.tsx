
import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { apiClient } from '@/lib/api';

export default function Settings() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState('Độc giả');
  const [MANV, setManv] = useState('');
  const [MADG, setMadg] = useState('');
  const [createMsg, setCreateMsg] = useState('');

  const [backupMsg, setBackupMsg] = useState('');
  const [backupType, setBackupType] = useState('FULL');

  const [oldPassword, setOldPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [changePwdMsg, setChangePwdMsg] = useState('');

  const handleCreateAccount = async (e: React.FormEvent) => {
    e.preventDefault();
    setCreateMsg('');
    try {
      const res = await apiClient.post('/api/auth/create-account', { username, password, role, MANV, MADG });
      setCreateMsg(res.data.message);
      // toast.success(res.data.message);
    } catch (error) {
      const err = error as { response?: { data?: { message?: string } } };
      setCreateMsg(err.response?.data?.message || 'Lỗi tạo tài khoản');
      // toast.error(err.response?.data?.message || 'Lỗi tạo tài khoản');
    }
  };

  const handleBackup = async () => {
    setBackupMsg('Đang sao lưu...');
    try {
      const res = await apiClient.post('/api/settings/backup', { type: backupType });
      setBackupMsg(res.data.message);
      // toast.success(res.data.message);
    } catch (error) {
      const err = error as { response?: { data?: { message?: string } } };
      setBackupMsg(err.response?.data?.message || 'Lỗi sao lưu');
      // toast.error(err.response?.data?.message || 'Lỗi sao lưu');
    }
  };

  const handleChangePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setChangePwdMsg('');
    try {
      const res = await apiClient.post('/api/auth/change-password', { oldPassword, newPassword });
      setChangePwdMsg(res.data.message);
      // toast.success(res.data.message);
      setOldPassword('');
      setNewPassword('');
    } catch (error) {
      const err = error as { response?: { data?: { message?: string } } };
      setChangePwdMsg(err.response?.data?.message || 'Lỗi đổi mật khẩu');
      // toast.error(err.response?.data?.message || 'Lỗi đổi mật khẩu');
    }
  };

  return (
    <div className="p-6 space-y-8">
      <h1 className="text-2xl font-bold">Cài đặt Hệ thống</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        
        {/* Đổi Mật Khẩu */}
        <div className="p-6 bg-white rounded-lg shadow dark:bg-gray-800">
          <h2 className="text-lg font-bold mb-4">Đổi Mật Khẩu</h2>
          {changePwdMsg && <p className="mb-4 text-sm text-blue-600">{changePwdMsg}</p>}
          <form className="space-y-4" onSubmit={handleChangePassword}>
            <div className="space-y-2">
              <Label>Mật khẩu cũ</Label>
              <Input type="password" value={oldPassword} onChange={e => setOldPassword(e.target.value)} required />
            </div>
            <div className="space-y-2">
              <Label>Mật khẩu mới</Label>
              <Input type="password" value={newPassword} onChange={e => setNewPassword(e.target.value)} required />
            </div>
            <Button type="submit">Đổi mật khẩu</Button>
          </form>
        </div>

        {/* Tạo Tài Khoản */}
        <div className="p-6 bg-white rounded-lg shadow dark:bg-gray-800">
          <h2 className="text-lg font-bold mb-4">Tạo Tài khoản (Chỉ Quản lý)</h2>
          {createMsg && <p className="mb-4 text-sm text-blue-600">{createMsg}</p>}
          <form className="space-y-4" onSubmit={handleCreateAccount}>
            <div className="space-y-2">
              <Label>Tên đăng nhập</Label>
              <Input value={username} onChange={e => setUsername(e.target.value)} required />
            </div>
            <div className="space-y-2">
              <Label>Mật khẩu</Label>
              <Input type="password" value={password} onChange={e => setPassword(e.target.value)} required />
            </div>
            <div className="space-y-2">
              <Label>Vai trò</Label>
              <Select value={role} onValueChange={setRole}>
                <SelectTrigger>
                  <SelectValue placeholder="Chọn vai trò" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="Quản lý">Quản lý</SelectItem>
                  <SelectItem value="Thủ thư">Thủ thư</SelectItem>
                  <SelectItem value="Độc giả">Độc giả</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label>Mã NV (nếu có)</Label>
              <Input value={MANV} onChange={e => setManv(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Mã ĐG (nếu có)</Label>
              <Input value={MADG} onChange={e => setMadg(e.target.value)} />
            </div>
            <Button type="submit">Tạo tài khoản</Button>
          </form>
        </div>

        {/* Sao Lưu */}
        <div className="p-6 bg-white rounded-lg shadow dark:bg-gray-800">
          <h2 className="text-lg font-bold mb-4">Sao lưu Dữ liệu (Chỉ Quản lý)</h2>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label>Loại Sao lưu</Label>
              <Select value={backupType} onValueChange={setBackupType}>
                <SelectTrigger>
                  <SelectValue placeholder="Loại sao lưu" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="FULL">Full Backup</SelectItem>
                  <SelectItem value="DIFF">Differential Backup</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <Button onClick={handleBackup}>Thực hiện sao lưu</Button>
            {backupMsg && <p className="mt-4 text-sm text-blue-600">{backupMsg}</p>}
          </div>
        </div>
      </div>
    </div>
  );
}
