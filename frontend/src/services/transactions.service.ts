import { apiClient } from '../lib/api';
import type { BorrowRequest, BorrowSlip, FineSlip, MessageResponse, PayFineRequest, ReturnRequest } from '../types/api.types';

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

  getBorrowSlips: async (): Promise<BorrowSlip[]> => {
    const response = await apiClient.get<BorrowSlip[]>('/api/transactions/borrows');
    return response.data;
  },

  getFineSlips: async (): Promise<FineSlip[]> => {
    const response = await apiClient.get<FineSlip[]>('/api/transactions/fines');
    return response.data;
  },
};

