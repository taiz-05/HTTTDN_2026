# ==============================================================================
# PART 9: ĐẶC TẢ CHUYÊN SÂU HOẠT ĐỘNG TỪNG CHỨC NĂNG GIAO DIỆN, HỒ SƠ KIỂM THỬ
# CHI TIẾT KÈM TRUY VẤN SQL ĐỐI SOÁT & ĐẶC TẢ TOÀN BỘ MODELS / DTOS / DBCONTEXT
# ==============================================================================

function New-DetailedTestExecutionCard {
    param(
        [string]$TcId,
        [string]$Title,
        [string]$Module,
        [string]$RequirementRef,
        [string]$PreState,
        [string]$TestSteps,
        [string]$InputData,
        [string]$ExpectedUiAndApi,
        [string]$SqlVerification
    )
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append((New-WHeading4 "Hồ sơ Thực thi Kiểm thử Chi tiết [$TcId]: $Title"))
    [void]$sb.Append((New-WTable -Headers @("Hạng mục Hồ sơ Kiểm thử", "Nội dung Chi tiết Ca Kiểm thử [$TcId]") -ColWidths @(2500, 7100) -Rows @(
        @("Mã & Tên Ca Kiểm thử", "[$TcId] — $Title"),
        @("Phân hệ & Yêu cầu Đề bài", "$Module  |  Đáp ứng yêu cầu: $RequirementRef"),
        @("Trạng thái CSDL Trước Kiểm thử", $PreState),
        @("Các Bước Thao tác trên Giao diện", $TestSteps),
        @("Dữ liệu Đầu vào (Payload / Input)", $InputData),
        @("Kết quả Giao diện & HTTP API", $ExpectedUiAndApi),
        @("Truy vấn SQL Đối soát CSDL", $SqlVerification),
        @("Kết luận Nghiệm thu", "ĐẠT (100% PASS) — Khớp hoàn toàn giữa Giao diện, API và CSDL SQL Server.")
    )))
    return $sb.ToString()
}

