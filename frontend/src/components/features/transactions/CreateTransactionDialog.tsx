import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Plus } from 'lucide-react';
import { transactionsService } from '@/services/transactions.service';
import { toast } from 'sonner';

interface Props {
  onSuccess: () => void;
}

export function CreateTransactionDialog({ onSuccess }: Props) {
  const [open, setOpen] = useState(false);
  const [formData, setFormData] = useState({ MADG: '', MANV: '', DSMACs: '' });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const DSMACs = formData.DSMACs.split(',').map(s => s.trim()).filter(Boolean);
      await transactionsService.borrowBook({ MADG: formData.MADG, MANV: formData.MANV, DSMACs });
      toast.success('Mượn sách thành công');
      setFormData({ MADG: '', MANV: '', DSMACs: '' });
      setOpen(false);
      onSuccess();
    } catch {
      toast.error('Lỗi khi mượn sách');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button>
          <Plus className="w-4 h-4 mr-2" />
          Mượn Sách
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Thêm Phiếu Mượn Mới</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4 mt-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Mã Độc Giả</label>
            <Input 
              value={formData.MADG}
              onChange={(e) => setFormData({ ...formData, MADG: e.target.value })}
              placeholder="VD: DG01" 
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Mã Nhân Viên</label>
            <Input 
              value={formData.MANV}
              onChange={(e) => setFormData({ ...formData, MANV: e.target.value })}
              placeholder="VD: NV01" 
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Danh Sách Mã Cuốn Sách</label>
            <Input 
              value={formData.DSMACs}
              onChange={(e) => setFormData({ ...formData, DSMACs: e.target.value })}
              placeholder="VD: CS01, CS02" 
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
