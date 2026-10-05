export interface SearchBookResponse {
  // TODO: Thêm các trường dựa trên kết quả SP_TIMSACH trả về
  maSach?: string;
  tenSach?: string;
  tacGia?: string;
  [key: string]: unknown;
}

export interface CreateReaderRequest {
  hoTen: string;
  ngaySinh?: string;
  diaChi?: string;
}

export interface UpdateReaderRequest {
  maDg: string;
  hoTen: string;
  ngaySinh: string;
  gioiTinh: string;
  diaChi?: string;
  soDt: string;
  email?: string;
  maLdg: string;
}

export interface UpdateBookRequest {
  maDs: string;
  tenDs: string;
  maTl: string;
  maNxb: string;
  namXb: number;
  soTrang: number;
  gia: number;
}

export interface BorrowRequest {
  maDg: string;
  maNv: string;
  dsMaCs: string[];
}

export interface ReturnRequest {
  maPm?: string;
  maNv: string;
  dsMaCs: string[];
}

export interface PayFineRequest {
  maDg: string;
  soTienThu?: number;
  maNv: string;
}

export interface TopBookResponse {
  maSach?: string;
  tenSach?: string;
  soLuotMuon?: number;
  [key: string]: unknown;
}

export interface MonthlyStatsResponse {
  soPhieu: number;
  soLuotSach: number;
  tienPhat: number;
  top5Books: TopBookResponse[];
}

export type GenericApiResponse = Record<string, unknown>;
