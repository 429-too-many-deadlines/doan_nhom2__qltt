import { DataTablePagination } from '../components/ui/data-table-pagination';
import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { booksService } from '../services/books.service';
import type { Category, Publisher, SearchBookResponse } from '../types/api.types';
import { toast } from 'sonner';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../components/ui/table';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { Input } from '../components/ui/input';
import { Button } from '../components/ui/button';
import { Search, Edit, Trash2, Info } from 'lucide-react';
import { categoriesService } from '../services/categories.service';
import { publishersService } from '../services/publishers.service';
import { CreateBookDialog } from '@/components/features/books/CreateBookDialog';
import { UpdateBookDialog } from '@/components/features/books/UpdateBookDialog';
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

export default function Books() {
  const navigate = useNavigate();
  const [books, setBooks] = useState<SearchBookResponse[]>([]);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [query, setQuery] = useState('');
  
  const [categories, setCategories] = useState<Category[]>([]);
  const [publishers, setPublishers] = useState<Publisher[]>([]);

  const [selectedBook, setSelectedBook] = useState<SearchBookResponse | null>(null);
  const [isUpdateOpen, setIsUpdateOpen] = useState(false);

  const fetchBooks = async (searchQuery: string = '') => {
    try {
      setLoading(true);
      const dataResult = await booksService.searchBooks(searchQuery, page);
      const data = dataResult.items || [];
      setTotalPages(dataResult.totalPages);
      setBooks(data || []);
    } catch (error) {
      console.error(error);
      toast.error('Lỗi khi tải danh sách sách');
    } finally {
      setLoading(false);
    }
  };

  const fetchMasterData = async () => {
    try {
      const catsResult = await categoriesService.getCategories();
      const cats = catsResult.items || [];
      const pubsResult = await publishersService.getPublishers();
      const pubs = pubsResult.items || [];
      setCategories(cats);
      setPublishers(pubs);
    } catch {
      console.error('Failed to fetch master data');
    }
  };

  useEffect(() => {
    fetchBooks(query);
  }, [page]);

  useEffect(() => {
    fetchMasterData();
  }, []);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    setPage(1);
    fetchBooks(query);
  };

  const handleDeleteBook = async (maDs: string) => {
    try {
      await booksService.deleteBook(maDs);
      toast.success('Xóa sách thành công');
      fetchBooks(query);
    } catch (err) {
      toast.error('Lỗi khi xóa sách (có thể sách đang có cuốn sách con)');
      console.error(err);
    }
  };

  const handleEdit = (book: SearchBookResponse) => {
    setSelectedBook(book);
    setIsUpdateOpen(true);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold tracking-tight">Quản lý Sách</h1>
      </div>

      <div className="grid grid-cols-1 gap-6">
        <Card className="col-span-1">
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle>Danh sách Đầu Sách</CardTitle>
            <div className="flex items-center space-x-2">
              <form onSubmit={handleSearch} className="flex gap-2">
                <Input 
                  placeholder="Tìm kiếm sách..." 
                  value={query}
                  onChange={(e) => setQuery(e.target.value)}
                  className="w-64"
                />
                <Button type="submit" disabled={loading} variant="secondary">
                  <Search className="w-4 h-4" />
                </Button>
              </form>
              <CreateBookDialog 
                onSuccess={() => fetchBooks(query)} 
                categories={categories} 
                publishers={publishers} 
              />
            </div>
          </CardHeader>
          <CardContent>
            <div className="rounded-md border">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Mã Sách</TableHead>
                    <TableHead>Tên Sách</TableHead>
                    <TableHead>Tác Giả</TableHead>
                    <TableHead className="w-[180px]">Hành Động</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loading ? (
                    <TableRow>
                      <TableCell colSpan={4} className="h-24 text-center">
                        Đang tải...
                      </TableCell>
                    </TableRow>
                  ) : books.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={4} className="h-24 text-center">
                        Không tìm thấy sách.
                      </TableCell>
                    </TableRow>
                  ) : (
                    books.map((book) => (
                      <TableRow key={book.MADS || Math.random().toString()}>
                        <TableCell className="font-medium">{book.MADS}</TableCell>
                        <TableCell>{book.TENDS}</TableCell>
                        <TableCell>{book.TACGIA}</TableCell>
                        <TableCell>
                          <div className="flex gap-2">
                            <Button 
                              variant="outline" 
                              size="icon" 
                              onClick={() => navigate(`/books/${book.MADS}`)}
                              title="Chi tiết"
                            >
                              <Info className="w-4 h-4" />
                            </Button>
                            <Button 
                              variant="outline" 
                              size="icon" 
                              onClick={() => handleEdit(book)}
                              title="Chỉnh sửa"
                            >
                              <Edit className="w-4 h-4" />
                            </Button>
                            <AlertDialog>
                              <AlertDialogTrigger asChild>
                                <Button variant="destructive" size="icon" title="Xóa">
                                  <Trash2 className="w-4 h-4" />
                                </Button>
                              </AlertDialogTrigger>
                              <AlertDialogContent>
                                <AlertDialogHeader>
                                  <AlertDialogTitle>Bạn có chắc chắn muốn xoá?</AlertDialogTitle>
                                  <AlertDialogDescription>
                                    Hành động này không thể hoàn tác. Đầu sách này sẽ bị xoá vĩnh viễn khỏi hệ thống.
                                  </AlertDialogDescription>
                                </AlertDialogHeader>
                                <AlertDialogFooter>
                                  <AlertDialogCancel>Hủy</AlertDialogCancel>
                                  <AlertDialogAction onClick={() => book.MADS && handleDeleteBook(book.MADS)}>
                                    Xác nhận
                                  </AlertDialogAction>
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

      <UpdateBookDialog 
        book={selectedBook}
        open={isUpdateOpen}
        onOpenChange={setIsUpdateOpen}
        onSuccess={() => fetchBooks(query)}
        categories={categories}
        publishers={publishers}
      />
    </div>
  );
}
