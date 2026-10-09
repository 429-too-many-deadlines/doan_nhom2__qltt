# Chương 4: Trình bày thông tin

**Khoa Khoa học và kỹ thuật thông tin**
**Bộ môn Thiết bị di động và Công nghệ Web**
**Trường Đại học Công nghệ Thông tin, Đại học Quốc gia TP.HCM**

## Nội dung
1. Menu
2. Form
3. Report

---

## 1. Menu
Menu là một bảng ghi lại tất cả các thao tác mà người dùng có thể thực thi. 
Đây là bộ phận giúp điều hướng cho người dùng thực hiện các chức năng đối với hệ thống. 
Tổ chức tốt menu sẽ giúp cho thông tin được tổ chức tốt hơn trên hệ thống, khiến cho người dùng không bị rối.

### Ví dụ menu
* **Menu cha:** chứa các chức năng chính.
* **Menu con:** chứa các chức năng phụ trợ, nằm trong menu cha.

### Các dạng menu
* Menu ngang.
* Menu dọc.
* Menu thả.
* Menu phụ.

#### Menu ngang
Rất phổ biến nhưng có vẻ đã lỗi thời vì chiếm quá nhiều diện tích. Nhược điểm của nó là chiều ngang bị hạn chế bởi kích thước web. Do đó, việc lựa chọn danh mục cũng bị hạn chế theo. Số từ để đặt tên danh mục cũng sẽ bị hạn chế chỉ khoảng 2-3 từ.

#### Menu dọc
Nó được sử dụng phổ biến hơn menu ngang trong thiết kế website. Ưu điểm của nó là không bị hạn chế về diện tích, không gian sử dụng. Hơn thế hàng dọc có sức chứa rất nhiều danh mục, tha hồ sử dụng từ ngữ cho các danh mục đó. Tên danh mục bạn có thể lựa chọn thoải mái 3 – 4 từ.

#### Menu thả
Nó thường sử dụng đi kèm với cách thiết kế navigation ngang hoặc dọc. Menu này cho phép người dùng sử dụng linh hoạt tất cả các danh mục. Rất thích hợp với những web có nhiều nội dung như trang báo mạng.

#### Menu phụ
Nó bổ sung thêm thông tin cho danh mục chính. Nó thường được đặt ngay dưới danh mục chính. Vai trò của nó là rất quan trọng giúp hiển thị chi tiết hơn menu chính.

### Các ví dụ về Menu
* Top Navigation Menu
* Footer Menu (Ví dụ: Liên kết nhanh, Liên hệ, Địa chỉ, Điện thoại, Email...)
* Sidebar Menu (Ví dụ: YouTube Sidebar)
* Hamburger Menu (Ví dụ: Menu của ứng dụng Google Drive trên mobile)
* Mega Menu (Ví dụ: CellphoneS)

### Nguyên tắc thiết kế Menu hiệu quả
* Tên menu ngắn gọn, dễ hiểu, dễ đoán.
* Các menu cần tuân theo cùng một kiểu trình bày.
* Các mục liên quan nên được gom nhóm (ví dụ: “Tài khoản” gồm đăng nhập, đăng ký, đổi mật khẩu).
* Ưu tiên các chức năng sử dụng thường xuyên ở trên cùng.
* Khi người dùng rê chuột hoặc click, cần có hiệu ứng phản hồi (hover, highlight).

### Nguyên tắc của Jakob Nielsen (10 Usability Heuristics)
* **Visibility of system status:** Người dùng phải biết mình đang ở đâu trong menu.
  * *Ví dụ Đúng:* Highlight vị trí hiện tại. Trang hiện tại "Sản phẩm" được đánh dấu rõ ràng.
  * *Ví dụ Sai:* Không có dấu hiệu chỉ mục nào đang được xem.
* **Recognition rather than recall:** Người dùng nhận diện dễ dàng, không cần nhớ quá nhiều.
  * *Ví dụ Đúng:* Có biểu tượng và chữ. Người dùng dễ nhận diện các chức năng qua biểu tượng + nhãn.
  * *Ví dụ Sai:* Chỉ có biểu tượng. Người dùng phải đoán từng biểu tượng đại diện cho chức năng nào.
