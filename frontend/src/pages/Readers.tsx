import { DataTablePagination } from '../components/ui/data-table-pagination';
import { useState, useEffect } from 'react';
import { readersService } from '../services/readers.service';
import type { Reader } from '../types/api.types';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../components/ui/table';

import { Input } from '../components/ui/input';
import { Button } from '../components/ui/button';
import { Trash2, Edit } from 'lucide-react';
import { CreateReaderDialog } from '@/components/features/readers/CreateReaderDialog';
import { UpdateReaderDialog } from '@/components/features/readers/UpdateReaderDialog';
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

export default function Readers() {
  const [readers, setReaders] = useState<Reader[]>([]);
  const [loadingReaders, setLoadingReaders] = useState(false);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [searchReaderQuery, setSearchReaderQuery] = useState('');
  
  const [selectedReader, setSelectedReader] = useState<Reader | null>(null);
  const [isUpdateOpen, setIsUpdateOpen] = useState(false);

  const fetchReaders = async () => {
    try {
      setLoadingReaders(true);
      const dataResult = await readersService.searchReaders(searchReaderQuery, page);
      const data = dataResult.items || [];
      setTotalPages(dataResult.totalPages || 1);
      setReaders(data || []);
    } catch (error) {
      console.error(error);
      // toast.error('Lỗi khi tải danh sách độc giả');
    } finally {
      setLoadingReaders(false);
    }
  };

  useEffect(() => {
    fetchReaders();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [page]);

  const handleSearchReaders = (e: React.FormEvent) => {
    e.preventDefault();
    if (page !== 1) {
      setPage(1);
    } else {
      fetchReaders();
    }
  };

  const handleDeleteReader = async (MADG: string) => {
    try {
      await readersService.deleteReader(MADG);
      // toast.success('Xóa độc giả thành công');
      fetchReaders();
    } catch (err) {
      // toast.error('Lỗi khi xóa độc giả (có thể độc giả đã mượn sách)');
      console.error(err);
    }
  };

  const handleEdit = (reader: Reader) => {
    setSelectedReader(reader);
    setIsUpdateOpen(true);
  };

  return (
    <div className="space-y-6 p-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold tracking-tight">Quản lý Độc giả</h1>
      </div>

      <div className="grid grid-cols-1 gap-6">
        <div className="col-span-1">
          <div className="flex flex-row items-center justify-between mb-4">
            <h2 className="text-xl font-semibold">Danh sách độc giả</h2>
            <div className="flex items-center space-x-2">
              <form onSubmit={handleSearchReaders} className="flex items-center space-x-2">
                <Input 
                  placeholder="Tìm kiếm mã hoặc tên..." 
                  value={searchReaderQuery}
                  onChange={(e) => setSearchReaderQuery(e.target.value)}
                  className="w-64"
                />
                <Button type="submit" variant="secondary" disabled={loadingReaders}>
                  Tìm kiếm
                </Button>
              </form>
              <CreateReaderDialog onSuccess={fetchReaders} />
            </div>
          </div>
          <div>
            <div className="rounded-md border">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Mã ĐG</TableHead>
                    <TableHead>Họ Tên</TableHead>
                    <TableHead>Giới Tính</TableHead>
                    <TableHead>Số ĐT</TableHead>
                    <TableHead>Tổng Nợ</TableHead>
                    <TableHead className="w-[150px]">Hành Động</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loadingReaders ? (
                    <TableRow><TableCell colSpan={6} className="text-center h-24">Đang tải...</TableCell></TableRow>
                  ) : readers.length === 0 ? (
                    <TableRow><TableCell colSpan={6} className="text-center h-24">Không có dữ liệu.</TableCell></TableRow>
                  ) : (
                    readers.map((reader, i) => {
                      const r = reader as Reader & Record<string, unknown>;
                      return (
                      <TableRow key={r.MADG || i}>
                        <TableCell className="font-medium font-mono text-xs">{r.MADG || (r.madg as string) || '-'}</TableCell>
                        <TableCell className="font-medium">{r.HOTEN || (r.hoten as string) || '-'}</TableCell>
                        <TableCell>{r.GIOITINH || (r.gioitinh as string) || '-'}</TableCell>
                        <TableCell>{r.SODT || (r.sodt as string) || '-'}</TableCell>
                        <TableCell className="font-semibold text-rose-600">{Number(r.TONGNO ?? (r.tongno as number) ?? 0).toLocaleString('vi-VN')} đ</TableCell>
                        <TableCell>
                          <div className="flex gap-2">
                            <Button size="icon" variant="outline" onClick={() => handleEdit(r)}>
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
                                    Hành động này không thể hoàn tác. Độc giả này sẽ bị xoá vĩnh viễn khỏi hệ thống.
                                  </AlertDialogDescription>
                                </AlertDialogHeader>
                                <AlertDialogFooter>
                                  <AlertDialogCancel>Hủy</AlertDialogCancel>
                                  <AlertDialogAction onClick={() => r.MADG && handleDeleteReader(r.MADG)}>Xác nhận</AlertDialogAction>
                                </AlertDialogFooter>
                              </AlertDialogContent>
                            </AlertDialog>
                          </div>
                        </TableCell>
                      </TableRow>
                      );
                    })
                  )}
                </TableBody>
              </Table>
            </div>
            <DataTablePagination page={page} totalPages={totalPages} onPageChange={setPage} />
          </div>
        </div>
      </div>

      <UpdateReaderDialog 
        reader={selectedReader} 
        open={isUpdateOpen} 
        onOpenChange={setIsUpdateOpen} 
        onSuccess={fetchReaders} 
      />
    </div>
  );
}
