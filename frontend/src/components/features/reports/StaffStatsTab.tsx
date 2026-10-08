import { useState, useEffect, useMemo } from 'react';
import { reportsService } from '../../../services/reports.service';
import type { GenericApiResponse } from '../../../types/api.types';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../../ui/card';
import { Button } from '../../ui/button';
import { Input } from '../../ui/input';
import { Badge } from '../../ui/badge';
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
  Legend,
  CartesianGrid,
} from 'recharts';
import { Users, Award, Bell, Play, CheckCircle2 } from 'lucide-react';

interface StaffStatsTabProps {
  month: number;
  year: number;
}

export const StaffStatsTab = ({ month, year }: StaffStatsTabProps) => {
  const [allStaffData, setAllStaffData] = useState<GenericApiResponse[]>([]);
  const [loadingStaff, setLoadingStaff] = useState(false);

  // Automated cursor states
  const [rankingData, setRankingData] = useState<GenericApiResponse[] | null>(null);
  const [reminderData, setReminderData] = useState<GenericApiResponse[] | null>(null);
  const [runningRanking, setRunningRanking] = useState(false);
  const [runningReminder, setRunningReminder] = useState(false);
  const [checkDate, setCheckDate] = useState(new Date().toISOString().slice(0, 10));

  useEffect(() => {
    let isMounted = true;
    const fetchStaff = async () => {
      try {
        setLoadingStaff(true);
        const res = await reportsService.getLibrarianPerformance();
        if (isMounted) {
          setAllStaffData(res || []);
        }
      } catch (err) {
        console.error('Lỗi khi tải hiệu suất nhân viên:', err);
        if (isMounted) setAllStaffData([]);
      } finally {
        if (isMounted) setLoadingStaff(false);
      }
    };

    fetchStaff();
    return () => {
      isMounted = false;
    };
  }, []);

  // Filter staff data by month and year
  const staffForSelectedMonth = useMemo(() => {
    return allStaffData.filter(
      (r) => Number(r.NAM || r.nam) === year && Number(r.THANG || r.thang) === month
    );
  }, [allStaffData, month, year]);

  // Chart data
  const chartData = useMemo(() => {
    return staffForSelectedMonth.map((r) => ({
      MANV: String(r.MANV || r.manv || ''),
      HOTEN: String(r.HOTEN || r.hoten || 'Chưa rõ'),
      SOPHIEU: Number(r.SOPHIEU || r.sophieu || 0),
      SOSACH: Number(r.SOSACH || r.sosach || 0),
    }));
  }, [staffForSelectedMonth]);

  // Overall totals
  const totalStaffStats = useMemo(() => {
    let totalPhieu = 0;
    let totalSach = 0;
    staffForSelectedMonth.forEach((r) => {
      totalPhieu += Number(r.SOPHIEU || r.sophieu || 0);
      totalSach += Number(r.SOSACH || r.sosach || 0);
    });
    return { totalPhieu, totalSach };
  }, [staffForSelectedMonth]);

  // Handler for ranking cursor
  const handleRunRanking = async () => {
    try {
      setRunningRanking(true);
      const res = await reportsService.runRankingCursor();
      setRankingData(res || []);
    } catch (err) {
      console.error('Lỗi khi chạy xếp loại độc giả:', err);
      setRankingData([]);
    } finally {
      setRunningRanking(false);
    }
  };

  // Handler for reminder cursor
  const handleRunReminder = async () => {
    try {
      setRunningReminder(true);
      const res = await reportsService.runReminderCursor(checkDate);
      setReminderData(res || []);
    } catch (err) {
      console.error('Lỗi khi chạy nhắc nhở quá hạn:', err);
      setReminderData([]);
    } finally {
      setRunningReminder(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Nhân Viên Hoạt Động
            </CardTitle>
            <Users className="h-4 w-4 text-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {loadingStaff ? '...' : staffForSelectedMonth.length}
            </div>
            <p className="text-xs text-muted-foreground mt-1">
              Thủ thư xử lý phiếu trong tháng {month}/{year}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Tổng Phiếu Mượn Lập
            </CardTitle>
            <Award className="h-4 w-4 text-blue-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-blue-600">
              {loadingStaff ? '...' : totalStaffStats.totalPhieu.toLocaleString('vi-VN')}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Được xử lý bởi toàn bộ thủ thư</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Tổng Bản Sách Đã Xử Lý
            </CardTitle>
            <CheckCircle2 className="h-4 w-4 text-emerald-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-emerald-600">
              {loadingStaff ? '...' : totalStaffStats.totalSach.toLocaleString('vi-VN')}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Cuốn sách lưu thông qua bàn thủ thư</p>
          </CardContent>
        </Card>
      </div>

      {/* Staff Grouped BarChart */}
      <Card>
        <CardHeader>
          <CardTitle>Biểu Đồ So Sánh Hiệu Suất Thủ Thư (Tháng {month}/{year})</CardTitle>
          <CardDescription>
            Số phiếu mượn và số cuốn sách đã xử lý của từng nhân viên
          </CardDescription>
        </CardHeader>
        <CardContent>
          {loadingStaff ? (
            <div className="h-[320px] flex items-center justify-center text-muted-foreground">
              Đang tải biểu đồ hiệu suất...
            </div>
          ) : chartData.length === 0 ? (
            <div className="h-[320px] flex items-center justify-center text-muted-foreground">
              Chưa có dữ liệu xử lý phiếu của nhân viên trong tháng {month}/{year}.
            </div>
          ) : (
            <div className="h-[320px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={chartData} margin={{ top: 10, right: 30, left: 0, bottom: 20 }}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} strokeOpacity={0.4} />
                  <XAxis dataKey="HOTEN" tick={{ fontSize: 12 }} />
                  <YAxis allowDecimals={false} tick={{ fontSize: 12 }} />
                  <Tooltip
                    contentStyle={{
                      borderRadius: '8px',
                      backgroundColor: 'var(--background, #fff)',
                      borderColor: 'var(--border, #e2e8f0)',
                    }}
                  />
                  <Legend wrapperStyle={{ paddingTop: 10 }} />
                  <Bar dataKey="SOPHIEU" name="Số phiếu mượn" fill="#3b82f6" radius={[4, 4, 0, 0]} />
                  <Bar dataKey="SOSACH" name="Số sách xử lý" fill="#10b981" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Automated Database Procedures (Cursor Operations) */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Procedure 1: Reader Ranking */}
        <Card>
          <CardHeader>
            <CardTitle className="text-base flex items-center gap-2">
              <Award className="h-5 w-5 text-indigo-500" />
              Thủ Tục Xếp Loại Độc Giả
            </CardTitle>
            <CardDescription>
              Kích hoạt Cursor CSDL tự động phân loại độc giả dựa trên lịch sử mượn và vi phạm
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <Button
              onClick={handleRunRanking}
              disabled={runningRanking}
              className="w-full sm:w-auto"
            >
              <Play className="h-4 w-4 mr-2" />
              {runningRanking ? 'Đang thực thi Cursor...' : 'Chạy Xếp Loại Độc Giả'}
            </Button>

            {rankingData && (
              <div className="space-y-2 mt-4">
                <div className="flex items-center justify-between text-xs text-muted-foreground">
                  <span>Kết quả phân loại:</span>
                  <Badge variant="outline">{rankingData.length} độc giả</Badge>
                </div>
                <div className="max-h-[220px] overflow-auto rounded border">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Mã ĐG</TableHead>
                        <TableHead>Họ Tên</TableHead>
                        <TableHead className="text-right">Xếp Loại</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {rankingData.length === 0 ? (
                        <TableRow>
                          <TableCell colSpan={3} className="text-center text-muted-foreground py-4">
                            Không có kết quả trả về
                          </TableCell>
                        </TableRow>
                      ) : (
                        rankingData.slice(0, 10).map((r, i) => (
                          <TableRow key={i}>
                            <TableCell className="font-mono text-xs">
                              {String(r.MADG || r.madg || '-')}
                            </TableCell>
                            <TableCell className="text-xs">
                              {String(r.HOTEN || r.hoten || '')}
                            </TableCell>
                            <TableCell className="text-right">
                              <Badge variant="secondary" className="text-xs">
                                {String(r.XEPLOAI || r.xeploai || r.HANG || 'Chuẩn')}
                              </Badge>
                            </TableCell>
                          </TableRow>
                        ))
                      )}
                    </TableBody>
                  </Table>
                </div>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Procedure 2: Overdue Reminders */}
        <Card>
          <CardHeader>
            <CardTitle className="text-base flex items-center gap-2">
              <Bell className="h-5 w-5 text-amber-500" />
              Thủ Tục Quét & Nhắc Nhở Quá Hạn
            </CardTitle>
            <CardDescription>
              Kích hoạt Cursor CSDL kiểm tra hạn trả và phát cảnh báo nhắc nhở
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex flex-col sm:flex-row items-start sm:items-end gap-3">
              <div className="space-y-1 w-full sm:w-auto">
                <label className="text-xs font-medium text-muted-foreground">Ngày kiểm tra</label>
                <Input
                  type="date"
                  value={checkDate}
                  onChange={(e) => setCheckDate(e.target.value)}
                  className="w-full sm:w-[160px]"
                />
              </div>
              <Button
                onClick={handleRunReminder}
                disabled={runningReminder}
                variant="outline"
                className="w-full sm:w-auto"
              >
                <Play className="h-4 w-4 mr-2" />
                {runningReminder ? 'Đang kiểm tra...' : 'Quét & Nhắc Nhở'}
              </Button>
            </div>

            {reminderData && (
              <div className="space-y-2 mt-4">
                <div className="flex items-center justify-between text-xs text-muted-foreground">
                  <span>Thông báo đã gửi:</span>
                  <Badge variant="outline">{reminderData.length} thông báo</Badge>
                </div>
                <div className="max-h-[220px] overflow-auto rounded border">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Độc Giả</TableHead>
                        <TableHead>Nội Dung</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {reminderData.length === 0 ? (
                        <TableRow>
                          <TableCell colSpan={2} className="text-center text-muted-foreground py-4">
                            Không có cảnh báo mới cần nhắc nhở vào ngày này.
                          </TableCell>
                        </TableRow>
                      ) : (
                        reminderData.slice(0, 10).map((r, i) => (
                          <TableRow key={i}>
                            <TableCell className="font-medium text-xs">
                              {String(r.MADG || r.madg || r.HOTEN || '')}
                            </TableCell>
                            <TableCell className="text-xs text-muted-foreground">
                              {String(r.NOIDUNG || r.noidung || r.THONGBAO || 'Đã gửi nhắc nhở quá hạn')}
                            </TableCell>
                          </TableRow>
                        ))
                      )}
                    </TableBody>
                  </Table>
                </div>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

