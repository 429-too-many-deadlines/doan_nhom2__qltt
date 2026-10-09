import { Link, useLocation } from "react-router-dom"
import {
  Sidebar,
  SidebarContent,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarHeader,
  SidebarFooter,
  SidebarRail,
} from "@/components/ui/sidebar"
import { Home, BookOpen, Users, ArrowRightLeft, BarChart, Settings, Shield, Tags, PenTool, Building} from "lucide-react"

import { useEffect } from "react"
import { useAuth } from "@/contexts/AuthContext"

const routePreloaders: Record<string, () => void> = {
  "/reports": () => { import("@/pages/Reports") },
  "/books": () => { import("@/pages/Books") },
  "/transactions": () => { import("@/pages/Transactions") },
}

const handlePrefetch = (url: string) => {
  routePreloaders[url]?.()
}

const menuItems = [
  { title: "Trang chủ", url: "/", icon: Home },
  { title: "Quản lý Sách", url: "/books", icon: BookOpen },
  { title: "Thể loại", url: "/categories", icon: Tags },
  { title: "Tác giả", url: "/authors", icon: PenTool },
  { title: "Nhà xuất bản", url: "/publishers", icon: Building },
  { title: "Quản lý Độc giả", url: "/readers", icon: Users },
  { title: "Quản lý Mượn trả", url: "/transactions", icon: ArrowRightLeft },
  { title: "Báo cáo thống kê", url: "/reports", icon: BarChart },
  { title: "Đổi mật khẩu", url: "/accounts", icon: Shield },
  { title: "Cài đặt", url: "/settings", icon: Settings },
]

export function AppSidebar() {
  const location = useLocation()
  const { user } = useAuth()

  useEffect(() => {
    // Warm up the reports chunk during idle time so navigation is instantaneous
    const timer = setTimeout(() => {
      import("@/pages/Reports")
    }, 1200)
    return () => clearTimeout(timer)
  }, [])

  const filteredMenuItems = user ? menuItems : []

  return (
    <Sidebar collapsible="icon">
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton size="lg" asChild>
              <Link to="/">
                <div className="flex aspect-square size-8 items-center justify-center rounded-lg bg-sidebar-primary text-sidebar-primary-foreground">
                  <BookOpen className="size-4" />
                </div>
                <div className="grid flex-1 text-left text-sm leading-tight">
                  <span className="truncate font-semibold">QL Thư viện</span>
                  <span className="truncate text-xs text-sidebar-foreground/70">v1.0.0</span>
                </div>
              </Link>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>Quản lý Thư viện</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {filteredMenuItems.map((item) => (
                <SidebarMenuItem key={item.title}>
                  <SidebarMenuButton asChild isActive={location.pathname === item.url}>
                    <Link
                      to={item.url}
                      onMouseEnter={() => handlePrefetch(item.url)}
                      onFocus={() => handlePrefetch(item.url)}
                    >
                      <item.icon />
                      <span>{item.title}</span>
                    </Link>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>
      <SidebarFooter>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton size="lg" asChild>
              <a href="#">
                <div className="flex aspect-square size-8 items-center justify-center rounded-lg bg-muted text-muted-foreground">
                  <Users className="size-4" />
                </div>
                <div className="grid flex-1 text-left text-sm leading-tight">
                  <span className="truncate font-semibold">Nhóm 2</span>
                  <span className="truncate text-xs text-sidebar-foreground/70">Dự án môn học</span>
                </div>
              </a>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarFooter>
      <SidebarRail />
    </Sidebar>
  )
}


