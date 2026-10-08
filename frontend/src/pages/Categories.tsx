import { DataTablePagination } from '../components/ui/data-table-pagination';
import { useEffect, useState } from 'react';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { categoriesService } from '@/services/categories.service';
import { Trash2, Edit } from 'lucide-react';
import type { Category } from '@/types/api.types';
import { CreateCategoryDialog } from '@/components/features/categories/CreateCategoryDialog';
import { UpdateCategoryDialog } from '@/components/features/categories/UpdateCategoryDialog';
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

export default function Categories() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [selectedCategory, setSelectedCategory] = useState<Category | null>(null);
  const [isUpdateOpen, setIsUpdateOpen] = useState(false);

  const fetchCategories = async () => {
    setLoading(true);
    try {
      const dataResult = await categoriesService.getCategories('', page, 10);
      const data = dataResult.items || [];
      setTotalPages(dataResult.totalPages);
      setCategories(data);
    } catch {
      // toast.error('Lỗi khi tải danh sách thể loại');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCategories();
  }, [page]);

  const handleDelete = async (maTl: string) => {
    try {
      await categoriesService.deleteCategory(maTl);
      // toast.success('Xoá thành công');
      fetchCategories();
    } catch {
      // toast.error('Lỗi khi xoá. Có thể thể loại này đã có sách.');
    }
  };

  const handleEdit = (cat: Category) => {
    setSelectedCategory(cat);
    setIsUpdateOpen(true);
  };

  return (
    <div className="space-y-6 p-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold tracking-tight">Quản lý Thể loại</h1>
      </div>

      <div className="grid grid-cols-1 gap-6">
        <div className="col-span-1">
          <div className="flex flex-row items-center justify-between mb-4">
            <h2 className="text-xl font-semibold">Danh sách Thể loại</h2>
            <div className="flex items-center space-x-2">
              <Input placeholder="Tìm kiếm..." className="w-64" />
              <CreateCategoryDialog onSuccess={fetchCategories} />
            </div>
          </div>
          <div>
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
                      <TableRow key={cat.MATL}>
                        <TableCell className="font-medium">{cat.MATL}</TableCell>
                        <TableCell>{cat.TENTL}</TableCell>
                        <TableCell>
                          <div className="flex gap-2">
                            <Button size="icon" variant="outline" onClick={() => handleEdit(cat)}>
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
                                    Hành động này không thể hoàn tác. Thể loại này sẽ bị xoá vĩnh viễn khỏi hệ thống.
                                  </AlertDialogDescription>
                                </AlertDialogHeader>
                                <AlertDialogFooter>
                                  <AlertDialogCancel>Hủy</AlertDialogCancel>
                                  <AlertDialogAction onClick={() => handleDelete(cat.MATL)}>Xác nhận</AlertDialogAction>
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

      <UpdateCategoryDialog 
        category={selectedCategory} 
        open={isUpdateOpen} 
        onOpenChange={setIsUpdateOpen} 
        onSuccess={fetchCategories} 
      />
    </div>
  );
}
