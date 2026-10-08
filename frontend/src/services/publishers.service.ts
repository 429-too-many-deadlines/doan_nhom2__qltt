import type { CreatePublisherRequest, UpdatePublisherRequest } from '../types/api.types';
import { apiClient } from '../lib/api';

export const publishersService = {
  getPublishers: async (query?: string, page = 1, pageSize = 10) => {
    const response = await apiClient.get('/api/publishers', { params: { query, page, pageSize } });
    return response.data;
  },
  createPublisher: async (data: CreatePublisherRequest) => {
    const response = await apiClient.post('/api/publishers', data);
    return response.data;
  },
  updatePublisher: async (id: string, data: UpdatePublisherRequest) => {
    const response = await apiClient.put(`/api/publishers/${id}`, data);
    return response.data;
  },
  deletePublisher: async (id: string) => {
    const response = await apiClient.delete(`/api/publishers/${id}`);
    return response.data;
  }
};
