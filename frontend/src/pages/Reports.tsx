import { useState, lazy, Suspense } from 'react';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '../components/ui/tabs';
import { Input } from '../components/ui/input';
import { Button } from '../components/ui/button';
import { MonthlyOverviewTab } from '../components/features/reports/MonthlyOverviewTab';
import { ReportTabSkeleton } from '../components/features/reports/ReportSkeleton';
import {
  BarChart3,
  BookOpen,
  Layers,
  CircleDollarSign,
  Users,
  Calendar,
  RotateCcw,
} from 'lucide-react';

const BorrowStatsTab = lazy(() =>
  import('../components/features/reports/BorrowStatsTab').then((m) => ({ default: m.BorrowStatsTab }))
);
const InventoryStatsTab = lazy(() =>
  import('../components/features/reports/InventoryStatsTab').then((m) => ({ default: m.InventoryStatsTab }))
);
const FineStatsTab = lazy(() =>
  import('../components/features/reports/FineStatsTab').then((m) => ({ default: m.FineStatsTab }))
);

const tabPreloaders: Record<string, () => void> = {
  borrows: () => { import('../components/features/reports/BorrowStatsTab'); },
  inventory: () => { import('../components/features/reports/InventoryStatsTab'); },
  fines: () => { import('../components/features/reports/FineStatsTab'); },
  };

export default function Reports() {
  const currentDate = new Date();
  const [activeTab, setActiveTab] = useState('monthly');
  const [visitedTabs, setVisitedTabs] = useState<Record<string, boolean>>({ monthly: true });
  const [month, setMonth] = useState(currentDate.getMonth() + 1);
  const [year, setYear] = useState(currentDate.getFullYear());

  const handleTabChange = (val: string) => {
    setActiveTab(val);
    setVisitedTabs((prev) => (prev[val] ? prev : { ...prev, [val]: true }));
  };

  const handleResetToCurrent = () => {
    const now = new Date();
    setMonth(now.getMonth() + 1);
    setYear(now.getFullYear());
  };

  const showMonthFilter = activeTab === 'monthly' || activeTab === 'staff';

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Báo Cáo & Thống Kê Thư Viện</h1>
          <p className="text-sm text-muted-foreground mt-1">
            Hệ thống dashboard trực quan hóa dữ liệu mượn trả, kho sách, tài chính và hiệu suất
          </p>
        </div>

        {/* Dynamic Month/Year Filter for Time-Sensitive Tabs */}
        {showMonthFilter && (
          <div className="flex items-center gap-2 bg-muted/40 p-2 rounded-lg border">
            <Calendar className="h-4 w-4 text-primary ml-1" />
            <div className="flex items-center gap-1">
              <span className="text-xs text-muted-foreground font-medium">Tháng:</span>
              <Input
                type="number"
                min={1}
                max={12}
                value={month}
                onChange={(e) => {
                  const val = Number(e.target.value);
                  if (val >= 1 && val <= 12) setMonth(val);
                }}
                className="w-16 h-8 text-xs text-center"
              />
            </div>
            <div className="flex items-center gap-1">
              <span className="text-xs text-muted-foreground font-medium">Năm:</span>
              <Input
                type="number"
                min={2000}
                max={2100}
                value={year}
                onChange={(e) => {
                  const val = Number(e.target.value);
                  if (val >= 1900) setYear(val);
                }}
                className="w-20 h-8 text-xs text-center"
              />
            </div>
            <Button
              variant="ghost"
              size="sm"
              onClick={handleResetToCurrent}
              title="Về tháng hiện tại"
              className="h-8 px-2 text-xs"
            >
              <RotateCcw className="h-3.5 w-3.5" />
            </Button>
          </div>
        )}
      </div>

      {/* Tabs Navigation */}
      <Tabs value={activeTab} onValueChange={handleTabChange} className="space-y-6">
        <TabsList className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 w-full h-auto p-1 gap-1 bg-muted/60">
          <TabsTrigger value="monthly" className="h-auto py-2 text-xs sm:text-sm font-medium">
            <BarChart3 className="h-4 w-4 mr-1.5" />
            Tổng Quan Tháng
          </TabsTrigger>
          <TabsTrigger
            value="borrows"
            onMouseEnter={() => tabPreloaders.borrows()}
            className="h-auto py-2 text-xs sm:text-sm font-medium"
          >
            <BookOpen className="h-4 w-4 mr-1.5" />
            Mượn - Trả Sách
          </TabsTrigger>
          <TabsTrigger
            value="inventory"
            onMouseEnter={() => tabPreloaders.inventory()}
            className="h-auto py-2 text-xs sm:text-sm font-medium"
          >
            <Layers className="h-4 w-4 mr-1.5" />
            Kho & Đầu Sách
          </TabsTrigger>
          <TabsTrigger
            value="fines"
            onMouseEnter={() => tabPreloaders.fines()}
            className="h-auto py-2 text-xs sm:text-sm font-medium"
          >
            <CircleDollarSign className="h-4 w-4 mr-1.5" />
            Tiền Phạt & Quá Hạn
          </TabsTrigger>
          <TabsTrigger
            value="staff"
            onMouseEnter={() => tabPreloaders.staff()}
            className="h-auto py-2 text-xs sm:text-sm font-medium"
          >
            <Users className="h-4 w-4 mr-1.5" />
            Hiệu Suất Thủ Thư
          </TabsTrigger>
        </TabsList>

        {/* Tab 1: Monthly Overview */}
        <TabsContent value="monthly" className="outline-none data-[state=inactive]:hidden" forceMount>
          <MonthlyOverviewTab month={month} year={year} />
        </TabsContent>

        {/* Tab 2: Borrow Trends */}
        {visitedTabs.borrows && (
          <TabsContent value="borrows" className="outline-none data-[state=inactive]:hidden" forceMount>
            <Suspense fallback={<ReportTabSkeleton />}>
              <BorrowStatsTab />
            </Suspense>
          </TabsContent>
        )}

        {/* Tab 3: Inventory & Top Books */}
        {visitedTabs.inventory && (
          <TabsContent value="inventory" className="outline-none data-[state=inactive]:hidden" forceMount>
            <Suspense fallback={<ReportTabSkeleton />}>
              <InventoryStatsTab />
            </Suspense>
          </TabsContent>
        )}

        {/* Tab 4: Fines & Overdue Readers */}
        {visitedTabs.fines && (
          <TabsContent value="fines" className="outline-none data-[state=inactive]:hidden" forceMount>
            <Suspense fallback={<ReportTabSkeleton />}>
              <FineStatsTab />
            </Suspense>
          </TabsContent>
        )}

        
      </Tabs>
    </div>
  );
}
