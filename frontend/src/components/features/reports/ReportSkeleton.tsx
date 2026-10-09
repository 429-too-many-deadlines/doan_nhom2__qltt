import { Card, CardContent, CardHeader } from '@/components/ui/card';

export function ReportTabSkeleton() {
  return (
    <div className="space-y-6 animate-pulse">
      {/* 3 KPI Skeleton Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {[1, 2, 3].map((i) => (
          <Card key={i}>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <div className="h-4 w-24 bg-muted rounded" />
              <div className="h-4 w-4 bg-muted rounded-full" />
            </CardHeader>
            <CardContent className="space-y-2">
              <div className="h-8 w-20 bg-muted rounded" />
              <div className="h-3 w-32 bg-muted/60 rounded" />
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Chart & Table Skeleton */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        <Card className="lg:col-span-7">
          <CardHeader className="space-y-2">
            <div className="h-5 w-48 bg-muted rounded" />
            <div className="h-3 w-64 bg-muted/60 rounded" />
          </CardHeader>
          <CardContent>
            <div className="h-[300px] w-full flex items-end justify-between gap-4 pt-8 px-4 border-b border-muted">
              {[40, 75, 55, 90, 60].map((h, idx) => (
                <div key={idx} className="flex-1 flex flex-col items-center gap-2">
                  <div
                    className="w-full bg-muted rounded-t"
                    style={{ height: `${h}%` }}
                  />
                  <div className="h-3 w-12 bg-muted/60 rounded" />
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card className="lg:col-span-5">
          <CardHeader className="space-y-2">
            <div className="h-5 w-40 bg-muted rounded" />
            <div className="h-3 w-32 bg-muted/60 rounded" />
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              <div className="h-8 w-full bg-muted rounded" />
              {[1, 2, 3, 4, 5].map((row) => (
                <div key={row} className="h-9 w-full bg-muted/50 rounded flex items-center justify-between px-3">
                  <div className="h-3 w-12 bg-muted rounded" />
                  <div className="h-3 w-28 bg-muted rounded" />
                  <div className="h-3 w-8 bg-muted rounded" />
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

