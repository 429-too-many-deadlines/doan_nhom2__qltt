import { useState, useEffect, useMemo } from 'react';
import { reportsService } from '../../../services/reports.service';
import type { GenericApiResponse } from '../../../types/api.types';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../../ui/card';
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
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  CartesianGrid,
} from 'recharts';
import { TrendingUp, Calendar, BookMarked } from 'lucide-react';

const PALETTE = [
  '#2563eb', // blue
  '#10b981', // emerald
  '#f59e0b', // amber
  '#ec4899', // pink
  '#8b5cf6', // purple
  '#06b6d4', // cyan
  '#f97316', // orange
  '#64748b', // slate
];

export const BorrowStatsTab = () => {
  const [rawData, setRawData] = useState<GenericApiResponse[]>([]);
  const [loading, setLoading] = useState(false);
  const [selectedYear, setSelectedYear] = useState<number>(new Date().getFullYear());
  const [page, setPage] = useState(1);
  const pageSize = 10;

  useEffect(() => {
    let isMounted = true;
    const fetchData = async () => {
      try {
        setLoading(true);
        const res = await reportsService.getBorrowsByMonth();
        if (isMounted) {
          const list = res || [];
          setRawData(list);
          // If data has years, pick the max year or keep current
          const years = Array.from(new Set(list.map((r) => Number(r.NAM || r.nam)))).filter(Boolean);
          if (years.length > 0) {
            setSelectedYear(prev => years.includes(prev) ? prev : Math.max(...years));
          }
        }
      } catch (err) {
        console.error('Lỗi khi tải dữ liệu mượn theo tháng:', err);
        if (isMounted) setRawData([]);
      } finally {
        if (isMounted) setLoading(false);
      }
    };

    fetchData();
    return () => {
      isMounted = false;
    };
  }, []);

  // Available years
  const availableYears = useMemo(() => {
    const years = Array.from(new Set(rawData.map((r) => Number(r.NAM || r.nam)))).filter(Boolean);
    if (!years.includes(selectedYear)) {
      years.push(selectedYear);
    }
    return years.sort((a, b) => b - a);
  }, [rawData, selectedYear]);

  // Filtered by selected year
  const dataForYear = useMemo(() => {
    return rawData.filter((r) => Number(r.NAM || r.nam) === selectedYear);
  }, [rawData, selectedYear]);

  // Unique categories for the selected year
  const categories = useMemo(() => {
    const set = new Set<string>();
    dataForYear.forEach((r) => {
      const cat = r.TENTL || r.tentl;
      if (cat) set.add(String(cat));
    });
    return Array.from(set);
  }, [dataForYear]);

  // Pivot chart data: 12 months with values per category
  const chartData = useMemo(() => {
    const months = Array.from({ length: 12 }, (_, i) => i + 1);
    return months.map((m) => {
      const row: Record<string, string | number> = { thang: `Tháng ${m}`, thangNum: m };
      let totalMonth = 0;
      categories.forEach((cat) => {
        const item = dataForYear.find(
          (r) => Number(r.THANG || r.thang) === m && (r.TENTL || r.tentl) === cat
        );
        const val = Number(item?.SOLUOTMUON || item?.soluotmuon || 0);
        row[cat] = val;
        totalMonth += val;
      });
      row.total = totalMonth;
      return row;
    });
  }, [dataForYear, categories]);

  // Total borrows in the selected year
  const totalBorrowsYear = useMemo(() => {
    return dataForYear.reduce(
      (sum, r) => sum + Number(r.SOLUOTMUON || r.soluotmuon || 0),
      0
    );
  }, [dataForYear]);

  // Paginated table data
  const totalPages = Math.ceil(dataForYear.length / pageSize) || 1;
  const paginatedData = useMemo(() => {
    const start = (page - 1) * pageSize;
    return dataForYear.slice(start, start + pageSize);
  }, [dataForYear, page]);

  return (
    <div className="space-y-6">
      {/* Top Filter and Highlights */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-muted/30 p-4 rounded-lg border">
        <div className="flex items-center gap-3">
          <Calendar className="h-5 w-5 text-primary" />
          <div className="flex items-center gap-2">
            <label className="text-sm font-medium">Năm thống kê:</label>
            <select
              value={selectedYear}
              onChange={(e) => {
                setSelectedYear(Number(e.target.value));
                setPage(1);
              }}
              className="border rounded-md px-3 py-1.5 text-sm bg-background focus:outline-none focus:ring-2 focus:ring-ring"
            >
              {availableYears.map((y) => (
                <option key={y} value={y}>
                  Năm {y}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="flex items-center gap-6 text-sm">
          <div className="flex items-center gap-2">
            <BookMarked className="h-4 w-4 text-blue-500" />
            <span>Tổng lượt mượn: </span>
            <span className="font-bold text-base text-blue-600">
              {totalBorrowsYear.toLocaleString('vi-VN')}
            </span>
          </div>
          <div className="flex items-center gap-2">
            <TrendingUp className="h-4 w-4 text-emerald-500" />
            <span>Số thể loại: </span>
            <span className="font-bold text-base">{categories.length}</span>
          </div>
        </div>
      </div>

      {/* Chart Section */}
      <Card>
        <CardHeader>
          <CardTitle>Diễn Biến Lượt Mượn Sách Theo Thể Loại ({selectedYear})</CardTitle>
          <CardDescription>
            Đường biểu diễn số lượt mượn từng thể loại sách qua 12 tháng
          </CardDescription>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="h-[360px] flex items-center justify-center text-muted-foreground">
              Đang tải biểu đồ mượn trả...
            </div>
          ) : dataForYear.length === 0 ? (
            <div className="h-[360px] flex items-center justify-center text-muted-foreground">
              Không có dữ liệu lượt mượn trong năm {selectedYear}.
            </div>
          ) : (
            <div className="h-[360px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={chartData} margin={{ top: 10, right: 30, left: -10, bottom: 10 }}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} strokeOpacity={0.4} />
                  <XAxis dataKey="thang" tick={{ fontSize: 12 }} />
                  <YAxis allowDecimals={false} tick={{ fontSize: 12 }} />
                  <Tooltip
                    contentStyle={{
                      borderRadius: '8px',
                      backgroundColor: 'var(--background, #fff)',
                      borderColor: 'var(--border, #e2e8f0)',
                    }}
                  />
                  <Legend wrapperStyle={{ paddingTop: 10 }} />
                  {categories.map((cat, idx) => (
                    <Line
                      key={cat}
                      type="monotone"
                      dataKey={cat}
                      name={cat}
                      stroke={PALETTE[idx % PALETTE.length]}
                      strokeWidth={2}
                      activeDot={{ r: 6 }}
                    />
                  ))}
                </LineChart>
              </ResponsiveContainer>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Detail Table */}
      <Card>
        <CardHeader>
          <CardTitle>Bảng Số Liệu Chi Tiết</CardTitle>
          <CardDescription>
            Danh sách bản ghi lượt mượn theo tháng và thể loại năm {selectedYear}
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="rounded-md border overflow-hidden">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="w-[100px]">Tháng</TableHead>
                  <TableHead className="w-[100px]">Năm</TableHead>
                  <TableHead>Tên Thể Loại</TableHead>
                  <TableHead className="text-right">Số Lượt Mượn</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {loading ? (
                  <TableRow>
                    <TableCell colSpan={4} className="text-center py-6 text-muted-foreground">
                      Đang tải dữ liệu...
                    </TableCell>
                  </TableRow>
                ) : paginatedData.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={4} className="text-center py-6 text-muted-foreground">
                      Không có bản ghi nào
                    </TableCell>
                  </TableRow>
                ) : (
                  paginatedData.map((row, idx) => (
                    <TableRow key={idx}>
                      <TableCell className="font-medium">
                        Tháng {String(row.THANG || row.thang || '')}
                      </TableCell>
                      <TableCell>{String(row.NAM || row.nam || '')}</TableCell>
                      <TableCell>{String(row.TENTL || row.tentl || '')}</TableCell>
                      <TableCell className="text-right font-bold text-blue-600">
                        {Number(row.SOLUOTMUON || row.soluotmuon || 0).toLocaleString('vi-VN')}
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
  );
};