* **Consistency and standards:** Menu nên đồng bộ trong toàn hệ thống.
  * *Ví dụ Đúng:* Menu đồng bộ giữa Trang chủ website trường đại học và Trang con: Giới thiệu. Cùng một kiểu menu được sử dụng xuyên suốt website, đảm bảo tính đồng bộ.
  * *Ví dụ Sai:* Menu không đồng bộ giữa các trang (Home, About, Academic, Research...).

### Lý thuyết về hành vi người dùng (User Behavior)
* **Fitts's Law:** Thời gian để di chuyển đến một mục tiêu (menu) phụ thuộc vào khoảng cách và kích thước của mục tiêu đó.
* **Hick’s Law:** Thời gian để đưa ra quyết định tăng theo số lượng lựa chọn.
* **Miller’s Law:** Con người chỉ có thể nhớ khoảng 7±2 đơn vị thông tin trong ngắn hạn.

### Phân cấp thông tin trong Menu
* Menu là một dạng biểu diễn kiến trúc thông tin, theo dạng cây phân cấp.
* Thiết kế tốt giúp người dùng đi từ tổng quát đến chi tiết một cách tự nhiên.
* Các cấp phân loại trong Menu:
  * Cấp 1: Menu chính (ví dụ: Trang chủ, Giới thiệu, Sản phẩm)
  * Cấp 2: Submenu (ví dụ: Sản phẩm → Laptop, Điện thoại)
  * Cấp 3: Chi tiết (ví dụ: Điện thoại → iPhone, Samsung)

### Thiết kế Menu
* **Định vị rõ ràng:** Dễ biết người dùng đang ở đâu trong hệ thống.
* **Tính tương thích:** Thiết kế phù hợp trên desktop, tablet, mobile (responsive menu).
* **Tính thân thiện:** Giao diện menu đơn giản, trực quan cho người mới tiếp cận.
* **Khả năng tìm kiếm:** Có ô tìm kiếm giúp truy cập nhanh mục menu mong muốn.
* **Biểu tượng:** Sử dụng icon kèm chữ giúp dễ nhận biết (ví dụ: icon Giỏ hàng).

### Các lỗi phổ biến khi thiết kế Menu
* Menu quá dài, rối mắt.
* Menu không phản hồi khi click.
* Không hỗ trợ thiết bị di động.
* Không có dấu hiệu chỉ vị trí hiện tại.
* Menu không đồng nhất trong toàn hệ thống.

### Các công cụ, thư viện hỗ trợ thiết kế Menu
* HTML / CSS: Tạo cấu trúc và định dạng giao diện
* JavaScript / jQuery: Xử lý sự kiện, tạo hiệu ứng động
* React / Angular / Vue: Xây dựng menu động theo SPA
* Bootstrap / Tailwind: Thư viện hỗ trợ menu responsive
* CMS (WordPress, Joomla...): Tạo menu không cần code
* ...

### Bài tập thiết kế Menu
* Bài 1: Thiết kế menu ngang cho website thương mại điện tử
* Bài 2: Thiết kế menu dọc cho phần mềm quản lý sinh viên

---

## 2. Form
Form (hay biểu mẫu) là công cụ được thiết kế để người dùng nhập (Xem/Xóa/Sửa) vào các thông tin trên hệ thống.
Một biểu mẫu sẽ quy định các ràng buộc về các trường thông tin mà một người dùng có thể nhập vào. 

**Các công dụng của Form:**
* Hỗ trợ người dùng nhập thông tin.
* Kiểm tra thông tin người dùng nhập vào trước khi gửi lên hệ thống.

