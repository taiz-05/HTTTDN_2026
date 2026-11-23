# ==============================================================================
# PART 6: CHƯƠNG 4, CHƯƠNG 5, PHẦN II (CÀI ĐẶT CSDL & BACKUP/RESTORE) & PHẦN III
# ==============================================================================

function Build-Part6-Chapters4ToPart3 {
    $sb = New-Object System.Text.StringBuilder

    # ==========================================================================
    # CHƯƠNG 4: CÀI ĐẶT VÀ BẢO TRÌ HTTT, HƯỚNG DẪN SỬ DỤNG HỆ THỐNG (5 ĐIỂM)
    # ==========================================================================
    [void]$sb.Append((New-WHeading1 "CHƯƠNG 4: CÀI ĐẶT VÀ BẢO TRÌ HỆ THỐNG THÔNG TIN, HƯỚNG DẪN SỬ DỤNG HỆ THỐNG (5 ĐIỂM)"))

    [void]$sb.Append((New-WHeading2 "4.1. Phương án Cài đặt cho Hệ thống Vừa Được Thiết kế Xây dựng"))
    [void]$sb.Append((New-WHeading3 "4.1.1. Sơ đồ Kiến trúc Triển khai Hệ thống 3 Tầng (3-Tier Deployment Architecture)"))
    [void]$sb.Append((New-WP -Text "Hệ thống Thông tin Doanh nghiệp SGU Tech được triển khai theo mô hình kiến trúc 3 tầng vật lý tách biệt rõ ràng: Tầng Giao diện Trình diễn (Presentation Tier gồm admin.html, quanly.html, user.html), Tầng Xử lý Nghiệp vụ RESTful API (Application/Business Tier chạy trên ASP.NET Core 8.0 cổng 5000) và Tầng Lưu trữ Dữ liệu (Data Tier trên Microsoft SQL Server):" -IndentFirst 420))

    [void]$sb.Append((New-WImage -RelId "rIdImg9" -WidthEmu 5850000 -HeightEmu 3550000 -Caption "Hình 4.1: Sơ đồ Kiến trúc Triển khai Hệ thống 3 Tầng (Presentation – Business API – SQL Server Data Tier)" -DocPrId 109))

    [void]$sb.Append((New-WHeading3 "4.1.2. Yêu cầu Cấu hình Phần cứng, Phần mềm và Quy trình Cài đặt Chi tiết"))
    [void]$sb.Append((New-WTable -Headers @("Hạng mục Hạ tầng", "Cấu hình Tối thiểu", "Cấu hình Khuyến nghị (Production / Demo)", "Vai trò trong Hệ thống") -ColWidths @(2200, 2300, 2500, 2600) -Rows @(
        @("Vi xử lý (CPU)", "Intel Core i3 / 4 vCPU", "Intel Core i5/i7 hoặc AMD Ryzen 5 (8 vCPU)", "Xử lý đồng thời các luồng truy vấn API và thống kê CRM."),
        @("Bộ nhớ trong (RAM)", "8 GB DDR4", "16 GB DDR4/DDR5", "Đảm bảo SQL Server Buffer Pool và .NET 8 Runtime vận hành mượt mà."),
        @("Ổ cứng lưu trữ (Storage)", "10 GB SSD trống", "50 GB NVMe SSD (tách phân vùng chứa Backup)", "Lưu trữ CSDL HTTTDN_DB, nhật ký giao dịch (.ldf) và bản sao lưu (.bak)."),
        @("Hệ điều hành", "Windows 10 (64-bit)", "Windows 11 Pro / Windows Server 2022", "Môi trường thực thi Kestrel Web Server và dịch vụ SQL Server."),
        @("Nền tảng Thực thi Backend", ".NET 8.0 Runtime", ".NET 8.0 SDK (v8.0.x)", "Biên dịch và chạy dự án HTTTDN.AdminApi.csproj trên cổng 5000."),
        @("Hệ quản trị Cơ sở dữ liệu", "SQL Server Express / LocalDB", "Microsoft SQL Server 2019 / 2022 Developer", "Quản trị 9 bảng CSDL, khóa ngoại và thực thi kịch bản Backup/Restore."),
        @("Trình duyệt Web", "Chrome / Edge 110+", "Google Chrome / Microsoft Edge phiên bản mới nhất", "Hiển thị giao diện admin.html, quanly.html, user.html và biểu đồ Canvas.")
    )))

    [void]$sb.Append((New-WCodeBlock -Title "Quy trình Lệnh Cài đặt và Khởi chạy Hệ thống Thực tế (Terminal / PowerShell):" -CodeText @"
# BƯỚC 1: Khởi tạo CSDL trên SQL Server Management Studio (SSMS)
# Mở tệp d:\HTTTDN_2026\Database\HTTTDN_DB.sql và nhấn F5 (Execute)
# Hoặc để Backend tự động khởi tạo và nạp dữ liệu qua lớp DbInitializer.cs

# BƯỚC 2: Di chuyển vào thư mục Backend và khởi chạy máy chủ Web API (Port 5000)
cd d:\HTTTDN_2026\Backend\HTTTDN.AdminApi
dotnet restore
dotnet run --urls "http://localhost:5000"

# BƯỚC 3: Mở các cổng giao diện tại thư mục d:\HTTTDN_2026\Frontend_Admin\
# - Cổng Đăng nhập chung:      d:\HTTTDN_2026\Frontend_Admin\login.html
# - Phân hệ Admin Server:      d:\HTTTDN_2026\Frontend_Admin\admin.html
# - Phân hệ Người Quản lý CRM: d:\HTTTDN_2026\Frontend_Admin\quanly.html
# - Phân hệ Khách hàng:        d:\HTTTDN_2026\Frontend_Admin\user.html
"@))

    [void]$sb.Append((New-WHeading2 "4.2. Phương án Chuyển đổi từ Hệ thống Cũ sang Hệ thống Mới và Quy trình Bảo trì"))
    [void]$sb.Append((New-WP -Text "Nhằm đảm bảo quá trình chuyển giao từ hệ thống quản lý thủ công rời rạc (File Excel + Google Forms + Phần mềm cũ chưa tách quyền) sang Hệ thống Thông tin Quản trị Doanh nghiệp & CRM SGU Tech diễn ra an toàn, không làm gián đoạn hoạt động kinh doanh, doanh nghiệp áp dụng Phương án Chuyển đổi Song song kết hợp Chuyển đổi theo Giai đoạn (Parallel & Phased Conversion) trong 4 giai đoạn:" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Giai đoạn Chuyển đổi", "Thời gian", "Nội dung Công việc Chuyển đổi Cụ thể", "Tiêu chí Nghiệm thu & Phương án Dự phòng (Rollback)") -ColWidths @(1800, 1200, 3600, 3000) -Rows @(
        @("Giai đoạn 1:`nChuẩn hóa & Di trú Dữ liệu (Data Migration)", "3 ngày đầu", "Rà soát các file Excel khách hàng cũ; lọc bỏ SĐT/Email trùng lặp; chuẩn hóa trường Độ tuổi và 4 nhóm Sở thích; nạp vào bảng Roles, Accounts, CustomerProfiles, Products qua kịch bản HTTTDN_DB.sql.", "100% bản ghi hợp lệ không vi phạm khóa ngoại; lưu bản Snapshot Excel gốc để đối chiếu."),
        @("Giai đoạn 2:`nVận hành Song song (Parallel Run)", "7 ngày tiếp theo", "Vận hành đồng thời hệ thống mới (admin.html, quanly.html, user.html) song song với quy trình cũ; đào tạo kỹ sư IT sử dụng Admin Server và chuyên viên CRM sử dụng 5 tab quản lý.", "Đối soát số liệu Báo cáo Độ tuổi/Sở thích và Thống kê Khảo sát khớp 100% với thực tế."),
        @("Giai đoạn 3:`nChuyển đổi Theo Phân hệ (Phased Cut-over)", "4 ngày tiếp theo", "Đưa Phân hệ Admin Server và Phân hệ Người Quản lý CRM vào vận hành chính thức trước; tiếp đó mở Cổng Khách hàng (user.html) cho toàn bộ khách hàng thành viên truy cập.", "Thời gian phản hồi API < 100ms; 0 lỗi HTTP 500 phát sinh trong nhật ký máy chủ."),
        @("Giai đoạn 4:`nNgừng Hệ thống Cũ & Vận hành Chính thức", "Từ tuần thứ 3", "Ngừng hoàn toàn việc nhập liệu trên các file Excel rời rạc và Google Forms; kích hoạt lịch trình tự động sao lưu CSDL (Full/Diff/Log Backup) hàng ngày.", "Hệ thống vận hành ổn định 24/7; định kỳ kiểm tra khôi phục thử nghiệm hàng tháng.")
    )))

    [void]$sb.Append((New-WHeading3 "4.2.2. Quy trình Bảo trì Hệ thống và Cam kết Mức Chất lượng Dịch vụ (SLA)"))
    [void]$sb.Append((New-WTable -Headers @("Loại hình Bảo trì", "Tần suất", "Nội dung Thực hiện Bảo trì", "Thời gian Đáp ứng (SLA)") -ColWidths @(2200, 1400, 4000, 2000) -Rows @(
        @("1. Bảo trì Hiệu chỉnh (Corrective)", "Tức thời khi có sự cố", "Khắc phục ngay các lỗi phát sinh trong quá trình đăng nhập, phân quyền, gửi phản hồi hoặc nộp khảo sát.", "Phản hồi < 15 phút; Xử lý dứt điểm < 2 giờ"),
        @("2. Bảo trì Phòng ngừa (Preventive)", "Hàng ngày / Hàng tuần", "Kiểm tra dung lượng ổ cứng chứa bản Backup SQL Server, kiểm tra tính toàn vẹn CSDL (DBCC CHECKDB).", "Thực hiện tự động vào 00:00 – 02:00 sáng"),
        @("3. Bảo trì Thích nghi (Adaptive)", "Hàng quý", "Cập nhật các bản vá bảo mật của .NET 8.0, SQL Server và tương thích trình duyệt Chrome/Edge mới.", "Bảo trì định kỳ không gián đoạn (Zero Downtime)"),
        @("4. Bảo trì Hoàn thiện (Perfective)", "6 tháng / lần", "Tối ưu hóa chỉ mục (Index) trên bảng Feedbacks và SurveyResponses, bổ sung tính năng theo yêu cầu CRM.", "Triển khai theo kế hoạch nâng cấp phiên bản")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # 4.3. TÀI LIỆU HƯỚNG DẪN SỬ DỤNG CHI TIẾT THEO 3 VAI TRÒ
    # ==========================================================================
    [void]$sb.Append((New-WHeading2 "4.3. Tài liệu Hướng dẫn Sử dụng Hệ thống Chi tiết (User Manual)"))
    [void]$sb.Append((New-WP -Text "Tài liệu hướng dẫn sử dụng dưới đây được biên soạn chi tiết từng bước cho cả 3 nhóm người dùng tương ứng với 3 phân hệ của phần mềm:" -IndentFirst 420))

    [void]$sb.Append((New-WHeading3 "4.3.1. Hướng dẫn Sử dụng dành cho Quản trị viên Máy chủ (Admin Server — admin.html)"))
    [void]$sb.Append((New-WBullet "Bước 1 — Đăng nhập vào Admin Server:" "Mở tệp Frontend_Admin/login.html, nhập tài khoản 'admin' và mật khẩu '123456' (hoặc nhấn nút chọn nhanh 'Admin Server'), sau đó nhấn 'Đăng nhập vào Hệ thống'. Hệ thống tự động chuyển vào giao diện tách biệt admin.html."))
    [void]$sb.Append((New-WBullet "Bước 2 — Xem & Tìm kiếm Tài khoản:" "Tại Tab 1 (Quản lý Tài khoản & Phân quyền), quan sát 4 thẻ KPI tổng quan. Nhập từ khóa vào ô tìm kiếm hoặc chọn hộp lọc vai trò (Admin / Manager / Customer) để lọc danh sách tài khoản."))
    [void]$sb.Append((New-WBullet "Bước 3 — Thêm Tài khoản Mới:" "Nhấn nút '+ Thêm tài khoản mới' ở góc phải, nhập Tên đăng nhập, Mật khẩu, Họ tên, Email, Số điện thoại, chọn Vai trò cần cấp và nhấn 'Lưu tài khoản'."))
    [void]$sb.Append((New-WBullet "Bước 4 — Phân quyền cho Account:" "Trên dòng của bất kỳ tài khoản nào trong bảng, chọn quyền mới từ hộp chọn Dropdown (Admin / Manager / Customer) và nhấn nút màu cam 'Phân quyền'. Quyền mới được cập nhật tức thì."))
    [void]$sb.Append((New-WBullet "Bước 5 — Khóa / Mở khóa và Xóa Account:" "Nhấn nút 'Khóa' (hoặc 'Mở khóa') để đình chỉ/khôi phục quyền đăng nhập của tài khoản; nhấn nút 'Xóa Account' và xác nhận để xóa vĩnh viễn tài khoản khỏi hệ thống."))

    [void]$sb.Append((New-WHeading3 "4.3.2. Hướng dẫn Sử dụng dành cho Người Quản lý CRM (CRM Manager — quanly.html)"))
    [void]$sb.Append((New-WBullet "Bước 1 — Đăng nhập vào Giao diện Quản lý CRM:" "Tại login.html, đăng nhập với tài khoản 'quanly' / '123456'. Hệ thống điều hướng vào giao diện quanly.html gồm 5 tab nghiệp vụ ở thanh bên trái."))
    [void]$sb.Append((New-WBullet "Bước 2 — Thêm mới, Xóa & Khóa Tài khoản Khách hàng (Tab 1):" "Tại tab '1. Quản lý Khách hàng', nhấn '+ Thêm một khách hàng mới' để tạo khách hàng kèm hồ sơ độ tuổi & sở thích; nhấn nút 'Khóa TK' để khóa tài khoản khách hàng vi phạm; nhấn nút 'Xóa' để xóa hồ sơ khách hàng."))
    [void]$sb.Append((New-WBullet "Bước 3 — Tiếp nhận & Giải đáp Phản hồi Khách hàng (Tab 2):" "Chuyển sang tab '2. Tiếp nhận Phản hồi', xem biểu đồ phân bổ 1–5 sao. Nhấn nút 'Tiếp nhận & Trả lời' tại phản hồi của khách hàng, nhập câu trả lời giải đáp và nhấn Lưu."))
    [void]$sb.Append((New-WBullet "Bước 4 — Xem Báo cáo Tỷ lệ Độ tuổi & Sở thích (Tab 3):" "Chuyển sang tab '3. Báo cáo Độ tuổi & Sở thích' để xem tự động Biểu đồ tròn Tỷ lệ Độ tuổi, Biểu đồ cột Phân bố Sở thích và bảng số liệu tỷ lệ %."))
    [void]$sb.Append((New-WBullet "Bước 5 — Tạo Bảng Khảo sát gửi đến TK Khách hàng (Tab 4):" "Chuyển sang tab '4. Tạo & Gửi Khảo sát', điền Tiêu đề, Sản phẩm khảo sát, Giá dự kiến, Thời hạn và Mô tả rồi nhấn 'Phát hành & Gửi đến Khách hàng'."))
    [void]$sb.Append((New-WBullet "Bước 6 — Xem Thống kê Kết quả Khảo sát (Tab 5):" "Chuyển sang tab '5. Thống kê Khảo sát' để xem tỷ lệ tham gia, điểm quan tâm trung bình, biểu đồ ý định mua sắm và danh sách chi tiết toàn bộ phiếu trả lời của khách hàng."))

    [void]$sb.Append((New-WHeading3 "4.3.3. Hướng dẫn Sử dụng dành cho Khách hàng (Customer Portal — user.html)"))
    [void]$sb.Append((New-WBullet "Bước 1 — Đăng ký hoặc Đăng nhập Tài khoản Khách hàng:" "Mở tệp Frontend_Admin/user.html. Chọn tab 'Đăng ký tài khoản' để tạo tài khoản mới hoặc chọn tab 'Đăng nhập' và nhập 'khachhang1' / '123456'."))
    [void]$sb.Append((New-WBullet "Bước 2 — Gửi Phản hồi về Sản phẩm & Xem Giải đáp (Tab 1):" "Tại tab 'Phản hồi sản phẩm', chọn sản phẩm cần đánh giá, chọn mức sao (1–5 sao), nhập nhận xét và nhấn 'Gửi phản hồi'. Sử dụng hộp 'Lọc theo sản phẩm' bên dưới để xem đánh giá và câu trả lời từ Người quản lý."))
    [void]$sb.Append((New-WBullet "Bước 3 — Nhận được Khảo sát và Thực hiện (Tab 2):" "Nhấn vào mục 'Khảo sát thị trường' (có huy hiệu báo số khảo sát mới). Nhấn nút 'Thực hiện khảo sát' trên chiến dịch đang mở, chọn điểm quan tâm (1–5), chọn ý định mua sắm, nhập ý kiến đóng góp và nhấn 'Gửi kết quả khảo sát'."))
    [void]$sb.Append((New-WBullet "Bước 4 — Chỉnh sửa Thông tin Cá nhân (Tab 3):" "Nhấn vào mục 'Hồ sơ cá nhân', cập nhật Họ tên, Số điện thoại, Email, Độ tuổi, Giới tính, Sở thích hoặc Địa chỉ rồi nhấn 'Lưu chỉnh sửa thông tin'."))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # 4.4. KẾ HOẠCH VÀ BẢNG 30 KỊCH BẢN KIỂM THỬ NGHIỆM THU (30 TEST CASES)
    # ==========================================================================
    [void]$sb.Append((New-WHeading2 "4.4. Hồ sơ Kiểm thử Phần mềm Toàn diện (30 Kịch bản Kiểm thử Nghiệm thu — Test Cases)"))
    [void]$sb.Append((New-WP -Text "Để đảm bảo chất lượng phần mềm đạt độ tin cậy tuyệt đối khi chấm điểm và demo trực tiếp, nhóm đã xây dựng và thực thi 30 kịch bản kiểm thử (Test Cases) bao phủ cả luồng thành công (Positive Cases) lẫn luồng kiểm tra ràng buộc/ngoại lệ (Negative & Edge Cases):" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Mã TC", "Phân hệ", "Tên Kịch bản Kiểm thử (Test Case)", "Dữ liệu Đầu vào & Thao tác Thực hiện", "Kết quả Mong đợi (Expected Result)", "Kết quả") -ColWidths @(750, 1200, 2150, 2400, 2300, 800) -Rows @(
        @("TC-01", "Auth", "Đăng nhập Admin Server thành công", "Nhập admin / 123456 tại login.html, nhấn Đăng nhập.", "HTTP 200 OK; roleName = 'Admin'; tự động chuyển hướng tới admin.html.", "PASS"),
        @("TC-02", "Auth", "Đăng nhập Người Quản lý CRM thành công", "Nhập quanly / 123456 tại login.html, nhấn Đăng nhập.", "HTTP 200 OK; roleName = 'Manager'; tự động chuyển hướng tới quanly.html.", "PASS"),
        @("TC-03", "Auth", "Đăng nhập Khách hàng thành công", "Nhập khachhang1 / 123456 tại user.html, nhấn Đăng nhập.", "HTTP 200 OK; hiển thị tên Nguyễn Văn An và vào cổng khách hàng.", "PASS"),
        @("TC-04", "Auth", "Chặn đăng nhập khi tài khoản bị khóa", "Nhập khachhang5 / 123456 (tài khoản có IsActive = 0).", "HTTP 401 Unauthorized; báo lỗi 'Tài khoản của bạn đã bị khóa!'.", "PASS"),
        @("TC-05", "Auth", "Bắt lỗi nhập sai mật khẩu", "Nhập admin / sai_mat_khau tại login.html.", "HTTP 401 Unauthorized; báo lỗi 'Sai mật khẩu!'.", "PASS"),
        @("TC-06", "Admin", "Kiểm tra tách biệt giao diện Admin Server", "Quan sát toàn bộ menu và nội dung trên admin.html.", "Tách biệt hoàn toàn với Kho, Nhân sự, Bán hàng, CRM; đã bỏ lọc SP/NCC.", "PASS"),
        @("TC-07", "Admin", "Kiểm tra chuẩn hóa đúng 3 Role trong Dropdown", "Mở hộp chọn phân quyền trên admin.html.", "Chỉ hiển thị đúng 3 Role: Admin, Manager, Customer (đã xóa HR, Warehouse, Sales).", "PASS"),
        @("TC-08", "Admin", "Xem danh sách 19 Account & 4 thẻ KPI", "Tải màn hình Tab 1 trên admin.html.", "Hiển thị Tổng 19 tài khoản, 17 Hoạt động, 2 Đã khóa, 3 Vai trò.", "PASS"),
        @("TC-09", "Admin", "Tìm kiếm & Lọc tài khoản theo Role", "Nhập 'khachhang1' hoặc chọn lọc Role = Manager.", "Bảng dữ liệu lọc tức thời đúng các tài khoản khớp điều kiện.", "PASS"),
        @("TC-10", "Admin", "Thêm mới tài khoản từ Admin Server", "Nhấn + Thêm tài khoản mới, nhập user_demo, chọn Role = Manager.", "POST /api/admin/accounts trả về 200 OK; tài khoản mới hiển thị đầu bảng.", "PASS"),
        @("TC-11", "Admin", "Bắt lỗi trùng Username khi tạo Account", "Tạo tài khoản mới với Username = 'admin' đã tồn tại.", "HTTP 400 BadRequest; báo lỗi 'Username đã tồn tại!'.", "PASS"),
        @("TC-12", "Admin", "Phân quyền cho Account (Đổi Role)", "Chọn Role mới cho tài khoản trên dòng và nhấn nút 'Phân quyền'.", "PUT /api/admin/accounts/{id}/role cập nhật thành công quyền hạn mới.", "PASS"),
        @("TC-13", "Admin", "Khóa và Mở khóa trạng thái Account", "Nhấn nút 'Khóa' rồi nhấn 'Mở khóa' trên dòng tài khoản.", "PUT .../toggle-status đảo cờ IsActive (Hoạt động <-> Đã khóa) chính xác.", "PASS"),
        @("TC-14", "Admin", "Xóa Account có dữ liệu liên kết", "Nhấn 'Xóa Account' trên một tài khoản khách hàng.", "DELETE /api/admin/accounts/{id} xóa dây chuyền an toàn không lỗi FK.", "PASS"),
        @("TC-15", "CRM", "Thêm một khách hàng mới từ Quản lý", "Tại Tab 1 (quanly.html), nhấn + Thêm KH mới, điền thông tin & Lưu.", "POST /api/admin/crm/customers tạo đồng bộ Account + CustomerProfile.", "PASS"),
        @("TC-16", "CRM", "Khóa tài khoản khách hàng vi phạm", "Tại Tab 1 (quanly.html), nhấn nút 'Khóa TK' ở dòng khách hàng.", "PUT /api/admin/crm/customers/{id}/toggle-status chuyển TK sang Đã khóa.", "PASS"),
        @("TC-17", "CRM", "Xóa hồ sơ khách hàng", "Tại Tab 1 (quanly.html), nhấn nút 'Xóa' trên dòng khách hàng.", "DELETE /api/admin/crm/customers/{id} xóa sạch khách hàng khỏi danh sách.", "PASS"),
        @("TC-18", "CRM", "Tiếp nhận danh sách 18 phản hồi & biểu đồ sao", "Mở Tab 2 (Tiếp nhận Phản hồi) trên quanly.html.", "Hiển thị 18 phản hồi, 4 thẻ KPI và 2 biểu đồ thống kê sao/sản phẩm.", "PASS"),
        @("TC-19", "CRM", "Gửi câu trả lời giải đáp phản hồi KH", "Nhấn 'Tiếp nhận & Trả lời', nhập nội dung giải đáp và Lưu.", "PUT /api/admin/crm/feedbacks/{id}/reply cập nhật Status = 'Đã tiếp nhận & Xử lý'.", "PASS"),
        @("TC-20", "CRM", "Xem Báo cáo tỷ lệ Độ tuổi & Sở thích", "Mở Tab 3 (Báo cáo Độ tuổi & Sở thích) trên quanly.html.", "Hiển thị chính xác Biểu đồ tròn Độ tuổi, Biểu đồ cột Sở thích & 2 bảng %.", "PASS"),
        @("TC-21", "CRM", "Tạo bảng khảo sát mới gửi đến TK KH", "Tại Tab 4, nhập tiêu đề, sản phẩm, giá dự kiến, hạn và nhấn Phát hành.", "POST /api/admin/crm/surveys tạo khảo sát và gửi tới toàn bộ TK khách hàng.", "PASS"),
        @("TC-22", "CRM", "Khóa/Mở khóa & Xóa chiến dịch khảo sát", "Tại Tab 4, nhấn nút Đóng/Mở hoặc Xóa trên dòng khảo sát.", "PUT .../toggle-lock và DELETE .../surveys/{id} hoạt động chính xác.", "PASS"),
        @("TC-23", "CRM", "Xem Thống kê kết quả khảo sát", "Mở Tab 5 (Thống kê Khảo sát) trên quanly.html.", "Hiển thị 4 thẻ KPI, 2 biểu đồ khảo sát, bảng tỷ lệ % và 16 phiếu trả lời.", "PASS"),
        @("TC-24", "Customer", "Đăng ký tài khoản khách hàng mới", "Tại user.html, mở tab Đăng ký, điền thông tin và nhấn Hoàn tất.", "POST /api/customer/register tạo tài khoản thành công và tự động đăng nhập.", "PASS"),
        @("TC-25", "Customer", "Chỉnh sửa thông tin cá nhân khách hàng", "Tại Tab Hồ sơ cá nhân, đổi Tuổi, Sở thích, Địa chỉ và nhấn Lưu.", "PUT /api/customer/profile/{id} lưu thành công và cập nhật báo cáo CRM.", "PASS"),
        @("TC-26", "Customer", "Gửi phản hồi về sản phẩm (1–5 sao)", "Chọn sản phẩm, chọn 5 Sao, nhập nhận xét và nhấn Gửi phản hồi.", "POST /api/customer/feedbacks/{id} lưu thành công và hiển thị đầu bảng.", "PASS"),
        @("TC-27", "Customer", "Lọc xem phản hồi & giải đáp theo sản phẩm", "Chọn một sản phẩm cụ thể tại hộp 'Lọc theo sản phẩm'.", "GET /api/customer/all-feedbacks?productId=... lọc đúng sản phẩm đã chọn.", "PASS"),
        @("TC-28", "Customer", "Nhận khảo sát và gửi phiếu trả lời khảo sát", "Tại Tab Khảo sát thị trường, nhấn Thực hiện khảo sát, điền và gửi.", "POST /api/customer/surveys/{sid}/submit/{aid} lưu phiếu và báo Đã thực hiện.", "PASS"),
        @("TC-29", "Customer", "Chặn gửi trùng lặp phiếu khảo sát lần 2", "Thử gửi lại phiếu trả lời cho khảo sát đã thực hiện.", "HTTP 400 BadRequest; báo lỗi 'Bạn đã thực hiện bài khảo sát này rồi!'.", "PASS"),
        @("TC-30", "Database", "Thực thi kịch bản Backup & Restore CSDL", "Chạy lệnh BACKUP DATABASE và RESTORE VERIFYONLY trên SQL Server.", "Tạo file .bak thành công, kiểm tra toàn vẹn đạt 100% hợp lệ.", "PASS")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # CHƯƠNG 5: TỔNG KẾT VÀ HƯỚNG PHÁT TRIỂN HỆ THỐNG (5 ĐIỂM)
    # ==========================================================================
    [void]$sb.Append((New-WHeading1 "CHƯƠNG 5: TỔNG KẾT VÀ HƯỚNG PHÁT TRIỂN HỆ THỐNG (5 ĐIỂM)"))

    [void]$sb.Append((New-WHeading2 "5.1. Tổng kết Những gì Đã làm được so với Yêu cầu Đồ án"))
    [void]$sb.Append((New-WP -Text "Sau 15 tuần làm việc nghiêm túc, nhóm đã hoàn thành 100% toàn bộ các yêu cầu phân tích, thiết kế, cài đặt CSDL và xây dựng ứng dụng phần mềm của học phần Hệ thống Thông tin Doanh nghiệp (841065):" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Phân hệ / Hạng mục Yêu cầu trong Đề bài", "Trạng thái Hoàn thành", "Kết quả Đạt được Thực tế trong Đồ án & Báo cáo") -ColWidths @(2800, 1500, 5300) -Rows @(
        @("1. Giao diện Admin Server tách biệt độc lập", "Hoàn thành 100%", "Giao diện admin.html tách biệt hoàn toàn với Nhân sự, Kho, Bán hàng, CRM; đã loại bỏ toàn bộ bảng tìm kiếm/lọc sản phẩm và nhà cung cấp."),
        @("2. Admin thêm, xóa, khóa & phân quyền Account", "Hoàn thành 100%", "Admin thực hiện Thêm mới, Xóa (Cascade), Khóa/Mở khóa và Phân quyền cho Account theo đúng 3 vai trò chuẩn: Admin, Manager, Customer."),
        @("3. Người quản lý: Thêm, Xóa, Khóa khách hàng", "Hoàn thành 100%", "Tab 1 trên quanly.html hỗ trợ Thêm một khách hàng mới, Xóa khách hàng và Khóa/Mở khóa tài khoản khách hàng tức thời."),
        @("4. Người quản lý: Tiếp nhận phản hồi KH", "Hoàn thành 100%", "Tab 2 trên quanly.html tiếp nhận toàn bộ đánh giá 1–5 sao, vẽ biểu đồ phân tích và cho phép gửi câu trả lời giải đáp chính thức."),
        @("5. Người quản lý: Báo cáo độ tuổi & sở thích", "Hoàn thành 100%", "Tab 3 trên quanly.html tự động tổng hợp và vẽ Biểu đồ tròn Tỷ lệ Độ tuổi cùng Biểu đồ cột Phân bố Sở thích tiêu dùng."),
        @("6. Người quản lý: Tạo khảo sát gửi đến TK KH", "Hoàn thành 100%", "Tab 4 trên quanly.html cho phép tạo chiến dịch khảo sát sản phẩm mới (kèm giá dự kiến & thời hạn) gửi tới toàn bộ tài khoản khách hàng."),
        @("7. Người quản lý: Thống kê kết quả khảo sát", "Hoàn thành 100%", "Tab 5 trên quanly.html thống kê tổng lượt trả lời, điểm quan tâm trung bình (1–5), biểu đồ ý định mua sắm và danh sách chi tiết 16 phiếu."),
        @("8. Khách hàng: Đăng ký, Đăng nhập, Sửa hồ sơ", "Hoàn thành 100%", "Cổng user.html hỗ trợ Đăng ký nhanh gọn, Đăng nhập an toàn và Chỉnh sửa thông tin cá nhân (Họ tên, SĐT, Tuổi, Giới tính, Sở thích, Địa chỉ)."),
        @("9. Khách hàng: Gửi phản hồi & Làm khảo sát", "Hoàn thành 100%", "Cổng user.html cho phép chấm 1–5 sao về sản phẩm, lọc xem giải đáp theo sản phẩm, nhận thông báo khảo sát mới và gửi phiếu khảo sát."),
        @("10. Báo cáo, Sơ đồ BFD/Context/DFD/ERD & SQL", "Hoàn thành 100%", "Đầy đủ 9 sơ đồ kỹ thuật chuẩn, 15 ảnh chụp giao diện thực tế, CSDL 9 bảng chuẩn 3NF, kịch bản Backup/Restore và tập tin readme.txt.")
    )))

    [void]$sb.Append((New-WHeading2 "5.2. Đánh giá Ưu điểm và Nhược điểm của HTTT Vừa được Xây dựng"))
    [void]$sb.Append((New-WTable -Headers @("Tiêu chí Đánh giá", "Ưu điểm Nổi bật của Hệ thống Đã Xây dựng", "Nhược điểm / Hạn chế Cần Cải tiến") -ColWidths @(2200, 3800, 3600) -Rows @(
        @("1. Kiến trúc & An toàn Phân quyền", "Tuân thủ triệt để nguyên tắc Separation of Duties: tách biệt hoàn toàn giao diện Admin Server, Người Quản lý CRM và Khách hàng; mật khẩu băm BCrypt; xóa dây chuyền an toàn.", "Chưa tích hợp cơ chế xác thực 2 lớp (2FA/OTP qua Email hoặc SMS) khi người dùng quên mật khẩu."),
        @("2. Tính Đầy đủ & Chính xác Nghiệp vụ", "Khép kín vòng lặp dữ liệu thời gian thực giữa Khách hàng và Người Quản lý (Gửi phản hồi <-> Nhận giải đáp; Phát hành khảo sát <-> Thực hiện & Thống kê tự động).", "Cấu trúc câu hỏi khảo sát hiện cố định theo chuẩn 3 tiêu chí (Điểm quan tâm, Ý định mua, Ý kiến đóng góp), chưa hỗ trợ tự định nghĩa thêm câu hỏi trắc nghiệm tùy ý."),
        @("3. Trải nghiệm Giao diện & Báo cáo", "Giao diện chuẩn doanh nghiệp VNG Corporation hiện đại, rộng rãi; tích hợp bộ vẽ biểu đồ Canvas hoạt động 100% cả khi có mạng lẫn ngoại tuyến.", "Chưa có phiên bản ứng dụng di động gốc (Native Mobile App trên iOS/Android) để gửi thông báo đẩy (Push Notification).")
    )))

    [void]$sb.Append((New-WHeading2 "5.3. Hướng Phát triển cho Hệ thống trong Tương lai"))
    [void]$sb.Append((New-WBullet "1. Tích hợp Thông báo Thời gian thực (SignalR WebSockets & Email Service):" "Tự động đẩy thông báo tức thời lên màn hình Người quản lý ngay khi có khách hàng gửi đánh giá 1–2 sao và gửi Email thông báo khi có chiến dịch khảo sát mới."))
    [void]$sb.Append((New-WBullet "2. Tích hợp Trí tuệ Nhân tạo Phân tích Cảm xúc Khách hàng (AI Sentiment Analysis):" "Ứng dụng mô hình xử lý ngôn ngữ tự nhiên tiếng Việt (PhoBERT / Gemini API) để tự động phân loại sắc thái bình luận và gợi ý câu trả lời mẫu cho Người quản lý CRM."))
    [void]$sb.Append((New-WBullet "3. Mở rộng Hệ sinh thái Omnichannel & Ứng dụng Di động:" "Phát triển ứng dụng di động bằng Flutter/React Native tích hợp quét mã QR bảo hành sản phẩm, tích điểm thành viên (Loyalty Program) và cá nhân hóa khuyến mãi theo nhóm Sở thích tiêu dùng."))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # PHẦN II: XÂY DỰNG VÀ CÀI ĐẶT CСР SỞ DỮ LIỆU & PHƯƠNG ÁN BACKUP/RESTORE (30Đ)
    # ==========================================================================
    [void]$sb.Append((New-WHeading1 "PHẦN II: XÂY DỰNG VÀ CÀI ĐẶT CƠ SỞ DỮ LIỆU & PHƯƠNG ÁN SAO LƯU, PHỤC HỒI CSDL (30 ĐIỂM)"))

    [void]$sb.Append((New-WHeading2 "II.1. Kịch bản Cài đặt Cơ sở Dữ liệu Đầy đủ 9 Bảng Chuẩn 3NF (Database DDL Script)"))
    [void]$sb.Append((New-WP -Text "Dưới đây là kịch bản T-SQL chuẩn hóa dùng để khởi tạo toàn bộ 9 bảng dữ liệu, các khóa chính (PRIMARY KEY), khóa ngoại (FOREIGN KEY), ràng buộc kiểm tra miền giá trị (CHECK) và cơ chế xóa dây chuyền (ON DELETE CASCADE) của hệ thống trong tệp Database/HTTTDN_DB.sql:" -IndentFirst 420))

    [void]$sb.Append((New-WCodeBlock -Title "Kịch bản T-SQL Khởi tạo Cấu trúc 9 Bảng CSDL (Database/HTTTDN_DB.sql):" -CodeText @"
USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'HTTTDN_DB')
BEGIN
    ALTER DATABASE [HTTTDN_DB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [HTTTDN_DB];
END
GO
CREATE DATABASE [HTTTDN_DB];
GO
USE [HTTTDN_DB];
GO

-- 1. Bảng Vai trò (Roles) — Chỉ giữ đúng 3 Role: Admin, Manager, Customer
CREATE TABLE Roles (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(250) NULL
);

-- 2. Bảng Tài khoản người dùng (Accounts)
CREATE TABLE Accounts (
    AccountId INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    Email VARCHAR(100) NULL,
    Phone VARCHAR(20) NULL,
    RoleId INT NOT NULL FOREIGN KEY REFERENCES Roles(RoleId),
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

-- 3. Bảng Danh mục sản phẩm (Categories)
CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255) NULL
);

-- 4. Bảng Nhà cung cấp (Suppliers)
CREATE TABLE Suppliers (
    SupplierId INT IDENTITY(1,1) PRIMARY KEY,
    SupplierCode VARCHAR(20) NOT NULL UNIQUE,
    SupplierName NVARCHAR(150) NOT NULL,
    ContactName NVARCHAR(100) NULL,
    Phone VARCHAR(20) NULL,
    Email VARCHAR(100) NULL,
    Address NVARCHAR(255) NULL
);

-- 5. Bảng Sản phẩm (Products)
CREATE TABLE Products (
    ProductId INT IDENTITY(1,1) PRIMARY KEY,
    ProductCode VARCHAR(50) NOT NULL UNIQUE,
    ProductName NVARCHAR(200) NOT NULL,
    CategoryId INT NOT NULL FOREIGN KEY REFERENCES Categories(CategoryId),
    SupplierId INT NOT NULL FOREIGN KEY REFERENCES Suppliers(SupplierId),
    Price DECIMAL(18,2) NOT NULL,
    CostPrice DECIMAL(18,2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    Unit NVARCHAR(20) NOT NULL,
    Status NVARCHAR(50) NOT NULL,
    ImageUrl NVARCHAR(500) NULL
);

-- 6. Bảng Hồ sơ nhân khẩu học khách hàng (CustomerProfiles)
CREATE TABLE CustomerProfiles (
    ProfileId INT IDENTITY(1,1) PRIMARY KEY,
    AccountId INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Accounts(AccountId) ON DELETE CASCADE,
    Age INT NOT NULL,
    Gender NVARCHAR(10) NULL,
    Address NVARCHAR(255) NULL,
    Interest NVARCHAR(100) NULL
);

-- 7. Bảng Phản hồi & Đánh giá sản phẩm (Feedbacks)
CREATE TABLE Feedbacks (
    FeedbackId INT IDENTITY(1,1) PRIMARY KEY,
    AccountId INT NOT NULL FOREIGN KEY REFERENCES Accounts(AccountId) ON DELETE CASCADE,
    ProductId INT NOT NULL FOREIGN KEY REFERENCES Products(ProductId) ON DELETE CASCADE,
    Rating INT NOT NULL CHECK (Rating >= 1 AND Rating <= 5),
    Comment NVARCHAR(1000) NOT NULL,
    AdminReply NVARCHAR(1000) NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT N'Chờ xử lý',
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

-- 8. Bảng Chiến dịch Khảo sát sản phẩm mới (Surveys)
CREATE TABLE Surveys (
    SurveyId INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NULL,
    TargetProduct NVARCHAR(150) NOT NULL,
    ExpectedPrice DECIMAL(18,2) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1,
    ExpiresAt DATETIME NULL
);

-- 9. Bảng Kết quả trả lời khảo sát (SurveyResponses)
CREATE TABLE SurveyResponses (
    ResponseId INT IDENTITY(1,1) PRIMARY KEY,
    SurveyId INT NOT NULL FOREIGN KEY REFERENCES Surveys(SurveyId) ON DELETE CASCADE,
    AccountId INT NOT NULL FOREIGN KEY REFERENCES Accounts(AccountId) ON DELETE CASCADE,
    Score INT NOT NULL CHECK (Score >= 1 AND Score <= 5),
    BuyingIntent NVARCHAR(50) NOT NULL,
    CustomerOpinion NVARCHAR(1000) NULL,
    SubmittedAt DATETIME NOT NULL DEFAULT GETDATE()
);
GO
"@))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # II.2. PHƯƠNG ÁN SAO LƯU VÀ PHỤC HỒI CƠ SỞ DỮ LIỆU TRONG BÁO CÁO (5 ĐIỂM)
    # ==========================================================================
    [void]$sb.Append((New-WHeading2 "II.2. Phương án Sao lưu và Phục hồi Cơ sở Dữ liệu (Database Backup & Disaster Recovery Plan — 5 điểm)"))
    [void]$sb.Append((New-WP -Text "Thực hiện yêu cầu bắt buộc trong thang điểm: 'Phải có phương án để sao lưu và phục hồi CSDL trong báo cáo (5đ)', nhóm thiết kế Chiến lược Sao lưu An toàn 3 Tầng (3-Tier Backup Strategy) kết hợp Quy trình Phục hồi Thảm họa theo Thời điểm (Point-in-Time Disaster Recovery) trên Microsoft SQL Server:" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Cấp độ Sao lưu", "Loại Bản Sao lưu", "Lịch trình Tự động", "Mục tiêu Điểm Khôi phục (RPO) & Thời gian Khôi phục (RTO)", "Chính sách Lưu trữ (Retention)") -ColWidths @(1600, 1800, 1600, 2600, 2000) -Rows @(
        @("Tầng 1 (Full)", "FULL DATABASE BACKUP (.bak)", "00:00 Chủ nhật hàng tuần", "Sao lưu 100% cấu trúc 9 bảng, chỉ mục và dữ liệu làm mốc cơ sở (Baseline). RTO < 15 phút.", "Lưu 12 tuần trên ổ cứng máy chủ & Cloud Storage."),
        @("Tầng 2 (Diff)", "DIFFERENTIAL BACKUP (.bak)", "23:30 mỗi tối (Thứ 2 – Thứ 7)", "Chỉ sao lưu các trang dữ liệu thay đổi từ lần Full Backup gần nhất; tăng tốc độ sao lưu gấp 5 lần.", "Lưu 14 ngày liên tiếp trên phân vùng Backup."),
        @("Tầng 3 (Log)", "TRANSACTION LOG BACKUP (.trn)", "Mỗi 30 phút / lần (07:00 – 22:00)", "Đảm bảo RPO < 5 phút; cho phép khôi phục chính xác đến từng giây trước khi xảy ra thao tác xóa nhầm.", "Lưu 7 ngày liên tiếp để phục vụ Point-in-Time Restore.")
    )))

    [void]$sb.Append((New-WCodeBlock -Title "1. Kịch bản T-SQL Sao lưu Cơ sở Dữ liệu 3 Tầng & Kiểm tra Toàn vẹn (Backup Script):" -CodeText @"
-- =========================================================================
-- KỊCH BẢN T-SQL SAO LƯU CSDL HTTTDN_DB (FULL + DIFFERENTIAL + LOG BACKUP)
-- =========================================================================
USE master;
GO

-- Bước 1: Chuyển chế độ Recovery Model sang FULL để hỗ trợ sao lưu nhật ký giao dịch
ALTER DATABASE [HTTTDN_DB] SET RECOVERY FULL;
GO

-- Bước 2: Kịch bản Sao lưu Toàn phần (FULL BACKUP) - Chạy định kỳ Chủ nhật
BACKUP DATABASE [HTTTDN_DB]
TO DISK = N'D:\SQLBackups\HTTTDN_DB_Full.bak'
WITH FORMAT, INIT,
     NAME = N'HTTTDN_DB - Full Database Backup',
     COMPRESSION, CHECKSUM, STATS = 10;
GO

-- Bước 3: Kịch bản Sao lưu Vi sai / Khác biệt (DIFFERENTIAL BACKUP) - Chạy 23:30 hàng ngày
BACKUP DATABASE [HTTTDN_DB]
TO DISK = N'D:\SQLBackups\HTTTDN_DB_Diff.bak'
WITH DIFFERENTIAL, INIT,
     NAME = N'HTTTDN_DB - Differential Database Backup',
     COMPRESSION, CHECKSUM, STATS = 10;
GO

-- Bước 4: Kịch bản Sao lưu Nhật ký Giao dịch (TRANSACTION LOG BACKUP) - Chạy mỗi 30 phút
BACKUP LOG [HTTTDN_DB]
TO DISK = N'D:\SQLBackups\HTTTDN_DB_Log.trn'
WITH INIT,
     NAME = N'HTTTDN_DB - Transaction Log Backup',
     COMPRESSION, CHECKSUM, STATS = 10;
GO

-- Bước 5: Kiểm tra tính toàn vẹn vật lý của tệp sao lưu (Verify Backup Integrity)
RESTORE VERIFYONLY
FROM DISK = N'D:\SQLBackups\HTTTDN_DB_Full.bak'
WITH CHECKSUM;
GO
"@))

    [void]$sb.Append((New-WCodeBlock -Title "2. Kịch bản T-SQL Phục hồi Cơ sở Dữ liệu khi Xảy ra Sự cố (Disaster Recovery Restore Script):" -CodeText @"
-- =========================================================================
-- KỊCH BẢN T-SQL PHỤC HỒI CSDL HTTTDN_DB (TAIL-LOG -> FULL -> DIFF -> LOG)
-- =========================================================================
USE master;
GO

-- Bước 1: Ngắt toàn bộ kết nối hiện hành và chuyển CSDL về chế độ SINGLE_USER
ALTER DATABASE [HTTTDN_DB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Bước 2: Sao lưu phần nhật ký cuối cùng chưa kịp lưu trước sự cố (Tail-Log Backup)
BACKUP LOG [HTTTDN_DB]
TO DISK = N'D:\SQLBackups\HTTTDN_DB_TailLog.trn'
WITH NORECOVERY, INIT,
     NAME = N'HTTTDN_DB - Tail-Log Backup';
GO

-- Bước 3: Khôi phục bản FULL BACKUP gần nhất ở trạng thái NORECOVERY
RESTORE DATABASE [HTTTDN_DB]
FROM DISK = N'D:\SQLBackups\HTTTDN_DB_Full.bak'
WITH NORECOVERY, REPLACE, STATS = 10;
GO

-- Bước 4: Khôi phục bản DIFFERENTIAL BACKUP gần nhất ở trạng thái NORECOVERY
RESTORE DATABASE [HTTTDN_DB]
FROM DISK = N'D:\SQLBackups\HTTTDN_DB_Diff.bak'
WITH NORECOVERY, STATS = 10;
GO

-- Bước 5: Khôi phục bản TRANSACTION LOG và mở lại CSDL hoạt động (WITH RECOVERY)
RESTORE LOG [HTTTDN_DB]
FROM DISK = N'D:\SQLBackups\HTTTDN_DB_Log.trn'
WITH RECOVERY, STATS = 10;
GO

-- Bước 6: Đưa CSDL trở lại chế độ đa người dùng (MULTI_USER)
ALTER DATABASE [HTTTDN_DB] SET MULTI_USER;
GO
"@))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # PHẦN III: ĐẶC TẢ KIẾN TRÚC RESTFUL API & MÃ NGUỒN CÀI ĐẶT PHẦN MỀM (30Đ)
    # ==========================================================================
    [void]$sb.Append((New-WHeading1 "PHẦN III: ĐẶC TẢ KIẾN TRÚC RESTFUL API & MÃ NGUỒN CÀI ĐẶT ỨNG DỤNG (30 ĐIỂM)"))

    [void]$sb.Append((New-WHeading2 "III.1. Bảng Tổng hợp Toàn bộ 21 RESTful API Endpoints của Hệ thống Backend"))
    [void]$sb.Append((New-WP -Text "Toàn bộ hệ thống Backend ASP.NET Core 8.0 (HTTTDN.AdminApi) cung cấp 21 RESTful API Endpoints được phân chia rõ ràng theo các Controller chuyên trách:" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("STT", "Phương thức & Đường dẫn API (Route)", "Controller Xử lý", "Phân hệ Gọi", "Mô tả Chức năng Xử lý Nghiệp vụ & CSDL") -ColWidths @(550, 2750, 1750, 1250, 3300) -Rows @(
        @("01", "POST /api/admin/auth/login", "AuthController", "login.html", "Xác thực đăng nhập tập trung (hỗ trợ BCrypt) và trả về RoleName để phân luồng giao diện."),
        @("02", "GET /api/admin/accounts", "AccountsController", "admin.html", "Lấy danh sách toàn bộ 19 tài khoản kèm thông tin vai trò từ bảng Accounts & Roles."),
        @("03", "GET /api/admin/accounts/roles", "AccountsController", "admin.html", "Lấy danh sách 3 vai trò chuẩn (Admin, Manager, Customer) phục vụ phân quyền."),
        @("04", "POST /api/admin/accounts", "AccountsController", "admin.html", "Thêm tài khoản mới; tự động tạo bản ghi CustomerProfiles nếu Role là Customer."),
        @("05", "PUT /api/admin/accounts/{id}/role", "AccountsController", "admin.html", "Cập nhật phân quyền (RoleId) cho bất kỳ tài khoản nào trên máy chủ."),
        @("06", "PUT /api/admin/accounts/{id}/toggle-status", "AccountsController", "admin.html", "Khóa hoặc mở khóa trạng thái hoạt động (IsActive) của tài khoản."),
        @("07", "DELETE /api/admin/accounts/{id}", "AccountsController", "admin.html", "Xóa dây chuyền dữ liệu liên kết và xóa tài khoản khỏi bảng Accounts."),
        @("08", "GET /api/admin/crm/customers", "CrmAdminController", "quanly.html", "Lấy danh sách 15 khách hàng kèm hồ sơ nhân khẩu học (Tuổi, Giới tính, Sở thích, Địa chỉ)."),
        @("09", "POST /api/admin/crm/customers", "CrmAdminController", "quanly.html", "Người quản lý thêm một khách hàng mới (tạo đồng bộ Account + CustomerProfile)."),
        @("10", "PUT /api/admin/crm/customers/{id}/toggle-status", "CrmAdminController", "quanly.html", "Người quản lý khóa hoặc mở khóa tài khoản khách hàng."),
        @("11", "DELETE /api/admin/crm/customers/{id}", "CrmAdminController", "quanly.html", "Người quản lý xóa hồ sơ khách hàng và tài khoản liên kết."),
        @("12", "GET /api/admin/crm/feedbacks", "CrmAdminController", "quanly.html", "Tiếp nhận danh sách toàn bộ 18 phản hồi sản phẩm của khách hàng kèm ảnh sản phẩm."),
        @("13", "PUT /api/admin/crm/feedbacks/{id}/reply", "CrmAdminController", "quanly.html", "Người quản lý gửi câu trả lời giải đáp (AdminReply) và đổi trạng thái xử lý."),
        @("14", "GET /api/admin/crm/reports/demographics", "CrmAdminController", "quanly.html", "Tổng hợp báo cáo thống kê tỷ lệ độ tuổi (<20, 20–30, >30) và tỷ lệ % các nhóm sở thích."),
        @("15", "GET /api/admin/crm/surveys", "CrmAdminController", "quanly.html", "Lấy danh sách các chiến dịch khảo sát kèm số lượng phản hồi đã thu thập."),
        @("16", "POST /api/admin/crm/surveys", "CrmAdminController", "quanly.html", "Tạo bảng khảo sát sản phẩm mới và phát hành đến toàn bộ tài khoản khách hàng."),
        @("17", "PUT /api/admin/crm/surveys/{id}/toggle-lock", "CrmAdminController", "quanly.html", "Khóa hoặc mở khóa nhận câu trả lời cho một chiến dịch khảo sát."),
        @("18", "DELETE /api/admin/crm/surveys/{id}", "CrmAdminController", "quanly.html", "Xóa chiến dịch khảo sát cùng các phiếu trả lời liên quan."),
        @("19", "GET /api/admin/crm/surveys/{id}/statistics", "CrmAdminController", "quanly.html", "Thống kê chi tiết kết quả khảo sát: Điểm quan tâm TB, Ý định mua, Phân bố điểm & DS phiếu."),
        @("20", "POST /api/customer/register & /login", "CustomerPortalController", "user.html", "Khách hàng tự đăng ký tài khoản mới và đăng nhập vào Cổng Khách hàng."),
        @("21", "GET & PUT /api/customer/profile/{id} | POST /feedbacks & /surveys", "CustomerPortalController", "user.html", "Khách hàng chỉnh sửa hồ sơ, gửi phản hồi sản phẩm, lọc xem giải đáp và nộp phiếu khảo sát.")
    )))

    [void]$sb.Append((New-WHeading2 "III.2. Đặc tả Mã nguồn Cốt lõi Tầng Backend ASP.NET Core 8.0"))
    [void]$sb.Append((New-WP -Text "Dưới đây là mã nguồn thực tế của các Controller trọng tâm đã được cài đặt tại thư mục Backend/HTTTDN.AdminApi/Controllers/:" -IndentFirst 420))

    [void]$sb.Append((New-WCodeBlock -Title "1. Mã nguồn AccountsController.cs (Phân hệ Admin Server — Quản lý & Phân quyền Account):" -CodeText @"
[Route("api/admin/accounts")]
[ApiController]
public class AccountsController : ControllerBase
{
    private readonly AppDbContext _context;
    public AccountsController(AppDbContext context) => _context = context;

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var list = await _context.Accounts
            .Include(a => a.Role)
            .OrderByDescending(a => a.AccountId)
            .Select(a => new {
                a.AccountId, a.Username, a.FullName, a.Email, a.Phone, a.RoleId,
                RoleName = a.Role != null ? a.Role.RoleName : "Customer",
                RoleDescription = a.Role != null ? a.Role.Description : "",
                a.IsActive, a.CreatedAt
            }).ToListAsync();
        return Ok(list);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AccountCreateDto dto)
    {
        if (await _context.Accounts.AnyAsync(a => a.Username.ToLower() == dto.Username.Trim().ToLower()))
            return BadRequest(new { message = "Username đã tồn tại!" });

        var acc = new Account {
            Username = dto.Username.Trim(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(string.IsNullOrWhiteSpace(dto.Password) ? "123456" : dto.Password),
            FullName = dto.FullName.Trim(),
            Email = string.IsNullOrWhiteSpace(dto.Email) ? $"{dto.Username.Trim().ToLower()}@sgutech.vn" : dto.Email.Trim(),
            Phone = dto.Phone, RoleId = dto.RoleId, IsActive = true, CreatedAt = DateTime.Now
        };
        _context.Accounts.Add(acc);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Tạo tài khoản thành công!" });
    }

    [HttpPut("{id}/role")]
    public async Task<IActionResult> UpdateRole(int id, [FromBody] UpdateRoleDto dto)
    {
        var acc = await _context.Accounts.FindAsync(id);
        if (acc == null) return NotFound(new { message = "Không tìm thấy tài khoản!" });
        acc.RoleId = dto.RoleId;
        await _context.SaveChangesAsync();
        return Ok(new { message = "Cập nhật phân quyền thành công!" });
    }

    [HttpPut("{id}/toggle-status")]
    public async Task<IActionResult> ToggleStatus(int id)
    {
        var acc = await _context.Accounts.FindAsync(id);
        if (acc == null) return NotFound(new { message = "Không tìm thấy tài khoản!" });
        acc.IsActive = !acc.IsActive;
        await _context.SaveChangesAsync();
        return Ok(new { message = acc.IsActive ? "Đã mở khóa tài khoản!" : "Đã khóa tài khoản!", isActive = acc.IsActive });
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var acc = await _context.Accounts.FindAsync(id);
        if (acc == null) return NotFound(new { message = "Không tìm thấy tài khoản!" });
        _context.CustomerProfiles.RemoveRange(await _context.CustomerProfiles.Where(p => p.AccountId == id).ToListAsync());
        _context.Feedbacks.RemoveRange(await _context.Feedbacks.Where(f => f.AccountId == id).ToListAsync());
        _context.SurveyResponses.RemoveRange(await _context.SurveyResponses.Where(r => r.AccountId == id).ToListAsync());
        _context.Accounts.Remove(acc);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Đã xóa tài khoản thành công!" });
    }
}
"@))

    [void]$sb.Append((New-WCodeBlock -Title "2. Mã nguồn CrmAdminController.cs (Phân hệ Người Quản lý CRM — 7 Chức năng Nghiệp vụ):" -CodeText @"
[Route("api/admin/crm")]
[ApiController]
public class CrmAdminController : ControllerBase
{
    private readonly AppDbContext _context;
    public CrmAdminController(AppDbContext context) => _context = context;

    // Báo cáo về khách hàng: Tỷ lệ độ tuổi & sở thích
    [HttpGet("reports/demographics")]
    public async Task<IActionResult> GetDemographicsReport()
    {
        var profiles = await _context.CustomerProfiles.ToListAsync();
        int total = profiles.Count;
        var ageStats = new {
            Under20 = profiles.Count(p => p.Age < 20),
            From20To30 = profiles.Count(p => p.Age >= 20 && p.Age <= 30),
            Over30 = profiles.Count(p => p.Age > 30)
        };
        var interestStats = profiles
            .GroupBy(p => string.IsNullOrEmpty(p.Interest) ? "Khác" : p.Interest)
            .Select(g => new {
                Interest = g.Key, Count = g.Count(),
                Percentage = total > 0 ? Math.Round((double)g.Count() * 100 / total, 1) : 0
            }).ToList();
        return Ok(new { totalCustomers = total, ageStats, interestStats });
    }

    // Thống kê kết quả khảo sát
    [HttpGet("surveys/{id}/statistics")]
    public async Task<IActionResult> GetSurveyStatistics(int id)
    {
        var survey = await _context.Surveys.FindAsync(id);
        if (survey == null) return NotFound(new { message = "Không tìm thấy khảo sát." });
        var responses = await _context.SurveyResponses.Include(r => r.Account)
            .Where(r => r.SurveyId == id).OrderByDescending(r => r.SubmittedAt).ToListAsync();
        int total = responses.Count;
        double avgScore = total > 0 ? Math.Round(responses.Average(r => r.Score), 2) : 0;
        var intentStats = new {
            WantToBuy = responses.Count(r => r.BuyingIntent == "Rất muốn mua"),
            Considering = responses.Count(r => r.BuyingIntent == "Đang cân nhắc"),
            NotBuying = responses.Count(r => r.BuyingIntent == "Không mua")
        };
        return Ok(new { survey.SurveyId, survey.Title, survey.TargetProduct, totalResponses = total, averageScore = avgScore, intentStats });
    }
}
"@))

    return $sb.ToString()
}
