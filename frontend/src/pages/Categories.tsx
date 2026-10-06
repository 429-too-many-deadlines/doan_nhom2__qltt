import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { toast } from 'sonner';
import { categoriesService } from '@/services/categories.service';
import { Plus, Trash2, Edit } from 'lucide-react';
import type { Category } from '@/types/api.types';

export default function Categories() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({ maTl: '', tenTl: '' });
  const [isEditing, setIsEditing] = useState(false);

  const fetchCategories = async () => {
    setLoading(true);
    try {
      const data = await categoriesService.getCategories();
      setCategories(data);
    } catch {
      toast.error('Lỗi khi tải danh sách thể loại');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCategories();
   
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (isEditing) {
        await categoriesService.updateCategory(formData.maTl, { tenTL: formData.tenTl });
        toast.success('Cập nhật thành công');
      } else {
        await categoriesService.createCategory({ maTL: formData.maTl, tenTL: formData.tenTl });
        toast.success('Thêm thành công');
      }
      setFormData({ maTl: '', tenTl: '' });
      setIsEditing(false);
      fetchCategories();
    } catch {
      toast.error(isEditing ? 'Lỗi khi cập nhật' : 'Lỗi khi thêm mới');
    }
  };

  const handleDelete = async (maTl: string) => {
    if (!window.confirm('Bạn có chắc chắn muốn xoá thể loại này?')) return;
    try {
      await categoriesService.deleteCategory(maTl);
      toast.success('Xoá thành công');
      fetchCategories();
    } catch {
      toast.error('Lỗi khi xoá. Có thể thể loại này đã có sách.');
    }
  };

  const handleEdit = (cat: Category) => {
    setFormData({ maTl: cat.maTL, tenTl: cat.tenTL });
    setIsEditing(true);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold tracking-tight">Quản lý Thể loại</h1>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="md:col-span-1">
          <CardHeader>
            <CardTitle>{isEditing ? 'Cập nhật Thể loại' : 'Thêm Thể loại'}</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">Mã Thể Loại</label>
                <Input 
                  value={formData.maTl}
                  onChange={(e) => setFormData({ ...formData, maTl: e.target.value })}
                  placeholder="VD: IT01" 
                  required 
                  disabled={isEditing}
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Tên Thể Loại</label>
                <Input 
                  value={formData.tenTl}
                  onChange={(e) => setFormData({ ...formData, tenTl: e.target.value })}
                  placeholder="Nhập tên thể loại..." 
                  required 
                />
              </div>
              <div className="flex gap-2">
                <Button type="submit" className="flex-1">
                  {isEditing ? <Edit className="w-4 h-4 mr-2" /> : <Plus className="w-4 h-4 mr-2" />}
                  {isEditing ? 'Cập nhật' : 'Thêm mới'}
                </Button>
                {isEditing && (
                  <Button type="button" variant="outline" onClick={() => { setIsEditing(false); setFormData({ maTl: '', tenTl: '' }); }}>
                    Hủy
                  </Button>
                )}
              </div>
            </form>
          </CardContent>
        </Card>

        <Card className="md:col-span-2">
          <CardHeader>
            <CardTitle>Danh sách Thể loại</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="rounded-md border">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Mã TL</TableHead>
                    <TableHead>Tên Thể Loại</TableHead>
                    <TableHead className="w-[150px]">Hành Động</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loading ? (
                    <TableRow>
                      <TableCell colSpan={3} className="text-center h-24">Đang tải...</TableCell>
                    </TableRow>
                  ) : categories.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={3} className="text-center h-24">Không có dữ liệu</TableCell>
                    </TableRow>
                  ) : (
                    categories.map((cat) => (
                      <TableRow key={cat.maTL}>
                        <TableCell className="font-medium">{cat.maTL}</TableCell>
                        <TableCell>{cat.tenTL}</TableCell>
                        <TableCell>
                          <div className="flex gap-2">
                            <Button size="icon" variant="outline" onClick={() => handleEdit(cat)}>
                              <Edit className="w-4 h-4" />
                            </Button>
                            <Button size="icon" variant="destructive" onClick={() => handleDelete(cat.maTL)}>
                              <Trash2 className="w-4 h-4" />
                            </Button>
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
