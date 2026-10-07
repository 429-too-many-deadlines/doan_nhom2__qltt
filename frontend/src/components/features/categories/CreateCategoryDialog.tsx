import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Plus } from 'lucide-react';
import { categoriesService } from '@/services/categories.service';

interface Props {
  onSuccess: () => void;
}

export function CreateCategoryDialog({ onSuccess }: Props) {
  const [open, setOpen] = useState(false);
  const [formData, setFormData] = useState({ maTl: '', tenTl: '' });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await categoriesService.createCategory({ MATL: formData.maTl, TENTL: formData.tenTl });
      // toast.success('Thêm thành công');
      setFormData({ maTl: '', tenTl: '' });
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
          <DialogTitle>Thêm Thể loại</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4 mt-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Mã Thể Loại</label>
            <Input 
              value={formData.maTl}
              onChange={(e) => setFormData({ ...formData, maTl: e.target.value })}
              placeholder="VD: IT01" 
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Tên Thể Loại</label>
            <Input 
              value={formData.tenTl}
              onChange={(e) => setFormData({ ...formData, tenTl: e.target.value })}
              placeholder="Nhập tên thể loại..." 
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

