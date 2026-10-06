import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Plus } from 'lucide-react';
import { booksService } from '@/services/books.service';
import { toast } from 'sonner';
import type { Category, Publisher } from '@/types/api.types';

interface Props {
  onSuccess: () => void;
  categories: Category[];
  publishers: Publisher[];
}

export function CreateBookDialog({ onSuccess, categories, publishers }: Props) {
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);
    
    const formData = new FormData(e.currentTarget);
    const data = {
      MADS: formData.get('maDs') as string,
      TENDS: formData.get('tenDs') as string,
      MATL: formData.get('maTl') as string,
      MANXB: formData.get('maNxb') as string,
      NAMXB: parseInt(formData.get('namXb') as string, 10),
      SOTRANG: parseInt(formData.get('SOTRANG') as string, 10),
      GIA: parseFloat(formData.get('GIA') as string),
    };

    if (!data.MADS) {
      toast.error('Vui lòng nhập mã đầu sách');
      setLoading(false);
      return;
    }

    try {
      await booksService.createBook(data);
      toast.success('Thêm đầu sách thành công');
      setOpen(false);
      onSuccess();
    } catch {
      toast.error('Lỗi khi thêm đầu sách');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button>
          <Plus className="w-4 h-4 mr-2" />
          Thêm Đầu Sách
        </Button>
      </DialogTrigger>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle>Thêm Đầu Sách</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4 mt-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Mã Đầu Sách</label>
            <Input name="maDs" placeholder="VD: DS001" required />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Tên Sách</label>
            <Input name="tenDs" placeholder="Tên sách mới..." required />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Thể Loại</label>
            <select name="maTl" required className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50">
              <option value="">-- Chọn thể loại --</option>
              {categories.map((c) => (
                <option key={c.MATL} value={c.MATL}>{c.TENTL}</option>
              ))}
            </select>
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Nhà Xuất Bản</label>
            <select name="maNxb" required className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50">
              <option value="">-- Chọn NXB --</option>
              {publishers.map((p) => (
                <option key={p.MANXB} value={p.MANXB}>{p.TENNXB}</option>
              ))}
            </select>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <label className="text-sm font-medium">Năm Xuất Bản</label>
              <Input name="namXb" type="number" placeholder="2023" required />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">Số Trang</label>
              <Input name="SOTRANG" type="number" placeholder="300" required />
            </div>
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Giá</label>
            <Input name="GIA" type="number" step="1000" placeholder="150000" required />
          </div>
          <div className="flex gap-2 justify-end pt-4">
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
