import axios from 'axios';
import { ApiError, type ProblemDetails } from '../types/error.types';

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
      localStorage.removeItem('token');
    }

    if (error.response?.data) {
      const data = error.response.data as Partial<ProblemDetails>;
      // Check if it's a ProblemDetails response (has status and title/type)
      if (data.status && (data.title || data.type)) {
        return Promise.reject(new ApiError(data as ProblemDetails));
      }
    }

    // Fallback for network errors or unhandled formats
    const fallbackProblem: ProblemDetails = {
      status: error.response?.status || 500,
      title: error.response?.statusText || 'Error',
      detail: error.message || 'An unexpected network error occurred.',
    };
    return Promise.reject(new ApiError(fallbackProblem));
  }
);

