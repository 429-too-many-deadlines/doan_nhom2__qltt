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
import { Layers, Award, CheckCircle2, Clock, AlertTriangle, XCircle } from 'lucide-react';

export const InventoryStatsTab = () => {
  const [topBooks, setTopBooks] = useState<GenericApiResponse[]>([]);
  const [inventory, setInventory] = useState<GenericApiResponse[]>([]);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(1);
  const pageSize = 10;

  useEffect(() => {
    let isMounted = true;
    const fetchData = async () => {
      try {
        setLoading(true);
        const [topRes, invRes] = await Promise.all([
          reportsService.getTopBorrowedBooks(),
          reportsService.getInventoryReport(),
        ]);
        if (isMounted) {
          setTopBooks(topRes || []);
          setInventory(invRes || []);
        }
      } catch (err) {
        console.error('Lỗi khi tải dữ liệu kho & đầu sách:', err);
        if (isMounted) {
          setTopBooks([]);
          setInventory([]);
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

  // Compute overall inventory totals
  const totals = useMemo(() => {
    let tongSo = 0;
    let coSan = 0;
    let dangMuon = 0;
    let huHong = 0;
    let mat = 0;

    inventory.forEach((r) => {
      tongSo += Number(r.TONGSO || r.tongso || 0);
      coSan += Number(r.COSAN || r.cosan || 0);
      dangMuon += Number(r.DANGMUON || r.dangmuon || 0);
      huHong += Number(r.HUHONG || r.huhong || 0);
      mat += Number(r.MAT || r.mat || 0);
    });

    return { tongSo, coSan, dangMuon, huHong, mat };
  }, [inventory]);

  // Donut chart data for book copy status
  const donutData = useMemo(() => {
    return [
      { name: 'Có sẵn', value: totals.coSan, color: '#10b981' },
      { name: 'Đang mượn', value: totals.dangMuon, color: '#3b82f6' },
      { name: 'Hư hỏng', value: totals.huHong, color: '#f59e0b' },
      { name: 'Mất', value: totals.mat, color: '#ef4444' },
    ].filter((item) => item.value > 0);
  }, [totals]);

  // Top 10 books data formatted for horizontal bar chart
  const top10Data = useMemo(() => {
    return topBooks.slice(0, 10).map((b) => ({
      MADS: String(b.MADS || b.mads || ''),
      TENDS: String(b.TENDS || b.tends || 'Chưa rõ'),
      TENTL: String(b.TENTL || b.tentl || ''),
      SOLUOTMUON: Number(b.SOLUOTMUON || b.soluotmuon || 0),
      SODOCGIA: Number(b.SODOCGIA || b.sodocgia || 0),
    }));
  }, [topBooks]);

  // Paginated inventory table
  const totalPages = Math.ceil(inventory.length / pageSize) || 1;
  const paginatedInventory = useMemo(() => {
    const start = (page - 1) * pageSize;
    return inventory.slice(start, start + pageSize);
  }, [inventory, page]);

  return (
    <div className="space-y-6">
      {/* 4 Status KPI Badges */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Có Sẵn</CardTitle>
            <CheckCircle2 className="h-4 w-4 text-emerald-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-emerald-600">
              {loading ? '...' : totals.coSan.toLocaleString('vi-VN')}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Cuốn sẵn sàng phục vụ</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Đang Mượn</CardTitle>
            <Clock className="h-4 w-4 text-blue-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-blue-600">
              {loading ? '...' : totals.dangMuon.toLocaleString('vi-VN')}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Cuốn độc giả đang giữ</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Hư Hỏng</CardTitle>
            <AlertTriangle className="h-4 w-4 text-amber-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-amber-600">
              {loading ? '...' : totals.huHong.toLocaleString('vi-VN')}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Cần sửa chữa / phục hồi</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Mất Sách</CardTitle>
            <XCircle className="h-4 w-4 text-rose-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-rose-600">
              {loading ? '...' : totals.mat.toLocaleString('vi-VN')}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Đã lập biên bản đền bù</p>
          </CardContent>
        </Card>
      </div>

      {/* Charts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Donut Chart: Warehouse Status */}
        <Card className="lg:col-span-5">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Layers className="h-5 w-5 text-primary" />
              Tỉ Lệ Trạng Thái Kho Sách
            </CardTitle>
            <CardDescription>
              Tổng số: {totals.tongSo.toLocaleString('vi-VN')} bản sách lưu kho
            </CardDescription>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="h-[320px] flex items-center justify-center text-muted-foreground">
                Đang tải biểu đồ kho...
              </div>
            ) : donutData.length === 0 ? (
              <div className="h-[320px] flex items-center justify-center text-muted-foreground">
                Không có dữ liệu cuốn sách.
              </div>
            ) : (
              <div className="h-[320px] w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={donutData}
                      dataKey="value"
                      nameKey="name"
                      cx="50%"
                      cy="50%"
                      innerRadius={65}
                      outerRadius={95}
                      paddingAngle={4}
                      label={({ name, percent }: { name: string; percent: number }) =>
                        `${name}: ${(percent * 100).toFixed(0)}%`
                      }
                      labelLine={false}
                    >
                      {donutData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip
                      formatter={(val: number | string) => [`${val} cuốn`, 'Số lượng']}
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

        {/* Horizontal BarChart: Top 10 Borrowed Books */}
        <Card className="lg:col-span-7">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Award className="h-5 w-5 text-amber-500" />
              Top 10 Sách Được Mượn Nhiều Nhất
            </CardTitle>
            <CardDescription>
              Thống kê toàn bộ lịch sử mượn và độc giả tiếp cận
            </CardDescription>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="h-[320px] flex items-center justify-center text-muted-foreground">
                Đang tải bảng xếp hạng...
              </div>
            ) : top10Data.length === 0 ? (
              <div className="h-[320px] flex items-center justify-center text-muted-foreground">
                Không có dữ liệu xếp hạng sách.
              </div>
            ) : (
              <div className="h-[320px] w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart
                    layout="vertical"
                    data={top10Data}
                    margin={{ top: 10, right: 30, left: 10, bottom: 10 }}
                  >
                    <CartesianGrid strokeDasharray="3 3" horizontal={false} strokeOpacity={0.4} />
                    <XAxis type="number" tick={{ fontSize: 12 }} />
                    <YAxis
                      dataKey="TENDS"
                      type="category"
                      width={130}
                      tick={{ fontSize: 11 }}
                      tickFormatter={(val: string) =>
                        val.length > 15 ? `${val.slice(0, 15)}...` : val
                      }
                    />
                    <Tooltip
                      contentStyle={{
                        borderRadius: '8px',
                        backgroundColor: 'var(--background, #fff)',
                        borderColor: 'var(--border, #e2e8f0)',
                      }}
                    />
                    <Legend wrapperStyle={{ paddingTop: 10 }} />
                    <Bar
                      dataKey="SOLUOTMUON"
                      name="Số lượt mượn"
                      fill="#6366f1"
                      radius={[0, 4, 4, 0]}
                    />
                    <Bar
                      dataKey="SODOCGIA"
                      name="Số độc giả"
                      fill="#06b6d4"
                      radius={[0, 4, 4, 0]}
                    />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Detailed Inventory Table */}
      <Card>
        <CardHeader>
          <CardTitle>Bảng Kiểm Kê Tồn Kho Theo Đầu Sách</CardTitle>
          <CardDescription>
            Chi tiết số lượng các tình trạng sách theo từng đầu sách trong thư viện
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="rounded-md border overflow-hidden">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="w-[80px]">Mã</TableHead>
                  <TableHead>Tên Đầu Sách</TableHead>
                  <TableHead>Thể Loại</TableHead>
                  <TableHead className="text-right">Tổng Số</TableHead>
                  <TableHead className="text-right text-emerald-600">Có Sẵn</TableHead>
                  <TableHead className="text-right text-blue-600">Đang Mượn</TableHead>
                  <TableHead className="text-right text-amber-600">Hư Hỏng</TableHead>
                  <TableHead className="text-right text-rose-600">Mất</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {loading ? (
                  <TableRow>
                    <TableCell colSpan={8} className="text-center py-6 text-muted-foreground">
                      Đang tải dữ liệu tồn kho...
                    </TableCell>
                  </TableRow>
                ) : paginatedInventory.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={8} className="text-center py-6 text-muted-foreground">
                      Không có bản ghi tồn kho
                    </TableCell>
                  </TableRow>
                ) : (
                  paginatedInventory.map((row, idx) => (
                    <TableRow key={idx}>
                      <TableCell className="font-mono text-xs text-muted-foreground">
                        {String(row.MADS || row.mads || '-')}
                      </TableCell>
                      <TableCell className="font-medium max-w-[200px] truncate" title={String(row.TENDS || row.tends)}>
                        {String(row.TENDS || row.tends || '')}
                      </TableCell>
                      <TableCell>{String(row.TENTL || row.tentl || '')}</TableCell>
                      <TableCell className="text-right font-bold">
                        {Number(row.TONGSO || row.tongso || 0).toLocaleString('vi-VN')}
                      </TableCell>
                      <TableCell className="text-right font-medium text-emerald-600">
                        {Number(row.COSAN || row.cosan || 0).toLocaleString('vi-VN')}
                      </TableCell>
                      <TableCell className="text-right font-medium text-blue-600">
                        {Number(row.DANGMUON || row.dangmuon || 0).toLocaleString('vi-VN')}
                      </TableCell>
                      <TableCell className="text-right font-medium text-amber-600">
                        {Number(row.HUHONG || row.huhong || 0).toLocaleString('vi-VN')}
                      </TableCell>
                      <TableCell className="text-right font-medium text-rose-600">
                        {Number(row.MAT || row.mat || 0).toLocaleString('vi-VN')}
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

