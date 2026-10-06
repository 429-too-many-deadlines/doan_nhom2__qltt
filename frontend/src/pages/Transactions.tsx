import { DataTablePagination } from '../components/ui/data-table-pagination';
import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { toast } from 'sonner';
import { transactionsService } from '@/services/transactions.service';
import { Trash2, Edit } from 'lucide-react';
import type { BorrowSlip } from '@/types/api.types';
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
  const [transactions, setTransactions] = useState<BorrowSlip[]>([]);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [selectedTransaction, setSelectedTransaction] = useState<BorrowSlip | null>(null);
  const [isUpdateOpen, setIsUpdateOpen] = useState(false);

  const fetchTransactions = async () => {
    setLoading(true);
    try {
      const dataResult = await transactionsService.getBorrowSlips(page, 10);
      // Handle both PagedResult and array responses
      const data = 'items' in dataResult ? dataResult.items : (Array.isArray(dataResult) ? dataResult : []);
      const total = 'totalPages' in dataResult ? dataResult.totalPages : 1;
      setTotalPages(total);
      setTransactions(data);
    } catch {
      toast.error('Lỗi khi tải danh sách giao dịch');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTransactions();
  }, [page]);

  const handleDelete = async (MAPM: string, MACS: string) => {
    try {
      // Backend does not currently support delete via API, so we show an error toast
      toast.error('Chức năng xoá chưa được hỗ trợ bởi API');
      console.log('Delete clicked for', MAPM, MACS);
    } catch {
      toast.error('Lỗi khi xoá.');
    }
  };

  const handleEdit = (transaction: BorrowSlip) => {
    setSelectedTransaction(transaction);
    setIsUpdateOpen(true);
  };

  return (
    <div className="space-y-6 p-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold tracking-tight">Quản lý Giao dịch</h1>
      </div>

      <div className="grid grid-cols-1 gap-6">
        <Card className="col-span-1">
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle>Danh sách Giao dịch</CardTitle>
            <div className="flex items-center space-x-2">
              <Input placeholder="Tìm kiếm..." className="w-64" />
              <CreateTransactionDialog onSuccess={fetchTransactions} />
            </div>
          </CardHeader>
          <CardContent>
            <div className="rounded-md border">
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
                    transactions.map((transaction, index) => (
                      <TableRow key={`${transaction.MAPM}-${transaction.MACS}-${index}`}>
                        <TableCell className="font-medium">{transaction.MAPM}</TableCell>
                        <TableCell>{transaction.MADG}</TableCell>
                        <TableCell>{transaction.TENDG}</TableCell>
                        <TableCell>{transaction.MACS}</TableCell>
                        <TableCell>{transaction.NGAYMUON?.split('T')[0]}</TableCell>
                        <TableCell>{transaction.HANTRA?.split('T')[0]}</TableCell>
                        <TableCell>{transaction.NGAYTRA?.split('T')[0] || 'Chưa trả'}</TableCell>
                        <TableCell>{transaction.TINHTRANG}</TableCell>
                        <TableCell>{transaction.TINHTRANGTRA}</TableCell>
                        <TableCell>
                          <div className="flex gap-2">
                            <Button size="icon" variant="outline" onClick={() => handleEdit(transaction)}>
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
                                    Hành động này không thể hoàn tác. Giao dịch này sẽ bị xoá vĩnh viễn khỏi hệ thống.
                                  </AlertDialogDescription>
                                </AlertDialogHeader>
                                <AlertDialogFooter>
                                  <AlertDialogCancel>Hủy</AlertDialogCancel>
                                  <AlertDialogAction onClick={() => handleDelete(transaction.MAPM, transaction.MACS)}>Xác nhận</AlertDialogAction>
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

      <UpdateTransactionDialog 
        transaction={selectedTransaction} 
        open={isUpdateOpen} 
        onOpenChange={setIsUpdateOpen} 
        onSuccess={fetchTransactions} 
      />
    </div>
  );
}
