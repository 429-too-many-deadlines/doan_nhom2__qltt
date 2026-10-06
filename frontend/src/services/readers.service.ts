import { apiClient } from '../lib/api';
import type { CreateReaderRequest, MessageResponse, Reader, UpdateReaderRequest, GenericApiResponse } from '../types/api.types';

export const readersService = {
  createReader: async (data: CreateReaderRequest): Promise<MessageResponse> => {
    const response = await apiClient.post<MessageResponse>('/api/readers', data);
    return response.data;
  },

  updateReader: async (maDg: string, data: UpdateReaderRequest): Promise<MessageResponse> => {
    const response = await apiClient.put<MessageResponse>(`/api/readers/${maDg}`, data);
    return response.data;
  },

  deleteReader: async (maDg: string): Promise<MessageResponse> => {
    const response = await apiClient.delete<MessageResponse>(`/api/readers/${maDg}`);
    return response.data;
  },

  searchReaders: async (query: string = ''): Promise<Reader[]> => {
    const response = await apiClient.get<Reader[]>('/api/readers/search', {
      params: { query },
    });
    return response.data;
  },

  getReaderHistory: async (maDg: string): Promise<GenericApiResponse[]> => {
    const response = await apiClient.get<GenericApiResponse[]>(`/api/readers/${maDg}/history`);
    return response.data;
  },
};

