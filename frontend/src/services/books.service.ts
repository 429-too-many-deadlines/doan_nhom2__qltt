import { apiClient } from '../lib/api';
import type {  SearchBookResponse, UpdateBookRequest, CreateBookRequest, GenericApiResponse  } from '../types/api.types';

export const booksService = {
  searchBooks: async (query: string): Promise<SearchBookResponse[]> => {
    const response = await apiClient.get<SearchBookResponse[]>('/api/books/search', {
      params: { query },
    });
    return response.data;
  },
  
  createBook: async (data: CreateBookRequest): Promise<GenericApiResponse> => {
    const response = await apiClient.post<GenericApiResponse>('/api/books', data);
    return response.data;
  },

  updateBook: async (maDs: string, data: UpdateBookRequest): Promise<GenericApiResponse> => {
    const response = await apiClient.put<GenericApiResponse>(`/api/books/${maDs}`, data);
    return response.data;
  },

  deleteBook: async (maDs: string): Promise<GenericApiResponse> => {
    const response = await apiClient.delete<GenericApiResponse>(`/api/books/${maDs}`);
    return response.data;
  },
};
