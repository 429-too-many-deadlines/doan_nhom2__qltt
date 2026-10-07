import { DataTablePagination } from '../components/ui/data-table-pagination';
import { useState, useEffect } from 'react';
import { reportsService } from '../services/reports.service';
import type { MonthlyStatsResponse, TopBookResponse, GenericApiResponse } from '../types/api.types';

import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../components/ui/table';

export default function Reports() {
  const [reportData, setReportData] = useState<GenericApiResponse[]>([]);
  const [monthlyStats, setMonthlyStats] = useState<MonthlyStatsResponse | null>(null);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [activeReport, setActiveReport] = useState<string>('');

  const [month, setMonth] = useState(new Date().getMonth() + 1);
  const [year, setYear] = useState(new Date().getFullYear());

  const fetchReport = async (reportType: string, fetchFn: () => Promise<GenericApiResponse[]>) => {
    try {
      setLoading(true);
      setActiveReport(reportType);
      setMonthlyStats(null);
      const data = await fetchFn();
      setReportData(data || []);
      // toast.success(`Tải báo cáo ${reportType} thành công`);
    } catch (_error) {
      console.error(error);
      // toast.error('Lỗi khi tải báo cáo');
      setReportData([]);
    } finally {
      setLoading(false);
    }
  };

  const handleMonthlyStats = async () => {
    try {
      setLoading(true);
      setActiveReport('Thống kê tháng');
      setReportData([]);
      const data = await reportsService.getMonthlyStats(month, year);
      setMonthlyStats(data);
      // toast.success('Tải thống kê tháng thành công');
    } catch (_error) {
      console.error(error);
      // toast.error('Lỗi khi tải thống kê tháng');
      setMonthlyStats(null);
    } finally {
      setLoading(false);
    }
  };

  const getColumns = () => {
    if (reportData.length === 0) return [];
    return Object.keys(reportData[0]);
  };

  const columns = getColumns();
  const pageSize = 10;
  const computedTotalPages = Math.ceil(reportData.length / pageSize) || 1;
  const paginatedReportData = reportData.slice((page - 1) * pageSize, page * pageSize);

  // Update totalPages state if computed changes
  useEffect(() => {
    setTotalPages(computedTotalPages);
  }, [computedTotalPages]);

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Báo Cáo Thống Kê</h1>
      
      <div className="space-y-4">
        <div className="mb-4">
          <h2 className="text-xl font-semibold">Chọn Loại Báo Cáo</h2>
        </div>
        <div className="flex flex-wrap gap-4">
          <Button 
            variant={activeReport === 'Lượt mượn theo tháng' ? 'default' : 'outline'}
            onClick={() => fetchReport('Lượt mượn theo tháng', reportsService.getBorrowsByMonth)}
          >
            Lượt mượn theo tháng
          </Button>
          <Button 
            variant={activeReport === 'Tiền phạt theo tháng' ? 'default' : 'outline'}
            onClick={() => fetchReport('Tiền phạt theo tháng', reportsService.getFinesByMonth)}
          >
            Tiền phạt theo tháng
          </Button>
          <Button 
            variant={activeReport === 'Tồn kho sách' ? 'default' : 'outline'}
            onClick={() => fetchReport('Tồn kho sách', reportsService.getInventoryReport)}
          >
            Tồn kho sách
          </Button>
          <Button 
            variant={activeReport === 'Hiệu suất nhân viên' ? 'default' : 'outline'}
            onClick={() => fetchReport('Hiệu suất nhân viên', reportsService.getLibrarianPerformance)}
          >
            Hiệu suất NV
          </Button>
          <Button 
            variant={activeReport === 'Độc giả trễ hạn' ? 'default' : 'outline'}
            onClick={() => fetchReport('Độc giả trễ hạn', reportsService.getOverdueReaders)}
          >
            Độc giả trễ hạn
          </Button>
          <Button 
            variant={activeReport === 'Sách mượn nhiều nhất' ? 'default' : 'outline'}
            onClick={() => fetchReport('Sách mượn nhiều nhất', reportsService.getTopBorrowedBooks)}
          >
            Top Sách
          </Button>
          <Button 
            variant={activeReport === 'Xếp loại độc giả' ? 'default' : 'outline'}
            onClick={() => fetchReport('Xếp loại độc giả', reportsService.runRankingCursor)}
          >
            Xếp loại độc giả
          </Button>
          <Button 
            variant={activeReport === 'Nhắc nhở quá hạn' ? 'default' : 'outline'}
            onClick={() => fetchReport('Nhắc nhở quá hạn', () => reportsService.runReminderCursor())}
          >
            Nhắc nhở quá hạn
          </Button>
        </div>
      </div>

      <div className="space-y-4">
        <div className="mb-4">
          <h2 className="text-xl font-semibold">Thống kê tháng</h2>
        </div>
        <div>
          <div className="flex gap-4 items-end mb-4">
            <div className="space-y-2">
              <label className="text-sm font-medium">Tháng</label>
              <Input type="number" min={1} max={12} value={month} onChange={e => setMonth(Number(e.target.value))} />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">Năm</label>
              <Input type="number" min={1900} max={2100} value={year} onChange={e => setYear(Number(e.target.value))} />
            </div>
            <Button onClick={handleMonthlyStats} variant={activeReport === 'Thống kê tháng' ? 'default' : 'outline'}>
              Xem thống kê
            </Button>
          </div>
          {monthlyStats && (
            <div className="space-y-4">
              <div className="grid grid-cols-3 gap-4">
                <div className="p-4 border rounded shadow-sm text-center">
                  <div className="text-sm text-gray-500">Số Phiếu Mượn</div>
                  <div className="text-xl font-bold">{monthlyStats.SOPHIEU}</div>
                </div>
                <div className="p-4 border rounded shadow-sm text-center">
                  <div className="text-sm text-gray-500">Số Lượt Sách</div>
                  <div className="text-xl font-bold">{monthlyStats.SOLUOTSACH}</div>
                </div>
                <div className="p-4 border rounded shadow-sm text-center">
                  <div className="text-sm text-gray-500">Tiền Phạt</div>
                  <div className="text-xl font-bold">{monthlyStats.TIENPHAT?.toLocaleString()} VNĐ</div>
                </div>
              </div>
              <h3 className="font-bold mt-4">Top 5 Sách Mượn Nhiều Nhất</h3>
              <div className="rounded-md border overflow-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      {monthlyStats.top5Books.length > 0 && Object.keys(monthlyStats.top5Books[0]).map(col => (
                        <TableHead key={col}>{col}</TableHead>
                      ))}
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {monthlyStats.top5Books.map((row: TopBookResponse, idx: number) => (
                      <TableRow key={idx}>
                        {Object.keys(row).map(col => (
                          <TableCell key={col}>{String(row[col as keyof TopBookResponse])}</TableCell>
                        ))}
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
          </div>
            </div>
          )}
        </div>
      </div>

      {(activeReport && activeReport !== 'Thống kê tháng') && (
        <div className="space-y-4">
          <div className="mb-4">
            <h2 className="text-xl font-semibold">{`Kết quả: ${activeReport}`}</h2>
          </div>
          <div>
            <div className="rounded-md border overflow-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    {columns.map(col => (
                      <TableHead key={col}>{col}</TableHead>
                    ))}
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loading ? (
                    <TableRow>
                      <TableCell colSpan={columns.length || 1} className="h-24 text-center">
                        Đang tải...
                      </TableCell>
                    </TableRow>
                  ) : reportData.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={columns.length || 1} className="h-24 text-center">
                        Không có dữ liệu
                      </TableCell>
                    </TableRow>
                  ) : (
                    paginatedReportData.map((row, idx) => (
                      <TableRow key={idx}>
                        {columns.map(col => (
                          <TableCell key={col}>{String(row[col])}</TableCell>
                        ))}
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
          </div>
          <DataTablePagination page={page} totalPages={totalPages} onPageChange={setPage} />
          </div>
        </div>
      )}
    </div>
  );
}

