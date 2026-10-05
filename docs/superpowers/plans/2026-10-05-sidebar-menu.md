# Sidebar Menu Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a responsive sidebar menu for the Library Management System frontend using shadcn/ui.

**Architecture:** We will create an `AppSidebar` component using the existing shadcn/ui sidebar components, then wrap our application content with a `MainLayout` that includes the `SidebarProvider`.

**Tech Stack:** React 19, TypeScript, Tailwind CSS 4, shadcn/ui, Vitest (for testing).

**Spec:** Chốt yêu cầu trong chat (Các chức năng: Trang chủ, Quản lý Sách, Quản lý Độc giả, Quản lý Mượn trả, Báo cáo thống kê, Cài đặt).

## Global Constraints

- Không được sửa đổi bất kỳ file nào trong thư mục `frontend/src/components/ui/`
- Sử dụng các icon từ `lucide-react`
- Đảm bảo component mới tuân thủ TypeScript (strict mode)

## Review Focus

- Sidebar có render đúng danh sách 6 chức năng yêu cầu không? (Sẽ được test bằng unit test kiểm tra hiển thị text).
- SidebarProvider có bao bọc đúng nội dung chính của ứng dụng không? (Test hiển thị nút SidebarTrigger và nội dung bên trong layout).

---

### Task 1: Setup Testing Environment

**Files:**
- Create: `frontend/vitest.config.ts`
- Create: `frontend/test/setup.ts`
- Modify: `frontend/package.json`
- Modify: `frontend/tsconfig.app.json`

**Interfaces:**
- Consumes: N/A
- Produces: Testing environment capable of running `vitest`

- [ ] **Step 1: Install testing dependencies**

```bash
cd frontend && npm install -D vitest @testing-library/react @testing-library/jest-dom @testing-library/user-event jsdom
```

- [ ] **Step 2: Configure Vitest**

Tạo file `frontend/vitest.config.ts`:
```typescript
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./test/setup.ts'],
    globals: true,
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  }
});
```

- [ ] **Step 3: Create test setup file**

Tạo file `frontend/test/setup.ts`:
```typescript
import '@testing-library/jest-dom';
```

- [ ] **Step 4: Update package.json scripts**

Thêm script `test` vào `frontend/package.json`:
```json
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "lint": "eslint .",
    "preview": "vite preview",
    "test": "vitest run"
  },
```

- [ ] **Step 5: Add types to tsconfig.app.json**

Thêm `"types": ["vitest/globals", "@testing-library/jest-dom"]` vào compilerOptions trong `frontend/tsconfig.app.json`:
```json
    "compilerOptions": {
      "types": ["vitest/globals", "@testing-library/jest-dom"],
      // ...
```

- [ ] **Step 6: Commit**

```bash
cd frontend && git add package.json package-lock.json vitest.config.ts test/setup.ts tsconfig.app.json
git commit -m "chore: setup vitest for frontend components"
```

---

### Task 2: Create AppSidebar component

**Files:**
- Create: `frontend/src/components/layout/app-sidebar.tsx`
- Create: `frontend/src/components/layout/app-sidebar.test.tsx`

**Interfaces:**
- Consumes: `Sidebar`, `SidebarContent`, v.v. từ `@/components/ui/sidebar`, các icon từ `lucide-react`
- Produces: `<AppSidebar />` component

- [ ] **Step 1: Write the failing test**

```tsx
// frontend/src/components/layout/app-sidebar.test.tsx
import { render, screen } from '@testing-library/react';
import { AppSidebar } from './app-sidebar';
import { SidebarProvider } from '@/components/ui/sidebar';

describe('AppSidebar', () => {
  it('renders all required menu items', () => {
    render(
      <SidebarProvider>
        <AppSidebar />
      </SidebarProvider>
    );
    
    expect(screen.getByText('Trang chủ')).toBeInTheDocument();
    expect(screen.getByText('Quản lý Sách')).toBeInTheDocument();
    expect(screen.getByText('Quản lý Độc giả')).toBeInTheDocument();
    expect(screen.getByText('Quản lý Mượn trả')).toBeInTheDocument();
    expect(screen.getByText('Báo cáo thống kê')).toBeInTheDocument();
    expect(screen.getByText('Cài đặt')).toBeInTheDocument();
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd frontend && npm run test`
Expected: FAIL (Cannot find module './app-sidebar')