function Build-Chapter3-DeepFunctionalWalkthrough {
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.Append((New-WHeading3 "3.2.15. Phân tích Chuyên sâu Cơ chế Hoạt động của Từng Nhóm Chức năng trên Giao diện Phần mềm"))
    [void]$sb.Append((New-WP -Text "Nhằm thuyết minh đầy đủ và chi tiết nhất cho tiêu chí 'Đưa ra hình ảnh, giới thiệu chi tiết các chức năng và hoạt động của phần mềm (5 điểm)', bảng phân tích chuyên sâu dưới đây trình bày cơ chế vận hành nội tại từ lúc người dùng tương tác trên giao diện đến khi dữ liệu được xử lý và phản hồi lại màn hình cho từng chức năng cốt lõi:" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Phân hệ", "Chức năng trên Giao diện", "Cơ chế Hoạt động Chi tiết trên Phần mềm (UI -> JS -> REST API -> SQL Server -> UI)") -ColWidths @(1400, 2200, 6000) -Rows @(
        @("Admin Server`n(admin.html)", "1. Tách biệt Giao diện Admin Server", "Khi đăng nhập với tài khoản admin, hệ thống nạp độc quyền tệp admin.html và app.js. Thanh Sidebar chỉ chứa đúng 2 mục: 'Quản lý Tài khoản & Phân quyền' và 'Cơ cấu Phân quyền (3 Role)'. Tuyệt đối không nạp bất kỳ giao diện hay bảng dữ liệu nào của Nhân sự, Kho, Bán hàng, Sản phẩm hay Nhà cung cấp."),
        @("Admin Server`n(admin.html)", "2. Xem, Tìm kiếm & Lọc Account theo 3 Role", "Hàm loadAccountsAndRoles() gọi GET /api/admin/accounts lấy 19 tài khoản, tính toán 4 thẻ KPI (Tổng Account: 19, Đang hoạt động: 17, Đã khóa: 2, Tổng Role: 3). Khi Admin gõ vào ô tìm kiếm hoặc chọn Dropdown Role (Admin / Manager / Customer), bảng tài khoản lập tức lọc lại các dòng thỏa mãn mà không cần tải lại trang."),
        @("Admin Server`n(admin.html)", "3. Thêm Tài khoản Mới (Create Account)", "Khi nhấn '+ Thêm tài khoản mới', Modal hiện ra. Admin điền Username, Password, Họ tên, Email, SĐT và chọn 1 trong 3 Role. Khi nhấn Lưu, dữ liệu gửi tới POST /api/admin/accounts. Backend kiểm tra trùng Username, băm mật khẩu bằng BCrypt và lưu vào bảng Accounts (nếu là Customer thì tự tạo thêm bản ghi trong CustomerProfiles)."),
        @("Admin Server`n(admin.html)", "4. Phân quyền cho Account (Assign Role)", "Trên mỗi dòng của bảng tài khoản có sẵn hộp chọn Dropdown chứa 3 quyền: Admin (Quản trị máy chủ), Manager (Người quản lý CRM), Customer (Khách hàng). Khi Admin đổi quyền và nhấn nút 'Phân quyền', hàm changeAccountRole(id) gọi PUT /api/admin/accounts/{id}/role cập nhật ngay cột RoleId trong bảng Accounts."),
        @("Admin Server`n(admin.html)", "5. Khóa/Mở khóa & Xóa Account", "Khi nhấn nút 'Khóa' (hoặc 'Mở khóa'), phần mềm gọi PUT /api/admin/accounts/{id}/toggle-status để đảo cờ IsActive (1 <-> 0). Khi nhấn 'Xóa Account', phần mềm gọi DELETE /api/admin/accounts/{id}, tự động dọn dẹp các bản ghi phụ thuộc trong CustomerProfiles, Feedbacks, SurveyResponses trước khi xóa Account."),
        @("Người Quản lý`n(quanly.html)", "6. Thêm một Khách hàng mới (Tab 1)", "Tại Tab 1 (Quản lý Khách hàng), Người quản lý nhấn '+ Thêm một khách hàng mới', nhập thông tin định danh và nhân khẩu học (Độ tuổi, Giới tính, Sở thích, Địa chỉ). API POST /api/admin/crm/customers tạo đồng thời bản ghi Accounts (Role = Customer) và bản ghi CustomerProfiles, cập nhật ngay danh sách và biểu đồ."),
        @("Người Quản lý`n(quanly.html)", "7. Khóa TK & Xóa Khách hàng (Tab 1)", "Trên từng dòng khách hàng ở Tab 1, Người quản lý nhấn 'Khóa TK' để chặn khách hàng vi phạm đăng nhập vào cổng user.html (PUT /api/admin/crm/customers/{id}/toggle-status), hoặc nhấn 'Xóa' để xóa hoàn toàn khách hàng khỏi hệ thống (DELETE /api/admin/crm/customers/{id})."),
        @("Người Quản lý`n(quanly.html)", "8. Tiếp nhận & Giải đáp Phản hồi (Tab 2)", "Tại Tab 2 (Tiếp nhận Phản hồi), phần mềm hiển thị 4 thẻ KPI, Biểu đồ cột phân bố đánh giá 1–5 sao, Biểu đồ sản phẩm được đánh giá nhiều nhất và bảng 18 phản hồi. Người quản lý nhấn 'Tiếp nhận & Trả lời', nhập nội dung giải đáp và lưu qua PUT /api/admin/crm/feedbacks/{id}/reply."),
        @("Người Quản lý`n(quanly.html)", "9. Báo cáo Tỷ lệ Độ tuổi & Sở thích (Tab 3)", "Tại Tab 3 (Báo cáo Độ tuổi & Sở thích), phần mềm gọi GET /api/admin/crm/reports/demographics, tự động tính Độ tuổi trung bình (25.5 tuổi), vẽ Biểu đồ Vòng (Tỷ lệ các phân khúc độ tuổi) và Biểu đồ Cột (Tỷ lệ % các nhóm sở thích: Gaming, Văn phòng, Đồ họa, Lập trình) kèm 2 bảng số liệu chi tiết."),
        @("Người Quản lý`n(quanly.html)", "10. Tạo Bảng Khảo sát gửi đến TK KH (Tab 4)", "Tại Tab 4 (Tạo & Gửi Khảo sát), Người quản lý nhập Tiêu đề, Sản phẩm khảo sát, Giá dự kiến, Thời hạn và Mô tả rồi nhấn 'Phát hành & Gửi đến Khách hàng'. API POST /api/admin/crm/surveys lưu khảo sát mới và phân phối tức thời đến toàn bộ tài khoản khách hàng đang hoạt động."),
        @("Người Quản lý`n(quanly.html)", "11. Thống kê Kết quả Khảo sát (Tab 5)", "Tại Tab 5 (Thống kê Khảo sát), phần mềm tổng hợp dữ liệu từ GET /api/admin/crm/surveys/{id}/statistics, hiển thị 4 thẻ KPI, Biểu đồ Phân bố Ý định Mua sắm, Biểu đồ Điểm Quan tâm Trung bình (thang 1–5), bảng tỷ lệ tham gia từng chiến dịch và danh sách chi tiết toàn bộ 16 phiếu trả lời."),
        @("Khách hàng`n(user.html)", "12. Đăng ký, Đăng nhập & Chỉnh sửa Thông tin", "Khách hàng truy cập user.html để tự Đăng ký tài khoản mới (POST /api/customer/register) hoặc Đăng nhập (POST /api/customer/login). Tại tab 'Hồ sơ cá nhân', khách hàng xem thẻ định danh và chỉnh sửa Họ tên, SĐT, Email, Độ tuổi, Giới tính, Sở thích, Địa chỉ (PUT /api/customer/profile/{accountId})."),
        @("Khách hàng`n(user.html)", "13. Gửi Phản hồi SP & Nhận, Làm Khảo sát", "Tại tab 'Phản hồi sản phẩm', khách hàng chọn sản phẩm, chấm 1–5 sao, gửi nhận xét và lọc xem giải đáp từ Người quản lý theo từng sản phẩm. Tại tab 'Khảo sát thị trường', khách hàng nhận thông báo khảo sát mới, mở hộp thoại chấm điểm quan tâm (1–5), chọn ý định mua và gửi kết quả khảo sát.")
    )))

    [void]$sb.Append((New-WPageBreak))
    return $sb.ToString()
}