*Ví dụ: Tờ khai y tế (https://tokhaiyte.vn/)*

### Các thành phần cơ bản của Form
* **Textbox:** giúp người dùng nhập vào dạng text.
* **Combo box:** Cho người dùng chọn một tuỳ chọn trong danh sách.
* **Radio button:** Cho người dùng chọn 1 trong nhiều tuỳ chọn. Người dùng bắt buộc phải chọn 1.
* **Checkbox:** Cho người dùng chọn 1 trong nhiều tuỳ chọn. Người dùng có thể chọn tất cả hoặc không chọn gì.
* **Label:** Nhãn, hiển thị văn bản ra cho người dùng. Không thể chỉnh sửa label.
* **Date picker:** giúp người dùng nhập vào kiểu ngày tháng trực quan.
* **Button:** Giúp người dùng thao tác ra lệnh cho hệ thống. Thường sẽ là submit button.

Ngoài các thành phần cơ bản trên, Form có thể có các Component nâng cao khác nhằm nâng cao trải nghiệm người dùng.

### Phân loại Form
* **Form đăng nhập / đăng ký:**
  * Người dùng nhập tên tài khoản và mật khẩu.
  * Ví dụ: Form đăng nhập Facebook, Gmail.
* **Form nhập dữ liệu:**
  * Thu thập thông tin từ người dùng.
  * Ví dụ: Form đặt hàng, đăng ký sự kiện.
* **Form tìm kiếm:**
  * Dùng để tìm kiếm thông tin.
  * Ví dụ: Form tìm kiếm sản phẩm trên Shopee.
* **Form liên hệ:**
  * Người dùng nhập thông tin để gửi yêu cầu.
  * Ví dụ: Form gửi phản hồi khách hàng.

### Các ứng dụng sử dụng Form thường gặp
* Đăng ký tài khoản mới (VD: Facebook, Google, ...).
* Khai báo lý lịch sinh viên trên hệ thống daa.
* Khai báo y tế toàn dân.
* Đăng ký chương trình khuyến mãi.
* Google Form (Google biểu mẫu).
* ....

### Nguyên tắc thiết kế giao diện tốt cho Form
* Đơn giản, dễ hiểu: Chỉ hiển thị những trường cần thiết.
* Nhóm thông tin hợp lý: Các trường liên quan nên được sắp xếp gần nhau.
* Sử dụng nhãn (labels) rõ ràng: Nhãn nên ngắn gọn và dễ hiểu.
* Phản hồi nhanh (Feedback): Hiển thị lỗi ngay khi nhập sai.
* Tính nhất quán: Các form trong cùng một hệ thống cần có bố cục thống nhất.

### Nguyên tắc thiết kế Form nâng cao trải nghiệm người dùng
* Sử dụng Placeholder hợp lý: Gợi ý nhưng không thay thế nhãn.
* Tự động điền (Autocomplete): Giúp giảm thao tác cho người dùng.
* Xác thực dữ liệu tức thời (Inline validation): Cảnh báo lỗi ngay khi nhập.
* Sử dụng CTA (Call to Action) rõ ràng: Các nút bấm như "Gửi", "Lưu", "Hủy" cần nổi bật.

### Các kỹ thuật xác thực dữ liệu (Form Validation)
* **Xác thực phía máy khách (Client-Side Validation):** Kiểm tra dữ liệu ngay khi nhập, sử dụng JavaScript hoặc HTML5.
* **Xác thực phía máy chủ (Server-Side Validation):** Kiểm tra dữ liệu khi gửi lên server để đảm bảo an toàn.
* **Xác thực theo kiểu dữ liệu (Type Validation):** Kiểm tra xem giá trị nhập vào có đúng định dạng không (số, ngày tháng, email…).
* **Xác thực theo quy tắc nghiệp vụ (Business Logic Validation):** Kiểm tra theo logic hệ thống (ví dụ: mật khẩu phải có ít nhất 8 ký tự, chứa số và chữ hoa, ký tự đặc biệt).

### Xử lý sự kiện (Event Handling)
Khi người dùng nhập dữ liệu vào Form, các sự kiện xảy ra có thể được xử lý bằng ngôn ngữ lập trình như JavaScript, React, Angular….
Các sự kiện phổ biến trong Form:
* `onChange`: Khi giá trị của ô nhập liệu thay đổi.
* `onSubmit`: Khi nhấn nút gửi Form.
* `onBlur`: Khi ô nhập liệu mất focus.
* `onFocus`: Khi người dùng click vào ô nhập liệu.

### Bảo mật dữ liệu trong Form
* **SQL Injection:** Hacker nhập mã độc vào ô nhập liệu để lấy dữ liệu từ database.
* **Cross-Site Scripting (XSS):** Hacker chèn mã JavaScript vào Form để đánh cắp thông tin.
* **Cross-Site Request Forgery (CSRF):** Tấn công giả mạo yêu cầu của người dùng hợp lệ.

**Cách bảo vệ:**
* Sanitize dữ liệu nhập vào: Lọc bỏ các ký tự nguy hiểm.
* Sử dụng Prepared Statements cho SQL: Ngăn chặn SQL Injection.
* Escape output, lọc HTML.
* Thêm Token CSRF vào Form: Đảm bảo chỉ yêu cầu hợp lệ mới được thực hiện.
* Sử dụng HTTPS: Mã hóa dữ liệu truyền tải giữa client và server.

### Quy trình xử lý dữ liệu từ Form đến Database
1. Người dùng nhập dữ liệu vào Form.
2. Hệ thống kiểm tra dữ liệu (Validation).
3. Gửi dữ liệu lên Backend Server (Node.js, PHP, Python...).
4. Lưu dữ liệu vào Database (MySQL, MongoDB, Firebase...).

### Các công cụ, thư viện hỗ trợ thiết kế form
* Windows Form
* Electron
* HTML/CSS
* Boostrap
* React
* Angular JS
* Vue JS
* ...

### Bài tập thiết kế Form
* Bài 1: Thiết kế Form dùng để nhập một hóa đơn mới vào hệ thống (Khi khách đến mua hàng)
* Bài 2: Thiết kế Form dùng để phản hồi về thức ăn của 1 nhà hàng

---

## 3. Report
Report (báo cáo) là công cụ dùng để hiển thị thông tin cho người dùng, giúp người dùng hiểu về thông tin đang có trong hệ thống.
Report có thể ở dạng văn bản, hoặc dạng đồ hoạ trực quan.
Người dùng không thể chỉnh sửa các chi tiết của 1 report.

Ví dụ:
* Báo cáo điểm trung bình một lớp.
* Báo cáo thu / chi hằng tháng của 1 đơn vị.

### Nguyên tắc thiết kế Report
* Dễ đọc, dễ hiểu: Chỉ hiển thị thông tin quan trọng, tránh rườm rà.
* Tính trực quan cao: Sử dụng bảng, biểu đồ, đồ thị thay vì chỉ có chữ.
* Cấu trúc hợp lý: Báo cáo nên có tiêu đề, mục lục, nội dung chính, tóm tắt.

### Quy trình tạo báo cáo từ dữ liệu
1. **Thu thập dữ liệu:** Lấy thông tin từ cơ sở dữ liệu (SQL, MongoDB, Firebase).
2. **Xử lý dữ liệu:** Tính toán, tổng hợp, làm sạch dữ liệu trước khi hiển thị.
3. **Trực quan hóa dữ liệu:** Chuyển đổi dữ liệu thành bảng, biểu đồ, đồ thị.
4. **Hiển thị báo cáo:** Xuất ra giao diện người dùng hoặc file PDF, Excel.

### Các công cụ xử lý dữ liệu phổ biến
* SQL Query: Lấy dữ liệu từ database.
* Excel / Google Sheets: Xuất báo cáo thủ công.
* Power BI / Tableau: Công cụ BI hỗ trợ trực quan hóa.
* Crystal Reports: Tạo báo cáo trong phần mềm doanh nghiệp.
* JasperReports: Hệ thống báo cáo mã nguồn mở cho Java.

#### Ví dụ query SQL tạo báo cáo doanh thu theo tháng
```sql
SELECT MONTH(NgayHD) AS month, SUM(tongtien) AS doanhthu
FROM HoaDon
GROUP BY MONTH(NgayHD)
```

### Trực quan hóa báo cáo
**Lý do cần trực quan hóa báo cáo:**
* Giúp người dùng dễ hiểu dữ liệu hơn so với bảng số liệu đơn thuần.
* Phát hiện xu hướng, bất thường trong dữ liệu nhanh hơn.
* Hỗ trợ ra quyết định dựa trên biểu đồ.

#### Các loại biểu đồ phổ biến trong báo cáo
| Loại biểu đồ | Mô tả | Ví dụ |
|---|---|---|
| Biểu đồ cột (Bar Chart) | So sánh số liệu giữa các nhóm | Doanh thu theo tháng |
| Biểu đồ đường (Line Chart) | Hiển thị xu hướng theo thời gian | Biểu đồ tăng trưởng khách hàng theo năm |
| Biểu đồ tròn (Pie Chart) | Phân bổ phần trăm giữa các danh mục | Phân bổ ngân sách công ty |
| Biểu đồ nhiệt (Heatmap) | Hiển thị mức độ tập trung dữ liệu | Lưu lượng truy cập website theo giờ |
| Biểu đồ hộp (Box Plot) | Hiển thị phân bố dữ liệu và ngoại lệ | Phân tích độ lệch điểm số sinh viên |

#### Các định dạng xuất báo cáo
* PDF: Xuất báo cáo cố định, không chỉnh sửa được, chỉ để xem.
* Excel (XLSX, CSV): Báo cáo có thể chỉnh sửa, dùng để phân tích dữ liệu.
* HTML: Hiển thị trên website.
* JSON/XML: Định dạng dùng để trao đổi dữ liệu giữa hệ thống.

### Crystal Report
* Crystal Report là công cụ thiết kế báo cáo cho phép tạo ra những báo cáo (từ đơn giản đến phức tạp) bằng cách tìm và định dạng dữ liệu từ một hay nhiều nguồn dữ liệu khác nhau.
* Hỗ trợ các chức năng in ấn, kết xuất sang các định dạnh khác: PDF, Excel, Word…
* Crystal Report được tích hợp sẵn trong bộ Visual Studio Team System và Professional (không có trong phiên bản VS Express).
* Ngoài ra, có thể download Crystal Report và sử dụng công cụ này như một phần mềm chuyên dùng để thiết kế báo cáo.
* Tham khảo: https://www.crystalreports.com/

### Cấu trúc Report
1. **Report Header:** chứa các dòng chữ hay hình ảnh xuất hiện ở đầu của mỗi report như: tên report, logo, …
2. **Page Header:** chứa các thông tin hiện diện ở đầu mỗi trang, ví dụ như tên danh mục cần hiển thị từ cơ sở dữ liệu.
3. **Details:** chứa phần dữ liệu của Report.
   * Liên kết với các fields trong CSDL để hiển thị các dòng (data rows), các rows này có thể gom nhóm theo một số tiêu chí nào đó (column gom nhóm), khi đó sẽ xuất hiện phần Group By nằm trong Section “Details”.
   * Trong phần Section “Details”, Group by cũng có Group Header và Group Footer.
   * Ta có thể thêm Field tính toán cho cuối mỗi Group này bằng cách click chuột từ thanh công cụ của Crystal Report để Insert một Summary.
4. **Page Footer:** chứa các thông tin nằm ở cuối mỗi trang như số trang…
5. **Report Footer:** chứa các thông tin xuất hiện ở cuối mỗi report: tổng kết, số lượng mẫu tin trong báo cáo, địa chỉ, người ký, chức vụ, ngày ký, .…..

### Xây dựng 1 report
* **Bước 1:** Thiết kế Report.
  * Xác định các thông tin cần hiển thị, cách bố trí, tổ chức thông tin.
  * Thiết kế theo mẫu sẳn có hoặc theo đề nghị của người dùng.
  * Yêu cầu:
    * Đáp ứng mục tiêu nghiệp vụ, phù hợp với yêu cầu thực tế của người dùng.
    * Dữ liệu hiển thị vừa đủ, có sắp xếp, gom nhóm hợp lý.
* **Bước 2:** Chuẩn bị nguồn dữ liệu.
  * Tạo cơ sở dữ liệu, các câu truy vấn, các hàm … để hỗ trợ hiển thị dữ liệu theo yêu cầu của Report.
  * Có thể dùng crystal report hiển thị kết quả thực thi của một stored procedure.
    * Stored procedure phải thực thi một câu lệnh SELECT.
    * Các field trả về của câu select này được xem là các database field.
* **Bước 3:** Sử dụng công cụ để xây dựng Report theo thiết kế.
* **Bước 4:** Tích hợp Report vào ứng dụng.

### Phân loại Report
* **Không có tham số:** là những report đơn giản, các yêu cầu hiển thị dữ liệu không thay đổi.
* **Có tham số:** các yêu cầu hiển thị dữ liệu có thay đổi và giá trị của tham số phải do người dùng ấn định khi thực thi.

### Các đối tượng dữ liệu
1. **Database fields:**
   * Trường thuộc dạng csdl (có thể là Table, Stored Procedure, SQL command).
   * Thường được hiển thị trong phần Details của Report.
2. **Formula fields:**
   * Dùng để thiết lập các công thức.
   * Tạo mới đối tượng này bằng cách dùng Formula Editor hoặc Formula Expert.
3. **SQL Expression Fields:**
   * Dữ liệu được tính toán từ những trường khác (dùng hàm count, sum, … hay công thức tính toán bất kỳ).
   * Được đưa về xử lý ở database và trả kết quả về report qua SQL Expression field.
4. **Group Name Fields:** chứa các thuộc tính dùng để gom nhóm dữ liệu trong report.
5. **Parameters Fields:**
   * Là trường tham số.
   * Do ta tự khai báo hoặc Crystal Report tự động thêm vào khi ta đưa 1 stored procedure có tham số vào trong database field.
   * Khi thực thi report trong Crystal Report, những trường tham số sẽ được hỏi giá trị, ta cần nhập vào để hiển thị tạm thời.
6. **Running Total Fields:** chứa giá trị tổng hợp (aggregate) như max, min, sum, count, …
7. **Special Fields:** là trường đặc biệt, có sẵn của Crystal Report như số trang, ngày hiện tại, …

### Bài tập thiết kế Report
* Bài 1: Thiết kế Report trả về Điểm trung bình theo học kỳ của các sinh viên trong 1 lớp.
* Bài 2: Thiết kế Report trả về Tốc độ tăng trưởng doanh số hàng năm của công ty.

---

## Tổng kết
* **Menu:**
  * Tổ chức các thông tin trên một hệ thống.
  * Có nhiệm vụ hướng dẫn và điều hướng người dùng.
* **Form:**
  * Cho phép người dùng nhập thông tin vào hệ thống.
  * Có nhiệm vụ hỗ trợ người dùng nhập thông tin và kiểm tra thông tin vừa nhập trước khi gửi.
* **Report:**
  * Hiển thị thông tin từ hệ thống ra cho người dùng.
  * Có nhiệm vụ tổng hợp thông tin và hiển thị thông tin ra cho người dùng. Không cho phép sửa thông tin.

---

## TÀI LIỆU THAM KHẢO
1. Nguyễn Gia Tuấn Anh, Trương Châu Long, *Bài tập và bài giải SQL Server*, NXB Thanh niên (2005).
2. Đỗ Phúc, Nguyễn Đăng Tỵ, *Cơ sở dữ liệu*, NXB Đại học quốc gia TPHCM (2010).
3. Nguyễn Gia Tuấn Anh, Mai Văn Cường, Bùi Danh Hường, *Cơ sở dữ liệu nâng cao*, NXB Đại học quốc gia TPHCM (2019).
4. Itzik Ben-Gan, *Microsoft SQL Server 2012- TSQL Fundamentals*.

---

## BÀI TẬP CHUNG
* **BÀI 1:** Thiết kế Form cho sinh viên khai báo lý lịch sinh viên.
* **BÀI 2:** Thiết kế Report trả về Điểm trung bình của sinh viên trong 1 lớp.

**Yêu cầu:**
* Mô tả rõ có bao nhiêu thuộc tính cần hiển thị.
* Thiết kế report bao gồm đầy đủ các thành phần.
* Viết truy vấn lấy dữ liệu cho report.

