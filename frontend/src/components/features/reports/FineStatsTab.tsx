import { useState, useEffect, useMemo } from 'react';
import { reportsService } from '../../../services/reports.service';
import type { GenericApiResponse } from '../../../types/api.types';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../../ui/card';
import { Badge } from '../../ui/badge';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../../ui/table';
import { DataTablePagination } from '../../ui/data-table-pagination';
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  CartesianGrid,
} from 'recharts';
import { CircleDollarSign, CheckCircle, AlertOctagon, UserX, Calendar } from 'lucide-react';

const REASON_COLORS: Record<string, string> = {
  'Trễ hạn': '#ef4444',
  'Hư hỏng': '#f59e0b',
  'Mất sách': '#8b5cf6',
  'Khác': '#64748b',
};

const DEFAULT_COLORS = ['#ef4444', '#f59e0b', '#8b5cf6', '#3b82f6', '#10b981'];

export const FineStatsTab = () => {
  const [finesData, setFinesData] = useState<GenericApiResponse[]>([]);
  const [overdueReaders, setOverdueReaders] = useState<GenericApiResponse[]>([]);
  const [loading, setLoading] = useState(false);
  const [selectedYear, setSelectedYear] = useState<number>(new Date().getFullYear());
  const [page, setPage] = useState(1);
  const pageSize = 10;

  useEffect(() => {
    let isMounted = true;
    const fetchData = async () => {
      try {
        setLoading(true);
        const [finesRes, overdueRes] = await Promise.all([
          reportsService.getFinesByMonth(),
          reportsService.getOverdueReaders(),
        ]);
        if (isMounted) {
          const list = finesRes || [];
          setFinesData(list);
          setOverdueReaders(overdueRes || []);

          const years = Array.from(new Set(list.map((r) => Number(r.NAM || r.nam)))).filter(Boolean);
          if (years.length > 0 && !years.includes(selectedYear)) {
            setSelectedYear(Math.max(...years));
          }
        }
      } catch (err) {
        console.error('Lỗi khi tải dữ liệu phạt & quá hạn:', err);
        if (isMounted) {
          setFinesData([]);
          setOverdueReaders([]);
        }
      } finally {
        if (isMounted) setLoading(false);
      }
    };

    fetchData();
    return () => {
      isMounted = false;
    };
  }, []);

  // Available years from fines data
  const availableYears = useMemo(() => {
    const years = Array.from(new Set(finesData.map((r) => Number(r.NAM || r.nam)))).filter(Boolean);
    if (!years.includes(selectedYear)) {
      years.push(selectedYear);
    }
    return years.sort((a, b) => b - a);
  }, [finesData, selectedYear]);

  // Filter fines by selected year
  const finesOfYear = useMemo(() => {
    return finesData.filter((r) => Number(r.NAM || r.nam) === selectedYear);
  }, [finesData, selectedYear]);

  // Overall fine sums for the selected year
  const fineSummary = useMemo(() => {
    let tongTien = 0;
    let daThu = 0;
    let chuaThu = 0;
    finesOfYear.forEach((r) => {
      tongTien += Number(r.TONGTIEN || r.tongtien || 0);
      daThu += Number(r.DATHU || r.dathu || 0);
      chuaThu += Number(r.CHUATHU || r.chuathu || 0);
    });
    return { tongTien, daThu, chuaThu };
  }, [finesOfYear]);

  // Pie chart by reason
  const reasonPieData = useMemo(() => {
    const map = new Map<string, number>();
    finesOfYear.forEach((r) => {
      const reason = String(r.LYDO || r.lydo || 'Khác');
      const amount = Number(r.TONGTIEN || r.tongtien || 0);
      map.set(reason, (map.get(reason) || 0) + amount);
    });

    return Array.from(map.entries()).map(([name, value], idx) => ({
      name,
      value,
      color: REASON_COLORS[name] || DEFAULT_COLORS[idx % DEFAULT_COLORS.length],
    }));
  }, [finesOfYear]);

  // Monthly collection comparison (1..12)
  const monthlyBarData = useMemo(() => {
    const months = Array.from({ length: 12 }, (_, i) => i + 1);
    return months.map((m) => {
      const records = finesOfYear.filter((r) => Number(r.THANG || r.thang) === m);
      const daThu = records.reduce((s, r) => s + Number(r.DATHU || r.dathu || 0), 0);
      const chuaThu = records.reduce((s, r) => s + Number(r.CHUATHU || r.chuathu || 0), 0);
      return {
        thang: `T${m}`,
        DATHU: daThu,
        CHUATHU: chuaThu,
        total: daThu + chuaThu,
      };
    });
  }, [finesOfYear]);

  // Paginated overdue readers
  const totalPages = Math.ceil(overdueReaders.length / pageSize) || 1;
  const paginatedOverdue = useMemo(() => {
    const start = (page - 1) * pageSize;
    return overdueReaders.slice(start, start + pageSize);
  }, [overdueReaders, page]);

  return (
    <div className="space-y-6">
      {/* KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Tổng Tiền Phạt ({selectedYear})
            </CardTitle>
            <CircleDollarSign className="h-4 w-4 text-blue-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {loading ? '...' : `${fineSummary.tongTien.toLocaleString('vi-VN')} đ`}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Toàn bộ vi phạm phát sinh</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Đã Thu ({selectedYear})
            </CardTitle>
            <CheckCircle className="h-4 w-4 text-emerald-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-emerald-600">
              {loading ? '...' : `${fineSummary.daThu.toLocaleString('vi-VN')} đ`}
            </div>
            <p className="text-xs text-muted-foreground mt-1">
              Tỉ lệ:{' '}
              {fineSummary.tongTien > 0
                ? `${((fineSummary.daThu / fineSummary.tongTien) * 100).toFixed(1)}%`
                : '0%'}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Chưa Thu / Nợ Phạt
            </CardTitle>
            <AlertOctagon className="h-4 w-4 text-rose-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-rose-600">
              {loading ? '...' : `${fineSummary.chuaThu.toLocaleString('vi-VN')} đ`}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Đang chờ độc giả thanh toán</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Độc Giả Trễ Hạn Hiện Tại
            </CardTitle>
            <UserX className="h-4 w-4 text-amber-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-amber-600">
              {loading ? '...' : overdueReaders.length}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Đang mượn quá hạn tính đến nay</p>
          </CardContent>
        </Card>
      </div>

      {/* Year Filter */}
      <div className="flex items-center gap-3 bg-muted/30 p-3 rounded-lg border w-fit">
        <Calendar className="h-4 w-4 text-primary" />
        <label className="text-sm font-medium">Năm thống kê:</label>
        <select
          value={selectedYear}
          onChange={(e) => setSelectedYear(Number(e.target.value))}
          className="border rounded-md px-3 py-1 text-sm bg-background focus:outline-none focus:ring-2 focus:ring-ring"
        >
          {availableYears.map((y) => (
            <option key={y} value={y}>
              Năm {y}
            </option>
          ))}
        </select>
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Pie: Fine Reasons */}
        <Card className="lg:col-span-5">
          <CardHeader>
            <CardTitle>Cơ Cấu Tiền Phạt Theo Lý Do</CardTitle>
            <CardDescription>Tỉ lệ phân bổ các khoản phạt trong năm {selectedYear}</CardDescription>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="h-[320px] flex items-center justify-center text-muted-foreground">
                Đang tải dữ liệu...
              </div>
            ) : reasonPieData.length === 0 ? (
              <div className="h-[320px] flex items-center justify-center text-muted-foreground">
                Không có dữ liệu tiền phạt trong năm {selectedYear}.
              </div>
            ) : (
              <div className="h-[320px] w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={reasonPieData}
                      dataKey="value"
                      nameKey="name"
                      cx="50%"
                      cy="50%"
                      innerRadius={55}
                      outerRadius={90}
                      paddingAngle={3}
                      label={({ name, percent }: any) =>
                        `${name}: ${((percent || 0) * 100).toFixed(0)}%`
                      }
                      labelLine={false}
                    >
                      {reasonPieData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip
                      formatter={(val: any) => [`${Number(val).toLocaleString('vi-VN')} đ`, 'Số tiền']}
                      contentStyle={{
                        borderRadius: '8px',
                        backgroundColor: 'var(--background, #fff)',
                        borderColor: 'var(--border, #e2e8f0)',
                      }}
                    />
                    <Legend verticalAlign="bottom" height={36} />
                  </PieChart>
                </ResponsiveContainer>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Bar: Paid vs Unpaid Monthly */}
        <Card className="lg:col-span-7">
          <CardHeader>
            <CardTitle>So Sánh Thu Phạt Qua 12 Tháng</CardTitle>
            <CardDescription>Tiền phạt Đã thu vs Chưa thu theo từng tháng ({selectedYear})</CardDescription>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="h-[320px] flex items-center justify-center text-muted-foreground">
                Đang tải dữ liệu...
              </div>
            ) : (
              <div className="h-[320px] w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={monthlyBarData} margin={{ top: 10, right: 20, left: 10, bottom: 10 }}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} strokeOpacity={0.4} />
                    <XAxis dataKey="thang" tick={{ fontSize: 12 }} />
                    <YAxis
                      tick={{ fontSize: 11 }}
                      tickFormatter={(v) => (v >= 1000000 ? `${v / 1000000}M` : v >= 1000 ? `${v / 1000}k` : v)}
                    />
                    <Tooltip
                      formatter={(val: any) => [`${Number(val).toLocaleString('vi-VN')} đ`]}
                      contentStyle={{
                        borderRadius: '8px',
                        backgroundColor: 'var(--background, #fff)',
                        borderColor: 'var(--border, #e2e8f0)',
                      }}
                    />
                    <Legend wrapperStyle={{ paddingTop: 10 }} />
                    <Bar dataKey="DATHU" name="Đã thu" fill="#10b981" radius={[4, 4, 0, 0]} />
                    <Bar dataKey="CHUATHU" name="Chưa thu" fill="#ef4444" radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Warning Table: Overdue Readers */}
      <Card className="border-amber-200/50">
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="text-amber-700 dark:text-amber-400 flex items-center gap-2">
                <AlertOctagon className="h-5 w-5" />
                Danh Sách Độc Giả Giữ Sách Quá Hạn
              </CardTitle>
              <CardDescription>
                Cảnh báo những độc giả chưa trả sách tính đến thời điểm hiện tại
              </CardDescription>
            </div>
            <Badge variant="outline" className="border-amber-500 text-amber-600">
              {overdueReaders.length} trường hợp
            </Badge>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="rounded-md border overflow-hidden">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="w-[90px]">Mã ĐG</TableHead>
                  <TableHead>Họ Tên Độc Giả</TableHead>
                  <TableHead>Số ĐT</TableHead>
                  <TableHead>Tên Sách Mượn</TableHead>
                  <TableHead>Ngày Mượn</TableHead>
                  <TableHead>Hạn Trả</TableHead>
                  <TableHead className="text-center">Số Ngày Trễ</TableHead>
                  <TableHead className="text-right">Phạt Tạm Tính</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {loading ? (
                  <TableRow>
                    <TableCell colSpan={8} className="text-center py-6 text-muted-foreground">
                      Đang tải danh sách quá hạn...
                    </TableCell>
                  </TableRow>
                ) : paginatedOverdue.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={8} className="text-center py-6 text-muted-foreground">
                      Tuyệt vời! Hiện tại không có độc giả nào giữ sách quá hạn.
                    </TableCell>
                  </TableRow>
                ) : (
                  paginatedOverdue.map((row, idx) => {
                    const daysOverdue = Number(row.SONGAYTRE || row.songaytre || 0);
                    return (
                      <TableRow key={idx}>
                        <TableCell className="font-mono text-xs text-muted-foreground">
                          {String(row.MADG || row.madg || '-')}
                        </TableCell>
                        <TableCell className="font-medium">
                          {String(row.HOTEN || row.hoten || '')}
                        </TableCell>
                        <TableCell>{String(row.SODT || row.sodt || '-')}</TableCell>
                        <TableCell className="max-w-[200px] truncate" title={String(row.TENDS || row.tends)}>
                          {String(row.TENDS || row.tends || '')}
                        </TableCell>
                        <TableCell>
                          {row.NGAYMUON || row.ngaymuon
                            ? new Date(String(row.NGAYMUON || row.ngaymuon)).toLocaleDateString('vi-VN')
                            : '-'}
                        </TableCell>
                        <TableCell>
                          {row.HANTRA || row.hantra
                            ? new Date(String(row.HANTRA || row.hantra)).toLocaleDateString('vi-VN')
                            : '-'}
                        </TableCell>
                        <TableCell className="text-center">
                          <Badge
                            className={
                              daysOverdue > 14
                                ? 'bg-red-500 hover:bg-red-600 text-white'
                                : 'bg-amber-500 hover:bg-amber-600 text-white'
                            }
                          >
                            {daysOverdue} ngày
                          </Badge>
                        </TableCell>
                        <TableCell className="text-right font-bold text-rose-600">
                          {Number(row.TIENPHATTAMTINH || row.tienphattamtinh || 0).toLocaleString('vi-VN')} đ
                        </TableCell>
                      </TableRow>
                    );
                  })
                )}
              </TableBody>
            </Table>
          </div>

          <DataTablePagination page={page} totalPages={totalPages} onPageChange={setPage} />
        </CardContent>
      </Card>
    </div>
  );
};

