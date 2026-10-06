import { apiClient } from '../lib/api';
import type { PagedResult,  CreateReaderTypeRequest, MessageResponse, ReaderType, UpdateReaderTypeRequest  } from '../types/api.types';

export const readerTypesService = {
  getReaderTypes: async (page = 1, pageSize = 10): Promise<PagedResult<ReaderType>> => {
    const response = await apiClient.get<PagedResult<ReaderType>>('/api/readertypes', { params: { page, pageSize } });
    return response.data;
  },
  createReaderType: async (data: CreateReaderTypeRequest): Promise<MessageResponse> => {
    const response = await apiClient.post<MessageResponse>('/api/readertypes', data);
    return response.data;
  },
  updateReaderType: async (MALDG: string, data: UpdateReaderTypeRequest): Promise<MessageResponse> => {
    const response = await apiClient.put<MessageResponse>(`/api/readertypes/${MALDG}`, data);
    return response.data;
  },
  deleteReaderType: async (MALDG: string): Promise<MessageResponse> => {
    const response = await apiClient.delete<MessageResponse>(`/api/readertypes/${MALDG}`);
    return response.data;
  },
};
