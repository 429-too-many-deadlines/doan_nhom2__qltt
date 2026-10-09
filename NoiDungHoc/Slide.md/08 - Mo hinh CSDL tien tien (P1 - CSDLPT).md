# CHƯƠNG 5: MỘT SỐ MÔ HÌNH CSDL TIÊN TIẾN: CSDL PHÂN TÁN

**Khoa Khoa học và kỹ thuật thông tin**
**Bộ môn Thiết bị di động và Công nghệ Web**

---

## Nội dung

1. Khái niệm về CSDL phân tán.
2. Các đặc điểm của Cơ sở dữ liệu phân tán.
3. Các kỹ thuật phân mảnh.
4. Thiết kế CSDL phân tán.

---

## 1. Khái niệm

### Khái niệm 1:
CSDL phân tán là tập dữ liệu mà về mặt logic chúng thuộc cùng 1 hệ thống nhưng về mặt vật lý được trải ra nhiều nơi trong 1 mạng máy tính.

### Khái niệm 2:
CSDL phân tán là tập CSDL phân bố trên các máy tính khác nhau cùng một mạng. Mỗi máy có khả năng xử lý tự trị, có các ứng dụng local, tham gia vào ứng dụng global bằng hệ thống mạng.

---

### Ví dụ minh hoạ

**Ví dụ:** Ngân hàng ACB có 3 chi nhánh: Hà Nội (Site A), Đà Nẵng (Site B), và TP. Hồ Chí Minh (Site C). Mỗi chi nhánh quản lý dữ liệu khách hàng và giao dịch tại địa phương mình.

* `KHACHHANG(MSKH, TENKH)`
* `GIAODICH(MSGD, MSKH, SOTIEN, GUIRUT)`

➔ **Dữ liệu được phân tán như sau:**
* Site A: chứa dữ liệu KHACHHANG & GIAODICH tại Hà Nội
* Site B: chứa dữ liệu KHACHHANG & GIAODICH tại Đà Nẵng
* Site C: chứa dữ liệu KHACHHANG & GIAODICH tại TP.HCM

**Tình huống:** Khách hàng John (MSKH = KH1001) đăng ký tài khoản tại chi nhánh C (TP.HCM), thực hiện:
* Gửi tiền tại C
* Rút tiền tại C
* Sau đó gửi tiền vào tài khoản người thân tại chi nhánh A (Hà Nội)

Trong lúc xử lý giao dịch cuối, hệ thống cần truy vấn, cập nhật dữ liệu ở chi nhánh A và C, tức là:
* Có tương tác giữa hai site khác nhau
* Cùng một giao dịch ảnh hưởng nhiều vị trí lưu trữ dữ liệu

---

## 2. Đặc điểm CSDL phân tán

* Độc lập dữ liệu, tự trị.
* Dư thừa dữ liệu.
* Cấu trúc vật lý phức tạp.
* Tính toàn vẹn, toàn cục.
* Điều khiển đồng thời.
* Tính bảo mật.

### Độc lập dữ liệu và tính tự trị (Data Independence & Autonomy)

**Ý nghĩa:**
Mỗi site (nút trong hệ thống) có thể:
* Tự quản lý dữ liệu tại chỗ
* Quyết định cấu trúc bảng, quyền truy cập, chính sách riêng
* Không cần phụ thuộc hoàn toàn vào trung tâm

**Ví dụ:**
Chi nhánh A có thể cập nhật bảng KHACHHANG của riêng mình mà không cần xin phép trung tâm
* Ưu điểm: Dễ mở rộng, giảm phụ thuộc
* Thách thức: Khó đồng bộ và chuẩn hóa dữ liệu

### Dư thừa dữ liệu (Data Redundancy)

**Ý nghĩa:**
Cùng một dữ liệu có thể được lưu trữ ở nhiều site khác nhau để:
* Tăng hiệu năng (truy vấn gần)
* Hỗ trợ backup, khôi phục
* Gây ra tình trạng **trùng lặp dữ liệu** nếu không quản lý tốt

