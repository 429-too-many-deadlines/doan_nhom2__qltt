import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { employeesService } from '@/services/employees.service';
import type { Employee } from '@/types/api.types';

interface Props {
  employee: Employee | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSuccess: () => void;
}

export function UpdateEmployeeDialog({ employee, open, onOpenChange, onSuccess }: Props) {
  const [formData, setFormData] = useState({ MANV: '', HOTEN: '', NGSINH: '', SODT: '', CHUCVU: 'Thủ thư', NGVL: '' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (employee && open) {
      setFormData({ 
        MANV: employee.MANV, 
        HOTEN: employee.HOTEN, 
        NGSINH: employee.NGSINH?.split('T')[0] || '', 
        SODT: employee.SODT || '',
        CHUCVU: employee.CHUCVU || 'Thủ thư',
        NGVL: employee.NGVL?.split('T')[0] || ''
      });
    }
  }, [employee, open]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!employee) return;
    
    setLoading(true);
    try {
      await employeesService.updateEmployee(formData.MANV, formData);
      // toast.success('Cập nhật thành công');
      onOpenChange(false);
      onSuccess();
    } catch (_error: any) {
      // toast.error(error.response?.data?.message || 'Lỗi khi cập nhật');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Cập nhật Nhân viên</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4 mt-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Mã NV</label>
            <Input 
              value={formData.MANV}
              disabled
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Họ tên</label>
            <Input 
              value={formData.HOTEN}
              onChange={(e) => setFormData({ ...formData, HOTEN: e.target.value })}
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Ngày sinh</label>
            <Input 
              type="date"
              value={formData.NGSINH}
              onChange={(e) => setFormData({ ...formData, NGSINH: e.target.value })}
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Số điện thoại</label>
            <Input 
              value={formData.SODT}
              onChange={(e) => setFormData({ ...formData, SODT: e.target.value })}
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Chức vụ</label>
            <select 
              className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background"
              value={formData.CHUCVU} onChange={(e) => setFormData({ ...formData, CHUCVU: e.target.value })}
            >
              <option value="Quản lý">Quản lý</option>
              <option value="Thủ thư">Thủ thư</option>
              <option value="Kỹ thuật viên">Kỹ thuật viên</option>
            </select>
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Ngày vào làm</label>
            <Input 
              type="date"
              value={formData.NGVL}
              onChange={(e) => setFormData({ ...formData, NGVL: e.target.value })}
              required 
            />
          </div>
          <div className="flex gap-2 justify-end">
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Hủy
            </Button>
            <Button type="submit" disabled={loading}>
              Lưu
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
