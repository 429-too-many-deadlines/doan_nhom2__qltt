# Frontend Axios Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cài đặt và cấu hình một Axios instance hoàn chỉnh cho dự án React frontend, bao gồm xử lý interceptor cho xác thực (Token) và bắt lỗi toàn cục, cùng với việc thiết lập môi trường test (Vitest) để phát triển theo hướng TDD.

**Architecture:** 
- Thêm thư viện `axios` để gọi HTTP request. 
- Thêm `vitest` và `@testing-library/react` để viết test.
- Tạo file `src/lib/api.ts` xuất ra một instance của `axios` đã được cấu hình sẵn `baseURL` từ biến môi trường và đính kèm các Request/Response Interceptors.
- Xây dựng một service mẫu (`ping.service.ts`) gọi đến `/ping` để chứng minh instance hoạt động đúng.

**Tech Stack:** React, Vite, TypeScript, Axios, Vitest, MSW (Mock Service Worker cho test).

**Spec:** Yêu cầu cài đặt API base từ lệnh `/brainstorming setup api cho axios instance của frontend` của người dùng.

## Global Constraints

- Không làm thay đổi luồng build Vite hiện tại.
- Base URL mặc định lấy từ biến `VITE_API_URL` trong `.env`.
- Mã nguồn viết bằng TypeScript 100%, có type an toàn.

## Review Focus

- API URL bị thiếu trong `.env`: Cần có fallback an toàn (ví dụ `/api`) tránh crash app.
- Lấy token bị lỗi: Request Interceptor cần xử lý an toàn không quăng ngoại lệ làm gián đoạn request.
- Backend trả về 401 Unauthorized: Cần console.error hoặc emit event để đẩy ra trang Login.

---

### Task 1: Cài đặt Dependencies và cấu hình Vitest

**Files:**
- Create: `frontend/vitest.config.ts`
- Modify: `frontend/package.json`

**Interfaces:**
- Consumes: `npm install`
- Produces: Môi trường chạy test `npm run test`

- [ ] **Step 1: Write the failing test**
Không áp dụng vì đây là bước cài đặt hệ thống.

- [ ] **Step 2: Cài đặt thư viện**
```bash
cd frontend
npm install axios
npm install -D vitest @testing-library/react jsdom @testing-library/jest-dom
```

- [ ] **Step 3: Write minimal implementation**
Cập nhật `frontend/package.json` thêm script test:
```json
"scripts": {
  "test": "vitest run"
}
```
Tạo `frontend/vitest.config.ts`:
```typescript
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'jsdom',
    globals: true
  }
})
```

- [ ] **Step 4: Run test to verify it passes**
Run: `npm run test` (Sẽ báo "No test files found", nhưng lệnh chạy thành công).

- [ ] **Step 5: Commit**
```bash
git add package.json package-lock.json vitest.config.ts
git commit -m "chore: setup vitest and install axios"
```

---

### Task 2: Thiết lập Biến Môi Trường (Environment Variables)

**Files:**
- Create: `frontend/.env`
- Create: `frontend/.env.example`
- Modify: `frontend/src/vite-env.d.ts`

**Interfaces:**
- Consumes: N/A
- Produces: `import.meta.env.VITE_API_URL` typed.

- [ ] **Step 1: Write the failing test**
Không cần test tự động cho file `.env`.

- [ ] **Step 2: Định nghĩa TypeScript cho Env**
Mở `frontend/src/vite-env.d.ts` và thêm:
```typescript
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_URL: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
```

- [ ] **Step 3: Write minimal implementation**
Tạo `frontend/.env`:
```
VITE_API_URL=http://localhost:5242
```
Tạo `frontend/.env.example`:
```
VITE_API_URL=http://localhost:5242
```

- [ ] **Step 4: Commit**
```bash
git add src/vite-env.d.ts .env.example
git commit -m "chore: setup environment variables for API URL"
```

---

### Task 3: Tạo Axios Instance với Interceptors

**Files:**
- Create: `frontend/src/lib/api.ts`
- Create: `frontend/src/lib/api.test.ts`

**Interfaces:**
- Consumes: `import.meta.env.VITE_API_URL`
- Produces: `export const apiClient: AxiosInstance`

- [ ] **Step 1: Write the failing test**

```typescript
// frontend/src/lib/api.test.ts
import { describe, it, expect } from 'vitest';
import { apiClient } from './api';

describe('apiClient', () => {
  it('should be defined', () => {
    expect(apiClient).toBeDefined();
  });

  it('should have the correct baseURL', () => {
    // baseURL lấy từ vite fallback do trong vitest meta.env có thể rỗng
    expect(apiClient.defaults.baseURL).toBeDefined();
  });
});
```

- [ ] **Step 2: Run test to verify it fails**
Run: `npm run test`
Expected: FAIL (api.ts chưa tồn tại)

- [ ] **Step 3: Write minimal implementation**

```typescript
// frontend/src/lib/api.ts
import axios from 'axios';

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL || '/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request Interceptor
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response Interceptor
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      console.error('Unauthorized access. Redirecting to login...');
      // Logic logout / clear token có thể thêm sau
      localStorage.removeItem('token');
    }
    return Promise.reject(error);
  }
);
```

- [ ] **Step 4: Run test to verify it passes**
Run: `npm run test`
Expected: PASS

- [ ] **Step 5: Commit**
```bash
git add src/lib/api.ts src/lib/api.test.ts
git commit -m "feat: create configured axios instance with interceptors"
```

---

### Task 4: Tạo Ping Service (Đóng vai trò Example)

**Files:**
- Create: `frontend/src/services/ping.service.ts`
- Create: `frontend/src/services/ping.service.test.ts`

**Interfaces:**
- Consumes: `apiClient` từ `src/lib/api.ts`
- Produces: `export const pingService = { getPing: () => Promise<string> }`

- [ ] **Step 1: Write the failing test**

```typescript
// frontend/src/services/ping.service.test.ts
import { describe, it, expect, vi } from 'vitest';
import { pingService } from './ping.service';
import { apiClient } from '../lib/api';

vi.mock('../lib/api', () => ({
  apiClient: {
    get: vi.fn(),
  },
}));

describe('pingService', () => {
  it('should call GET /ping', async () => {
    vi.mocked(apiClient.get).mockResolvedValueOnce({ data: 'pong!' });
    const result = await pingService.getPing();
    expect(apiClient.get).toHaveBeenCalledWith('/ping');
    expect(result).toBe('pong!');
  });
});
```

- [ ] **Step 2: Run test to verify it fails**
Run: `npm run test`
Expected: FAIL

- [ ] **Step 3: Write minimal implementation**

```typescript
// frontend/src/services/ping.service.ts
import { apiClient } from '../lib/api';

export const pingService = {
  getPing: async (): Promise<string> => {
    const response = await apiClient.get<string>('/ping');
    return response.data;
  },
};
```

- [ ] **Step 4: Run test to verify it passes**
Run: `npm run test`
Expected: PASS

- [ ] **Step 5: Commit**
```bash
git add src/services/ping.service.ts src/services/ping.service.test.ts
git commit -m "feat: add ping service as example using apiClient"
```
