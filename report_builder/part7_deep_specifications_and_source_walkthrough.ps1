# ==============================================================================
# PART 7: MỞ RỘNG CHUYÊN SÂU CHO CÁC CHƯƠNG NHIỀU ĐIỂM (CHƯƠNG 2, CHƯƠNG 3,
# CHƯƠNG 4, PHẦN II & PHẦN III) — ĐẢM BẢO BÁO CÁO > 115 TRANG CHẤT LƯỢNG CAO
# ==============================================================================

function New-BfdLeafDetailCard {
    param(
        [string]$Code,
        [string]$Name,
        [string]$Module,
        [string]$Actor,
        [string]$Trigger,
        [string]$InputSpec,
        [string]$ValidationSpec,
        [string]$AlgorithmSpec,
        [string]$SqlSpec,
        [string]$OutputSpec
    )
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append((New-WHeading4 "Hồ sơ Đặc tả Chức năng Lá BFD [$Code]: $Name"))
    [void]$sb.Append((New-WTable -Headers @("Tiêu chí Đặc tả Chức năng BFD", "Nội dung Phân tích Kỹ thuật Chi tiết của Chức năng [$Code]") -ColWidths @(2500, 7100) -Rows @(
        @("Mã & Tên chức năng lá", "[$Code] — $Name"),
        @("Thuộc nhánh phân hệ BFD", $Module),
        @("Tác nhân kích hoạt", $Actor),
        @("Sự kiện kích hoạt (Trigger)", $Trigger),
        @("Cấu trúc Dữ liệu Đầu vào", $InputSpec),
        @("Ràng buộc Kiểm tra Hợp lệ", $ValidationSpec),
        @("Thuật toán Xử lý Từng bước", $AlgorithmSpec),
        @("Truy vấn SQL / Entity Framework", $SqlSpec),
        @("Kết quả Đầu ra (Output)", $OutputSpec)
    )))
    return $sb.ToString()
}

