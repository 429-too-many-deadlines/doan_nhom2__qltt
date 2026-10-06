import { apiClient } from '../lib/api';
import type { PagedResult, BorrowRequest, BorrowSlip, FineSlip, MessageResponse, PayFineRequest, ReturnRequest } from '../types/api.types';

export const transactionsService = {
  borrowBook: async (data: BorrowRequest): Promise<MessageResponse> => {
    const response = await apiClient.post<MessageResponse>('/api/transactions/borrow', data);
    return response.data;
  },

  returnBook: async (data: ReturnRequest): Promise<MessageResponse> => {
    const response = await apiClient.post<MessageResponse>('/api/transactions/return', data);
    return response.data;
  },

  payFine: async (data: PayFineRequest): Promise<MessageResponse> => {
    const response = await apiClient.post<MessageResponse>('/api/transactions/pay-fine', data);
    return response.data;
  },

  getBorrowSlips: async (page = 1, pageSize = 10): Promise<PagedResult<BorrowSlip>> => {
    const response = await apiClient.get<PagedResult<BorrowSlip>>('/api/transactions/borrows', {
      params: { page, pageSize },
    });
    return response.data;
  },

  getFineSlips: async (page = 1, pageSize = 10): Promise<PagedResult<FineSlip>> => {
    const response = await apiClient.get<PagedResult<FineSlip>>('/api/transactions/fines', {
      params: { page, pageSize },
    });
    return response.data;
  },
};

