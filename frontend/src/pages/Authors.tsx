import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { toast } from 'sonner';
import { authorsService } from '@/services/authors.service';
import { Plus, Trash2, Edit, Search } from 'lucide-react';
import type { Author } from '@/types/api.types';

export default function Authors() {
  const [items, setItems] = useState<Author[]>([]);
  const [loading, setLoading] = useState(false);
  const [query, setQuery] = useState('');
  const [formData, setFormData] = useState({ maTG: '', tenTG: '', namSinh: '', quocTich: '' });
  const [isEditing, setIsEditing] = useState(false);

  const fetchItems = async (q = '') => {
    setLoading(true);
    try {
      const data = await authorsService.getAuthors(q);
      setItems(data);
    } catch {
      toast.error('Lỗi khi tải danh sách');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchItems();
   
  }, []);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    fetchItems(query);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const payload = {
        ...formData,
        namSinh: formData.namSinh ? parseInt(formData.namSinh) : null,
      };
      if (isEditing) {
        await authorsService.updateAuthor(formData.maTG, payload);
        toast.success('Cập nhật thành công');
      } else {
        await authorsService.createAuthor(payload);
        toast.success('Thêm thành công');
      }
      setFormData({ maTG: '', tenTG: '', namSinh: '', quocTich: '' });
      setIsEditing(false);
      fetchItems(query);
    } catch {
      toast.error('Lỗi thao tác');
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Xoá tác giả này?')) return;
    try {
      await authorsService.deleteAuthor(id);
      toast.success('Xoá thành công');
      fetchItems(query);
    } catch {
      toast.error('Lỗi khi xoá. Có thể đang được sử dụng.');
    }
  };

  const handleEdit = (item: Author) => {
    setFormData({ 
      maTG: item.maTG, 
      tenTG: item.tenTG, 
      namSinh: item.namSinh?.toString() || '', 
      quocTich: item.quocTich || '' 
    });
    setIsEditing(true);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold tracking-tight">Quản lý Tác giả</h1>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-1">
          <CardHeader>
            <CardTitle>{isEditing ? 'Cập nhật' : 'Thêm mới'}</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">Mã TG</label>
                <Input value={formData.maTG} onChange={(e) => setFormData({ ...formData, maTG: e.target.value })} required disabled={isEditing} />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Tên TG</label>
                <Input value={formData.tenTG} onChange={(e) => setFormData({ ...formData, tenTG: e.target.value })} required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Năm sinh</label>
                <Input type="number" value={formData.namSinh} onChange={(e) => setFormData({ ...formData, namSinh: e.target.value })} />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Quốc tịch</label>
                <Input value={formData.quocTich} onChange={(e) => setFormData({ ...formData, quocTich: e.target.value })} />
              </div>
              <div className="flex gap-2">
                <Button type="submit" className="flex-1">
                  {isEditing ? <Edit className="w-4 h-4 mr-2" /> : <Plus className="w-4 h-4 mr-2" />}
                  {isEditing ? 'Lưu' : 'Thêm'}
                </Button>
                {isEditing && (
                  <Button type="button" variant="outline" onClick={() => { setIsEditing(false); setFormData({ maTG: '', tenTG: '', namSinh: '', quocTich: '' }); }}>Hủy</Button>
                )}
              </div>
            </form>
          </CardContent>
        </Card>

        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Danh sách</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSearch} className="flex gap-2 mb-4">
              <Input placeholder="Tìm theo mã, tên..." value={query} onChange={(e) => setQuery(e.target.value)} className="max-w-sm" />
              <Button type="submit"><Search className="w-4 h-4 mr-2" />Tìm</Button>
            </form>

            <div className="rounded-md border overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Mã</TableHead>
                    <TableHead>Tên</TableHead>
                    <TableHead>Năm Sinh</TableHead>
                    <TableHead>Quốc Tịch</TableHead>
                    <TableHead>Hành Động</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loading ? (
                    <TableRow><TableCell colSpan={5} className="text-center h-24">Đang tải...</TableCell></TableRow>
                  ) : items.length === 0 ? (
                    <TableRow><TableCell colSpan={5} className="text-center h-24">Không có dữ liệu</TableCell></TableRow>
                  ) : (
                    items.map((item) => (
                      <TableRow key={item.maTG}>
                        <TableCell className="font-medium">{item.maTG}</TableCell>
                        <TableCell>{item.tenTG}</TableCell>
                        <TableCell>{item.namSinh}</TableCell>
                        <TableCell>{item.quocTich}</TableCell>
                        <TableCell>
                          <div className="flex gap-2">
                            <Button size="icon" variant="outline" onClick={() => handleEdit(item)}><Edit className="w-4 h-4" /></Button>
                            <Button size="icon" variant="destructive" onClick={() => handleDelete(item.maTG)}><Trash2 className="w-4 h-4" /></Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
