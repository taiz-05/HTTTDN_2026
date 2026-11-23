# ==============================================================================
# PART 8: ĐẶC TẢ CHUYÊN SÂU MỨC ĐỈNH CHO CÁC PHẦN NHIỀU ĐIỂM NHẤT CỦA ĐỒ ÁN:
# - ĐẶC TẢ 13 TIẾN TRÌNH DFD MỨC 1 BẰNG NGÔN NGỮ CÓ CẤU TRÚC (STRUCTURED ENGLISH)
# - ĐẶC TẢ HỆ THỐNG RÀNG BUỘC TOÀN VẸN CSDL & BẢNG TẦM ẢNH HƯỞNG (INSERT/DELETE/UPDATE)
# - ĐẶC TẢ KỊCH BẢN TƯƠNG TÁC GIAO DIỆN & TRẠNG THÁI (UI STATE & EVENT FLOWS)
# - ĐẶC TẢ CHI TIẾT NHẬT KÝ THỰC THI KIỂM THỬ & MÃ NGUỒN FRONTEND/BACKEND ĐẦY ĐỦ
# ==============================================================================

function New-ProcessMiniSpec {
    param(
        [string]$ProcId,
        [string]$PName,
        [string]$ParentDfd,
        [string]$Inputs,
        [string]$Outputs,
        [string]$DataStores,
        [string]$StructuredEnglish
    )
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append((New-WHeading4 "Đặc tả Tiến trình DFD [$ProcId]: $PName"))
    [void]$sb.Append((New-WTable -Headers @("Thuộc tính Tiến trình (P-Spec)", "Nội dung Đặc tả Chi tiết Tiến trình [$ProcId]") -ColWidths @(2500, 7100) -Rows @(
        @("Số hiệu & Tên Tiến trình", "Tiến trình $ProcId — $PName"),
        @("Thuộc Sơ đồ DFD", $ParentDfd),
        @("Luồng Dữ liệu Vào (Input Flows)", $Inputs),
        @("Luồng Dữ liệu Ra (Output Flows)", $Outputs),
        @("Kho Dữ liệu Tham chiếu", $DataStores)
    )))
    [void]$sb.Append((New-WCodeBlock -Title "Đặc tả Thuật toán Ngôn ngữ Có Cấu trúc (Structured English) của Tiến trình $ProcId :" -CodeText $StructuredEnglish))
    return $sb.ToString()
}