- [ ] **Step 3: Write minimal implementation**

```tsx
// frontend/src/components/layout/app-sidebar.tsx
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd frontend && npm run test`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd frontend && git add src/components/layout/app-sidebar.tsx src/components/layout/app-sidebar.test.tsx
git commit -m "feat: create AppSidebar component"
```

---

### Task 3: Create MainLayout component

**Files:**
- Create: `frontend/src/components/layout/main-layout.tsx`
- Create: `frontend/src/components/layout/main-layout.test.tsx`

**Interfaces:**
- Consumes: `AppSidebar`, `SidebarProvider`, `SidebarTrigger`
- Produces: `<MainLayout>{children}</MainLayout>` component

- [ ] **Step 1: Write the failing test**

```tsx
// frontend/src/components/layout/main-layout.test.tsx
import { render, screen } from '@testing-library/react';
import { MainLayout } from './main-layout';

describe('MainLayout', () => {
  it('renders sidebar and children content', () => {
    render(
      <MainLayout>
        <div data-testid="main-content">Nội dung trang</div>
      </MainLayout>
    );
    
    expect(screen.getByText('Quản lý Thư viện')).toBeInTheDocument(); // from Sidebar
    expect(screen.getByTestId('main-content')).toBeInTheDocument();
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd frontend && npm run test`
Expected: FAIL (Cannot find module './main-layout')

- [ ] **Step 3: Write minimal implementation**

```tsx
// frontend/src/components/layout/main-layout.tsx
import { SidebarProvider, SidebarTrigger } from "@/components/ui/sidebar"
import { AppSidebar } from "./app-sidebar"

export function MainLayout({ children }: { children: React.ReactNode }) {
  return (
    <SidebarProvider>
      <AppSidebar />
      <main className="w-full flex-1">
        <div className="p-2">
          <SidebarTrigger />
        </div>
        <div className="p-4">
          {children}
        </div>
      </main>
    </SidebarProvider>
  )
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd frontend && npm run test`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd frontend && git add src/components/layout/main-layout.tsx src/components/layout/main-layout.test.tsx
git commit -m "feat: create MainLayout component wrapper"
```

---

### Task 4: Integrate Layout into App

**Files:**
- Modify: `frontend/src/App.tsx`
- Test: `frontend/src/App.test.tsx` (optional if it doesn't exist, we will create a basic mount test)

**Interfaces:**
- Consumes: `MainLayout`
- Produces: Updated App root

- [ ] **Step 1: Write the failing test**

```tsx
// frontend/src/App.test.tsx
import { render, screen } from '@testing-library/react';
import App from './App';

describe('App', () => {
  it('renders within the MainLayout (checks for sidebar)', () => {
    render(<App />);
    expect(screen.getByText('Quản lý Thư viện')).toBeInTheDocument();
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd frontend && npm run test`
Expected: FAIL (App currently doesn't have the sidebar)

- [ ] **Step 3: Write minimal implementation**

Cập nhật `frontend/src/App.tsx`. Sửa lại hàm return để bọc toàn bộ nội dung trong `<MainLayout>`:

```tsx
// frontend/src/App.tsx
// Add import at the top:
import { MainLayout } from '@/components/layout/main-layout';

// Find the return statement and wrap the div with MainLayout:
  return (
    <MainLayout>
      <div className="app-container">
        <header className="app-header">
// ... existing code ...
      </div>
    </MainLayout>
  );
```
*(Ghi chú: Thay thế khối JSX return cũ bằng khối bọc trong `MainLayout`, giữ nguyên logic fetchWeather)*

- [ ] **Step 4: Run test to verify it passes**

Run: `cd frontend && npm run test`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd frontend && git add src/App.tsx src/App.test.tsx
git commit -m "feat: integrate MainLayout into App root"
```
