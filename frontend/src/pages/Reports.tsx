import { useState } from 'react';
import { reportsService } from '../services/reports.service';
import type { GenericApiResponse } from '../types/api.types';
import { toast } from 'sonner';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { Button } from '../components/ui/button';
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
  const [loading, setLoading] = useState(false);
  const [activeReport, setActiveReport] = useState<string>('');

  const fetchReport = async (reportType: string, fetchFn: () => Promise<GenericApiResponse[]>) => {
    try {
      setLoading(true);
      setActiveReport(reportType);
      const data = await fetchFn();
      setReportData(data || []);
      toast.success(`Tải báo cáo ${reportType} thành công`);
    } catch (error) {
      console.error(error);
      toast.error('Lỗi khi tải báo cáo');
      setReportData([]);
    } finally {
      setLoading(false);
    }
  };

  const getColumns = () => {
    if (reportData.length === 0) return [];
    return Object.keys(reportData[0]);
  };

  const columns = getColumns();

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Báo Cáo Thống Kê</h1>
      
      <Card>
        <CardHeader>
          <CardTitle>Chọn Loại Báo Cáo</CardTitle>
        </CardHeader>
        <CardContent className="flex flex-wrap gap-4">
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
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>{activeReport ? `Kết quả: ${activeReport}` : 'Kết quả báo cáo'}</CardTitle>
        </CardHeader>
        <CardContent>
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
                  reportData.map((row, idx) => (
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
        </CardContent>
      </Card>
    </div>
  );
}
