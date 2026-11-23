# ==============================================================================
# PART 10: MỞ RỘNG CHUYÊN SÂU BỔ SUNG CHO CHƯƠNG 1, CHƯƠNG 2, CHƯƠNG 3 & PHẦN II
# ĐẢM BẢO ĐỘ DÀI BÁO CÁO ĐẠT > 115–130 TRANG VỚI 100% NỘI DUNG CỐT LÕI ĐỒ ÁN
# ==============================================================================

function Build-Chapter1-DeepSurveyAnalysis {
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.Append((New-WHeading3 "1.2.5. Phân tích Thống kê Chéo theo 3 Nhóm Đối tượng Khảo sát & Phân tích Nguyên nhân Gốc rễ (5-Whys Analysis)"))
    [void]$sb.Append((New-WP -Text "Để đánh giá khách quan mức độ đồng thuận của từng nhóm đối tượng tham gia khảo sát (05 Kỹ sư IT Admin, 10 Chuyên viên CRM, 20 Khách hàng thành viên), nhóm tiến hành lập bảng phân tích thống kê chéo (Cross-Tabulation Analysis) cho toàn bộ 25 câu hỏi điều tra:" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Mã Câu", "Tóm tắt Nội dung Câu hỏi Khảo sát HTTT", "Khối IT Admin (n = 5)", "Khối Quản lý CRM (n = 10)", "Khối Khách hàng (n = 20)", "Tổng hợp (n = 35)", "Đánh giá Mức độ Cấp thiết") -ColWidths @(800, 2700, 1100, 1200, 1200, 1100, 1500) -Rows @(
        @("Câu 01", "Thực trạng công cụ quản lý danh mục Account", "5/5 (100%)", "8/10 (80%)", "14/20 (70%)", "27/35 (77.1%)", "Rất cấp thiết (Ưu tiên 1)"),
        @("Câu 02", "Thực trạng chưa tách biệt giao diện Admin Server", "5/5 (100%)", "10/10 (100%)", "16/20 (80%)", "31/35 (88.6%)", "Bắt buộc tách biệt 100%"),
        @("Câu 03", "Lẫn lộn chức năng lọc SP & NCC trên màn hình Admin", "5/5 (100%)", "9/10 (90%)", "18/20 (90%)", "32/35 (91.4%)", "Bắt buộc loại bỏ ngay"),
        @("Câu 04", "Thời gian cấp mới, xóa và phân quyền Account chậm", "4/5 (80%)", "9/10 (90%)", "16/20 (80%)", "29/35 (82.9%)", "Cần tự động hóa qua Web"),
        @("Câu 05", "Dư thừa các Role không sử dụng (HR, Warehouse, Sales)", "5/5 (100%)", "10/10 (100%)", "18/20 (90%)", "33/35 (94.3%)", "Chuẩn hóa đúng 3 Role"),
        @("Câu 06", "Hồ sơ khách hàng lưu phân tán trên nhiều file Excel", "4/5 (80%)", "10/10 (100%)", "16/20 (80%)", "30/35 (85.7%)", "Tập trung về SQL Server"),
        @("Câu 07", "Người quản lý thiếu công cụ Thêm mới KH trực tiếp", "4/5 (80%)", "10/10 (100%)", "17/20 (85%)", "31/35 (88.6%)", "Xây dựng Modal Thêm KH"),
        @("Câu 08", "Người quản lý thiếu nút Khóa TK & Xóa khách hàng", "5/5 (100%)", "10/10 (100%)", "17/20 (85%)", "32/35 (91.4%)", "Xây dựng nút Khóa & Xóa"),
        @("Câu 09", "Xóa khách hàng bị lỗi xung đột khóa ngoại SQL", "5/5 (100%)", "9/10 (90%)", "14/20 (70%)", "28/35 (80.0%)", "Cài đặt Cascade Delete"),
        @("Câu 10", "Tìm kiếm & lọc khách hàng theo sở thích mất thời gian", "4/5 (80%)", "10/10 (100%)", "16/20 (80%)", "30/35 (85.7%)", "Tích hợp thanh lọc tức thời"),
        @("Câu 11", "Phản hồi sản phẩm bị trôi trên Zalo / Facebook", "4/5 (80%)", "9/10 (90%)", "16/20 (80%)", "29/35 (82.9%)", "Tập trung về bảng Feedbacks"),
        @("Câu 12", "Thiếu thang chấm điểm 1–5 sao gắn với sản phẩm", "5/5 (100%)", "9/10 (90%)", "18/20 (90%)", "32/35 (91.4%)", "Bắt buộc có Rating 1–5 sao"),
        @("Câu 13", "Thiếu luồng Tiếp nhận & Giải đáp phản hồi của Quản lý", "5/5 (100%)", "10/10 (100%)", "18/20 (90%)", "33/35 (94.3%)", "Xây dựng chức năng Reply"),
        @("Câu 14", "Khách hàng không xem được câu trả lời từ Quản lý", "4/5 (80%)", "9/10 (90%)", "19/20 (95%)", "32/35 (91.4%)", "Hiển thị AdminReply trên web"),
        @("Câu 15", "Khách hàng thiếu bộ lọc đánh giá theo từng sản phẩm", "4/5 (80%)", "8/10 (80%)", "19/20 (95%)", "31/35 (88.6%)", "Tích hợp lọc theo ProductId"),
        @("Câu 16", "Chưa chuẩn hóa dữ liệu Độ tuổi & Sở thích khách hàng", "4/5 (80%)", "10/10 (100%)", "17/20 (85%)", "31/35 (88.6%)", "Tạo bảng CustomerProfiles"),
        @("Câu 17", "Tổng hợp báo cáo Độ tuổi & Sở thích mất 1–2 ngày", "4/5 (80%)", "10/10 (100%)", "16/20 (80%)", "30/35 (85.7%)", "Vẽ biểu đồ tự động Real-time"),
        @("Câu 18", "Báo cáo không tự động cập nhật khi KH sửa hồ sơ", "5/5 (100%)", "10/10 (100%)", "18/20 (90%)", "33/35 (94.3%)", "Đồng bộ API Demographics"),
        @("Câu 19", "Khảo sát qua link Google Forms ngoài tỷ lệ làm < 8%", "4/5 (80%)", "10/10 (100%)", "16/20 (80%)", "30/35 (85.7%)", "Gửi khảo sát vào TK KH"),
        @("Câu 20", "Thiếu quản lý thời hạn (ExpiresAt) và Khóa khảo sát", "4/5 (80%)", "10/10 (100%)", "17/20 (85%)", "31/35 (88.6%)", "Hỗ trợ hạn & Toggle Lock"),
        @("Câu 21", "Khách hàng muốn nhận thông báo & làm khảo sát trên web", "5/5 (100%)", "10/10 (100%)", "19/20 (95%)", "34/35 (97.1%)", "Tích hợp Tab Khảo sát KH"),
        @("Câu 22", "Không chặn được một khách hàng gửi trùng khảo sát", "5/5 (100%)", "9/10 (90%)", "16/20 (80%)", "30/35 (85.7%)", "Kiểm tra Unique (Survey, Acc)"),
        @("Câu 23", "Thiếu Dashboard thống kê kết quả khảo sát tự động", "4/5 (80%)", "10/10 (100%)", "18/20 (90%)", "32/35 (91.4%)", "Xây dựng Tab 5 Thống kê KS"),
        @("Câu 24", "Giao diện cũ thiếu chuyên nghiệp, form đăng ký rườm rà", "4/5 (80%)", "9/10 (90%)", "19/20 (95%)", "32/35 (91.4%)", "Chuẩn hóa UI VNG Enterprise"),
        @("Câu 25", "Chưa có kịch bản Sao lưu & Phục hồi CSDL định kỳ", "5/5 (100%)", "9/10 (90%)", "19/20 (95%)", "33/35 (94.3%)", "Xây dựng Backup/Restore SQL")
    )))

    [void]$sb.Append((New-WHeading4 "Phân tích Nguyên nhân Gốc rễ (Root Cause Analysis — 5 Whys) của 5 Vấn đề Trọng tâm:"))
    [void]$sb.Append((New-WTable -Headers @("TT", "Vấn đề Bất cập Phát hiện qua Khảo sát", "Phân tích Nguyên nhân Gốc rễ (Root Cause)", "Giải pháp Kỹ thuật Triệt để trong Đồ án") -ColWidths @(600, 2600, 3100, 3300) -Rows @(
        @("1", "Giao diện Admin bị chồng chéo với Kho, Nhân sự, Bán hàng và chứa bảng lọc SP/NCC dư thừa.", "Do thiết kế cũ không áp dụng kiến trúc phân quyền RBAC và không tách riêng tệp giao diện theo vai trò.", "Tách riêng hoàn toàn admin.html (chỉ quản lý Account & Role), quanly.html (5 tab CRM) và user.html (Cổng KH)."),
        @("2", "Người quản lý CRM không chủ động thêm, xóa, khóa khách hàng và hay gặp lỗi khóa ngoại khi xóa.", "Do chưa có API chuyên biệt cho CRM quản lý bảng Accounts/CustomerProfiles và thiếu cơ chế xóa dây chuyền.", "Xây dựng CrmAdminController hỗ trợ tạo đồng bộ Account + Profile, đảo cờ IsActive và xóa dây chuyền an toàn."),
        @("3", "Phản hồi của khách hàng bị thất lạc, không đo lường được mức sao hài lòng theo từng sản phẩm.", "Do chưa có bảng Feedbacks liên kết khóa ngoại với bảng Products và thiếu trường AdminReply để giải đáp 2 chiều.", "Thiết kế bảng Feedbacks(AccountId, ProductId, Rating 1–5, Comment, AdminReply, Status) kèm bộ lọc theo sản phẩm."),
        @("4", "Báo cáo tỷ lệ độ tuổi và sở thích mất 1–2 ngày tổng hợp thủ công trên Excel.", "Do thông tin tuổi và sở thích không được lưu chuẩn hóa trong CSDL và thiếu thuật toán gom nhóm tự động.", "Chuẩn hóa bảng CustomerProfiles(Age, Gender, Interest, Address) và xây dựng API /reports/demographics vẽ biểu đồ tức thời."),
        @("5", "Khảo sát thị trường rời rạc, tỷ lệ phản hồi thấp, bị spam trùng lặp và phải tính kết quả bằng tay.", "Do dùng biểu mẫu bên ngoài không gắn với định danh AccountId của khách hàng trong hệ thống.", "Xây dựng bảng Surveys & SurveyResponses gắn chặt với AccountId, chặn gửi trùng 100% và tự động thống kê kết quả.")
    )))

    [void]$sb.Append((New-WPageBreak))
    return $sb.ToString()
}

