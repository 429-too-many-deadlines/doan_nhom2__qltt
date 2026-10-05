import { apiClient } from '../lib/api';
import { SearchBookResponse } from '../types/api.types';

export const booksService = {
  searchBooks: async (query: string): Promise<SearchBookResponse[]> => {
    const response = await apiClient.get<SearchBookResponse[]>('/api/books/search', {
      params: { query },
    });
    return response.data;
  },
};
