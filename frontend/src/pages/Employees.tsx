import { DataTablePagination } from '../components/ui/data-table-pagination';
import { useEffect, useState } from 'react';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { employeesService } from '@/services/employees.service';
import { Trash2, Edit } from 'lucide-react';
import type { Employee } from '@/types/api.types';
import { CreateEmployeeDialog } from '@/components/features/employees/CreateEmployeeDialog';
import { UpdateEmployeeDialog } from '@/components/features/employees/UpdateEmployeeDialog';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";

export default function Employees() {
  const [items, setItems] = useState<Employee[]>([]);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [selectedEmployee, setSelectedEmployee] = useState<Employee | null>(null);
  const [isUpdateOpen, setIsUpdateOpen] = useState(false);

  const fetchItems = async () => {
    setLoading(true);
    try {
      const dataResult = await employeesService.getEmployees(page, 10);
      const data = dataResult.items || [];
      setTotalPages(dataResult.totalPages);
      setItems(data);
    } catch {
      // toast.error('Lỗi khi tải danh sách nhân viên');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchItems();
  }, [page]);

  const handleDelete = async (MANV: string) => {
    try {
      await employeesService.deleteEmployee(MANV);
      // toast.success('Xoá thành công');
      fetchItems();
    } catch (_error: any) {
      // toast.error(error.response?.data?.message || 'Lỗi khi xoá nhân viên');
    }
  };

  const handleEdit = (item: Employee) => {
    setSelectedEmployee(item);
    setIsUpdateOpen(true);
  };

  return (
    <div className="space-y-6 p-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold tracking-tight">Quản lý Nhân viên</h1>
      </div>

      <div className="grid grid-cols-1 gap-6">
        <div className="col-span-1">
          <div className="flex flex-row items-center justify-between mb-4">
            <h2 className="text-xl font-semibold">Danh sách Nhân viên</h2>
            <div className="flex items-center space-x-2">
              <Input placeholder="Tìm kiếm..." className="w-64" />
              <CreateEmployeeDialog onSuccess={fetchItems} />
            </div>
          </div>
          <div>
            <div className="rounded-md border overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Mã NV</TableHead>
                    <TableHead>Họ Tên</TableHead>
                    <TableHead>SĐT</TableHead>
                    <TableHead>Chức Vụ</TableHead>
                    <TableHead className="w-[150px]">Hành Động</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loading ? (
                    <TableRow>
                      <TableCell colSpan={5} className="text-center h-24">Đang tải...</TableCell>
                    </TableRow>
                  ) : items.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={5} className="text-center h-24">Không có dữ liệu</TableCell>
                    </TableRow>
                  ) : (
                    items.map((item) => (
                      <TableRow key={item.MANV}>
                        <TableCell className="font-medium">{item.MANV}</TableCell>
                        <TableCell>{item.HOTEN}</TableCell>
                        <TableCell>{item.SODT}</TableCell>
                        <TableCell>{item.CHUCVU}</TableCell>
                        <TableCell>
                          <div className="flex gap-2">
                            <Button size="icon" variant="outline" onClick={() => handleEdit(item)}>
                              <Edit className="w-4 h-4" />
                            </Button>
                            <AlertDialog>
                              <AlertDialogTrigger asChild>
                                <Button size="icon" variant="destructive">
                                  <Trash2 className="w-4 h-4" />
                                </Button>
                              </AlertDialogTrigger>
                              <AlertDialogContent>
                                <AlertDialogHeader>
                                  <AlertDialogTitle>Bạn có chắc chắn muốn xoá?</AlertDialogTitle>
                                  <AlertDialogDescription>
                                    Hành động này không thể hoàn tác. Nhân viên này sẽ bị xoá vĩnh viễn khỏi hệ thống.
                                  </AlertDialogDescription>
                                </AlertDialogHeader>
                                <AlertDialogFooter>
                                  <AlertDialogCancel>Hủy</AlertDialogCancel>
                                  <AlertDialogAction onClick={() => handleDelete(item.MANV)}>Xác nhận</AlertDialogAction>
                                </AlertDialogFooter>
                              </AlertDialogContent>
                            </AlertDialog>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
          </div>
          <DataTablePagination page={page} totalPages={totalPages} onPageChange={setPage} />
          </div>
        </div>
      </div>

      <UpdateEmployeeDialog 
        employee={selectedEmployee} 
        open={isUpdateOpen} 
        onOpenChange={setIsUpdateOpen} 
        onSuccess={fetchItems} 
      />
    </div>
  );
}
