import { useEffect, useState } from 'react';
import { booksService } from '../services/books.service';
import type { SearchBookResponse } from '../types/api.types';
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
import { Search } from 'lucide-react';

export default function Books() {
  const [books, setBooks] = useState<SearchBookResponse[]>([]);
  const [loading, setLoading] = useState(false);
  const [query, setQuery] = useState('');

  const fetchBooks = async (searchQuery: string = '') => {
    try {
      setLoading(true);
      const data = await booksService.searchBooks(searchQuery);
      setBooks(data || []);
    } catch (error) {
      console.error(error);
      toast.error('Lỗi khi tải danh sách sách');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBooks();
  }, []);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    fetchBooks(query);
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Quản lý Sách</h1>
      
      <Card>
        <CardHeader>
          <CardTitle>Danh sách sách</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSearch} className="flex gap-2 mb-4">
            <Input 
              placeholder="Tìm kiếm sách..." 
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              className="max-w-sm"
            />
            <Button type="submit" disabled={loading}>
              <Search className="w-4 h-4 mr-2" />
              Tìm kiếm
            </Button>
          </form>

          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Mã Sách</TableHead>
                  <TableHead>Tên Sách</TableHead>
                  <TableHead>Tác Giả</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {loading ? (
                  <TableRow>
                    <TableCell colSpan={3} className="h-24 text-center">
                      Đang tải...
                    </TableCell>
                  </TableRow>
                ) : books.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={3} className="h-24 text-center">
                      Không tìm thấy sách.
                    </TableCell>
                  </TableRow>
                ) : (
                  books.map((book) => (
                    <TableRow key={book.maSach || Math.random().toString()}>
                      <TableCell>{book.maSach}</TableCell>
                      <TableCell>{book.tenSach}</TableCell>
                      <TableCell>{book.tacGia}</TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
