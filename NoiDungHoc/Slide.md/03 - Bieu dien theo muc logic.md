# CHƯƠNG 2: TỔ CHỨC THÔNG TIN TRÊN MÁY TÍNH: BIỂU DIỄN DỮ LIỆU MỨC LOGIC

**Khoa Khoa học và kỹ thuật thông tin**  
**Bộ môn Thiết bị di động và Công nghệ Web**  
Trường Đại học Công nghệ Thông tin, ĐHQG-HCM

---

## Nội dung

1. Mô hình dữ liệu phẳng.
2. Mô hình dữ liệu có cấu trúc.
3. Chỉ mục và Khoá.
4. Mô hình quan hệ.
5. Ràng buộc toàn vẹn.
6. Mô hình dữ liệu XML.

---

## 1. Mô hình dữ liệu phẳng

- Một cơ sở dữ liệu phẳng là một hệ thống cơ sở dữ liệu đơn giản, trong đó mỗi cơ sở dữ liệu được biểu diễn như là một bảng duy nhất.
- Tuy nhiên, một số nhà phát triển ứng dụng vẫn sử dụng các tập tin phẳng để giảm chi phí và tính phức tạp của việc tích hợp cơ sở dữ liệu quan hệ.
- Cơ sở dữ liệu phẳng đôi khi cũng được gọi là cơ sở dữ liệu tệp phẳng (flat-file databases).

### VÍ DỤ

**Thông tin các lớp học và gia sư cho học sinh**

| ID No. | Name | D.o.B. | Phone | Class | Tutor | Room |
|---|---|---|---|---|---|---|
| 356 | Jess | 3 Mar 1995 | 7564356 | 5B | Mr Noggin | 56 |
| 412 | Hamad | 12 Nov 1994 | 7465846 | 5B | Mr Noggin | 56 |
| 459 | Sita | 9 Jan 1994 | 8565634 | 6Y | Ms Take | 18 |
| 502 | Hamad | 3 Mar 1995 | 6554546 | 5B | Mr Noggin | 56 |

**Bảng điểm sinh viên**

| STT | Mã số SV | Họ và tên sinh viên | Số tờ | Chữ ký sinh viên | Điểm số | Điểm chữ | Ghi chú | MAGV (Nếu điểm TH hoặc QT) |
|---|---|---|---|---|---|---|---|---|
| 1 | 20690162 | Võ Ngọc Thạch | | | 1 | | | 80495 |
| 2 | 23973621 | Ân Tuấn Ngọc | | | 4 | | | 80495 |
| 3 | 22680252 | Võ Thái San | | | 0 | | | 80495 |
| 4 | 24249617 | Đỗ Hoàng Ngôn | | | 5 | | | 80495 |
| 5 | 21620292 | Lâm Ngọc Lân | | | 5 | | | 80495 |
| 6 | 20705186 | Mạch Phước Thiện | | | 5 | | | 80495 |
| 7 | 20886991 | Vưu Hoài Tín | | | 1 | | | 80495 |
| 8 | 23229574 | Vũ Nam Hải | | | 3 | | | 80495 |
| 9 | 23915967 | Nguyễn Khắc Việt | | | 2 | | | 80495 |
| 10 | 24206686 | Huỳnh Quang Lâm | | | 8 | | | 80495 |
| 11 | 24303114 | Hàn Việt Hải | | | 7 | | | 80495 |
| 12 | 24479838 | Quách Chấn Hùng | | | 1 | | | 80495 |
| 13 | 23158847 | Uất Chí Dũng | | | 2 | | | 80495 |
| 14 | 22511656 | Mai Việt Thông | | | 7 | | | 80495 |
| 15 | 23684905 | Phạm Tuấn Thành | | | 0 | | | 80495 |
| 16 | 20923149 | Vũ Bình Đạt | | | 1 | | | 80495 |
| 17 | 22152474 | Mạch Quang Vinh | | | 6 | | | 80495 |
| 18 | 22173144 | Nguyễn Việt Phương | | | 0 | | | 80495 |
| 19 | 20626924 | Thân Trung Hiếu | | | 9 | | | 80495 |
| 20 | 23537981 | Hoàng Công Bằng | | | 5 | | | 80495 |
| 21 | 21269208 | Hàn Thành Tường | | | 8 | | | 80495 |
| 22 | 23152685 | Ngô Năng Tự | | | 1 | | | 80495 |
| 23 | 21726258 | Thạch Duy Chước | | | 9 | | | 80495 |
| 24 | 21751076 | Văn Vĩnh Cao | | | 0 | | | 80495 |

