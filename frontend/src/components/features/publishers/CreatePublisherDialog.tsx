import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Plus } from 'lucide-react';
import { publishersService } from '@/services/publishers.service';
import { toast } from 'sonner';

interface Props {
  onSuccess: () => void;
}

export function CreatePublisherDialog({ onSuccess }: Props) {
  const [open, setOpen] = useState(false);
  const [formData, setFormData] = useState({ MANXB: '', TENNXB: '', DIACHI: '', SODT: '' });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await publishersService.createPublisher(formData);
      toast.success('Thêm thành công');
      setFormData({ MANXB: '', TENNXB: '', DIACHI: '', SODT: '' });
      setOpen(false);
      onSuccess();
    } catch {
      toast.error('Lỗi khi thêm mới');
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
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Thêm Nhà xuất bản</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4 mt-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Mã NXB</label>
            <Input 
              value={formData.MANXB}
              onChange={(e) => setFormData({ ...formData, MANXB: e.target.value })}
              placeholder="VD: NXB01" 
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Tên NXB</label>
            <Input 
              value={formData.TENNXB}
              onChange={(e) => setFormData({ ...formData, TENNXB: e.target.value })}
              placeholder="Nhập tên nhà xuất bản..." 
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Địa chỉ</label>
            <Input 
              value={formData.DIACHI}
              onChange={(e) => setFormData({ ...formData, DIACHI: e.target.value })}
              placeholder="Nhập địa chỉ..." 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Số điện thoại</label>
            <Input 
              value={formData.SODT}
              onChange={(e) => setFormData({ ...formData, SODT: e.target.value })}
              placeholder="Nhập số điện thoại..." 
            />
          </div>
          <div className="flex gap-2 justify-end">
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
