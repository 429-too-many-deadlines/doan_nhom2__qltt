import { DataTablePagination } from '../components/ui/data-table-pagination';
import { useEffect, useState, useCallback } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { toast } from 'sonner';
import { authorsService } from '@/services/authors.service';
import { Trash2, Edit } from 'lucide-react';
import type { Author } from '@/types/api.types';
import { CreateAuthorDialog } from '@/components/features/authors/CreateAuthorDialog';
import { UpdateAuthorDialog } from '@/components/features/authors/UpdateAuthorDialog';
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

export default function Authors() {
  const [items, setItems] = useState<Author[]>([]);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [query, setQuery] = useState('');
  
  const [selectedAuthor, setSelectedAuthor] = useState<Author | null>(null);
  const [isUpdateOpen, setIsUpdateOpen] = useState(false);

  const fetchItems = useCallback(async (searchQuery = query, currentPage = page) => {
    setLoading(true);
    try {
      const dataResult = await authorsService.getAuthors(searchQuery, currentPage);
      const data = dataResult.items || [];
      setTotalPages(dataResult.totalPages);
      setItems(data);
    } catch {
      toast.error('Lỗi khi tải danh sách');
    } finally {
      setLoading(false);
    }
  }, [query, page]);

  useEffect(() => {
    fetchItems(query, page);
  }, [fetchItems, page]); // Using page because fetchItems captures it, but to be safe

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    setPage(1);
    fetchItems(query, 1);
  };

  const handleDelete = async (id: string) => {
    try {
      await authorsService.deleteAuthor(id);
      toast.success('Xoá thành công');
      fetchItems(query, page);
    } catch {
      toast.error('Lỗi khi xoá. Có thể đang được sử dụng.');
    }
  };

  const handleEdit = (item: Author) => {
    setSelectedAuthor(item);
    setIsUpdateOpen(true);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold tracking-tight">Quản lý Tác giả</h1>
      </div>

      <div className="grid grid-cols-1 gap-6">
        <Card className="col-span-1">
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle>Danh sách Tác giả</CardTitle>
            <div className="flex items-center space-x-2">
              <form onSubmit={handleSearch} className="flex items-center space-x-2">
                <Input 
                  placeholder="Tìm kiếm..." 
                  value={query}
                  onChange={(e) => setQuery(e.target.value)}
                  className="w-64" 
                />
              </form>
              <CreateAuthorDialog onSuccess={() => fetchItems(query, page)} />
            </div>
          </CardHeader>
          <CardContent>
            <div className="rounded-md border overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Mã</TableHead>
                    <TableHead>Tên</TableHead>
                    <TableHead>Năm Sinh</TableHead>
                    <TableHead>Quốc Tịch</TableHead>
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
                      <TableRow key={item.MATG}>
                        <TableCell className="font-medium">{item.MATG}</TableCell>
                        <TableCell>{item.TENTG}</TableCell>
                        <TableCell>{item.NAMSINH}</TableCell>
                        <TableCell>{item.QUOCTICH}</TableCell>
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
                                    Hành động này không thể hoàn tác. Tác giả này sẽ bị xoá vĩnh viễn khỏi hệ thống.
                                  </AlertDialogDescription>
                                </AlertDialogHeader>
                                <AlertDialogFooter>
                                  <AlertDialogCancel>Hủy</AlertDialogCancel>
                                  <AlertDialogAction onClick={() => handleDelete(item.MATG)}>Xác nhận</AlertDialogAction>
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

      <UpdateAuthorDialog 
        author={selectedAuthor} 
        open={isUpdateOpen} 
        onOpenChange={setIsUpdateOpen} 
        onSuccess={() => fetchItems(query, page)} 
      />
    </div>
  );
}
