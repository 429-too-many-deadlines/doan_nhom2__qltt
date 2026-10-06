# Global Exception Handling & Problem Details Design

## 1. Overview
This design outlines the architecture for standardizing API error responses across the `QuanLyThuVien` application. We will implement global exception handling on the .NET backend to return RFC 7807 Problem Details and update the React frontend's Axios client to uniformly process and surface these errors.

## 2. Backend Architecture (.NET 8 Minimal APIs)

### 2.1. Directory Structure Additions
- `QuanLyThuVien.Server/Exceptions/`: Contains domain-specific custom exceptions.
- `QuanLyThuVien.Server/Infrastructure/ErrorHandling/`: Contains the global exception handler logic.

### 2.2. Custom Exceptions
To allow clean throwing of specific error types anywhere in the application logic, we will introduce:
- `AppException` (abstract base): Base class for all application-specific exceptions.
- `NotFoundException`: Maps to HTTP 404 (Not Found).
- `BadRequestException`: Maps to HTTP 400 (Bad Request) for general logic errors.
- `ValidationException`: Maps to HTTP 400 (Bad Request) and includes an `IDictionary<string, string[]>` of validation errors per field.

### 2.3. Global Exception Handler
A centralized handler `GlobalExceptionHandler` implementing `Microsoft.AspNetCore.Diagnostics.IExceptionHandler`:
- intercepts all unhandled exceptions.
- performs pattern matching on the exception type:
  - `NotFoundException` -> HTTP 404, Title: "Not Found".
  - `BadRequestException` -> HTTP 400, Title: "Bad Request".
  - `ValidationException` -> HTTP 400, Title: "Validation Error", appends the dictionary of errors to the Problem Details `extensions` property.
  - General `Exception` -> HTTP 500, Title: "Internal Server Error" (hides stack trace from client).
- writes the configured `ProblemDetails` to the response using the built-in `IProblemDetailsService`.

### 2.4. Application Configuration (`Program.cs`)
- Register the default Problem Details service: `builder.Services.AddProblemDetails();`
- Register the custom handler: `builder.Services.AddExceptionHandler<GlobalExceptionHandler>();`
- Enable the exception handling middleware: `app.UseExceptionHandler();`

---

## 3. Frontend Architecture (React + Axios)

### 3.1. Type Definitions
To strongly type the incoming errors, we will add models to `frontend/src/types/api.types.ts` (or equivalent):
- `ProblemDetails`: Interface defining the standard RFC 7807 structure (`type`, `title`, `status`, `detail`, `instance`) along with an optional `errors` dictionary for validation.
- `ApiError`: A custom class extending the native JavaScript `Error` that encapsulates the `ProblemDetails` object.

### 3.2. Axios Interceptor Modifications
In `frontend/src/lib/api.ts`, update `apiClient.interceptors.response.use`:
- Intercept the error response block.
- Maintain existing 401 Unauthorized handling.
- Extract `error.response?.data`. If it matches the `ProblemDetails` schema, map it to an `ApiError`.
- If the error is a network error or missing structured data, construct a generic `ProblemDetails` object (e.g., 500/503 status) and wrap it in `ApiError`.
- Reject the promise with the newly constructed `ApiError`.

### 3.3. Usage Pattern
UI components calling the API will use standard `try-catch` blocks. Caught errors can be checked via `error instanceof ApiError`.
- Generic messages can be displayed globally via `error.problem.detail`.
- Form-specific validation errors can be targeted via `error.problem.errors`.