**Thông tin nhân viên (Tập tin phẳng - FlatDB.txt)**

```text
ID,Name,Age,Department,Salary,Email,Join_Date,Status,Location
1,John Doe,28,Engineering,75000,john.doe@example.com,2020-06-15,Active,New York
2,Jane Smith,32,Marketing,68000,jane.smith@example.com,2018-09-23,Active,Los Angeles
3,Alex Brown,25,Sales,54000,alex.brown@example.com,2021-03-10,Active,Chicago
4,Emily Davis,30,HR,62000,emily.davis@example.com,2019-11-05,Inactive,San Francisco
5,Michael Johnson,35,Finance,89000,michael.johnson@example.com,2017-08-22,Active,Houston
6,Sarah Lee,27,IT,72000,sarah.lee@example.com,2021-07-18,Active,Seattle
7,David Wilson,29,Operations,67000,david.wilson@example.com,2020-02-14,Active,Miami
8,Anna Roberts,31,Customer Support,58000,anna.roberts@example.com,2019-05-30,Inactive,Denver
9,James Taylor,40,Engineering,95000,james.taylor@example.com,2015-12-12,Active,Boston
10,Laura Green,26,Sales,52000,laura.green@example.com,2022-01-20,Active,Atlanta
```

**Thông tin sinh viên dưới dạng cấu trúc cố định (Fixed Width / JSON-like Schema)**

```text
form: FIXEDWIDTH
structures:
- id: 'StudentDetails'
  name: Student Details
  data:
  - { idRef: 'PersonalInfo' }
  - { idRef: 'CourseDetails' }
segments:
- id: 'PersonalInfo'
  name: "Personal Information"
  values:
  - { name: 'Record Type', type: String, length: 2, tagValue: 'PI' }
  - { name: 'Student Name', type: String, length: 10 }
  - { name: 'Student Contact', type: String, length: 10 }
  - { name: 'Student dob', type: String, length: 10 }
- id: 'CourseDetails'
  name: "Academic Details"
  values:
  - { name: 'Record Type', type: String, length: 2, tagValue: 'CD' }
  - { name: 'Student USN', type: String, length: 10 }
  - { name: 'Student course', type: String, length: 10 }
```

### ƯU VÀ NHƯỢC ĐIỂM CỦA CSDL PHẲNG

**ƯU ĐIỂM**
- Nhiều phương thức truy xuất khác nhau:
  + Tuần tự.
  + Ngẫu nhiên.
  + Chỉ mục.

**NHƯỢC ĐIỂM**
- Dữ liệu trùng lặp.
- Cần chi phí để xử lý dữ liệu đồng nhất và điều khiển việc truy xuất.
- Bảo mật kém.
- Rất khó để điều khiển việc nhiều người dùng cùng truy cập một lúc.

---

## 2. Mô hình dữ liệu có cấu trúc

### 2.1. Mô hình phân cấp

- Mô hình phân cấp (Hierarchical model)
  + Đưa ra vào những năm 60.
  + Dữ liệu được tổ chức thành cấu trúc cây.
  + Các nút (node) là tập các thực thể.
  + Các cành là các mối quan hệ giữa hai nút theo mối quan hệ nhất định.
- Là mô hình dữ liệu trong đó các bản ghi được sắp xếp theo cấu trúc top-down (tree).
- Một con chỉ có một cha, chỉ có một đường truy nhập tới dữ liệu đó trước.

**Ví dụ MÔ HÌNH PHÂN CẤP:**
- Hệ thống máy tính (cơ bản): 
  - Software -> Operating Systems, Developer Tools
  - Hardware -> Peripherals (Keyboards, Mice), Monitors
- Sơ đồ cơ cấu của tổ chức / Sơ đồ tổ chức của UIT.

