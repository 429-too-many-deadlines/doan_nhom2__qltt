import type { CreateCategoryReq, UpdateCategoryRequest } from '../types/api.types';
import { apiClient } from '../lib/api';

export const categoriesService = {
  getCategories: async () => {
    const response = await apiClient.get('/api/categories');
    return response.data;
  },
  createCategory: async (data: CreateCategoryReq) => {
    const response = await apiClient.post('/api/categories', data);
    return response.data;
  },
  updateCategory: async (id: string, data: UpdateCategoryRequest) => {
    const response = await apiClient.put(`/api/categories/${id}`, data);
    return response.data;
  },
  deleteCategory: async (id: string) => {
    const response = await apiClient.delete(`/api/categories/${id}`);
    return response.data;
  }
};