**Ví dụ:**
Dữ liệu khách hàng “John” có thể được lưu tại cả chi nhánh A và C
* Ưu điểm: Tăng tính sẵn sàng
* Thách thức: Khó duy trì tính nhất quán

### Cấu trúc vật lý phức tạp (Complex Physical Structure)

**Ý nghĩa:**
Dữ liệu được phân tán theo địa lý, server, định dạng khác nhau
* Cần có cơ chế định tuyến truy vấn, giao tiếp mạng, đồng bộ dữ liệu

**Ví dụ:**
Một phần dữ liệu lưu ở Hà Nội (SQL Server), phần khác ở TP.HCM (Oracle)
* Thách thức:
    * Cấu hình hệ thống phức tạp
    * Chi phí hạ tầng cao

### Tính toàn vẹn và toàn cục (Integrity & Consistency)

**Ý nghĩa:**
Hệ thống cần đảm bảo ràng buộc toàn vẹn dữ liệu ở mức toàn hệ thống, không chỉ trong 1 site
* Phải kiểm tra ràng buộc dù dữ liệu nằm ở nơi khác

**Ví dụ:**
Mã khách hàng (MSKH) không được trùng trên toàn quốc
* Ưu điểm: Đảm bảo dữ liệu tin cậy
* Thách thức: Khó thiết kế kiểm tra toàn cục, nhất là khi mạng không ổn định

### Điều khiển đồng thời (Concurrency Control)

**Ý nghĩa:**
Nhiều người dùng ở nhiều site có thể cùng truy cập/sửa cùng 1 dữ liệu
* Cần có cơ chế kiểm soát xung đột, khóa phân tán, rollback đa site

**Ví dụ:**
2 nhân viên ở chi nhánh A và B cùng chỉnh sửa giao dịch cho khách hàng John
* Ưu điểm: Tránh lỗi logic, mất mát dữ liệu
* Thách thức: Cần đồng bộ phức tạp (2-phase commit, timestamp...)

### Tính bảo mật (Security)

**Ý nghĩa:**
Mỗi site có thể có chính sách bảo mật riêng
Cần đảm bảo:
* Xác thực người dùng theo phân quyền
* Mã hóa khi truyền dữ liệu giữa các site
* Phân quyền truy cập theo vùng

**Ví dụ:**
Nhân viên giao dịch làm việc ở chi nhánh C không được phép xem các dữ liệu không liên quan khác tại chi nhánh A
* Ưu điểm: Bảo vệ dữ liệu phân tán
* Thách thức: Cần phối hợp chính sách bảo mật giữa nhiều node

### CSDL phân tán vs. CSDL tập trung

**CSDL tập trung:**
* Không độc lập dữ liệu cao.
* Tự trị duy nhất.
* Rủi ro cao.

**CSDL phân tán:**
* Độc lập dữ liệu cao.
* Tính tự trị cao.
* Cấu trúc vật lý, quản trị phức tạp.
* Chi phí lớn.

---

## Hệ quản trị CSDL phân tán

* Truy xuất dữ liệu từ xa (remote access)
* Hỗ trợ mức trong suốt (transparency) cho csdl phân tán.
* Hỗ trợ quản trị, giám sát csdl.
* Hỗ trợ phục hồi dữ liệu.
* Hỗ trợ môi trường không đồng nhất.

### Ví dụ: Hệ quản trị CSDL phân tán

**Truy xuất dữ liệu từ xa (remote access)**
* Do hệ quản trị CSDL cung cấp: không phong phú, chưa đáp ứng được nhu cầu đa dạng.
* Do phần mềm ứng dụng cung cấp.

