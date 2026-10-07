import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { publishersService } from '@/services/publishers.service';
import type { Publisher } from '@/types/api.types';

interface Props {
  publisher: Publisher | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSuccess: () => void;
}

export function UpdatePublisherDialog({ publisher, open, onOpenChange, onSuccess }: Props) {
  const [formData, setFormData] = useState({ MANXB: '', TENNXB: '', DIACHI: '', SODT: '' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (publisher && open) {
      setFormData({ 
        MANXB: publisher.MANXB, 
        TENNXB: publisher.TENNXB,
        DIACHI: publisher.DIACHI || '',
        SODT: publisher.SODT || ''
      });
    }
  }, [publisher, open]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!publisher) return;
    
    setLoading(true);
    try {
      await publishersService.updatePublisher(formData.MANXB, { 
        TENNXB: formData.TENNXB,
        DIACHI: formData.DIACHI,
        SODT: formData.SODT
      });
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
          <DialogTitle>Cập nhật Nhà xuất bản</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4 mt-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Mã NXB</label>
            <Input 
              value={formData.MANXB}
              disabled
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
