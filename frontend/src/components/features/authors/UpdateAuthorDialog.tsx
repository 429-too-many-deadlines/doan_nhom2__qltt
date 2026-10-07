import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { authorsService } from '@/services/authors.service';
import type { Author } from '@/types/api.types';

interface Props {
  author: Author | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSuccess: () => void;
}

export function UpdateAuthorDialog({ author, open, onOpenChange, onSuccess }: Props) {
  const [formData, setFormData] = useState({ MATG: '', TENTG: '', NAMSINH: '', QUOCTICH: '' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (author && open) {
      setFormData({ 
        MATG: author.MATG, 
        TENTG: author.TENTG, 
        NAMSINH: author.NAMSINH?.toString() || '', 
        QUOCTICH: author.QUOCTICH || '' 
      });
    }
  }, [author, open]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!author) return;
    
    setLoading(true);
    try {
      const payload = {
        TENTG: formData.TENTG,
        NAMSINH: formData.NAMSINH ? parseInt(formData.NAMSINH) : null,
        QUOCTICH: formData.QUOCTICH || null,
      };
      await authorsService.updateAuthor(formData.MATG, payload);
      // toast.success('Cập nhật thành công');
      onOpenChange(false);
      onSuccess();
    } catch {
      // toast.error('Lỗi khi cập nhật');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Cập nhật Tác giả</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4 mt-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Mã Tác Giả</label>
            <Input 
              value={formData.MATG}
              disabled
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
