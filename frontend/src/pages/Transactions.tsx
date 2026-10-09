import { DataTablePagination } from '../components/ui/data-table-pagination';
import { useEffect, useState, useCallback } from 'react';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
import { Badge } from '@/components/ui/badge';
import { toast } from 'sonner';
import { transactionsService } from '@/services/transactions.service';
import { Trash2, Edit, CheckCircle, CreditCard, ArrowRightLeft, AlertCircle } from 'lucide-react';
import type { BorrowSlip, FineSlip } from '@/types/api.types';
import { CreateTransactionDialog } from '@/components/features/transactions/CreateTransactionDialog';
import { UpdateTransactionDialog } from '@/components/features/transactions/UpdateTransactionDialog';
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

export default function Transactions() {
  const [activeTab, setActiveTab] = useState('borrows');

  // Borrows state
  const [transactions, setTransactions] = useState<BorrowSlip[]>([]);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [selectedTransaction, setSelectedTransaction] = useState<BorrowSlip | null>(null);
  const [isUpdateOpen, setIsUpdateOpen] = useState(false);

  // Fines state
  const [fineSlips, setFineSlips] = useState<FineSlip[]>([]);
  const [loadingFines, setLoadingFines] = useState(false);
  const [finePage, setFinePage] = useState(1);
  const [fineTotalPages, setFineTotalPages] = useState(1);
  const [payingFine, setPayingFine] = useState(false);

  const fetchTransactions = useCallback(async () => {
    setLoading(true);
    try {
      const dataResult = await transactionsService.getBorrowSlips(page, 10);
      const data = 'items' in dataResult ? dataResult.items : (Array.isArray(dataResult) ? dataResult : []);
      const total = 'totalPages' in dataResult ? dataResult.totalPages : 1;
      setTotalPages(total);
      setTransactions(data);
    } catch {
      // toast.error('Lỗi khi tải danh sách giao dịch');
    } finally {
      setLoading(false);
    }
  }, [page]);

  const fetchFineSlips = useCallback(async () => {
    setLoadingFines(true);
    try {
      const dataResult = await transactionsService.getFineSlips(finePage, 10);
      const data = 'items' in dataResult ? dataResult.items : (Array.isArray(dataResult) ? dataResult : []);
      const total = 'totalPages' in dataResult ? dataResult.totalPages : 1;
      setFineTotalPages(total);
      setFineSlips(data);
    } catch {
      // toast.error('Lỗi khi tải danh sách phiếu phạt');
    } finally {
      setLoadingFines(false);
    }
  }, [finePage]);

  useEffect(() => {
    if (activeTab === 'borrows') {
      fetchTransactions();
    } else {
      fetchFineSlips();
    }
  }, [activeTab, fetchTransactions, fetchFineSlips]);

  const handleDelete = async (MAPM: string, MACS: string) => {
    try {
      toast.error('Chức năng xoá chưa được hỗ trợ bởi API');
      console.log('Delete clicked for', MAPM, MACS);
    } catch {
      // toast.error('Lỗi khi xoá.');
    }
  };

  const handleEdit = (transaction: BorrowSlip) => {
    setSelectedTransaction(transaction);
    setIsUpdateOpen(true);
  };

  const handlePayFine = async (madg: string) => {
    if (!madg) return;
    try {
      setPayingFine(true);
      const res = await transactionsService.payFine({ MADG: madg });
      toast.success(res.message || 'Thanh toán tiền phạt thành công');
      fetchFineSlips();
    } catch {
      toast.error('Lỗi khi thanh toán tiền phạt');
    } finally {
      setPayingFine(false);
    }
  };

  return (
    <div className="space-y-6 p-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Quản lý Giao dịch</h1>
          <p className="text-sm text-muted-foreground mt-1">
            Theo dõi phiếu mượn, trả sách và quản lý các khoản phạt độc giả
          </p>
        </div>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-4">
        <TabsList className="grid grid-cols-2 w-[400px]">
          <TabsTrigger value="borrows" className="flex items-center gap-2">
            <ArrowRightLeft className="w-4 h-4" />
            Phiếu Mượn Sách
          </TabsTrigger>
          <TabsTrigger value="fines" className="flex items-center gap-2">
            <AlertCircle className="w-4 h-4" />
            Phiếu Phạt Vi Phạm
          </TabsTrigger>
        </TabsList>

        {/* Tab 1: Borrow Slips */}
        <TabsContent value="borrows" className="space-y-4">
          <div className="flex flex-row items-center justify-between mb-4">
            <h2 className="text-xl font-semibold">Danh sách Phiếu Mượn</h2>
            <div className="flex items-center space-x-2">
              <Input placeholder="Tìm kiếm..." className="w-64" />
              <CreateTransactionDialog onSuccess={fetchTransactions} />
            </div>
          </div>
          <div>
            <div className="rounded-md border overflow-x-auto">
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
                    <TableHead className="w-[150px]">Hành Động</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loading ? (
                    <TableRow>
                      <TableCell colSpan={10} className="text-center h-24">Đang tải...</TableCell>
                    </TableRow>
                  ) : transactions.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={10} className="text-center h-24">Không có dữ liệu</TableCell>
                    </TableRow>
                  ) : (
                    transactions.map((transaction, index) => {
                      const t = transaction as typeof transaction & Record<string, unknown>;
                      const mapm = t.MAPM || t.mapm || '-';
                      const madg = t.MADG || t.madg || '-';
                      const tendg = t.TENDG || t.tendg || '-';
                      const macs = t.MACS || t.macs || '-';
                      const ngayMuon = ((t.NGAYMUON || t.ngaymuon) as string | undefined)?.split('T')[0] || '-';
                      const hanTra = ((t.HANTRA || t.hantra) as string | undefined)?.split('T')[0] || '-';
                      const ngayTra = ((t.NGAYTRA || t.ngaytra) as string | undefined)?.split('T')[0] || 'Chưa trả';
                      const tinhTrangPM = t.TINHTRANG || t.tinhtrang || '-';
                      const tinhTrangSach = t.TINHTRANGTRA || t.tinhtrangtra || (t.NGAYTRA ? 'Bình thường' : 'Chưa trả');

                      return (
                        <TableRow key={`${mapm}-${macs}-${index}`}>
                          <TableCell className="font-medium font-mono text-xs">{mapm}</TableCell>
                          <TableCell className="font-mono text-xs">{madg}</TableCell>
                          <TableCell className="font-medium">{tendg}</TableCell>
                          <TableCell className="font-mono text-xs">{macs}</TableCell>
                          <TableCell>{ngayMuon}</TableCell>
                          <TableCell>{hanTra}</TableCell>
                          <TableCell>
                            {ngayTra === 'Chưa trả' ? (
                              <span className="text-amber-600 font-medium">{ngayTra}</span>
                            ) : (
                              <span>{ngayTra}</span>
                            )}
                          </TableCell>
                          <TableCell>
                            <Badge variant={tinhTrangPM === 'Đã trả' ? 'secondary' : 'outline'}>
                              {tinhTrangPM}
                            </Badge>
                          </TableCell>
                          <TableCell>
                            <span className={tinhTrangSach === 'Chưa trả' ? 'text-muted-foreground' : 'font-medium'}>
                              {tinhTrangSach}
                            </span>
                          </TableCell>
                          <TableCell>
                            <div className="flex gap-2">
                              <Button size="icon" variant="outline" onClick={() => handleEdit(transaction)} title="Cập nhật trả sách">
                                <Edit className="w-4 h-4" />
                              </Button>
                              <AlertDialog>
                                <AlertDialogTrigger asChild>
                                  <Button size="icon" variant="destructive" title="Xóa giao dịch">
                                    <Trash2 className="w-4 h-4" />
                                  </Button>
                                </AlertDialogTrigger>
                                <AlertDialogContent>
                                  <AlertDialogHeader>
                                    <AlertDialogTitle>Bạn có chắc chắn muốn xoá?</AlertDialogTitle>
                                    <AlertDialogDescription>
                                      Hành động này không thể hoàn tác. Giao dịch này sẽ bị xoá vĩnh viễn khỏi hệ thống.
                                    </AlertDialogDescription>
                                  </AlertDialogHeader>
                                  <AlertDialogFooter>
                                    <AlertDialogCancel>Hủy</AlertDialogCancel>
                                    <AlertDialogAction onClick={() => handleDelete(mapm, macs)}>Xác nhận</AlertDialogAction>
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
        </TabsContent>

        {/* Tab 2: Fine Slips */}
        <TabsContent value="fines" className="space-y-4">
          <div className="flex flex-row items-center justify-between mb-4">
            <h2 className="text-xl font-semibold">Danh sách Phiếu Phạt</h2>
          </div>
          <div>
            <div className="rounded-md border overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Mã PP</TableHead>
                    <TableHead>Mã PM</TableHead>
                    <TableHead>Mã ĐG</TableHead>
                    <TableHead>Tên Độc Giả</TableHead>
                    <TableHead>Mã Cuốn Sách</TableHead>
                    <TableHead>Ngày Lập</TableHead>
                    <TableHead>Lý Do</TableHead>
                    <TableHead className="text-right">Số Tiền Phạt</TableHead>
                    <TableHead className="text-center">Trạng Thái</TableHead>
                    <TableHead className="text-right">Hành Động</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loadingFines ? (
                    <TableRow>
                      <TableCell colSpan={10} className="text-center h-24">Đang tải phiếu phạt...</TableCell>
                    </TableRow>
                  ) : fineSlips.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={10} className="text-center h-24">Không có phiếu phạt nào</TableCell>
                    </TableRow>
                  ) : (
                    fineSlips.map((fine, idx) => {
                      const f = fine as typeof fine & Record<string, unknown>;
                      const mapp = f.MAPP || f.maPP || f.maPT || '-';
                      const mapm = f.MAPM || f.mapm || '-';
                      const madg = f.MADG || f.madg || '-';
                      const tendg = f.TENDG || f.tendg || '-';
                      const macs = f.MACS || f.macs || '-';
                      const ngayLap = ((f.NGAYLAP || f.ngayThu || f.ngaylap) as string | undefined)?.split('T')[0] || '-';
                      const lydo = f.LYDO || f.lydo || 'Vi phạm quy định';
                      const sotien = Number(f.SOTIEN ?? f.soTienThu ?? f.sotien ?? 0);
                      const isPaid = Boolean(f.DATHANHTOAN ?? f.dathanhtoan);

                      return (
                        <TableRow key={`${mapp}-${idx}`}>
                          <TableCell className="font-medium font-mono text-xs">{mapp}</TableCell>
                          <TableCell className="font-mono text-xs">{mapm}</TableCell>
                          <TableCell className="font-mono text-xs">{madg}</TableCell>
                          <TableCell className="font-medium">{tendg}</TableCell>
                          <TableCell className="font-mono text-xs">{macs}</TableCell>
                          <TableCell>{ngayLap}</TableCell>
                          <TableCell>{lydo}</TableCell>
                          <TableCell className="text-right font-bold text-rose-600">
                            {sotien.toLocaleString('vi-VN')} đ
                          </TableCell>
                          <TableCell className="text-center">
                            {isPaid ? (
                              <Badge className="bg-green-100 text-green-800 hover:bg-green-100 border-none">
                                <CheckCircle className="w-3 h-3 mr-1" /> Đã thu
                              </Badge>
                            ) : (
                              <Badge className="bg-red-100 text-red-800 hover:bg-red-100 border-none">
                                Chưa thu
                              </Badge>
                            )}
                          </TableCell>
                          <TableCell className="text-right">
                            {!isPaid && madg !== '-' ? (
                              <Button
                                size="sm"
                                variant="outline"
                                disabled={payingFine}
                                onClick={() => handlePayFine(madg)}
                                className="text-xs"
                              >
                                <CreditCard className="w-3.5 h-3.5 mr-1" />
                                Thu tiền
                              </Button>
                            ) : (
                              <span className="text-xs text-muted-foreground">-</span>
                            )}
                          </TableCell>
                        </TableRow>
                      );
                    })
                  )}
                </TableBody>
              </Table>
            </div>
            <DataTablePagination page={finePage} totalPages={fineTotalPages} onPageChange={setFinePage} />
          </div>
        </TabsContent>
      </Tabs>

      <UpdateTransactionDialog 
        transaction={selectedTransaction} 
        open={isUpdateOpen} 
        onOpenChange={setIsUpdateOpen} 
        onSuccess={fetchTransactions} 
      />
    </div>
  );
}