**ƯU VÀ NHƯỢC ĐIỂM CỦA MÔ HÌNH PHÂN CẤP**

*ƯU ĐIỂM*
- Đơn giản về khái niệm:
  + Nhóm dữ liệu có thể được liên quan đến nhau.
  + Dữ liệu liên quan có thể được xem với nhau.
- Tập trung dữ liệu.
- Giảm sự dư thừa và phát huy tính nhất quán.

*NHƯỢC ĐIỂM*
- Biểu diễn hạn chế về mối quan hệ dữ liệu:
  + Không cho phép quan hệ (M:N)
- Thực hiện phức tạp:
  + Cần kiến thức chuyên sâu về lưu trữ dữ liệu vật lý
- Sự phụ thuộc cấu trúc:
  + Truy cập dữ liệu đòi hỏi đường dẫn lưu trữ vật lý

### 2.2. Mô hình mạng

- Được đưa vào cuối những năm 60.
- Dữ liệu được tổ chức thành một đồ thị có hướng.
- Các đỉnh là các thực thể.
- Các cung là quan hệ giữa hai đỉnh, một kiểu bản ghi có thể liên kết với nhiều kiểu bản ghi khác.
- Một con có thể có nhiều cha, có nhiều đường truy nhập đến một dữ liệu cho trước.

**Ví dụ MÔ HÌNH MẠNG:**
- Hệ thống cửa hàng (Store -> Customer, Manager, Salesman -> Order, Items).
- Mạng xã hội.
- Cảnh báo và phát hiện gian lận tài chính.
- Mạng viễn thông.
- Mạng doanh nghiệp.

**ƯU VÀ NHƯỢC ĐIỂM CỦA MÔ HÌNH MẠNG**

*ƯU ĐIỂM*
- Cho phép nhiều loại quan hệ dữ liệu.
- Hiệu quả và truy cập dữ liệu linh hoạt.
- Phù hợp với các tiêu chuẩn.
- Tăng cường quản trị cơ sở dữ liệu.

*NHƯỢC ĐIỂM*
- Hệ thống phức tạp.
- Đòi hỏi phải có sự quen thuộc với cấu trúc nội bộ để truy cập dữ liệu.
- Thay đổi cấu trúc nhỏ đòi hỏi thay đổi chương trình.

---

## 3. Chỉ mục và Khoá

### 3.1. Chỉ mục

- Chỉ mục (index) là bảng tra cứu đặc biệt mà Database Search Engine có thể sử dụng để tăng nhanh thời gian và hiệu suất thu thập dữ liệu.
- Phân loại:
  + Chỉ mục trên cột là khóa.
  + Chỉ mục trên cột không là khóa.
  + B Tree.

**Chỉ mục trên cột là khoá**
- Tập tin chỉ mục là một FILE với các mẫu tin có 2 cột: khóa và địa chỉ block, đã được sắp trên thuộc tính khóa. Địa chỉ khóa cho biết vị trí của block chứa mẫu tin trên đĩa. Tập tin chỉ mục có kích thước nhỏ hơn nhiều so với FILE dữ liệu chính. Vì vậy tập tin chỉ mục sẽ được đọc vào bộ nhớ chính khi chương trình CSDL khởi động.
- Vì tập tin chỉ mục đã được sắp nên nó dùng thuật toán tìm kiếm nhị phân khi tìm kiếm.
- Nếu 1 mẫu tin trong tập tin chỉ mục tương ứng 1 mẫu tin trong File dữ liệu chính ta gọi chỉ mục dày (dense index). Nếu 1 mẫu tin trong tập tin chỉ mục tương ứng nhiều mẫu tin trong File dữ liệu chính ta gọi chỉ mục thưa (nondense index).

**Chỉ mục trên cột không là khoá**
- Nếu các mẫu tin đã được sắp trên một cột không phải khóa (key) và có giá trị có thể lặp lại, cột đó được gọi là cột Clustering (clustering field), trường hợp này ta tạo ra một file chỉ mục gọi là Clustering Index.
- Clustering Index có 2 cột: cột 1 giống với cột clustering của file dữ liệu chính, cột thứ 2 chứa con trỏ khối chỉ tới đầu khối có chứa dữ liệu cột clustering. Giá trị trên cột 1 trong Clustering Index là duy nhất. Nó là 1 ví dụ của tập tin chỉ mục thưa.