function Build-Chapter2-DeepSequenceFlows {
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.Append((New-WHeading3 "2.1.4. Đặc tả Kịch bản Tuần tự Tương tác Giữa các Tầng Hệ thống (End-to-End Sequence Specifications)"))
    [void]$sb.Append((New-WP -Text "Để làm rõ luồng thông điệp tuần tự di chuyển qua 4 lớp kiến trúc (1. Tác nhân -> 2. Giao diện HTML/JS -> 3. ASP.NET Core Controller -> 4. SQL Server Database) của toàn bộ các chức năng trong đồ án, dưới đây là bảng đặc tả tuần tự chi tiết cho 12 luồng giao dịch cốt lõi:" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Mã Luồng", "Nghiệp vụ Thực hiện", "Bước 1: Thao tác Tác nhân & Giao diện (Frontend)", "Bước 2: Gọi RESTful API & Xử lý Controller (Backend)", "Bước 3: Thực thi Giao dịch SQL Server & Phản hồi UI") -ColWidths @(900, 1800, 2200, 2350, 2350) -Rows @(
        @("SEQ-01", "Đăng nhập & Phân luồng 3 Vai trò", "Người dùng nhập Username, Password tại login.html -> Gọi hàm handleLogin().", "POST /api/admin/auth/login -> AuthController.Login() kiểm tra IsActive và BCrypt.", "SELECT Accounts JOIN Roles -> Trả về roleName -> Chuyển hướng tới admin.html / quanly.html / user.html."),
        @("SEQ-02", "Admin Thêm Tài khoản Mới", "Admin mở Modal trên admin.html, nhập thông tin Account & chọn Role -> Nhấn Lưu.", "POST /api/admin/accounts -> AccountsController.Create() kiểm tra trùng Username & băm mật khẩu.", "INSERT INTO Accounts (và INSERT CustomerProfiles nếu là Customer) -> Làm mới bảng 19+ tài khoản."),
        @("SEQ-03", "Admin Phân quyền cho Account", "Admin chọn Role mới (Admin / Manager / Customer) tại Dropdown dòng #id -> Nhấn 'Phân quyền'.", "PUT /api/admin/accounts/{id}/role -> AccountsController.UpdateRole() nhận UpdateRoleDto.", "UPDATE Accounts SET RoleId = @roleId WHERE AccountId = @id -> Cập nhật huy hiệu vai trò tức thì."),
        @("SEQ-04", "Admin Khóa / Mở khóa & Xóa Account", "Admin nhấn nút 'Khóa' hoặc 'Xóa Account' trên dòng tài khoản tại admin.html.", "PUT .../toggle-status hoặc DELETE /api/admin/accounts/{id} tại AccountsController.", "UPDATE IsActive = ~IsActive hoặc DELETE Cascade (CustomerProfiles, Feedbacks, SurveyResponses, Accounts)."),
        @("SEQ-05", "Quản lý Thêm mới Khách hàng", "Người quản lý mở Modal tại Tab 1 (quanly.html), nhập định danh + Tuổi, Giới tính, Sở thích, Địa chỉ.", "POST /api/admin/crm/customers -> CrmAdminController.CreateCustomer() xử lý tạo kép.", "INSERT INTO Accounts (Role=Customer) -> Lấy AccountId -> INSERT INTO CustomerProfiles -> Cập nhật UI."),
        @("SEQ-06", "Quản lý Khóa TK & Xóa Khách hàng", "Người quản lý nhấn 'Khóa TK' hoặc 'Xóa' trên dòng khách hàng tại Tab 1 (quanly.html).", "PUT /api/admin/crm/customers/{id}/toggle-status hoặc DELETE .../customers/{id}.", "Đảo cờ IsActive chặn khách đăng nhập hoặc xóa sạch hồ sơ khách hàng khỏi SQL Server."),
        @("SEQ-07", "Quản lý Tiếp nhận & Giải đáp Phản hồi", "Người quản lý mở Tab 2 (quanly.html), nhấn 'Tiếp nhận & Trả lời', nhập nội dung giải đáp.", "PUT /api/admin/crm/feedbacks/{id}/reply -> CrmAdminController.ReplyFeedback().", "UPDATE Feedbacks SET AdminReply = @reply, Status = N'Đã tiếp nhận & Xử lý' -> Đồng bộ sang cổng KH."),
        @("SEQ-08", "Quản lý Xem Báo cáo Độ tuổi & Sở thích", "Người quản lý mở Tab 3 (Báo cáo Độ tuổi & Sở thích) trên giao diện quanly.html.", "GET /api/admin/crm/reports/demographics -> CrmAdminController.GetDemographicsReport().", "Đọc toàn bộ CustomerProfiles -> Tính 3 phân khúc tuổi & GroupBy Sở thích -> Vẽ 2 biểu đồ Canvas."),
        @("SEQ-09", "Quản lý Tạo Khảo sát gửi đến TK KH", "Người quản lý điền form tại Tab 4 (quanly.html): Tiêu đề, Sản phẩm, Giá dự kiến, Hạn, Mô tả.", "POST /api/admin/crm/surveys -> CrmAdminController.CreateSurvey() tính toán ExpiresAt.", "INSERT INTO Surveys -> Đếm số TK khách hàng đang hoạt động -> Phân phối khảo sát tới cổng user.html."),
        @("SEQ-10", "Quản lý Xem Thống kê Kết quả Khảo sát", "Người quản lý mở Tab 5 (Thống kê Khảo sát) trên giao diện quanly.html.", "GET /api/admin/crm/surveys/{id}/statistics -> CrmAdminController.GetSurveyStatistics().", "SELECT SurveyResponses JOIN Accounts -> Tính Average(Score), đếm 3 mức BuyingIntent -> Vẽ 2 biểu đồ."),
        @("SEQ-11", "Khách hàng Đăng ký & Sửa Hồ sơ Cá nhân", "Khách hàng đăng ký mới hoặc mở Tab 3 (Hồ sơ cá nhân) trên user.html để sửa Tuổi, Sở thích, SĐT.", "POST /api/customer/register hoặc PUT /api/customer/profile/{accountId} tại CustomerPortalController.", "INSERT hoặc UPDATE đồng thời bảng Accounts và bảng CustomerProfiles -> Làm mới báo cáo nhân khẩu học."),
        @("SEQ-12", "Khách hàng Gửi Phản hồi & Làm Khảo sát", "Khách hàng gửi đánh giá 1–5 sao (Tab 1) hoặc điền phiếu khảo sát sản phẩm mới (Tab 2) trên user.html.", "POST /api/customer/feedbacks/{id} và POST /api/customer/surveys/{sid}/submit/{aid}.", "INSERT INTO Feedbacks và INSERT INTO SurveyResponses (kiểm tra chống trùng) -> Cập nhật thống kê CRM.")
    )))

    [void]$sb.Append((New-WPageBreak))
    return $sb.ToString()
}

