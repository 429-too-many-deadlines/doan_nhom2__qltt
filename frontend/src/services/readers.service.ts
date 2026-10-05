import { apiClient } from '../lib/api';
import { CreateReaderRequest, GenericApiResponse } from '../types/api.types';

export const readersService = {
  createReader: async (data: CreateReaderRequest): Promise<GenericApiResponse> => {
    const response = await apiClient.post<GenericApiResponse>('/api/readers', data);
    return response.data;
  },

  getReaderHistory: async (maDg: string): Promise<GenericApiResponse[]> => {
    const response = await apiClient.get<GenericApiResponse[]>(`/api/readers/${maDg}/history`);
    return response.data;
  },
};

