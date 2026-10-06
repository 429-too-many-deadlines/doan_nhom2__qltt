import { apiClient } from '../lib/api';
import type { PagedResult,  Employee, CreateEmployeeRequest, MessageResponse  } from '../types/api.types';

export const employeesService = {
  getEmployees: async (page = 1, pageSize = 10): Promise<PagedResult<Employee>> => {
    const response = await apiClient.get<PagedResult<Employee>>('/api/employees', { params: { page, pageSize } });
    return response.data;
  },
  createEmployee: async (data: CreateEmployeeRequest): Promise<MessageResponse> => {
    const response = await apiClient.post<MessageResponse>('/api/employees', data);
    return response.data;
  },
  updateEmployee: async (MANV: string, data: CreateEmployeeRequest): Promise<MessageResponse> => {
    const response = await apiClient.put<MessageResponse>(`/api/employees/${MANV}`, data);
    return response.data;
  },
  deleteEmployee: async (MANV: string): Promise<MessageResponse> => {
    const response = await apiClient.delete<MessageResponse>(`/api/employees/${MANV}`);
    return response.data;
  },
};