### 3.2. B-Tree

- Định nghĩa: B Tree là cây tìm kiếm nhiều nhánh thỏa điều kiện sau:
  + Tất cả các node lá có cùng độ cao.
  + Tất cả các Node trung gian có nhiều nhất m cây con và có ít nhất m/2 cây con khác rỗng.
  + Node gốc có thể có m cây con hay có thể có 2 cây con không phải là lá.
  + Các giá trị khóa trên các Node đã sắp (tăng dần).
  + Gọi k là số cây con của một Node thì số khóa nằm trên Node là k-1.
  + Các Node có cùng cấu trúc dữ liệu.
  + Mỗi Node có cấu trúc như sau : `<P1, <K1, Q1>, P2, <K2, Q2>, . . .<. . . > >`
- Trong đó :
  + Pi là con trỏ đến một Node khác trong cây
  + Ki là khóa
  + Qi là con trỏ dữ liệu, trỏ đến block trên FILE dữ liệu chứa mẫu tin có khóa là Ki.

**Đánh giá về B-Tree**
- Vì có nhiều khóa trên một Node và có nhiều Node trên cùng độ cao nên việc tìm kiếm trên B Tree khá tốt. Càng nhiều mẫu tin trên một Node thì cây càng có độ cao càng nhỏ nhằm cải tiến tốc độ truy xuất đĩa.
- Tổ chức theo BTree không những nhanh hơn so với File có thứ tự mà việc thêm, xóa cũng hiệu quả hơn.

---

## 4. Mô hình quan hệ

### Giới thiệu
- E.F Codd (1923-2003) đưa vào đầu những năm 70.
- Dựa trên lý thuyết tập hợp và đại số quan hệ.
- Vì tính chất chặt chẽ của toán học về lí thuyết tập hợp nên mô hình này đã mô tả dữ liệu một cách rõ ràng, mềm dẻo và là mô hình thông dụng.
- Nhiều hệ QTCSDL đều tổ chức dữ liệu theo mô hình dữ liệu quan hệ.
- Trong đó dữ liệu được tổ chức dưới dạng bảng, các phép toán thao tác trên dữ liệu dựa trên lý thuyết tập hợp của toán học.

### Các thành phần chính của mô hình quan hệ
- Các khái niệm chính:
  + Quan hệ - ứng với bảng.
  + Bộ - ứng với dòng.
  + Thuộc tính - ứng với cột.
- Tân từ.
- Thể hiện của một quan hệ.
- Lược đồ quan hệ.

**Quan hệ**
- Các thông tin lưu trữ trong CSDL được tổ chức thành bảng (table) gọi là quan hệ.

**Bộ**
- Bộ là các dòng của quan hệ (trừ dòng tiêu đề: tên của các thuộc tính).
- Thể hiện dữ liệu cụ thể của các thuộc tính trong quan hệ.

**Thuộc tính**
- Thuộc tính:
  + Tên gọi: dãy ký tự (gợi nhớ).
  + Kiểu dữ liệu: Số, Chuỗi, Thời gian, Luận lý, OLE.
  + Miền giá trị: tập giá trị mà thuộc tính có thể nhận.
- Ký hiệu miền giá trị của thuộc tính A là Dom(A).
- Một thuộc tính không có giá trị hoặc chưa xác định được giá trị => giá trị Null.
- Tên các cột của quan hệ:
  + Mô tả ý nghĩa cho các giá trị tại cột đó.
  + Tất cả các dữ liệu trong cùng một cột đều có dùng kiểu dữ liệu.

**Thể hiện của quan hệ**
- Thể hiện của một quan hệ là tập hợp các bộ giá trị của quan hệ tại một thời điểm nhất định.
- VD: Thể hiện cho quan hệ Nhân viên tại 1 thời điểm t gồm các bộ (dòng) như sau:

