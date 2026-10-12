// Giới hạn độ dài theo schema CSDL (db/1_TaoBang.sql), khớp với QuanLyThuVien.Server/Shared/DbRules.cs.
// Backend vẫn kiểm tra lại; phần này chỉ để người dùng không nhập quá độ dài.
export const DB_LIMITS = {
  MADG: 5,
  MADS: 5,
  MACS: 5,
  MATG: 5,
  MANXB: 5,
  MATL: 4,
  MAPM: 6,
  HOTEN_DG: 40,
  DIACHI_DG: 100,
  SODT: 15,
  EMAIL: 50,
  TENDS: 100,
  TENTL: 50,
  TENTG: 50,
  QUOCTICH: 30,
  TENNXB: 60,
  DIACHI_NXB: 100,
  VITRI: 20,
  TENDANGNHAP: 30,
  MATKHAU: 100,
} as const;

// Giá trị hợp lệ theo CHECK constraint CK_DOCGIA_GIOITINH
export const GIOITINH_OPTIONS = ['Nam', 'Nữ'] as const;
