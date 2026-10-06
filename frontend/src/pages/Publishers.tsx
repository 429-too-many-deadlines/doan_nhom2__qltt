import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { toast } from 'sonner';
import { publishersService } from '@/services/publishers.service';
import { Plus, Trash2, Edit, Search } from 'lucide-react';
import type { Publisher } from '@/types/api.types';

export default function Publishers() {
  const [items, setItems] = useState<Publisher[]>([]);
  const [loading, setLoading] = useState(false);
  const [query, setQuery] = useState('');
  const [formData, setFormData] = useState({ maNXB: '', tenNXB: '', diaChi: '', soDT: '' });
  const [isEditing, setIsEditing] = useState(false);

  const fetchItems = async (q = '') => {
    setLoading(true);
    try {
      const data = await publishersService.getPublishers(q);
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
      if (isEditing) {
        await publishersService.updatePublisher(formData.maNXB, formData);
        toast.success('Cập nhật thành công');
      } else {
        await publishersService.createPublisher(formData);
        toast.success('Thêm thành công');
      }
      setFormData({ maNXB: '', tenNXB: '', diaChi: '', soDT: '' });
      setIsEditing(false);
      fetchItems(query);
    } catch {
      toast.error('Lỗi thao tác');
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Xoá nhà xuất bản này?')) return;
    try {
      await publishersService.deletePublisher(id);
      toast.success('Xoá thành công');
      fetchItems(query);
    } catch {
      toast.error('Lỗi khi xoá. Có thể NXB này đã có sách.');
    }
  };

  const handleEdit = (item: Publisher) => {
    setFormData({ 
      maNXB: item.maNXB, 
      tenNXB: item.tenNXB, 
      diaChi: item.diaChi || '', 
      soDT: item.soDT || '' 
    });
    setIsEditing(true);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold tracking-tight">Quản lý Nhà xuất bản</h1>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-1">
          <CardHeader>
            <CardTitle>{isEditing ? 'Cập nhật' : 'Thêm mới'}</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">Mã NXB</label>
                <Input value={formData.maNXB} onChange={(e) => setFormData({ ...formData, maNXB: e.target.value })} required disabled={isEditing} />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Tên NXB</label>
                <Input value={formData.tenNXB} onChange={(e) => setFormData({ ...formData, tenNXB: e.target.value })} required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Địa chỉ</label>
                <Input value={formData.diaChi} onChange={(e) => setFormData({ ...formData, diaChi: e.target.value })} />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Số điện thoại</label>
                <Input value={formData.soDT} onChange={(e) => setFormData({ ...formData, soDT: e.target.value })} />
              </div>
              <div className="flex gap-2">
                <Button type="submit" className="flex-1">
                  {isEditing ? <Edit className="w-4 h-4 mr-2" /> : <Plus className="w-4 h-4 mr-2" />}
                  {isEditing ? 'Lưu' : 'Thêm'}
                </Button>
                {isEditing && (
                  <Button type="button" variant="outline" onClick={() => { setIsEditing(false); setFormData({ maNXB: '', tenNXB: '', diaChi: '', soDT: '' }); }}>Hủy</Button>
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
                    <TableHead>Mã NXB</TableHead>
                    <TableHead>Tên NXB</TableHead>
                    <TableHead>Địa chỉ</TableHead>
                    <TableHead>SĐT</TableHead>
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
                      <TableRow key={item.maNXB}>
                        <TableCell className="font-medium">{item.maNXB}</TableCell>
                        <TableCell>{item.tenNXB}</TableCell>
                        <TableCell>{item.diaChi}</TableCell>
                        <TableCell>{item.soDT}</TableCell>
                        <TableCell>
                          <div className="flex gap-2">
                            <Button size="icon" variant="outline" onClick={() => handleEdit(item)}><Edit className="w-4 h-4" /></Button>
                            <Button size="icon" variant="destructive" onClick={() => handleDelete(item.maNXB)}><Trash2 className="w-4 h-4" /></Button>
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
