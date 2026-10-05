import {
  Sidebar,
  SidebarContent,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar"
import { Home, BookOpen, Users, ArrowRightLeft, BarChart, Settings } from "lucide-react"

const menuItems = [
  { title: "Trang chủ", url: "#", icon: Home },
  { title: "Quản lý Sách", url: "#", icon: BookOpen },
  { title: "Quản lý Độc giả", url: "#", icon: Users },
  { title: "Quản lý Mượn trả", url: "#", icon: ArrowRightLeft },
  { title: "Báo cáo thống kê", url: "#", icon: BarChart },
  { title: "Cài đặt", url: "#", icon: Settings },
]

export function AppSidebar() {
  return (
    <Sidebar>
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>Quản lý Thư viện</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {menuItems.map((item) => (
                <SidebarMenuItem key={item.title}>
                  <SidebarMenuButton asChild>
                    <a href={item.url}>
                      <item.icon />
                      <span>{item.title}</span>
                    </a>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>
    </Sidebar>
  )
}
