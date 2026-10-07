import axios from 'axios';
import { toast } from 'sonner';
import { ApiError, type ProblemDetails } from '../types/error.types';

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL || '',
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
  (response) => {
    const isGet = response.config.method?.toLowerCase() === 'get';
    // Check if there is a message field in the response data and show success toast
    if (!isGet && response.data && response.data.message) {
      toast.success(response.data.message);
    }
    return response;
  },
  (error) => {
    const isGet = error.config?.method?.toLowerCase() === 'get';

    if (error.response?.status === 401) {
      if (!isGet) toast.error('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.');
      console.error('Unauthorized access. Redirecting to login...');
      localStorage.removeItem('token');
    }

    if (error.response?.data) {
      const data = error.response.data as Partial<ProblemDetails>;
      // Check if it's a ProblemDetails response (has status and title/type)
      if (data.status && (data.title || data.type)) {
        if (!isGet) {
          const errorMsg = data.detail || data.title || 'Đã có lỗi xảy ra';
          toast.error(errorMsg);
        }
        return Promise.reject(new ApiError(data as ProblemDetails));
      }
    }

    // Fallback for network errors or unhandled formats
    const fallbackProblem: ProblemDetails = {
      status: error.response?.status || 500,
      title: error.response?.statusText || 'Error',
      detail: error.message || 'An unexpected network error occurred.',
    };
    
    // Don't show generic error toast for 401s again since it was handled above
    if (!isGet && error.response?.status !== 401) {
      toast.error(fallbackProblem.detail || fallbackProblem.title);
    }
    return Promise.reject(new ApiError(fallbackProblem));
  }
);

