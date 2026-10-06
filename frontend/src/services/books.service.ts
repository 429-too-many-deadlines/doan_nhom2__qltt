import { apiClient } from '../lib/api';
import type { AuthorRoleRequest, BookAuthor, BookCopy, CreateBookCopyRequest, CreateBookRequest, MessageResponse, SearchBookResponse, UpdateBookCopyRequest, UpdateBookRequest } from '../types/api.types';

export const booksService = {
  // --- Copies ---
  getBookCopies: async (maDs: string): Promise<BookCopy[]> => {
    const response = await apiClient.get<BookCopy[]>(`/api/books/${maDs}/copies`);
    return response.data;
  },
  createBookCopy: async (maDs: string, data: CreateBookCopyRequest): Promise<MessageResponse> => {
    const response = await apiClient.post<MessageResponse>(`/api/books/${maDs}/copies`, data);
    return response.data;
  },
  updateBookCopy: async (maCs: string, data: UpdateBookCopyRequest): Promise<MessageResponse> => {
    const response = await apiClient.put<MessageResponse>(`/api/books/copies/${maCs}`, data);
    return response.data;
  },
  deleteBookCopy: async (maCs: string): Promise<MessageResponse> => {
    const response = await apiClient.delete<MessageResponse>(`/api/books/copies/${maCs}`);
    return response.data;
  },
  // --- Authors ---
  getBookAuthors: async (maDs: string): Promise<BookAuthor[]> => {
    const response = await apiClient.get<BookAuthor[]>(`/api/books/${maDs}/authors`);
    return response.data;
  },
  updateBookAuthors: async (maDs: string, authors: AuthorRoleRequest[]): Promise<MessageResponse> => {
    const response = await apiClient.put<MessageResponse>(`/api/books/${maDs}/authors`, { authors });
    return response.data;
  },

  searchBooks: async (query: string): Promise<SearchBookResponse[]> => {
    const response = await apiClient.get<SearchBookResponse[]>('/api/books/search', {
      params: { query },
    });
    return response.data;
  },
  
  createBook: async (data: CreateBookRequest): Promise<MessageResponse> => {
    const response = await apiClient.post<MessageResponse>('/api/books', data);
    return response.data;
  },

  updateBook: async (maDs: string, data: UpdateBookRequest): Promise<MessageResponse> => {
    const response = await apiClient.put<MessageResponse>(`/api/books/${maDs}`, data);
    return response.data;
  },

  deleteBook: async (maDs: string): Promise<MessageResponse> => {
    const response = await apiClient.delete<MessageResponse>(`/api/books/${maDs}`);
    return response.data;
  },
};
