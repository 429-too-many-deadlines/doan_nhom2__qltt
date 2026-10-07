import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Plus } from 'lucide-react';
import { authorsService } from '@/services/authors.service';

interface Props {
  onSuccess: () => void;
}

export function CreateAuthorDialog({ onSuccess }: Props) {
  const [open, setOpen] = useState(false);
  const [formData, setFormData] = useState({ MATG: '', TENTG: '', NAMSINH: '', QUOCTICH: '' });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const payload = {
        ...formData,
        NAMSINH: formData.NAMSINH ? parseInt(formData.NAMSINH) : null,
      };
      await authorsService.createAuthor(payload);
      // toast.success('Thêm thành công');
      setFormData({ MATG: '', TENTG: '', NAMSINH: '', QUOCTICH: '' });
      setOpen(false);
      onSuccess();
    } catch {
      // toast.error('Lỗi khi thêm mới');
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
          <DialogTitle>Thêm Tác giả</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4 mt-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Mã Tác Giả</label>
            <Input 
              value={formData.MATG}
              onChange={(e) => setFormData({ ...formData, MATG: e.target.value })}
              placeholder="VD: TG01" 
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Tên Tác Giả</label>
            <Input 
              value={formData.TENTG}
              onChange={(e) => setFormData({ ...formData, TENTG: e.target.value })}
              placeholder="Nhập tên tác giả..." 
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Năm Sinh</label>
            <Input 
              type="number"
              value={formData.NAMSINH}
              onChange={(e) => setFormData({ ...formData, NAMSINH: e.target.value })}
              placeholder="VD: 1990" 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Quốc Tịch</label>
            <Input 
              value={formData.QUOCTICH}
              onChange={(e) => setFormData({ ...formData, QUOCTICH: e.target.value })}
              placeholder="VD: Việt Nam" 
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
