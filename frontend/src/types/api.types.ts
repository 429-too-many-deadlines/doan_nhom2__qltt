

export interface PagedResult<T> {
  items: T[];
  totalCount: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface SearchBookResponse {
  MADS?: string;
  TENDS?: string;
  TENTL?: string;
  TENNXB?: string;
  NAMXB?: number;
  TACGIA?: string;
  SOLUONG?: number;
  SLCON?: number;
}











export interface TopBookResponse {
  MADS?: string;
  TENDS?: string;
  SOLUOTMUON?: number;}

export interface MonthlyStatsResponse {
  SOPHIEU: number;
  SOLUOTSACH: number;
  TIENPHAT: number;
  top5Books: TopBookResponse[];
}



// --- Book Copies & Authors ---
export interface BookCopy {
  MACS: string;
  MADS: string;
  NGAYNHAP: string;
  VITRI: string;
  TINHTRANG: string;
}

export interface BookAuthor {
  MATG: string;
  VAITRO: string;
}







// --- Employees ---
export interface Employee {
  MANV: string;
  HOTEN: string;
  NGSINH: string;
  SODT: string;
  CHUCVU: string;
  NGVL: string;
}



// --- Reader Types ---




export interface Author {
    MATG: string;
    TENTG: string;
    NAMSINH?: number;
    QUOCTICH?: string;
}

export interface Category {
    MATL: string;
    TENTL: string;
}

export interface Publisher {
    MANXB: string;
    TENNXB: string;
    DIACHI?: string;
    SODT?: string;
}

export interface Book {
    MADS: string;
    TENDS: string;
    MATL: string;
    MANXB: string;
    NAMXB: number;
    SOTRANG: number;
    GIA: number;
}

export interface Reader {
    MADG: string;
    HOTEN: string;
    ngaySinh: string;
    GIOITINH: string;
    DIACHI?: string;
    SODT: string;
    EMAIL?: string;
    TONGNO?: number;
}

export interface FineSlip {
    maPT: string;
    MADG: string;
    soTienThu: number;
    ngayThu: string;
    LYDO?: string;
    MAPP?: string;
    MAPM?: string;
    TENDG?: string;
    DATHANHTOAN?: boolean;
}

export interface BackupHistory {
    backup_start_date: string;
    backup_finish_date: string;
    LOAI: string;
    DUONGDAN: string;
    DUNGLUONG_MB: number;
}

export interface BackupRequest {
    type: string;
}

export interface ChangePasswordRequest {
  oldPassword: string;
  newPassword: string;
}

export interface CreateAccountRequest {
  username: string;
  password: string;
  role: string;
  MANV: string | null;
  MADG: string | null;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface CreateAuthorRequest {
  MATG: string;
  TENTG: string;
  NAMSINH: number | null;
  QUOCTICH: string | null;
}

export interface UpdateAuthorRequest {
  TENTG: string;
  NAMSINH: number | null;
  QUOCTICH: string | null;
}

export interface CreateBookCopyRequest {
  MACS: string;
  VITRI: string;
  TINHTRANG: string;
}

export interface CreateBookRequest {
  MADS: string;
  TENDS: string;
  MATL: string;
  MANXB: string;
  NAMXB: number;
  SOTRANG: number;
  GIA: number;
}

export interface AuthorRoleRequest {
  MATG: string;
  VAITRO: string;
}

export interface UpdateBookAuthorsRequest {
  authors: AuthorRoleRequest[];
}

export interface UpdateBookCopyRequest {
  VITRI: string;
  TINHTRANG: string;
}

export interface UpdateBookRequest {
  TENDS: string;
  MATL: string;
  MANXB: string;
  NAMXB: number;
  SOTRANG: number;
  GIA: number;
}

export interface CreateCategoryReq {
  MATL: string;
  TENTL: string;
}

export interface UpdateCategoryRequest {
  TENTL: string;
}

export interface CreateEmployeeRequest {
  MANV: string;
  HOTEN: string;
  NGSINH: string;
  SODT: string;
  CHUCVU: string;
  NGVL: string;
}

export interface UpdateEmployeeRequest {
  HOTEN: string;
  NGSINH: string;
  SODT: string;
  CHUCVU: string;
  NGVL: string;
}

export interface CreatePublisherRequest {
  MANXB: string;
  TENNXB: string;
  DIACHI: string | null;
  SODT: string | null;
}

export interface UpdatePublisherRequest {
  TENNXB: string;
  DIACHI: string | null;
  SODT: string | null;
}

export interface CreateReaderRequest {
  MADG: string;
  HOTEN: string;
  NGSINH: string;
  GIOITINH: string;
  DIACHI: string | null;
  SODT: string;
  EMAIL: string | null;
}

export interface UpdateReaderRequest {
  MADG: string;
  HOTEN: string;
  NGSINH: string;
  GIOITINH: string;
  DIACHI: string | null;
  SODT: string;
  EMAIL: string | null;
}



export interface BackupResponse {
  message: string;
  history: BackupHistory[];
}

export interface MessageResponse {
  message: string;
}

export interface BorrowRequest {
  MADG: string;
  MANV: string;
  DSMACs: string[];
}

export interface BorrowResponse {
  message: string;
  MAPM: string;
}

export interface BorrowSlip {
  MAPM: string;
  MADG: string;
  TENDG: string;
  MANV: string;
  NGAYMUON: string;
  HANTRA: string;
  TINHTRANG: string;
  MACS: string;
  NGAYTRA: string | null;
  TINHTRANGTRA: string;
}

export interface PayFineRequest {
  MADG: string;
}

export interface ReturnRequest {
  MAPM: string;
  MACS: string;
  TINHTRANGTRA: string | null;
}

export type GenericApiResponse = Record<string, unknown>;
