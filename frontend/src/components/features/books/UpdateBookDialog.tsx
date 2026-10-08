import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { booksService } from '@/services/books.service';
import type { Category, Publisher, SearchBookResponse } from '@/types/api.types';
import { AsyncCombobox } from '@/components/ui/async-combobox';
import { categoriesService } from '@/services/categories.service';
import { publishersService } from '@/services/publishers.service';

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
        MATL: book.MATL || '',
        MANXB: book.MANXB || '',
        NAMXB: book.NAMXB?.toString() || '',
        SOTRANG: book.SOTRANG?.toString() || '',
        GIA: book.GIA?.toString() || ''
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

  const fetchCategories = async (query: string) => {
    const res = await categoriesService.getCategories(query);
    return res.Items.map((c: any) => ({ value: c.MATL, label: c.TENTL }));
  };

  const fetchPublishers = async (query: string) => {
    const res = await publishersService.getPublishers(query);
    return res.Items.map((p: any) => ({ value: p.MANXB, label: p.TENNXB }));
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
            <AsyncCombobox
              value={formData.MATL}
              onChange={(val) => setFormData(prev => ({ ...prev, MATL: val }))}
              fetcher={fetchCategories}
              defaultOptions={categories.map(c => ({ value: c.MATL, label: c.TENTL }))}
              placeholder="-- Chọn thể loại --"
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">Nhà Xuất Bản</label>
            <AsyncCombobox
              value={formData.MANXB}
              onChange={(val) => setFormData(prev => ({ ...prev, MANXB: val }))}
              fetcher={fetchPublishers}
              defaultOptions={publishers.map(p => ({ value: p.MANXB, label: p.TENNXB }))}
              placeholder="-- Chọn NXB --"
            />
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
