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
import { Home, BookOpen, Users, ArrowRightLeft, BarChart, Settings, Shield, Tags, PenTool, Building, Contact} from "lucide-react"

import { useAuth } from "@/contexts/AuthContext"

const menuItems = [
  { title: "Trang chủ", url: "/", icon: Home, roles: ["Quản lý", "Thủ thư", "Độc giả"] },
  { title: "Quản lý Sách", url: "/books", icon: BookOpen, roles: ["Quản lý", "Thủ thư", "Độc giả"] },
  { title: "Thể loại", url: "/categories", icon: Tags, roles: ["Quản lý", "Thủ thư"] },
  { title: "Tác giả", url: "/authors", icon: PenTool, roles: ["Quản lý", "Thủ thư"] },
  { title: "Nhà xuất bản", url: "/publishers", icon: Building, roles: ["Quản lý", "Thủ thư"] },
  { title: "Quản lý Độc giả", url: "/readers", icon: Users, roles: ["Quản lý", "Thủ thư"] },
  { title: "Quản lý Nhân viên", url: "/employees", icon: Contact, roles: ["Quản lý"] },
  { title: "Quản lý Mượn trả", url: "/transactions", icon: ArrowRightLeft, roles: ["Quản lý", "Thủ thư", "Độc giả"] },
  { title: "Báo cáo thống kê", url: "/reports", icon: BarChart, roles: ["Quản lý", "Thủ thư"] },
  { title: "Tài khoản", url: "/accounts", icon: Shield, roles: ["Quản lý"] },
  { title: "Cài đặt", url: "/settings", icon: Settings, roles: ["Quản lý"] },
]

export function AppSidebar() {
  const location = useLocation()
  const { user } = useAuth()

  const filteredMenuItems = menuItems.filter(item => user && item.roles.includes(user.role))

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
                    <Link to={item.url}>
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


