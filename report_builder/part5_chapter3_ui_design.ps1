# ==============================================================================
# PART 5: CHƯƠNG 3 (MỤC 3.2) — THIẾT KẾ GIAO DIỆN: HÌNH ẢNH THỰC TẾ, GIỚI THIỆU
# CHI TIẾT CÁC CHỨC NĂNG VÀ HOẠT ĐỘNG CỦA TOÀN BỘ 13 MÀN HÌNH PHẦN MỀM (5Đ)
# ==============================================================================

function Build-Part5-Chapter3-UI {
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.Append((New-WHeading2 "3.2. Thiết kế Giao diện: Hình ảnh thực tế, Giới thiệu chi tiết các chức năng và hoạt động của phần mềm (5 điểm)"))

    [void]$sb.Append((New-WHeading3 "3.2.1. Hệ thống Quy chuẩn Thiết kế Giao diện Doanh nghiệp (VNG Enterprise Design System)"))
    [void]$sb.Append((New-WP -Text "Toàn bộ giao diện người dùng của đồ án tại thư mục Frontend_Admin được thiết kế thống nhất theo ngôn ngữ thiết kế doanh nghiệp hiện đại (Enterprise Corporate UI lấy cảm hứng từ hệ sinh thái quản trị của VNG Corporation), loại bỏ hoàn toàn các chi tiết rườm rà và đảm bảo sự tách biệt độc lập giữa 3 vai trò:" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Thành phần Quy chuẩn UI", "Thông số Kỹ thuật CSS / Giao diện", "Mục đích và Ý nghĩa trong Hệ thống") -ColWidths @(2400, 3200, 4000) -Rows @(
        @("1. Phân tách 3 Không gian Giao diện", "• admin.html (Admin Server)`n• quanly.html (Người Quản lý CRM)`n• user.html (Cổng Khách hàng)", "Đảm bảo giao diện Admin Server tách biệt hoàn toàn với quản lý nhân sự, kho, bán hàng và CRM theo đúng yêu cầu đề bài."),
        @("2. Bảng màu Chủ đạo (Color Palette)", "• Primary Brand: #F97316 (Corporate Orange)`n• Sidebar & Dark Navy: #0F172A`n• Enterprise Blue: #1D4ED8`n• Success / Danger: #10B981 / #EF4444", "Tạo độ tương phản cao, chuyên nghiệp, giúp phân biệt rõ trạng thái tài khoản Hoạt động (Xanh lá) và Đã khóa (Đỏ)."),
        @("3. Hệ thống Chữ (Typography)", "Font-family: 'Be Vietnam Pro', 'Inter', system-ui, sans-serif; kích thước chuẩn 14px–24px", "Hiển thị tiếng Việt rõ nét, chuẩn xác trên mọi độ phân giải màn hình doanh nghiệp."),
        @("4. Công nghệ Biểu đồ Thống kê", "Chart.js 4.x kết hợp Bộ vẽ Đồ họa Dự phòng HTML5 Canvas 2D (Offline Fallback Renderer)", "Đảm bảo toàn bộ 6 biểu đồ thống kê (Phản hồi sao, Độ tuổi, Sở thích, Khảo sát) luôn hiển thị 100% kể cả khi máy tính không có kết nối Internet.")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # MÀN HÌNH 1: CỔNG ĐĂNG NHẬP NỘI BỘ & QUẢN TRỊ (login.html)
    # ==========================================================================
    [void]$sb.Append((New-WHeading3 "3.2.2. Màn hình 1: Cổng Đăng nhập Nội bộ & Điều hướng Phân quyền Tự động (login.html)"))
    [void]$sb.Append((New-WImage -RelId "rIdImg10" -WidthEmu 5850000 -HeightEmu 3550000 -Caption "Hình 3.2: Giao diện Cổng Đăng nhập Nội bộ & Điều hướng Phân quyền Tự động (login.html)" -DocPrId 110))

    [void]$sb.Append((New-WP -Text "1. Giới thiệu chi tiết chức năng: Màn hình login.html là cổng xác thực tập trung của hệ thống. Giao diện được chia làm 2 cột chuẩn doanh nghiệp: cột trái giới thiệu kiến trúc phân tách 3 phân hệ (Admin Server, Quản lý CRM, Khách hàng), cột phải là biểu mẫu đăng nhập kèm 3 nút chọn nhanh tài khoản Demo (Admin Server, Người Quản lý CRM, Khách hàng) và liên kết chuyển sang Cổng Khách hàng." -IndentFirst 420))
    [void]$sb.Append((New-WP -Text "2. Hoạt động của phần mềm: Khi người dùng nhập Tên đăng nhập và Mật khẩu rồi nhấn 'Đăng nhập vào Hệ thống', hàm xử lý gửi yêu cầu POST /api/admin/auth/login. Dựa vào trường roleName trả về từ SQL Server, hệ thống tự động phân luồng: nếu là 'Admin' chuyển thẳng vào admin.html; nếu là 'Manager' chuyển thẳng vào quanly.html; nếu là 'Customer' chuyển thẳng vào user.html." -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Tên Điều khiển (Control)", "ID / Selector DOM", "Loại Control", "Ràng buộc & Kiểm tra", "Sự kiện & Hoạt động Xử lý API") -ColWidths @(2000, 1800, 1300, 1700, 2800) -Rows @(
        @("Ô Tên đăng nhập", "#username", "Input Text", "Required, Trim khoảng trắng", "Nhận chuỗi Username (VD: admin, quanly, khachhang1)."),
        @("Ô Mật khẩu", "#password", "Input Password", "Required, che ký tự bảo mật", "Nhận mật khẩu xác thực (mặc định demo: 123456)."),
        @("Nút Đăng nhập", "button[type=submit]", "Submit Button", "Disable khi đang gọi API", "Gọi POST /api/admin/auth/login, lưu localStorage và chuyển trang theo Role."),
        @("Nút Demo Admin Server", "fillDemo('admin')", "Quick Action Button", "Tự động điền admin / 123456", "Điền nhanh tài khoản Quản trị viên máy chủ để kiểm thử tức thì."),
        @("Nút Demo Quản lý CRM", "fillDemo('quanly')", "Quick Action Button", "Tự động điền quanly / 123456", "Điền nhanh tài khoản Người quản lý CRM để kiểm thử 7 chức năng."),
        @("Liên kết Cổng Khách hàng", "a[href='user.html']", "Navigation Link", "Mở trực tiếp user.html", "Chuyển sang Cổng tự phục vụ dành riêng cho Khách hàng.")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # MÀN HÌNH 2 & 3: ADMIN SERVER — TAB 1: QUẢN LÝ ACCOUNT & PHÂN QUYỀN (admin.html)
    # ==========================================================================
    [void]$sb.Append((New-WHeading3 "3.2.3. Màn hình 2 & 3: Giao diện Admin Server — Quản trị Tài khoản, Thêm/Xóa/Khóa & Phân quyền Account (admin.html)"))
    [void]$sb.Append((New-WImage -RelId "rIdImg11" -WidthEmu 5850000 -HeightEmu 3500000 -Caption "Hình 3.3: Giao diện Admin Server — Tổng quan 4 Chỉ số KPI & Danh sách Quản trị Tài khoản (admin.html)" -DocPrId 111))
    [void]$sb.Append((New-WImage -RelId "rIdImg12" -WidthEmu 5850000 -HeightEmu 2900000 -Caption "Hình 3.4: Bảng Thao tác Phân quyền 3 Vai trò, Khóa/Mở khóa và Xóa Account trên Admin Server" -DocPrId 112))

    [void]$sb.Append((New-WP -Text "1. Giới thiệu chi tiết chức năng: Giao diện admin.html được thiết kế tách biệt hoàn toàn với giao diện của quản lý nhân sự, quản lý kho, quản lý bán hàng và quản lý CRM. Toàn bộ các chức năng xem, tìm kiếm, sắp xếp, lọc sản phẩm và nhà cung cấp đã được loại bỏ hoàn toàn. Màn hình tập trung 100% vào nhiệm vụ quản trị tài khoản máy chủ:" -IndentFirst 420))
    [void]$sb.Append((New-WBullet "• Khu vực 4 Thẻ KPI Máy chủ:" "Hiển thị trực quan Tổng số tài khoản (19), Tài khoản đang hoạt động (17), Tài khoản đã khóa (2) và Tổng số vai trò hệ thống (3)."))
    [void]$sb.Append((New-WBullet "• Thanh công cụ Tìm kiếm, Lọc & Thêm mới:" "Cho phép tìm kiếm tức thời theo Username, Họ tên, Email, SĐT; lọc theo đúng 3 vai trò (Admin, Manager, Customer); và mở Modal '+ Thêm tài khoản mới'."))
    [void]$sb.Append((New-WBullet "• Bảng Quản trị & Phân quyền Account:" "Trên từng dòng tài khoản, Admin có hộp chọn Dropdown chứa đúng 3 quyền (Admin, Manager, Customer) kèm nút 'Phân quyền', nút 'Khóa / Mở khóa' và nút 'Xóa Account'."))

    [void]$sb.Append((New-WTable -Headers @("Tên Điều khiển (Control)", "ID / Hàm JS", "Loại Control", "Hoạt động Xử lý Nghiệp vụ & Kết nối Backend API") -ColWidths @(2200, 2100, 1400, 3900) -Rows @(
        @("4 Thẻ KPI Tài khoản", "#statTotalAccounts...", "Metric Cards", "Tự động tổng hợp số liệu từ phản hồi của API GET /api/admin/accounts."),
        @("Ô Tìm kiếm Tài khoản", "#accountSearchInput", "Search Input", "Lọc thời gian thực bảng tài khoản theo Username, Họ tên, Email hoặc Số điện thoại."),
        @("Bộ lọc Vai trò (3 Role)", "#roleFilterSelect", "Select Dropdown", "Lọc danh sách tài khoản theo 3 vai trò: Admin (1), Manager (2), Customer (3)."),
        @("Nút + Thêm tài khoản mới", "openCreateAccountModal()", "Primary Button", "Mở hộp thoại nhập Username, Password, Họ tên, Email, SĐT, Role và gọi POST /api/admin/accounts."),
        @("Dropdown Chọn Quyền + Nút Phân quyền", "#roleSelect_{id} & changeRole(id)", "Select + Button", "Cho phép chọn Admin / Manager / Customer và gọi PUT /api/admin/accounts/{id}/role để lưu quyền mới."),
        @("Nút Khóa / Mở khóa Account", "toggleAccountStatus(id)", "Warning Button", "Gọi PUT /api/admin/accounts/{id}/toggle-status để đảo trạng thái IsActive (Hoạt động <-> Đã khóa)."),
        @("Nút Xóa Account", "deleteAccount(id)", "Danger Button", "Xác nhận xóa và gọi DELETE /api/admin/accounts/{id} để xóa tài khoản cùng dữ liệu liên kết.")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # MÀN HÌNH 4: ADMIN SERVER — TAB 2: CƠ CẤU PHÂN QUYỀN & MA TRẬN RBAC
    # ==========================================================================
    [void]$sb.Append((New-WHeading3 "3.2.4. Màn hình 4: Giao diện Admin Server — Tab 2: Cơ cấu Phân quyền 3 Vai trò & Ma trận RBAC (admin.html?tab=roles)"))
    [void]$sb.Append((New-WImage -RelId "rIdImg13" -WidthEmu 5850000 -HeightEmu 3550000 -Caption "Hình 3.5: Giao diện Admin Server — Tab 2: Cơ cấu Phân quyền 3 Vai trò & Ma trận Phân tách Hệ thống RBAC" -DocPrId 113))

    [void]$sb.Append((New-WP -Text "1. Giới thiệu chi tiết chức năng & hoạt động: Tab thứ hai trên giao diện Admin Server cung cấp cái nhìn tổng thể về kiến trúc kiểm soát truy cập dựa trên vai trò (Role-Based Access Control – RBAC). Màn hình hiển thị 3 thẻ vai trò chuẩn (Admin: 2 tài khoản, Manager: 2 tài khoản, Customer: 15 tài khoản) cùng bảng Ma trận Phân tách Quyền hạn, chứng minh rõ ràng việc Admin Server được tách biệt độc lập với các phân hệ nghiệp vụ." -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Thành phần Giao diện", "ID / Selector DOM", "Mô tả Hoạt động Hiển thị & Xử lý Dữ liệu") -ColWidths @(2400, 2200, 5000) -Rows @(
        @("Lưới 3 Thẻ Vai trò Hệ thống", "#rolesSummaryGrid", "Đếm tự động số lượng tài khoản thuộc từng vai trò (Admin, Manager, Customer) từ CSDL."),
        @("Bảng Ma trận Phân quyền RBAC", "#rbacMatrixTable", "Hiển thị rõ cổng giao diện riêng biệt (admin.html, quanly.html, user.html) và phạm vi quyền hạn của từng vai trò."),
        @("Nút Chuyển Tab điều hướng", ".nav-item[data-tab='roles']", "Chuyển đổi mượt mà giữa Tab Quản lý Tài khoản và Tab Cơ cấu Phân quyền mà không cần tải lại trang.")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # MÀN HÌNH 5: NGƯỜI QUẢN LÝ CRM — TAB 1: QUẢN LÝ HỒ SƠ KHÁCH HÀNG
    # ==========================================================================
    [void]$sb.Append((New-WHeading3 "3.2.5. Màn hình 5: Giao diện Người Quản lý CRM — Tab 1: Quản lý Khách hàng (Thêm mới, Xóa & Khóa TK Khách hàng)"))
    [void]$sb.Append((New-WImage -RelId "rIdImg14" -WidthEmu 5850000 -HeightEmu 3550000 -Caption "Hình 3.6: Giao diện Người Quản lý CRM — Tab 1: Quản lý Khách hàng (Thêm mới, Xóa & Khóa Tài khoản Khách hàng)" -DocPrId 114))

    [void]$sb.Append((New-WP -Text "1. Giới thiệu chi tiết chức năng: Đây là tab đầu tiên trên giao diện Người Quản lý (quanly.html), trực tiếp giải quyết 3 yêu cầu đầu tiên của Người quản lý trong đề bài: (1) Thêm một khách hàng mới, (2) Xóa khách hàng, (3) Khóa tài khoản khách hàng." -IndentFirst 420))
    [void]$sb.Append((New-WP -Text "2. Hoạt động của phần mềm: Khi tải trang, hàm loadCustomers() trong manager_crm.js gọi GET /api/admin/crm/customers để hiển thị 15 hồ sơ khách hàng kèm 3 thẻ thống kê (Tổng số khách hàng: 15, Đang hoạt động: 13, Tài khoản bị khóa: 2). Người quản lý có thể tìm kiếm khách hàng theo tên/SĐT/email, lọc theo nhóm sở thích, nhấn '+ Thêm một khách hàng mới' để mở Modal tạo khách hàng, hoặc nhấn 'Khóa TK / Mở khóa' và 'Xóa' ngay trên từng dòng khách hàng." -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Tên Điều khiển (Control)", "ID / Hàm JS", "Loại Control", "Hoạt động Xử lý Nghiệp vụ & Kết nối Backend API") -ColWidths @(2200, 2100, 1400, 3900) -Rows @(
        @("3 Thẻ KPI Khách hàng", "#crmTotalCust, #crmActiveCust, #crmLockedCust", "Metric Cards", "Hiển thị Tổng số KH (15), Đang hoạt động (13) và Tài khoản bị khóa (2)."),
        @("Nút + Thêm một khách hàng mới", "openAddCustomerModal()", "Primary Button", "Mở Modal nhập thông tin KH (Username, Password, Họ tên, SĐT, Email, Tuổi, Giới tính, Sở thích, Địa chỉ) -> Gọi POST /api/admin/crm/customers."),
        @("Ô Tìm kiếm & Lọc Sở thích", "#custSearchInput, #custInterestFilter", "Input & Select", "Lọc tức thời danh sách khách hàng theo từ khóa hoặc theo sở thích (Gaming, Đồ họa, Văn phòng, Lập trình)."),
        @("Nút Khóa TK / Mở khóa", "toggleCustomerLock(accountId)", "Warning Button", "Gọi PUT /api/admin/crm/customers/{id}/toggle-status để khóa hoặc mở khóa quyền đăng nhập của khách hàng."),
        @("Nút Xóa Khách hàng", "deleteCustomer(accountId)", "Danger Button", "Gọi DELETE /api/admin/crm/customers/{id} để xóa khách hàng cùng hồ sơ và dữ liệu liên kết.")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # MÀN HÌNH 6: NGƯỜI QUẢN LÝ CRM — TAB 2: TIẾP NHẬN & GIẢI ĐÁP PHẢN HỒI KH
    # ==========================================================================
    [void]$sb.Append((New-WHeading3 "3.2.6. Màn hình 6: Giao diện Người Quản lý CRM — Tab 2: Tiếp nhận & Giải đáp Phản hồi Khách hàng (quanly.html?tab=feedbacks)"))
    [void]$sb.Append((New-WImage -RelId "rIdImg15" -WidthEmu 5850000 -HeightEmu 3550000 -Caption "Hình 3.7: Giao diện Người Quản lý CRM — Tab 2: Tiếp nhận & Giải đáp Phản hồi Khách hàng kèm Biểu đồ Sao" -DocPrId 115))

    [void]$sb.Append((New-WP -Text "1. Giới thiệu chi tiết chức năng: Màn hình thực hiện yêu cầu thứ (4) của Người quản lý: 'Tiếp nhận phản hồi của khách hàng'. Giao diện cung cấp 4 thẻ KPI (Tổng phản hồi, Đã giải đáp, Đang chờ xử lý, Điểm hài lòng trung bình), 2 biểu đồ phân tích trực quan (Phân bổ mức độ hài lòng 1–5 sao & Top sản phẩm nhận nhiều phản hồi nhất) và bảng danh sách phản hồi kèm ảnh sản phẩm." -IndentFirst 420))
    [void]$sb.Append((New-WP -Text "2. Hoạt động của phần mềm: Người quản lý có thể lọc các phản hồi đang ở trạng thái 'Chờ xử lý' hoặc lọc theo số sao (1–5 sao). Khi nhấn nút 'Tiếp nhận & Trả lời', hộp thoại nhập nội dung giải đáp hiện ra. Sau khi nhấn Lưu, phần mềm gọi PUT /api/admin/crm/feedbacks/{id}/reply để cập nhật câu trả lời vào trường AdminReply và chuyển trạng thái sang 'Đã tiếp nhận & Xử lý'." -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Tên Điều khiển (Control)", "ID / Hàm JS", "Loại Control", "Hoạt động Xử lý Nghiệp vụ & Kết nối Backend API") -ColWidths @(2200, 2100, 1400, 3900) -Rows @(
        @("Biểu đồ Phân bổ 1–5 Sao", "#crmRatingBarChart", "Canvas Bar Chart", "Thống kê số lượng đánh giá ở từng mức 1 sao, 2 sao, 3 sao, 4 sao và 5 sao."),
        @("Biểu đồ Top Sản phẩm", "#crmProductReviewChart", "Canvas Chart", "Hiển thị các sản phẩm công nghệ nhận được nhiều lượt phản hồi nhất từ khách hàng."),
        @("Bộ lọc Sao & Trạng thái", "#fbRatingFilter, #fbStatusFilter", "Select Dropdown", "Lọc nhanh các phản hồi Chờ xử lý hoặc các phản hồi 1–2 sao cần ưu tiên giải quyết."),
        @("Nút Tiếp nhận & Trả lời", "openReplyModal(feedbackId)", "Action Button", "Mở hộp thoại nhập câu trả lời giải đáp và gọi PUT /api/admin/crm/feedbacks/{id}/reply.")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # MÀN HÌNH 7: NGƯỜI QUẢN LÝ CRM — TAB 3: BÁO CÁO ĐỘ TUỔI & SỞ THÍCH
    # ==========================================================================
    [void]$sb.Append((New-WHeading3 "3.2.7. Màn hình 7: Giao diện Người Quản lý CRM — Tab 3: Báo cáo về Khách hàng, Tỷ lệ Độ tuổi & Sở thích (quanly.html?tab=demographics)"))
    [void]$sb.Append((New-WImage -RelId "rIdImg16" -WidthEmu 5850000 -HeightEmu 3550000 -Caption "Hình 3.8: Giao diện Người Quản lý CRM — Tab 3: Báo cáo về Khách hàng, Tỷ lệ Độ tuổi & Sở thích" -DocPrId 116))

    [void]$sb.Append((New-WP -Text "1. Giới thiệu chi tiết chức năng: Màn hình thực hiện yêu cầu thứ (5) của Người quản lý: 'Báo cáo về khách hàng, tỷ lệ độ tuổi, sở thích'. Giao diện được bố cục gồm 3 thẻ chỉ số tổng hợp (Độ tuổi trung bình: 25.5 tuổi; Phân khúc tuổi lớn nhất: Từ 20 - 25 tuổi (Trẻ); Sở thích phổ biến nhất: Gaming), 2 biểu đồ đồ họa sắc nét (Biểu đồ Tỷ lệ Độ tuổi Khách hàng & Biểu đồ Phân bố Sở thích Khách hàng) và 2 bảng phân tích chi tiết từng phân khúc." -IndentFirst 420))
    [void]$sb.Append((New-WP -Text "2. Hoạt động của phần mềm: Khi chuyển sang Tab 3, hàm loadDemographicsReport() gọi API GET /api/admin/crm/reports/demographics, tính toán số lượng và tỷ lệ % của từng nhóm độ tuổi cũng như từng nhóm sở thích tiêu dùng, sau đó tự động vẽ biểu đồ tròn (Doughnut Chart), biểu đồ cột (Bar Chart) và thanh tiến trình tỷ lệ % trong bảng." -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Tên Điều khiển (Control)", "ID / Hàm JS", "Loại Control", "Hoạt động Xử lý Nghiệp vụ & Kết nối Backend API") -ColWidths @(2200, 2100, 1400, 3900) -Rows @(
        @("3 Thẻ Chỉ số Nhân khẩu học", "#demoAvgAge, #demoTopAgeGroup, #demoTopInterest", "Summary Cards", "Tính toán độ tuổi trung bình, nhóm tuổi chiếm tỷ trọng cao nhất và sở thích dẫn đầu."),
        @("Biểu đồ Tỷ lệ Độ tuổi", "#agePieChart", "Doughnut Chart", "Biểu diễn trực quan tỷ lệ % các phân khúc độ tuổi của khách hàng SGU Tech."),
        @("Biểu đồ Phân bố Sở thích", "#interestBarChart", "Bar Chart", "Biểu diễn số lượng và tỷ lệ % khách hàng theo từng nhóm sở thích (Gaming, Văn phòng, Đồ họa, Lập trình)."),
        @("2 Bảng Phân tích Chi tiết", "#ageDetailTableBody, #interestDetailTableBody", "Data Tables", "Hiển thị số lượng khách hàng, tỷ lệ % kèm thanh Progress Bar trực quan và gợi ý chiến lược sản phẩm.")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # MÀN HÌNH 8: NGƯỜI QUẢN LÝ CRM — TAB 4: TẠO & PHÁT HÀNH BẢNG KHẢO SÁT
    # ==========================================================================
    [void]$sb.Append((New-WHeading3 "3.2.8. Màn hình 8: Giao diện Người Quản lý CRM — Tab 4: Tạo Bảng Khảo sát và Gửi đến Tài khoản Khách hàng (quanly.html?tab=surveys)"))
    [void]$sb.Append((New-WImage -RelId "rIdImg17" -WidthEmu 5850000 -HeightEmu 3550000 -Caption "Hình 3.9: Giao diện Người Quản lý CRM — Tab 4: Tạo & Phát hành Bảng Khảo sát gửi đến Tài khoản Khách hàng" -DocPrId 117))

    [void]$sb.Append((New-WP -Text "1. Giới thiệu chi tiết chức năng: Màn hình thực hiện yêu cầu thứ (6) của Người quản lý: 'Tạo bảng khảo sát và gửi đến tài khoản khách hàng'. Khu vực phía trên là biểu mẫu khởi tạo chiến dịch khảo sát mới; khu vực phía dưới là bảng quản lý danh sách các chiến dịch khảo sát đã phát hành kèm tiến độ thu thập phiếu." -IndentFirst 420))
    [void]$sb.Append((New-WP -Text "2. Hoạt động của phần mềm: Người quản lý điền Tiêu đề khảo sát, Tên sản phẩm khảo sát, Giá dự kiến, Thời hạn hoàn thành và Mô tả khảo sát rồi nhấn 'Phát hành & Gửi đến Khách hàng'. Phần mềm gọi POST /api/admin/crm/surveys để lưu vào bảng Surveys và phân phối tự động tới tất cả tài khoản khách hàng. Ngoài ra, Người quản lý có thể Khóa/Mở khóa khảo sát (PUT /api/admin/crm/surveys/{id}/toggle-lock) hoặc Xóa khảo sát (DELETE /api/admin/crm/surveys/{id})." -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Tên Điều khiển (Control)", "ID / Hàm JS", "Loại Control", "Hoạt động Xử lý Nghiệp vụ & Kết nối Backend API") -ColWidths @(2200, 2100, 1400, 3900) -Rows @(
        @("Ô Tiêu đề & Sản phẩm KS", "#surveyTitle, #surveyProduct", "Input Text", "Nhập tiêu đề chiến dịch và tên dòng sản phẩm công nghệ dự kiến ra mắt."),
        @("Ô Giá bán dự kiến & Hạn", "#surveyPrice, #surveyDeadline", "Input Number/Date", "Nhập mức giá thăm dò (VNĐ) và thời hạn kết thúc nhận phiếu khảo sát."),
        @("Ô Mô tả nội dung khảo sát", "#surveyDesc", "Textarea", "Nhập mô tả tính năng, công nghệ và câu hỏi định hướng cho khách hàng."),
        @("Nút Phát hành & Gửi đến KH", "createSurvey(event)", "Submit Button", "Gọi POST /api/admin/crm/surveys, phát hành bảng khảo sát tới toàn bộ tài khoản khách hàng."),
        @("Nút Đóng/Mở & Xóa Khảo sát", "toggleSurveyStatus(id), deleteSurvey(id)", "Action Buttons", "Khóa/mở khóa nhận phản hồi hoặc xóa chiến dịch khảo sát khỏi hệ thống.")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # MÀN HÌNH 9: NGƯỜI QUẢN LÝ CRM — TAB 5: THỐNG KÊ KẾT QUẢ KHẢO SÁT
    # ==========================================================================
    [void]$sb.Append((New-WHeading3 "3.2.9. Màn hình 9: Giao diện Người Quản lý CRM — Tab 5: Thống kê & Đo lường Kết quả Khảo sát (quanly.html?tab=surveystats)"))
    [void]$sb.Append((New-WImage -RelId "rIdImg18" -WidthEmu 5850000 -HeightEmu 3550000 -Caption "Hình 3.10: Giao diện Người Quản lý CRM — Tab 5: Thống kê & Đo lường Kết quả Khảo sát" -DocPrId 118))

    [void]$sb.Append((New-WP -Text "1. Giới thiệu chi tiết chức năng: Màn hình thực hiện yêu cầu thứ (7) của Người quản lý: 'Thống kê kết quả khảo sát'. Giao diện hiển thị 4 thẻ KPI khảo sát (Tổng chiến dịch khảo sát: 5; Tổng lượt KH trả lời: 16; Điểm quan tâm TB: 4.6 / 5; Tỷ lệ rất muốn mua: 69%), 2 biểu đồ phân tích (Biểu đồ Phân bố Ý định Mua sắm & Biểu đồ Điểm Quan tâm Trung bình theo từng Khảo sát), bảng tổng hợp tỷ lệ tham gia từng chiến dịch và bảng danh sách chi tiết toàn bộ 16 phiếu trả lời của khách hàng." -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Tên Điều khiển (Control)", "ID / Hàm JS", "Loại Control", "Hoạt động Xử lý Nghiệp vụ & Kết nối Backend API") -ColWidths @(2200, 2100, 1400, 3900) -Rows @(
        @("4 Thẻ KPI Thống kê Khảo sát", "#statTotalSurveys, #statTotalResponses...", "Metric Cards", "Tổng hợp số chiến dịch, tổng số phiếu thu về, điểm quan tâm trung bình và tỷ lệ muốn mua."),
        @("Biểu đồ Ý định Mua sắm", "#surveyIntentChart", "Doughnut Chart", "Biểu diễn tỷ lệ khách hàng chọn: Rất muốn mua, Có thể mua / Đang cân nhắc, Không mua."),
        @("Biểu đồ Điểm Quan tâm TB", "#surveyScoreChart", "Bar Chart", "So sánh điểm mức độ quan tâm trung bình (thang 1–5) giữa các chiến dịch khảo sát."),
        @("Bảng Tổng hợp & Bảng Chi tiết", "#surveySummaryTableBody, #surveyResponsesTableBody", "Data Tables", "Liệt kê tỷ lệ tham gia (%) của từng chiến dịch và chi tiết từng câu trả lời của khách hàng.")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # MÀN HÌNH 10: CỔNG KHÁCH HÀNG — ĐĂNG KÝ & ĐĂNG NHẬP (user.html)
    # ==========================================================================
    [void]$sb.Append((New-WHeading3 "3.2.10. Màn hình 10: Giao diện Cổng Khách hàng — Đăng ký Tài khoản & Đăng nhập (user.html)"))
    [void]$sb.Append((New-WImage -RelId "rIdImg20" -WidthEmu 4800000 -HeightEmu 3400000 -Caption "Hình 3.11: Giao diện Cổng Khách hàng — Biểu mẫu Đăng ký Tài khoản Khách hàng mới (user.html)" -DocPrId 120))
    [void]$sb.Append((New-WImage -RelId "rIdImg21" -WidthEmu 4800000 -HeightEmu 3100000 -Caption "Hình 3.12: Giao diện Cổng Khách hàng — Biểu mẫu Đăng nhập Tài khoản Khách hàng (user.html)" -DocPrId 121))

    [void]$sb.Append((New-WP -Text "1. Giới thiệu chi tiết chức năng & hoạt động: Thực hiện 2 nghiệp vụ đầu tiên của Khách hàng: (1) Đăng ký tài khoản khách hàng và (2) Đăng nhập. Biểu mẫu được thiết kế tinh gọn, hiện đại. Khi khách hàng điền thông tin đăng ký và nhấn 'Hoàn tất đăng ký', hàm handleCustomerRegister() gọi POST /api/customer/register để tạo đồng bộ bản ghi Accounts + CustomerProfiles và tự động đăng nhập thẳng vào Cổng Khách hàng." -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Tên Điều khiển (Control)", "ID / Hàm JS", "Loại Control", "Hoạt động Xử lý Nghiệp vụ & Kết nối Backend API") -ColWidths @(2200, 2100, 1400, 3900) -Rows @(
        @("Tab Chuyển đổi Đăng nhập / Đăng ký", "switchAuthTab('login' | 'register')", "Tab Buttons", "Chuyển đổi mượt mà giữa biểu mẫu Đăng nhập và biểu mẫu Đăng ký tài khoản mới."),
        @("Biểu mẫu Đăng nhập KH", "#custLoginForm", "Form Submit", "Gọi POST /api/customer/login; kiểm tra trạng thái khóa IsActive và mở giao diện Cổng Khách hàng."),
        @("Biểu mẫu Đăng ký KH", "#custRegisterForm", "Form Submit", "Gọi POST /api/customer/register; tạo tài khoản Customer + hồ sơ nhân khẩu học và tự động đăng nhập.")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # MÀN HÌNH 11: CỔNG KHÁCH HÀNG — TAB 1: GỬI PHẢN HỒI SẢN PHẨM & LỌC XEM GIẢI ĐÁP
    # ==========================================================================
    [void]$sb.Append((New-WHeading3 "3.2.11. Màn hình 11: Giao diện Cổng Khách hàng — Tab 1: Gửi Phản hồi về Sản phẩm & Lọc theo Sản phẩm (user.html?tab=feedback)"))
    [void]$sb.Append((New-WImage -RelId "rIdImg22" -WidthEmu 5850000 -HeightEmu 3350000 -Caption "Hình 3.13: Giao diện Khách hàng — Biểu mẫu Gửi Phản hồi về Sản phẩm & Theo dõi Giải đáp từ Người quản lý" -DocPrId 122))
    [void]$sb.Append((New-WImage -RelId "rIdImg19" -WidthEmu 5850000 -HeightEmu 3100000 -Caption "Hình 3.14: Chức năng Lọc xem Đánh giá & Phản hồi theo từng Sản phẩm Công nghệ trên Cổng Khách hàng" -DocPrId 119))

    [void]$sb.Append((New-WP -Text "1. Giới thiệu chi tiết chức năng & hoạt động: Thực hiện yêu cầu thứ (4) của Khách hàng: 'Gửi phản hồi về sản phẩm'. Khách hàng chọn sản phẩm từ hộp chọn 16 sản phẩm công nghệ, chọn mức độ hài lòng (1–5 sao), nhập nhận xét và nhấn 'Gửi phản hồi' (POST /api/customer/feedbacks/{accountId}). Phía dưới là bảng danh sách phản hồi tích hợp bộ lọc theo từng sản phẩm (GET /api/customer/all-feedbacks?productId=...) và hiển thị rõ cột 'Phản hồi tiếp nhận từ Người quản lý'." -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Tên Điều khiển (Control)", "ID / Hàm JS", "Loại Control", "Hoạt động Xử lý Nghiệp vụ & Kết nối Backend API") -ColWidths @(2200, 2100, 1400, 3900) -Rows @(
        @("Hộp chọn Sản phẩm cần phản hồi", "#fbProductSelect", "Select Dropdown", "Hiển thị danh sách 16 sản phẩm công nghệ từ API GET /api/products."),
        @("Hộp chọn Mức độ hài lòng", "#fbRatingSelect", "Select (1–5 sao)", "Cho phép khách hàng chấm điểm từ 1 Sao (Rất tệ) đến 5 Sao (Rất hài lòng)."),
        @("Ô Nội dung phản hồi & Nút Gửi", "#fbCommentInput & submitCustomerFeedback()", "Input + Button", "Gọi POST /api/customer/feedbacks/{accountId} để lưu phản hồi mới vào bảng Feedbacks."),
        @("Bộ lọc Xem theo Sản phẩm", "#publicFbProductFilter", "Filter Select", "Gọi GET /api/customer/all-feedbacks?productId={id} để lọc đánh giá của từng sản phẩm.")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # MÀN HÌNH 12 & 13: CỔNG KHÁCH HÀNG — TAB 2 (KHẢO SÁT) & TAB 3 (HỒ SƠ CÁ NHÂN)
    # ==========================================================================
    [void]$sb.Append((New-WHeading3 "3.2.12. Màn hình 12: Giao diện Cổng Khách hàng — Tab 2: Nhận được Khảo sát và Thực hiện (user.html?tab=surveys)"))
    [void]$sb.Append((New-WImage -RelId "rIdImg23" -WidthEmu 5850000 -HeightEmu 3550000 -Caption "Hình 3.15: Giao diện Khách hàng — Nhận được Bảng Khảo sát và Hộp thoại Thực hiện Khảo sát" -DocPrId 123))

    [void]$sb.Append((New-WP -Text "1. Giới thiệu chi tiết chức năng & hoạt động: Thực hiện yêu cầu thứ (5) của Khách hàng: 'Nhận được khảo sát và thực hiện'. Trên thanh menu của khách hàng hiển thị huy hiệu đỏ báo số khảo sát mới chưa thực hiện (VD: '2 mới'). Khi nhấn nút 'Thực hiện khảo sát', hộp thoại Modal mở ra hiển thị tên sản phẩm khảo sát, mức giá dự kiến và 3 câu hỏi chuẩn: (1) Đánh giá mức độ quan tâm (1–5 điểm), (2) Ý định mua sắm khi sản phẩm ra mắt, (3) Ý kiến đóng góp cho sản phẩm mới. Khi nhấn 'Gửi kết quả khảo sát', phần mềm gọi POST /api/customer/surveys/{surveyId}/submit/{accountId} để lưu phiếu trả lời vào CSDL." -IndentFirst 420))

    [void]$sb.Append((New-WHeading3 "3.2.13. Màn hình 13: Giao diện Cổng Khách hàng — Tab 3: Chỉnh sửa Thông tin Tài khoản Khách hàng (user.html?tab=profile)"))
    [void]$sb.Append((New-WImage -RelId "rIdImg24" -WidthEmu 5850000 -HeightEmu 3400000 -Caption "Hình 3.16: Giao diện Khách hàng — Chỉnh sửa Thông tin Cá nhân (Họ tên, SĐT, Độ tuổi, Giới tính, Sở thích, Địa chỉ)" -DocPrId 124))

    [void]$sb.Append((New-WP -Text "1. Giới thiệu chi tiết chức năng & hoạt động: Thực hiện yêu cầu thứ (3) của Khách hàng: 'Chỉnh sửa thông tin'. Cột bên trái hiển thị Thẻ định danh khách hàng (Avatar chữ cái, Họ tên, @username, tổng số phản hồi đã gửi, tổng số khảo sát đã làm, trạng thái tài khoản, độ tuổi, sở thích). Cột bên phải là biểu mẫu cho phép khách hàng chỉnh sửa Họ và tên, Số điện thoại, Email, Độ tuổi, Giới tính, Sở thích tiêu dùng và Địa chỉ chi tiết. Khi nhấn 'Lưu chỉnh sửa thông tin', hệ thống gọi PUT /api/customer/profile/{accountId} cập nhật tức thời vào SQL Server." -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Tên Điều khiển (Control)", "ID / Hàm JS", "Loại Control", "Hoạt động Xử lý Nghiệp vụ & Kết nối Backend API") -ColWidths @(2200, 2100, 1400, 3900) -Rows @(
        @("Huy hiệu Khảo sát mới", "#newSurveyBadge", "Notification Badge", "Đếm số bảng khảo sát đang mở mà tài khoản khách hàng hiện tại chưa thực hiện."),
        @("Hộp thoại Thực hiện Khảo sát", "#surveyModal, submitSurveyResponse()", "Modal Form", "Chọn điểm quan tâm (1–5), ý định mua, nhập góp ý và gọi POST /api/customer/surveys/{id}/submit/{aid}."),
        @("Thẻ Định danh Cá nhân", "#profileSummaryCard", "Profile Card", "Hiển thị đồng bộ Avatar, Họ tên, @username, số phản hồi, số khảo sát, độ tuổi và sở thích."),
        @("Biểu mẫu Chỉnh sửa Thông tin", "#profileEditForm, saveCustomerProfile()", "Form Submit", "Cập nhật Họ tên, SĐT, Email, Tuổi, Giới tính, Sở thích, Địa chỉ qua PUT /api/customer/profile/{accountId}.")
    )))

    [void]$sb.Append((New-WPageBreak))
    return $sb.ToString()
}