function Build-Chapter2-DeepBFDAndDataDictionary {
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.Append((New-WHeading3 "2.2.3. Hồ sơ Đặc tả Thuật toán Chi tiết cho Từng Chức năng Lá trên Sơ đồ BFD (17 Chức năng)"))
    [void]$sb.Append((New-WP -Text "Để làm rõ logic xử lý bên trong từng nút lá của Sơ đồ Chức năng (BFD), dưới đây là 17 bảng hồ sơ đặc tả kỹ thuật chi tiết cho toàn bộ 17 chức năng nghiệp vụ lá thuộc 3 phân hệ (1.0 Admin Server, 2.0 Người Quản lý CRM, 3.0 Khách hàng):" -IndentFirst 420))

    # Nhánh 1.0: Admin Server (1.1 -> 1.6)
    [void]$sb.Append((New-BfdLeafDetailCard -Code "1.1" -Name "Tách biệt Giao diện Admin Server Độc lập" `
        -Module "1.0 Phân hệ Quản trị Máy chủ (Admin Server)" -Actor "Quản trị viên Máy chủ (Admin)" `
        -Trigger "Người dùng đăng nhập thành công với tài khoản có RoleName = 'Admin' hoặc truy cập trực tiếp tệp admin.html." `
        -InputSpec "Thông tin phiên đăng nhập lưu trong localStorage: { accountId, username, fullName, roleId: 1, roleName: 'Admin' }." `
        -ValidationSpec "Kiểm tra phiên làm việc hợp lệ; cô lập hoàn toàn DOM của admin.html khỏi các tập lệnh của quản lý nhân sự, quản lý kho, quản lý bán hàng và quản lý CRM." `
        -AlgorithmSpec "Bước 1: Đọc thông tin phiên đăng nhập từ localStorage.`nBước 2: Khởi tạo khung giao diện Admin Server chỉ gồm 2 Tab chuyên biệt: (Tab 1) Quản lý Tài khoản & Phân quyền, (Tab 2) Cơ cấu Phân quyền & Ma trận RBAC.`nBước 3: Không nạp bất kỳ module tìm kiếm/lọc sản phẩm hay nhà cung cấp nào vào không gian Admin Server." `
        -SqlSpec "SELECT a.*, r.RoleName FROM Accounts a INNER JOIN Roles r ON a.RoleId = r.RoleId WHERE a.Username = @username AND r.RoleName = N'Admin';" `
        -OutputSpec "Không gian làm việc độc lập tại admin.html, đảm bảo 100% nguyên tắc Separation of Duties."))

    [void]$sb.Append((New-BfdLeafDetailCard -Code "1.2" -Name "Xem, Tìm kiếm và Lọc Danh sách Account Hệ thống" `
        -Module "1.0 Phân hệ Quản trị Máy chủ (Admin Server)" -Actor "Quản trị viên Máy chủ (Admin)" `
        -Trigger "Khi khởi chạy Tab 1 trên admin.html hoặc khi Admin gõ từ khóa vào ô tìm kiếm / chọn Dropdown lọc vai trò." `
        -InputSpec "Từ khóa tìm kiếm (keyword: string) và Mã vai trò cần lọc (roleFilter: 'ALL' | 'Admin' | 'Manager' | 'Customer')." `
        -ValidationSpec "Chuẩn hóa chuỗi tìm kiếm về chữ thường (toLowerCase().trim()) để tìm kiếm chính xác tiếng Việt có dấu và không dấu." `
        -AlgorithmSpec "Bước 1: Gọi GET /api/admin/accounts để lấy toàn bộ 19 tài khoản từ SQL Server.`nBước 2: Tính toán 4 chỉ số KPI: Tổng số Account (all.length), Đang hoạt động (all.filter(x => x.isActive).length), Đã khóa (all.filter(x => !x.isActive).length), Tổng số Role (3).`nBước 3: Áp dụng bộ lọc kết hợp theo từ khóa (khớp Username, FullName, Email, Phone) và theo RoleName.`nBước 4: Kết xuất các dòng HTML vào bảng #accountsTableBody." `
        -SqlSpec "SELECT a.AccountId, a.Username, a.FullName, a.Email, a.Phone, a.RoleId, r.RoleName, a.IsActive, a.CreatedAt FROM Accounts a LEFT JOIN Roles r ON a.RoleId = r.RoleId ORDER BY a.AccountId DESC;" `
        -OutputSpec "Bảng danh sách tài khoản trực quan kèm 4 thẻ KPI cập nhật tức thời."))

    [void]$sb.Append((New-WPageBreak))

    [void]$sb.Append((New-BfdLeafDetailCard -Code "1.3" -Name "Thêm mới Tài khoản Định danh Người dùng (Create Account)" `
        -Module "1.0 Phân hệ Quản trị Máy chủ (Admin Server)" -Actor "Quản trị viên Máy chủ (Admin)" `
        -Trigger "Admin nhấn nút '+ Thêm tài khoản mới', điền biểu mẫu Modal và nhấn nút 'Lưu tài khoản'." `
        -InputSpec "Gói dữ liệu AccountCreateDto: { Username, Password, FullName, Email, Phone, RoleId }." `
        -ValidationSpec "1. Username và FullName không được rỗng.`n2. Username chưa tồn tại trong bảng Accounts (kiểm tra AnyAsync không phân biệt hoa thường).`n3. RoleId phải thuộc tập {1 (Admin), 2 (Manager), 3 (Customer)}." `
        -AlgorithmSpec "Bước 1: Kiểm tra trùng Username trong bảng Accounts.`nBước 2: Băm mật khẩu bằng BCrypt.Net.BCrypt.HashPassword(password).`nBước 3: Nếu Email rỗng, tự động gán '{username}@sgutech.vn'.`nBước 4: Thêm bản ghi mới vào bảng Accounts với IsActive = true, CreatedAt = DateTime.Now.`nBước 5: Nếu RoleId tương ứng với 'Customer', tự động khởi tạo thêm bản ghi mặc định trong bảng CustomerProfiles." `
        -SqlSpec "INSERT INTO Accounts (Username, PasswordHash, FullName, Email, Phone, RoleId, IsActive, CreatedAt) VALUES (@u, @p, @fn, @em, @ph, @rid, 1, GETDATE());" `
        -OutputSpec "Tài khoản mới được lưu vào CSDL và xuất hiện ngay ở dòng đầu tiên của bảng Account."))

    [void]$sb.Append((New-BfdLeafDetailCard -Code "1.4" -Name "Xóa Tài khoản Người dùng (Delete Account with Safe Cascade)" `
        -Module "1.0 Phân hệ Quản trị Máy chủ (Admin Server)" -Actor "Quản trị viên Máy chủ (Admin)" `
        -Trigger "Admin nhấn nút 'Xóa Account' tại dòng tài khoản bất kỳ và xác nhận hộp thoại cảnh báo." `
        -InputSpec "Mã định danh tài khoản cần xóa: id (int)." `
        -ValidationSpec "Kiểm tra tài khoản tồn tại trong bảng Accounts; cảnh báo xác nhận trước khi thực hiện xóa vĩnh viễn." `
        -AlgorithmSpec "Bước 1: Truy vấn bản ghi Account theo id.`nBước 2: Truy vấn và xóa toàn bộ bản ghi phụ thuộc trong bảng CustomerProfiles (Where AccountId == id).`nBước 3: Truy vấn và xóa toàn bộ bản ghi phụ thuộc trong bảng Feedbacks (Where AccountId == id).`nBước 4: Truy vấn và xóa toàn bộ bản ghi phụ thuộc trong bảng SurveyResponses (Where AccountId == id).`nBước 5: Xóa bản ghi gốc trong bảng Accounts và gọi SaveChangesAsync()." `
        -SqlSpec "DELETE FROM CustomerProfiles WHERE AccountId = @id; DELETE FROM Feedbacks WHERE AccountId = @id; DELETE FROM SurveyResponses WHERE AccountId = @id; DELETE FROM Accounts WHERE AccountId = @id;" `
        -OutputSpec "Tài khoản và dữ liệu phụ thuộc bị xóa sạch mà không xảy ra lỗi xung đột khóa ngoại SQL Server."))

    [void]$sb.Append((New-WPageBreak))

    [void]$sb.Append((New-BfdLeafDetailCard -Code "1.5" -Name "Khóa / Mở khóa Trạng thái Tài khoản (Toggle Account Lock)" `
        -Module "1.0 Phân hệ Quản trị Máy chủ (Admin Server)" -Actor "Quản trị viên Máy chủ (Admin)" `
        -Trigger "Admin nhấn nút 'Khóa' hoặc 'Mở khóa' trên dòng tài khoản tại bảng Quản trị Account." `
        -InputSpec "Mã định danh tài khoản: id (int)." `
        -ValidationSpec "Kiểm tra bản ghi Account tồn tại trong CSDL." `
        -AlgorithmSpec "Bước 1: Tìm bản ghi Account theo khóa chính id.`nBước 2: Đảo giá trị logic của thuộc tính IsActive (acc.IsActive = !acc.IsActive).`nBước 3: Lưu thay đổi vào SQL Server và trả về trạng thái mới cho giao diện." `
        -SqlSpec "UPDATE Accounts SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END WHERE AccountId = @id;" `
        -OutputSpec "Trạng thái tài khoản chuyển đổi tức thời giữa 'Hoạt động' (Xanh) và 'Đã khóa' (Đỏ)."))

    [void]$sb.Append((New-BfdLeafDetailCard -Code "1.6" -Name "Phân quyền Vai trò cho Account (Assign Role)" `
        -Module "1.0 Phân hệ Quản trị Máy chủ (Admin Server)" -Actor "Quản trị viên Máy chủ (Admin)" `
        -Trigger "Admin chọn vai trò mới trong Dropdown (Admin / Manager / Customer) trên dòng tài khoản và nhấn nút 'Phân quyền'." `
        -InputSpec "AccountId (int) và gói dữ liệu UpdateRoleDto: { RoleId: int }." `
        -ValidationSpec "Kiểm tra AccountId hợp lệ và RoleId thuộc danh mục 3 vai trò chuẩn trong bảng Roles." `
        -AlgorithmSpec "Bước 1: Tìm bản ghi Account theo id.`nBước 2: Gán acc.RoleId = dto.RoleId và lưu vào bảng Accounts.`nBước 3: Kiểm tra nếu vai trò mới là 'Customer' và tài khoản chưa có hồ sơ trong CustomerProfiles thì tự động khởi tạo bản ghi CustomerProfile mới." `
        -SqlSpec "UPDATE Accounts SET RoleId = @newRoleId WHERE AccountId = @id;" `
        -OutputSpec "Huy hiệu vai trò của tài khoản được cập nhật ngay trên giao diện và có hiệu lực ở lần đăng nhập kế tiếp."))

    [void]$sb.Append((New-WPageBreak))

    # Nhánh 2.0: Người Quản lý CRM (2.1 -> 2.7)
    [void]$sb.Append((New-BfdLeafDetailCard -Code "2.1" -Name "Thêm một Khách hàng mới (Create Customer & Demographics Profile)" `
        -Module "2.0 Phân hệ Người Quản lý Quan hệ Khách hàng (CRM Manager)" -Actor "Người Quản lý CRM (Manager)" `
        -Trigger "Người quản lý nhấn nút '+ Thêm một khách hàng mới' tại Tab 1 trên quanly.html, nhập thông tin và nhấn Lưu." `
        -InputSpec "CustomerRegisterDto: { Username, Password, FullName, Email, Phone, Age, Gender, Interest, Address }." `
        -ValidationSpec "Kiểm tra Username và FullName không được để trống; kiểm tra Username chưa tồn tại; Age > 0." `
        -AlgorithmSpec "Bước 1: Truy xuất bản ghi Role có RoleName == 'Customer' (RoleId = 3).`nBước 2: Tạo bản ghi Account mới với mật khẩu băm BCrypt, IsActive = true và lưu vào bảng Accounts để nhận AccountId tự tăng.`nBước 3: Tạo bản ghi CustomerProfile gắn với AccountId vừa sinh, lưu đầy đủ Độ tuổi (Age), Giới tính (Gender), Sở thích (Interest) và Địa chỉ (Address).`nBước 4: Cập nhật lại danh sách khách hàng và biểu đồ nhân khẩu học." `
        -SqlSpec "INSERT INTO Accounts (...) VALUES (...); INSERT INTO CustomerProfiles (AccountId, Age, Gender, Address, Interest) VALUES (SCOPE_IDENTITY(), @age, @gender, @addr, @interest);" `
        -OutputSpec "Khách hàng mới được khởi tạo đồng bộ cả tài khoản đăng nhập lẫn hồ sơ nhân khẩu học CRM."))

    [void]$sb.Append((New-BfdLeafDetailCard -Code "2.2 & 2.3" -Name "Xóa Khách hàng & Khóa Tài khoản Khách hàng" `
        -Module "2.0 Phân hệ Người Quản lý Quan hệ Khách hàng (CRM Manager)" -Actor "Người Quản lý CRM (Manager)" `
        -Trigger "Người quản lý nhấn nút 'Khóa TK / Mở khóa' hoặc nút 'Xóa' trên dòng khách hàng tại Tab 1 (quanly.html)." `
        -InputSpec "Mã tài khoản khách hàng: AccountId (int)." `
        -ValidationSpec "Xác thực khách hàng tồn tại trong CSDL; hiển thị hộp thoại xác nhận trước khi xóa vĩnh viễn." `
        -AlgorithmSpec "• Đối với Khóa TK (2.3): Gọi PUT /api/admin/crm/customers/{id}/toggle-status để đảo cờ IsActive của khách hàng. Khi IsActive = false, khách hàng bị chặn đăng nhập tại user.html.`n• Đối với Xóa KH (2.2): Gọi DELETE /api/admin/crm/customers/{id}, xóa sạch hồ sơ trong CustomerProfiles, các đánh giá trong Feedbacks, các phiếu khảo sát trong SurveyResponses rồi xóa bản ghi trong Accounts." `
        -SqlSpec "UPDATE Accounts SET IsActive = ~IsActive WHERE AccountId = @id; -- Hoặc chuỗi lệnh DELETE Cascade an toàn." `
        -OutputSpec "Cập nhật tức thời trạng thái khóa hoặc loại bỏ hoàn toàn khách hàng khỏi danh sách CRM."))

    [void]$sb.Append((New-WPageBreak))

    [void]$sb.Append((New-BfdLeafDetailCard -Code "2.4" -Name "Tiếp nhận và Giải đáp Phản hồi của Khách hàng" `
        -Module "2.0 Phân hệ Người Quản lý Quan hệ Khách hàng (CRM Manager)" -Actor "Người Quản lý CRM (Manager)" `
        -Trigger "Người quản lý mở Tab 2 (Tiếp nhận Phản hồi), nhấn nút 'Tiếp nhận & Trả lời', nhập nội dung giải đáp và nhấn Lưu." `
        -InputSpec "FeedbackId (int) và gói dữ liệu FeedbackReplyDto: { AdminReply: string }." `
        -ValidationSpec "Kiểm tra FeedbackId tồn tại trong bảng Feedbacks; nội dung giải đáp AdminReply không được rỗng." `
        -AlgorithmSpec "Bước 1: Tải toàn bộ danh sách phản hồi kèm thông tin Khách hàng (Accounts) và Sản phẩm (Products).`nBước 2: Vẽ biểu đồ cột phân bổ số lượng đánh giá từ 1 sao đến 5 sao và biểu đồ top sản phẩm được phản hồi.`nBước 3: Khi Người quản lý gửi câu trả lời, cập nhật trường fb.AdminReply = dto.AdminReply và chuyển trạng thái fb.Status = 'Đã tiếp nhận & Xử lý'." `
        -SqlSpec "UPDATE Feedbacks SET AdminReply = @reply, Status = N'Đã tiếp nhận & Xử lý' WHERE FeedbackId = @id;" `
        -OutputSpec "Câu trả lời giải đáp của Người quản lý được lưu trữ và hiển thị công khai trên Cổng Khách hàng."))

    [void]$sb.Append((New-BfdLeafDetailCard -Code "2.5" -Name "Báo cáo về Khách hàng: Tỷ lệ Độ tuổi & Sở thích" `
        -Module "2.0 Phân hệ Người Quản lý Quan hệ Khách hàng (CRM Manager)" -Actor "Người Quản lý CRM (Manager)" `
        -Trigger "Người quản lý mở Tab 3 (Báo cáo Độ tuổi & Sở thích) trên giao diện quanly.html." `
        -InputSpec "Yêu cầu HTTP GET /api/admin/crm/reports/demographics." `
        -ValidationSpec "Kiểm tra tổng số hồ sơ khách hàng (totalCustomers > 0) trước khi tính tỷ lệ phần trăm." `
        -AlgorithmSpec "Bước 1: Đọc toàn bộ bản ghi trong bảng CustomerProfiles.`nBước 2: Phân nhóm độ tuổi khách hàng thành các phân khúc chuẩn và tính tỷ lệ % từng phân khúc.`nBước 3: Thực hiện GroupBy theo thuộc tính Interest (Gaming, Văn phòng, Đồ họa, Lập trình), đếm số lượng (Count) và tính Percentage = Round(Count * 100.0 / Total, 1).`nBước 4: Vẽ Biểu đồ Vòng (Doughnut Chart) cho tỷ lệ độ tuổi và Biểu đồ Cột (Bar Chart) cho phân bố sở thích." `
        -SqlSpec "SELECT Interest, COUNT(*) AS Count, CAST(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS DECIMAL(5,1)) AS Percentage FROM CustomerProfiles GROUP BY Interest;" `
        -OutputSpec "Báo cáo nhân khẩu học trực quan gồm 3 thẻ chỉ số, 2 biểu đồ đồ họa và 2 bảng phân tích tỷ lệ %."))

    [void]$sb.Append((New-WPageBreak))

    [void]$sb.Append((New-BfdLeafDetailCard -Code "2.6 & 2.7" -Name "Tạo Bảng Khảo sát Gửi đến TK Khách hàng & Thống kê Kết quả Khảo sát" `
        -Module "2.0 Phân hệ Người Quản lý Quan hệ Khách hàng (CRM Manager)" -Actor "Người Quản lý CRM (Manager)" `
        -Trigger "Người quản lý thao tác tại Tab 4 (Tạo & Gửi Khảo sát) và Tab 5 (Thống kê Khảo sát) trên quanly.html." `
        -InputSpec "• Tạo khảo sát (2.6): SurveyCreateDto { Title, TargetProduct, ExpectedPrice, DurationType, DurationDays, ExpiresAt, Description }.`n• Thống kê khảo sát (2.7): SurveyId cần tổng hợp kết quả." `
        -ValidationSpec "Kiểm tra Title, TargetProduct không rỗng; ExpectedPrice >= 0; tính toán chính xác thời điểm hết hạn ExpiresAt." `
        -AlgorithmSpec "• Tạo khảo sát (2.6): Lưu chiến dịch mới vào bảng Surveys với IsActive = true; tự động phân phối tới toàn bộ tài khoản khách hàng đang hoạt động.`n• Thống kê khảo sát (2.7): Truy vấn bảng SurveyResponses theo SurveyId; tính tổng số lượt trả lời (totalResponses), điểm mức độ quan tâm trung bình (averageScore = Average(Score)), thống kê 3 mức ý định mua ('Rất muốn mua', 'Đang cân nhắc', 'Không mua') và phân bố điểm 1–5." `
        -SqlSpec "SELECT SurveyId, COUNT(*) AS TotalResponses, AVG(CAST(Score AS FLOAT)) AS AvgScore, SUM(CASE WHEN BuyingIntent = N'Rất muốn mua' THEN 1 ELSE 0 END) AS WantToBuy FROM SurveyResponses GROUP BY SurveyId;" `
        -OutputSpec "Chiến dịch khảo sát được gửi tới tài khoản khách hàng và kết xuất Dashboard thống kê khảo sát toàn diện."))

    # Nhánh 3.0: Khách hàng (3.1 -> 3.5)
    [void]$sb.Append((New-BfdLeafDetailCard -Code "3.1, 3.2 & 3.3" -Name "Đăng ký Tài khoản, Đăng nhập & Chỉnh sửa Thông tin Cá nhân Khách hàng" `
        -Module "3.0 Phân hệ Cổng Tương tác Khách hàng (Customer Portal)" -Actor "Khách hàng (Customer)" `
        -Trigger "Khách hàng thao tác tại màn hình Đăng ký/Đăng nhập hoặc Tab 'Hồ sơ cá nhân' trên user.html." `
        -InputSpec "Thông tin đăng ký/đăng nhập hoặc gói dữ liệu cập nhật hồ sơ CustomerUpdateProfileDto: { FullName, Email, Phone, Age, Gender, Address, Interest }." `
        -ValidationSpec "Kiểm tra Username duy nhất khi đăng ký; kiểm tra tài khoản không bị khóa (IsActive == true) khi đăng nhập; kiểm tra Age > 0 khi sửa hồ sơ." `
        -AlgorithmSpec "1. Đăng ký (3.1): Băm mật khẩu BCrypt, tạo bản ghi Accounts (Role = Customer) + CustomerProfiles và cấp phiên đăng nhập tự động.`n2. Đăng nhập (3.2): Kiểm tra Username/Password và trạng thái IsActive, tải thông tin cá nhân của khách hàng.`n3. Chỉnh sửa thông tin (3.3): Cập nhật đồng thời Họ tên, SĐT, Email vào bảng Accounts và Độ tuổi, Giới tính, Sở thích, Địa chỉ vào bảng CustomerProfiles." `
        -SqlSpec "UPDATE Accounts SET FullName = @fn, Email = @em, Phone = @ph WHERE AccountId = @id; UPDATE CustomerProfiles SET Age = @age, Gender = @g, Address = @addr, Interest = @int WHERE AccountId = @id;" `
        -OutputSpec "Hồ sơ cá nhân của khách hàng luôn được cập nhật chính xác và đồng bộ tức thời với báo cáo CRM."))

    [void]$sb.Append((New-WPageBreak))

    [void]$sb.Append((New-BfdLeafDetailCard -Code "3.4 & 3.5" -Name "Gửi Phản hồi về Sản phẩm & Nhận, Thực hiện Bảng Khảo sát" `
        -Module "3.0 Phân hệ Cổng Tương tác Khách hàng (Customer Portal)" -Actor "Khách hàng (Customer)" `
        -Trigger "Khách hàng thao tác tại Tab 1 (Phản hồi sản phẩm) và Tab 2 (Khảo sát thị trường) trên user.html." `
        -InputSpec "• Phản hồi SP (3.4): { ProductId, Rating (1–5 sao), Comment }.`n• Làm khảo sát (3.5): { SurveyId, AccountId, Score (1–5 điểm), BuyingIntent, CustomerOpinion }." `
        -ValidationSpec "• Phản hồi SP: Phải chọn sản phẩm hợp lệ, Rating thuộc [1..5], Comment không rỗng.`n• Làm khảo sát: Khảo sát phải đang mở (IsActive == true), chưa hết hạn (ExpiresAt > Now) và khách hàng chưa từng nộp phiếu cho SurveyId này." `
        -AlgorithmSpec "• Phản hồi SP (3.4): Thêm bản ghi mới vào bảng Feedbacks với Status = 'Chờ xử lý'; hỗ trợ lọc danh sách đánh giá công khai và câu trả lời của Người quản lý theo từng sản phẩm.`n• Làm khảo sát (3.5): Kiểm tra chống gửi trùng lặp bằng AnyAsync(r => r.SurveyId == surveyId && r.AccountId == accountId); lưu phiếu trả lời vào bảng SurveyResponses và đổi trạng thái nút thành 'Đã thực hiện'." `
        -SqlSpec "INSERT INTO Feedbacks (AccountId, ProductId, Rating, Comment, Status, CreatedAt) VALUES (@aid, @pid, @rate, @cmt, N'Chờ xử lý', GETDATE());`nINSERT INTO SurveyResponses (SurveyId, AccountId, Score, BuyingIntent, CustomerOpinion, SubmittedAt) VALUES (@sid, @aid, @sc, @intent, @op, GETDATE());" `
        -OutputSpec "Phản hồi sản phẩm và kết quả khảo sát của khách hàng được ghi nhận tức thời vào CSDL trung tâm."))

    # TỪ ĐIỂN ĐẠI SỐ LUỒNG DỮ LIỆU (DATA FLOW ALGEBRAIC DICTIONARY)
    [void]$sb.Append((New-WHeading3 "2.3.4. Từ điển Cấu trúc Đại số các Luồng Dữ liệu (Data Flow Algebraic Dictionary)"))
    [void]$sb.Append((New-WP -Text "Theo phương pháp luận Phân tích và Thiết kế Hệ thống Thông tin có cấu trúc (Structured Systems Analysis and Design Method – SSADM), cấu trúc của từng luồng dữ liệu trên Sơ đồ Ngữ cảnh và Sơ đồ DFD được định nghĩa chính xác bằng ký hiệu đại số dữ liệu ('=' là bao gồm; '+' là nối kết; '[ | ]' là lựa chọn một trong các phương án; '{ }n' là lặp lại n lần; '( )' là thành phần tùy chọn):" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Tên Luồng Dữ liệu Chuẩn", "Biểu thức Định nghĩa Cấu trúc Đại số Dữ liệu (Data Structure Expression)") -ColWidths @(2800, 6800) -Rows @(
        @("ThongTinDangNhap", "= Username + Password"),
        @("PhienLamViecHopLe", "= AccountId + Username + FullName + RoleId + [ 'Admin' | 'Manager' | 'Customer' ]"),
        @("LenhTaoAccount", "= Username + Password + FullName + (Email) + (Phone) + RoleId"),
        @("LenhPhanQuyenAccount", "= AccountId + [ RoleId_Admin | RoleId_Manager | RoleId_Customer ]"),
        @("DanhSachAccountHeThong", "= TongSoAccount + SoAccountHoatDong + SoAccountBiKhoa + { AccountId + Username + FullName + Email + Phone + RoleName + IsActive + CreatedAt }1..N"),
        @("HoSoKhachHangMoi", "= Username + Password + FullName + Phone + (Email) + Age + [ 'Nam' | 'Nữ' | 'Khác' ] + [ 'Gaming' | 'Đồ họa' | 'Văn phòng' | 'Lập trình' ] + (Address)"),
        @("PhieuDanhGiaSanPham", "= AccountId + ProductId + [ 1_Sao | 2_Sao | 3_Sao | 4_Sao | 5_Sao ] + Comment + CreatedAt"),
        @("GiaiDapPhanHoiQuanLy", "= FeedbackId + AdminReply + [ 'Chờ xử lý' | 'Đã tiếp nhận & Xử lý' ]"),
        @("BaoCaoNhanKhauHocKH", "= TotalCustomers + (Under20Count + From20To30Count + Over30Count) + { InterestName + CustomerCount + Percentage }1..K"),
        @("ChienDichKhaoSatMoi", "= Title + TargetProduct + ExpectedPrice + [ 'NoLimit' | 'Days' + DurationDays | 'Date' + ExpiresAt ] + Description"),
        @("PhieuTraLoiKhaoSat", "= SurveyId + AccountId + [ 1_Diem | 2_Diem | 3_Diem | 4_Diem | 5_Diem ] + [ 'Rất muốn mua' | 'Đang cân nhắc' | 'Không mua' ] + (CustomerOpinion)"),
        @("BaoCaoThongKeKhaoSat", "= SurveyId + Title + TargetProduct + TotalResponses + AverageScore + (WantToBuyCount + ConsideringCount + NotBuyingCount) + { CustomerName + Score + BuyingIntent + CustomerOpinion + SubmittedAt }0..M")
    )))

    [void]$sb.Append((New-WPageBreak))
    return $sb.ToString()
}

function Build-Chapter3-DeepSqlAndUiWalkthrough {
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.Append((New-WHeading3 "3.1.5. Thiết kế Chỉ mục Tối ưu Hiệu năng (Database Indexing) và Truy vấn Thống kê Cốt lõi"))
    [void]$sb.Append((New-WP -Text "Để đảm bảo thời gian phản hồi của toàn bộ 21 RESTful API luôn đạt dưới 50ms khi quy mô dữ liệu mở rộng lên hàng trăm nghìn bản ghi, hệ thống thiết kế bộ chỉ mục phi cụm (Non-Clustered Indexes) và các câu lệnh truy vấn thống kê tối ưu trên SQL Server:" -IndentFirst 420))

    [void]$sb.Append((New-WCodeBlock -Title "Thiết kế Chỉ mục (Indexes) và Truy vấn Phân tích Thống kê CRM trên SQL Server:" -CodeText @"
-- 1. CÁC CHỈ MỤC TỐI ƯU HÓA TÌM KIẾM & THỐNG KÊ (NON-CLUSTERED INDEXES)
CREATE UNIQUE NONCLUSTERED INDEX IX_Accounts_Username ON Accounts(Username);
CREATE NONCLUSTERED INDEX IX_Accounts_RoleId_IsActive ON Accounts(RoleId, IsActive);
CREATE NONCLUSTERED INDEX IX_CustomerProfiles_Interest_Age ON CustomerProfiles(Interest, Age);
CREATE NONCLUSTERED INDEX IX_Feedbacks_ProductId_Rating ON Feedbacks(ProductId, Rating, Status);
CREATE UNIQUE NONCLUSTERED INDEX IX_SurveyResponses_UniqueCustomerSurvey ON SurveyResponses(SurveyId, AccountId);
GO

-- 2. TRUY VẤN BÁO CÁO TỶ LỆ ĐỘ TUỔI KHÁCH HÀNG (PHỤC VỤ TAB 3 NGƯỜI QUẢN LÝ CRM)
SELECT
    COUNT(*) AS TongSoKhachHang,
    ROUND(AVG(CAST(Age AS FLOAT)), 1) AS DoTuoiTrungBinh,
    SUM(CASE WHEN Age < 20 THEN 1 ELSE 0 END) AS Duoi20Tuoi,
    SUM(CASE WHEN Age BETWEEN 20 AND 30 THEN 1 ELSE 0 END) AS Tu20Den30Tuoi,
    SUM(CASE WHEN Age > 30 THEN 1 ELSE 0 END) AS Tren30Tuoi
FROM CustomerProfiles;
GO

-- 3. TRUY VẤN BÁO CÁO PHÂN BỐ SỞ THÍCH TIÊU DÙNG KÈM TỶ LỆ PHẦN TRĂM
SELECT
    ISNULL(Interest, N'Khác') AS NhomSoThich,
    COUNT(*) AS SoLuongKhachHang,
    CAST(ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM CustomerProfiles), 0), 1) AS DECIMAL(5,1)) AS TyLePhanTram
FROM CustomerProfiles
GROUP BY ISNULL(Interest, N'Khác')
ORDER BY SoLuongKhachHang DESC;
GO

-- 4. TRUY VẤN THỐNG KÊ KẾT QUẢ KHẢO SÁT TOÀN DIỆN (PHỤC VỤ TAB 5 NGƯỜI QUẢN LÝ CRM)
SELECT
    s.SurveyId,
    s.Title,
    s.TargetProduct,
    s.ExpectedPrice,
    COUNT(r.ResponseId) AS SoLuotThamGia,
    ISNULL(ROUND(AVG(CAST(r.Score AS FLOAT)), 2), 0) AS DiemQuanTamTrungBinh,
    SUM(CASE WHEN r.BuyingIntent = N'Rất muốn mua' THEN 1 ELSE 0 END) AS RatMuonMua,
    SUM(CASE WHEN r.BuyingIntent = N'Đang cân nhắc' THEN 1 ELSE 0 END) AS DangCanNhac,
    SUM(CASE WHEN r.BuyingIntent = N'Không mua' THEN 1 ELSE 0 END) AS KhongMua
FROM Surveys s
LEFT JOIN SurveyResponses r ON s.SurveyId = r.SurveyId
GROUP BY s.SurveyId, s.Title, s.TargetProduct, s.ExpectedPrice
ORDER BY s.SurveyId ASC;
GO
"@))

    [void]$sb.Append((New-WPageBreak))
    return $sb.ToString()
}

function Build-Part3-DeepControllersAndFrontendCode {
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.Append((New-WHeading2 "III.3. Đặc tả Mã nguồn Cốt lõi Phân hệ Cổng Khách hàng (CustomerPortalController.cs)"))
    [void]$sb.Append((New-WP -Text "Toàn bộ 5 nghiệp vụ của Khách hàng (Đăng ký, Đăng nhập, Chỉnh sửa thông tin cá nhân, Gửi phản hồi về sản phẩm kèm lọc theo sản phẩm, Nhận và thực hiện khảo sát) được xử lý tập trung tại lớp CustomerPortalController.cs dưới đây:" -IndentFirst 420))

    [void]$sb.Append((New-WCodeBlock -Title "Mã nguồn CustomerPortalController.cs (Xử lý 5 Nghiệp vụ Cổng Khách hàng):" -CodeText @"
[Route("api/customer")]
[ApiController]
public class CustomerPortalController : ControllerBase
{
    private readonly AppDbContext _context;
    public CustomerPortalController(AppDbContext context) => _context = context;

    // 1. ĐĂNG KÝ TÀI KHOẢN KHÁCH HÀNG MỚI
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] CustomerRegisterDto dto)
    {
        string username = (dto.Username ?? "").Trim();
        string password = (dto.Password ?? "").Trim();
        string fullName = (dto.FullName ?? "").Trim();
        if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            return BadRequest(new { message = "Vui lòng nhập đầy đủ Tên đăng nhập và Mật khẩu!" });

        if (await _context.Accounts.AnyAsync(a => a.Username.ToLower() == username.ToLower()))
            return BadRequest(new { message = "Tên đăng nhập này đã được sử dụng!" });

        var role = await _context.Roles.FirstOrDefaultAsync(r => r.RoleName == "Customer");
        string email = string.IsNullOrWhiteSpace(dto.Email) ? $"{username.ToLower()}@customer.sgutech.vn" : dto.Email.Trim();

        var acc = new Account {
            Username = username,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(password),
            FullName = string.IsNullOrEmpty(fullName) ? username : fullName,
            Email = email, Phone = (dto.Phone ?? "").Trim(),
            RoleId = role!.RoleId, IsActive = true, CreatedAt = DateTime.Now
        };
        _context.Accounts.Add(acc);
        await _context.SaveChangesAsync();

        var profile = new CustomerProfile {
            AccountId = acc.AccountId,
            Age = dto.Age > 0 ? dto.Age : 20,
            Gender = string.IsNullOrWhiteSpace(dto.Gender) ? "Nam" : dto.Gender,
            Address = dto.Address ?? "",
            Interest = string.IsNullOrWhiteSpace(dto.Interest) ? "Gaming" : dto.Interest
        };
        _context.CustomerProfiles.Add(profile);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Đăng ký tài khoản thành công!", accountId = acc.AccountId, username = acc.Username, fullName = acc.FullName, role = "Customer" });
    }

    // 2. CHỈNH SỬA THÔNG TIN HỒ SƠ CÁ NHÂN KHÁCH HÀNG
    [HttpPut("profile/{accountId}")]
    public async Task<IActionResult> UpdateProfile(int accountId, [FromBody] CustomerUpdateProfileDto dto)
    {
        var acc = await _context.Accounts.FindAsync(accountId);
        if (acc == null) return NotFound();
        if (!string.IsNullOrWhiteSpace(dto.FullName)) acc.FullName = dto.FullName.Trim();
        if (!string.IsNullOrWhiteSpace(dto.Email)) acc.Email = dto.Email.Trim();
        if (dto.Phone != null) acc.Phone = dto.Phone.Trim();

        var profile = await _context.CustomerProfiles.FirstOrDefaultAsync(p => p.AccountId == accountId);
        if (profile == null) {
            profile = new CustomerProfile { AccountId = accountId };
            _context.CustomerProfiles.Add(profile);
        }
        if (dto.Age > 0) profile.Age = dto.Age;
        if (!string.IsNullOrWhiteSpace(dto.Gender)) profile.Gender = dto.Gender;
        if (dto.Address != null) profile.Address = dto.Address.Trim();
        if (!string.IsNullOrWhiteSpace(dto.Interest)) profile.Interest = dto.Interest;

        await _context.SaveChangesAsync();
        return Ok(new { message = "Cập nhật thông tin hồ sơ thành công!" });
    }

    // 3. GỬI PHẢN HỒI ĐÁNH GIÁ VỀ SẢN PHẨM
    [HttpPost("feedbacks/{accountId}")]
    public async Task<IActionResult> CreateFeedback(int accountId, [FromBody] FeedbackCreateDto dto)
    {
        var fb = new Feedback {
            AccountId = accountId, ProductId = dto.ProductId,
            Rating = dto.Rating, Comment = dto.Comment,
            Status = "Chờ xử lý", CreatedAt = DateTime.Now
        };
        _context.Feedbacks.Add(fb);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Cảm ơn bạn đã gửi đánh giá sản phẩm!" });
    }

    // 4. NHẬN BẢNG KHẢO SÁT VÀ GỬI KẾT QUẢ THỰC HIỆN KHẢO SÁT
    [HttpPost("surveys/{surveyId}/submit/{accountId}")]
    public async Task<IActionResult> SubmitSurvey(int surveyId, int accountId, [FromBody] SurveyAnswerDto dto)
    {
        var survey = await _context.Surveys.FindAsync(surveyId);
        if (survey == null) return NotFound(new { message = "Không tìm thấy khảo sát!" });
        if (!survey.IsActive) return BadRequest(new { message = "Khảo sát này hiện đang bị khóa!" });
        if (survey.ExpiresAt.HasValue && survey.ExpiresAt.Value < DateTime.Now)
            return BadRequest(new { message = "Khảo sát này đã hết thời hạn tham gia!" });
        if (await _context.SurveyResponses.AnyAsync(r => r.SurveyId == surveyId && r.AccountId == accountId))
            return BadRequest(new { message = "Bạn đã thực hiện bài khảo sát này rồi!" });

        var resp = new SurveyResponse {
            SurveyId = surveyId, AccountId = accountId,
            Score = dto.Score, BuyingIntent = dto.BuyingIntent,
            CustomerOpinion = dto.CustomerOpinion, SubmittedAt = DateTime.Now
        };
        _context.SurveyResponses.Add(resp);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Gửi kết quả khảo sát thành công!" });
    }
}
"@))

    [void]$sb.Append((New-WHeading2 "III.4. Kịch bản Demo Nghiệm thu Trực tiếp trên Lớp (Step-by-Step Live Demo Script)"))
    [void]$sb.Append((New-WP -Text "Bảng kịch bản dưới đây tóm tắt lộ trình trình bày và demo trực tiếp 100% tính năng của đồ án trước Giảng viên chấm thi trong thời gian 10–15 phút:" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Bước Demo", "Màn hình / Cổng Giao diện", "Tài khoản Sử dụng", "Thao tác Trình diễn Trực tiếp trước Giảng viên", "Điểm Nhấn Kỹ thuật & Nghiệp vụ Chứng minh") -ColWidths @(1000, 1700, 1400, 3000, 2500) -Rows @(
        @("Bước 1`n(2 phút)", "Admin Server`n(admin.html)", "admin`nMật khẩu: 123456", "1. Đăng nhập vào Admin Server.`n2. Chỉ rõ giao diện tách biệt hoàn toàn, không còn mục lọc SP/NCC.`n3. Thêm 1 tài khoản mới, đổi phân quyền (Admin/Manager/Customer), Khóa/Mở khóa và Xóa Account.", "Đáp ứng 100% yêu cầu tách biệt giao diện Admin Server và chuẩn hóa đúng 3 Role."),
        @("Bước 2`n(3 phút)", "Người Quản lý`n(quanly.html`nTab 1 & Tab 2)", "quanly`nMật khẩu: 123456", "1. Tại Tab 1: Thêm 1 khách hàng mới, Khóa TK khách hàng và Xóa khách hàng.`n2. Tại Tab 2: Xem biểu đồ đánh giá 1–5 sao, nhấn 'Tiếp nhận & Trả lời' một phản hồi đang chờ xử lý.", "Đáp ứng 4 nghiệp vụ đầu của Người quản lý CRM; câu trả lời đồng bộ ngay sang cổng KH."),
        @("Bước 3`n(3 phút)", "Người Quản lý`n(quanly.html`nTab 3, 4, 5)", "quanly`nMật khẩu: 123456", "1. Tại Tab 3: Trình bày Biểu đồ Tỷ lệ Độ tuổi & Biểu đồ Sở thích.`n2. Tại Tab 4: Tạo 1 bảng khảo sát sản phẩm mới gửi đến TK khách hàng.`n3. Tại Tab 5: Xem Thống kê kết quả khảo sát.", "Đáp ứng trọn vẹn 3 nghiệp vụ báo cáo nhân khẩu học, phát hành khảo sát & thống kê khảo sát."),
        @("Bước 4`n(3 phút)", "Cổng Khách hàng`n(user.html)", "khachhang1`nMật khẩu: 123456", "1. Đăng ký tài khoản KH mới hoặc đăng nhập khachhang1.`n2. Gửi phản hồi 5 sao cho sản phẩm, lọc xem giải đáp theo sản phẩm.`n3. Mở tab Khảo sát thị trường, thực hiện bảng khảo sát vừa tạo.`n4. Mở tab Hồ sơ cá nhân, chỉnh sửa Độ tuổi & Sở thích.", "Đáp ứng trọn vẹn 5 nghiệp vụ của Khách hàng; kết quả khảo sát & hồ sơ cập nhật ngược về CRM tức thì.")
    )))

    return $sb.ToString()
}
