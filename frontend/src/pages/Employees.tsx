import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { toast } from 'sonner';
import { employeesService } from '@/services/employees.service';
import { Plus, Trash2, Edit, RefreshCw } from 'lucide-react';
import type { Employee } from '@/types/api.types';

export default function Employees() {
  const [items, setItems] = useState<Employee[]>([]);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({ maNV: '', hoTen: '', ngSinh: '', soDT: '', chucVu: 'Thủ thư', ngvl: '' });
  const [isEditing, setIsEditing] = useState(false);

  const fetchItems = async () => {
    setLoading(true);
    try {
      const data = await employeesService.getEmployees();
      setItems(data);
    } catch {
      toast.error('Lỗi khi tải danh sách nhân viên');
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
      const payload = {
        ...formData,
        ngVL: formData.ngvl
      };
      if (isEditing) {
        await employeesService.updateEmployee(formData.maNV, payload);
        toast.success('Cập nhật thành công');
      } else {
        await employeesService.createEmployee(payload);
        toast.success('Thêm thành công');
      }
      setFormData({ maNV: '', hoTen: '', ngSinh: '', soDT: '', chucVu: 'Thủ thư', ngvl: '' });
      setIsEditing(false);
      fetchItems();
    } catch (error) {
      const err = error as { response?: { data?: { message?: string } } };
      toast.error(err.response?.data?.message || 'Lỗi thao tác');
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Xoá nhân viên này?')) return;
    try {
      await employeesService.deleteEmployee(id);
      toast.success('Xoá thành công');
      fetchItems();
    } catch (error) {
      const err = error as { response?: { data?: { message?: string } } };
      toast.error(err.response?.data?.message || 'Lỗi khi xoá');
    }
  };

  const handleEdit = (item: Employee) => {
    setFormData({ 
      maNV: item.maNV, 
      hoTen: item.hoTen, 
      ngSinh: item.ngSinh?.split('T')[0] || '', 
      soDT: item.soDT || '',
      chucVu: item.chucVu,
      ngvl: item.ngvl?.split('T')[0] || ''
    });
    setIsEditing(true);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold tracking-tight">Quản lý Nhân viên</h1>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-1">
          <CardHeader>
            <CardTitle>{isEditing ? 'Cập nhật' : 'Thêm mới'}</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">Mã NV</label>
                <Input value={formData.maNV} onChange={(e) => setFormData({ ...formData, maNV: e.target.value })} required disabled={isEditing} />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Họ tên</label>
                <Input value={formData.hoTen} onChange={(e) => setFormData({ ...formData, hoTen: e.target.value })} required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Ngày sinh</label>
                <Input type="date" value={formData.ngSinh} onChange={(e) => setFormData({ ...formData, ngSinh: e.target.value })} required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Số điện thoại</label>
                <Input value={formData.soDT} onChange={(e) => setFormData({ ...formData, soDT: e.target.value })} required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Chức vụ</label>
                <select 
                  className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background"
                  value={formData.chucVu} onChange={(e) => setFormData({ ...formData, chucVu: e.target.value })}
                >
                  <option value="Quản lý">Quản lý</option>
                  <option value="Thủ thư">Thủ thư</option>
                  <option value="Kỹ thuật viên">Kỹ thuật viên</option>
                </select>
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Ngày vào làm</label>
                <Input type="date" value={formData.ngvl} onChange={(e) => setFormData({ ...formData, ngvl: e.target.value })} required />
              </div>
              <div className="flex gap-2">
                <Button type="submit" className="flex-1">
                  {isEditing ? <Edit className="w-4 h-4 mr-2" /> : <Plus className="w-4 h-4 mr-2" />}
                  {isEditing ? 'Lưu' : 'Thêm'}
                </Button>
                {isEditing && (
                  <Button type="button" variant="outline" onClick={() => { setIsEditing(false); setFormData({ maNV: '', hoTen: '', ngSinh: '', soDT: '', chucVu: 'Thủ thư', ngvl: '' }); }}>Hủy</Button>
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
                    <TableHead>Họ Tên</TableHead>
                    <TableHead>SĐT</TableHead>
                    <TableHead>Chức Vụ</TableHead>
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
                      <TableRow key={item.maNV}>
                        <TableCell className="font-medium">{item.maNV}</TableCell>
                        <TableCell>{item.hoTen}</TableCell>
                        <TableCell>{item.soDT}</TableCell>
                        <TableCell>{item.chucVu}</TableCell>
                        <TableCell>
                          <div className="flex gap-2">
                            <Button size="icon" variant="outline" onClick={() => handleEdit(item)}><Edit className="w-4 h-4" /></Button>
                            <Button size="icon" variant="destructive" onClick={() => handleDelete(item.maNV)}><Trash2 className="w-4 h-4" /></Button>
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
