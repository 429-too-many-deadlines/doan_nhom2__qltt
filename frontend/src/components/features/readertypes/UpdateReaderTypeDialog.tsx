import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { readerTypesService } from '@/services/readertypes.service';
import { toast } from 'sonner';
import type { ReaderType } from '@/types/api.types';

interface Props {
  readerType: ReaderType | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSuccess: () => void;
}

export function UpdateReaderTypeDialog({ readerType, open, onOpenChange, onSuccess }: Props) {
  const [formData, setFormData] = useState({ MALDG: '', TENLDG: '', SOSACHTOIDA: 5, SONGAYMUON: 14 });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (readerType && open) {
      setFormData({ 
        MALDG: readerType.MALDG, 
        TENLDG: readerType.TENLDG, 
        SOSACHTOIDA: readerType.SOSACHTOIDA, 
        SONGAYMUON: readerType.SONGAYMUON 
      });
    }
  }, [readerType, open]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!readerType) return;
    
    setLoading(true);
    try {
      await readerTypesService.updateReaderType(formData.MALDG, formData);
      toast.success('Cập nhật thành công');
      onOpenChange(false);
      onSuccess();
    } catch (error) {
      const err = error as { response?: { data?: { message?: string } } };
      toast.error(err.response?.data?.message || 'Lỗi thao tác');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Cập nhật Loại Độc Giả</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4 mt-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Mã LĐG</label>
            <Input 
              value={formData.MALDG}
              disabled
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