**Hỗ trợ mức trong suốt cho csdl phân tán**
* `HOADON(mshd, tt)`
* `CTHD(mshd, msmh, sl, dongia)`
* `MATHANG(msmh, ten, donvitinh)`
Tại A không có dữ liệu Mathang. Sự hỗ trợ trong suốt làm cho A có cảm giác Mathang vẫn có tại A.

**Hỗ trợ quản trị , giám sát (audit, monitor) csdl**
* CSDL phân tán có các công cụ: Quản lý dữ liệu trên **nhiều site**, Giám sát trạng thái hoạt động, tốc độ đồng bộ, lỗi, Phân quyền người dùng theo từng site hoặc toàn hệ thống, …

**Hỗ trợ phục hồi (recover) dữ liệu**
* Khi có giao tác phân tán không hoàn thành, hệ quản trị phải hỗ trợ phục hồi csdl.

**Ví dụ:**
* `NHANKHAU(msnk, tennk)` ➔ Ở PHƯỜNG
    * 01 A
    * 02 B
* `NHANKHAU(msnk, tennk, phuong)` ➔ Ở QUẬN
    * 01 A 1
    * 02 B 1
    * 03 C 2
Khi B cập nhật `(02,’B’,2)` và truyền cập nhật tới Quận, nếu có sự cố xảy ra thì phải khôi phục đồng thời tại Phường và Quận, nghĩa là tại Phường 1 có giá trị `(02,’B’)`.

**Hỗ trợ môi trường không đồng nhất (in-homogeneous)**
* Các server có thể khác biệt phần cứng, HDH, hệ quản trị csdl. Tuy nhiên khác biệt về hệ quản trị csdl (khác về xử lý, lưu trữ, dữ liệu) là khó khăn lớn.
* Một hệ phân tán hình thành từ các hệ đã tồn tại trước khó đồng nhất.
* Một hệ phân tán hình thành từ khảo sát, phân tích, thiết kế từ đầu dễ đồng nhất.

---

## Kiến trúc CSDL phân tán 

* Mỗi quan hệ toàn cục có thể được chia thành các thành phần không trùng nhau được gọi là các phân mảnh. 
* Có nhiều cách để phân mảnh mà chúng ta sẽ bàn đến sau. 
* Ánh xạ từ các quan hệ toàn cục đến các phân mảnh được định nghĩa trong lược đồ phân mảnh. 
* Phép ánh xạ này là một-nhiều, nghĩa là có một số phân mảnh tương ứng với một quan hệ toàn cục nhưng chỉ có một quan hệ toàn cục ứng với một phân mảnh. 
* Các phân mảnh được chỉ định bởi tên quan hệ toàn cục với một chỉ mục (chỉ mục phân mảnh) ví dụ Ri chỉ phân mảnh thứ i của quan hệ toàn cục R.

* **Global schema:** Là các lược đồ quan hệ toàn cục.
* **Fragmentation:** là các lược đồ quan hệ đã phân mảnh.
* **Allocation schema:** gồm các lược đồ quan hệ đã phân mảnh gắn liền với vị trí vật lý tương ứng.
* Sau công đoạn thiết kế sẽ là phần cài đặt trên các hệ QTSDL tại các vị trí vật lý cụ thể.

---

## 3. CÁC KỸ THUẬT PHÂN MẢNH

### NHÂN BẢN (REPLICATION)
* Một quan hệ toàn cục $R(A_1, A_2, . . ., A_n)$, các quan hệ $R_i$ được phân bố giống hoàn toàn về cấu trúc cũng như tất cả dữ liệu so với R tạo ra hiện tượng nhân bản.
* Cho quan hệ toàn cục `SV(MSSV, TENSV, NAMS, NOIS, GT, DIACHI, EMAIL, MSK)` Nếu ta có 2 quan hệ SV1, SV2 có cùng cấu trúc và số dòng như SV nhưng khác site, thì SV1, SV2 được gọi là nhân bản của SV.