| MaNV | HoNV | TenNV | Email | SDT | Phong | Luong |
|---|---|---|---|---|---|---|
| NV01 | Nguyen Van | A | email1@domain.com | 0123456789 | 1 | 20000 |
| NV02 | Tran Thanh | B | email2@domain.com | 0987643210 | 1 | 22000 |
| NV03 | Tran Thi | C | email3@domain.org | 0388888888 | 3 | 15000 |

**Lược đồ quan hệ**
- Cấu trúc của một quan hệ: là tập thuộc tính hình thành nên quan hệ.
- Một lược đồ quan hệ gồm:
  + Một tập thuộc tính của quan hệ.
  + Một mô tả để xác định ý nghĩa và mối liên hệ giữa các thuộc tính.
- Lược đồ quan hệ được đặc trưng bởi:
  + Một tên phân biệt.
  + Một tập hợp hữu hạn các thuộc tính (A1, ..., An).
- Ký hiệu: Q(A1, A2, ..., An).
- Ví dụ: quan hệ nhân viên
  + Tên quan hệ: NhanVien.
  + Các thuộc tính: MaNV, HoNV, TenNV, Email, SoDT, Phong, Luong.
  + Ký hiệu: `NhanVien(MaNV, HoNV, TenNV, Email, SoDT, Phong, Luong)`

**Tân từ**
- Định nghĩa: Tân từ là một quy tắc dùng để mô tả một quan hệ.
- Ký hiệu: ||Q||.
- Ví dụ: 
  `NhanVien(MaNV, HoNV, TenNV, Email, SoDT, Phong, Luong)`
  `||NhanVien||`: MaNV – mã nhân viên; HoNV – họ nhân viên; TenNV – tên nhân viên; Email – email của nhân viên; SoDT - số điện thoại nhân viên; Phong – Phòng làm việc của nhân viên; Luong – lương của nhân viên.

### Các phép toán trên quan hệ
- Phép chiếu: σ
- Phép chọn: Π
- Phép hội: ∪
- Phép giao: ∩
- Phép trừ: \
- Phép chia: ÷
- Phép kết: ⋈
- Phép gom nhóm: ℐ

---

## 5. Ràng buộc dữ liệu (Ràng buộc toàn vẹn)

- Là những quy tắc, điều kiện, ràng buộc cần thoả mãn cho mọi dữ liệu, để dữ liệu đúng đắn và thống nhất.
- Ràng buộc toàn vẹn (RBTV - Integrity Constraint) là các quy tắc, ràng buộc lên cơ sở dữ liệu, để hạn chế tình trạng xấu của cơ sở dữ liệu, không phản ánh đúng thế giới mà nó đang biểu diễn.
- Các quy tắc có thể xuất phát từ:
  + Bản thân mô hình dữ liệu.
  + Quy tắc trong quản lý.
  + Quy tắc trong tự nhiên.

**Ví dụ:**
- `NhanVien (MSNV, NgaySinh, NVCty)`
- Ta có: `NgaySinh < NVCty`.
- Giải thích: Ngày vào công ty của nhân viên phải lớn hơn ngày sinh của nhân viên.

### Các loại ràng buộc

**1. RBTV có bối cảnh trên một quan hệ**
- RBTV miền giá trị
  + RBTV liên quan tới giá trị của một thuộc tính (VD: Ngày nhận chức trưởng phòng phải là một ngày sau năm 1970).
  + RBTV NOT NULL (VD: Mọi nhân viên đều phải thuộc một phòng ban).
  + RBTV về thời gian (VD: Lương của nhân viên lúc nào cũng không được giảm).
- RBTV liên thuộc tính một quan hệ
  + Là ràng buộc giữa các thuộc tính trên cùng 1 bộ của quan hệ.
  + VD1: Nếu ngày sinh trước 1/1/1970 thì nhân viên đó phải có lương tối thiểu là 50000.
  + VD2: Ngày bắt đầu (TUNGAY) giảng dạy một môn học cho một lớp luôn nhỏ hơn ngày kết thúc (DENNGAY).
