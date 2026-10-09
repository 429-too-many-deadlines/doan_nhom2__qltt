import { useState, useEffect } from 'react';
import { reportsService } from '../../../services/reports.service';
import type { MonthlyStatsResponse } from '../../../types/api.types';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../../ui/card';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../../ui/table';
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
} from 'recharts';
import { BookOpen, FileText, CircleDollarSign } from 'lucide-react';

import { ReportTabSkeleton } from './ReportSkeleton';

interface MonthlyOverviewTabProps {
  month: number;
  year: number;
}

const statsCache = new Map<string, MonthlyStatsResponse>();

export const MonthlyOverviewTab = ({ month, year }: MonthlyOverviewTabProps) => {
  const cacheKey = `${month}-${year}`;
  const [stats, setStats] = useState<MonthlyStatsResponse | null>(() => statsCache.get(cacheKey) || null);
  const [loading, setLoading] = useState(!statsCache.has(cacheKey));

  useEffect(() => {
    let isMounted = true;
    const cached = statsCache.get(cacheKey);
    if (cached) {
      setStats(cached);
    } else {
      setLoading(true);
    }

    const fetchStats = async () => {
      try {
        const data = await reportsService.getMonthlyStats(month, year);
        statsCache.set(cacheKey, data);
        if (isMounted) {
          setStats(data);
        }
      } catch (error) {
        console.error('Lỗi khi tải thống kê tháng:', error);
        if (isMounted && !cached) setStats(null);
      } finally {
        if (isMounted) setLoading(false);
      }
    };

    fetchStats();
    return () => {
      isMounted = false;
    };
  }, [cacheKey, month, year]);

  if (loading && !stats) {
    return <ReportTabSkeleton />;
  }

  const soPhieu = stats?.soPhieu ?? stats?.SOPHIEU ?? 0;
  const soLuotSach = stats?.soLuotSach ?? stats?.SOLUOTSACH ?? 0;
  const tienPhat = stats?.tienPhat ?? stats?.TIENPHAT ?? 0;

  const chartData = (stats?.top5Books || []).map((book) => ({
    maSach: book.maSach || book.MADS || '',
    tenSach: book.tenSach || book.TENDS || 'Chưa rõ',
    SOLUOTMUON: book.SOLUOTMUON ?? 0,
  }));

  return (
    <div className="space-y-6">
      {/* 3 KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Số Phiếu Mượn
            </CardTitle>
            <FileText className="h-4 w-4 text-blue-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {loading ? '...' : soPhieu.toLocaleString('vi-VN')}
            </div>
            <p className="text-xs text-muted-foreground mt-1">
              Tháng {month}/{year}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Lượt Mượn Sách
            </CardTitle>
            <BookOpen className="h-4 w-4 text-emerald-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {loading ? '...' : soLuotSach.toLocaleString('vi-VN')}
            </div>
            <p className="text-xs text-muted-foreground mt-1">
              Tổng số cuốn sách được mượn
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Tiền Phạt Thu Được
            </CardTitle>
            <CircleDollarSign className="h-4 w-4 text-amber-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {loading ? '...' : `${tienPhat.toLocaleString('vi-VN')} đ`}
            </div>
            <p className="text-xs text-muted-foreground mt-1">
              Các khoản phạt quá hạn & bồi hoàn
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Top 5 Sách BarChart & Bảng chi tiết */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        <Card className="lg:col-span-7">
          <CardHeader>
            <CardTitle>Top 5 Sách Mượn Nhiều Nhất</CardTitle>
            <CardDescription>
              Biểu đồ trực quan lượt mượn trong tháng {month}/{year}
            </CardDescription>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="h-[300px] flex items-center justify-center text-muted-foreground">
                Đang tải dữ liệu biểu đồ...
              </div>
            ) : chartData.length === 0 ? (
              <div className="h-[300px] flex items-center justify-center text-muted-foreground">
                Không có dữ liệu mượn sách trong tháng {month}/{year}.
              </div>
            ) : (
              <div className="h-[300px] w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={chartData} margin={{ top: 10, right: 20, left: -10, bottom: 40 }}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} strokeOpacity={0.4} />
                    <XAxis
                      dataKey="tenSach"
                      interval={0}
                      tick={{ fontSize: 12 }}
                      tickFormatter={(value: string) =>
                        value.length > 16 ? `${value.slice(0, 16)}...` : value
                      }
                      angle={-15}
                      textAnchor="end"
                    />
                    <YAxis allowDecimals={false} tick={{ fontSize: 12 }} />
                    <Tooltip
                      formatter={(value: any) => [`${value} lượt mượn`, 'Số lượt mượn']}
                      labelFormatter={(label: any) => `Sách: ${label}`}
                      contentStyle={{
                        borderRadius: '8px',
                        backgroundColor: 'var(--background, #fff)',
                        borderColor: 'var(--border, #e2e8f0)',
                      }}
                    />
                    <Bar
                      dataKey="SOLUOTMUON"
                      name="Số lượt mượn"
                      fill="#3b82f6"
                      radius={[4, 4, 0, 0]}
                    />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            )}
          </CardContent>
        </Card>

        <Card className="lg:col-span-5">
          <CardHeader>
            <CardTitle>Bảng Chi Tiết Top 5 Sách</CardTitle>
            <CardDescription>Danh sách cụ thể lượt mượn</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="rounded-md border overflow-hidden">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead className="w-[80px]">Mã</TableHead>
                    <TableHead>Tên Sách</TableHead>
                    <TableHead className="text-right">Lượt</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loading ? (
                    <TableRow>
                      <TableCell colSpan={3} className="text-center py-6 text-muted-foreground">
                        Đang tải...
                      </TableCell>
                    </TableRow>
                  ) : chartData.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={3} className="text-center py-6 text-muted-foreground">
                        Chưa có dữ liệu
                      </TableCell>
                    </TableRow>
                  ) : (
                    chartData.map((book, idx) => (
                      <TableRow key={book.maSach || idx}>
                        <TableCell className="font-mono text-xs text-muted-foreground">
                          {book.maSach || '-'}
                        </TableCell>
                        <TableCell className="font-medium max-w-[180px] truncate" title={book.tenSach}>
                          {book.tenSach}
                        </TableCell>
                        <TableCell className="text-right font-bold text-blue-600">
                          {book.SOLUOTMUON}
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
};

