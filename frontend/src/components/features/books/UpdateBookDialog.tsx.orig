import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { booksService } from '@/services/books.service';
import type { Category, Publisher, SearchBookResponse } from '@/types/api.types';

interface Props {
  book: SearchBookResponse | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSuccess: () => void;
  categories: Category[];
  publishers: Publisher[];
}

export function UpdateBookDialog({ book, open, onOpenChange, onSuccess, categories, publishers }: Props) {
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    MADS: '',
    TENDS: '',
    MATL: '',
    MANXB: '',
    NAMXB: '',
    SOTRANG: '',
    GIA: ''
  });

  useEffect(() => {
    if (book && open) {
      setFormData({
        MADS: book.MADS || '',
        TENDS: book.TENDS || '',
        MATL: '',
        MANXB: '',
        NAMXB: '',
        SOTRANG: '',
        GIA: ''
      });
    }
  }, [book, open]);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!book || !formData.MADS) return;
    
    setLoading(true);
    
    const data = {
      TENDS: formData.TENDS,
      MATL: formData.MATL,
      MANXB: formData.MANXB,
      NAMXB: parseInt(formData.NAMXB, 10),
      SOTRANG: parseInt(formData.SOTRANG, 10),
      GIA: parseFloat(formData.GIA)
    };

    try {
      await booksService.updateBook(formData.MADS, data);
      // toast.success('Cập nhật thành công');
      onOpenChange(false);
      onSuccess();
    } catch {
      // toast.error('Lỗi khi cập nhật đầu sách');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle>Cập nhật Đầu Sách</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4 mt-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Mã Đầu Sách</label>
            <Input 
              name="MADS"
              value={formData.MADS}
              disabled
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Tên Sách Mới</label>
            <Input 
              name="TENDS"
              value={formData.TENDS}
              onChange={handleChange}
              placeholder="Tên sách mới..." 
              required 
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Thể Loại</label>
            <select 
              name="MATL"
              value={formData.MATL}
              onChange={handleChange}
              required 
              className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
            >
              <option value="">-- Chọn thể loại --</option>
              {categories.map((c) => (
                <option key={c.MATL} value={c.MATL}>{c.TENTL}</option>
              ))}
            </select>
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Nhà Xuất Bản</label>
            <select 
              name="MANXB"
              value={formData.MANXB}
              onChange={handleChange}
              required 
              className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
            >
              <option value="">-- Chọn NXB --</option>
              {publishers.map((p) => (
                <option key={p.MANXB} value={p.MANXB}>{p.TENNXB}</option>
              ))}
            </select>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <label className="text-sm font-medium">Năm Xuất Bản</label>
              <Input 
                name="NAMXB"
                type="number"
                value={formData.NAMXB}
                onChange={handleChange}
                placeholder="2023" 
                required 
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">Số Trang</label>
              <Input 
                name="SOTRANG"
                type="number"
                value={formData.SOTRANG}
                onChange={handleChange}
                placeholder="300" 
                required 
              />
            </div>
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Giá</label>
            <Input 
              name="GIA"
              type="number"
              step="1000"
              value={formData.GIA}
              onChange={handleChange}
              placeholder="150000" 
              required 
            />
          </div>
          <div className="flex gap-2 justify-end pt-4">
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
