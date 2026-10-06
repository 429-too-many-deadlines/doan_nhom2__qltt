

export interface SearchBookResponse {
  // TODO: Thêm các trường dựa trên kết quả SP_TIMSACH trả về
  maSach?: string;
  tenSach?: string;
  tacGia?: string;}











export interface TopBookResponse {
  maSach?: string;
  tenSach?: string;
  soLuotMuon?: number;}

export interface MonthlyStatsResponse {
  soPhieu: number;
  soLuotSach: number;
  tienPhat: number;
  top5Books: TopBookResponse[];
}



// --- Book Copies & Authors ---
export interface BookCopy {
  maCS: string;
  maDS: string;
  ngayNhap: string;
  viTri: string;
  tinhTrang: string;
}

export interface BookAuthor {
  maTG: string;
  vaiTro: string;
}







// --- Employees ---
export interface Employee {
  maNV: string;
  hoTen: string;
  ngSinh: string;
  soDT: string;
  chucVu: string;
  ngvl: string;
}



// --- Reader Types ---
export interface ReaderType {
  maLDG: string;
  tenLDG: string;
  soSachToiDa: number;
  soNgayMuon: number;
}




export interface Author {
    maTG: string;
    tenTG: string;
    namSinh?: number;
    quocTich?: string;
}

export interface Category {
    maTL: string;
    tenTL: string;
}

export interface Publisher {
    maNXB: string;
    tenNXB: string;
    diaChi?: string;
    soDT?: string;
}

export interface Book {
    maDS: string;
    tenDS: string;
    maTL: string;
    maNXB: string;
    namXB: number;
    soTrang: number;
    gia: number;
}

export interface Reader {
    maDG: string;
    hoTen: string;
    ngaySinh: string;
    gioiTinh: string;
    diaChi?: string;
    soDT: string;
    email?: string;
    maLDG: string;
    loaiDG?: string;
    tongNo?: number;
}

export interface FineSlip {
    maPT: string;
    maDG: string;
    soTienThu: number;
    ngayThu: string;
    lyDo?: string;
    mapp?: string;
    mapm?: string;
    madg?: string;
    tendg?: string;
    dathanhtoan?: boolean;
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
  maNV: string | null;
  maDG: string | null;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface CreateAuthorRequest {
  maTG: string;
  tenTG: string;
  namSinh: number | null;
  quocTich: string | null;
}

export interface UpdateAuthorRequest {
  tenTG: string;
  namSinh: number | null;
  quocTich: string | null;
}

export interface CreateBookCopyRequest {
  maCS: string;
  viTri: string;
  tinhTrang: string;
}

export interface CreateBookRequest {
  maDS: string;
  tenDS: string;
  maTL: string;
  maNXB: string;
  namXB: number;
  soTrang: number;
  gia: number;
}

export interface AuthorRoleRequest {
  maTG: string;
  vaiTro: string;
}

export interface UpdateBookAuthorsRequest {
  authors: AuthorRoleRequest[];
}

export interface UpdateBookCopyRequest {
  viTri: string;
  tinhTrang: string;
}

export interface UpdateBookRequest {
  tenDS: string;
  maTL: string;
  maNXB: string;
  namXB: number;
  soTrang: number;
  gia: number;
}

export interface CreateCategoryReq {
  maTL: string;
  tenTL: string;
}

export interface UpdateCategoryRequest {
  tenTL: string;
}

export interface CreateEmployeeRequest {
  maNV: string;
  hoTen: string;
  ngSinh: string;
  soDT: string;
  chucVu: string;
  ngVL: string;
}

export interface UpdateEmployeeRequest {
  hoTen: string;
  ngSinh: string;
  soDT: string;
  chucVu: string;
  ngVL: string;
}

export interface CreatePublisherRequest {
  maNXB: string;
  tenNXB: string;
  diaChi: string | null;
  soDT: string | null;
}

export interface UpdatePublisherRequest {
  tenNXB: string;
  diaChi: string | null;
  soDT: string | null;
}

export interface CreateReaderRequest {
  maDg: string;
  hoTen: string;
  ngSinh: string;
  gioiTinh: string;
  diaChi: string | null;
  soDt: string;
  email: string | null;
  maLdg: string;
}

export interface UpdateReaderRequest {
  maDg: string;
  hoTen: string;
  ngSinh: string;
  gioiTinh: string;
  diaChi: string | null;
  soDt: string;
  email: string | null;
  maLdg: string;
}

export interface CreateReaderTypeRequest {
  maLDG: string;
  tenLDG: string;
  soSachToiDa: number;
  soNgayMuon: number;
}

export interface UpdateReaderTypeRequest {
  tenLDG: string;
  soSachToiDa: number;
  soNgayMuon: number;
}

export interface BackupResponse {
  message: string;
  history: BackupHistory[];
}

export interface MessageResponse {
  message: string;
}

export interface BorrowRequest {
  maDg: string;
  maNv: string;
  dsMaCs: string[];
}

export interface BorrowResponse {
  message: string;
  maPm: string;
}

export interface BorrowSlip {
  mapm: string;
  madg: string;
  tendg: string;
  manv: string;
  ngaymuon: string;
  hantra: string;
  tinhtrang: string;
  macs: string;
  ngaytra: string | null;
  tinhtrangtra: string;
}

export interface PayFineRequest {
  maDg: string;
}

export interface ReturnRequest {
  maPm: string;
  maCs: string;
  tinhTrangTra: string | null;
}

export type GenericApiResponse = Record<string, unknown>;
