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
import { Search } from 'lucide-react';
import { categoriesService } from '../services/categories.service';
import { publishersService } from '../services/publishers.service';

export default function Books() {
  const navigate = useNavigate();
  const [books, setBooks] = useState<SearchBookResponse[]>([]);
  const [loading, setLoading] = useState(false);
  const [query, setQuery] = useState('');
  
  const [categories, setCategories] = useState<Category[]>([]);
  const [publishers, setPublishers] = useState<Publisher[]>([]);

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

  const fetchMasterData = async () => {
    try {
      const cats = await categoriesService.getCategories();
      const pubs = await publishersService.getPublishers();
      setCategories(cats);
      setPublishers(pubs);
    } catch {
      console.error('Failed to fetch master data');
    }
  };

  useEffect(() => {
    fetchBooks();
    fetchMasterData();
   
  }, []);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    fetchBooks(query);
  };

  const handleDeleteBook = async (maDs: string) => {
    if (!confirm('Bạn có chắc chắn muốn xóa đầu sách này?')) return;
    try {
      await booksService.deleteBook(maDs);
      toast.success('Xóa sách thành công');
      fetchBooks(query);
    } catch (err) {
      toast.error('Lỗi khi xóa sách (có thể sách đang có cuốn sách con)');
      console.error(err);
    }
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
                  <TableHead>Hành Động</TableHead>
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
                    <TableRow key={book.maSach || Math.random().toString()}>
                      <TableCell>{book.maSach}</TableCell>
                      <TableCell>{book.tenSach}</TableCell>
                      <TableCell>{book.tacGia}</TableCell>
                      <TableCell>
                        <div className="flex gap-2">
                          <Button variant="outline" size="sm" onClick={() => navigate(`/books/${book.maSach}`)}>Chi tiết</Button>
                          <Button variant="destructive" size="sm" onClick={() => book.maSach && handleDeleteBook(book.maSach)}>Xóa</Button>
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

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Thêm Đầu Sách</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={async (e) => {
              e.preventDefault();
              const formData = new FormData(e.currentTarget);
              const data = {
                maDS: formData.get('maDs') as string,
                tenDS: formData.get('tenDs') as string,
                maTL: formData.get('maTl') as string,
                maNXB: formData.get('maNxb') as string,
                namXB: parseInt(formData.get('namXb') as string, 10),
                soTrang: parseInt(formData.get('soTrang') as string, 10),
                gia: parseFloat(formData.get('gia') as string),
              };
              if (!data.maDS) { toast.error('Vui lòng nhập mã đầu sách'); return; }
              try {
                await booksService.createBook(data);
                toast.success('Thêm đầu sách thành công');
                fetchBooks(query);
                (e.target as HTMLFormElement).reset();
              } catch(err) {
                toast.error('Lỗi khi thêm đầu sách');
                console.error(err);
              }
            }} className="grid grid-cols-1 gap-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">Mã Đầu Sách</label>
                <Input name="maDs" placeholder="DS001" required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Tên Sách</label>
                <Input name="tenDs" placeholder="Tên sách mới..." required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Thể Loại</label>
                <select name="maTl" required className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50">
                  <option value="">-- Chọn thể loại --</option>
                  {categories.map((c: Category) => (
                    <option key={c.maTL} value={c.maTL}>{c.tenTL}</option>
                  ))}
                </select>
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Nhà Xuất Bản</label>
                <select name="maNxb" required className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50">
                  <option value="">-- Chọn NXB --</option>
                  {publishers.map((p: Publisher) => (
                    <option key={p.maNXB} value={p.maNXB}>{p.tenNXB}</option>
                  ))}
                </select>
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Năm Xuất Bản</label>
                <Input name="namXb" type="number" placeholder="2023" required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Số Trang</label>
                <Input name="soTrang" type="number" placeholder="300" required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Giá</label>
                <Input name="gia" type="number" step="1000" placeholder="150000" required />
              </div>
              <Button type="submit" className="w-full">Thêm Đầu Sách</Button>
            </form>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Cập Nhật Đầu Sách</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={async (e) => {
              e.preventDefault();
              const formData = new FormData(e.currentTarget);
              const data = {
                maDS: formData.get('maDs') as string,
                tenDS: formData.get('tenDs') as string,
                maTL: formData.get('maTl') as string,
                maNXB: formData.get('maNxb') as string,
                namXB: parseInt(formData.get('namXb') as string, 10),
                soTrang: parseInt(formData.get('soTrang') as string, 10),
                gia: parseFloat(formData.get('gia') as string),
              };
              if (!data.maDS) { toast.error('Vui lòng nhập mã đầu sách'); return; }
              try {
                await booksService.updateBook(data.maDS, data);
                toast.success('Cập nhật đầu sách thành công');
                fetchBooks(query);
              } catch(err) {
                toast.error('Lỗi khi cập nhật đầu sách');
                console.error(err);
              }
            }} className="grid grid-cols-1 gap-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">Mã Đầu Sách (cần sửa)</label>
                <Input name="maDs" placeholder="DS001" required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Tên Sách Mới</label>
                <Input name="tenDs" placeholder="Tên sách mới..." required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Thể Loại</label>
                <select name="maTl" required className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50">
                  <option value="">-- Chọn thể loại --</option>
                  {categories.map((c: Category) => (
                    <option key={c.maTL} value={c.maTL}>{c.tenTL}</option>
                  ))}
                </select>
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Nhà Xuất Bản</label>
                <select name="maNxb" required className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50">
                  <option value="">-- Chọn NXB --</option>
                  {publishers.map((p: Publisher) => (
                    <option key={p.maNXB} value={p.maNXB}>{p.tenNXB}</option>
                  ))}
                </select>
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Năm Xuất Bản</label>
                <Input name="namXb" type="number" placeholder="2023" required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Số Trang</label>
                <Input name="soTrang" type="number" placeholder="300" required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Giá</label>
                <Input name="gia" type="number" step="1000" placeholder="150000" required />
              </div>
              <Button type="submit" className="w-full">Cập Nhật Đầu Sách</Button>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
