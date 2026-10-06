# Global Exception Handling Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement global exception handling on the .NET backend to return RFC 7807 Problem Details and update the React frontend's Axios client to uniformly process these errors.

**Architecture:** We will create custom exceptions and an `IExceptionHandler` on the backend to map them to `ProblemDetails`. On the frontend, we will introduce an `ApiError` class and update the Axios interceptor to parse the backend errors uniformly.

**Tech Stack:** .NET 8 Minimal APIs, xUnit (new), React, Axios, Vitest (new).

**Spec:** `docs/superpowers/specs/2026-10-06-global-exception-handling-design.md`

## Global Constraints
- Target Framework: .NET 8.0 for backend.
- C# features: File-scoped namespaces, nullable reference types enabled.
- Node.js: >=20.19.0.
- Frontend: TypeScript strictly typed.

## Review Focus
- Unhandled generic exceptions: Should return 500 Internal Server Error without exposing stack traces. Test: Throw generic `Exception` in handler tests.
- ValidationException with null/empty dictionary: Should return 400 Bad Request with an empty `errors` object, not crash. Test: Pass empty dictionary to `ValidationException`.
- Frontend receiving non-JSON errors (e.g., 502 Bad Gateway HTML page): Interceptor should not crash parsing JSON, but fallback to a generic `ApiError`. Test: Mock axios response with HTML string.

---

### Task 1: Backend Setup & Custom Exceptions

**Files:**
- Create: `QuanLyThuVien.Server.Tests/QuanLyThuVien.Server.Tests.csproj`
- Create: `QuanLyThuVien.Server/Exceptions/AppException.cs`
- Create: `QuanLyThuVien.Server/Exceptions/NotFoundException.cs`
- Create: `QuanLyThuVien.Server/Exceptions/BadRequestException.cs`
- Create: `QuanLyThuVien.Server/Exceptions/ValidationException.cs`
- Create: `QuanLyThuVien.Server.Tests/Exceptions/ExceptionTests.cs`
- Modify: `QuanLyThuVien.sln`

**Interfaces:**
- Produces: `NotFoundException`, `BadRequestException`, `ValidationException(IDictionary<string, string[]> errors)` for use by the exception handler and future domain logic.

- [ ] **Step 1: Create test project and add to solution**
Run: `dotnet new xunit -n QuanLyThuVien.Server.Tests`
Run: `dotnet sln add QuanLyThuVien.Server.Tests/QuanLyThuVien.Server.Tests.csproj`
Run: `dotnet add QuanLyThuVien.Server.Tests/QuanLyThuVien.Server.Tests.csproj reference QuanLyThuVien.Server/QuanLyThuVien.Server.csproj`

- [ ] **Step 2: Write tests for exceptions**
```csharp
// QuanLyThuVien.Server.Tests/Exceptions/ExceptionTests.cs
using QuanLyThuVien.Server.Exceptions;
namespace QuanLyThuVien.Server.Tests.Exceptions;

public class ExceptionTests
{
    [Fact]
    public void ValidationException_ShouldStoreErrors()
    {
        var errors = new Dictionary<string, string[]> { { "Email", new[] { "Required" } } };
        var ex = new ValidationException("Validation failed", errors);
        Assert.Equal(errors, ex.Errors);
    }
}
```