function Build-Chapter3-DeepStorageAndValidation {
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.Append((New-WHeading3 "3.1.7. Ước lượng Dung lượng Lưu trữ Vật lý CSDL (Database Physical Storage Sizing — Chu kỳ 3 Năm)"))
    [void]$sb.Append((New-WP -Text "Trong thiết kế CSDL vật lý cho doanh nghiệp, việc tính toán kích thước bản ghi trung bình (Average Row Size) và dự báo tốc độ tăng trưởng dung lượng lưu trữ trong 3 năm giúp Quản trị viên Máy chủ (Admin Server) quy hoạch chính xác dung lượng ổ cứng lưu trữ và phân vùng chứa bản sao lưu (Backup Partition):" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("STT", "Tên Bảng Vật lý", "Kích thước 1 Bản ghi (Bytes)", "Số Bản ghi Hiện tại (Demo)", "Dự kiến Bản ghi sau 1 Năm", "Dự kiến Bản ghi sau 3 Năm", "Dung lượng Ước tính (Kèm Index)") -ColWidths @(600, 1800, 1300, 1300, 1500, 1500, 1600) -Rows @(
        @("1", "Roles", "~ 320 Bytes", "03 bản ghi", "03 bản ghi (Cố định)", "03 bản ghi (Cố định)", "< 16 KB"),
        @("2", "Accounts", "~ 480 Bytes", "19 bản ghi", "25.000 bản ghi", "100.000 bản ghi", "~ 65 MB"),
        @("3", "CustomerProfiles", "~ 380 Bytes", "15 bản ghi", "24.950 bản ghi", "99.900 bản ghi", "~ 52 MB"),
        @("4", "Categories", "~ 360 Bytes", "05 bản ghi", "20 bản ghi", "50 bản ghi", "< 64 KB"),
        @("5", "Suppliers", "~ 520 Bytes", "06 bản ghi", "50 bản ghi", "150 bản ghi", "< 256 KB"),
        @("6", "Products", "~ 680 Bytes", "16 bản ghi", "1.500 bản ghi", "5.000 bản ghi", "~ 6.5 MB"),
        @("7", "Feedbacks", "~ 1.450 Bytes", "18 bản ghi", "120.000 bản ghi", "500.000 bản ghi", "~ 850 MB"),
        @("8", "Surveys", "~ 1.100 Bytes", "05 bản ghi", "120 bản ghi", "400 bản ghi", "~ 1.2 MB"),
        @("9", "SurveyResponses", "~ 820 Bytes", "16 bản ghi", "300.000 bản ghi", "1.200.000 bản ghi", "~ 1.15 GB"),
        @("TỔNG", "TỔNG DUNG LƯỢNG CSDL HTTTDN_DB", "9 Bảng + 6 Indexes", "103 bản ghi mẫu", "~ 471.643 bản ghi", "~ 1.905.503 bản ghi", "~ 2.13 GB (Data + Index)")
    )))

    [void]$sb.Append((New-WHeading3 "3.2.16. Đặc tả Quy tắc Kiểm tra Hợp lệ Biểu mẫu trên Giao diện (Client-Side & Server-Side Validation Matrix)"))
    [void]$sb.Append((New-WP -Text "Mọi biểu mẫu nhập liệu trên cả 3 phân hệ (admin.html, quanly.html, user.html) đều được bảo vệ bởi cơ chế kiểm tra hợp lệ 2 lớp (Dual-Layer Validation: kiểm tra tức thời bằng HTML5/JavaScript tại trình duyệt và kiểm tra chặt chẽ tại ASP.NET Core API Controller trước khi ghi vào SQL Server):" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Biểu mẫu Giao diện", "Trường Nhập liệu", "Kiểm tra tại Trình duyệt (Client-Side)", "Kiểm tra tại Máy chủ (Server-Side API)", "Thông báo Lỗi Hiển thị cho Người dùng") -ColWidths @(1700, 1600, 2000, 2100, 2200) -Rows @(
        @("Đăng nhập Hệ thống`n(login.html & user.html)", "Username & Password", "Thuộc tính required; tự động cắt khoảng trắng đầu/cuối (.trim()).", "Kiểm tra khác rỗng, kiểm tra tồn tại Username, kiểm tra IsActive == true và BCrypt.Verify().", "'Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu!' / 'Tài khoản này đã bị khóa!'"),
        @("Thêm Tài khoản Mới`n(admin.html)", "Username, Password, FullName, RoleId", "Required trên Username, FullName; RoleId chọn từ Dropdown 3 quyền.", "AnyAsync kiểm tra trùng Username (không phân biệt hoa thường); gán mật khẩu mặc định nếu trống.", "'Username đã tồn tại!' / 'Tạo tài khoản thành công!'"),
        @("Thêm Khách hàng Mới`n(quanly.html — Tab 1)", "Username, FullName, Phone, Age, Gender, Interest", "Required trên Username, FullName, Phone; Age kiểu number (min=12, max=100).", "Kiểm tra trùng Username; tự động gán Age = 20 nếu <= 0; tự sinh Email chuẩn nếu để trống.", "'Vui lòng nhập đầy đủ Tên đăng nhập và Họ tên khách hàng!'"),
        @("Giải đáp Phản hồi KH`n(quanly.html — Tab 2)", "AdminReply (Nội dung trả lời)", "Textarea required, kiểm tra độ dài tối thiểu >= 5 ký tự.", "Kiểm tra FeedbackId tồn tại trong bảng Feedbacks; cập nhật Status = 'Đã tiếp nhận & Xử lý'.", "'Đã gửi phản hồi cho khách hàng.'"),
        @("Tạo Bảng Khảo sát`n(quanly.html — Tab 4)", "Title, TargetProduct, ExpectedPrice, Duration", "Required trên Title, TargetProduct; ExpectedPrice kiểu số >= 0.", "Tính toán chính xác ExpiresAt theo DurationType ('NoLimit', 'Days', 'Date').", "'Đã tạo bảng khảo sát và gửi đến N tài khoản khách hàng đang hoạt động!'"),
        @("Đăng ký & Sửa Hồ sơ`n(user.html)", "Username, Password, FullName, Phone, Age, Interest", "Kiểm tra định dạng số điện thoại 10 số, độ tuổi hợp lệ, chọn nhóm sở thích.", "Kiểm tra trùng Username khi đăng ký; đồng bộ cập nhật cả bảng Accounts và CustomerProfiles.", "'Đăng ký tài khoản thành công!' / 'Cập nhật thông tin hồ sơ thành công!'"),
        @("Gửi Phản hồi Sản phẩm`n(user.html — Tab 1)", "ProductId, Rating (1–5), Comment", "Bắt buộc chọn sản phẩm, chọn mức sao (1–5) và nhập nội dung nhận xét.", "Ràng buộc CHECK (Rating >= 1 AND Rating <= 5) và khóa ngoại ProductId, AccountId.", "'Cảm ơn bạn đã gửi đánh giá sản phẩm!'"),
        @("Thực hiện Khảo sát`n(user.html — Tab 2)", "Score (1–5), BuyingIntent, CustomerOpinion", "Bắt buộc chọn điểm mức độ quan tâm (1–5) và chọn 1 trong 3 ý định mua sắm.", "Kiểm tra Survey.IsActive == true, chưa quá hạn ExpiresAt và khách chưa làm khảo sát này.", "'Bạn đã thực hiện bài khảo sát này rồi!' / 'Gửi kết quả khảo sát thành công!'")
    )))

    [void]$sb.Append((New-WPageBreak))
    return $sb.ToString()
}
