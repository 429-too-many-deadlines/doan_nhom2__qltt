import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Plus } from 'lucide-react';
import { readerTypesService } from '@/services/readertypes.service';
import { toast } from 'sonner';

interface Props {
  onSuccess: () => void;
}

export function CreateReaderTypeDialog({ onSuccess }: Props) {
  const [open, setOpen] = useState(false);
  const [formData, setFormData] = useState({ MALDG: '', TENLDG: '', SOSACHTOIDA: 5, SONGAYMUON: 14 });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await readerTypesService.createReaderType(formData);
      toast.success('Thêm thành công');
      setFormData({ MALDG: '', TENLDG: '', SOSACHTOIDA: 5, SONGAYMUON: 14 });
      setOpen(false);
      onSuccess();
    } catch (error) {
      const err = error as { response?: { data?: { message?: string } } };
      toast.error(err.response?.data?.message || 'Lỗi thao tác');
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
          <DialogTitle>Thêm Loại Độc Giả</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4 mt-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Mã LĐG (2 ký tự)</label>
            <Input 
              value={formData.MALDG}
              onChange={(e) => setFormData({ ...formData, MALDG: e.target.value })}
              maxLength={2}
              placeholder="VD: VIP" 
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Tên Loại</label>
            <Input 
              value={formData.TENLDG}
              onChange={(e) => setFormData({ ...formData, TENLDG: e.target.value })}
              placeholder="Nhập tên loại độc giả..." 
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Số sách tối đa</label>
            <Input 
              type="number"
              value={formData.SOSACHTOIDA}
              onChange={(e) => setFormData({ ...formData, SOSACHTOIDA: parseInt(e.target.value) || 0 })}
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Số ngày mượn</label>
            <Input 
              type="number"
              value={formData.SONGAYMUON}
              onChange={(e) => setFormData({ ...formData, SONGAYMUON: parseInt(e.target.value) || 0 })}
              required 
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
