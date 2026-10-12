import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Plus } from 'lucide-react';
import { transactionsService } from '@/services/transactions.service';
import { readersService } from '@/services/readers.service';
import { DB_LIMITS } from '@/lib/db-limits';

interface Props {
  onSuccess: () => void;
}

export function CreateTransactionDialog({ onSuccess }: Props) {
  const [open, setOpen] = useState(false);
  const [formData, setFormData] = useState({ MADG: '', DSMACs: '' });
  const [loading, setLoading] = useState(false);
  const [borrowingInfo, setBorrowingInfo] = useState('');

  // FN_SOSACHDANGMUON: cho thủ thư biết độc giả đang giữ bao nhiêu cuốn trước khi lập phiếu
  const checkBorrowingCount = async () => {
    const madg = formData.MADG.trim();
    if (!madg) return setBorrowingInfo('');
    try {
      const { soSachDangMuon } = await readersService.getBorrowingCount(madg);
      setBorrowingInfo(`Độc giả đang mượn ${soSachDangMuon} cuốn chưa trả.`);
    } catch (error) {
      setBorrowingInfo(error instanceof Error ? error.message : 'Không kiểm tra được độc giả.');
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const DSMACs = formData.DSMACs.split(',').map(s => s.trim()).filter(Boolean);
      await transactionsService.borrowBook({ MADG: formData.MADG, DSMACs });
      // toast.success('Mượn sách thành công');
      setFormData({ MADG: '', DSMACs: '' });
      setBorrowingInfo('');
      setOpen(false);
      onSuccess();
    } catch {
      // toast.error('Lỗi khi mượn sách');
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
              value={formData.MADG} maxLength={DB_LIMITS.MADG}
              onChange={(e) => {
                setFormData({ ...formData, MADG: e.target.value });
                setBorrowingInfo('');
              }}
              onBlur={checkBorrowingCount}
              placeholder="VD: DG001" 
              required 
            />
            {borrowingInfo && <p className="text-xs text-muted-foreground">{borrowingInfo}</p>}
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
