
import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { toast } from 'sonner';
import { booksService } from '@/services/books.service';
import { authorsService } from '@/services/authors.service';
import { Plus, Trash2, ArrowLeft, Save, Edit2, X } from 'lucide-react';
import type { BookCopy, BookAuthor } from '@/types/api.types';

export default function BookDetails() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  
  const [copies, setCopies] = useState<BookCopy[]>([]);
  const [bookAuthors, setBookAuthors] = useState<BookAuthor[]>([]);
  const [allAuthors, setAllAuthors] = useState<import('@/types/api.types').Author[]>([]);
  
  const [loadingCopies, setLoadingCopies] = useState(false);
  const [loadingAuthors, setLoadingAuthors] = useState(false);
  
  const [newCopy, setNewCopy] = useState({ MACS: '', VITRI: '', TINHTRANG: 'Có sẵn' });
  const [editingCopyId, setEditingCopyId] = useState<string | null>(null);
  const [editCopyData, setEditCopyData] = useState({ VITRI: '', TINHTRANG: '' });

  useEffect(() => {
    if (id) {
      fetchCopies();
      fetchBookAuthors();
      fetchAllAuthors();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const fetchCopies = async () => {
    setLoadingCopies(true);
    try {
      const data = await booksService.getBookCopies(id!);
      const normalized = (data || []).map((c: Record<string, unknown>) => ({
        MACS: (c.MACS || c.MaCS || c.macs || '') as string,
        MADS: (c.MADS || c.MaDS || c.mads || id!) as string,
        NGAYNHAP: (c.NGAYNHAP || c.NgayNhap || c.ngayNhap || '') as string,
        VITRI: (c.VITRI ?? c.ViTri ?? c.viTri ?? '') as string,
        TINHTRANG: (c.TINHTRANG || c.TinhTrang || c.tinhTrang || 'Có sẵn') as string,
      }));
      setCopies(normalized);
    } catch {
      // toast.error('Lỗi khi tải bản sao');
    } finally {
      setLoadingCopies(false);
    }
  };

  const fetchBookAuthors = async () => {
    setLoadingAuthors(true);
    try {
      const data = await booksService.getBookAuthors(id!);
      const normalized = (data || []).map((a: Record<string, unknown>) => ({
        MATG: (a.MATG || a.MaTG || a.matg || '') as string,
        VAITRO: (a.VAITRO || a.VaiTro || a.vaitro || 'Tác giả') as string,
      }));
      setBookAuthors(normalized);
    } catch {
      // toast.error('Lỗi khi tải tác giả của sách');
    } finally {
      setLoadingAuthors(false);
    }
  };

  const fetchAllAuthors = async () => {
    try {
      const dataResult = await authorsService.getAuthors('', 1, 1000);
      const data = dataResult.items || [];
      setAllAuthors(data);
    } catch {
      console.error('Lỗi khi tải danh sách tác giả');
    }
  };

  const handleAddCopy = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await booksService.createBookCopy(id!, newCopy);
      // toast.success('Thêm cuốn sách thành công');
      setNewCopy({ MACS: '', VITRI: '', TINHTRANG: 'Có sẵn' });
      fetchCopies();
    } catch (error) {
      console.error(error);
    }
  };

  const handleDeleteCopy = async (MACS: string) => {
    if (!window.confirm('Xoá cuốn sách này?')) return;
    try {
      await booksService.deleteBookCopy(MACS);
      // toast.success('Xoá thành công');
      fetchCopies();
    } catch (error) {
      console.error(error);
    }
  };

  const handleUpdateCopy = async () => {
    if (!editingCopyId) return;
    try {
      await booksService.updateBookCopy(editingCopyId, { 
        VITRI: editCopyData.VITRI, 
        TINHTRANG: editCopyData.TINHTRANG 
      });
      // toast.success('Cập nhật cuốn sách thành công');
      setEditingCopyId(null);
      fetchCopies();
    } catch (error) {
      console.error(error);
    }
  };

  const handleSaveAuthors = async () => {
    try {
      await booksService.updateBookAuthors(id!, bookAuthors);
      // toast.success('Lưu danh sách tác giả thành công');
      fetchBookAuthors();
    } catch (error) {
      console.error(error);
    }
  };

  const handleAddAuthorToBook = (MATG: string) => {
    if (!MATG) return;
    if (bookAuthors.find(a => a.MATG === MATG)) {
      toast.warning('Tác giả này đã có trong danh sách');
      return;
    }
    setBookAuthors([...bookAuthors, { MATG, VAITRO: 'Tác giả' }]);
  };

  const handleRemoveAuthorFromBook = (MATG: string) => {
    setBookAuthors(bookAuthors.filter(a => a.MATG !== MATG));
  };

  const handleAuthorRoleChange = (MATG: string, VAITRO: string) => {
    setBookAuthors(bookAuthors.map(a => a.MATG === MATG ? { ...a, VAITRO } : a));
  };

  return (
    <div className="space-y-6 p-6">
      <div className="flex items-center gap-4">
        <Button variant="outline" size="icon" onClick={() => navigate('/books')}>
          <ArrowLeft className="h-4 w-4" />
        </Button>
        <h1 className="text-3xl font-bold tracking-tight">Chi tiết Sách: {id}</h1>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Tác giả của sách */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle>Tác giả / Dịch giả</CardTitle>
            <Button size="sm" onClick={handleSaveAuthors}><Save className="w-4 h-4 mr-2"/> Lưu</Button>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex gap-2">
              <select 
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                id="select-author"
              >
                <option value="">-- Chọn tác giả để thêm --</option>
                {allAuthors.map(a => (
                  <option key={a.MATG} value={a.MATG}>{a.TENTG}</option>
                ))}
              </select>
              <Button onClick={() => {
                const el = document.getElementById('select-author') as HTMLSelectElement;
                handleAddAuthorToBook(el.value);
              }}>Thêm</Button>
            </div>

            <div className="rounded-md border overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Mã TG</TableHead>
                    <TableHead>Tên Tác Giả</TableHead>
                    <TableHead>Vai trò</TableHead>
                    <TableHead className="w-[80px]"></TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loadingAuthors ? (
                    <TableRow><TableCell colSpan={4} className="text-center h-24">Đang tải...</TableCell></TableRow>
                  ) : bookAuthors.length === 0 ? (
                    <TableRow><TableCell colSpan={4} className="text-center h-24">Chưa có tác giả</TableCell></TableRow>
                  ) : (
                    bookAuthors.map((item) => {
                      const authorInfo = allAuthors.find(a => (a.MATG || (a as import('@/types/api.types').Author & Record<string, unknown>).maTG) === item.MATG);
                      return (
                        <TableRow key={item.MATG}>
                          <TableCell className="font-medium">{item.MATG}</TableCell>
                          <TableCell>{authorInfo?.TENTG || '-'}</TableCell>
                          <TableCell>
                            <select 
                              className="h-8 rounded-md border border-input text-sm"
                              value={item.VAITRO} 
                              onChange={(e) => handleAuthorRoleChange(item.MATG, e.target.value)}
                            >
                              <option value="Tác giả">Tác giả</option>
                              <option value="Đồng tác giả">Đồng tác giả</option>
                              <option value="Dịch giả">Dịch giả</option>
                            </select>
                          </TableCell>
                          <TableCell>
                            <Button size="icon" variant="destructive" onClick={() => handleRemoveAuthorFromBook(item.MATG)}>
                              <Trash2 className="w-4 h-4" />
                            </Button>
                          </TableCell>
                        </TableRow>
                      );
                    })
                  )}
                </TableBody>
              </Table>
          </div>

          </CardContent>
        </Card>

        {/* Bản sao cuốn sách */}
        <Card>
          <CardHeader>
            <CardTitle>Bản sao vật lý (CUONSACH)</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <form onSubmit={handleAddCopy} className="flex gap-2 items-end">
              <div className="space-y-2 flex-1">
                <label className="text-xs">Mã Cuốn Sách</label>
                <Input value={newCopy.MACS} onChange={(e) => setNewCopy({...newCopy, MACS: e.target.value})} required placeholder="CS001" />
              </div>
              <div className="space-y-2 flex-1">
                <label className="text-xs">Vị trí</label>
                <Input value={newCopy.VITRI} onChange={(e) => setNewCopy({...newCopy, VITRI: e.target.value})} placeholder="Kệ A1" />
              </div>
              <Button type="submit"><Plus className="w-4 h-4 mr-2"/>Thêm</Button>
            </form>

            <div className="rounded-md border overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Mã CS</TableHead>
                    <TableHead>Ngày nhập</TableHead>
                    <TableHead>Vị trí</TableHead>
                    <TableHead>Tình trạng</TableHead>
                    <TableHead className="text-right">Hành động</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loadingCopies ? (
                    <TableRow><TableCell colSpan={5} className="text-center h-24">Đang tải...</TableCell></TableRow>
                  ) : copies.length === 0 ? (
                    <TableRow><TableCell colSpan={5} className="text-center h-24">Chưa có bản sao nào</TableCell></TableRow>
                  ) : (
                    copies.map((item) => {
                      const macs = item.MACS || item.MaCS || '';
                      const ngayNhap = (item.NGAYNHAP || item.NgayNhap)?.split('T')[0] || '-';
                      const viTri = item.VITRI ?? item.ViTri ?? '-';
                      const tinhTrang = item.TINHTRANG || item.TinhTrang || 'Có sẵn';

                      return (
                        <TableRow key={macs}>
                          <TableCell className="font-medium">{macs}</TableCell>
                          <TableCell>{ngayNhap}</TableCell>
                          
                          {editingCopyId === macs ? (
                            <>
                              <TableCell>
                                <Input 
                                  className="h-8 w-24"
                                  value={editCopyData.VITRI} 
                                  onChange={(e) => setEditCopyData({...editCopyData, VITRI: e.target.value})} 
                                />
                              </TableCell>
                              <TableCell>
                                <select 
                                  className="h-8 rounded-md border border-input text-sm"
                                  value={editCopyData.TINHTRANG} 
                                  onChange={(e) => setEditCopyData({...editCopyData, TINHTRANG: e.target.value})}
                                >
                                  <option value="Có sẵn">Có sẵn</option>
                                  <option value="Đang mượn">Đang mượn</option>
                                  <option value="Hư hỏng">Hư hỏng</option>
                                  <option value="Mất">Mất</option>
                                </select>
                              </TableCell>
                              <TableCell className="text-right">
                                <Button size="icon" variant="ghost" onClick={handleUpdateCopy} className="mr-1 text-green-600">
                                  <Save className="w-4 h-4" />
                                </Button>
                                <Button size="icon" variant="ghost" onClick={() => setEditingCopyId(null)} className="text-gray-500">
                                  <X className="w-4 h-4" />
                                </Button>
                              </TableCell>
                            </>
                          ) : (
                            <>
                              <TableCell>{viTri}</TableCell>
                              <TableCell>{tinhTrang}</TableCell>
                              <TableCell className="text-right">
                                <Button 
                                  size="icon" 
                                  variant="ghost" 
                                  onClick={() => {
                                    setEditingCopyId(macs);
                                    setEditCopyData({ VITRI: viTri === '-' ? '' : viTri, TINHTRANG: tinhTrang });
                                  }} 
                                  className="mr-1 text-blue-600"
                                >
                                  <Edit2 className="w-4 h-4" />
                                </Button>
                                <Button size="icon" variant="destructive" onClick={() => handleDeleteCopy(macs)}>
                                  <Trash2 className="w-4 h-4" />
                                </Button>
                              </TableCell>
                            </>
                          )}
                        </TableRow>
                      );
                    })
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
