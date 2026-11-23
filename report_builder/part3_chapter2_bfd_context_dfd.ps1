# ==============================================================================
# PART 3: CHƯƠNG 2 (MỤC 2.2, 2.3, 2.4) — BFD, CONTEXT DIAGRAM, LEVEL 0 & 1 DFD
# ==============================================================================

function Build-Part3-Chapter2-Diagrams {
    $sb = New-Object System.Text.StringBuilder

    # ==========================================================================
    # 2.2. SƠ ĐỒ CHỨC NĂNG (BUSINESS FUNCTION DIAGRAM — BFD) (2 ĐIỂM)
    # ==========================================================================
    [void]$sb.Append((New-WHeading2 "2.2. Sơ đồ Chức năng (Business Function Diagram – BFD) (2 điểm)"))
    [void]$sb.Append((New-WHeading3 "2.2.1. Sơ đồ Phân rã Chức năng Tổng thể (BFD)"))
    [void]$sb.Append((New-WP -Text "Sơ đồ Chức năng (Business Function Diagram – BFD) là công cụ mô hình hóa cấu trúc phân cấp các chức năng nghiệp vụ của hệ thống theo phương pháp phân rã từ trên xuống (Top-Down Decomposition). Từ chức năng gốc ở đỉnh (Hệ thống Quản trị Doanh nghiệp & CRM SGU Tech), hệ thống được phân rã thành 3 nhánh phân hệ độc lập hoàn toàn (1.0 Phân hệ Quản trị Máy chủ – Admin Server; 2.0 Phân hệ Người Quản lý – CRM Manager; 3.0 Phân hệ Khách hàng – Customer Portal) và 17 chức năng nghiệp vụ lá cụ thể:" -IndentFirst 420))

    [void]$sb.Append((New-WImage -RelId "rIdImg2" -WidthEmu 5900000 -HeightEmu 3700000 -Caption "Hình 2.1: Sơ đồ Phân rã Chức năng (Business Function Diagram – BFD) của Hệ thống SGU Tech" -DocPrId 102))

    [void]$sb.Append((New-WHeading3 "2.2.2. Bảng Đặc tả Chi tiết Toàn bộ 17 Chức năng Nghiệp vụ Lá trên Sơ đồ BFD"))
    [void]$sb.Append((New-WP -Text "Bảng dưới đây đặc tả chi tiết dữ liệu đầu vào (Input), thuật toán xử lý nghiệp vụ tại Backend/Frontend (Process), dữ liệu đầu ra (Output) và bảng CSDL tham chiếu của từng chức năng lá trên Sơ đồ BFD:" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Mã BFD", "Tên Chức năng Nghiệp vụ Lá", "Nhánh Phân hệ", "Dữ liệu Đầu vào (Input)", "Xử lý Nghiệp vụ & Thuật toán (Process)", "Kết quả Đầu ra (Output)") -ColWidths @(800, 1850, 1250, 1800, 2200, 1700) -Rows @(
        @("1.1", "Tách biệt giao diện Admin Server độc lập", "1.0 Admin Server", "Phiên đăng nhập RoleName = 'Admin'", "Kiểm tra quyền Admin tại app.js, cô lập hoàn toàn không gian admin.html khỏi Nhân sự, Kho, Bán hàng, CRM; loại bỏ toàn bộ bảng lọc SP/NCC.", "Giao diện quản trị máy chủ độc lập admin.html"),
        @("1.2", "Xem & tìm kiếm danh sách Account", "1.0 Admin Server", "Từ khóa tìm kiếm, Bộ lọc vai trò (RoleId)", "Gọi GET /api/admin/accounts, kết hợp bảng Roles, tính 4 chỉ số KPI máy chủ và lọc tức thời theo Username, Họ tên, Email hoặc Role.", "Bảng 19 tài khoản & 4 thẻ chỉ số KPI"),
        @("1.3", "Thêm mới tài khoản người dùng", "1.0 Admin Server", "Username, Password, FullName, Email, Phone, RoleId", "Gọi POST /api/admin/accounts; kiểm tra trùng Username; băm mật khẩu BCrypt; lưu vào Accounts (tự tạo CustomerProfile nếu là Customer).", "Tài khoản mới kích hoạt trong CSDL"),
        @("1.4", "Xóa tài khoản người dùng", "1.0 Admin Server", "Mã định danh tài khoản (AccountId)", "Gọi DELETE /api/admin/accounts/{id}; xóa dây chuyền dữ liệu con trong CustomerProfiles, Feedbacks, SurveyResponses trước khi xóa Account.", "Tài khoản bị xóa sạch không lỗi FK"),
        @("1.5", "Khóa / Mở khóa trạng thái Account", "1.0 Admin Server", "Mã định danh tài khoản (AccountId)", "Gọi PUT /api/admin/accounts/{id}/toggle-status; đảo ngược giá trị trường bit IsActive (1 <-> 0) trong bảng Accounts.", "Cập nhật trạng thái Hoạt động / Đã khóa"),
        @("1.6", "Phân quyền vai trò cho Account", "1.0 Admin Server", "AccountId, Mã quyền mới RoleId (1, 2, 3)", "Gọi PUT /api/admin/accounts/{id}/role; cập nhật khóa ngoại RoleId sang Admin (1), Manager (2) hoặc Customer (3).", "Quyền hạn mới có hiệu lực tức thời"),
        @("2.1", "Thêm một khách hàng mới", "2.0 Người Quản lý", "Username, Password, FullName, Phone, Email, Age, Gender, Interest, Address", "Gọi POST /api/admin/crm/customers; tạo đồng thời bản ghi Accounts (Role = Customer) và bản ghi CustomerProfiles liên kết 1–1.", "Hồ sơ khách hàng mới hiển thị trên CRM"),
        @("2.2", "Xóa khách hàng", "2.0 Người Quản lý", "Mã tài khoản khách hàng (AccountId)", "Gọi DELETE /api/admin/crm/customers/{id}; xóa sạch hồ sơ nhân khẩu học, lịch sử phản hồi, phiếu khảo sát và tài khoản của KH.", "Khách hàng bị loại bỏ khỏi hệ thống"),
        @("2.3", "Khóa tài khoản khách hàng", "2.0 Người Quản lý", "Mã tài khoản khách hàng (AccountId)", "Gọi PUT /api/admin/crm/customers/{id}/toggle-status; chuyển IsActive = false để chặn quyền đăng nhập của khách hàng vi phạm.", "Tài khoản KH chuyển sang trạng thái Đã khóa"),
        @("2.4", "Tiếp nhận & giải đáp phản hồi KH", "2.0 Người Quản lý", "FeedbackId, Nội dung trả lời AdminReply", "Gọi GET /api/admin/crm/feedbacks & PUT .../reply; lưu câu trả lời vào trường AdminReply và đổi Status thành 'Đã tiếp nhận & Xử lý'.", "Giải đáp hiển thị công khai trên cổng KH"),
        @("2.5", "Báo cáo KH: Tỷ lệ độ tuổi & sở thích", "2.0 Người Quản lý", "Yêu cầu thống kê nhân khẩu học", "Gọi GET /api/admin/crm/reports/demographics; phân nhóm tuổi (<20, 20–30, >30) và GroupBy theo Interest để tính tỷ lệ % và vẽ biểu đồ.", "Biểu đồ tròn Độ tuổi & Biểu đồ cột Sở thích"),
        @("2.6", "Tạo bảng khảo sát gửi đến TK KH", "2.0 Người Quản lý", "Title, TargetProduct, ExpectedPrice, DurationType, ExpiresAt, Description", "Gọi POST /api/admin/crm/surveys; lưu chiến dịch khảo sát mới với IsActive = true và phân phối tới toàn bộ tài khoản khách hàng.", "Bảng khảo sát mới xuất hiện ở cổng KH"),
        @("2.7", "Thống kê kết quả khảo sát", "2.0 Người Quản lý", "Mã bảng khảo sát (SurveyId)", "Gọi GET /api/admin/crm/surveys/{id}/statistics; tính tổng phản hồi, điểm quan tâm TB (1–5), phân bổ 3 mức ý định mua và liệt kê phiếu trả lời.", "Dashboard biểu đồ & bảng chi tiết khảo sát"),
        @("3.1", "Đăng ký tài khoản khách hàng", "3.0 Khách hàng", "Username, Password, FullName, Phone, Email, Age, Gender, Interest, Address", "Gọi POST /api/customer/register; kiểm tra trùng Username, băm mật khẩu BCrypt, tạo Account + CustomerProfile và tự động đăng nhập.", "Tài khoản KH mới & phiên đăng nhập"),
        @("3.2", "Đăng nhập hệ thống", "3.0 Khách hàng", "Username, Password", "Gọi POST /api/customer/login; kiểm tra Role = Customer, kiểm tra IsActive = true, xác thực mật khẩu và cấp phiên truy cập user.html.", "Truy cập thành công vào Cổng Khách hàng"),
        @("3.3", "Chỉnh sửa thông tin cá nhân", "3.0 Khách hàng", "AccountId, FullName, Phone, Email, Age, Gender, Interest, Address", "Gọi PUT /api/customer/profile/{accountId}; cập nhật đồng bộ bảng Accounts và bảng CustomerProfiles.", "Hồ sơ cá nhân & báo cáo CRM được làm mới"),
        @("3.4", "Gửi phản hồi về sản phẩm", "3.0 Khách hàng", "AccountId, ProductId, Rating (1–5 sao), Comment", "Gọi POST /api/customer/feedbacks/{accountId}; lưu đánh giá sản phẩm; hỗ trợ lọc xem đánh giá & giải đáp theo từng sản phẩm.", "Đánh giá mới hiển thị kèm câu trả lời QL"),
        @("3.5", "Nhận được khảo sát và thực hiện", "3.0 Khách hàng", "SurveyId, AccountId, Score (1–5), BuyingIntent, CustomerOpinion", "Gọi GET /api/customer/surveys/{accountId} & POST .../submit/{accountId}; kiểm tra hạn và chưa làm trước đó, lưu vào SurveyResponses.", "Phiếu khảo sát chuyển sang Đã thực hiện")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # 2.3. SƠ ĐỒ NGỮ CẢNH (CONTEXT DIAGRAM) (2 ĐIỂM)
    # ==========================================================================
    [void]$sb.Append((New-WHeading2 "2.3. Sơ đồ Ngữ cảnh (Context Diagram) (2 điểm)"))
    [void]$sb.Append((New-WHeading3 "2.3.1. Mô hình Sơ đồ Ngữ cảnh Tổng thể của Hệ thống"))
    [void]$sb.Append((New-WP -Text "Sơ đồ Ngữ cảnh (Context Diagram) xác định ranh giới của Hệ thống Thông tin Quản trị Doanh nghiệp & CRM SGU Tech (biểu diễn bằng Tiến trình trung tâm duy nhất 0.0) và mô tả toàn bộ các mối tương tác thông tin vào/ra giữa hệ thống với 3 Tác nhân ngoài (External Entities): QUẢN TRỊ VIÊN (ADMIN SERVER), NGƯỜI QUẢN LÝ (CRM MANAGER) và KHÁCH HÀNG (CUSTOMER):" -IndentFirst 420))

    [void]$sb.Append((New-WImage -RelId "rIdImg3" -WidthEmu 5850000 -HeightEmu 3600000 -Caption "Hình 2.2: Sơ đồ Ngữ cảnh Hệ thống (System Context Diagram – Tiến trình 0.0 & 3 Tác nhân ngoài)" -DocPrId 103))

    [void]$sb.Append((New-WHeading3 "2.3.2. Đặc tả Chi tiết 3 Tác nhân Ngoài (External Entities)"))
    [void]$sb.Append((New-WTable -Headers @("Ký hiệu Tác nhân", "Tên Tác nhân Ngoài", "Phân hệ Giao diện", "Vai trò, Trách nhiệm và Mối quan hệ trao đổi dữ liệu với Tiến trình 0.0") -ColWidths @(1400, 2000, 1600, 4600) -Rows @(
        @("Tác nhân 01", "QUẢN TRỊ VIÊN`n(ADMIN SERVER)", "admin.html`n(Tách biệt độc lập)", "Là kỹ sư quản trị máy chủ của doanh nghiệp. Gửi các lệnh tạo mới, xóa, khóa/mở khóa và phân quyền vai trò (Admin/Manager/Customer) cho Account vào Tiến trình 0.0; nhận lại danh sách tài khoản, trạng thái phân quyền và 4 chỉ số KPI máy chủ."),
        @("Tác nhân 02", "NGƯỜI QUẢN LÝ`n(CRM MANAGER)", "quanly.html`n(5 Tab CRM)", "Là cán bộ quản lý quan hệ khách hàng. Gửi thông tin thêm mới, xóa, khóa khách hàng, câu trả lời giải đáp phản hồi và chiến dịch khảo sát mới vào Tiến trình 0.0; nhận lại danh sách hồ sơ khách hàng, danh sách phản hồi sản phẩm, báo cáo tỷ lệ độ tuổi/sở thích và báo cáo thống kê kết quả khảo sát."),
        @("Tác nhân 03", "KHÁCH HÀNG`n(CUSTOMER)", "user.html`n(Cổng Khách hàng)", "Là người tiêu dùng mua sắm thiết bị công nghệ tại SGU Tech. Gửi yêu cầu đăng ký, đăng nhập, chỉnh sửa hồ sơ cá nhân, đánh giá 1–5 sao về sản phẩm và phiếu trả lời khảo sát vào Tiến trình 0.0; nhận lại thông tin hồ sơ, danh mục sản phẩm, câu trả lời giải đáp từ Người quản lý và các bảng khảo sát mới.")
    )))

    [void]$sb.Append((New-WHeading3 "2.3.3. Bảng Đặc tả Chi tiết 16 Luồng Dữ liệu Vào/Ra trên Sơ đồ Ngữ cảnh"))
    [void]$sb.Append((New-WTable -Headers @("Mã Luồng", "Tên Luồng Dữ liệu Ngữ cảnh", "Nguồn (Source)", "Đích (Sink)", "Các Thuộc tính Dữ liệu Thành phần (Data Elements)", "API Endpoint Tương ứng") -ColWidths @(850, 2100, 1350, 1350, 2350, 1600) -Rows @(
        @("CF-01", "Thông tin đăng nhập Admin", "Quản trị viên", "Hệ thống 0.0", "Username, Password", "POST /api/admin/auth/login"),
        @("CF-02", "Lệnh Thêm / Xóa / Khóa Account", "Quản trị viên", "Hệ thống 0.0", "AccountId, Username, Password, FullName, Email, Phone, RoleId", "POST, PUT, DELETE /api/admin/accounts"),
        @("CF-03", "Lệnh Phân quyền Vai trò (Role)", "Quản trị viên", "Hệ thống 0.0", "AccountId, RoleId (1: Admin, 2: Manager, 3: Customer)", "PUT /api/admin/accounts/{id}/role"),
        @("CF-04", "DS Account & Trạng thái phân quyền", "Hệ thống 0.0", "Quản trị viên", "Danh sách 19 Accounts, 3 Roles, IsActive, 4 chỉ số KPI máy chủ", "GET /api/admin/accounts & /roles"),
        @("CF-05", "Lệnh Thêm / Xóa / Khóa Khách hàng", "Người Quản lý", "Hệ thống 0.0", "AccountId, Username, FullName, Phone, Email, Age, Gender, Interest, Address", "POST, PUT, DELETE /api/admin/crm/customers"),
        @("CF-06", "Nội dung Giải đáp Phản hồi KH", "Người Quản lý", "Hệ thống 0.0", "FeedbackId, AdminReply, Status ('Đã tiếp nhận & Xử lý')", "PUT /api/admin/crm/feedbacks/{id}/reply"),
        @("CF-07", "Bảng Khảo sát Mới phát hành", "Người Quản lý", "Hệ thống 0.0", "Title, TargetProduct, ExpectedPrice, DurationType, ExpiresAt, Description", "POST /api/admin/crm/surveys"),
        @("CF-08", "DS Hồ sơ KH & Phản hồi Sản phẩm", "Hệ thống 0.0", "Người Quản lý", "Danh sách 15 Khách hàng kèm Profile & 18 Phản hồi sản phẩm", "GET /api/admin/crm/customers & /feedbacks"),
        @("CF-09", "Báo cáo Tỷ lệ Độ tuổi & Sở thích", "Hệ thống 0.0", "Người Quản lý", "totalCustomers, ageStats (<20, 20–30, >30), interestStats (Count, %)", "GET /api/admin/crm/reports/demographics"),
        @("CF-10", "Báo cáo Thống kê Kết quả Khảo sát", "Hệ thống 0.0", "Người Quản lý", "totalResponses, averageScore, intentStats, scoreDistribution, detailResponses", "GET /api/admin/crm/surveys/{id}/statistics"),
        @("CF-11", "Thông tin Đăng ký & Đăng nhập KH", "Khách hàng", "Hệ thống 0.0", "Username, Password, FullName, Phone, Email, Age, Gender, Interest, Address", "POST /api/customer/register & /login"),
        @("CF-12", "Thông tin Chỉnh sửa Hồ sơ Cá nhân", "Khách hàng", "Hệ thống 0.0", "AccountId, FullName, Phone, Email, Age, Gender, Interest, Address", "PUT /api/customer/profile/{accountId}"),
        @("CF-13", "Đánh giá Sao & Phản hồi Sản phẩm", "Khách hàng", "Hệ thống 0.0", "AccountId, ProductId, Rating (1–5 sao), Comment", "POST /api/customer/feedbacks/{accountId}"),
        @("CF-14", "Phiếu Kết quả Thực hiện Khảo sát", "Khách hàng", "Hệ thống 0.0", "SurveyId, AccountId, Score (1–5 điểm), BuyingIntent, CustomerOpinion", "POST /api/customer/surveys/{id}/submit/{aid}"),
        @("CF-15", "Hồ sơ Cá nhân & Giải đáp từ Quản lý", "Hệ thống 0.0", "Khách hàng", "Thông tin Profile cá nhân, Danh mục 16 SP, Danh sách phản hồi & AdminReply", "GET /api/customer/profile & /all-feedbacks"),
        @("CF-16", "Danh sách Bảng Khảo sát gửi tới TK", "Hệ thống 0.0", "Khách hàng", "Danh sách 5 chiến dịch khảo sát, IsActive, IsExpired, IsCompleted, MyResponse", "GET /api/customer/surveys/{accountId}")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # 2.4. SƠ ĐỒ LUỒNG DỮ LIỆU MỨC ĐỈNH (LEVEL 0 DFD) & MỨC 1 (LEVEL 1 DFD) (4Đ)
    # ==========================================================================
    [void]$sb.Append((New-WHeading2 "2.4. Sơ đồ Luồng Dữ liệu Mức Đỉnh (Level 0 DFD) & Phân rã Mức 1 (Level 1 DFD) (4 điểm)"))
    [void]$sb.Append((New-WHeading3 "2.4.1. Sơ đồ Luồng Dữ liệu Mức Đỉnh (Level 0 DFD)"))
    [void]$sb.Append((New-WP -Text "Phân rã Tiến trình 0.0 từ Sơ đồ Ngữ cảnh, Sơ đồ Luồng Dữ liệu Mức Đỉnh (Level 0 DFD) tổ chức hệ thống thành 5 Tiến trình nghiệp vụ cốt lõi (1.0 đến 5.0) kết nối trực tiếp với 3 Tác nhân ngoài và 5 Kho dữ liệu chuẩn (D1 đến D5). Toàn bộ các kho dữ liệu từ D1 đến D5 trên sơ đồ này chính là cơ sở trực tiếp để thiết kế 9 bảng Cơ sở dữ liệu ở Chương 3:" -IndentFirst 420))

    [void]$sb.Append((New-WImage -RelId "rIdImg4" -WidthEmu 5900000 -HeightEmu 3700000 -Caption "Hình 2.3: Sơ đồ Luồng Dữ liệu Mức Đỉnh (Level 0 DFD — 5 Tiến trình & 5 Kho dữ liệu D1..D5)" -DocPrId 104))

    [void]$sb.Append((New-WHeading3 "2.4.2. Bảng Đặc tả 5 Tiến trình Chính và 5 Kho Dữ liệu trên Sơ đồ DFD Mức Đỉnh"))
    [void]$sb.Append((New-WTable -Headers @("Ký hiệu", "Tên Tiến trình / Kho dữ liệu", "Phân loại", "Mô tả chi tiết chức năng xử lý / Nội dung lưu trữ dữ liệu", "Bảng CSDL Vật lý Ánh xạ") -ColWidths @(900, 2100, 1200, 3600, 1800) -Rows @(
        @("Tiến trình 1.0", "Quản trị Tài khoản & Phân quyền", "Process (Admin Server)", "Tiếp nhận yêu cầu từ Quản trị viên để xác thực, thêm mới Account, xóa Account, khóa/mở khóa trạng thái truy cập và cập nhật phân quyền vai trò (Admin, Manager, Customer).", "Bảng Roles,`nBảng Accounts,`nBảng CustomerProfiles"),
        @("Tiến trình 2.0", "Quản lý Hồ sơ Khách hàng", "Process (CRM & Customer)", "Xử lý các thao tác Thêm mới, Xóa, Khóa tài khoản khách hàng từ Người quản lý CRM; đồng thời xử lý Đăng ký tài khoản, Đăng nhập và Chỉnh sửa hồ sơ cá nhân từ Khách hàng.", "Bảng Accounts,`nBảng CustomerProfiles"),
        @("Tiến trình 3.0", "Xử lý Phản hồi Sản phẩm", "Process (CRM & Customer)", "Tiếp nhận đánh giá 1–5 sao và nhận xét sản phẩm từ Khách hàng đối chiếu với kho sản phẩm D3; lưu trữ câu trả lời giải đáp (AdminReply) từ Người quản lý vào kho D4.", "Bảng Feedbacks,`nBảng Products,`nBảng Categories,`nBảng Suppliers"),
        @("Tiến trình 4.0", "Báo cáo Độ tuổi & Sở thích", "Process (CRM Analytics)", "Đọc dữ liệu nhân khẩu học từ kho D2 (Customers), thực hiện phân nhóm độ tuổi (<20, 20–30, >30) và gom nhóm sở thích tiêu dùng để kết xuất báo cáo trực quan cho Người quản lý.", "Bảng CustomerProfiles,`nBảng Accounts"),
        @("Tiến trình 5.0", "Quản lý & Thống kê Khảo sát", "Process (CRM & Customer)", "Cho phép Người quản lý tạo bảng khảo sát gửi đến tài khoản khách hàng; tiếp nhận phiếu trả lời khảo sát từ Khách hàng và tổng hợp báo cáo thống kê kết quả khảo sát.", "Bảng Surveys,`nBảng SurveyResponses"),
        @("Kho D1", "D1: Accounts & Roles", "Data Store", "Lưu trữ thông tin định danh tài khoản (AccountId, Username, PasswordHash, FullName, Email, Phone, RoleId, IsActive) và danh mục 3 vai trò chuẩn (Admin, Manager, Customer).", "Bảng Roles,`nBảng Accounts"),
        @("Kho D2", "D2: Customers", "Data Store", "Lưu trữ hồ sơ nhân khẩu học chi tiết của khách hàng liên kết 1–1 với Account: ProfileId, AccountId, Age (Độ tuổi), Gender (Giới tính), Address (Địa chỉ), Interest (Sở thích).", "Bảng CustomerProfiles"),
        @("Kho D3", "D3: Products", "Data Store", "Lưu trữ danh mục 16 sản phẩm công nghệ, 5 nhóm danh mục loại sản phẩm và 6 nhà cung cấp đối tác để khách hàng tra cứu và chọn sản phẩm khi gửi phản hồi.", "Bảng Categories,`nBảng Suppliers,`nBảng Products"),
        @("Kho D4", "D4: Feedbacks", "Data Store", "Lưu trữ toàn bộ 18 lượt đánh giá sao (Rating 1–5), nội dung nhận xét của khách hàng (Comment), câu trả lời của Người quản lý (AdminReply) và trạng thái xử lý (Status).", "Bảng Feedbacks"),
        @("Kho D5", "D5: Surveys & Responses", "Data Store", "Lưu trữ 5 chiến dịch bảng khảo sát sản phẩm mới (Surveys) và 16 phiếu kết quả trả lời khảo sát của từng tài khoản khách hàng (SurveyResponses).", "Bảng Surveys,`nBảng SurveyResponses")
    )))

    [void]$sb.Append((New-WHeading3 "2.4.3. Bảng Đặc tả Chi tiết các Luồng Dữ liệu Trung gian trên Sơ đồ DFD Mức Đỉnh"))
    [void]$sb.Append((New-WTable -Headers @("STT", "Tên Luồng Dữ liệu trên DFD Mức 0", "Điểm đầu (From)", "Điểm cuối (To)", "Nội dung dữ liệu truyền tải và câu lệnh SQL / API tương ứng") -ColWidths @(650, 2350, 1600, 1600, 3400) -Rows @(
        @("01", "Yêu cầu Thêm / Xóa / Khóa / Phân quyền", "Tác nhân Admin", "Tiến trình 1.0", "Gói dữ liệu AccountCreateDto, UpdateRoleDto hoặc lệnh ToggleStatus/Delete gửi vào AccountsController."),
        @("02", "Ghi / Cập nhật Account & Role", "Tiến trình 1.0", "Kho D1 (Accounts)", "Thực thi INSERT, UPDATE RoleId, UPDATE IsActive hoặc DELETE trên bảng Accounts."),
        @("03", "Đọc danh sách Account & Role", "Kho D1 (Accounts)", "Tiến trình 1.0", "Thực thi SELECT Accounts JOIN Roles ORDER BY AccountId DESC."),
        @("04", "Danh sách Account & KPI Máy chủ", "Tiến trình 1.0", "Tác nhân Admin", "Trả về mảng JSON 19 tài khoản, 3 vai trò và 4 chỉ số thống kê KPI cho màn hình admin.html."),
        @("05", "Lệnh Thêm / Xóa / Khóa Khách hàng", "Người Quản lý CRM", "Tiến trình 2.0", "Gửi thông tin hồ sơ khách hàng mới hoặc lệnh khóa/xóa khách hàng vào CrmAdminController."),
        @("06", "Thông tin Đăng ký & Cập nhật Hồ sơ", "Tác nhân Khách hàng", "Tiến trình 2.0", "Khách hàng gửi biểu mẫu đăng ký mới hoặc chỉnh sửa thông tin cá nhân vào CustomerPortalController."),
        @("07", "Đồng bộ định danh Khách hàng", "Tiến trình 2.0", "Kho D1 (Accounts)", "Tạo mới tài khoản Role = Customer, cập nhật FullName/Email/Phone hoặc đảo trạng thái IsActive."),
        @("08", "Ghi / Cập nhật Hồ sơ Nhân khẩu học", "Tiến trình 2.0", "Kho D2 (Customers)", "Thực thi INSERT, UPDATE (Age, Gender, Interest, Address) hoặc DELETE trên bảng CustomerProfiles."),
        @("09", "Đọc danh sách Hồ sơ Khách hàng", "Kho D2 (Customers)", "Tiến trình 2.0", "Truy vấn danh sách 15 hồ sơ khách hàng kết hợp trạng thái tài khoản từ kho D1."),
        @("10", "Đánh giá 1–5 sao & Nhận xét SP", "Tác nhân Khách hàng", "Tiến trình 3.0", "Khách hàng chọn sản phẩm (ProductId), mức sao (Rating 1–5) và gửi nhận xét (Comment)."),
        @("11", "Đối chiếu thông tin Sản phẩm", "Kho D3 (Products)", "Tiến trình 3.0", "Đọc ProductName, ProductCode, ImageUrl từ bảng Products để gắn với lượt phản hồi."),
        @("12", "Lưu phản hồi mới & Giải đáp", "Tiến trình 3.0", "Kho D4 (Feedbacks)", "Thực thi INSERT phản hồi mới của KH hoặc UPDATE AdminReply, Status của Người quản lý."),
        @("13", "Đọc danh sách Phản hồi & Giải đáp", "Kho D4 (Feedbacks)", "Tiến trình 3.0", "Truy vấn toàn bộ lịch sử phản hồi sản phẩm và câu trả lời giải đáp từ bảng Feedbacks."),
        @("14", "Đọc dữ liệu Tuổi & Sở thích KH", "Kho D2 (Customers)", "Tiến trình 4.0", "Đọc toàn bộ cột Age và Interest của 15 khách hàng trong bảng CustomerProfiles."),
        @("15", "Báo cáo Tỷ lệ Độ tuổi & Sở thích", "Tiến trình 4.0", "Người Quản lý CRM", "Kết xuất JSON thống kê 3 nhóm tuổi và 4 nhóm sở thích kèm tỷ lệ % cho biểu đồ Tab 3."),
        @("16", "Thông tin Bảng khảo sát mới", "Người Quản lý CRM", "Tiến trình 5.0", "Người quản lý gửi Title, TargetProduct, ExpectedPrice, ExpiresAt, Description để phát hành khảo sát."),
        @("17", "Lưu chiến dịch & Phiếu trả lời KS", "Tiến trình 5.0", "Kho D5 (Surveys)", "Thực thi INSERT vào bảng Surveys (khi tạo KS) và INSERT vào SurveyResponses (khi KH nộp phiếu)."),
        @("18", "Đọc dữ liệu Khảo sát & Kết quả", "Kho D5 (Surveys)", "Tiến trình 5.0", "Truy vấn danh sách khảo sát và toàn bộ 16 phiếu trả lời khảo sát để tính toán thống kê."),
        @("19", "Phân phối Khảo sát đến TK KH", "Tiến trình 5.0", "Tác nhân Khách hàng", "Hiển thị danh sách khảo sát đang mở và trạng thái đã làm/chưa làm trên tài khoản khách hàng."),
        @("20", "Báo cáo Thống kê Kết quả Khảo sát", "Tiến trình 5.0", "Người Quản lý CRM", "Trả về tổng lượt tham gia, điểm quan tâm trung bình, phân bổ ý định mua và danh sách chi tiết.")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # 2.4.4. SƠ ĐỒ DFD MỨC 1 — PHÂN RÃ TIẾN TRÌNH 1.0 (ADMIN SERVER)
    # ==========================================================================
    [void]$sb.Append((New-WHeading3 "2.4.4. Sơ đồ Luồng Dữ liệu Mức 1 — Phân rã Tiến trình 1.0: Quản trị Máy chủ (Admin Server)"))
    [void]$sb.Append((New-WP -Text "Để làm rõ hoạt động bên trong Phân hệ Quản trị Máy chủ (Admin Server), Tiến trình 1.0 được phân rã chi tiết ở Mức 1 thành 4 tiến trình con (1.1 Xác thực & Tách biệt Giao diện Admin; 1.2 Thêm mới & Xóa Tài khoản; 1.3 Phân quyền Vai trò cho Account; 1.4 Khóa / Mở khóa & Truy vấn Account) tương tác trực tiếp với kho D1 (Accounts & Roles) và kho D2 (Customers):" -IndentFirst 420))

    [void]$sb.Append((New-WImage -RelId "rIdImg5" -WidthEmu 5850000 -HeightEmu 3550000 -Caption "Hình 2.4: Sơ đồ DFD Mức 1 — Phân rã Tiến trình 1.0: Phân hệ Quản trị Máy chủ (Admin Server)" -DocPrId 105))

    [void]$sb.Append((New-WTable -Headers @("Mã Tiến trình", "Tên Tiến trình Con (DFD Mức 1 – Admin)", "Đầu vào (Input Flows)", "Thuật toán Xử lý Chi tiết", "Đầu ra & Kho Dữ liệu Tác động") -ColWidths @(1100, 2100, 1800, 2700, 1900) -Rows @(
        @("Tiến trình 1.1", "Xác thực & Tách biệt Giao diện Admin Server", "Username, Password từ Quản trị viên", "Kiểm tra thông tin đăng nhập đối chiếu kho D1; xác nhận RoleName == 'Admin' và IsActive == true; cấp quyền truy cập độc quyền vào admin.html.", "Phiên làm việc Admin hợp lệ; đọc Kho D1 (Accounts & Roles)."),
        @("Tiến trình 1.2", "Thêm mới & Xóa Tài khoản (Account)", "Thông tin Account mới hoặc AccountId cần xóa", "Khi thêm: kiểm tra trùng Username, băm BCrypt mật khẩu, ghi vào D1 (và tạo hồ sơ mặc định vào D2 nếu là Customer). Khi xóa: xóa dây chuyền dữ liệu liên kết rồi xóa bản ghi trong D1.", "Ghi/Xóa trên Kho D1 (Accounts) và Kho D2 (CustomerProfiles)."),
        @("Tiến trình 1.3", "Phân quyền Vai trò cho Account", "AccountId, RoleId mới (1: Admin, 2: Manager, 3: Customer)", "Kiểm tra sự tồn tại của Account trong D1; cập nhật khóa ngoại RoleId sang vai trò mới; tự động bổ sung bản ghi D2 nếu nâng/chuyển quyền sang Customer.", "Cập nhật RoleId trong Kho D1; đồng bộ Kho D2."),
        @("Tiến trình 1.4", "Khóa / Mở khóa & Truy vấn Danh sách Account", "AccountId cần đảo trạng thái hoặc từ khóa tìm kiếm/lọc", "Đảo ngược trạng thái bit IsActive trong kho D1; truy vấn danh sách 19 tài khoản kết hợp bảng Roles và tính toán 4 chỉ số KPI máy chủ.", "Cập nhật/Đọc Kho D1; trả bảng Account & KPI về Admin.")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # 2.4.5. SƠ ĐỒ DFD MỨC 1 — PHÂN RÃ NGHIỆP VỤ NGƯỜI QUẢN LÝ CRM
    # ==========================================================================
    [void]$sb.Append((New-WHeading3 "2.4.5. Sơ đồ Luồng Dữ liệu Mức 1 — Phân rã Nghiệp vụ Người Quản lý Quan hệ Khách hàng (CRM Manager)"))
    [void]$sb.Append((New-WP -Text "Toàn bộ 7 yêu cầu chức năng của Người Quản lý CRM được mô hình hóa chi tiết trong Sơ đồ DFD Mức 1 dưới đây thông qua 5 tiến trình nghiệp vụ chuyên sâu (2.1 Thêm mới, Xóa & Khóa TK Khách hàng; 3.1 Tiếp nhận & Giải đáp Phản hồi KH; 4.1 Tổng hợp Báo cáo Độ tuổi & Sở thích; 5.1 Tạo & Phát hành Bảng Khảo sát; 5.2 Thống kê & Đo lường Kết quả Khảo sát):" -IndentFirst 420))

    [void]$sb.Append((New-WImage -RelId "rIdImg6" -WidthEmu 5850000 -HeightEmu 3550000 -Caption "Hình 2.5: Sơ đồ DFD Mức 1 — Phân rã Nghiệp vụ Người Quản lý Quan hệ Khách hàng (CRM Manager)" -DocPrId 106))

    [void]$sb.Append((New-WTable -Headers @("Mã Tiến trình", "Tên Tiến trình Con (DFD Mức 1 – CRM)", "Yêu cầu Đề bài Đáp ứng", "Thuật toán Xử lý Nghiệp vụ tại CrmAdminController", "Kho Dữ liệu Tác động") -ColWidths @(1100, 2100, 1800, 2800, 1800) -Rows @(
        @("Tiến trình 2.1", "Thêm mới, Xóa & Khóa TK Khách hàng", "(1) Thêm KH mới`n(2) Xóa khách hàng`n(3) Khóa TK khách hàng", "Tạo đồng bộ Account (Role = Customer) vào D1 và hồ sơ nhân khẩu học vào D2; đảo cờ IsActive trong D1 khi khóa TK; xóa dây chuyền D2, D4, D5 và D1 khi xóa khách hàng.", "Kho D1 (Accounts),`nKho D2 (Customers)"),
        @("Tiến trình 3.1", "Tiếp nhận & Giải đáp Phản hồi Khách hàng", "(4) Tiếp nhận phản hồi của khách hàng", "Truy vấn danh sách đánh giá sản phẩm từ D4 kết hợp tên khách hàng (D1) và tên/hình ảnh sản phẩm (D3); lưu nội dung giải đáp AdminReply và cập nhật trạng thái 'Đã tiếp nhận & Xử lý'.", "Kho D4 (Feedbacks),`nKho D3 (Products),`nKho D1 (Accounts)"),
        @("Tiến trình 4.1", "Tổng hợp Báo cáo Độ tuổi & Sở thích", "(5) Báo cáo về KH, tỷ lệ độ tuổi, sở thích", "Đọc toàn bộ hồ sơ khách hàng từ D2; phân loại trường Age vào 3 nhóm (<20, 20–30, >30); thực hiện GroupBy theo trường Interest để tính số lượng và tỷ lệ phần trăm từng sở thích.", "Kho D2 (Customers)"),
        @("Tiến trình 5.1", "Tạo & Phát hành Bảng Khảo sát", "(6) Tạo bảng khảo sát & gửi đến TK khách hàng", "Nhận thông tin chiến dịch khảo sát mới, tính toán thời hạn ExpiresAt theo DurationType, lưu vào kho D5 (Surveys) với IsActive = true và phân phối đến toàn bộ tài khoản KH.", "Kho D5 (Surveys),`nKho D1 (Accounts)"),
        @("Tiến trình 5.2", "Thống kê & Đo lường Kết quả Khảo sát", "(7) Thống kê kết quả khảo sát", "Đọc dữ liệu từ bảng Surveys và SurveyResponses trong kho D5; tính tổng số lượt trả lời, điểm quan tâm trung bình (1–5), thống kê 3 nhóm ý định mua sắm và kết xuất danh sách chi tiết.", "Kho D5 (Surveys & SurveyResponses)")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # 2.4.6. SƠ ĐỒ DFD MỨC 1 — PHÂN RÃ CỔNG TƯƠNG TÁC KHÁCH HÀNG (CUSTOMER PORTAL)
    # ==========================================================================
    [void]$sb.Append((New-WHeading3 "2.4.6. Sơ đồ Luồng Dữ liệu Mức 1 — Phân rã Cổng Tương tác Khách hàng (Customer Portal)"))
    [void]$sb.Append((New-WP -Text "Toàn bộ 5 yêu cầu chức năng của Khách hàng được phân rã chi tiết tại Sơ đồ DFD Mức 1 dưới đây thông qua 4 tiến trình tương tác trực tuyến (2.2 Đăng ký Tài khoản & Đăng nhập; 2.3 Chỉnh sửa Thông tin Hồ sơ Cá nhân; 3.2 Gửi Phản hồi về Sản phẩm & Xem Giải đáp; 5.3 Nhận Bảng Khảo sát & Gửi Kết quả Thực hiện):" -IndentFirst 420))

    [void]$sb.Append((New-WImage -RelId "rIdImg7" -WidthEmu 5850000 -HeightEmu 3550000 -Caption "Hình 2.6: Sơ đồ DFD Mức 1 — Phân rã Nghiệp vụ Cổng Tương tác Khách hàng (Customer Portal)" -DocPrId 107))

    [void]$sb.Append((New-WTable -Headers @("Mã Tiến trình", "Tên Tiến trình Con (DFD Mức 1 – Khách hàng)", "Yêu cầu Đề bài Đáp ứng", "Thuật toán Xử lý Nghiệp vụ tại CustomerPortalController", "Kho Dữ liệu Tác động") -ColWidths @(1100, 2100, 1800, 2800, 1800) -Rows @(
        @("Tiến trình 2.2", "Đăng ký Tài khoản & Đăng nhập Hệ thống", "(1) Đăng ký TK khách hàng`n(2) Đăng nhập", "Kiểm tra trùng Username, băm mật khẩu BCrypt, ghi bản ghi mới vào D1 (Accounts) và D2 (CustomerProfiles); xác thực đăng nhập, kiểm tra IsActive == true và cấp phiên làm việc.", "Kho D1 (Accounts),`nKho D2 (Customers)"),
        @("Tiến trình 2.3", "Chỉnh sửa Thông tin Hồ sơ Cá nhân", "(3) Chỉnh sửa thông tin", "Tiếp nhận dữ liệu cập nhật từ khách hàng; cập nhật FullName, Email, Phone vào kho D1 và cập nhật Age, Gender, Interest, Address vào kho D2.", "Kho D1 (Accounts),`nKho D2 (Customers)"),
        @("Tiến trình 3.2", "Gửi Phản hồi Sản phẩm & Xem Giải đáp", "(4) Gửi phản hồi về sản phẩm", "Đọc danh mục 16 sản phẩm từ kho D3; lưu đánh giá sao (Rating 1–5) và nhận xét của khách hàng vào kho D4; truy vấn lịch sử phản hồi và câu trả lời giải đáp từ Người quản lý.", "Kho D3 (Products),`nKho D4 (Feedbacks)"),
        @("Tiến trình 5.3", "Nhận Bảng Khảo sát & Thực hiện Khảo sát", "(5) Nhận được khảo sát và thực hiện", "Truy vấn các chiến dịch khảo sát từ kho D5 kèm cờ kiểm tra đã thực hiện (IsCompleted); kiểm tra khảo sát còn mở và chưa quá hạn, lưu phiếu trả lời (Score, BuyingIntent, Opinion) vào kho D5.", "Kho D5 (Surveys & SurveyResponses)")
    )))

    [void]$sb.Append((New-WHeading3 "2.4.7. Ma trận Tương tác Tiến trình – Kho Dữ liệu (CRUD Matrix & DFD Balancing)"))
    [void]$sb.Append((New-WP -Text "Để kiểm chứng tính đầy đủ, nhất quán và cân bằng dữ liệu (Data Flow Balancing) giữa Sơ đồ Chức năng (BFD), Sơ đồ Ngữ cảnh (Context Diagram), Sơ đồ DFD Mức 0 và DFD Mức 1, nhóm lập Ma trận CRUD (C – Create: Tạo mới; R – Read: Đọc/Truy vấn; U – Update: Cập nhật; D – Delete: Xóa) giữa 13 tiến trình con Mức 1 và 5 Kho dữ liệu (9 bảng CSDL):" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Mã Tiến trình DFD", "Tên Tiến trình Nghiệp vụ", "D1: Roles & Accounts", "D2: CustomerProfiles", "D3: Categories, Suppliers, Products", "D4: Feedbacks", "D5: Surveys & SurveyResponses") -ColWidths @(1100, 2700, 1160, 1160, 1160, 1160, 1160) -Rows @(
        @("1.1 (Admin)", "Xác thực & Tách biệt Giao diện Admin", "R", "—", "—", "—", "—"),
        @("1.2 (Admin)", "Thêm mới & Xóa Tài khoản (Account)", "C, R, D", "C, D", "—", "D (Cascade)", "D (Cascade)"),
        @("1.3 (Admin)", "Phân quyền Vai trò cho Account", "R, U", "C, R", "—", "—", "—"),
        @("1.4 (Admin)", "Khóa / Mở khóa & Truy vấn Account", "R, U", "—", "—", "—", "—"),
        @("2.1 (CRM)", "Thêm mới, Xóa & Khóa TK Khách hàng", "C, R, U, D", "C, R, U, D", "—", "D (Cascade)", "D (Cascade)"),
        @("3.1 (CRM)", "Tiếp nhận & Giải đáp Phản hồi KH", "R", "—", "R", "R, U", "—"),
        @("4.1 (CRM)", "Tổng hợp Báo cáo Độ tuổi & Sở thích", "R", "R", "—", "—", "—"),
        @("5.1 (CRM)", "Tạo, Khóa/Mở & Xóa Bảng Khảo sát", "R", "—", "—", "—", "C, R, U, D"),
        @("5.2 (CRM)", "Thống kê & Đo lường Kết quả Khảo sát", "R", "—", "—", "—", "R"),
        @("2.2 (KH)", "Đăng ký Tài khoản & Đăng nhập KH", "C, R", "C, R", "—", "—", "—"),
        @("2.3 (KH)", "Chỉnh sửa Thông tin Hồ sơ Cá nhân", "R, U", "C, R, U", "—", "—", "—"),
        @("3.2 (KH)", "Gửi Phản hồi Sản phẩm & Xem Giải đáp", "R", "—", "R", "C, R", "—"),
        @("5.3 (KH)", "Nhận Bảng Khảo sát & Gửi Phiếu Trả lời", "R", "—", "—", "—", "C, R")
    )))

    [void]$sb.Append((New-WPageBreak))
    return $sb.ToString()
}
