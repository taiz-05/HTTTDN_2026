# ==============================================================================
# PART 2: CHƯƠNG 2 (MỤC 2.1) — BÀI TOÁN MÔ TẢ CHI TIẾT CÁC HOẠT ĐỘNG HTTT DN
# BAO GỒM 20 QUY TẮC NGHIỆP VỤ (BR) & 15 HỒ SƠ ĐẶC TẢ USE CASE CHI TIẾT
# ==============================================================================

function New-UseCaseSpec {
    param(
        [string]$UcId,
        [string]$UcName,
        [string]$Actor,
        [string]$Endpoint,
        [string]$UiScreen,
        [string]$Goal,
        [string]$PreCond,
        [string]$PostCond,
        [string]$MainFlow,
        [string]$AltFlow,
        [string]$RulesAndTables,
        [string]$JsonSample
    )
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append((New-WHeading4 "Đặc tả Quy trình Nghiệp vụ $UcId : $UcName"))
    [void]$sb.Append((New-WTable -Headers @("Thuộc tính Đặc tả", "Nội dung Chi tiết Quy trình Nghiệp vụ $UcId") -ColWidths @(2400, 7200) -Rows @(
        @("Mã & Tên Quy trình", "$UcId — $UcName"),
        @("Tác nhân thực hiện (Actor)", $Actor),
        @("Giao diện & API Endpoint", "Giao diện: $UiScreen  |  RESTful API: $Endpoint"),
        @("Mục tiêu nghiệp vụ", $Goal),
        @("Điều kiện tiên quyết (Pre-conditions)", $PreCond),
        @("Luồng sự kiện chính (Main Success Flow)", $MainFlow),
        @("Luồng rẽ nhánh & Ngoại lệ (Exception Flows)", $AltFlow),
        @("Điều kiện hoàn tất (Post-conditions)", $PostCond),
        @("Quy tắc nghiệp vụ & Bảng CSDL tác động", $RulesAndTables)
    )))
    if ($JsonSample -ne "") {
        [void]$sb.Append((New-WCodeBlock -Title "Cấu trúc Gói tin Giao tiếp JSON / Thực thi Backend của $UcId ($Endpoint):" -CodeText $JsonSample))
    }
    return $sb.ToString()
}