- RBTV liên bộ
  + Là ràng buộc giữa các bộ trên cùng một quan hệ (có thể liên quan đến nhiều thuộc tính).
  + RBTV khóa chính: mỗi quan hệ có một khóa chính và các giá trị khóa chính đều phải khác null (một phần hay toàn bộ). VD: Tất cả các học viên phải có mã số phân biệt với nhau.
  + RB duy nhất (Unique). VD: Tên các phòng ban phải khác nhau.
  + Ràng buộc về số bộ trong một quan hệ. VD: Mỗi dự án có tối đa 15 nhân viên tham gia.

**2. RBTV có bối cảnh trên nhiều quan hệ**
- RBTV tham chiếu (Khóa ngoại)
  + Còn gọi là ràng buộc phụ thuộc tồn tại hay ràng buộc khóa ngoại: Giá trị xuất hiện tại các thuộc tính trong một quan hệ nào đó phải tham chiếu đến giá trị khóa chính của một quan hệ khác cho trước.
  + VD1: Một dự án do một phòng ban chủ trì.
  + VD2: Một thân nhân phải có mối quan hệ với một nhân viên trong công ty.
  + VD3: Sinh viên thi một môn học nào đó thì môn học đó phải có trong danh sách các môn học.
  + *Đặc điểm khoá ngoại:*
    - Có thể NULL.
    - Một lựơc đồ quan hệ có thể có nhiều khoá ngoại.
    - Một thuộc tính có thể vừa tham gia khoá ngoại vừa tham gia khoá chính.
    - Tên khoá chính và khoá ngoại có thể khác nhau.
    - Khoá chính và khoá ngoại có thể nằm trên một lược đồ.
- RBTV liên bộ, liên quan hệ
  + Là ràng buộc xảy ra giữa các bộ trên nhiều quan hệ khác nhau.
  + VD1: Một phòng ban có ít nhất 3 nhân viên => Liên quan đến 2 quan hệ là PHONGBAN, NHANVIEN.
- RBTV liên thuộc tính, liên quan hệ
  + Là ràng buộc giữa các thuộc tính trên những quan hệ khác nhau: Thông thường đó là các phụ thuộc tính toán, một suy diễn giá trị của một hay nhiều thuộc tính.
  + VD1: Ngày sinh của trưởng phòng phải nhỏ hơn ngày nhận chức (PHONGBAN, NHANVIEN).
  + VD2: Ngày thi một môn học phải lớn hơn ngày kết thúc học môn học đó (GIANGDAY, KETQUATHI).
- RBTV do thuộc tính tổng hợp
  + Thuộc tính tổng hợp: là thuộc tính có giá trị được tính toán từ các thuộc tính khác của quan hệ khác. Khi CSDL có thuộc tính tổng hợp, RBTV bảo đảm quan hệ giữa thuộc tính tổng hợp và các thuộc tính nguồn.
  + VD1: Thuộc tính SLMH trong HOADON cho biết số loại sản phẩm có trong một hóa đơn (Đếm từ bảng CTHĐ).
  + VD2: Trị giá của một hoá đơn bằng tổng thành tiền của các chi tiết thuộc hoá đơn đó (Tổng Số lượng x Đơn giá của tất cả sản phẩm).
  + VD3: Sĩ số của một lớp là số lượng sinh viên thuộc lớp đó.
- RBTV do xuất hiện chu trình
  + RBTV do sự hiện diện của chu trình trên đồ thị biểu diễn lược đồ CSDL.
  + VD1: Trưởng phòng là một trong các nhân viên thuộc phòng.
  + VD2: Nhân viên chỉ được phân công vào các đề án do phòng ban của mình phụ trách.
  + VD3: Giảng viên chỉ được phân công dạy những môn do khoa trực thuộc phụ trách (GIANGDAY, GIAOVIEN, MONHOC).

**Các lưu ý**
- Khi thêm xoá sửa dữ liệu có thể vi phạm các ràng buộc khóa chính và khóa ngoại.
- Thứ tự tạo và xoá bảng có ý nghĩa.
- Thứ tự tạo và xoá dữ liệu trong bảng có ý nghĩa.

---

## 6. Mô hình dữ liệu XML

### Giới thiệu
- Dùng cho cơ sở dữ liệu nhỏ.
- Nền tảng: Win32, WinCE, PalmOS, Linux, Solaris
- Tìm kiếm, thêm, cập nhật và xóa dữ liệu trong cơ sở dữ liệu được tạo ra bởi các tập tin XML.
- Các cơ sở dữ liệu có thể là một phần của một ứng dụng.