function Build-Chapter2-DeepProcessMiniSpecs {
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.Append((New-WHeading3 "2.4.8. Hồ sơ Đặc tả Chi tiết 13 Tiến trình DFD Mức 1 bằng Ngôn ngữ Có Cấu trúc (Process Mini-Specifications / P-Specs)"))
    [void]$sb.Append((New-WP -Text "Trong phương pháp phân tích hệ thống có cấu trúc, mỗi tiến trình lá trên Sơ đồ Luồng dữ liệu Mức 1 (Level 1 DFD) phải được đặc tả chi tiết bằng Ngôn ngữ Có Cấu trúc (Structured English / Pseudocode) để định nghĩa rõ ràng các điều kiện rẽ nhánh (IF – THEN – ELSE), các thao tác đọc/ghi Kho dữ liệu (READ / WRITE / UPDATE / DELETE) và luồng trả kết quả về Tác nhân:" -IndentFirst 420))

    # P1.1
    [void]$sb.Append((New-ProcessMiniSpec -ProcId "1.1" -PName "Xác thực & Tách biệt Giao diện Admin Server" `
        -ParentDfd "DFD Mức 1 — Phân hệ 1.0: Quản trị Máy chủ (Admin Server)" `
        -Inputs "ThongTinDangNhap (Username, Password) từ Tác nhân Quản trị viên" `
        -Outputs "PhienLamViecHopLe hoặc ThongBaoLoiXacThuc về Tác nhân Quản trị viên" `
        -DataStores "Đọc Kho D1 (Bảng Accounts kết hợp Bảng Roles)" `
        -StructuredEnglish @"
BEGIN PROCESS 1.1 (XacThuc_Va_TachBiet_GiaoDien_Admin)
  RECEIVE Username, Password FROM Actor_Admin
  IF Username IS EMPTY OR Password IS EMPTY THEN
      RETURN HTTP_400 ("Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu!")
  END IF

  READ Account JOIN Role FROM DataStore_D1 (Accounts, Roles)
       WHERE LOWER(Account.Username) = LOWER(TRIM(Username))

  IF Account NOT FOUND THEN
      RETURN HTTP_401 ("Tài khoản không tồn tại!")
  ELSE IF Account.IsActive = FALSE THEN
      RETURN HTTP_401 ("Tài khoản này đã bị khóa!")
  END IF

  IF VerifyPassword(Password, Account.PasswordHash) = FALSE THEN
      RETURN HTTP_401 ("Sai mật khẩu!")
  END IF

  IF Account.Role.RoleName = "Admin" THEN
      SET SessionToken = { AccountId, Username, FullName, RoleId: 1, RoleName: "Admin" }
      REDIRECT Actor_Admin TO Isolated_Workspace ("admin.html")
      -- Tuyệt đối tách biệt khỏi giao diện Nhân sự, Kho, Bán hàng và CRM
  ELSE IF Account.Role.RoleName = "Manager" THEN
      REDIRECT User TO CRM_Workspace ("quanly.html")
  ELSE
      REDIRECT User TO Customer_Portal ("user.html")
  END IF
END PROCESS 1.1
"@))

    # P1.2
    [void]$sb.Append((New-ProcessMiniSpec -ProcId "1.2" -PName "Thêm mới & Xóa Tài khoản Định danh (Account)" `
        -ParentDfd "DFD Mức 1 — Phân hệ 1.0: Quản trị Máy chủ (Admin Server)" `
        -Inputs "LenhTaoAccount (AccountCreateDto) hoặc LenhXoaAccount (AccountId) từ Quản trị viên" `
        -Outputs "ThongBaoKetQuaCapNhat về Quản trị viên" `
        -DataStores "Ghi/Xóa Kho D1 (Accounts), Kho D2 (CustomerProfiles), Kho D4 (Feedbacks), Kho D5 (SurveyResponses)" `
        -StructuredEnglish @"
BEGIN PROCESS 1.2 (ThemMoi_Va_Xoa_Account)
  IF Action = "CREATE_ACCOUNT" THEN
      RECEIVE { Username, Password, FullName, Email, Phone, RoleId } FROM Actor_Admin
      READ ExistingAccount FROM DataStore_D1 WHERE LOWER(Username) = LOWER(TRIM(dto.Username))
      IF ExistingAccount EXISTS THEN
          RETURN HTTP_400 ("Username đã tồn tại!")
      END IF
      SET HashedPass = BCrypt_Hash(ISNULL(Password, "123456"))
      SET NormalizedEmail = ISNULL(Email, LOWER(Username) + "@sgutech.vn")
      WRITE New_Account(Username, HashedPass, FullName, NormalizedEmail, Phone, RoleId, IsActive=TRUE) TO DataStore_D1
      IF RoleId = 3 (RoleName = "Customer") THEN
          WRITE Default_CustomerProfile(AccountId = New_Account.AccountId, Age = 22, Interest = "Lập trình") TO DataStore_D2
      END IF
      RETURN HTTP_200 ("Tạo tài khoản thành công!")

  ELSE IF Action = "DELETE_ACCOUNT" THEN
      RECEIVE TargetAccountId FROM Actor_Admin
      READ Account FROM DataStore_D1 WHERE AccountId = TargetAccountId
      IF Account NOT FOUND THEN
          RETURN HTTP_404 ("Không tìm thấy tài khoản!")
      END IF
      -- Xóa dây chuyền an toàn (Safe Cascade Delete) để bảo toàn khóa ngoại SQL Server:
      DELETE FROM DataStore_D2 (CustomerProfiles) WHERE AccountId = TargetAccountId
      DELETE FROM DataStore_D4 (Feedbacks)        WHERE AccountId = TargetAccountId
      DELETE FROM DataStore_D5 (SurveyResponses)  WHERE AccountId = TargetAccountId
      DELETE FROM DataStore_D1 (Accounts)         WHERE AccountId = TargetAccountId
      RETURN HTTP_200 ("Đã xóa tài khoản thành công!")
  END IF
END PROCESS 1.2
"@))

    [void]$sb.Append((New-WPageBreak))

    # P1.3 & P1.4
    [void]$sb.Append((New-ProcessMiniSpec -ProcId "1.3" -PName "Phân quyền Vai trò cho Account (Assign Role)" `
        -ParentDfd "DFD Mức 1 — Phân hệ 1.0: Quản trị Máy chủ (Admin Server)" `
        -Inputs "AccountId và RoleId mới (1: Admin, 2: Manager, 3: Customer) từ Quản trị viên" `
        -Outputs "TrangThaiPhanQuyenMoi về Quản trị viên" `
        -DataStores "Cập nhật Kho D1 (Accounts); Kiểm tra & Ghi Kho D2 (CustomerProfiles)" `
        -StructuredEnglish @"
BEGIN PROCESS 1.3 (PhanQuyen_VaiTro_Account)
  RECEIVE AccountId, NewRoleId FROM Actor_Admin
  READ Account FROM DataStore_D1 (Accounts) WHERE Account.AccountId = AccountId
  IF Account NOT FOUND THEN
      RETURN HTTP_404 ("Không tìm thấy tài khoản!")
  END IF

  READ TargetRole FROM DataStore_D1 (Roles) WHERE RoleId = NewRoleId
  IF TargetRole NOT IN ("Admin", "Manager", "Customer") THEN
      RETURN HTTP_400 ("Vai trò phân quyền không hợp lệ!")
  END IF

  UPDATE DataStore_D1 (Accounts) SET RoleId = NewRoleId WHERE AccountId = AccountId

  IF TargetRole.RoleName = "Customer" THEN
      READ Profile FROM DataStore_D2 (CustomerProfiles) WHERE AccountId = AccountId
      IF Profile NOT FOUND THEN
          WRITE Default_CustomerProfile(AccountId, Age=22, Gender="Nam", Interest="Lập trình") TO DataStore_D2
      END IF
  END IF
  RETURN HTTP_200 ("Cập nhật phân quyền thành công!")
END PROCESS 1.3
"@))

    [void]$sb.Append((New-ProcessMiniSpec -ProcId "1.4" -PName "Khóa / Mở khóa & Truy vấn Danh sách Account" `
        -ParentDfd "DFD Mức 1 — Phân hệ 1.0: Quản trị Máy chủ (Admin Server)" `
        -Inputs "LenhKhoaMoKhoa (AccountId) hoặc YeuCauTruyVanDanhSach (Keyword, RoleFilter)" `
        -Outputs "DanhSachAccountHeThong & 4 Chỉ số KPI Máy chủ về Quản trị viên" `
        -DataStores "Đọc & Cập nhật Kho D1 (Accounts, Roles)" `
        -StructuredEnglish @"
BEGIN PROCESS 1.4 (KhoaMoKhoa_Va_TruyVan_Account)
  IF Action = "TOGGLE_STATUS" THEN
      RECEIVE AccountId FROM Actor_Admin
      READ Account FROM DataStore_D1 (Accounts) WHERE Account.AccountId = AccountId
      SET Account.IsActive = NOT (Account.IsActive)
      UPDATE DataStore_D1 (Accounts) SET IsActive = Account.IsActive WHERE AccountId = AccountId
      RETURN HTTP_200 (Account.IsActive)
  ELSE IF Action = "GET_ALL_ACCOUNTS" THEN
      READ AllAccounts JOIN Roles FROM DataStore_D1 ORDER BY AccountId DESC
      COMPUTE TotalAccounts  = COUNT(AllAccounts)
      COMPUTE ActiveAccounts = COUNT(AllAccounts WHERE IsActive = TRUE)
      COMPUTE LockedAccounts = COUNT(AllAccounts WHERE IsActive = FALSE)
      COMPUTE TotalRoles     = COUNT(Roles) -- Chuẩn 3 vai trò: Admin, Manager, Customer
      RETURN { AllAccounts, KPI: { TotalAccounts, ActiveAccounts, LockedAccounts, TotalRoles } } TO Actor_Admin
  END IF
END PROCESS 1.4
"@))

    [void]$sb.Append((New-WPageBreak))

    # P2.1 & P3.1 (CRM Manager)
    [void]$sb.Append((New-ProcessMiniSpec -ProcId "2.1" -PName "Thêm mới, Xóa & Khóa Tài khoản Khách hàng (CRM Customer Management)" `
        -ParentDfd "DFD Mức 1 — Phân hệ Người Quản lý Quan hệ Khách hàng (CRM Manager)" `
        -Inputs "HoSoKhachHangMoi, LenhKhoaKhachHang (AccountId) hoặc LenhXoaKhachHang (AccountId) từ Người Quản lý" `
        -Outputs "DanhSachHoSoKhachHang & ThongBaoKetQua về Người Quản lý" `
        -DataStores "Đọc/Ghi/Cập nhật/Xóa trên Kho D1 (Accounts) và Kho D2 (CustomerProfiles)" `
        -StructuredEnglish @"
BEGIN PROCESS 2.1 (QuanLy_HoSo_KhachHang_CRM)
  SWITCH (Manager_Command)
    CASE "ADD_NEW_CUSTOMER":
      RECEIVE { Username, Password, FullName, Phone, Email, Age, Gender, Interest, Address } FROM Actor_Manager
      IF EXISTS (SELECT 1 FROM DataStore_D1 WHERE LOWER(Username) = LOWER(dto.Username)) THEN
          RETURN HTTP_400 ("Tên đăng nhập đã tồn tại!")
      END IF
      WRITE Account(Username, BCrypt(Password), FullName, Email, Phone, Role="Customer", IsActive=TRUE) TO DataStore_D1
      WRITE CustomerProfile(Account.AccountId, Age, Gender, Address, Interest) TO DataStore_D2
      RETURN HTTP_200 ("Thêm khách hàng mới thành công!")

    CASE "LOCK_UNLOCK_CUSTOMER":
      RECEIVE CustomerAccountId FROM Actor_Manager
      UPDATE DataStore_D1 (Accounts) SET IsActive = NOT IsActive WHERE AccountId = CustomerAccountId
      RETURN HTTP_200 ("Đã cập nhật trạng thái khóa tài khoản khách hàng!")

    CASE "DELETE_CUSTOMER":
      RECEIVE CustomerAccountId FROM Actor_Manager
      DELETE FROM DataStore_D2 (CustomerProfiles) WHERE AccountId = CustomerAccountId
      DELETE FROM DataStore_D4 (Feedbacks)        WHERE AccountId = CustomerAccountId
      DELETE FROM DataStore_D5 (SurveyResponses)  WHERE AccountId = CustomerAccountId
      DELETE FROM DataStore_D1 (Accounts)         WHERE AccountId = CustomerAccountId
      RETURN HTTP_200 ("Đã xóa khách hàng thành công.")
  END SWITCH
END PROCESS 2.1
"@))

    [void]$sb.Append((New-ProcessMiniSpec -ProcId "3.1" -PName "Tiếp nhận và Giải đáp Phản hồi của Khách hàng" `
        -ParentDfd "DFD Mức 1 — Phân hệ Người Quản lý Quan hệ Khách hàng (CRM Manager)" `
        -Inputs "YeuCauXemPhanHoi hoặc GiaiDapPhanHoi (FeedbackId, AdminReply) từ Người Quản lý" `
        -Outputs "DanhSachPhanHoiSanPham, Biểu đồ Sao & TrangThaiGiaiDap về Người Quản lý" `
        -DataStores "Đọc Kho D1 (Accounts), Kho D3 (Products); Đọc & Cập nhật Kho D4 (Feedbacks)" `
        -StructuredEnglish @"
BEGIN PROCESS 3.1 (TiepNhan_Va_GiaiDap_PhanHoi)
  IF Action = "LOAD_FEEDBACKS" THEN
      READ Feedbacks JOIN Accounts (D1) JOIN Products (D3) FROM DataStore_D4 ORDER BY CreatedAt DESC
      COMPUTE TotalFeedbacks   = COUNT(Feedbacks)
      COMPUTE RepliedCount     = COUNT(Feedbacks WHERE AdminReply IS NOT NULL)
      COMPUTE PendingCount     = COUNT(Feedbacks WHERE AdminReply IS NULL)
      COMPUTE AverageStarScore = ROUND(AVG(Feedbacks.Rating), 1)
      RETURN { Feedbacks, KPI: { TotalFeedbacks, RepliedCount, PendingCount, AverageStarScore } } TO Actor_Manager

  ELSE IF Action = "REPLY_FEEDBACK" THEN
      RECEIVE FeedbackId, AdminReplyText FROM Actor_Manager
      READ FeedbackRecord FROM DataStore_D4 WHERE FeedbackId = FeedbackId
      IF FeedbackRecord NOT FOUND THEN
          RETURN HTTP_404 ("Không tìm thấy phản hồi.")
      END IF
      SET FeedbackRecord.AdminReply = TRIM(AdminReplyText)
      SET FeedbackRecord.Status     = "Đã tiếp nhận & Xử lý"
      UPDATE DataStore_D4 (Feedbacks) SET AdminReply = FeedbackRecord.AdminReply, Status = FeedbackRecord.Status
      RETURN HTTP_200 ("Đã gửi phản hồi cho khách hàng.")
  END IF
END PROCESS 3.1
"@))

    [void]$sb.Append((New-WPageBreak))

    # P4.1, P5.1, P5.2 (CRM Analytics & Surveys)
    [void]$sb.Append((New-ProcessMiniSpec -ProcId "4.1" -PName "Tổng hợp Báo cáo Khách hàng: Tỷ lệ Độ tuổi & Sở thích" `
        -ParentDfd "DFD Mức 1 — Phân hệ Người Quản lý Quan hệ Khách hàng (CRM Manager)" `
        -Inputs "YeuCauBaoCaoNhanKhauHoc từ Người Quản lý" `
        -Outputs "BaoCaoNhanKhauHocKH (Biểu đồ Tỷ lệ Độ tuổi & Biểu đồ Phân bố Sở thích) về Người Quản lý" `
        -DataStores "Đọc Kho D2 (Bảng CustomerProfiles)" `
        -StructuredEnglish @"
BEGIN PROCESS 4.1 (BaoCao_TyLe_DoTuoi_Va_SoThich)
  READ AllProfiles FROM DataStore_D2 (CustomerProfiles)
  SET Total = COUNT(AllProfiles)

  -- 1. Phân tích Tỷ lệ Độ tuổi theo các phân khúc nhân khẩu học:
  SET AgeStats.Under20    = COUNT(AllProfiles WHERE Age < 20)
  SET AgeStats.From20To30 = COUNT(AllProfiles WHERE Age >= 20 AND Age <= 30)
  SET AgeStats.Over30     = COUNT(AllProfiles WHERE Age > 30)

  -- 2. Phân tích Tỷ lệ Sở thích tiêu dùng công nghệ:
  INITIALIZE InterestStatsList = EMPTY_LIST
  FOR EACH Group IN GROUP_BY(AllProfiles, Key = ISNULL(Interest, "Khác")) DO
      SET GroupCount = COUNT(Group)
      SET GroupPct   = IF Total > 0 THEN ROUND((GroupCount * 100.0) / Total, 1) ELSE 0
      APPEND { Interest: Group.Key, Count: GroupCount, Percentage: GroupPct } TO InterestStatsList
  END FOR

  RETURN { TotalCustomers: Total, AgeStats, InterestStats: InterestStatsList } TO Actor_Manager
END PROCESS 4.1
"@))

    [void]$sb.Append((New-ProcessMiniSpec -ProcId "5.1 & 5.2" -PName "Tạo Bảng Khảo sát Gửi đến TK Khách hàng & Thống kê Kết quả Khảo sát" `
        -ParentDfd "DFD Mức 1 — Phân hệ Người Quản lý Quan hệ Khách hàng (CRM Manager)" `
        -Inputs "ChienDichKhaoSatMoi (SurveyCreateDto) hoặc YeuCauThongKeKhaoSat (SurveyId) từ Người Quản lý" `
        -Outputs "ThongBaoPhatHanhKhaoSat & BaoCaoThongKeKhaoSat về Người Quản lý" `
        -DataStores "Đọc/Ghi/Cập nhật/Xóa trên Kho D5 (Surveys, SurveyResponses) và Đọc Kho D1 (Accounts)" `
        -StructuredEnglish @"
BEGIN PROCESS 5.1_AND_5.2 (Tao_KhaoSat_Va_ThongKe_KetQua)
  IF Action = "CREATE_AND_SEND_SURVEY" THEN
      RECEIVE { Title, TargetProduct, ExpectedPrice, DurationType, DurationDays, ExpiresAt, Description } FROM Actor_Manager
      IF DurationType = "Days" AND DurationDays > 0 THEN
          SET CalculatedExpiry = NOW() + DurationDays
      ELSE IF DurationType = "Date" AND ExpiresAt IS NOT NULL THEN
          SET CalculatedExpiry = END_OF_DAY(ExpiresAt)
      ELSE
          SET CalculatedExpiry = NULL -- Không giới hạn thời hạn
      END IF
      WRITE Survey(Title, Description, TargetProduct, ExpectedPrice, IsActive=TRUE, ExpiresAt=CalculatedExpiry) TO DataStore_D5
      READ ActiveCustomerCount = COUNT(DataStore_D1 WHERE RoleName = "Customer" AND IsActive = TRUE)
      RETURN HTTP_200 ("Đã tạo bảng khảo sát và gửi đến " + ActiveCustomerCount + " tài khoản khách hàng!")

  ELSE IF Action = "GET_SURVEY_STATISTICS" THEN
      RECEIVE TargetSurveyId FROM Actor_Manager
      READ Survey FROM DataStore_D5 (Surveys) WHERE SurveyId = TargetSurveyId
      READ Responses JOIN Accounts FROM DataStore_D5 (SurveyResponses) WHERE SurveyId = TargetSurveyId
      SET TotalResponses = COUNT(Responses)
      SET AverageScore   = IF TotalResponses > 0 THEN ROUND(AVG(Responses.Score), 2) ELSE 0
      SET IntentStats = {
          WantToBuy:   COUNT(Responses WHERE BuyingIntent = "Rất muốn mua"),
          Considering: COUNT(Responses WHERE BuyingIntent = "Đang cân nhắc"),
          NotBuying:   COUNT(Responses WHERE BuyingIntent = "Không mua")
      }
      SET ScoreDist = { S1..S5: COUNT(Responses WHERE Score = 1..5) }
      RETURN { Survey, TotalResponses, AverageScore, IntentStats, ScoreDist, DetailResponses: Responses } TO Actor_Manager
  END IF
END PROCESS 5.1_AND_5.2
"@))

    [void]$sb.Append((New-WPageBreak))

    # P2.2, P2.3, P3.2, P5.3 (Customer Portal)
    [void]$sb.Append((New-ProcessMiniSpec -ProcId "2.2 & 2.3" -PName "Đăng ký, Đăng nhập & Chỉnh sửa Thông tin Cá nhân Khách hàng" `
        -ParentDfd "DFD Mức 1 — Phân hệ Cổng Tương tác Khách hàng (Customer Portal)" `
        -Inputs "ThongTinDangKy, ThongTinDangNhap hoặc ThongTinCapNhatHoSo từ Khách hàng" `
        -Outputs "PhienDangNhapKhachHang & HoSoCaNhanDaCapNhat về Khách hàng" `
        -DataStores "Đọc/Ghi/Cập nhật Kho D1 (Accounts) và Kho D2 (CustomerProfiles)" `
        -StructuredEnglish @"
BEGIN PROCESS 2.2_AND_2.3 (DangKy_DangNhap_Va_ChinhSuaHoSo_KhachHang)
  IF Action = "CUSTOMER_REGISTER" THEN
      RECEIVE { Username, Password, FullName, Phone, Email, Age, Gender, Interest, Address } FROM Actor_Customer
      IF EXISTS (SELECT 1 FROM DataStore_D1 WHERE LOWER(Username) = LOWER(Username)) THEN
          RETURN HTTP_400 ("Tên đăng nhập này đã được sử dụng!")
      END IF
      WRITE Account(Username, BCrypt(Password), FullName, Email, Phone, Role="Customer", IsActive=TRUE) TO DataStore_D1
      WRITE CustomerProfile(Account.AccountId, Age, Gender, Address, Interest) TO DataStore_D2
      RETURN HTTP_200_AUTO_LOGIN (Account)

  ELSE IF Action = "UPDATE_PROFILE" THEN
      RECEIVE AccountId, { FullName, Email, Phone, Age, Gender, Interest, Address } FROM Actor_Customer
      UPDATE DataStore_D1 (Accounts) SET FullName = FullName, Email = Email, Phone = Phone WHERE AccountId = AccountId
      UPDATE DataStore_D2 (CustomerProfiles) SET Age = Age, Gender = Gender, Interest = Interest, Address = Address WHERE AccountId = AccountId
      RETURN HTTP_200 ("Cập nhật thông tin hồ sơ thành công!")
  END IF
END PROCESS 2.2_AND_2.3
"@))

    [void]$sb.Append((New-ProcessMiniSpec -ProcId "3.2 & 5.3" -PName "Gửi Phản hồi về Sản phẩm & Nhận, Thực hiện Bảng Khảo sát" `
        -ParentDfd "DFD Mức 1 — Phân hệ Cổng Tương tác Khách hàng (Customer Portal)" `
        -Inputs "PhieuDanhGiaSanPham (ProductId, Rating, Comment) hoặc PhieuTraLoiKhaoSat (SurveyId, Score, BuyingIntent, Opinion) từ Khách hàng" `
        -Outputs "DanhSachPhanHoiKemGiaiDap & TrangThaiHoanThanhKhaoSat về Khách hàng" `
        -DataStores "Đọc Kho D3 (Products); Đọc/Ghi Kho D4 (Feedbacks); Đọc/Ghi Kho D5 (Surveys, SurveyResponses)" `
        -StructuredEnglish @"
BEGIN PROCESS 3.2_AND_5.3 (GuiPhanHoiSanPham_Va_ThucHienKhaoSat)
  IF Action = "SUBMIT_PRODUCT_FEEDBACK" THEN
      RECEIVE AccountId, { ProductId, Rating, Comment } FROM Actor_Customer
      IF Rating < 1 OR Rating > 5 THEN
          RETURN HTTP_400 ("Mức đánh giá sao phải từ 1 đến 5!")
      END IF
      WRITE Feedback(AccountId, ProductId, Rating, Comment, Status="Chờ xử lý", CreatedAt=NOW()) TO DataStore_D4
      RETURN HTTP_200 ("Cảm ơn bạn đã gửi đánh giá sản phẩm!")

  ELSE IF Action = "SUBMIT_SURVEY_RESPONSE" THEN
      RECEIVE SurveyId, AccountId, { Score, BuyingIntent, CustomerOpinion } FROM Actor_Customer
      READ Survey FROM DataStore_D5 (Surveys) WHERE SurveyId = SurveyId
      IF Survey.IsActive = FALSE THEN
          RETURN HTTP_400 ("Khảo sát này hiện đang bị khóa bởi Người quản lý!")
      ELSE IF Survey.ExpiresAt IS NOT NULL AND Survey.ExpiresAt < NOW() THEN
          RETURN HTTP_400 ("Khảo sát này đã hết thời hạn tham gia!")
      END IF
      IF EXISTS (SELECT 1 FROM DataStore_D5 (SurveyResponses) WHERE SurveyId = SurveyId AND AccountId = AccountId) THEN
          RETURN HTTP_400 ("Bạn đã thực hiện bài khảo sát này rồi!")
      END IF
      WRITE SurveyResponse(SurveyId, AccountId, Score, BuyingIntent, CustomerOpinion, SubmittedAt=NOW()) TO DataStore_D5
      RETURN HTTP_200 ("Gửi kết quả khảo sát thành công!")
  END IF
END PROCESS 3.2_AND_5.3
"@))

    [void]$sb.Append((New-WPageBreak))
    return $sb.ToString()
}

function Build-Chapter3-DeepIntegrityConstraints {
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.Append((New-WHeading3 "3.1.6. Đặc tả Hệ thống Ràng buộc Toàn vẹn CSDL (Database Integrity Constraints Specification)"))
    [void]$sb.Append((New-WP -Text "Để đảm bảo tính nhất quán dữ liệu tuyệt đối trong suốt quá trình vận hành, hệ thống thiết lập 18 Ràng buộc Toàn vẹn (Integrity Constraints) được phân loại theo 4 nhóm lý thuyết Cơ sở dữ liệu quan hệ:" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Mã RB", "Loại Ràng buộc Toàn vẹn", "Bảng Áp dụng", "Biểu thức Hình thức / Điều kiện Ràng buộc trong SQL Server & EF Core") -ColWidths @(900, 2100, 1600, 5000) -Rows @(
        @("RB-01", "Toàn vẹn Thực thể (PK)", "Tất cả 9 Bảng", "∀ t1, t2 ∈ Table (t1 ≠ t2) ⇒ t1.PrimaryKey ≠ t2.PrimaryKey ∧ t1.PrimaryKey ≠ NULL (IDENTITY(1,1))."),
        @("RB-02", "Toàn vẹn Duy nhất (Unique)", "Roles", "∀ r1, r2 ∈ Roles (r1 ≠ r2) ⇒ r1.RoleName ≠ r2.RoleName. Tập giá trị chuẩn: {'Admin', 'Manager', 'Customer'}."),
        @("RB-03", "Toàn vẹn Duy nhất (Unique)", "Accounts", "∀ a1, a2 ∈ Accounts (a1 ≠ a2) ⇒ LOWER(a1.Username) ≠ LOWER(a2.Username)."),
        @("RB-04", "Toàn vẹn Duy nhất (Unique)", "CustomerProfiles", "∀ p1, p2 ∈ CustomerProfiles (p1 ≠ p2) ⇒ p1.AccountId ≠ p2.AccountId (Quan hệ 1–1 chặt với Accounts)."),
        @("RB-05", "Toàn vẹn Duy nhất (Unique)", "Products, Suppliers", "ProductCode là duy nhất trong bảng Products (SP001..SP016); SupplierCode là duy nhất trong bảng Suppliers (NCC001..NCC006)."),
        @("RB-06", "Toàn vẹn Miền giá trị", "Accounts", "a.IsActive ∈ {0 (False - Đã khóa), 1 (True - Hoạt động)}; mặc định khi tạo mới là 1."),
        @("RB-07", "Toàn vẹn Miền giá trị", "CustomerProfiles", "p.Age ∈ Z+ (Age > 0); p.Gender ∈ {N'Nam', N'Nữ', N'Khác'}; p.Interest ∈ {N'Gaming', N'Đồ họa', N'Văn phòng', N'Lập trình', N'Khác'}."),
        @("RB-08", "Toàn vẹn Miền giá trị", "Products", "pr.Price > 0 ∧ pr.CostPrice > 0 ∧ pr.StockQuantity >= 0; pr.Status ∈ {N'Đang bán', N'Hết hàng'}."),
        @("RB-09", "Toàn vẹn Miền giá trị", "Feedbacks", "fb.Rating ∈ {1, 2, 3, 4, 5} (CHECK Rating >= 1 AND Rating <= 5); fb.Status ∈ {N'Chờ xử lý', N'Đã tiếp nhận & Xử lý'}."),
        @("RB-10", "Toàn vẹn Miền giá trị", "SurveyResponses", "sr.Score ∈ {1, 2, 3, 4, 5} (CHECK Score >= 1 AND Score <= 5); sr.BuyingIntent ∈ {N'Rất muốn mua', N'Đang cân nhắc', N'Không mua'}."),
        @("RB-11", "Toàn vẹn Tham chiếu (FK)", "Accounts -> Roles", "∀ a ∈ Accounts ⇒ ∃ r ∈ Roles : a.RoleId = r.RoleId."),
        @("RB-12", "Toàn vẹn Tham chiếu (FK)", "CustomerProfiles -> Accounts", "∀ p ∈ CustomerProfiles ⇒ ∃ a ∈ Accounts : p.AccountId = a.AccountId (ON DELETE CASCADE)."),
        @("RB-13", "Toàn vẹn Tham chiếu (FK)", "Products -> Categories, Suppliers", "∀ pr ∈ Products ⇒ (∃ c ∈ Categories : pr.CategoryId = c.CategoryId) ∧ (∃ s ∈ Suppliers : pr.SupplierId = s.SupplierId)."),
        @("RB-14", "Toàn vẹn Tham chiếu (FK)", "Feedbacks -> Accounts, Products", "∀ fb ∈ Feedbacks ⇒ (∃ a ∈ Accounts : fb.AccountId = a.AccountId) ∧ (∃ pr ∈ Products : fb.ProductId = pr.ProductId)."),
        @("RB-15", "Toàn vẹn Tham chiếu (FK)", "SurveyResponses -> Surveys, Accounts", "∀ sr ∈ SurveyResponses ⇒ (∃ s ∈ Surveys : sr.SurveyId = s.SurveyId) ∧ (∃ a ∈ Accounts : sr.AccountId = a.AccountId)."),
        @("RB-16", "Toàn vẹn Liên thuộc tính", "Feedbacks", "∀ fb ∈ Feedbacks : Nếu fb.AdminReply ≠ NULL ⇒ fb.Status = N'Đã tiếp nhận & Xử lý'."),
        @("RB-17", "Toàn vẹn Liên quan hệ", "SurveyResponses", "∀ sr1, sr2 ∈ SurveyResponses (sr1 ≠ sr2) ⇒ (sr1.SurveyId, sr1.AccountId) ≠ (sr2.SurveyId, sr2.AccountId) (Mỗi KH chỉ trả lời 1 lần/khảo sát)."),
        @("RB-18", "Toàn vẹn Thời gian", "Surveys, SurveyResponses", "∀ sr ∈ SurveyResponses JOIN s ∈ Surveys : s.IsActive = 1 ∧ (s.ExpiresAt IS NULL ∨ sr.SubmittedAt <= s.ExpiresAt).")
    )))

    [void]$sb.Append((New-WHeading4 "Bảng Tầm ảnh hưởng (Insert / Delete / Update Impact Matrix) của các Ràng buộc Tham chiếu:"))
    [void]$sb.Append((New-WTable -Headers @("Quan hệ (Bảng)", "Thao tác Thêm (INSERT)", "Thao tác Xóa (DELETE)", "Thao tác Sửa (UPDATE)") -ColWidths @(2200, 2500, 2500, 2400) -Rows @(
        @("Roles (Bảng Cha)", "Kiểm tra trùng RoleName (RB-02).", "Chặn xóa nếu đang có Account tham chiếu tới RoleId (RB-11).", "Không sửa khóa chính RoleId."),
        @("Accounts (Cha & Con)", "Kiểm tra trùng Username (RB-03) và tồn tại RoleId trong Roles (RB-11).", "Tự động xóa dây chuyền (CASCADE) các bản ghi con trong CustomerProfiles, Feedbacks, SurveyResponses.", "Kiểm tra RoleId hợp lệ khi phân quyền; cập nhật cờ IsActive khi khóa/mở khóa."),
        @("CustomerProfiles (Con)", "Kiểm tra tồn tại AccountId trong Accounts và Age > 0 (RB-07, RB-12).", "Cho phép xóa tự do (không có bảng con phụ thuộc).", "Kiểm tra miền giá trị Age, Gender, Interest khi khách hàng sửa hồ sơ."),
        @("Products (Cha & Con)", "Kiểm tra trùng ProductCode và tồn tại CategoryId, SupplierId.", "Xóa dây chuyền các bản ghi đánh giá trong Feedbacks của sản phẩm đó.", "Kiểm tra Price > 0 và StockQuantity >= 0."),
        @("Feedbacks (Bảng Con)", "Kiểm tra tồn tại AccountId, ProductId và Rating ∈ [1..5] (RB-09, RB-14).", "Cho phép xóa tự do.", "Khi cập nhật AdminReply thì tự động cập nhật Status (RB-16)."),
        @("Surveys (Bảng Cha)", "Kiểm tra ExpectedPrice >= 0 và tính toán ExpiresAt.", "Xóa dây chuyền (CASCADE) toàn bộ phiếu trả lời trong SurveyResponses.", "Cho phép cập nhật IsActive (Khóa/Mở khóa khảo sát)."),
        @("SurveyResponses (Con)", "Kiểm tra Survey đang mở, còn hạn, chưa làm trước đó và Score ∈ [1..5].", "Cho phép xóa tự do.", "Không cho phép sửa khóa ngoại SurveyId, AccountId.")
    )))

    [void]$sb.Append((New-WPageBreak))
    return $sb.ToString()
}

function Build-Chapter3-DeepUiFlows {
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.Append((New-WHeading3 "3.2.14. Đặc tả Chi tiết Luồng Xử lý Trạng thái Giao diện (Frontend State & Event Execution Flows)"))
    [void]$sb.Append((New-WP -Text "Để minh họa rõ cách thức tầng Giao diện (Frontend HTML5/JS) tương tác thời gian thực với tầng Backend ASP.NET Core 8.0 và xử lý dữ liệu biểu đồ, dưới đây là mã nguồn xử lý giao diện thực tế tại 3 tệp kịch bản trung tâm: app.js (Admin Server), manager_crm.js (Người Quản lý CRM) và user.js (Cổng Khách hàng):" -IndentFirst 420))

    [void]$sb.Append((New-WCodeBlock -Title "1. Luồng Xử lý Giao diện Admin Server Độc lập (Trích Frontend_Admin/app.js):" -CodeText @"
// KHỞI TẠO KHÔNG GIAN ADMIN SERVER TÁCH BIỆT ĐỘC LẬP (admin.html)
const API_BASE = "http://localhost:5000/api/admin";
let allAccounts = [];
let allRoles = [];

async function loadAccountsAndRoles() {
    const [accRes, roleRes] = await Promise.all([
        fetch(`${API_BASE}/accounts`),
        fetch(`${API_BASE}/accounts/roles`)
    ]);
    allAccounts = await accRes.json();
    allRoles = await roleRes.json();
    updateAdminKpiCards();
    renderAccountsTable(allAccounts);
    renderRolesSummaryTab();
}

// PHÂN QUYỀN VAI TRÒ CHO ACCOUNT (CHỈ GIỮ ĐÚNG 3 ROLE: Admin, Manager, Customer)
async function changeAccountRole(accountId) {
    const selectEl = document.getElementById(`roleSelect_${accountId}`);
    const newRoleId = parseInt(selectEl.value, 10);
    const res = await fetch(`${API_BASE}/accounts/${accountId}/role`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ roleId: newRoleId })
    });
    if (res.ok) {
        showToast("Đã cập nhật phân quyền tài khoản thành công!", "success");
        await loadAccountsAndRoles();
    }
}

// KHÓA / MỞ KHÓA VÀ XÓA ACCOUNT TRÊN ADMIN SERVER
async function toggleAccountStatus(accountId) {
    const res = await fetch(`${API_BASE}/accounts/${accountId}/toggle-status`, { method: "PUT" });
    if (res.ok) await loadAccountsAndRoles();
}

async function deleteAccount(accountId) {
    if (!confirm("Bạn có chắc chắn muốn xóa vĩnh viễn tài khoản này khỏi máy chủ?")) return;
    const res = await fetch(`${API_BASE}/accounts/${accountId}`, { method: "DELETE" });
    if (res.ok) await loadAccountsAndRoles();
}
"@))

    [void]$sb.Append((New-WCodeBlock -Title "2. Luồng Xử lý Giao diện Người Quản lý CRM & Vẽ Biểu đồ Thống kê (Trích Frontend_Admin/manager_crm.js):" -CodeText @"
// 1. THÊM MỚI, KHÓA VÀ XÓA KHÁCH HÀNG (TAB 1 NGƯỜI QUẢN LÝ CRM)
async function submitAddCustomer(event) {
    event.preventDefault();
    const payload = {
        username: document.getElementById("newCustUsername").value.trim(),
        password: document.getElementById("newCustPassword").value.trim() || "123456",
        fullName: document.getElementById("newCustFullName").value.trim(),
        phone:    document.getElementById("newCustPhone").value.trim(),
        email:    document.getElementById("newCustEmail").value.trim(),
        age:      parseInt(document.getElementById("newCustAge").value, 10) || 22,
        gender:   document.getElementById("newCustGender").value,
        interest: document.getElementById("newCustInterest").value,
        address:  document.getElementById("newCustAddress").value.trim()
    };
    const res = await fetch("http://localhost:5000/api/admin/crm/customers", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
    });
    if (res.ok) {
        closeAddCustomerModal();
        await loadCrmCustomers();
        await loadDemographicsReport();
    }
}

// 2. TIẾP NHẬN & GIẢI ĐÁP PHẢN HỒI KHÁCH HÀNG (TAB 2 NGƯỜI QUẢN LÝ CRM)
async function submitFeedbackReply(feedbackId, replyText) {
    const res = await fetch(`http://localhost:5000/api/admin/crm/feedbacks/${feedbackId}/reply`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ adminReply: replyText })
    });
    if (res.ok) await loadCrmFeedbacks();
}

// 3. KẾT XUẤT BÁO CÁO TỶ LỆ ĐỘ TUỔI & SỞ THÍCH KHÁCH HÀNG (TAB 3 NGƯỜI QUẢN LÝ CRM)
async function loadDemographicsReport() {
    const res = await fetch("http://localhost:5000/api/admin/crm/reports/demographics");
    const data = await res.json();
    renderAgeDoughnutChart(data.ageStats);
    renderInterestBarChart(data.interestStats);
}
"@))

    [void]$sb.Append((New-WCodeBlock -Title "3. Luồng Xử lý Giao diện Cổng Khách hàng Trực tuyến (Trích Frontend_Admin/user.js):" -CodeText @"
// 1. KHÁCH HÀNG GỬI PHẢN HỒI VỀ SẢN PHẨM & LỌC XEM GIẢI ĐÁP THEO SẢN PHẨM
async function submitProductFeedback(event) {
    event.preventDefault();
    const accountId = currentCustomer.accountId;
    const payload = {
        productId: parseInt(document.getElementById("fbProductSelect").value, 10),
        rating:    parseInt(document.getElementById("fbRatingSelect").value, 10),
        comment:   document.getElementById("fbCommentInput").value.trim()
    };
    const res = await fetch(`http://localhost:5000/api/customer/feedbacks/${accountId}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
    });
    if (res.ok) await loadPublicFeedbacks();
}

// 2. KHÁCH HÀNG NHẬN BẢNG KHẢO SÁT VÀ GỬI KẾT QUẢ THỰC HIỆN KHẢO SÁT
async function submitCustomerSurveyResponse(surveyId) {
    const accountId = currentCustomer.accountId;
    const payload = {
        score:           parseInt(document.getElementById("surveyScoreSelect").value, 10),
        buyingIntent:    document.getElementById("surveyIntentSelect").value,
        customerOpinion: document.getElementById("surveyOpinionInput").value.trim()
    };
    const res = await fetch(`http://localhost:5000/api/customer/surveys/${surveyId}/submit/${accountId}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
    });
    if (res.ok) {
        closeSurveyModal();
        await loadAvailableSurveys();
    }
}
"@))

    [void]$sb.Append((New-WPageBreak))
    return $sb.ToString()
}