### Phân mảnh ngang (Horizontal fragmentation)
* Một quan hệ toàn cục $R(A_1, A_2, . . ., A_n)$ chia thành tập các quan hệ con Ri dựa vào các thuộc tính trên R. Các $R_i$ được gọi là phân mảnh ngang của R.
* Kí hiệu: $R_i = \sigma_{dk} (R)$.
* Ví dụ: cho quan hệ toàn cục `SV(MSSV, TENSV, NAMS, NOIS, GT, DIACHI, EMAIL, MSK)`
* Ta tạo ra 02 quan hệ SV3, SV4 thỏa điều kiện sau:
    * `SV3 = \sigma_{MSK=’CNTT’} (SV)`
    * `SV4 = \sigma_{MSK=’DTVT’} (SV)`
* Người ta phân loại phân mảnh ngang thành: Phân mảnh ngang (PMN) nguyên thủy và PMN dẫn xuất.

**Phân mảnh ngang nguyên thủy:**
* PMN nguyên thủy là PMN chỉ dựa trên một quan hệ.
* Ví dụ: cho quan hệ toàn cục `SV(MSSV, TENSV, NAMS, NOIS, GT, DIACHI, EMAIL, MSK)`
* Ta tạo ra 02 quan hệ SV3’, SV4’ thỏa điều kiện sau, chúng tạo thành 2 phân mảnh ngang của SV.
    * `SV3’ = \sigma_{GT=’Nu’} (SV)`
    * `SV4’ = \sigma_{GT=’Nam’} (SV)`

**Phân mảnh ngang dẫn xuất:**
* PMN dẫn xuất là PMN một quan hệ nhưng cần dựa vào quan hệ khác để phân mảnh.
* Ví dụ:
    * `SV5 = \pi [\sigma_{tenkhoa=’Cong Nghe Thong Tin’} (SV ⋈ KHOA) + Đk phép kết]`
    * `SV6 = \pi [\sigma_{tenkhoa=’Dien Tu Vien Thong’} (SV ⋈ KHOA) + Đk phép kết]`
* Một cách thể hiện khác của SV5, SV6:
    * `SV5 = \pi [ (SV3 ⋈ KHOA)]`
    * `SV6 = \pi [ (SV4 ⋈ KHOA)]`

### Phân mảnh dọc (Vertical fragmentation)
* Một quan hệ toàn cục $R(A_1, A_2, . . ., A_n)$ chia thành tập các quan hệ con Ri bằng cách rải các thuộc tính vào các quan hệ con Ri.
* Kí hiệu: $R_i = \pi_{\text{các cột}} (R)$
* Ví dụ: cho quan hệ toàn cục `SV(MSSV, TENSV, NAMS, NOIS, GT, DIACHI, EMAIL,MSK)`
* Ta tạo ra 02 quan hệ SV7, SV8 thỏa điều kiện sau:
    * `SV7 = \pi_{MSSV, NAMS, NOIS, GT, DIACHI, EMAIL, MSK} (SV)`
    * `SV8 = \pi_{MSSV, TENSV} (SV)`
* Người ta phân loại phân mảnh dọc thành: Phân mảnh dọc không dư thừa và Phân mảnh dọc dư thừa.

**Phân mảnh dọc không dư thừa (non-redundant fragmentation):**
* Phân mảnh dọc không dư thừa là các phân mảnh dọc không chứa thuộc tính chung không khóa nào cả.
* Ví dụ: `GV(MSGV, TENGV, NAMS, NOIS, GT, DC, SDT, NGAYVD)`
* Chia GV thành 2 phân mảnh dọc:
    * `GV1(MSGV, TENGV, NAMS, NOIS, GT, DC, SDT)`
    * `GV2(MSGV, NGAYVD)`

**Phân mảnh dọc dư thừa (redundant fragmentation):**
* Phân mảnh dọc dư thừa là các phân mảnh dọc chứa một hoặc nhiều thuộc tính chung không khóa.
* Ví dụ: `GV(MSGV, TENGV, NAMS, NOIS, GT, DC, SDT, NGAYVD)`
* Chia GV thành 2 phân mảnh dọc:
    * `GV3(MSGV, TENGV, NAMS, NOIS, GT, DC, SDT)`
    * `GV4(MSGV, TENGV, NGAYVD)`