### XML
- Là một dạng ngôn ngữ đánh dấu (markup language).
- Được sử dụng để tạo ra cấu trúc cho dữ liệu.
- Gồm 2 thành phần chính:
  + Thẻ: 
    - Thẻ mở đầu: ký hiệu `<tag>`.
    - Thẻ kết thúc: ký hiệu `</tag>`.
    - Thuộc tính cho thẻ (nếu có).
  + Nội dung.

**Ví dụ:**

```xml
<Telephone>
 <EntryID>1038</EntryID>
 <LoginName>jake</LoginName>
 <PassWord>pass38</PassWord>
 <Lastname>Kim</Lastname>
 <Firstname>Jungkee</Firstname>
 <Date_of_Birth>10.01.1964</Date_of_Birth>
 <Company>FSU</Company>
 <Salutation>Mr.</Salutation>
 <Email>jake@csit.fsu.edu</Email>
 <Address>
  <Street>400 Dirac Science Library</Street>
  <City>Tallahassee</City>
  <ZIP>32306</ZIP>
  <Country>Korea</Country>
  <Telephone>6447018</Telephone>
  <Fax /> 
 </Address>
</Telephone>
```

```xml
<university>
 <department>
  <dept_name> Comp. Sci. </dept_name>
  <building> Taylor </building>
  <budget> 100000 </budget>
 </department>
 <course>
  <course_id> CS-101 </course_id>
  <title> Intro. to Computer Science </title>
  <dept_name> Comp. Sci </dept_name>
  <credits> 4 </credits>
 </course>
</university>
```

### Cấu trúc cơ bản của một CSDL XML
- XML Document, XML Parser, XML Generator, Database (hỗ trợ Insert, Update, Delete, Search).
- Để truy vấn dữ liệu trên CSDL XML, ta dùng Xpath và Xquery.

---

## Bài tập

**Bài tập 1: Thiết kế lược đồ quan hệ cho CSDL quản lý đề tài tốt nghiệp như sau**
Người ta cần tin học hoá khâu Quản lí các đề tài tốt nghiệp của 1 trường ĐH. Với các thông tin sau:
- Mỗi SV năm 4 sẽ làm đề tài TN. Mỗi đề tài bao gồm Tên DT, giáo viên hướng dẫn, thời gian bắt đầu, kết thúc, thuộc khoa nào.
- Khoa sẽ thành lập hội đồng khoa học, mỗi HĐ gồm: Chủ tịch, 1 thành viên thư kí, ngày bảo vệ tại địa chỉ cụ thể. Mỗi đề tài sẽ bảo vệ tại một hội đồng, điểm đề tài là trung bình cộng của: Chủ tịch, 01 GV phản biện, 01 GV hướng dẫn. Giáo viên cho điểm theo từng Sinh viên mặc dù các sinh viên có thể làm chung đề tài.
- Trong đợt bảo vệ có thể có nhiều hội đồng, 1 GV có thể hướng dẫn nhiều DT, hay phản biện nhiều DT. Chủ tịch HD, thư ký là giáo viên. Mỗi giáo viên cần thông tin: Tên, địa chỉ, SDT, học vị, chuyên ngành.
- Mỗi DT có thể tối đa 03 Sinh viên thực hiện. SV có điểm TB<5 sẽ phải bảo vệ lại với khóa sau và chỉ được bảo vệ tối đa 2 lần, đề tài lần 1 phải khác lần 2.

**Bài tập 2: Chỉ mục**
- Tạo 1 CSDL mẫu
  + Phát hiện các ràng buộc trên CSDL.
  + Cài đặt CSDL và các ràng buộc này trên SQL Server.
- Thử nghiệm:
  + Thêm vào các bảng dữ liệu mẫu bằng vòng lặp for (khoảng 100000 dòng).
  + Viết câu select đơn giản trên 1 cột (c1) chưa index và đề ý đến thời gian thực hiện T1.
  + Chọn các cột trên các quan hệ để index.
  + Cài đặt các index trên SQL Server.
  + Viết câu select đơn giản trên 1 cột (c1) đã index và so sánh thời gian thực hiện T2 với T1.

