import type { PagedResult,  CreateAuthorRequest, UpdateAuthorRequest  } from '../types/api.types';
import { apiClient } from '../lib/api';

export const authorsService = {
  getAuthors: async (query?: string, page = 1, pageSize = 10) => {
    const response = await apiClient.get('/api/authors', { params: { query, page, pageSize } });
    return response.data;
  },
  createAuthor: async (data: CreateAuthorRequest) => {
    const response = await apiClient.post('/api/authors', data);
    return response.data;
  },
  updateAuthor: async (id: string, data: UpdateAuthorRequest) => {
    const response = await apiClient.put(`/api/authors/${id}`, data);
    return response.data;
  },
  deleteAuthor: async (id: string) => {
    const response = await apiClient.delete(`/api/authors/${id}`);
    return response.data;
  }
};