function Build-Part2-Chapter2-UseCases {
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.Append((New-WHeading1 "CHƯƠNG 2: PHÂN TÍCH HỆ THỐNG THÔNG TIN CỦA DOANH NGHIỆP (10 ĐIỂM)"))
    [void]$sb.Append((New-WHeading2 "2.1. Bài toán mô tả chi tiết và đầy đủ cho các hoạt động của HTTT Doanh nghiệp (2 điểm)"))

    [void]$sb.Append((New-WHeading3 "2.1.1. Mô tả tổng thể bài toán và Nguyên tắc Phân tách Hệ thống"))
    [void]$sb.Append((New-WP -Text "Bài toán trung tâm của Hệ thống Thông tin Doanh nghiệp tại Công ty Cổ phần Công nghệ SGU Tech là thiết kế và vận hành một nền tảng phần mềm Web 3 tầng thống nhất trên cùng một Cơ sở dữ liệu Microsoft SQL Server (HTTTDN_DB), nhưng được phân tách nghiêm ngặt thành 3 không gian làm việc độc lập tương ứng với 3 tác nhân:" -IndentFirst 420))
    [void]$sb.Append((New-WBullet "1. Không gian Quản trị Máy chủ (Admin Server — admin.html):" "Được tách biệt hoàn toàn với giao diện của quản lý nhân sự, quản lý kho, quản lý bán hàng và quản lý quan hệ khách hàng. Toàn bộ các chức năng xem, tìm kiếm nâng cao, sắp xếp và lọc sản phẩm, nhà cung cấp đã được loại bỏ khỏi giao diện Admin. Admin Server chỉ thực hiện các nghiệp vụ cốt lõi: Xem danh sách tài khoản, Tìm kiếm & lọc tài khoản theo 3 vai trò, Thêm tài khoản mới, Xóa tài khoản, Khóa/Mở khóa tài khoản và Phân quyền vai trò (Admin, Manager, Customer) cho từng Account."))
    [void]$sb.Append((New-WBullet "2. Không gian Người Quản lý Quan hệ Khách hàng (CRM Manager — quanly.html):" "Thực hiện đầy đủ 7 nghiệp vụ cốt lõi của Người quản lý: (1) Thêm một khách hàng mới; (2) Xóa khách hàng; (3) Khóa tài khoản khách hàng; (4) Tiếp nhận phản hồi của khách hàng và gửi câu trả lời giải đáp; (5) Báo cáo về khách hàng: thống kê tỷ lệ độ tuổi và sở thích; (6) Tạo bảng khảo sát và gửi đến tài khoản khách hàng; (7) Thống kê kết quả khảo sát."))
    [void]$sb.Append((New-WBullet "3. Không gian Cổng Khách hàng Trực tuyến (Customer Portal — user.html):" "Thực hiện đầy đủ 5 nghiệp vụ cốt lõi của Khách hàng: (1) Đăng ký tài khoản khách hàng; (2) Đăng nhập; (3) Chỉnh sửa thông tin cá nhân; (4) Gửi phản hồi về sản phẩm và xem giải đáp từ Người quản lý; (5) Nhận được bảng khảo sát trong tài khoản và thực hiện khảo sát."))

    [void]$sb.Append((New-WHeading3 "2.1.2. Hệ thống 20 Quy tắc Nghiệp vụ (Business Rules) của Hệ thống"))
    [void]$sb.Append((New-WP -Text "Mọi hoạt động xử lý dữ liệu tại tầng giao diện (Frontend) và tầng điều khiển (Backend API Controllers) đều tuân thủ nghiêm ngặt 20 quy tắc nghiệp vụ chuẩn hóa dưới đây:" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Mã QT", "Tên Quy tắc Nghiệp vụ", "Phân hệ áp dụng", "Mô tả chi tiết điều kiện kiểm tra và cơ chế xử lý trong phần mềm") -ColWidths @(850, 2150, 1400, 5200) -Rows @(
        @("BR-01", "Tách biệt tuyệt đối giao diện Admin Server", "Admin Server", "Khi đăng nhập với RoleName = 'Admin', hệ thống chỉ điều hướng vào admin.html. Giao diện này hoàn toàn không chứa bất kỳ menu hay bảng dữ liệu nào của Nhân sự, Kho, Bán hàng, Sản phẩm hay Nhà cung cấp."),
        @("BR-02", "Chuẩn hóa duy nhất 3 Vai trò hệ thống", "Toàn hệ thống", "Bảng Roles trong CSDL chỉ duy trì đúng 3 vai trò: RoleId = 1 (Admin), RoleId = 2 (Manager), RoleId = 3 (Customer). Mọi vai trò dư thừa (HR, Warehouse, Sales) đã được loại bỏ hoàn toàn."),
        @("BR-03", "Kiểm tra tính duy nhất của Username", "Admin / CRM / KH", "Trường Username trong bảng Accounts là duy nhất (UNIQUE, không phân biệt hoa thường). Khi thêm tài khoản hoặc đăng ký mới, nếu trùng Username hệ thống trả về HTTP 400 BadRequest."),
        @("BR-04", "Mã hóa mật khẩu chuẩn BCrypt", "Toàn hệ thống", "Mọi mật khẩu khi tạo mới qua API (AccountsController, CrmAdminController, CustomerPortalController) đều được băm an toàn bằng thuật toán BCrypt.Net.BCrypt.HashPassword()."),
        @("BR-05", "Tự động chuẩn hóa Email mặc định", "Admin / CRM / KH", "Nếu người dùng hoặc Admin không nhập Email khi tạo tài khoản mới, hệ thống tự động sinh Email chuẩn theo mẫu {username}@sgutech.vn hoặc {username}@customer.sgutech.vn."),
        @("BR-06", "Đồng bộ tự động Account – CustomerProfile", "Admin / CRM / KH", "Khi tạo mới một Account có Role = 'Customer' hoặc khi Admin đổi quyền một Account sang 'Customer', hệ thống tự động kiểm tra và khởi tạo bản ghi tương ứng trong bảng CustomerProfiles."),
        @("BR-07", "Chặn đăng nhập đối với tài khoản bị khóa", "Xác thực (Auth)", "Tại AuthController và CustomerPortalController, nếu tài khoản có IsActive == false, hệ thống lập tức từ chối đăng nhập với mã HTTP 401 Unauthorized và thông báo tài khoản đã bị khóa."),
        @("BR-08", "Phân luồng cổng đăng nhập theo vai trò", "Xác thực (Auth)", "Nếu tài khoản thuộc quyền Admin hoặc Manager cố tình đăng nhập tại cổng khách hàng (/api/customer/login), hệ thống chặn và yêu cầu đăng nhập tại Cổng Nội Bộ (login.html)."),
        @("BR-09", "Xóa dây chuyền an toàn (Safe Cascade Delete)", "Admin / CRM", "Khi Admin xóa Account hoặc Người quản lý xóa Khách hàng, hệ thống tự động xóa trước các bản ghi liên kết trong CustomerProfiles, Feedbacks và SurveyResponses rồi mới xóa bản ghi trong Accounts."),
        @("BR-10", "Ràng buộc miền giá trị Độ tuổi Khách hàng", "CRM / Khách hàng", "Trường Age trong CustomerProfiles phải là số nguyên dương (mặc định 20 nếu bỏ trống). Khi báo cáo nhân khẩu học, hệ thống phân thành 3 nhóm chuẩn: Dưới 20 tuổi (<20), Từ 20–30 tuổi (20..30) và Trên 30 tuổi (>30)."),
        @("BR-11", "Chuẩn hóa danh mục Sở thích tiêu dùng", "CRM / Khách hàng", "Trường Interest của khách hàng được chuẩn hóa theo các nhóm sở thích công nghệ chủ đạo: Gaming, Đồ họa, Văn phòng, Lập trình (và Khác nếu chưa xác định)."),
        @("BR-12", "Công thức tính Tỷ lệ % Sở thích Khách hàng", "Báo cáo CRM", "Tỷ lệ phần trăm của mỗi nhóm sở thích được tính theo công thức: Percentage = Math.Round((double)GroupCount * 100 / TotalProfiles, 1)."),
        @("BR-13", "Ràng buộc thang điểm Đánh giá Sản phẩm", "Phản hồi SP", "Trường Rating trong bảng Feedbacks bắt buộc là số nguyên từ 1 đến 5 (CHECK Rating >= 1 AND Rating <= 5) và phải gắn với một ProductId hợp lệ trong bảng Products."),
        @("BR-14", "Trạng thái vòng đời của Phản hồi Sản phẩm", "Phản hồi SP", "Khi khách hàng mới gửi phản hồi, Status mặc định là 'Chờ xử lý' và AdminReply = NULL. Ngay khi Người quản lý gửi câu trả lời giải đáp, Status tự động chuyển thành 'Đã tiếp nhận & Xử lý'."),
        @("BR-15", "Lọc phản hồi công khai theo từng Sản phẩm", "Cổng Khách hàng", "API GET /api/customer/all-feedbacks hỗ trợ tham số truy vấn ?productId={id}, cho phép khách hàng xem toàn bộ đánh giá hoặc lọc riêng đánh giá của từng sản phẩm công nghệ."),
        @("BR-16", "Cơ chế thiết lập Thời hạn Bảng khảo sát", "Khảo sát CRM", "Khi tạo khảo sát, Người quản lý có thể chọn 3 chế độ thời hạn (DurationType): 'NoLimit' (ExpiresAt = NULL), 'Days' (ExpiresAt = Now + DurationDays), hoặc 'Date' (ExpiresAt = 23:59:59 của ngày chọn)."),
        @("BR-17", "Phân phối Khảo sát đến toàn bộ Khách hàng", "Khảo sát CRM", "Mỗi bảng khảo sát khi tạo mới có IsActive = true và được gửi tự động đến toàn bộ các tài khoản khách hàng đang hoạt động (RoleName == 'Customer' && IsActive == true)."),
        @("BR-18", "Kiểm tra Khóa & Hết hạn khi nộp Khảo sát", "Khách hàng", "Khi khách hàng gửi phiếu khảo sát, nếu survey.IsActive == false hoặc survey.ExpiresAt < DateTime.Now, hệ thống từ chối nhận phiếu và trả về thông báo lỗi HTTP 400."),
        @("BR-19", "Chống gửi trùng lặp Phiếu trả lời Khảo sát", "Khách hàng", "Hệ thống kiểm tra _context.SurveyResponses.AnyAsync(r => r.SurveyId == surveyId && r.AccountId == accountId). Mỗi khách hàng chỉ được gửi kết quả tối đa 01 lần cho mỗi bảng khảo sát."),
        @("BR-20", "Tổng hợp Thống kê Kết quả Khảo sát", "Thống kê CRM", "Với mỗi khảo sát, hệ thống tự động tính Tổng số phản hồi (totalResponses), Điểm quan tâm trung bình (averageScore = Average(Score)), Phân bổ 3 nhóm ý định mua (Rất muốn mua, Đang cân nhắc, Không mua) và Phân bổ điểm 1–5.")
    )))

    [void]$sb.Append((New-WPageBreak))

    [void]$sb.Append((New-WHeading3 "2.1.3. Hồ sơ Đặc tả Chi tiết 15 Quy trình Nghiệp vụ Cốt lõi (Detailed Use Case Specifications)"))
    [void]$sb.Append((New-WP -Text "Để làm cơ sở vững chắc cho việc vẽ các sơ đồ BFD, Context Diagram, DFD ở các mục tiếp theo cũng như thiết kế CSDL và lập trình phần mềm, dưới đây là 15 hồ sơ đặc tả quy trình nghiệp vụ (Use Case Specifications) chi tiết cho toàn bộ các chức năng của 3 phân hệ:" -IndentFirst 420))

    # UC-01
    [void]$sb.Append((New-UseCaseSpec -UcId "UC-01" -UcName "Đăng nhập Tập trung & Phân luồng Tách biệt Giao diện theo Vai trò" `
        -Actor "Quản trị viên Máy chủ (Admin), Người Quản lý (Manager), Khách hàng (Customer)" `
        -Endpoint "POST /api/admin/auth/login & POST /api/customer/login" `
        -UiScreen "Frontend_Admin/login.html & Frontend_Admin/user.html" `
        -Goal "Xác thực định danh tài khoản, kiểm tra trạng thái khóa (IsActive) và điều hướng người dùng vào đúng không gian giao diện tách biệt của vai trò đó." `
        -PreCond "Tài khoản đã tồn tại trong bảng Accounts và được gán RoleId hợp lệ (1: Admin, 2: Manager, 3: Customer)." `
        -PostCond "Lưu thông tin phiên làm việc vào localStorage và chuyển hướng tự động tới admin.html (nếu là Admin), quanly.html (nếu là Manager) hoặc user.html (nếu là Customer)." `
        -MainFlow "1. Người dùng nhập Tên đăng nhập (Username) và Mật khẩu (Password) trên màn hình login.html, sau đó nhấn nút 'Đăng nhập vào Hệ thống'.`n2. Hàm xử lý sự kiện tại Frontend gửi yêu cầu HTTP POST /api/admin/auth/login kèm gói JSON { username, password }.`n3. AuthController.Login() truy vấn bảng Accounts kết hợp Include(a => a.Role) theo Username (không phân biệt hoa thường).`n4. Hệ thống kiểm tra trạng thái acc.IsActive == true và đối chiếu mật khẩu (hỗ trợ cả mật khẩu thuần demo và mã băm BCrypt).`n5. Hệ thống trả về HTTP 200 OK kèm thông tin { accountId, username, fullName, roleId, roleName }.`n6. Frontend kiểm tra roleName: nếu là 'Admin' điều hướng tới admin.html; nếu là 'Manager' điều hướng tới quanly.html; nếu là 'Customer' điều hướng tới user.html." `
        -AltFlow "• Nhánh 3a (Bỏ trống thông tin): Trả về HTTP 400 BadRequest: 'Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu!'.`n• Nhánh 4a (Tài khoản không tồn tại): Trả về HTTP 401 Unauthorized: 'Tài khoản không tồn tại!'.`n• Nhánh 4b (Tài khoản đang bị khóa IsActive = false): Trả về HTTP 401 Unauthorized: 'Tài khoản này đã bị khóa!'.`n• Nhánh 4c (Sai mật khẩu): Trả về HTTP 401 Unauthorized: 'Sai mật khẩu!'." `
        -RulesAndTables "Áp dụng quy tắc BR-01, BR-02, BR-04, BR-07, BR-08. Tác động đọc (READ) trên bảng Accounts và Roles." `
        -JsonSample @"
// Request: POST /api/admin/auth/login
{
  "username": "admin",
  "password": "123456"
}
// Response: 200 OK
{
  "accountId": 1,
  "username": "admin",
  "fullName": "Nguyễn Quản Trị Hệ Thống",
  "roleId": 1,
  "roleName": "Admin"
}
"@))

    # UC-02
    [void]$sb.Append((New-UseCaseSpec -UcId "UC-02" -UcName "[Admin Server] Xem, Tìm kiếm và Lọc Danh sách Tài khoản Hệ thống" `
        -Actor "Quản trị viên Máy chủ (Admin)" `
        -Endpoint "GET /api/admin/accounts & GET /api/admin/accounts/roles" `
        -UiScreen "Frontend_Admin/admin.html (Tab 1: Quản lý Tài khoản & Phân quyền)" `
        -Goal "Cho phép Admin Server theo dõi toàn bộ danh sách tài khoản trên máy chủ, thống kê 4 chỉ số KPI và tìm kiếm/lọc tài khoản theo từ khóa hoặc theo 3 vai trò chuẩn." `
        -PreCond "Admin đã đăng nhập thành công và đang ở giao diện tách biệt admin.html." `
        -PostCond "Hiển thị đầy đủ danh sách 19 tài khoản, 4 thẻ KPI (Tổng tài khoản, Đang hoạt động, Đã khóa, Tổng vai trò) và danh sách phân quyền." `
        -MainFlow "1. Khi mở admin.html, hàm loadAccountsAndRoles() trong app.js gọi song song 2 API: GET /api/admin/accounts và GET /api/admin/accounts/roles.`n2. AccountsController.GetAll() truy vấn _context.Accounts.Include(a => a.Role).OrderByDescending(a => a.AccountId) và trả về danh sách JSON.`n3. Frontend tính toán và cập nhật 4 thẻ KPI: Tổng số Account (19), Đang hoạt động (17), Đã khóa (2), Số vai trò (3).`n4. Khi Admin nhập từ khóa vào ô tìm kiếm (#accountSearchInput) hoặc chọn bộ lọc vai trò (#roleFilterSelect), hàm filterAccounts() lọc tức thời trên danh sách và kết xuất lại bảng HTML." `
        -AltFlow "• Nhánh 2a (Mất kết nối máy chủ tạm thời): Frontend tự động kích hoạt dữ liệu dự phòng (Fallback Seed Data) và hiển thị cảnh báo trạng thái kết nối để không gián đoạn phiên làm việc." `
        -RulesAndTables "Áp dụng quy tắc BR-01, BR-02. Tác động đọc (READ) trên bảng Accounts và Roles." `
        -JsonSample @"
// Response: GET /api/admin/accounts (Trích 2 bản ghi tiêu biểu)
[
  {
    "accountId": 1,
    "username": "admin",
    "fullName": "Nguyễn Quản Trị Hệ Thống",
    "email": "admin@sgutech.vn",
    "phone": "0901000001",
    "roleId": 1,
    "roleName": "Admin",
    "isActive": true,
    "createdAt": "2026-09-16T08:00:00"
  },
  {
    "accountId": 3,
    "username": "quanly",
    "fullName": "Trần Trưởng Phòng CRM",
    "email": "crm.manager@sgutech.vn",
    "phone": "0901000002",
    "roleId": 2,
    "roleName": "Manager",
    "isActive": true,
    "createdAt": "2026-09-21T08:00:00"
  }
]
"@))

    [void]$sb.Append((New-WPageBreak))

    # UC-03
    [void]$sb.Append((New-UseCaseSpec -UcId "UC-03" -UcName "[Admin Server] Thêm mới Tài khoản Định danh (Create Account)" `
        -Actor "Quản trị viên Máy chủ (Admin)" `
        -Endpoint "POST /api/admin/accounts" `
        -UiScreen "Frontend_Admin/admin.html (Modal Thêm Tài khoản mới)" `
        -Goal "Cho phép Admin Server tạo mới một tài khoản định danh bất kỳ và gán vào 1 trong 3 vai trò (Admin, Manager, Customer)." `
        -PreCond "Admin đang ở màn hình Quản lý Tài khoản trên admin.html." `
        -PostCond "Bản ghi mới được thêm vào bảng Accounts (và tự động tạo bản ghi CustomerProfiles nếu Role là Customer)." `
        -MainFlow "1. Admin nhấn nút '+ Thêm tài khoản mới' để mở hộp thoại Modal.`n2. Admin nhập Username, Password, Họ và tên, Email, Số điện thoại và chọn Vai trò (Admin / Manager / Customer), sau đó nhấn 'Lưu tài khoản'.`n3. Frontend gửi yêu cầu POST /api/admin/accounts kèm gói dữ liệu AccountCreateDto.`n4. AccountsController.Create() kiểm tra trùng Username trong bảng Accounts.`n5. Hệ thống băm mật khẩu bằng BCrypt, khởi tạo đối tượng Account với IsActive = true và lưu vào bảng Accounts.`n6. Nếu Role được chọn là 'Customer', hệ thống tự động tạo thêm 1 bản ghi trong bảng CustomerProfiles gắn với AccountId vừa tạo.`n7. Hệ thống trả về HTTP 200 OK và làm mới lại bảng danh sách tài khoản." `
        -AltFlow "• Nhánh 4a (Username đã tồn tại): Hệ thống trả về HTTP 400 BadRequest với thông báo 'Username đã tồn tại!'." `
        -RulesAndTables "Áp dụng quy tắc BR-03, BR-04, BR-05, BR-06. Tác động ghi (CREATE) trên bảng Accounts và CustomerProfiles." `
        -JsonSample @"
// Request: POST /api/admin/accounts
{
  "username": "quanly_moi",
  "password": "123456",
  "fullName": "Phạm Chuyên Viên CRM",
  "email": "chuyenvien.crm@sgutech.vn",
  "phone": "0909112233",
  "roleId": 2
}
// Response: 200 OK
{ "message": "Tạo tài khoản thành công!" }
"@))

    # UC-04
    [void]$sb.Append((New-UseCaseSpec -UcId "UC-04" -UcName "[Admin Server] Phân quyền Vai trò cho Account (Update Account Role)" `
        -Actor "Quản trị viên Máy chủ (Admin)" `
        -Endpoint "PUT /api/admin/accounts/{id}/role" `
        -UiScreen "Frontend_Admin/admin.html (Cột Phân quyền Tài khoản)" `
        -Goal "Cho phép Admin thay đổi quyền hạn (Role) của bất kỳ tài khoản nào giữa 3 vai trò: Admin, Manager, Customer." `
        -PreCond "Tài khoản cần phân quyền đã tồn tại trong bảng Accounts." `
        -PostCond "Trường RoleId của tài khoản được cập nhật sang vai trò mới; nếu chuyển sang Customer mà chưa có hồ sơ thì hệ thống tự động khởi tạo CustomerProfile." `
        -MainFlow "1. Trên dòng tài khoản cần thay đổi quyền tại bảng danh sách, Admin chọn vai trò mới từ hộp chọn Dropdown (Admin / Manager / Customer).`n2. Admin nhấn nút 'Phân quyền' ngay bên cạnh hộp chọn.`n3. Hàm changeRole(accountId) trong app.js gửi yêu cầu PUT /api/admin/accounts/{id}/role với body { roleId }.`n4. AccountsController.UpdateRole() tìm tài khoản theo id, cập nhật acc.RoleId = dto.RoleId và gọi SaveChangesAsync().`n5. Nếu quyền mới là 'Customer' và tài khoản chưa có bản ghi trong CustomerProfiles, hệ thống tự động thêm mới CustomerProfile mặc định.`n6. Hệ thống trả về thông báo 'Cập nhật phân quyền thành công!' và cập nhật lại huy hiệu vai trò trên giao diện." `
        -AltFlow "• Nhánh 4a (Không tìm thấy AccountId): Trả về HTTP 404 NotFound: 'Không tìm thấy tài khoản!'." `
        -RulesAndTables "Áp dụng quy tắc BR-02, BR-06. Tác động cập nhật (UPDATE) trên bảng Accounts và thêm mới (CREATE) trên CustomerProfiles (nếu cần)." `
        -JsonSample @"
// Request: PUT /api/admin/accounts/5/role
{ "roleId": 2 }
// Response: 200 OK
{ "message": "Cập nhật phân quyền thành công!" }
"@))

    [void]$sb.Append((New-WPageBreak))

    # UC-05
    [void]$sb.Append((New-UseCaseSpec -UcId "UC-05" -UcName "[Admin Server] Khóa và Mở khóa Tài khoản (Toggle Account Status)" `
        -Actor "Quản trị viên Máy chủ (Admin)" `
        -Endpoint "PUT /api/admin/accounts/{id}/toggle-status" `
        -UiScreen "Frontend_Admin/admin.html (Cột Thao tác Quản lý)" `
        -Goal "Cho phép Admin đình chỉ (Khóa) tạm thời quyền đăng nhập của một tài khoản vi phạm hoặc khôi phục (Mở khóa) tài khoản đó." `
        -PreCond "Tài khoản tồn tại trong bảng Accounts." `
        -PostCond "Giá trị trường IsActive của tài khoản được đảo ngược (true <-> false) trong CSDL." `
        -MainFlow "1. Admin nhấn vào nút 'Khóa' (đối với tài khoản đang hoạt động) hoặc 'Mở khóa' (đối với tài khoản đang bị khóa) trên dòng tài khoản tương ứng.`n2. Frontend gửi yêu cầu PUT /api/admin/accounts/{id}/toggle-status.`n3. AccountsController.ToggleStatus() truy xuất bản ghi Account theo id, thực hiện lệnh acc.IsActive = !acc.IsActive và lưu vào SQL Server.`n4. Hệ thống trả về trạng thái mới cùng thông báo tương ứng ('Đã khóa tài khoản thành công!' hoặc 'Đã mở khóa tài khoản thành công!')." `
        -AltFlow "• Nhánh 1a (Bảo vệ tài khoản gốc): Nếu Admin thao tác khóa chính tài khoản quản trị gốc đang đăng nhập, giao diện cảnh báo xác nhận an toàn." `
        -RulesAndTables "Áp dụng quy tắc BR-07. Tác động cập nhật (UPDATE) trường IsActive trên bảng Accounts." `
        -JsonSample @"
// Request: PUT /api/admin/accounts/9/toggle-status
// Response: 200 OK
{
  "message": "Đã khóa tài khoản thành công!",
  "isActive": false
}
"@))

    # UC-06
    [void]$sb.Append((New-UseCaseSpec -UcId "UC-06" -UcName "[Admin Server] Xóa Tài khoản khỏi Hệ thống (Delete Account)" `
        -Actor "Quản trị viên Máy chủ (Admin)" `
        -Endpoint "DELETE /api/admin/accounts/{id}" `
        -UiScreen "Frontend_Admin/admin.html (Nút Xóa Account)" `
        -Goal "Xóa vĩnh viễn một tài khoản người dùng cùng toàn bộ các bản ghi dữ liệu phụ thuộc khỏi cơ sở dữ liệu mà không gây lỗi khóa ngoại." `
        -PreCond "Tài khoản tồn tại trong bảng Accounts." `
        -PostCond "Bản ghi Account và các bản ghi liên quan trong CustomerProfiles, Feedbacks, SurveyResponses bị xóa hoàn toàn khỏi CSDL." `
        -MainFlow "1. Admin nhấn nút 'Xóa Account' trên dòng tài khoản cần xóa và xác nhận hộp thoại cảnh báo.`n2. Frontend gọi API DELETE /api/admin/accounts/{id}.`n3. AccountsController.Delete() kiểm tra sự tồn tại của tài khoản.`n4. Hệ thống truy vấn và xóa toàn bộ các bản ghi con có AccountId == id trong 3 bảng: CustomerProfiles, Feedbacks, và SurveyResponses.`n5. Hệ thống thực hiện _context.Accounts.Remove(acc) và gọi SaveChangesAsync().`n6. Trả về HTTP 200 OK: 'Đã xóa tài khoản thành công!' và cập nhật lại bảng giao diện." `
        -AltFlow "• Nhánh 3a (Tài khoản đã bị xóa trước đó): Trả về HTTP 404 NotFound." `
        -RulesAndTables "Áp dụng quy tắc BR-09 (Safe Cascade Delete). Tác động xóa (DELETE) trên CustomerProfiles, Feedbacks, SurveyResponses và Accounts." `
        -JsonSample @"
// Request: DELETE /api/admin/accounts/19
// Response: 200 OK
{ "message": "Đã xóa tài khoản thành công!" }
"@))

    [void]$sb.Append((New-WPageBreak))

    # UC-07
    [void]$sb.Append((New-UseCaseSpec -UcId "UC-07" -UcName "[Người Quản lý] Thêm một Khách hàng mới (Create Customer & Profile)" `
        -Actor "Người Quản lý Quan hệ Khách hàng (CRM Manager)" `
        -Endpoint "POST /api/admin/crm/customers" `
        -UiScreen "Frontend_Admin/quanly.html (Tab 1: Quản lý Khách hàng — Modal Thêm Khách hàng)" `
        -Goal "Cho phép Người quản lý thêm mới một khách hàng kèm đầy đủ thông tin tài khoản đăng nhập và hồ sơ nhân khẩu học (Độ tuổi, Giới tính, Sở thích, Địa chỉ)." `
        -PreCond "Người quản lý đã đăng nhập vào giao diện quanly.html." `
        -PostCond "Khởi tạo đồng bộ 1 bản ghi trong bảng Accounts (Role = Customer) và 1 bản ghi trong bảng CustomerProfiles." `
        -MainFlow "1. Tại Tab 1 (Quản lý Khách hàng), Người quản lý nhấn nút '+ Thêm một khách hàng mới'.`n2. Người quản lý nhập: Tên đăng nhập, Mật khẩu, Họ và tên, Số điện thoại, Email, Độ tuổi, Giới tính, Sở thích tiêu dùng (Gaming / Đồ họa / Văn phòng / Lập trình) và Địa chỉ.`n3. Frontend gửi yêu cầu POST /api/admin/crm/customers kèm gói dữ liệu CustomerRegisterDto.`n4. CrmAdminController.CreateCustomer() kiểm tra hợp lệ và kiểm tra trùng Username.`n5. Hệ thống tạo bản ghi Account mới với Role = Customer, IsActive = true, mật khẩu băm BCrypt và lưu vào bảng Accounts.`n6. Hệ thống tiếp tục tạo bản ghi CustomerProfile gắn với AccountId vừa sinh, lưu Age, Gender, Address, Interest vào bảng CustomerProfiles.`n7. Trả về HTTP 200 OK kèm accountId mới; giao diện tự động cập nhật danh sách khách hàng và biểu đồ nhân khẩu học." `
        -AltFlow "• Nhánh 4a (Thiếu Username hoặc Họ tên): Trả về HTTP 400 BadRequest: 'Vui lòng nhập đầy đủ Tên đăng nhập và Họ tên khách hàng!'.`n• Nhánh 4b (Trùng Username): Trả về HTTP 400 BadRequest: 'Tên đăng nhập đã tồn tại!'." `
        -RulesAndTables "Áp dụng quy tắc BR-03, BR-04, BR-05, BR-06, BR-10, BR-11. Tác động ghi (CREATE) trên bảng Accounts và CustomerProfiles." `
        -JsonSample @"
// Request: POST /api/admin/crm/customers
{
  "username": "khachhang16",
  "password": "123456",
  "fullName": "Lý Minh Khôi",
  "email": "khoi.ly@gmail.com",
  "phone": "0918889999",
  "age": 24,
  "gender": "Nam",
  "interest": "Gaming",
  "address": "Quận 7, TP. Hồ Chí Minh"
}
// Response: 200 OK
{ "message": "Thêm khách hàng mới thành công!", "accountId": 20 }
"@))

    # UC-08
    [void]$sb.Append((New-UseCaseSpec -UcId "UC-08" -UcName "[Người Quản lý] Xóa Khách hàng khỏi Hệ thống (Delete Customer)" `
        -Actor "Người Quản lý Quan hệ Khách hàng (CRM Manager)" `
        -Endpoint "DELETE /api/admin/crm/customers/{id}" `
        -UiScreen "Frontend_Admin/quanly.html (Tab 1: Quản lý Khách hàng)" `
        -Goal "Cho phép Người quản lý xóa bỏ hồ sơ khách hàng không còn giao dịch hoặc tài khoản ảo cùng toàn bộ dữ liệu liên quan." `
        -PreCond "Khách hàng cần xóa tồn tại trong danh sách khách hàng CRM." `
        -PostCond "Hồ sơ CustomerProfile, các phản hồi Feedbacks, các phiếu trả lời SurveyResponses và tài khoản Account của khách hàng đó bị xóa sạch." `
        -MainFlow "1. Trên dòng khách hàng tại Tab 1 (quanly.html), Người quản lý nhấn nút 'Xóa' và xác nhận hộp thoại.`n2. Frontend gọi API DELETE /api/admin/crm/customers/{id}.`n3. CrmAdminController.DeleteCustomer() tìm tài khoản khách hàng theo id.`n4. Hệ thống xóa tuần tự các bản ghi liên kết trong CustomerProfiles, Feedbacks và SurveyResponses có AccountId == id.`n5. Hệ thống xóa bản ghi trong bảng Accounts và lưu thay đổi vào SQL Server.`n6. Trả về HTTP 200 OK: 'Đã xóa khách hàng thành công.' và làm mới danh sách khách hàng." `
        -AltFlow "• Nhánh 3a (Không tìm thấy khách hàng): Trả về HTTP 404 NotFound: 'Không tìm thấy khách hàng.'." `
        -RulesAndTables "Áp dụng quy tắc BR-09. Tác động xóa (DELETE) trên CustomerProfiles, Feedbacks, SurveyResponses và Accounts." `
        -JsonSample @"
// Request: DELETE /api/admin/crm/customers/19
// Response: 200 OK
{ "message": "Đã xóa khách hàng thành công." }
"@))

    [void]$sb.Append((New-WPageBreak))

    # UC-09
    [void]$sb.Append((New-UseCaseSpec -UcId "UC-09" -UcName "[Người Quản lý] Khóa / Mở khóa Tài khoản Khách hàng (Lock/Unlock Customer)" `
        -Actor "Người Quản lý Quan hệ Khách hàng (CRM Manager)" `
        -Endpoint "PUT /api/admin/crm/customers/{id}/toggle-status" `
        -UiScreen "Frontend_Admin/quanly.html (Tab 1: Quản lý Khách hàng — Nút Khóa TK / Mở khóa)" `
        -Goal "Cho phép Người quản lý khóa tức thời tài khoản khách hàng có hành vi gửi phản hồi spam, ngôn từ không phù hợp hoặc mở khóa lại khi khách hàng đã khắc phục." `
        -PreCond "Hồ sơ khách hàng đang hiển thị trên bảng Quản lý Khách hàng." `
        -PostCond "Trường IsActive của khách hàng trong bảng Accounts được đảo trạng thái; khách hàng bị khóa sẽ không thể đăng nhập vào user.html." `
        -MainFlow "1. Người quản lý nhấn nút 'Khóa TK' (hoặc 'Mở khóa') trên dòng khách hàng tương ứng.`n2. Frontend gửi yêu cầu PUT /api/admin/crm/customers/{id}/toggle-status.`n3. CrmAdminController.ToggleCustomerStatus() đảo giá trị account.IsActive = !account.IsActive và lưu vào CSDL.`n4. Hệ thống trả về trạng thái isActive mới và thông báo xác nhận; giao diện cập nhật ngay số lượng KPI 'Tài khoản bị khóa'." `
        -AltFlow "• Nhánh 3a (ID khách hàng không tồn tại): Trả về HTTP 404 NotFound." `
        -RulesAndTables "Áp dụng quy tắc BR-07. Tác động cập nhật (UPDATE) trên bảng Accounts." `
        -JsonSample @"
// Request: PUT /api/admin/crm/customers/9/toggle-status
// Response: 200 OK
{
  "message": "Đã khóa tài khoản khách hàng.",
  "isActive": false
}
"@))

    # UC-10
    [void]$sb.Append((New-UseCaseSpec -UcId "UC-10" -UcName "[Người Quản lý] Tiếp nhận và Giải đáp Phản hồi của Khách hàng" `
        -Actor "Người Quản lý Quan hệ Khách hàng (CRM Manager)" `
        -Endpoint "GET /api/admin/crm/feedbacks & PUT /api/admin/crm/feedbacks/{id}/reply" `
        -UiScreen "Frontend_Admin/quanly.html (Tab 2: Tiếp nhận Phản hồi)" `
        -Goal "Tiếp nhận toàn bộ các đánh giá sao (1–5 sao) và nhận xét sản phẩm từ khách hàng, phân tích biểu đồ mức độ hài lòng và gửi câu trả lời giải đáp chính thức." `
        -PreCond "Khách hàng đã gửi ít nhất một phản hồi sản phẩm vào bảng Feedbacks." `
        -PostCond "Trường AdminReply được lưu nội dung trả lời của Người quản lý và trường Status chuyển sang 'Đã tiếp nhận & Xử lý'." `
        -MainFlow "1. Người quản lý mở Tab 2 (Tiếp nhận Phản hồi). Frontend gọi GET /api/admin/crm/feedbacks để tải danh sách 18 phản hồi kèm tên khách hàng, tên sản phẩm, ảnh sản phẩm, số sao (Rating) và trạng thái.`n2. Frontend tự động tính toán 4 chỉ số KPI (Tổng phản hồi, Đã giải đáp, Đang chờ xử lý, Điểm sao TB) và vẽ 2 biểu đồ: Phân bổ đánh giá 1–5 sao & Top sản phẩm được phản hồi nhiều nhất.`n3. Người quản lý nhấn nút 'Tiếp nhận & Trả lời' tại một dòng phản hồi, nhập nội dung giải đáp vào hộp thoại Modal và nhấn 'Gửi phản hồi giải đáp'.`n4. Frontend gọi PUT /api/admin/crm/feedbacks/{id}/reply kèm gói JSON { adminReply }.`n5. CrmAdminController.ReplyFeedback() cập nhật fb.AdminReply = dto.AdminReply và fb.Status = 'Đã tiếp nhận & Xử lý', sau đó lưu vào SQL Server.`n6. Câu trả lời hiển thị ngay lập tức trên cả màn hình của Người quản lý và trên Cổng Khách hàng (user.html)." `
        -AltFlow "• Nhánh 5a (Không tìm thấy FeedbackId): Trả về HTTP 404 NotFound." `
        -RulesAndTables "Áp dụng quy tắc BR-13, BR-14. Tác động đọc/cập nhật (READ/UPDATE) trên bảng Feedbacks, kết hợp đọc Accounts và Products." `
        -JsonSample @"
// Request: PUT /api/admin/crm/feedbacks/17/reply
{
  "adminReply": "SGU Tech chân thành xin lỗi anh về sự cố khâu vận chuyển! Quản lý kho đã liên hệ và đổi mới nguyên seal cho anh ngay trong hôm nay ạ."
}
// Response: 200 OK
{ "message": "Đã gửi phản hồi cho khách hàng." }
"@))

    [void]$sb.Append((New-WPageBreak))

    # UC-11
    [void]$sb.Append((New-UseCaseSpec -UcId "UC-11" -UcName "[Người Quản lý] Báo cáo về Khách hàng: Tỷ lệ Độ tuổi & Sở thích" `
        -Actor "Người Quản lý Quan hệ Khách hàng (CRM Manager)" `
        -Endpoint "GET /api/admin/crm/reports/demographics" `
        -UiScreen "Frontend_Admin/quanly.html (Tab 3: Báo cáo Độ tuổi & Sở thích)" `
        -Goal "Cung cấp báo cáo phân tích nhân khẩu học thời gian thực về cơ cấu độ tuổi và tỷ lệ phần trăm các nhóm sở thích tiêu dùng của toàn bộ tệp khách hàng." `
        -PreCond "Bảng CustomerProfiles đã có dữ liệu hồ sơ khách hàng." `
        -PostCond "Hiển thị chính xác các chỉ số tổng hợp, Biểu đồ tròn Tỷ lệ Độ tuổi, Biểu đồ cột Phân bố Sở thích và 2 bảng thống kê chi tiết kèm thanh tỷ lệ %." `
        -MainFlow "1. Người quản lý chọn Tab 3 (Báo cáo Độ tuổi & Sở thích) trên quanly.html.`n2. Frontend gọi API GET /api/admin/crm/reports/demographics (kết hợp dữ liệu chi tiết từ danh sách hồ sơ khách hàng).`n3. CrmAdminController.GetDemographicsReport() truy vấn bảng CustomerProfiles, đếm tổng số khách hàng (totalCustomers) và thống kê số lượng theo phân khúc tuổi (Under20: Age < 20; From20To30: 20 <= Age <= 30; Over30: Age > 30).`n4. Đồng thời, Controller thực hiện GroupBy theo trường Interest (Gaming, Văn phòng, Đồ họa, Lập trình), tính số lượng (Count) và tỷ lệ phần trăm (Percentage) của từng sở thích.`n5. Frontend nhận dữ liệu JSON, kết xuất Biểu đồ Vòng (Doughnut Chart) cho tỷ lệ độ tuổi, Biểu đồ Cột ngang (Bar Chart) cho sở thích tiêu dùng và 2 bảng phân tích chi tiết." `
        -AltFlow "• Nhánh 3a (Chưa có khách hàng nào trong CSDL): Hệ thống trả về totalCustomers = 0 và các tỷ lệ bằng 0% mà không gây lỗi chia cho 0." `
        -RulesAndTables "Áp dụng quy tắc BR-10, BR-11, BR-12. Tác động đọc và gom nhóm (READ / GROUP BY) trên bảng CustomerProfiles." `
        -JsonSample @"
// Response: GET /api/admin/crm/reports/demographics
{
  "totalCustomers": 15,
  "ageStats": {
    "under20": 3,
    "from20To30": 7,
    "over30": 5
  },
  "interestStats": [
    { "interest": "Gaming", "count": 5, "percentage": 33.3 },
    { "interest": "Văn phòng", "count": 4, "percentage": 26.7 },
    { "interest": "Lập trình", "count": 3, "percentage": 20.0 },
    { "interest": "Đồ họa", "count": 3, "percentage": 20.0 }
  ]
}
"@))

    # UC-12
    [void]$sb.Append((New-UseCaseSpec -UcId "UC-12" -UcName "[Người Quản lý] Tạo Bảng Khảo sát và Gửi đến Tài khoản Khách hàng" `
        -Actor "Người Quản lý Quan hệ Khách hàng (CRM Manager)" `
        -Endpoint "POST /api/admin/crm/surveys & GET /api/admin/crm/surveys" `
        -UiScreen "Frontend_Admin/quanly.html (Tab 4: Tạo & Gửi Khảo sát)" `
        -Goal "Khởi tạo chiến dịch khảo sát thị trường cho dòng sản phẩm công nghệ dự kiến ra mắt (hỗ trợ cài đặt thời hạn linh hoạt) và phát hành trực tiếp đến toàn bộ tài khoản khách hàng." `
        -PreCond "Người quản lý đang làm việc tại Tab 4 (Tạo & Gửi Khảo sát) trên quanly.html." `
        -PostCond "Bản ghi khảo sát mới được lưu vào bảng Surveys và xuất hiện ngay lập tức trong mục 'Khảo sát thị trường' của tất cả tài khoản khách hàng." `
        -MainFlow "1. Người quản lý nhập Tiêu đề bảng khảo sát (Title), Tên sản phẩm khảo sát (TargetProduct), Mức giá dự kiến (ExpectedPrice), chọn Chế độ thời hạn (Không giới hạn / Theo số ngày / Chọn ngày hết hạn) và nhập Mô tả nội dung khảo sát (Description).`n2. Người quản lý nhấn nút 'Phát hành & Gửi đến Khách hàng'.`n3. Frontend gửi yêu cầu POST /api/admin/crm/surveys kèm gói SurveyCreateDto.`n4. CrmAdminController.CreateSurvey() tính toán trường ExpiresAt dựa trên DurationType, khởi tạo đối tượng Survey với IsActive = true và lưu vào bảng Surveys.`n5. Hệ thống đếm tổng số tài khoản khách hàng đang hoạt động (recipientCount) và trả về thông báo xác nhận số lượng tài khoản khách hàng đã nhận được khảo sát." `
        -AltFlow "• Nhánh 6a (Khóa/Mở khóa hoặc Xóa khảo sát): Người quản lý có thể nhấn nút Khóa/Mở khóa (PUT /api/admin/crm/surveys/{id}/toggle-lock) hoặc Xóa khảo sát (DELETE /api/admin/crm/surveys/{id})." `
        -RulesAndTables "Áp dụng quy tắc BR-16, BR-17. Tác động ghi/cập nhật/xóa (CREATE/UPDATE/DELETE) trên bảng Surveys." `
        -JsonSample @"
// Request: POST /api/admin/crm/surveys
{
  "title": "Khảo sát nhu cầu dòng Laptop AI Siêu Mỏng Nhẹ 2026",
  "targetProduct": "ASUS Zenbook S16 OLED AI 2026",
  "expectedPrice": 36990000,
  "durationType": "Days",
  "durationDays": 20,
  "description": "Đánh giá nhu cầu trang bị chip NPU AI chuyên dụng hỗ trợ lập trình viên và sáng tạo nội dung đa nhiệm."
}
// Response: 200 OK
{
  "message": "Đã tạo bảng khảo sát và gửi đến 13 tài khoản khách hàng đang hoạt động!",
  "surveyId": 1,
  "recipientCount": 13
}
"@))

    [void]$sb.Append((New-WPageBreak))

    # UC-13
    [void]$sb.Append((New-UseCaseSpec -UcId "UC-13" -UcName "[Người Quản lý] Thống kê Kết quả Khảo sát (Survey Statistics & Analytics)" `
        -Actor "Người Quản lý Quan hệ Khách hàng (CRM Manager)" `
        -Endpoint "GET /api/admin/crm/surveys/{id}/statistics" `
        -UiScreen "Frontend_Admin/quanly.html (Tab 5: Thống kê Khảo sát)" `
        -Goal "Tổng hợp và phân tích chi tiết kết quả thực hiện khảo sát của khách hàng: tổng lượt tham gia, điểm mức độ quan tâm trung bình (1–5), phân bổ ý định mua sắm và danh sách từng câu trả lời." `
        -PreCond "Chiến dịch khảo sát đã được tạo trong bảng Surveys." `
        -PostCond "Hiển thị đầy đủ 4 thẻ KPI khảo sát, 2 biểu đồ thống kê (Ý định mua sắm & Điểm quan tâm), bảng tổng hợp chiến dịch và bảng chi tiết toàn bộ phiếu trả lời của khách hàng." `
        -MainFlow "1. Người quản lý mở Tab 5 (Thống kê Khảo sát) hoặc chọn một chiến dịch khảo sát cụ thể để xem báo cáo.`n2. Frontend gọi API GET /api/admin/crm/surveys và GET /api/admin/crm/surveys/{id}/statistics.`n3. CrmAdminController.GetSurveyStatistics() truy vấn toàn bộ bản ghi trong SurveyResponses có SurveyId == id kèm thông tin Account của khách hàng.`n4. Hệ thống tính toán: Tổng số lượt trả lời (totalResponses), Điểm quan tâm trung bình (averageScore = Math.Round(Average(Score), 2)), thống kê 3 mức ý định mua (WantToBuy: 'Rất muốn mua', Considering: 'Đang cân nhắc', NotBuying: 'Không mua') và phân bố điểm từ 1 đến 5 sao.`n5. Frontend hiển thị trực quan bằng Biểu đồ Vòng (Ý định mua sắm), Biểu đồ Cột (Điểm quan tâm TB) và bảng danh sách chi tiết từng phiếu trả lời." `
        -AltFlow "• Nhánh 3a (Khảo sát mới tạo chưa có người trả lời): Hệ thống trả về totalResponses = 0, averageScore = 0 và danh sách rỗng an toàn." `
        -RulesAndTables "Áp dụng quy tắc BR-20. Tác động đọc (READ) và tổng hợp thống kê trên bảng Surveys, SurveyResponses và Accounts." `
        -JsonSample @"
// Response: GET /api/admin/crm/surveys/1/statistics
{
  "surveyId": 1,
  "title": "Khảo sát nhu cầu dòng Laptop AI Siêu Mỏng Nhẹ 2026",
  "targetProduct": "ASUS Zenbook S16 OLED AI 2026",
  "expectedPrice": 36990000,
  "totalResponses": 6,
  "averageScore": 4.33,
  "intentStats": { "wantToBuy": 3, "considering": 2, "notBuying": 1 },
  "scoreDistribution": { "score1": 0, "score2": 0, "score3": 1, "score4": 2, "score5": 3 }
}
"@))

    # UC-14
    [void]$sb.Append((New-UseCaseSpec -UcId "UC-14" -UcName "[Khách hàng] Đăng ký Tài khoản, Đăng nhập & Chỉnh sửa Thông tin Cá nhân" `
        -Actor "Khách hàng (Customer)" `
        -Endpoint "POST /api/customer/register, POST /api/customer/login, GET & PUT /api/customer/profile/{accountId}" `
        -UiScreen "Frontend_Admin/user.html (Màn hình Đăng ký/Đăng nhập & Tab Hồ sơ cá nhân)" `
        -Goal "Cho phép khách hàng tự đăng ký tài khoản mới nhanh gọn, đăng nhập vào cổng khách hàng và chủ động chỉnh sửa thông tin cá nhân, độ tuổi, sở thích, địa chỉ mọi lúc." `
        -PreCond "Khách hàng truy cập Cổng Khách hàng tại user.html." `
        -PostCond "Tài khoản và hồ sơ nhân khẩu học của khách hàng được tạo mới hoặc cập nhật đồng bộ trong bảng Accounts và CustomerProfiles." `
        -MainFlow "1. (Đăng ký): Khách hàng chọn tab 'Đăng ký tài khoản', nhập Username, Password, Họ tên, SĐT, Email, Độ tuổi, Giới tính, Sở thích, Địa chỉ và nhấn 'Hoàn tất đăng ký'. API POST /api/customer/register tạo bản ghi Accounts + CustomerProfiles và tự động đăng nhập cho khách hàng.`n2. (Xem hồ sơ): Khi khách hàng mở tab 'Hồ sơ cá nhân', Frontend gọi GET /api/customer/profile/{accountId} để hiển thị thông tin lên thẻ định danh và biểu mẫu.`n3. (Chỉnh sửa thông tin): Khách hàng thay đổi Họ tên, Số điện thoại, Email, Độ tuổi, Giới tính, Sở thích hoặc Địa chỉ rồi nhấn 'Lưu chỉnh sửa thông tin'.`n4. Frontend gọi PUT /api/customer/profile/{accountId} kèm CustomerUpdateProfileDto.`n5. CustomerPortalController.UpdateProfile() cập nhật đồng thời bảng Accounts (FullName, Email, Phone) và bảng CustomerProfiles (Age, Gender, Address, Interest) rồi lưu vào SQL Server." `
        -AltFlow "• Nhánh 1a (Trùng Username khi đăng ký): Trả về HTTP 400 BadRequest: 'Tên đăng nhập này đã được sử dụng!'." `
        -RulesAndTables "Áp dụng quy tắc BR-03, BR-04, BR-06, BR-10, BR-11. Tác động CREATE/READ/UPDATE trên bảng Accounts và CustomerProfiles." `
        -JsonSample @"
// Request: PUT /api/customer/profile/5
{
  "fullName": "Nguyễn Văn An",
  "email": "an.nguyen@gmail.com",
  "phone": "0912345671",
  "age": 20,
  "gender": "Nam",
  "interest": "Gaming",
  "address": "273 An Dương Vương, Quận 5, TP.HCM"
}
// Response: 200 OK
{ "message": "Cập nhật thông tin hồ sơ thành công!" }
"@))

    [void]$sb.Append((New-WPageBreak))

    # UC-15
    [void]$sb.Append((New-UseCaseSpec -UcId "UC-15" -UcName "[Khách hàng] Gửi Phản hồi về Sản phẩm & Nhận, Thực hiện Bảng Khảo sát" `
        -Actor "Khách hàng (Customer)" `
        -Endpoint "POST /api/customer/feedbacks/{accountId} & POST /api/customer/surveys/{surveyId}/submit/{accountId}" `
        -UiScreen "Frontend_Admin/user.html (Tab 1: Phản hồi sản phẩm & Tab 2: Khảo sát thị trường)" `
        -Goal "Cho phép khách hàng gửi đánh giá sao (1–5 sao) kèm nhận xét về sản phẩm, lọc xem giải đáp từ Người quản lý, đồng thời nhận và thực hiện các bảng khảo sát thị trường." `
        -PreCond "Khách hàng đã đăng nhập thành công vào Cổng Khách hàng (user.html)." `
        -PostCond "Bản ghi phản hồi mới được lưu vào bảng Feedbacks; bản ghi kết quả khảo sát mới được lưu vào bảng SurveyResponses và đồng bộ tức thời sang màn hình Người quản lý." `
        -MainFlow "1. (Gửi phản hồi sản phẩm): Tại Tab 1 (Phản hồi sản phẩm), khách hàng chọn sản phẩm từ danh sách 16 sản phẩm công nghệ, chọn mức độ hài lòng (1 đến 5 sao), nhập nội dung nhận xét và nhấn 'Gửi phản hồi'.`n2. Frontend gửi POST /api/customer/feedbacks/{accountId} kèm { productId, rating, comment }. Hệ thống lưu vào bảng Feedbacks với Status = 'Chờ xử lý'.`n3. Khách hàng có thể chọn bộ lọc 'Lọc theo sản phẩm' (GET /api/customer/all-feedbacks?productId=...) để xem đánh giá và câu trả lời giải đáp của Người quản lý.`n4. (Nhận & Thực hiện khảo sát): Tại Tab 2 (Khảo sát thị trường), Frontend gọi GET /api/customer/surveys/{accountId} hiển thị các bảng khảo sát được gửi tới kèm trạng thái (Chưa thực hiện / Đã thực hiện / Đã hết hạn).`n5. Khách hàng nhấn nút 'Thực hiện khảo sát' trên khảo sát đang mở, chọn Điểm mức độ quan tâm (1–5 điểm), chọn Ý định mua sắm ('Rất muốn mua' / 'Đang cân nhắc' / 'Không mua'), nhập ý kiến đóng góp và nhấn 'Gửi kết quả khảo sát'.`n6. Frontend gọi POST /api/customer/surveys/{surveyId}/submit/{accountId}. Hệ thống kiểm tra khảo sát còn hạn và khách chưa làm trước đó, sau đó lưu vào bảng SurveyResponses." `
        -AltFlow "• Nhánh 6a (Khách hàng gửi lại khảo sát đã làm): Hệ thống chặn và trả về HTTP 400: 'Bạn đã thực hiện bài khảo sát này rồi!'.`n• Nhánh 6b (Khảo sát đã bị khóa hoặc quá hạn ExpiresAt): Trả về HTTP 400 từ chối nhận phiếu." `
        -RulesAndTables "Áp dụng quy tắc BR-13, BR-14, BR-15, BR-18, BR-19. Tác động CREATE/READ trên bảng Feedbacks, Products, Surveys và SurveyResponses." `
        -JsonSample @"
// 1. Request Gửi phản hồi SP: POST /api/customer/feedbacks/5
{
  "productId": 1,
  "rating": 5,
  "comment": "Laptop ROG Strix chạy cực kỳ mượt, tản nhiệt mát mẻ khi chiến game AAA nặng."
}
// 2. Request Nộp phiếu khảo sát: POST /api/customer/surveys/3/submit/5
{
  "score": 5,
  "buyingIntent": "Rất muốn mua",
  "customerOpinion": "Chống ồn AI và pin 40 giờ rất ấn tượng, mức giá 7.99 triệu hoàn toàn hợp lý."
}
"@))

    [void]$sb.Append((New-WPageBreak))
    return $sb.ToString()
}