### Phân mảnh hỗn hợp
* Một quan hệ toàn cục $R(A_1, A_2, . . ., A_n)$ được chia thành các quan hệ con Ri kết hợp cả phân mảnh ngang lẫn phân mảnh dọc.
* Ví dụ: cho quan hệ toàn cục `SV(MSSV, TENSV, NAMS, NOIS, GT, DIACHI, EMAIL, MSK)`
* 02 quan hệ SV3, SV4 thỏa điều kiện sau, chúng tạo thành 2 phân mảnh ngang của SV.
    * `SV3 = \sigma_{MSK=’CNTT’} (SV)`
    * `SV4 = \sigma_{MSK=’DTVT’} (SV)`
* Tạo ra SV9, SV10 theo công thức:
    * `SV9 = \pi_{MSSV, NAMS, NOIS, GT, DIACHI, EMAIL, MSK} [\sigma_{MSK=’CNTT’} (SV)]`
    * `SV10 = \pi_{MSSV, TENSV} [\sigma_{MSK=’CNTT’} (SV)]`
* Ta nói SV9, SV10 là phân mảnh hỗn hợp của SV.

### Ưu khuyết của việc phân mảnh

**Trùng lắp dữ liệu và cấu trúc (Nhân bản)**
* Ưu điểm:
    * Tốc độ truy xuất dữ liệu nhanh chóng
    * Do khoảng cách vật lý nhỏ.
    * Số xử lý trong cùng một thời điểm là nhỏ.
    * Sức đề kháng cao: xác suất toàn bộ mạng sụp đổ cùng lúc là nhỏ.
* Khuyết điểm: 
    * Cơ sở vật chất tốn kém (CPU, harddisk)
    * Xử lý vấn đề thêm xóa sửa phức tạp do dữ liệu cần đồng nhất.

**Trùng về cấu trúc khác dữ liệu (cắt ngang)**
* Ưu điểm:
    * Tự nhiên.
    * Hiệu quả tìm kiếm.
    * An toàn dữ liệu, dễ tìm lỗi.
* Khuyết điểm: 
    * Tốc độ không tốt khi truy xuất từ xa.
    * Gặp sự cố trên node chứa dữ liệu độc quyền dẫn đến mất mát dữ liệu.
    * Rất phổ biến.

**Khác nhau về cấu trúc và trùng dữ liệu (cắt dọc)**
* Ưu điểm:
    * Tiết kiệm không gian lưu trữ.
* Khuyết điểm:
    * Mất thời gian lấy dữ liệu từ xa.

**Mô hình hỗn hợp**
* Là sự trộn lẫn giữ 3 mô hình 1, 2, 3.
* Ưu điểm:
    * Lấy ưu của 3 mô hình.
    * Độ linh động cao.
* Khuyết:
    * Lấy khuyết của 3 mô hình.
    * Quản lý rất phức tạp.
    * Mang tính tự nhiên cao nhất

### Ví dụ tổng hợp

Cho CSDL Quản lý sinh viên như sau:

`SINHVIEN(MSSV, HoTen, NgVDoan, NgVDang, NgSinh, QueQuan, MaKhoa)`
* `123`, `Ng. V. A`, `8/2/2012`, `8/8/2015`, `11/2/2000`, `TPHCM`, `KHKTTT`
* `124`, `Ng. V. B`, `8/1/2017`, `8/3/2019`, `9/7/2000`, `Vinh Long`, `KHMT`

`MONHOC(MSMH, TenMH, SoTC, MaKhoaQL)`
* `IE103`, `QLTT`, `4`, `KHKTTT`
* `IT003`, `CTDL&GT`, `4`, `KHMT`

