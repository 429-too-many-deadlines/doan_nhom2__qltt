import { apiClient } from '../lib/api';
import type { MessageResponse } from '../types/api.types';

export const authService = {
  changePassword: async (oldPassword: string, newPassword: string): Promise<MessageResponse> => {
    const response = await apiClient.post<MessageResponse>('/api/auth/change-password', { oldPassword, newPassword });
    return response.data;
  }
};
