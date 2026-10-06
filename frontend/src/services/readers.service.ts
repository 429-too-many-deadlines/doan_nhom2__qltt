import { apiClient } from '../lib/api';
import type { PagedResult, CreateReaderRequest, MessageResponse, Reader, UpdateReaderRequest, GenericApiResponse } from '../types/api.types';

export const readersService = {
  createReader: async (data: CreateReaderRequest): Promise<MessageResponse> => {
    const response = await apiClient.post<MessageResponse>('/api/readers', data);
    return response.data;
  },

  updateReader: async (MADG: string, data: UpdateReaderRequest): Promise<MessageResponse> => {
    const response = await apiClient.put<MessageResponse>(`/api/readers/${MADG}`, data);
    return response.data;
  },

  deleteReader: async (MADG: string): Promise<MessageResponse> => {
    const response = await apiClient.delete<MessageResponse>(`/api/readers/${MADG}`);
    return response.data;
  },

  searchReaders: async (query: string = '', page: number = 1, pageSize: number = 10): Promise<PagedResult<Reader>> => {
    const response = await apiClient.get<PagedResult<Reader>>('/api/readers/search', {
      params: { query, page, pageSize },
    });
    return response.data;
  },

  getReaderHistory: async (MADG: string): Promise<GenericApiResponse[]> => {
    const response = await apiClient.get<GenericApiResponse[]>(`/api/readers/${MADG}/history`);
    return response.data;
  },
};

