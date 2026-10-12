# Văn trình bày – Xây dựng hệ thống quản lý thư viện (Nhóm 2)

Tổng thời lượng khoảng 10 phút (khoảng 1.330 từ, đọc 140 từ/phút là 9,5 phút, cộng thời gian chuyển slide). Đọc chậm, rõ; dòng *[in nghiêng trong ngoặc vuông]* là thao tác, không đọc.

---

## Slide 1 – Bìa (15 giây)

Em xin chào thầy Nguyễn Thành Luân và các bạn. Em đại diện Nhóm 2 trình bày đồ án môn Quản lý thông tin với đề tài: **Xây dựng hệ thống quản lý thư viện**.

## Slide 2 – Mục lục (20 giây)

Bài trình bày gồm năm phần: mô tả bài toán, phân tích và thiết kế, cài đặt, quản lý thông tin – gồm xử lý, an toàn và trình bày thông tin – và cuối cùng là tổng kết cùng kịch bản demo trên SQL Server.

## Slide 3 – Bài toán, mục tiêu và đối tượng sử dụng (55 giây)

Khi quản lý thư viện thủ công, thủ thư không biết một cuốn sách đang trên kệ, đang được mượn hay đã hư, mất. Tiền phạt tính tay nên dễ sai, độc giả còn nợ vẫn mượn tiếp được, và dữ liệu nằm rải rác, không phân quyền, không sao lưu.

Vì vậy hệ thống đặt ra các mục tiêu: theo dõi đến từng cuốn sách, kiểm tra điều kiện mượn ngay trong cơ sở dữ liệu, tự lập phiếu phạt và cộng dồn công nợ, phân quyền và sao lưu dữ liệu.

*[chỉ vào cột phải]* Hệ thống có ba đối tượng: quản lý thư viện có toàn quyền; thủ thư lập thẻ, cho mượn, nhận trả nhưng không được xóa dữ liệu; còn độc giả chỉ tra cứu sách.

## Slide 4 – Quy trình nghiệp vụ (45 giây)

*[chỉ theo lưu đồ]* Đây là quy trình chính. Khi độc giả đưa thẻ và sách, hệ thống kiểm tra thẻ còn hạn và không nợ, rồi kiểm tra từng cuốn có sẵn hay không. Nếu một điều kiện không đạt thì từ chối. Nếu đạt thì lập phiếu mượn với hạn trả 14 ngày.

Khi trả sách, nếu trễ hạn, hư hoặc mất, hệ thống tự lập phiếu phạt: trễ 5.000 đồng mỗi ngày, hư phạt 50% giá sách, mất phạt 100% giá sách. Độc giả thanh toán xong thì công nợ trở về 0. Ngoài ra, khi lập thẻ, độc giả phải đủ 16 tuổi và thẻ có hạn 2 năm.

## Slide 5 – Các chức năng của hệ thống (30 giây)

Từ quy trình đó, nhóm xác định tám nhóm chức năng: xác thực, quản lý danh mục, quản lý kho sách, quản lý độc giả, mượn – trả, nhắc nhở và xếp loại độc giả, báo cáo, và quản trị cơ sở dữ liệu. Mọi chức năng đều được xử lý trực tiếp bằng stored procedure, function hoặc view trong cơ sở dữ liệu.

## Slide 6 – Thực thể và sơ đồ ERD (45 giây)

*[chỉ vào sơ đồ]* Cơ sở dữ liệu gồm 11 thực thể. Điểm quan trọng là nhóm tách **đầu sách** và **cuốn sách**: đầu sách là tựa sách, còn cuốn sách là từng bản vật lý trên kệ, nhờ vậy theo dõi được tình trạng của từng cuốn.

Có hai quan hệ nhiều – nhiều: đầu sách với tác giả qua bảng DAUSACH_TACGIA, và phiếu mượn với cuốn sách qua bảng chi tiết phiếu mượn. Mỗi dòng chi tiết có thể phát sinh nhiều phiếu phạt, ví dụ vừa trả trễ vừa làm hư sách. Bảng tài khoản đứng độc lập, chỉ dùng để đăng nhập.

## Slide 7 – 17 ràng buộc toàn vẹn (40 giây)

Nhóm xác định 17 ràng buộc toàn vẹn. Ràng buộc 1 đến 12 chỉ liên quan một bảng, nên cài đặt bằng CHECK và UNIQUE ngay trong lệnh tạo bảng, ví dụ giá sách lớn hơn 0, số cuốn còn không vượt quá tổng số cuốn, độc giả đủ 16 tuổi.

*[chỉ vào bảng bên phải]* Năm ràng buộc còn lại liên quan nhiều bảng hoặc thuộc tính dẫn xuất, như chỉ cho mượn khi thẻ còn hạn và không nợ, hay tổng nợ bằng tổng tiền phạt chưa thanh toán. Các ràng buộc này phải dùng trigger.

## Slide 8 – Mô hình logic và tân từ (25 giây)

Từ ERD, nhóm chuyển sang mô hình logic gồm 11 lược đồ quan hệ; khóa chính gạch chân, khóa ngoại in nghiêng, và mỗi lược đồ có tân từ giải thích ý nghĩa. Lưu ý hai thuộc tính: TONGNO của độc giả là tiền phạt chưa thanh toán, và mật khẩu trong bảng tài khoản được lưu dạng băm SHA2-256.

