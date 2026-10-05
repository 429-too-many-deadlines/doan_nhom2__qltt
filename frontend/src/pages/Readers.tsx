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
      </div>
    </div>
  );
}
