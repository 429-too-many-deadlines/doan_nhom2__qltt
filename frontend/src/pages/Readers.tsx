import { useState } from 'react';
import { readersService } from '../services/readers.service';
import type { CreateReaderRequest, GenericApiResponse } from '../types/api.types';
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

export default function Readers() {
  const [createData, setCreateData] = useState<CreateReaderRequest>({ hoTen: '', ngaySinh: '', diaChi: '' });
  const [creating, setCreating] = useState(false);

  const [maDgHistory, setMaDgHistory] = useState('');
  const [history, setHistory] = useState<GenericApiResponse[]>([]);
  const [loadingHistory, setLoadingHistory] = useState(false);

  const [readers, setReaders] = useState<any[]>([]);
  const [searchReaderQuery, setSearchReaderQuery] = useState('');
  const [loadingReaders, setLoadingReaders] = useState(false);

  const handleSearchReaders = async (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    try {
      setLoadingReaders(true);
      const data = await readersService.searchReaders(searchReaderQuery);
      setReaders(data || []);
    } catch (error) {
      console.error(error);
      toast.error('Lỗi khi tải danh sách độc giả');
    } finally {
      setLoadingReaders(false);
    }
  };

  const handleDeleteReader = async (maDg: string) => {
    if (!confirm('Bạn có chắc chắn muốn xóa độc giả này?')) return;
    try {
      await readersService.deleteReader(maDg);
      toast.success('Xóa độc giả thành công');
      handleSearchReaders();
    } catch (err) {
      toast.error('Lỗi khi xóa độc giả (có thể độc giả đã mượn sách)');
      console.error(err);
    }
  };

  const handleCreateReader = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!createData.hoTen) {
      toast.error('Vui lòng nhập họ tên độc giả');
      return;
    }
    try {
      setCreating(true);
      await readersService.createReader(createData);
      toast.success('Tạo độc giả thành công!');
      setCreateData({ hoTen: '', ngaySinh: '', diaChi: '' });
    } catch (error) {
      console.error(error);
      toast.error('Lỗi khi tạo độc giả');
    } finally {
      setCreating(false);
    }
  };

  const handleGetHistory = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!maDgHistory) return;
    try {
      setLoadingHistory(true);
      const data = await readersService.getReaderHistory(maDgHistory);
      setHistory(data || []);
    } catch (error) {
      console.error(error);
      toast.error('Lỗi khi lấy lịch sử độc giả');
    } finally {
      setLoadingHistory(false);
    }
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Quản lý Độc giả</h1>

      <Card>
        <CardHeader>
          <CardTitle>Danh sách độc giả</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSearchReaders} className="flex gap-2 mb-4">
            <Input 
              placeholder="Tìm kiếm mã hoặc tên độc giả..." 
              value={searchReaderQuery}
              onChange={(e) => setSearchReaderQuery(e.target.value)}
              className="max-w-sm"
            />
            <Button type="submit" disabled={loadingReaders}>
              Tìm kiếm
            </Button>
          </form>

          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Mã ĐG</TableHead>
                  <TableHead>Họ Tên</TableHead>
                  <TableHead>Giới Tính</TableHead>
                  <TableHead>Loại ĐG</TableHead>
                  <TableHead>Tổng Nợ</TableHead>
                  <TableHead>Hành Động</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {loadingReaders ? (
                  <TableRow><TableCell colSpan={6} className="text-center h-24">Đang tải...</TableCell></TableRow>
                ) : readers.length === 0 ? (
                  <TableRow><TableCell colSpan={6} className="text-center h-24">Bấm Tìm kiếm để xem danh sách hoặc không tìm thấy kết quả.</TableCell></TableRow>
                ) : (
                  readers.map((r, i) => (
                    <TableRow key={r.madg || i}>
                      <TableCell>{r.madg}</TableCell>
                      <TableCell>{r.hoten}</TableCell>
                      <TableCell>{r.gioitinh}</TableCell>
                      <TableCell>{r.loaidg}</TableCell>
                      <TableCell>{r.tongno}</TableCell>
                      <TableCell>
                        <Button variant="destructive" size="sm" onClick={() => r.madg && handleDeleteReader(r.madg)}>Xóa</Button>
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
            <CardTitle>Thêm Độc Giả Mới</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleCreateReader} className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">Họ Tên</label>
                <Input 
                  placeholder="Nguyễn Văn A" 
                  value={createData.hoTen}
                  onChange={(e) => setCreateData({ ...createData, hoTen: e.target.value })}
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Ngày Sinh</label>
                <Input 
                  type="date"
                  value={createData.ngaySinh}
                  onChange={(e) => setCreateData({ ...createData, ngaySinh: e.target.value })}
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Địa Chỉ</label>
                <Input 
                  placeholder="TP.HCM" 
                  value={createData.diaChi}
                  onChange={(e) => setCreateData({ ...createData, diaChi: e.target.value })}
                />
              </div>
              <Button type="submit" disabled={creating} className="w-full">
                {creating ? 'Đang thêm...' : 'Thêm Độc Giả'}
              </Button>
            </form>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Lịch Sử Mượn/Trả</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <form onSubmit={handleGetHistory} className="flex gap-2">
              <Input 
                placeholder="Nhập Mã Độc Giả (VD: DG001)" 
                value={maDgHistory}
                onChange={(e) => setMaDgHistory(e.target.value)}
              />
              <Button type="submit" disabled={loadingHistory}>
                Xem Lịch Sử
              </Button>
            </form>

            <div className="rounded-md border mt-4">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Chi Tiết</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loadingHistory ? (
                    <TableRow>
                      <TableCell className="h-24 text-center">Đang tải...</TableCell>
                    </TableRow>
                  ) : history.length === 0 ? (
                    <TableRow>
                      <TableCell className="h-24 text-center">Không có dữ liệu.</TableCell>
                    </TableRow>
                  ) : (
                    history.map((item, idx) => (
                      <TableRow key={idx}>
                        <TableCell>
                          <pre className="text-xs">{JSON.stringify(item, null, 2)}</pre>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>

        <Card className="md:col-span-2">
          <CardHeader>
            <CardTitle>Cập Nhật Độc Giả</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={async (e) => {
              e.preventDefault();
              const formData = new FormData(e.currentTarget);
              const data = {
                maDg: formData.get('maDg') as string,
                hoTen: formData.get('hoTen') as string,
                ngaySinh: formData.get('ngaySinh') as string,
                gioiTinh: formData.get('gioiTinh') as string,
                diaChi: formData.get('diaChi') as string,
                soDt: formData.get('soDt') as string,
                email: formData.get('email') as string,
                maLdg: formData.get('maLdg') as string,
              };
              if (!data.maDg) { toast.error('Vui lòng nhập mã độc giả'); return; }
              try {
                await readersService.updateReader(data.maDg, data);
                toast.success('Cập nhật độc giả thành công');
              } catch(err) {
                toast.error('Lỗi khi cập nhật độc giả');
                console.error(err);
              }
            }} className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">Mã Độc Giả</label>
                <Input name="maDg" placeholder="DG001" required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Họ Tên</label>
                <Input name="hoTen" placeholder="Nguyễn Văn B" required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Ngày Sinh</label>
                <Input name="ngaySinh" type="date" required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Giới Tính</label>
                <Input name="gioiTinh" placeholder="Nam/Nữ" required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Số Điện Thoại</label>
                <Input name="soDt" placeholder="090..." required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Mã Loại ĐG</label>
                <Input name="maLdg" placeholder="SV/GV/KH" required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Địa Chỉ</label>
                <Input name="diaChi" placeholder="Địa chỉ..." />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Email</label>
                <Input name="email" type="email" placeholder="email@..." />
              </div>
              <div className="md:col-span-2">
                <Button type="submit" className="w-full">Cập Nhật</Button>
              </div>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