## Slide 9 – Cài đặt (35 giây)

Cơ sở dữ liệu cài trên SQL Server 2022 chạy bằng Docker, collation tiếng Việt. Các script chạy theo thứ tự từ tạo bảng, dữ liệu mẫu, function, trigger, đến stored procedure, cursor, an toàn thông tin và report.

Dữ liệu mẫu có 118 độc giả và 26 cuốn sách, được chọn để bao quát tình huống: độc giả thẻ hết hạn, độc giả đang nợ, cuốn sách hư, cuốn bị mất, phiếu trả một phần, phiếu quá hạn.

## Slide 10 – Stored Procedure (40 giây)

Hệ thống có tổng cộng 38 stored procedure, trong đó có 5 thủ tục nghiệp vụ chính: thêm độc giả, lập phiếu mượn, trả sách, thanh toán phạt và thống kê tháng.

*[chỉ vào khung code]* Ví dụ thủ tục lập phiếu mượn nhận một danh sách mã cuốn sách. Toàn bộ chạy trong một transaction: nếu một cuốn không hợp lệ thì hủy cả phiếu. Khi chạy thử với hai cuốn của “Mắt biếc”, hệ thống tạo phiếu PM0329 và số cuốn còn lại của đầu sách này giảm về 0.

## Slide 11 – Trigger (45 giây)

Năm trigger cài đặt năm ràng buộc liên bảng. Đáng chú ý nhất là chuỗi kích hoạt khi trả sách: thủ tục trả sách cập nhật chi tiết phiếu mượn, trigger trả sách tự lập phiếu phạt, rồi trigger phiếu phạt cập nhật tổng nợ của độc giả.

*[chỉ vào các ô số]* Ví dụ trả cuốn CS003 bị hư và trễ 7 ngày: hệ thống tự lập hai phiếu phạt, 55.000 đồng do hư và 35.000 đồng do trễ, tổng nợ của độc giả là 90.000 đồng. Còn khi lập phiếu cho độc giả thẻ hết hạn hoặc đang nợ, trigger từ chối ngay.

## Slide 12 – Function và Cursor (40 giây)

Nhóm viết ba function. Hàm tính tiền phạt trễ được dùng lại trong cả trigger và cursor, nên cách tính phạt chỉ nằm ở một chỗ. Hàm lịch sử mượn trả về bảng các lần mượn của một độc giả.

Hai cursor duyệt từng dòng dữ liệu: cursor thứ nhất xếp loại 119 độc giả theo số lần trễ, hư, mất và tiền nợ; cursor thứ hai lập danh sách nhắc nhở sách quá hạn. Ngày 11/10 cursor tạo 4 nhắc nhở, và chạy lại cùng ngày thì không tạo trùng.

## Slide 13 – An toàn thông tin (40 giây)

Về an toàn thông tin, nhóm làm bốn phần. Thứ nhất, xác thực hai lớp: login của SQL Server và tài khoản ứng dụng có mật khẩu băm. Thứ hai, phân quyền bằng ba role quản lý, thủ thư và độc giả với GRANT và DENY; ví dụ thủ thư xóa phiếu phạt sẽ bị từ chối.

Thứ ba, import dữ liệu bằng BULK INSERT và export bằng bcp. Thứ tư, sao lưu FULL và DIFFERENTIAL, khi phục hồi thì restore bản FULL trước rồi đến bản DIFF.

## Slide 14 – Trình bày thông tin: 5 report (35 giây)

Nhóm xây dựng 5 report, mỗi report lấy dữ liệu từ một view nên luôn là số liệu mới nhất. *[chỉ lần lượt]* Report tình trạng kho cho thấy 13 trên 26 cuốn đang có sẵn. Report sách mượn nhiều: “Mắt biếc” dẫn đầu với 5 lượt. Lượt mượn tăng mạnh vào tháng 9, đầu năm học. Tổng tiền phạt là 498.000 đồng, trong đó mất sách chiếm khoảng một nửa. Report cuối liệt kê độc giả giữ sách quá hạn, cũng là đầu vào cho cursor nhắc nhở.

## Slide 15 – Tổng kết (30 giây)

Tóm lại, nhóm đã hoàn thành cơ sở dữ liệu 11 bảng với 17 ràng buộc toàn vẹn, 38 stored procedure, 5 trigger, 3 function, 2 cursor và 5 report. Các nghiệp vụ quan trọng như kiểm tra điều kiện mượn, tính phạt và cập nhật công nợ đều được xử lý tự động ngay trong cơ sở dữ liệu, kèm phân quyền và sao lưu.

## Slide 16 – Kịch bản demo trên SQL Server (30 giây)

Phần demo đi theo năm bước. Một, lập phiếu mượn hai cuốn sách. Hai, thử lập phiếu cho độc giả thẻ hết hạn và độc giả đang nợ, cả hai bị từ chối. Ba, trả một cuốn sách hư và trễ hạn để thấy phiếu phạt và tổng nợ tự cập nhật. Bốn, chạy cursor nhắc nhở sách quá hạn. Và năm, xem 5 report từ các view.

## Slide 17 – Cảm ơn (15 giây)

Phần trình bày của Nhóm 2 đến đây là kết thúc. Em cảm ơn thầy và các bạn đã lắng nghe, nhóm rất mong nhận được câu hỏi và góp ý ạ.