- [ ] **Step 3: Run test to verify it fails (doesn't compile yet)**
Run: `dotnet test QuanLyThuVien.Server.Tests`
Expected: FAIL (build errors)

- [ ] **Step 4: Implement Custom Exceptions**
Implement `AppException` (base), `NotFoundException`, `BadRequestException`, and `ValidationException` in `QuanLyThuVien.Server/Exceptions/`. Ensure `ValidationException` accepts and stores `IDictionary<string, string[]> Errors`.

- [ ] **Step 5: Run tests to verify they pass**
Run: `dotnet test QuanLyThuVien.Server.Tests`
Expected: PASS

- [ ] **Step 6: Commit**
```bash
git add .
git commit -m "feat: add backend custom exceptions and test project"
```

---

### Task 2: Backend Global Exception Handler

**Files:**
- Create: `QuanLyThuVien.Server/Infrastructure/ErrorHandling/GlobalExceptionHandler.cs`
- Modify: `QuanLyThuVien.Server/Program.cs`
- Create: `QuanLyThuVien.Server.Tests/Infrastructure/GlobalExceptionHandlerTests.cs`

**Interfaces:**
- Consumes: Custom exceptions from Task 1.
- Produces: Mapped HTTP responses (400, 404, 500) via `IExceptionHandler`.

- [ ] **Step 1: Write tests for GlobalExceptionHandler**
```csharp
// QuanLyThuVien.Server.Tests/Infrastructure/GlobalExceptionHandlerTests.cs
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Diagnostics;
using QuanLyThuVien.Server.Exceptions;
using QuanLyThuVien.Server.Infrastructure.ErrorHandling;

namespace QuanLyThuVien.Server.Tests.Infrastructure;

public class GlobalExceptionHandlerTests
{
    // Need a mock or simple context to test IExceptionHandler.TryHandleAsync
    // Since Mocking IProblemDetailsService is complex, test the status code mapping manually or use an integration test.
    // For simplicity, implement a unit test that verifies TryHandleAsync returns true and sets the right status code.
}
```
*Note: Write a basic test asserting `httpContext.Response.StatusCode` when `NotFoundException`, `ValidationException`, and `Exception` are thrown.*

- [ ] **Step 2: Implement GlobalExceptionHandler**
Implement `IExceptionHandler` in `GlobalExceptionHandler.cs`.
- `NotFoundException` -> 404
- `BadRequestException` -> 400
- `ValidationException` -> 400 (add `Errors` to `extensions["errors"]`)
- `Exception` -> 500

- [ ] **Step 3: Register handler in Program.cs**
Add `builder.Services.AddExceptionHandler<GlobalExceptionHandler>();` below `builder.Services.AddProblemDetails();`.

- [ ] **Step 4: Run tests to verify they pass**
Run: `dotnet test QuanLyThuVien.Server.Tests`
Expected: PASS

- [ ] **Step 5: Commit**
```bash
git add .
git commit -m "feat: implement and register global exception handler"
```

---

### Task 3: Frontend Setup & Type Definitions

**Files:**
- Modify: `frontend/package.json`
- Create: `frontend/src/types/error.types.ts`
- Create: `frontend/src/types/error.types.test.ts`
- Modify: `frontend/vite.config.ts` (to configure vitest)

**Interfaces:**
- Produces: `ProblemDetails` interface and `ApiError` class.

- [ ] **Step 1: Install Vitest**
Run: `cd frontend && npm install -D vitest`

- [ ] **Step 2: Update vite.config.ts**
Add `/// <reference types="vitest" />` at the top of `vite.config.ts` if needed, and configure `test` environment. Add `"test": "vitest run"` to `package.json` scripts.

- [ ] **Step 3: Write tests for ApiError**
```typescript
// frontend/src/types/error.types.test.ts
import { describe, it, expect } from 'vitest';
import { ApiError } from './error.types';

describe('ApiError', () => {
  it('should initialize with problem details', () => {
    const problem = { type: 'about:blank', title: 'Error', status: 400, detail: 'msg' };
    const error = new ApiError(problem);
    expect(error.problem).toEqual(problem);
    expect(error.message).toBe('msg');
  });
});
```

- [ ] **Step 4: Run test to verify it fails**
Run: `cd frontend && npm run test`
Expected: FAIL (missing module)

- [ ] **Step 5: Implement Type Definitions**
Create `frontend/src/types/error.types.ts` with `ProblemDetails` interface and `ApiError` class extending `Error`.

- [ ] **Step 6: Run tests to verify they pass**
Run: `cd frontend && npm run test`
Expected: PASS

- [ ] **Step 7: Commit**
```bash
git add .
git commit -m "feat(frontend): setup vitest and add api error types"
```

---

### Task 4: Frontend Axios Interceptor

**Files:**
- Modify: `frontend/src/lib/api.ts`
- Create: `frontend/src/lib/api.test.ts`

**Interfaces:**
- Consumes: `ApiError` from Task 3.

- [ ] **Step 1: Write tests for Axios Interceptor**
```typescript
// frontend/src/lib/api.test.ts
import { describe, it, expect, vi } from 'vitest';
import { apiClient } from './api';
import { ApiError } from '../types/error.types';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';

describe('Axios Interceptor', () => {
  it('should throw ApiError on 400 with problem details', async () => {
    const mock = new MockAdapter(apiClient);
    const problem = { title: 'Validation', status: 400, detail: 'Failed' };
    mock.onGet('/test').reply(400, problem);

    await expect(apiClient.get('/test')).rejects.toThrow(ApiError);
  });
});
```

- [ ] **Step 2: Install axios-mock-adapter**
Run: `cd frontend && npm install -D axios-mock-adapter`

- [ ] **Step 3: Run test to verify it fails**
Run: `cd frontend && npm run test`
Expected: FAIL (throws generic AxiosError)

- [ ] **Step 4: Update Axios Interceptor**
Modify `frontend/src/lib/api.ts` response interceptor error block to map `error.response?.data` to `ApiError` if it has problem details structure. Ensure network errors fallback to a generic `ApiError`.

- [ ] **Step 5: Run tests to verify they pass**
Run: `cd frontend && npm run test`
Expected: PASS

- [ ] **Step 6: Commit**
```bash
git add .
git commit -m "feat(frontend): update axios interceptor to use ApiError"
```
