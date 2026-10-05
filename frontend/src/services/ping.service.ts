import { apiClient } from '../lib/api';

export const pingService = {
  getPing: async (): Promise<string> => {
    const response = await apiClient.get<string>('/ping');
    return response.data;
  },
};