`DIEMSO(MSSV, MSMH, Diem)`
* `123`, `IE103`, `8`
* `123`, `IT003`, `8`
* `124`, `IE103`, `9`

`KHOA(MaKhoa, TenKhoa, NGTL)`
* `KHKTTT`, `Khoa hoc va Ky Thuat Thong tin`, `09/11/2018`
* `KHMT`, `Khoa hoc may tinh`, `08/06/2006`

**Xây dựng CSDL phân bố cho các phòng ban sau:**
1. Phòng đào tạo.
2. Phòng CTSV.
3. Văn phòng Khoa (cụ thể là Khoa Khoa học và Kỹ thuật thông tin).

**Phòng đào tạo:**
* `SINHVIEN(MSSV, HoTen, NgVDoan, QueQuan, MaKhoa)` ➔ Phân mảnh dọc
* `MONHOC(MSMH, TenMH, SoTC, MaKhoaQL)` ➔ Nhân bản
* `DIEMSO(MSSV, MSMH, Diem)` ➔ Nhân bản
* `KHOA(MaKhoa, TenKhoa, NGTL)` ➔ Nhân bản

**Phòng CTSV:**
* `SINHVIEN(MSSV, HoTen, NgVDoan, NgVDang, NgSinh, QueQuan, MaKhoa)` ➔ Nhân bản
* `KHOA(MaKhoa, TenKhoa, NGTL)` ➔ Nhân bản

**Văn phòng Khoa:**
* `SINHVIEN(MSSV, HoTen, NgVDoan, NgVDang, NgSinh, QueQuan)` ➔ Phân mảnh dọc
    * Chọn `123`, `Ng. V. A`, `8/2/2012`, `8/8/2015`, `11/2/2000`, `TPHCM`, `KHKTTT` ➔ Phân mảnh ngang
* `MONHOC(MSMH, TenMH, SoTC)` ➔ Phân mảnh dọc
* `DIEMSO(MSSV, MSMH, Diem)` ➔ Phân mảnh dọc

---

## 4. THIẾT KẾ CƠ SỞ DỮ LIỆU PHÂN TÁN

### CÁC MỤC TIÊU THIẾT KẾ
1. Sự truy xuất cục bộ.
2. Tính sẵn sàng của các dữ liệu phân tán.
3. Sự phân bố tải.
4. Chi phí lưu trữ.

**1. Sự truy xuất cục bộ**
* Mục tiêu của sự phân tán dữ liệu là để các ứng dụng truy xuất dữ liệu cục bộ càng nhiều càng tốt, giảm bớt các truy xuất dữ liệu từ xa.
* Việc thiết kế sự phân tán dữ liệu để tối đa hoá truy xuất cục bộ có thể được thực hiện bằng cách thêm số lượng các CSDL cục bộ thay thế cho các tham khảo CSDL từ xa tương ứng. 

**2. Tính sẵn sàng của các dữ liệu phân tán.**
* Mức độ sẵn sàng cao đối với các ứng dụng chỉ đọc được thực hiện bằng cách lưu trữ nhiều bản sao của cùng một thông tin; hệ thống phải có khả năng chuyển đến bản sao được chọn thích hợp khi một bản sao không được truy xuất bình thường.
* Độ khả tín cũng được thực hiện bằng cách lưu trữ nhiều bản sao, khi đó nó có khả năng phục hồi khi có sự phá huỷ một số bản sao.

**3. Sự phân bố tải.**
* Sự phân bố tải trên các sites là một tính chất quan trọng của các hệ thống máy tính phân tán. 
* Sự phân bố tải để tận dụng sức mạnh của việc sử dụng các máy tính, và cực đại hoá mức độ xử lý song song các lệnh thực thi của các ứng dụng. Vì sự phân bố tải có thể ảnh hưởng xấu đến sự truy xuất cục bộ nên cần xem xét để cân bằng hai mục tiêu này.

