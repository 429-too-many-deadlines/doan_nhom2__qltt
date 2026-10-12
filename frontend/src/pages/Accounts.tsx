import { useState } from 'react';
import { authService } from '../services/auth.service';
import { Input } from '../components/ui/input';
import { Button } from '../components/ui/button';
import { toast } from 'sonner';
import { DB_LIMITS } from '@/lib/db-limits';

export default function Accounts() {
  const [changePwdData, setChangePwdData] = useState({ oldPassword: '', newPassword: '', confirmPassword: '' });
  const [loading, setLoading] = useState(false);

  const handleChangePassword = async () => {
    if (!changePwdData.oldPassword || !changePwdData.newPassword || !changePwdData.confirmPassword) {
      toast.error('Vui lòng nhập đầy đủ thông tin.');
      return;
    }
    if (changePwdData.newPassword !== changePwdData.confirmPassword) {
      toast.error('Mật khẩu mới không khớp.');
      return;
    }
    setLoading(true);
    try {
      await authService.changePassword(changePwdData.oldPassword, changePwdData.newPassword);
      setChangePwdData({ oldPassword: '', newPassword: '', confirmPassword: '' });
    } catch {
      // Lỗi (ProblemDetails) đã được interceptor trong lib/api.ts hiển thị
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">Đổi mật khẩu Admin</h1>
      <div className="max-w-md space-y-4 bg-white p-6 rounded-md shadow-sm border border-gray-100">
        <div>
          <label className="block text-sm font-medium mb-1">Mật khẩu cũ</label>
          <Input 
            type="password"
            placeholder="Nhập mật khẩu cũ"
            value={changePwdData.oldPassword} 
            onChange={(e) => setChangePwdData({ ...changePwdData, oldPassword: e.target.value })} 
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Mật khẩu mới</label>
          <Input 
            type="password"
            placeholder="Nhập mật khẩu mới"
            value={changePwdData.newPassword} maxLength={DB_LIMITS.MATKHAU} 
            onChange={(e) => setChangePwdData({ ...changePwdData, newPassword: e.target.value })} 
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Xác nhận mật khẩu mới</label>
          <Input 
            type="password"
            placeholder="Nhập lại mật khẩu mới"
            value={changePwdData.confirmPassword} maxLength={DB_LIMITS.MATKHAU} 
            onChange={(e) => setChangePwdData({ ...changePwdData, confirmPassword: e.target.value })} 
          />
        </div>
        <Button onClick={handleChangePassword} disabled={loading} className="w-full">
          {loading ? 'Đang xử lý...' : 'Đổi mật khẩu'}
        </Button>
      </div>
    </div>
  );
}
