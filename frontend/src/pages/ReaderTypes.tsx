import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { toast } from 'sonner';
import { readerTypesService } from '@/services/readertypes.service';
import { Plus, Trash2, Edit, RefreshCw } from 'lucide-react';
import type { ReaderType } from '@/types/api.types';

export default function ReaderTypes() {
  const [items, setItems] = useState<ReaderType[]>([]);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({ maLDG: '', tenLDG: '', soSachToiDa: 5, soNgayMuon: 14 });
  const [isEditing, setIsEditing] = useState(false);

  const fetchItems = async () => {
    setLoading(true);
    try {
      const data = await readerTypesService.getReaderTypes();
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

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (isEditing) {
        await readerTypesService.updateReaderType(formData.maLDG, formData);
        toast.success('Cập nhật thành công');
      } else {
        await readerTypesService.createReaderType(formData);
        toast.success('Thêm thành công');
      }
      setFormData({ maLDG: '', tenLDG: '', soSachToiDa: 5, soNgayMuon: 14 });
      setIsEditing(false);
      fetchItems();
    } catch (error) {
      const err = error as { response?: { data?: { message?: string } } };
      toast.error(err.response?.data?.message || 'Lỗi thao tác');
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Xoá loại độc giả này?')) return;
    try {
      await readerTypesService.deleteReaderType(id);
      toast.success('Xoá thành công');
      fetchItems();
    } catch (error) {
      const err = error as { response?: { data?: { message?: string } } };
      toast.error(err.response?.data?.message || 'Lỗi khi xoá');
    }
  };

  const handleEdit = (item: ReaderType) => {
    setFormData({ 
      maLDG: item.maLDG, 
      tenLDG: item.tenLDG, 
      soSachToiDa: item.soSachToiDa, 
      soNgayMuon: item.soNgayMuon 
    });
    setIsEditing(true);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold tracking-tight">Loại Độc Giả</h1>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-1">
          <CardHeader>
            <CardTitle>{isEditing ? 'Cập nhật' : 'Thêm mới'}</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">Mã LĐG (2 ký tự)</label>
                <Input value={formData.maLDG} onChange={(e) => setFormData({ ...formData, maLDG: e.target.value })} maxLength={2} required disabled={isEditing} />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Tên Loại</label>
                <Input value={formData.tenLDG} onChange={(e) => setFormData({ ...formData, tenLDG: e.target.value })} required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Số sách tối đa</label>
                <Input type="number" value={formData.soSachToiDa} onChange={(e) => setFormData({ ...formData, soSachToiDa: parseInt(e.target.value) })} required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Số ngày mượn</label>
                <Input type="number" value={formData.soNgayMuon} onChange={(e) => setFormData({ ...formData, soNgayMuon: parseInt(e.target.value) })} required />
              </div>
              <div className="flex gap-2">
                <Button type="submit" className="flex-1">
                  {isEditing ? <Edit className="w-4 h-4 mr-2" /> : <Plus className="w-4 h-4 mr-2" />}
                  {isEditing ? 'Lưu' : 'Thêm'}
                </Button>
                {isEditing && (
                  <Button type="button" variant="outline" onClick={() => { setIsEditing(false); setFormData({ maLDG: '', tenLDG: '', soSachToiDa: 5, soNgayMuon: 14 }); }}>Hủy</Button>
                )}
              </div>
            </form>
          </CardContent>
        </Card>

        <Card className="lg:col-span-2">
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle>Danh sách</CardTitle>
            <Button variant="outline" size="sm" onClick={fetchItems}><RefreshCw className="w-4 h-4 mr-2"/>Làm mới</Button>
          </CardHeader>
          <CardContent>
            <div className="rounded-md border overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Mã</TableHead>
                    <TableHead>Tên Loại</TableHead>
                    <TableHead>Sách tối đa</TableHead>
                    <TableHead>Ngày mượn</TableHead>
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
                      <TableRow key={item.maLDG}>
                        <TableCell className="font-medium">{item.maLDG}</TableCell>
                        <TableCell>{item.tenLDG}</TableCell>
                        <TableCell>{item.soSachToiDa}</TableCell>
                        <TableCell>{item.soNgayMuon}</TableCell>
                        <TableCell>
                          <div className="flex gap-2">
                            <Button size="icon" variant="outline" onClick={() => handleEdit(item)}><Edit className="w-4 h-4" /></Button>
                            <Button size="icon" variant="destructive" onClick={() => handleDelete(item.maLDG)}><Trash2 className="w-4 h-4" /></Button>
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
