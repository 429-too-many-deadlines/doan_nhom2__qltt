import { apiClient } from '../lib/api';
import type { Employee, CreateEmployeeRequest, MessageResponse } from '../types/api.types';

export const employeesService = {
  getEmployees: async (): Promise<Employee[]> => {
    const response = await apiClient.get<Employee[]>('/api/employees');
    return response.data;
  },
  createEmployee: async (data: CreateEmployeeRequest): Promise<MessageResponse> => {
    const response = await apiClient.post<MessageResponse>('/api/employees', data);
    return response.data;
  },
  updateEmployee: async (maNV: string, data: CreateEmployeeRequest): Promise<MessageResponse> => {
    const response = await apiClient.put<MessageResponse>(`/api/employees/${maNV}`, data);
    return response.data;
  },
  deleteEmployee: async (maNV: string): Promise<MessageResponse> => {
    const response = await apiClient.delete<MessageResponse>(`/api/employees/${maNV}`);
    return response.data;
  },
};
