import { apiClient } from '../lib/api';
import type {  CreateReaderRequest, UpdateReaderRequest, GenericApiResponse  } from '../types/api.types';

export const readersService = {
  createReader: async (data: CreateReaderRequest): Promise<GenericApiResponse> => {
    const response = await apiClient.post<GenericApiResponse>('/api/readers', data);
    return response.data;
  },

  updateReader: async (maDg: string, data: UpdateReaderRequest): Promise<GenericApiResponse> => {
    const response = await apiClient.put<GenericApiResponse>(`/api/readers/${maDg}`, data);
    return response.data;
  },

  deleteReader: async (maDg: string): Promise<GenericApiResponse> => {
    const response = await apiClient.delete<GenericApiResponse>(`/api/readers/${maDg}`);
    return response.data;
  },

  searchReaders: async (query: string = ''): Promise<any[]> => {
    const response = await apiClient.get<any[]>('/api/readers/search', {
      params: { query },
    });
    return response.data;
  },

  getReaderHistory: async (maDg: string): Promise<GenericApiResponse[]> => {
    const response = await apiClient.get<GenericApiResponse[]>(`/api/readers/${maDg}/history`);
    return response.data;
  },
};