**4. Chi phí lưu trữ**
* Sự phân tán cơ sở dữ liệu phản ánh chi phí của sự lưu trữ tại các sites khác nhau. 
* Tuy nhiên chi phí lưu trữ dữ liệu không đáng kể so với chi phí xuất nhập, chi phí truyền thông của các ứng dụng. 
* Những giới hạn của bộ lưu trữ phải được xem xét kỹ.

### CÁC CHIẾN LƯỢC THIẾT KẾ CSDL PHÂN TÁN
Có hai cách tiếp cận cho thiết kế cơ sở dữ liệu: 
* Tiếp cận từ trên-xuống (top-down). 
* Tiếp cận từ dưới-lên (bottom-up).

**TOP-DOWN**
* Đặc điểm của tiếp cận Top-down:
    * Thiết kế lược đồ phổ quát
    * Thiết kế sự phân mảnh cơ sở dữ liệu 
    * Cấp phát các mảnh đến các sites, tạo các ảnh vật lý của chúng.
* Cách tiếp cận này thích hợp đối với các hệ thống được phát triển từ đầu và nó cho phép thiết kế một cách hợp lý. 
* Khi cơ sở dữ liệu phân tán được phát triển như là sự tổ hợp các cơ sở dữ liệu sẵn có thì nó lại không dễ dàng đối với phương pháp tiếp cận này. Trong trường hợp này lược đồ phổ quát thường được tạo ra từ sự thoả hiệp giữa các mô tả dữ liệu sẵn có. Từ đó cách tiếp cận từ dưới-lên có thể được sử dụng để thiết kế sự phân tán dữ liệu.

**BOTTOM UP**
* Cách thiết kế Bottom-up:
    * Chọn một mô hình cơ sở dữ liệu chung để mô tả lược đồ phổ quát của cơ sở dữ liệu.
    * Chuyển dịch mỗi lược đồ cục bộ vào trong mô hình dữ liệu chung.
    * Tổ hợp lại lược đồ cục bộ vào trong lược đồ phổ quát chung.
    * Ba vấn đề này không riêng biệt gì đối với cơ sở dữ liệu phân tán mà nó hiện diện ngay trong các hệ thống tập trung.

---

## TÀI LIỆU THAM KHẢO
1. Nguyễn Gia Tuấn Anh, Trương Châu Long, *Bài tập và bài giải SQL Server*, NXB Thanh niên (2005).
2. Đỗ Phúc, Nguyễn Đăng Tỵ, *Cơ sở dữ liệu*, NXB Đại học quốc gia TPHCM (2010).
3. Nguyễn Gia Tuấn Anh, Mai Văn Cường, Bùi Danh Hường, *Cơ sở dữ liệu nâng cao*, NXB Đại học quốc gia TPHCM (2019).
4. Itzik Ben-Gan, *Microsoft SQL Server 2012- TSQL Fundamentals*.

---

## Bài tập

1. Cho CSDL toàn cục sau, hãy đề xuất 1 mô hình phân tán, và lí giải cách chọn lựa; biết nhà trường hiện có 5 cơ sở tại các tỉnh A, B, C, D, E; mỗi cơ sở hiện có 8 khoa: k1, k2, k3,... k8.
    * `SV(#mssv, tensv, noisinh, namsinh, msk)`
    * `KHOA(#msk, tenkhoa)`
    * `MON(#msm, tenm, STC)`
    * `SV-MON(#mssv, #msm, diem)` 
    * `COSO (#mscs, tencs, diachi, sdt)`

2. Tìm các ứng dụng phổ biến, đang sử dụng mô hình phân tán? Tại sao đó là lựa chọn tốt nhất?

3. Tiến hành cài đặt bài 1 bằng 1 hệ QTCSDL? Viết các thực nghiệm so sánh nó với CSDLTT.

4. So sánh các tính năng phân tán được hỗ trợ trên 2 hệ QTCSDL Oracle và MySQL?

