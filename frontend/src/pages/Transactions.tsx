import { useState, useEffect } from 'react';
import { transactionsService } from '../services/transactions.service';
import type { BorrowRequest, BorrowSlip, FineSlip, PayFineRequest, ReturnRequest } from '../types/api.types';
import { toast } from 'sonner';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { Input } from '../components/ui/input';
import { Button } from '../components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../components/ui/tabs';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '../components/ui/table';

export default function Transactions() {
  // Mượn sách
  const [borrowData, setBorrowData] = useState<BorrowRequest>({ maDg: '', maNv: '', dsMaCs: [] });
  const [borrowMaCsInput, setBorrowMaCsInput] = useState('');
  const [borrowing, setBorrowing] = useState(false);

  // Trả sách
  const [returnData, setReturnData] = useState<ReturnRequest>({ maPm: '', maCs: '', tinhTrangTra: 'Bình thường' });
  const [returnMaCsInput, setReturnMaCsInput] = useState('');
  const [returning, setReturning] = useState(false);

  // Đóng phạt
  const [fineData, setFineData] = useState<PayFineRequest>({ maDg: '' });
  const [payingFine, setPayingFine] = useState(false);

  // Dữ liệu danh sách
  const [borrowSlips, setBorrowSlips] = useState<BorrowSlip[]>([]);
  const [fineSlips, setFineSlips] = useState<FineSlip[]>([]);

  const fetchData = async () => {
    try {
      const [bData, fData] = await Promise.all([transactionsService.getBorrowSlips(), transactionsService.getFineSlips()]);
      setBorrowSlips(bData);
      setFineSlips(fData);
    } catch (e) {
      console.error(e);
    }
  };

  useEffect(() => {
    fetchData();
   
  }, []);

  const handleBorrow = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setBorrowing(true);
      const dsMaCs = borrowMaCsInput.split(',').map(s => s.trim()).filter(Boolean);
      await transactionsService.borrowBook({ ...borrowData, dsMaCs });
      toast.success('Mượn sách thành công');
      setBorrowData({ maDg: '', maNv: '', dsMaCs: [] });
      setBorrowMaCsInput('');
      fetchData();
    } catch (error) {
      console.error(error);
      toast.error('Lỗi khi mượn sách');
    } finally {
      setBorrowing(false);
    }
  };

  const handleReturn = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setReturning(true);
      const dsMaCs = returnMaCsInput.split(',').map(s => s.trim()).filter(Boolean);
      
      let hasError = false;
      for (const maCs of dsMaCs) {
        try {
          await transactionsService.returnBook({ ...returnData, maCs });
        } catch (err) {
          console.error(err);
          hasError = true;
          toast.error(`Lỗi khi trả sách mã: ${maCs}`);
        }
      }

      if (!hasError) {
        toast.success('Trả sách thành công');
      } else if (dsMaCs.length > 1) {
        toast.warning('Hoàn tất trả sách, có một số sách bị lỗi');
      }

      setReturnData({ maPm: '', maCs: '', tinhTrangTra: 'Bình thường' });
      setReturnMaCsInput('');
      fetchData();
    } catch (error) {
      console.error(error);
      toast.error('Lỗi hệ thống khi trả sách');
    } finally {
      setReturning(false);
    }
  };

  const handleFine = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setPayingFine(true);
      await transactionsService.payFine(fineData);
      toast.success('Thu tiền phạt thành công');
      setFineData({ maDg: '' });
      fetchData();
    } catch (error) {
      console.error(error);
      toast.error('Lỗi khi thu tiền phạt');
    } finally {
      setPayingFine(false);
    }
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Giao Dịch</h1>
      
            <Tabs defaultValue="actions">
        <TabsList className="mb-4">
          <TabsTrigger value="actions">Thao tác</TabsTrigger>
          <TabsTrigger value="borrow-slips">DS Phiếu Mượn</TabsTrigger>
          <TabsTrigger value="fine-slips">DS Phiếu Phạt</TabsTrigger>
        </TabsList>

        <TabsContent value="actions" className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        {/* Card Mượn Sách */}
        <Card>
          <CardHeader>
            <CardTitle>Mượn Sách</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleBorrow} className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">Mã Độc Giả</label>
                <Input value={borrowData.maDg} onChange={(e) => setBorrowData({...borrowData, maDg: e.target.value})} required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Mã Nhân Viên</label>
                <Input value={borrowData.maNv} onChange={(e) => setBorrowData({...borrowData, maNv: e.target.value})} required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Danh Sách Mã Cuốn Sách</label>
                <Input placeholder="VD: CS01, CS02" value={borrowMaCsInput} onChange={(e) => setBorrowMaCsInput(e.target.value)} required />
              </div>
              <Button type="submit" disabled={borrowing} className="w-full">
                {borrowing ? 'Đang xử lý...' : 'Xác Nhận Mượn'}
              </Button>
            </form>
          </CardContent>
        </Card>

        {/* Card Trả Sách */}
        <Card>
          <CardHeader>
            <CardTitle>Trả Sách</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleReturn} className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">Mã Phiếu Mượn (Tuỳ chọn)</label>
                <Input value={returnData.maPm || ''} onChange={(e) => setReturnData({...returnData, maPm: e.target.value})} />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Danh Sách Mã Cuốn Sách</label>
                <Input placeholder="VD: CS01, CS02" value={returnMaCsInput} onChange={(e) => setReturnMaCsInput(e.target.value)} required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Tình trạng trả</label>
                <select 
                  className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                  value={returnData.tinhTrangTra || ''} 
                  onChange={(e) => setReturnData({...returnData, tinhTrangTra: e.target.value})}
                >
                  <option value="Bình thường">Bình thường</option>
                  <option value="Hư hỏng">Hư hỏng</option>
                  <option value="Mất">Mất</option>
                </select>
              </div>
              <Button type="submit" disabled={returning} className="w-full">
                {returning ? 'Đang xử lý...' : 'Xác Nhận Trả'}
              </Button>
            </form>
          </CardContent>
        </Card>

        {/* Card Thu Tiền Phạt */}
        <Card>
          <CardHeader>
            <CardTitle>Thu Tiền Phạt</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleFine} className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">Mã Độc Giả</label>
                <Input value={fineData.maDg} onChange={(e) => setFineData({...fineData, maDg: e.target.value})} required />
              </div>
              <Button type="submit" disabled={payingFine} className="w-full">
                {payingFine ? 'Đang xử lý...' : 'Xác Nhận Thu'}
              </Button>
            </form>
          </CardContent>
        </Card>

        </TabsContent>

        <TabsContent value="borrow-slips">
          <Card>
            <CardHeader><CardTitle>Danh sách Phiếu Mượn & Chi Tiết</CardTitle></CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Mã PM</TableHead>
                    <TableHead>Mã ĐG</TableHead>
                    <TableHead>Tên ĐG</TableHead>
                    <TableHead>Mã CS</TableHead>
                    <TableHead>Ngày mượn</TableHead>
                    <TableHead>Hạn trả</TableHead>
                    <TableHead>Ngày trả</TableHead>
                    <TableHead>Tình trạng PM</TableHead>
                    <TableHead>Tình trạng Sách</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {borrowSlips.map((row, i) => (
                    <TableRow key={i}>
                      <TableCell>{row.mapm}</TableCell>
                      <TableCell>{row.madg}</TableCell>
                      <TableCell>{row.tendg}</TableCell>
                      <TableCell>{row.macs}</TableCell>
                      <TableCell>{row.ngaymuon?.split('T')[0]}</TableCell>
                      <TableCell>{row.hantra?.split('T')[0]}</TableCell>
                      <TableCell>{row.ngaytra?.split('T')[0] || 'Chưa trả'}</TableCell>
                      <TableCell>{row.tinhtrang}</TableCell>
                      <TableCell>{row.tinhtrangtra}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="fine-slips">
          <Card>
            <CardHeader><CardTitle>Danh sách Phiếu Phạt</CardTitle></CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Mã PP</TableHead>
                    <TableHead>Mã PM</TableHead>
                    <TableHead>Mã ĐG</TableHead>
                    <TableHead>Tên ĐG</TableHead>
                    <TableHead>Lý do</TableHead>
                    <TableHead>Số tiền</TableHead>
                    <TableHead>Đã thanh toán</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {fineSlips.map((row, i) => (
                    <TableRow key={i}>
                      <TableCell>{row.mapp}</TableCell>
                      <TableCell>{row.mapm}</TableCell>
                      <TableCell>{row.madg}</TableCell>
                      <TableCell>{row.tendg}</TableCell>
                      <TableCell>{row.lyDo}</TableCell>
                      <TableCell>{row.soTienThu}</TableCell>
                      <TableCell>{row.dathanhtoan ? 'Rồi' : 'Chưa'}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
