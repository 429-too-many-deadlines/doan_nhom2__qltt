import { useState, useEffect } from 'react';
import { reportsService } from '../services/reports.service';
import type { MonthlyStatsResponse } from '../types/api.types';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { Input } from '../components/ui/input';
import { Button } from '../components/ui/button';

export default function Dashboard() {
  const currentDate = new Date();
  const [month, setMonth] = useState(currentDate.getMonth() + 1);
  const [year, setYear] = useState(currentDate.getFullYear());
  
  const [stats, setStats] = useState<MonthlyStatsResponse | null>(null);
  const [loading, setLoading] = useState(false);

  const fetchStats = async () => {
    try {
      setLoading(true);
      const data = await reportsService.getMonthlyStats(month, year);
      setStats(data);
    } catch (_error) {
      console.error(error);
      // toast.error('Lỗi khi tải thống kê tổng quan');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchStats();
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []); // Fetch current month on mount

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    fetchStats();
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Tổng Quan (Dashboard)</h1>
      
      <Card>
        <CardHeader>
          <CardTitle>Lọc Theo Tháng/Năm</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="flex gap-4 items-end">
            <div className="space-y-2">
              <label className="text-sm font-medium">Tháng</label>
              <Input 
                type="number" min="1" max="12" 
                value={month} 
                onChange={(e) => setMonth(Number(e.target.value))} 
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">Năm</label>
              <Input 
                type="number" min="2000" 
                value={year} 
                onChange={(e) => setYear(Number(e.target.value))} 
              />
            </div>
            <Button type="submit" disabled={loading}>
              Cập nhật
            </Button>
          </form>
        </CardContent>
      </Card>

      {loading ? (
        <p className="text-center py-10">Đang tải thống kê...</p>
      ) : stats ? (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">Số Phiếu Mượn</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold">{stats.SOPHIEU || 0}</div>
            </CardContent>
          </Card>
          
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">Số Lượt Mượn Sách</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold">{stats.SOLUOTSACH || 0}</div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">Tiền Phạt Thu Được</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold">{stats.TIENPHAT?.toLocaleString() || 0} đ</div>
            </CardContent>
          </Card>

          <Card className="md:col-span-3">
            <CardHeader>
              <CardTitle>Top 5 Sách Mượn Nhiều Nhất</CardTitle>
            </CardHeader>
            <CardContent>
              {stats.top5Books && stats.top5Books.length > 0 ? (
                <ul className="space-y-4">
                  {stats.top5Books.map((book, idx) => (
                    <li key={book.maSach || idx} className="flex justify-between items-center p-4 border rounded-lg">
                      <div>
                        <p className="font-medium">{book.tenSach}</p>
                        <p className="text-sm text-muted-foreground">Mã: {book.maSach}</p>
                      </div>
                      <div className="font-bold text-lg">
                        {book.SOLUOTMUON} lượt
                      </div>
                    </li>
                  ))}
                </ul>
              ) : (
                <p className="text-muted-foreground text-center py-4">Không có dữ liệu sách trong tháng này.</p>
              )}
            </CardContent>
          </Card>
        </div>
      ) : null}
    </div>
  );
}
