import { apiClient } from '../lib/api';
import type {  BorrowRequest, ReturnRequest, PayFineRequest, GenericApiResponse  } from '../types/api.types';

export const transactionsService = {
  borrowBook: async (data: BorrowRequest): Promise<GenericApiResponse> => {
    const response = await apiClient.post<GenericApiResponse>('/api/transactions/borrow', data);
    return response.data;
  },

  returnBook: async (data: ReturnRequest): Promise<GenericApiResponse> => {
    const response = await apiClient.post<GenericApiResponse>('/api/transactions/return', data);
    return response.data;
  },

  payFine: async (data: PayFineRequest): Promise<GenericApiResponse> => {
    const response = await apiClient.post<GenericApiResponse>('/api/transactions/pay-fine', data);
    return response.data;
  },
};

