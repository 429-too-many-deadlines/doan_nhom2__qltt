import { useState } from 'react';
import { transactionsService } from '../services/transactions.service';
import type { BorrowRequest, ReturnRequest, PayFineRequest } from '../types/api.types';
import { toast } from 'sonner';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { Input } from '../components/ui/input';
import { Button } from '../components/ui/button';

export default function Transactions() {
  // Mượn sách
  const [borrowData, setBorrowData] = useState<BorrowRequest>({ maDg: '', maNv: '', dsMaCs: [] });
  const [borrowMaCsInput, setBorrowMaCsInput] = useState('');
  const [borrowing, setBorrowing] = useState(false);

  // Trả sách
  const [returnData, setReturnData] = useState<ReturnRequest>({ maPm: '', maNv: '', dsMaCs: [] });
  const [returnMaCsInput, setReturnMaCsInput] = useState('');
  const [returning, setReturning] = useState(false);

  // Đóng phạt
  const [fineData, setFineData] = useState<PayFineRequest>({ maDg: '', maNv: '', soTienThu: 0 });
  const [payingFine, setPayingFine] = useState(false);

  const handleBorrow = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setBorrowing(true);
      const dsMaCs = borrowMaCsInput.split(',').map(s => s.trim()).filter(Boolean);
      await transactionsService.borrowBook({ ...borrowData, dsMaCs });
      toast.success('Mượn sách thành công');
      setBorrowData({ maDg: '', maNv: '', dsMaCs: [] });
      setBorrowMaCsInput('');
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
      await transactionsService.returnBook({ ...returnData, dsMaCs });
      toast.success('Trả sách thành công');
      setReturnData({ maPm: '', maNv: '', dsMaCs: [] });
      setReturnMaCsInput('');
    } catch (error) {
      console.error(error);
      toast.error('Lỗi khi trả sách');
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
      setFineData({ maDg: '', maNv: '', soTienThu: 0 });
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
      
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
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
                <label className="text-sm font-medium">Mã Nhân Viên</label>
                <Input value={returnData.maNv} onChange={(e) => setReturnData({...returnData, maNv: e.target.value})} required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Danh Sách Mã Cuốn Sách</label>
                <Input placeholder="VD: CS01, CS02" value={returnMaCsInput} onChange={(e) => setReturnMaCsInput(e.target.value)} required />
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
              <div className="space-y-2">
                <label className="text-sm font-medium">Mã Nhân Viên</label>
                <Input value={fineData.maNv} onChange={(e) => setFineData({...fineData, maNv: e.target.value})} required />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Số Tiền Thu</label>
                <Input type="number" value={fineData.soTienThu || ''} onChange={(e) => setFineData({...fineData, soTienThu: Number(e.target.value)})} />
              </div>
              <Button type="submit" disabled={payingFine} className="w-full">
                {payingFine ? 'Đang xử lý...' : 'Xác Nhận Thu'}
              </Button>
            </form>
          </CardContent>
        </Card>

      </div>
    </div>
  );
}
