import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Plus } from 'lucide-react';
import { readersService } from '@/services/readers.service';
import { toast } from 'sonner';

interface Props {
  onSuccess: () => void;
}

export function CreateReaderDialog({ onSuccess }: Props) {
  const [open, setOpen] = useState(false);
  const [formData, setFormData] = useState({
    MADG: '',
    HOTEN: '',
    NGSINH: '',
    GIOITINH: '',
    DIACHI: '',
    SODT: '',
    EMAIL: '',
  });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.MADG) {
      toast.error('Vui lòng nhập mã độc giả');
      return;
    }
    setLoading(true);
    try {
      await readersService.createReader({
        ...formData,
        DIACHI: formData.DIACHI || null,
        EMAIL: formData.EMAIL || null,
      });
      // toast.success('Thêm độc giả thành công');
      setFormData({
        MADG: '',
        HOTEN: '',
        NGSINH: '',
        GIOITINH: '',
        DIACHI: '',
        SODT: '',
        EMAIL: '',
      });
      setOpen(false);
      onSuccess();
    } catch {
      // toast.error('Lỗi khi thêm độc giả');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button>
          <Plus className="w-4 h-4 mr-2" />
          Thêm mới
        </Button>
      </DialogTrigger>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>Thêm Độc Giả Mới</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Mã Độc Giả</label>
            <Input 
              value={formData.MADG}
              onChange={(e) => setFormData({ ...formData, MADG: e.target.value })}
              placeholder="VD: DG001" 
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Họ Tên</label>
            <Input 
              value={formData.HOTEN}
              onChange={(e) => setFormData({ ...formData, HOTEN: e.target.value })}
              placeholder="Nguyễn Văn A" 
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Ngày Sinh</label>
            <Input 
              type="date"
              value={formData.NGSINH}
              onChange={(e) => setFormData({ ...formData, NGSINH: e.target.value })}
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Giới Tính</label>
            <Input 
              value={formData.GIOITINH}
              onChange={(e) => setFormData({ ...formData, GIOITINH: e.target.value })}
              placeholder="Nam/Nữ" 
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Số Điện Thoại</label>
            <Input 
              value={formData.SODT}
              onChange={(e) => setFormData({ ...formData, SODT: e.target.value })}
              placeholder="090..." 
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Địa Chỉ</label>
            <Input 
              value={formData.DIACHI}
              onChange={(e) => setFormData({ ...formData, DIACHI: e.target.value })}
              placeholder="Địa chỉ..." 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Email</label>
            <Input 
              type="EMAIL"
              value={formData.EMAIL}
              onChange={(e) => setFormData({ ...formData, EMAIL: e.target.value })}
              placeholder="EMAIL@..." 
            />
          </div>
          <div className="flex gap-2 justify-end md:col-span-2 mt-4">
            <Button type="button" variant="outline" onClick={() => setOpen(false)}>
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
