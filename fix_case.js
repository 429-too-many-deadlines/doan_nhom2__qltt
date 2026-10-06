const fs = require('fs');
const path = require('path');

const mappings = {
  'maTL': 'MATL',
  'tenTL': 'TENTL',
  'maTG': 'MATG',
  'tenTG': 'TENTG',
  'namSinh': 'NAMSINH',
  'quocTich': 'QUOCTICH',
  'maNXB': 'MANXB',
  'tenNXB': 'TENNXB',
  'diaChi': 'DIACHI',
  'soDT': 'SODT',
  'soDt': 'SODT',
  'maDS': 'MADS',
  'tenDS': 'TENDS',
  'namXB': 'NAMXB',
  'soTrang': 'SOTRANG',
  'gia': 'GIA',
  'maNV': 'MANV',
  'maNv': 'MANV',
  'hoTen': 'HOTEN',
  'ngSinh': 'NGSINH',
  'chucVu': 'CHUCVU',
  'ngvl': 'NGVL',
  'ngVL': 'NGVL',
  'maDG': 'MADG',
  'maDg': 'MADG',
  'gioiTinh': 'GIOITINH',
  'email': 'EMAIL',
  'maLDG': 'MALDG',
  'maLdg': 'MALDG',
  'tenLDG': 'TENLDG',
  'loaiDG': 'LOAIDG',
  'tongNo': 'TONGNO',
  'soSachToiDa': 'SOSACHTOIDA',
  'soNgayMuon': 'SONGAYMUON',
  'maCS': 'MACS',
  'maCs': 'MACS',
  'ngayNhap': 'NGAYNHAP',
  'viTri': 'VITRI',
  'tinhTrang': 'TINHTRANG',
  'vaiTro': 'VAITRO',
  'soLuotMuon': 'SOLUOTMUON',
  'soPhieu': 'SOPHIEU',
  'soLuotSach': 'SOLUOTSACH',
  'tienPhat': 'TIENPHAT',
  'maPm': 'MAPM',
  'tinhTrangTra': 'TINHTRANGTRA',
  'lyDo': 'LYDO',
  'mapp': 'MAPP',
  'mapm': 'MAPM',
  'madg': 'MADG',
  'tendg': 'TENDG',
  'dathanhtoan': 'DATHANHTOAN',
  'manv': 'MANV',
  'ngaymuon': 'NGAYMUON',
  'hantra': 'HANTRA',
  'tinhtrang': 'TINHTRANG',
  'macs': 'MACS',
  'ngaytra': 'NGAYTRA',
  'tinhtrangtra': 'TINHTRANGTRA',
  'dsMaCs': 'DSMACs'
};

function walkDir(dir, callback) {
  fs.readdirSync(dir).forEach(f => {
    let dirPath = path.join(dir, f);
    let isDirectory = fs.statSync(dirPath).isDirectory();
    isDirectory ? 
      walkDir(dirPath, callback) : callback(path.join(dir, f));
  });
}

walkDir('./frontend/src', function(filePath) {
  if (filePath.endsWith('.ts') || filePath.endsWith('.tsx')) {
    let content = fs.readFileSync(filePath, 'utf8');
    let original = content;
    for (const [key, value] of Object.entries(mappings)) {
      const regex = new RegExp(`\\b${key}\\b`, 'g');
      content = content.replace(regex, value);
    }
    if (content !== original) {
      fs.writeFileSync(filePath, content);
      console.log(`Updated ${filePath}`);
    }
  }
});
