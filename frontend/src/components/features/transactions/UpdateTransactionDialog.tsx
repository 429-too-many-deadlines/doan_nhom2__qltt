import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { transactionsService } from '@/services/transactions.service';
import { toast } from 'sonner';
import type { BorrowSlip } from '@/types/api.types';

interface Props {
  transaction: BorrowSlip | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSuccess: () => void;
}

export function UpdateTransactionDialog({ transaction, open, onOpenChange, onSuccess }: Props) {
  const [formData, setFormData] = useState({ MAPM: '', MACS: '', TINHTRANGTRA: 'Bình thường' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (transaction && open) {
      setFormData({ 
        MAPM: transaction.MAPM, 
        MACS: transaction.MACS, 
        TINHTRANGTRA: transaction.TINHTRANGTRA || 'Bình thường' 
      });
    }
  }, [transaction, open]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!transaction) return;
    
    setLoading(true);
    try {
      await transactionsService.returnBook({
        MAPM: formData.MAPM,
        MACS: formData.MACS,
        TINHTRANGTRA: formData.TINHTRANGTRA
      });
      toast.success('Trả sách thành công');
      onOpenChange(false);
      onSuccess();
    } catch {
      toast.error('Lỗi khi trả sách');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Cập nhật Giao dịch (Trả sách)</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4 mt-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Mã Phiếu Mượn</label>
            <Input 
              value={formData.MAPM}
              disabled
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Mã Cuốn Sách</label>
            <Input 
              value={formData.MACS}
              disabled
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Tình trạng trả</label>
            <select 
              className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              value={formData.TINHTRANGTRA} 
              onChange={(e) => setFormData({...formData, TINHTRANGTRA: e.target.value})}
            >
              <option value="Bình thường">Bình thường</option>
              <option value="Hư hỏng">Hư hỏng</option>
              <option value="Mất">Mất</option>
            </select>
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
