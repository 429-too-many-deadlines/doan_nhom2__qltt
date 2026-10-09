import { apiClient } from '../lib/api';
import type { Account, ChangePasswordRequest, CreateAccountRequest, MessageResponse } from '../types/api.types';

export const authService = {
  createAccount: async (data: CreateAccountRequest): Promise<MessageResponse> => {
    const response = await apiClient.post<MessageResponse>('/api/auth/create-account', data);
    return response.data;
  },
  changePassword: async (data: ChangePasswordRequest): Promise<MessageResponse> => {
    const response = await apiClient.post<MessageResponse>('/api/auth/change-password', data);
    return response.data;
  },
  getAccounts: async (): Promise<Account[]> => {
    const response = await apiClient.get<Account[]>('/api/auth/accounts');
    return response.data;
  },
  updateAccountStatus: async (username: string, status: boolean): Promise<MessageResponse> => {
    const response = await apiClient.put<MessageResponse>(`/api/auth/accounts/${username}/status`, { status });
    return response.data;
  }
};
