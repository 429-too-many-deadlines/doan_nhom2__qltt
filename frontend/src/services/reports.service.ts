import { apiClient } from '../lib/api';
import { MonthlyStatsResponse, GenericApiResponse } from '../types/api.types';

export const reportsService = {
  getMonthlyStats: async (month: number, year: number): Promise<MonthlyStatsResponse> => {
    const response = await apiClient.get<MonthlyStatsResponse>('/api/reports/monthly-stats', {
      params: { month, year },
    });
    return response.data;
  },

  getBorrowsByMonth: async (): Promise<GenericApiResponse[]> => {
    const response = await apiClient.get<GenericApiResponse[]>('/api/reports/borrows-by-month');
    return response.data;
  },

  getFinesByMonth: async (): Promise<GenericApiResponse[]> => {
    const response = await apiClient.get<GenericApiResponse[]>('/api/reports/fines-by-month');
    return response.data;
  },

  getInventoryReport: async (): Promise<GenericApiResponse[]> => {
    const response = await apiClient.get<GenericApiResponse[]>('/api/reports/inventory');
    return response.data;
  },

  getLibrarianPerformance: async (): Promise<GenericApiResponse[]> => {
    const response = await apiClient.get<GenericApiResponse[]>('/api/reports/librarian-performance');
    return response.data;
  },

  getOverdueReaders: async (): Promise<GenericApiResponse[]> => {
    const response = await apiClient.get<GenericApiResponse[]>('/api/reports/overdue-readers');
    return response.data;
  },

  getTopBorrowedBooks: async (): Promise<GenericApiResponse[]> => {
    const response = await apiClient.get<GenericApiResponse[]>('/api/reports/top-borrowed-books');
    return response.data;
  },
};

