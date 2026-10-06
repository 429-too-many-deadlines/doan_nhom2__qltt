import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { categoriesService } from '@/services/categories.service';
import { toast } from 'sonner';
import type { Category } from '@/types/api.types';

interface Props {
  category: Category | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSuccess: () => void;
}

export function UpdateCategoryDialog({ category, open, onOpenChange, onSuccess }: Props) {
  const [formData, setFormData] = useState({ maTl: '', tenTl: '' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (category && open) {
      setFormData({ maTl: category.MATL, tenTl: category.TENTL });
    }
  }, [category, open]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!category) return;
    
    setLoading(true);
    try {
      await categoriesService.updateCategory(formData.maTl, { TENTL: formData.tenTl });
      toast.success('Cập nhật thành công');
      onOpenChange(false);
      onSuccess();
    } catch {
      toast.error('Lỗi khi cập nhật');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Cập nhật Thể loại</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4 mt-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Mã Thể Loại</label>
            <Input 
              value={formData.maTl}
              disabled
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

