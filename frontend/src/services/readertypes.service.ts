import { apiClient } from '../lib/api';
import type { CreateReaderTypeRequest, MessageResponse, ReaderType, UpdateReaderTypeRequest } from '../types/api.types';

export const readerTypesService = {
  getReaderTypes: async (): Promise<ReaderType[]> => {
    const response = await apiClient.get<ReaderType[]>('/api/readertypes');
    return response.data;
  },
  createReaderType: async (data: CreateReaderTypeRequest): Promise<MessageResponse> => {
    const response = await apiClient.post<MessageResponse>('/api/readertypes', data);
    return response.data;
  },
  updateReaderType: async (maLDG: string, data: UpdateReaderTypeRequest): Promise<MessageResponse> => {
    const response = await apiClient.put<MessageResponse>(`/api/readertypes/${maLDG}`, data);
    return response.data;
  },
  deleteReaderType: async (maLDG: string): Promise<MessageResponse> => {
    const response = await apiClient.delete<MessageResponse>(`/api/readertypes/${maLDG}`);
    return response.data;
  },
};