---

## Phụ lục: Chuẩn hóa CSDL

### Giới thiệu
- Thiết kế cơ sở dữ liệu là 1 phần cực kì quan trọng, nếu thiết kế cẩn thận thì sau này sẽ tiết kiệm được rất nhiều thời gian trong quá trình phát triển. Và để tối ưu cơ sở dữ liệu thì nên tuân theo các chuẩn thiết kế.
- Có 4 loại dạng chuẩn như sau:
  + First Normal Form (1NF): dạng chuẩn 1NF
  + Second Normal Form (2NF): dạng chuẩn 2NF
  + Third Nomal Form (3NF): dạng chuẩn 3NF
  + Boyce-Codd Normal Form (BCNF): dạng chuẩn Boyce-Codd

### Dạng chuẩn 1 (1NF)
- **Điều kiện:** Lược đồ quan hệ R ở dạng chuẩn 1 (1NF - First Normal Form) nếu mọi thuộc tính của R đều chứa các giá trị nguyên tố (atomic value), giá trị này không là một danh sách các giá trị hoặc giá trị phức hợp (composite value).
- **Ví dụ:** Các thuộc tính chưa là giá trị nguyên tố: `TENMON -> CSDLAnh` có thể phân rã ra thành: `CSDL` và `Anh`.

| MASV | HOTEN | DIACHI | MAMON | TENMON | DIEM |
|---|---|---|---|---|---|
| A01 | Lê Na | 12 Thái Hà | M01M02 | CSDLAnh | 89 |
| A02 | Trần An | 56 Mã Mây | M01 | CSDL | 8 |
| A03 | Hà Nam | 24 Cầu Gỗ | M01M02M03 | CSDLAnhToán 1 | 689 |

### Dạng chuẩn 2 (2NF)
- **Điều kiện:** Lược đồ quan hệ R ở dạng chuẩn 2 (2NF - Second Normal Form) đối với tập phụ thuộc hàm F nếu R ở dạng chuẩn 1 và mọi thuộc tính không khóa đều phụ thuộc hàm đầy đủ vào mọi khóa của R.

**Phụ thuộc hàm**
- Cho một lược đồ quan hệ R(U), r là một quan hệ bất kỳ trên lược đồ quan hệ R, X và Y là hai tập thuộc tính con của U. Phụ thuộc hàm (FD - Functional Dependency) X->Y trên lược đồ quan hệ R, được đọc là "X xác định hàm Y" hoặc "y phụ thuộc hàm vào X", nếu: 
  `∀t1,t2 ∈ r(R): t1[X] = t2[X] => t1[Y] = t2[Y]`
- Tức là mỗi giá trị của X trong r chỉ tương ứng với một giá trị của Y.

### Dạng chuẩn 3 (3NF)
- **Điều kiện:**
  + Phải đạt chuẩn 2NF.
  + Mọi thuộc tính không khóa phụ thuộc bắc cầu vào thuộc tính khóa (nghĩa là tất cả các thuộc tính không khóa phải được suy ra trực tiếp từ thuộc tính khóa).

### Dạng chuẩn 4 (Boyce-Codd-Kent - BCNF)
- **Điều kiện:**
  + Phải đạt chuẩn 3NF.
  + Không có thuộc tính khóa nào phụ thuộc vào thuộc tính không khóa.

---

## Tài liệu tham khảo
1. Nguyễn Gia Tuấn Anh, Trương Châu Long, *Bài tập và bài giải SQL Server*, NXB Thanh niên (2005).
2. Đỗ Phúc, Nguyễn Đăng Tỵ, *Cơ sở dữ liệu*, NXB Đại học quốc gia TPHCM (2010).
3. Nguyễn Gia Tuấn Anh, Mai Văn Cường, Bùi Danh Hường, *Cơ sở dữ liệu nâng cao*, NXB Đại học quốc gia TPHCM (2019).
4. Itzik Ben-Gan, *Microsoft SQL Server 2012 - TSQL Fundamentals*.
5. E. Codd, *A relational model of data for large shared data banks*, Communications of the ACM (1970).