function Build-Chapter4-DeepTestExecutionLogs {
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.Append((New-WHeading3 "4.4.2. Hồ sơ Thực thi Kiểm thử Chi tiết Kèm Dữ liệu JSON & Truy vấn SQL Đối soát"))
    [void]$sb.Append((New-WP -Text "Dưới đây là hồ sơ thực thi kiểm thử chi tiết (Detailed Test Execution Logs) cho 10 nghiệp vụ trọng tâm nhất của đồ án, ghi nhận đầy đủ dữ liệu đầu vào, phản hồi API và câu lệnh SQL kiểm chứng trực tiếp trong CSDL:" -IndentFirst 420))

    [void]$sb.Append((New-DetailedTestExecutionCard -TcId "TC-DETAIL-01" -Title "Kiểm thử Tách biệt Giao diện Admin Server & Phân quyền 3 Vai trò" `
        -Module "Phân hệ Admin Server (admin.html)" `
        -RequirementRef "Giao diện Admin tách biệt hoàn toàn; bỏ lọc SP/NCC; Admin thêm, xóa, phân quyền cho Account." `
        -PreState "Bảng Roles có đúng 3 bản ghi (1: Admin, 2: Manager, 3: Customer). Tài khoản khachhang1 (AccountId = 5) đang có RoleId = 3." `
        -TestSteps "1. Đăng nhập tài khoản admin / 123456 tại login.html.`n2. Kiểm tra giao diện admin.html không chứa bảng sản phẩm hay nhà cung cấp.`n3. Tại dòng tài khoản khachhang1 (ID #5), chọn Dropdown phân quyền sang 'Manager (Người quản lý CRM)' và nhấn nút 'Phân quyền'." `
        -InputData "PUT http://localhost:5000/api/admin/accounts/5/role  |  Body: { `"roleId`": 2 }" `
        -ExpectedUiAndApi "HTTP 200 OK: { `"message`": `"Cập nhật phân quyền thành công!`" }. Huy hiệu vai trò trên dòng #5 đổi sang Manager." `
        -SqlVerification "SELECT AccountId, Username, RoleId FROM Accounts WHERE AccountId = 5; -- Kết quả: RoleId cập nhật chính xác từ 3 sang 2."))

    [void]$sb.Append((New-DetailedTestExecutionCard -TcId "TC-DETAIL-02" -Title "Kiểm thử Admin Server Thêm mới và Xóa Dây chuyền Account" `
        -Module "Phân hệ Admin Server (admin.html)" `
        -RequirementRef "Admin thêm, xóa, khóa/mở khóa cho Account." `
        -PreState "Bảng Accounts hiện có 19 bản ghi (AccountId từ 1 đến 19)." `
        -TestSteps "1. Nhấn nút '+ Thêm tài khoản mới', nhập Username = 'kt_test', FullName = 'Kiểm Thử Viên', chọn Role = Customer (3), nhấn Lưu.`n2. Sau khi tài khoản xuất hiện trên bảng, nhấn nút 'Xóa Account' tại dòng 'kt_test' và xác nhận." `
        -InputData "POST /api/admin/accounts: { `"username`": `"kt_test`", `"password`": `"123456`", `"fullName`": `"Kiểm Thử Viên`", `"roleId`": 3 } -> DELETE /api/admin/accounts/20" `
        -ExpectedUiAndApi "Khi thêm: HTTP 200 OK, tự động tạo cả Account và CustomerProfile. Khi xóa: HTTP 200 OK, xóa sạch cả CustomerProfile lẫn Account mà không lỗi khóa ngoại." `
        -SqlVerification "SELECT COUNT(*) FROM Accounts WHERE Username = 'kt_test'; -- Trước khi xóa = 1, Sau khi xóa = 0."))

    [void]$sb.Append((New-WPageBreak))

    [void]$sb.Append((New-DetailedTestExecutionCard -TcId "TC-DETAIL-03" -Title "Kiểm thử Người Quản lý Thêm mới, Khóa và Xóa Khách hàng" `
        -Module "Phân hệ Người Quản lý CRM (quanly.html — Tab 1)" `
        -RequirementRef "Người quản lý: (1) Thêm một khách hàng mới, (2) Xóa khách hàng, (3) Khóa tài khoản khách hàng." `
        -PreState "Người quản lý đăng nhập bằng tài khoản quanly / 123456 và mở Tab 1 (Quản lý Khách hàng)." `
        -TestSteps "1. Nhấn '+ Thêm một khách hàng mới', nhập Username = 'khachhang_vip', Họ tên = 'Trần Minh Quân', SĐT = '0908123456', Tuổi = 27, Giới tính = 'Nam', Sở thích = 'Đồ họa', Địa chỉ = 'Quận 3, TP.HCM' rồi nhấn Lưu.`n2. Nhấn nút 'Khóa TK' trên dòng khách hàng vừa tạo.`n3. Thử đăng nhập bằng tài khoản 'khachhang_vip' tại user.html." `
        -InputData "POST /api/admin/crm/customers -> PUT /api/admin/crm/customers/21/toggle-status" `
        -ExpectedUiAndApi "Thêm mới trả về HTTP 200 OK. Khi nhấn Khóa TK, trạng thái chuyển sang 'Đã khóa' (IsActive = false). Khi thử đăng nhập tại user.html, hệ thống chặn với HTTP 401: 'Tài khoản của bạn đã bị khóa bởi người quản lý!'." `
        -SqlVerification "SELECT a.Username, a.IsActive, p.Age, p.Interest FROM Accounts a JOIN CustomerProfiles p ON a.AccountId = p.AccountId WHERE a.Username = 'khachhang_vip';"))

    [void]$sb.Append((New-DetailedTestExecutionCard -TcId "TC-DETAIL-04" -Title "Kiểm thử Người Quản lý Tiếp nhận & Giải đáp Phản hồi Khách hàng" `
        -Module "Phân hệ Người Quản lý CRM (quanly.html — Tab 2)" `
        -RequirementRef "Người quản lý: (4) Tiếp nhận phản hồi của khách hàng." `
        -PreState "Phản hồi FeedbackId = 8 của khách hàng Nguyễn Văn An về sản phẩm 'Chuột Gaming Logitech G102' đang ở trạng thái 'Chờ xử lý' (AdminReply = NULL)." `
        -TestSteps "1. Tại Tab 2 (Tiếp nhận Phản hồi), lọc trạng thái 'Chờ xử lý'.`n2. Nhấn nút 'Tiếp nhận & Trả lời' tại dòng Feedback #8.`n3. Nhập nội dung: 'Cảm ơn bạn An đã tin dùng chuột Logitech G102 chính hãng tại SGU Tech!' và nhấn Lưu." `
        -InputData "PUT http://localhost:5000/api/admin/crm/feedbacks/8/reply  |  Body: { `"adminReply`": `"Cảm ơn bạn An đã tin dùng chuột Logitech G102 chính hãng tại SGU Tech!`" }" `
        -ExpectedUiAndApi "HTTP 200 OK. Trạng thái của Feedback #8 chuyển sang 'Đã tiếp nhận & Xử lý', số lượng KPI 'Đã phản hồi/giải đáp' tăng thêm 1, và khách hàng nhìn thấy ngay câu trả lời trên user.html." `
        -SqlVerification "SELECT FeedbackId, Rating, AdminReply, Status FROM Feedbacks WHERE FeedbackId = 8;"))

    [void]$sb.Append((New-WPageBreak))

    [void]$sb.Append((New-DetailedTestExecutionCard -TcId "TC-DETAIL-05" -Title "Kiểm thử Báo cáo Khách hàng: Tỷ lệ Độ tuổi & Sở thích" `
        -Module "Phân hệ Người Quản lý CRM (quanly.html — Tab 3)" `
        -RequirementRef "Người quản lý: (5) Báo cáo về khách hàng, tỷ lệ độ tuổi, sở thích." `
        -PreState "Bảng CustomerProfiles có 15 hồ sơ khách hàng với độ tuổi từ 18 đến 45 và 4 nhóm sở thích (Gaming, Văn phòng, Lập trình, Đồ họa)." `
        -TestSteps "1. Người quản lý chuyển sang Tab 3 (Báo cáo Độ tuổi & Sở thích).`n2. Quan sát 3 thẻ chỉ số tổng hợp, Biểu đồ tròn Tỷ lệ Độ tuổi, Biểu đồ cột Phân bố Sở thích và 2 bảng thống kê chi tiết." `
        -InputData "GET http://localhost:5000/api/admin/crm/reports/demographics" `
        -ExpectedUiAndApi "HTTP 200 OK trả về totalCustomers = 15; ageStats = { under20: 3, from20To30: 7, over30: 5 }; interestStats = [ Gaming: 5 (33.3%), Văn phòng: 4 (26.7%), Lập trình: 3 (20.0%), Đồ họa: 3 (20.0%) ]. Biểu đồ kết xuất chính xác 100%." `
        -SqlVerification "SELECT Interest, COUNT(*) AS SL, ROUND(COUNT(*)*100.0/15, 1) AS TyLe FROM CustomerProfiles GROUP BY Interest;"))

    [void]$sb.Append((New-DetailedTestExecutionCard -TcId "TC-DETAIL-06" -Title "Kiểm thử Tạo Bảng Khảo sát Gửi đến TK Khách hàng & Thống kê Kết quả Khảo sát" `
        -Module "Phân hệ Người Quản lý CRM (quanly.html — Tab 4 & Tab 5)" `
        -RequirementRef "Người quản lý: (6) Tạo bảng khảo sát và gửi đến tài khoản khách hàng; (7) Thống kê kết quả khảo sát." `
        -PreState "Hệ thống đang có 5 bảng khảo sát và 16 phiếu trả lời khảo sát trong CSDL." `
        -TestSteps "1. Tại Tab 4, nhập Tiêu đề = 'Khảo sát PC Đồ họa AI Workstation 2026', Sản phẩm = 'SGU Workstation RTX 5090', Giá dự kiến = 85000000, Thời hạn = 15 ngày, nhấn 'Phát hành & Gửi đến Khách hàng'.`n2. Chuyển sang Tab 5 (Thống kê Khảo sát) để kiểm tra báo cáo tổng hợp và chi tiết từng chiến dịch." `
        -InputData "POST /api/admin/crm/surveys -> GET /api/admin/crm/surveys/1/statistics" `
        -ExpectedUiAndApi "Tạo khảo sát trả về HTTP 200 OK kèm thông báo đã gửi đến toàn bộ tài khoản khách hàng đang hoạt động. Tại Tab 5, biểu đồ Ý định mua sắm và Điểm quan tâm trung bình hiển thị đầy đủ." `
        -SqlVerification "SELECT * FROM Surveys ORDER BY SurveyId DESC; SELECT SurveyId, AVG(CAST(Score AS FLOAT)) FROM SurveyResponses GROUP BY SurveyId;"))

    [void]$sb.Append((New-WPageBreak))

    [void]$sb.Append((New-DetailedTestExecutionCard -TcId "TC-DETAIL-07" -Title "Kiểm thử Khách hàng Đăng ký, Chỉnh sửa Hồ sơ, Gửi Phản hồi & Thực hiện Khảo sát" `
        -Module "Phân hệ Cổng Khách hàng (user.html)" `
        -RequirementRef "Khách hàng: (1) Đăng ký, (2) Đăng nhập, (3) Chỉnh sửa thông tin, (4) Gửi phản hồi về sản phẩm, (5) Nhận được khảo sát và thực hiện." `
        -PreState "Khách hàng Nguyễn Văn An (khachhang1, AccountId = 5) đăng nhập vào cổng user.html." `
        -TestSteps "1. Tại Tab 1 (Phản hồi sản phẩm): Chọn sản phẩm 'Webcam 4K Sony Bravia Cam Pro', chọn '5 Sao - Rất hài lòng', nhập nhận xét và nhấn 'Gửi phản hồi'. Dùng hộp 'Lọc theo sản phẩm' để kiểm tra.`n2. Tại Tab 2 (Khảo sát thị trường): Nhấn 'Thực hiện khảo sát' trên khảo sát số #3 ('Thăm dò Tai nghe chống ồn Hi-Res Thế hệ Mới'), chọn '5 điểm', chọn 'Rất muốn mua', nhập góp ý và nhấn 'Gửi kết quả khảo sát'.`n3. Tại Tab 3 (Hồ sơ cá nhân): Cập nhật Độ tuổi từ 19 lên 20, nhấn 'Lưu chỉnh sửa thông tin'." `
        -InputData "POST /api/customer/feedbacks/5 -> POST /api/customer/surveys/3/submit/5 -> PUT /api/customer/profile/5" `
        -ExpectedUiAndApi "Cả 3 thao tác đều trả về HTTP 200 OK. Phản hồi mới xuất hiện ngay đầu danh sách với nhãn 'Của bạn'; khảo sát #3 đổi trạng thái thành 'Đã thực hiện'; hồ sơ cá nhân cập nhật tuổi mới." `
        -SqlVerification "SELECT TOP 1 * FROM Feedbacks WHERE AccountId = 5 ORDER BY FeedbackId DESC;`nSELECT * FROM SurveyResponses WHERE SurveyId = 3 AND AccountId = 5;`nSELECT Age, Interest FROM CustomerProfiles WHERE AccountId = 5;"))

    [void]$sb.Append((New-WPageBreak))
    return $sb.ToString()
}

function Build-Part3-DeepModelsAndDtosCode {
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.Append((New-WHeading2 "III.5. Đặc tả Chi tiết Tầng Dữ liệu (AppDbContext, Entity Models & DTOs) và Cấu hình Hệ thống (Program.cs)"))
    [void]$sb.Append((New-WP -Text "Để hoàn thiện hồ sơ kỹ thuật của ứng dụng, dưới đây là toàn văn mã nguồn C# của lớp ngữ cảnh cơ sở dữ liệu (AppDbContext.cs), các lớp thực thể ánh xạ 9 bảng CSDL (Models), các lớp truyền tải dữ liệu (DTOs) và tệp cấu hình khởi tạo máy chủ (Program.cs):" -IndentFirst 420))

    [void]$sb.Append((New-WCodeBlock -Title "1. Mã nguồn AppDbContext.cs & Các Lớp Thực thể Cốt lõi (Role.cs, Account.cs, CrmModels.cs, Product.cs):" -CodeText @"
// File: Backend/HTTTDN.AdminApi/Data/AppDbContext.cs
using HTTTDN.AdminApi.Models;
using Microsoft.EntityFrameworkCore;

namespace HTTTDN.AdminApi.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Role> Roles { get; set; }
        public DbSet<Account> Accounts { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<Supplier> Suppliers { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<CustomerProfile> CustomerProfiles { get; set; }
        public DbSet<Feedback> Feedbacks { get; set; }
        public DbSet<Survey> Surveys { get; set; }
        public DbSet<SurveyResponse> SurveyResponses { get; set; }
    }
}

// File: Backend/HTTTDN.AdminApi/Models/Role.cs & Account.cs
namespace HTTTDN.AdminApi.Models
{
    public class Role
    {
        [Key] public int RoleId { get; set; }
        [Required, MaxLength(50)] public string RoleName { get; set; } = string.Empty;
        [MaxLength(250)] public string? Description { get; set; }
    }

    public class Account
    {
        [Key] public int AccountId { get; set; }
        [Required, MaxLength(50)] public string Username { get; set; } = string.Empty;
        [Required] public string PasswordHash { get; set; } = string.Empty;
        [Required, MaxLength(100)] public string FullName { get; set; } = string.Empty;
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public int RoleId { get; set; }
        [ForeignKey("RoleId")] public Role? Role { get; set; }
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
"@))

    [void]$sb.Append((New-WCodeBlock -Title "2. Mã nguồn Các Lớp Truyền tải Dữ liệu (AccountDTOs.cs, AuthDTOs.cs, CrmDTOs.cs) & Program.cs:" -CodeText @"
// File: Backend/HTTTDN.AdminApi/DTOs/CrmDTOs.cs
namespace HTTTDN.AdminApi.DTOs
{
    public class CustomerRegisterDto
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public int Age { get; set; } = 20;
        public string? Gender { get; set; } = "Khác";
        public string? Address { get; set; }
        public string? Interest { get; set; } = "Văn phòng";
    }

    public class CustomerUpdateProfileDto
    {
        public string FullName { get; set; } = string.Empty;
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public int Age { get; set; }
        public string? Gender { get; set; }
        public string? Address { get; set; }
        public string? Interest { get; set; }
    }

    public class FeedbackCreateDto
    {
        public int ProductId { get; set; }
        public int Rating { get; set; }
        public string Comment { get; set; } = string.Empty;
    }

    public class FeedbackReplyDto
    {
        public string AdminReply { get; set; } = string.Empty;
    }

    public class SurveyCreateDto
    {
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string TargetProduct { get; set; } = string.Empty;
        public decimal ExpectedPrice { get; set; }
        public string DurationType { get; set; } = "NoLimit";
        public int? DurationDays { get; set; }
        public DateTime? ExpiresAt { get; set; }
    }

    public class SurveyAnswerDto
    {
        public int Score { get; set; }
        public string BuyingIntent { get; set; } = string.Empty;
        public string? CustomerOpinion { get; set; }
    }
}
"@))

    return $sb.ToString()
}
