import { DataTablePagination } from '../components/ui/data-table-pagination';
import { useEffect, useState, useCallback } from 'react';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { publishersService } from '@/services/publishers.service';
import { Trash2, Edit, Search } from 'lucide-react';
import type { Publisher } from '@/types/api.types';
import { CreatePublisherDialog } from '@/components/features/publishers/CreatePublisherDialog';
import { UpdatePublisherDialog } from '@/components/features/publishers/UpdatePublisherDialog';
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

export default function Publishers() {
  const [items, setItems] = useState<Publisher[]>([]);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [query, setQuery] = useState('');
  
  const [selectedPublisher, setSelectedPublisher] = useState<Publisher | null>(null);
  const [isUpdateOpen, setIsUpdateOpen] = useState(false);

  const fetchItems = useCallback(async () => {
    setLoading(true);
    try {
      const dataResult = await publishersService.getPublishers(query || undefined, page, 10);
      const data = dataResult.items || [];
      setTotalPages(dataResult.totalPages);
      setItems(data);
    } catch {
      // toast.error('Lỗi khi tải danh sách');
    } finally {
      setLoading(false);
    }
  }, [query, page]);

  useEffect(() => {
    const timer = setTimeout(() => {
      fetchItems();
    }, 300);
    return () => clearTimeout(timer);
  }, [fetchItems]);

  const handleDelete = async (id: string) => {
    try {
      await publishersService.deletePublisher(id);
      // toast.success('Xoá thành công');
      fetchItems();
    } catch {
      // toast.error('Lỗi khi xoá. Có thể NXB này đã có sách.');
    }
  };

  const handleEdit = (item: Publisher) => {
    setSelectedPublisher(item);
    setIsUpdateOpen(true);
  };

  return (
    <div className="space-y-6 p-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold tracking-tight">Quản lý Nhà xuất bản</h1>
      </div>

      <div className="grid grid-cols-1 gap-6">
        <div className="col-span-1">
          <div className="flex flex-row items-center justify-between mb-4">
            <h2 className="text-xl font-semibold">Danh sách Nhà xuất bản</h2>
            <div className="flex items-center space-x-2">
              <div className="relative">
                <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                <Input 
                  placeholder="Tìm kiếm..." 
                  className="w-64 pl-8" 
                  value={query}
                  onChange={(e) => {
                    setQuery(e.target.value);
                    setPage(1);
                  }}
                />
              </div>
              <CreatePublisherDialog onSuccess={fetchItems} />
            </div>
          </div>
          <div>
            <div className="rounded-md border">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Mã NXB</TableHead>
                    <TableHead>Tên NXB</TableHead>
                    <TableHead>Địa chỉ</TableHead>
                    <TableHead>SĐT</TableHead>
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
                      <TableRow key={item.MANXB || (item as any).manxb}>
                        <TableCell className="font-medium font-mono text-xs">{item.MANXB || (item as any).manxb || '-'}</TableCell>
                        <TableCell className="font-medium">{item.TENNXB || (item as any).tennxb || '-'}</TableCell>
                        <TableCell>{item.DIACHI || (item as any).diachi || '-'}</TableCell>
                        <TableCell>{item.SODT || (item as any).sodt || '-'}</TableCell>
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
                                    Hành động này không thể hoàn tác. Nhà xuất bản này sẽ bị xoá vĩnh viễn khỏi hệ thống.
                                  </AlertDialogDescription>
                                </AlertDialogHeader>
                                <AlertDialogFooter>
                                  <AlertDialogCancel>Hủy</AlertDialogCancel>
                                  <AlertDialogAction onClick={() => handleDelete(item.MANXB)}>Xác nhận</AlertDialogAction>
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

      <UpdatePublisherDialog 
        publisher={selectedPublisher} 
        open={isUpdateOpen} 
        onOpenChange={setIsUpdateOpen} 
        onSuccess={fetchItems} 
      />
    </div>
  );
}
