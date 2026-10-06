import { DataTablePagination } from '../components/ui/data-table-pagination';
import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { toast } from 'sonner';
import { readerTypesService } from '@/services/readertypes.service';
import { Trash2, Edit } from 'lucide-react';
import type { ReaderType } from '@/types/api.types';
import { CreateReaderTypeDialog } from '@/components/features/readertypes/CreateReaderTypeDialog';
import { UpdateReaderTypeDialog } from '@/components/features/readertypes/UpdateReaderTypeDialog';
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

export default function ReaderTypes() {
  const [items, setItems] = useState<ReaderType[]>([]);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [selectedReaderType, setSelectedReaderType] = useState<ReaderType | null>(null);
  const [isUpdateOpen, setIsUpdateOpen] = useState(false);

  const fetchItems = async () => {
    setLoading(true);
    try {
      const dataResult = await readerTypesService.getReaderTypes(undefined, page);
      const data = dataResult.items || [];
      setTotalPages(dataResult.totalPages);
      setItems(data);
    } catch {
      toast.error('Lỗi khi tải danh sách');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchItems();
  }, [page]);

  const handleDelete = async (id: string) => {
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
    setSelectedReaderType(item);
    setIsUpdateOpen(true);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold tracking-tight">Quản lý Loại Độc Giả</h1>
      </div>

      <div className="grid grid-cols-1 gap-6">
        <Card className="col-span-1">
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle>Danh sách Loại Độc Giả</CardTitle>
            <div className="flex items-center space-x-2">
              <Input placeholder="Tìm kiếm..." className="w-64" />
              <CreateReaderTypeDialog onSuccess={fetchItems} />
            </div>
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
                      <TableRow key={item.MALDG}>
                        <TableCell className="font-medium">{item.MALDG}</TableCell>
                        <TableCell>{item.TENLDG}</TableCell>
                        <TableCell>{item.SOSACHTOIDA}</TableCell>
                        <TableCell>{item.SONGAYMUON}</TableCell>
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
                                    Hành động này không thể hoàn tác. Loại độc giả này sẽ bị xoá vĩnh viễn khỏi hệ thống.
                                  </AlertDialogDescription>
                                </AlertDialogHeader>
                                <AlertDialogFooter>
                                  <AlertDialogCancel>Hủy</AlertDialogCancel>
                                  <AlertDialogAction onClick={() => handleDelete(item.MALDG)}>Xác nhận</AlertDialogAction>
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
          </CardContent>
        </Card>
      </div>

      <UpdateReaderTypeDialog 
        readerType={selectedReaderType} 
        open={isUpdateOpen} 
        onOpenChange={setIsUpdateOpen} 
        onSuccess={fetchItems} 
      />
    </div>
  );
}
