# ==============================================================================
# PART 4: CHƯƠNG 3 (MỤC 3.1) — THIẾT KẾ CСР SỞ DỮ LIỆU CHUẨN 3NF (9 BẢNG)
# BAO GỒM ERD, CHỨNG MINH 3NF, DATA DICTIONARY, DDL & TOÀN BỘ DỮ LIỆU THỰC TẾ
# ==============================================================================

function Build-Part4-Chapter3-Database {
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.Append((New-WHeading1 "CHƯƠNG 3: THIẾT KẾ HỆ THỐNG THÔNG TIN TRONG HỆ THỐNG ĐỂ XÂY DỰNG PHẦN MỀM (10 ĐIỂM)"))
    [void]$sb.Append((New-WHeading2 "3.1. Thiết kế Cơ sở Dữ liệu (5 điểm)"))

    [void]$sb.Append((New-WHeading3 "3.1.1. Ánh xạ từ các Kho Dữ liệu DFD (D1 – D5) sang Lược đồ Cơ sở Dữ liệu Quan hệ"))
    [void]$sb.Append((New-WP -Text "Thực hiện đúng nguyên lý thiết kế Hệ thống Thông tin: 'Lược đồ CSDL phải được thiết kế dựa vào các kho dữ liệu đã phân tích ở trên', nhóm tiến hành ánh xạ trực tiếp 5 Kho dữ liệu (D1 đến D5) từ Sơ đồ Luồng dữ liệu Mức Đỉnh (Level 0 DFD) và Mức 1 (Level 1 DFD) sang 9 bảng thực thể vật lý trong Hệ quản trị Cơ sở dữ liệu Microsoft SQL Server (Tên CSDL: HTTTDN_DB):" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Kho dữ liệu trên DFD", "Tên Bảng Vật lý (SQL Server)", "Lớp Thực thể C# (Entity Model)", "Khóa chính (PK)", "Khóa ngoại (FK)", "Số bản ghi mẫu", "Vai trò lưu trữ trong Hệ thống") -ColWidths @(1150, 1550, 1500, 1100, 1600, 950, 1750) -Rows @(
        @("Kho D1`n(Accounts & Roles)", "1. Roles", "Role.cs", "RoleId (INT)", "Không có", "03 bản ghi", "Lưu 3 vai trò chuẩn: Admin (1), Manager (2), Customer (3)."),
        @("Kho D1`n(Accounts & Roles)", "2. Accounts", "Account.cs", "AccountId (INT)", "RoleId -> Roles(RoleId)", "19 bản ghi", "Quản lý định danh đăng nhập, mật khẩu BCrypt, trạng thái khóa IsActive."),
        @("Kho D2`n(Customers)", "3. CustomerProfiles", "CustomerProfile.cs", "ProfileId (INT)", "AccountId -> Accounts(AccountId)", "15 bản ghi", "Lưu nhân khẩu học KH: Độ tuổi (Age), Giới tính, Sở thích, Địa chỉ."),
        @("Kho D3`n(Products)", "4. Categories", "Category.cs", "CategoryId (INT)", "Không có", "05 bản ghi", "Phân nhóm danh mục ngành hàng công nghệ của SGU Tech."),
        @("Kho D3`n(Products)", "5. Suppliers", "Supplier.cs", "SupplierId (INT)", "Không có", "06 bản ghi", "Lưu thông tin đối tác nhà cung cấp/hãng sản xuất chính hãng."),
        @("Kho D3`n(Products)", "6. Products", "Product.cs", "ProductId (INT)", "CategoryId, SupplierId", "16 bản ghi", "Lưu 16 sản phẩm công nghệ kèm hình ảnh để KH chọn đánh giá."),
        @("Kho D4`n(Feedbacks)", "7. Feedbacks", "Feedback.cs", "FeedbackId (INT)", "AccountId, ProductId", "18 bản ghi", "Lưu đánh giá 1–5 sao, nhận xét của KH và giải đáp từ Quản lý."),
        @("Kho D5`n(Surveys)", "8. Surveys", "Survey.cs", "SurveyId (INT)", "Không có", "05 bản ghi", "Lưu chiến dịch bảng khảo sát sản phẩm mới, giá dự kiến & thời hạn."),
        @("Kho D5`n(Surveys)", "9. SurveyResponses", "SurveyResponse.cs", "ResponseId (INT)", "SurveyId, AccountId", "16 bản ghi", "Lưu kết quả thực hiện khảo sát (Điểm 1–5, Ý định mua, Ý kiến) của KH.")
    )))

    [void]$sb.Append((New-WHeading3 "3.1.2. Phân tích Phụ thuộc Hàm và Chứng minh Chuẩn hóa CSDL Đạt Dạng Chuẩn 3 (3NF)"))
    [void]$sb.Append((New-WP -Text "Để loại bỏ hoàn toàn sự dư thừa dữ liệu (Data Redundancy) và ngăn chặn các dị thường khi thêm, xóa, sửa (Insertion, Deletion, Update Anomalies), toàn bộ 9 bảng trong CSDL HTTTDN_DB đều được chuẩn hóa qua 3 bước nghiêm ngặt:" -IndentFirst 420))
    [void]$sb.Append((New-WBullet "Bước 1 — Đạt Dạng chuẩn 1 (First Normal Form – 1NF):" "Tất cả các thuộc tính trong cả 9 bảng đều mang giá trị nguyên tố (Atomic Value), không có thuộc tính đa trị hoặc thuộc tính lặp. Ví dụ: Thay vì lưu danh sách nhiều phản hồi hoặc nhiều phiếu khảo sát trong một cột chuỗi của bảng Accounts, hệ thống tách riêng thành các bảng giao dịch độc lập là Feedbacks và SurveyResponses."))
    [void]$sb.Append((New-WBullet "Bước 2 — Đạt Dạng chuẩn 2 (Second Normal Form – 2NF):" "Mọi bảng trong lược đồ đều thỏa 1NF và sử dụng khóa chính đơn (Single-column Surrogate Primary Key: RoleId, AccountId, ProfileId, CategoryId, SupplierId, ProductId, FeedbackId, SurveyId, ResponseId). Do đó, mọi thuộc tính không khóa trong từng bảng đều phụ thuộc hàm đầy đủ vào khóa chính, hoàn toàn không tồn tại phụ thuộc hàm bộ phận (Partial Dependency)."))
    [void]$sb.Append((New-WBullet "Bước 3 — Đạt Dạng chuẩn 3 (Third Normal Form – 3NF):" "Loại bỏ toàn bộ các phụ thuộc hàm bắc cầu (Transitive Dependency). Cụ thể:`n  • Trong bảng Accounts: Thuộc tính RoleName và Description phụ thuộc vào RoleId (AccountId -> RoleId -> RoleName). Do đó, hệ thống tách thành bảng Roles(RoleId, RoleName, Description) và chỉ giữ khóa ngoại RoleId trong bảng Accounts.`n  • Đối với thông tin nhân khẩu học (Age, Gender, Address, Interest): Chỉ các tài khoản có vai trò Customer mới có dữ liệu nhân khẩu học phục vụ báo cáo CRM. Việc tách bảng CustomerProfiles(ProfileId, AccountId, Age, Gender, Address, Interest) liên kết 1–1 với Accounts giúp bảng Accounts không bị chứa các cột NULL dư thừa đối với các tài khoản Admin và Manager.`n  • Trong bảng Products: Thông tin CategoryName phụ thuộc vào CategoryId và thông tin SupplierName, Phone, Email phụ thuộc vào SupplierId. Do đó, hệ thống tách chuẩn thành bảng Categories và bảng Suppliers.`n  • Trong bảng SurveyResponses: Các thông tin Title, TargetProduct, ExpectedPrice phụ thuộc vào SurveyId nên được lưu duy nhất tại bảng Surveys; bảng SurveyResponses chỉ lưu kết quả trả lời (Score, BuyingIntent, CustomerOpinion) gắn với cặp khóa ngoại (SurveyId, AccountId)."))

    [void]$sb.Append((New-WHeading3 "3.1.3. Lược đồ Quan hệ Thực thể Cơ sở Dữ liệu (ERD) Tổng thể"))
    [void]$sb.Append((New-WP -Text "Lược đồ Cơ sở dữ liệu (Entity-Relationship Diagram – ERD) của hệ thống gồm 9 bảng thực thể và 8 mối kết hợp khóa ngoại (Foreign Key Relationships) được biểu diễn trực quan tại Hình 3.1:" -IndentFirst 420))

    [void]$sb.Append((New-WImage -RelId "rIdImg8" -WidthEmu 5900000 -HeightEmu 3800000 -Caption "Hình 3.1: Lược đồ Quan hệ Thực thể Cơ sở Dữ liệu (ERD) 9 Bảng Chuẩn hóa 3NF của Hệ thống SGU Tech" -DocPrId 108))

    [void]$sb.Append((New-WTable -Headers @("STT", "Tên Mối kết hợp (Relationship)", "Bảng Cha (1)", "Bảng Con (N / 1)", "Bản số", "Khóa ngoại tham chiếu", "Cơ chế Toàn vẹn Tham chiếu") -ColWidths @(600, 2100, 1300, 1500, 800, 1700, 1600) -Rows @(
        @("1", "Phân quyền Tài khoản", "Roles", "Accounts", "1 — N", "Accounts.RoleId -> Roles.RoleId", "RESTRICT / NO ACTION"),
        @("2", "Hồ sơ Nhân khẩu học KH", "Accounts", "CustomerProfiles", "1 — 1", "CustomerProfiles.AccountId -> Accounts.AccountId", "ON DELETE CASCADE (UNIQUE)"),
        @("3", "Phân loại Danh mục SP", "Categories", "Products", "1 — N", "Products.CategoryId -> Categories.CategoryId", "RESTRICT / NO ACTION"),
        @("4", "Cung ứng Sản phẩm", "Suppliers", "Products", "1 — N", "Products.SupplierId -> Suppliers.SupplierId", "RESTRICT / NO ACTION"),
        @("5", "Khách hàng Gửi Phản hồi", "Accounts", "Feedbacks", "1 — N", "Feedbacks.AccountId -> Accounts.AccountId", "ON DELETE CASCADE"),
        @("6", "Sản phẩm Nhận Phản hồi", "Products", "Feedbacks", "1 — N", "Feedbacks.ProductId -> Products.ProductId", "ON DELETE CASCADE"),
        @("7", "Chiến dịch Nhận Phiếu KS", "Surveys", "SurveyResponses", "1 — N", "SurveyResponses.SurveyId -> Surveys.SurveyId", "ON DELETE CASCADE"),
        @("8", "Khách hàng Trả lời KS", "Accounts", "SurveyResponses", "1 — N", "SurveyResponses.AccountId -> Accounts.AccountId", "ON DELETE CASCADE")
    )))

    [void]$sb.Append((New-WPageBreak))

    # ==========================================================================
    # 3.1.4. BẢNG MÔ TẢ CHI TIẾT CÁC BẢNG, THUỘC TÍNH VÀ DỮ LIỆU THỰC TẾ (9 BẢNG)
    # ==========================================================================
    [void]$sb.Append((New-WHeading3 "3.1.4. Đặc tả Chi tiết Cấu trúc Thuộc tính (Data Dictionary) và Dữ liệu Thực tế của 9 Bảng"))

    # --- BẢNG 1: ROLES ---
    [void]$sb.Append((New-WHeading4 "3.1.4.1. Bảng 1: Roles (Danh mục Vai trò Phân quyền Hệ thống — Kho D1)"))
    [void]$sb.Append((New-WP -Text "Bảng Roles lưu trữ danh mục 3 vai trò phân quyền duy nhất của hệ thống sau khi đã tinh gọn các vai trò dư thừa. Mỗi bản ghi xác định một không gian làm việc tách biệt trên phần mềm." -IndentFirst 420))
    [void]$sb.Append((New-WTable -Headers @("STT", "Tên thuộc tính", "Kiểu dữ liệu SQL", "Cho phép NULL", "Ràng buộc (Constraints)", "Mô tả chi tiết ý nghĩa thuộc tính") -ColWidths @(650, 1650, 1600, 1100, 1800, 2800) -Rows @(
        @("1", "RoleId", "INT IDENTITY(1,1)", "NOT NULL", "PRIMARY KEY", "Mã định danh tự tăng duy nhất của vai trò (1: Admin, 2: Manager, 3: Customer)."),
        @("2", "RoleName", "NVARCHAR(50)", "NOT NULL", "UNIQUE", "Tên định danh vai trò dùng để kiểm tra phân quyền trong code ('Admin', 'Manager', 'Customer')."),
        @("3", "Description", "NVARCHAR(250)", "NULL", "Default NULL", "Mô tả chi tiết chức năng và phạm vi giao diện của vai trò.")
    )))
    [void]$sb.Append((New-WP -Text "Dữ liệu thực tế đang lưu trữ trong bảng Roles (03 bản ghi):" -Bold $true -Size 24 -Color "1E3A8A"))
    [void]$sb.Append((New-WTable -Headers @("RoleId", "RoleName", "Description (Mô tả vai trò trong CSDL)", "Giao diện Điều hướng") -ColWidths @(1100, 1800, 4500, 2200) -Rows @(
        @("1", "Admin", "Quản trị viên máy chủ hệ thống (Quản lý Account & Phân quyền độc lập)", "Frontend_Admin/admin.html"),
        @("2", "Manager", "Người quản lý phân hệ CRM (Quản lý KH, Phản hồi, Báo cáo & Khảo sát)", "Frontend_Admin/quanly.html"),
        @("3", "Customer", "Khách hàng mua sắm, gửi đánh giá sản phẩm và thực hiện khảo sát", "Frontend_Admin/user.html")
    )))

    # --- BẢNG 2: ACCOUNTS ---
    [void]$sb.Append((New-WHeading4 "3.1.4.2. Bảng 2: Accounts (Tài khoản Định danh Người dùng — Kho D1)"))
    [void]$sb.Append((New-WP -Text "Bảng Accounts là bảng trung tâm của phân hệ Admin Server, lưu trữ thông tin đăng nhập, họ tên, liên hệ, khóa ngoại phân quyền RoleId và cờ trạng thái khóa/mở khóa IsActive của toàn bộ người dùng." -IndentFirst 420))
    [void]$sb.Append((New-WTable -Headers @("STT", "Tên thuộc tính", "Kiểu dữ liệu SQL", "Cho phép NULL", "Ràng buộc (Constraints)", "Mô tả chi tiết ý nghĩa thuộc tính") -ColWidths @(650, 1650, 1600, 1100, 1800, 2800) -Rows @(
        @("1", "AccountId", "INT IDENTITY(1,1)", "NOT NULL", "PRIMARY KEY", "Mã định danh duy nhất của từng tài khoản người dùng trên máy chủ."),
        @("2", "Username", "VARCHAR(50)", "NOT NULL", "UNIQUE", "Tên đăng nhập duy nhất (không phân biệt hoa thường khi xác thực)."),
        @("3", "PasswordHash", "NVARCHAR(255)", "NOT NULL", "NOT NULL", "Chuỗi mật khẩu xác thực (hỗ trợ băm BCrypt '$2a$11$...' và mật khẩu demo '123456')."),
        @("4", "FullName", "NVARCHAR(100)", "NOT NULL", "NOT NULL", "Họ và tên đầy đủ của chủ tài khoản hiển thị trên Header và báo cáo."),
        @("5", "Email", "VARCHAR(100)", "NULL", "Default Email", "Địa chỉ thư điện tử liên hệ của tài khoản."),
        @("6", "Phone", "VARCHAR(20)", "NULL", "Default NULL", "Số điện thoại liên hệ của chủ sở hữu tài khoản."),
        @("7", "RoleId", "INT", "NOT NULL", "FK -> Roles(RoleId)", "Khóa ngoại xác định vai trò của tài khoản (1: Admin, 2: Manager, 3: Customer)."),
        @("8", "IsActive", "BIT", "NOT NULL", "DEFAULT 1", "Trạng thái tài khoản (1 = Đang hoạt động; 0 = Đã bị khóa bởi Admin hoặc Quản lý)."),
        @("9", "CreatedAt", "DATETIME", "NOT NULL", "DEFAULT GETDATE()", "Thời điểm tạo tài khoản trên hệ thống.")
    )))
    [void]$sb.Append((New-WP -Text "Dữ liệu thực tế đang lưu trữ trong bảng Accounts (19 bản ghi tài khoản chuẩn bị sẵn để test):" -Bold $true -Size 24 -Color "1E3A8A"))
    [void]$sb.Append((New-WTable -Headers @("AccountId", "Username", "FullName (Họ và tên)", "Email", "Phone", "RoleId (Vai trò)", "IsActive (Trạng thái)") -ColWidths @(900, 1350, 2350, 1950, 1150, 1000, 900) -Rows @(
        @("1", "admin", "Nguyễn Quản Trị Hệ Thống", "admin@sgutech.vn", "0901000001", "1 (Admin)", "1 (Hoạt động)"),
        @("2", "admin2", "Lê Hoàng Nam (Bảo mật IT)", "nam.le@sgutech.vn", "0901000003", "1 (Admin)", "1 (Hoạt động)"),
        @("3", "quanly", "Trần Trưởng Phòng CRM", "crm.manager@sgutech.vn", "0901000002", "2 (Manager)", "1 (Hoạt động)"),
        @("4", "quanly_cskh", "Nguyễn Thu Trang (Phó phòng CSKH)", "trang.nguyen@sgutech.vn", "0901000004", "2 (Manager)", "1 (Hoạt động)"),
        @("5", "khachhang1", "Nguyễn Văn An", "an.nguyen@gmail.com", "0912345671", "3 (Customer)", "1 (Hoạt động)"),
        @("6", "khachhang2", "Lê Thị Bình", "binh.le@gmail.com", "0912345672", "3 (Customer)", "1 (Hoạt động)"),
        @("7", "khachhang3", "Phạm Minh Châu", "chau.pham@gmail.com", "0912345673", "3 (Customer)", "1 (Hoạt động)"),
        @("8", "khachhang4", "Hoàng Đức Dũng", "dung.hoang@gmail.com", "0912345674", "3 (Customer)", "1 (Hoạt động)"),
        @("9", "khachhang5", "Võ Ngọc Hân (TK vi phạm - Đã khóa)", "han.vo@gmail.com", "0912345675", "3 (Customer)", "0 (Đã khóa)"),
        @("10", "khachhang6", "Trần Quốc Bảo", "bao.tran@gmail.com", "0912345676", "3 (Customer)", "1 (Hoạt động)"),
        @("11", "khachhang7", "Đặng Thúy Kiều", "kieu.dang@gmail.com", "0912345677", "3 (Customer)", "1 (Hoạt động)"),
        @("12", "khachhang8", "Vũ Tuấn Kiệt", "kiet.vu@gmail.com", "0912345678", "3 (Customer)", "1 (Hoạt động)"),
        @("13", "khachhang9", "Bùi Quỳnh Chi", "chi.bui@gmail.com", "0912345679", "3 (Customer)", "1 (Hoạt động)"),
        @("14", "khachhang10", "Đỗ Hoàng Long", "long.do@gmail.com", "0912345680", "3 (Customer)", "1 (Hoạt động)"),
        @("15", "khachhang11", "Ngô Phương Thảo", "thao.ngo@gmail.com", "0912345681", "3 (Customer)", "1 (Hoạt động)"),
        @("16", "khachhang12", "Trịnh Gia Huy", "huy.trinh@gmail.com", "0912345682", "3 (Customer)", "1 (Hoạt động)"),
        @("17", "khachhang13", "Mai Anh Tuấn", "tuan.mai@gmail.com", "0912345683", "3 (Customer)", "1 (Hoạt động)"),
        @("18", "khachhang14", "Dương Hoàng Yến", "yen.duong@gmail.com", "0912345684", "3 (Customer)", "1 (Hoạt động)"),
        @("19", "khachhang15", "Phan Thành Đạt (Tạm ngưng GD)", "dat.phan@gmail.com", "0912345685", "3 (Customer)", "0 (Đã khóa)")
    )))

    [void]$sb.Append((New-WPageBreak))

    # --- BẢNG 3: CUSTOMERPROFILES ---
    [void]$sb.Append((New-WHeading4 "3.1.4.3. Bảng 3: CustomerProfiles (Hồ sơ Nhân khẩu học Khách hàng — Kho D2)"))
    [void]$sb.Append((New-WP -Text "Bảng CustomerProfiles lưu trữ thông tin nhân khẩu học chuyên sâu của từng khách hàng (Độ tuổi, Giới tính, Địa chỉ, Sở thích tiêu dùng), phục vụ trực tiếp cho nghiệp vụ Báo cáo tỷ lệ độ tuổi và sở thích của Người quản lý CRM cũng như chức năng Chỉnh sửa thông tin của Khách hàng." -IndentFirst 420))
    [void]$sb.Append((New-WTable -Headers @("STT", "Tên thuộc tính", "Kiểu dữ liệu SQL", "Cho phép NULL", "Ràng buộc (Constraints)", "Mô tả chi tiết ý nghĩa thuộc tính") -ColWidths @(650, 1650, 1600, 1100, 1800, 2800) -Rows @(
        @("1", "ProfileId", "INT IDENTITY(1,1)", "NOT NULL", "PRIMARY KEY", "Mã định danh tự tăng của hồ sơ nhân khẩu học khách hàng."),
        @("2", "AccountId", "INT", "NOT NULL", "UNIQUE, FK -> Accounts", "Khóa ngoại liên kết 1–1 với bảng Accounts (ON DELETE CASCADE)."),
        @("3", "Age", "INT", "NOT NULL", "NOT NULL (Default 20)", "Độ tuổi hiện tại của khách hàng (dùng để phân tích tỷ lệ độ tuổi)."),
        @("4", "Gender", "NVARCHAR(10)", "NULL", "Nam / Nữ / Khác", "Giới tính của khách hàng."),
        @("5", "Address", "NVARCHAR(255)", "NULL", "Default NULL", "Địa chỉ liên hệ và nhận hàng chi tiết của khách hàng."),
        @("6", "Interest", "NVARCHAR(100)", "NULL", "Gaming/Đồ họa/Văn phòng/Lập trình", "Nhóm sở thích tiêu dùng công nghệ chính của khách hàng.")
    )))
    [void]$sb.Append((New-WP -Text "Dữ liệu thực tế đang lưu trữ trong bảng CustomerProfiles (15 hồ sơ khách hàng):" -Bold $true -Size 24 -Color "1E3A8A"))
    [void]$sb.Append((New-WTable -Headers @("ProfileId", "AccountId", "Tên Khách hàng (Liên kết)", "Age (Tuổi)", "Gender", "Interest (Sở thích)", "Address (Địa chỉ cư trú thực tế)") -ColWidths @(850, 900, 1950, 850, 800, 1250, 3000) -Rows @(
        @("1", "5", "Nguyễn Văn An (khachhang1)", "19", "Nam", "Gaming", "273 An Dương Vương, Quận 5, TP.HCM"),
        @("2", "6", "Lê Thị Bình (khachhang2)", "24", "Nữ", "Văn phòng", "120 Nguyễn Thị Minh Khai, Quận 3, TP.HCM"),
        @("3", "7", "Phạm Minh Châu (khachhang3)", "28", "Nam", "Lập trình", "45 Lê Văn Việt, TP. Thủ Đức, TP.HCM"),
        @("4", "8", "Hoàng Đức Dũng (khachhang4)", "35", "Nam", "Đồ họa", "88 Cộng Hòa, Quận Tân Bình, TP.HCM"),
        @("5", "9", "Võ Ngọc Hân (khachhang5)", "22", "Nữ", "Gaming", "15 Trần Hưng Đạo, Quận 1, TP.HCM"),
        @("6", "10", "Trần Quốc Bảo (khachhang6)", "31", "Nam", "Văn phòng", "102 Võ Văn Ngân, TP. Thủ Đức, TP.HCM"),
        @("7", "11", "Đặng Thúy Kiều (khachhang7)", "18", "Nữ", "Gaming", "334 Nguyễn Trãi, Quận 5, TP.HCM"),
        @("8", "12", "Vũ Tuấn Kiệt (khachhang8)", "42", "Nam", "Lập trình", "56 Điện Biên Phủ, Quận Bình Thạnh, TP.HCM"),
        @("9", "13", "Bùi Quỳnh Chi (khachhang9)", "26", "Nữ", "Đồ họa", "182 Hai Bà Trưng, Quận 1, TP.HCM"),
        @("10", "14", "Đỗ Hoàng Long (khachhang10)", "29", "Nam", "Gaming", "65 Hoàng Hoa Thám, Quận Phú Nhuận, TP.HCM"),
        @("11", "15", "Ngô Phương Thảo (khachhang11)", "23", "Nữ", "Văn phòng", "210 Cách Mạng Tháng 8, Quận 10, TP.HCM"),
        @("12", "16", "Trịnh Gia Huy (khachhang12)", "19", "Nam", "Lập trình", "99 Nguyễn Tri Phương, Quận 5, TP.HCM"),
        @("13", "17", "Mai Anh Tuấn (khachhang13)", "38", "Nam", "Đồ họa", "14 Phan Xích Long, Quận Phú Nhuận, TP.HCM"),
        @("14", "18", "Dương Hoàng Yến (khachhang14)", "25", "Nữ", "Văn phòng", "72 Ba Tháng Hai, Quận 10, TP.HCM"),
        @("15", "19", "Phan Thành Đạt (khachhang15)", "45", "Nam", "Gaming", "415 Lê Hồng Phong, Quận 5, TP.HCM")
    )))

    # --- BẢNG 4 & 5: CATEGORIES & SUPPLIERS ---
    [void]$sb.Append((New-WHeading4 "3.1.4.4. Bảng 4: Categories (Danh mục Nhóm Sản phẩm — Kho D3) & Bảng 5: Suppliers (Nhà cung cấp — Kho D3)"))
    [void]$sb.Append((New-WTable -Headers @("Tên Bảng", "Tên thuộc tính", "Kiểu dữ liệu SQL", "Ràng buộc", "Mô tả chi tiết ý nghĩa thuộc tính") -ColWidths @(1500, 1700, 1600, 1600, 3200) -Rows @(
        @("Categories", "CategoryId", "INT IDENTITY(1,1)", "PRIMARY KEY", "Mã định danh duy nhất của nhóm ngành hàng công nghệ."),
        @("Categories", "CategoryName", "NVARCHAR(100)", "NOT NULL", "Tên danh mục sản phẩm (Laptop, Màn hình, Phím Chuột, Linh kiện, Thiết bị mạng)."),
        @("Categories", "Description", "NVARCHAR(255)", "NULL", "Mô tả đặc điểm dòng sản phẩm trong danh mục."),
        @("Suppliers", "SupplierId", "INT IDENTITY(1,1)", "PRIMARY KEY", "Mã định danh duy nhất của đối tác nhà cung cấp."),
        @("Suppliers", "SupplierCode", "VARCHAR(20)", "NOT NULL, UNIQUE", "Mã hiệu nhà cung cấp (NCC001 đến NCC006)."),
        @("Suppliers", "SupplierName", "NVARCHAR(150)", "NOT NULL", "Tên pháp nhân đầy đủ của công ty cung ứng."),
        @("Suppliers", "ContactName, Phone, Email, Address", "NVARCHAR / VARCHAR", "NULL", "Thông tin người đại diện liên hệ, số điện thoại, email và địa chỉ trụ sở NCC.")
    )))
    [void]$sb.Append((New-WP -Text "Dữ liệu thực tế trong bảng Categories (5 bản ghi) và bảng Suppliers (6 bản ghi):" -Bold $true -Size 24 -Color "1E3A8A"))
    [void]$sb.Append((New-WTable -Headers @("Loại Dữ liệu", "Mã ID / Code", "Tên Danh mục / Tên Nhà cung cấp", "Thông tin Chi tiết / Mô tả trong CSDL") -ColWidths @(1500, 1300, 3200, 3600) -Rows @(
        @("Category #1", "CAT-01", "Laptop & Máy tính xách tay", "Dòng máy phục vụ học tập, văn phòng, đồ họa và gaming đỉnh cao"),
        @("Category #2", "CAT-02", "Màn hình chuyên dụng", "Màn hình độ phân giải cao 2K/4K/5K và tần số quét cao lên đến 180Hz"),
        @("Category #3", "CAT-03", "Bàn phím & Chuột cao cấp", "Bàn phím cơ Custom, chuột công thái học và phụ kiện gaming gear"),
        @("Category #4", "CAT-04", "Linh kiện & Lưu trữ tốc độ cao", "Ổ cứng SSD NVMe Gen 4, RAM DDR5 tản nhiệt và Card đồ họa"),
        @("Category #5", "CAT-05", "Thiết bị mạng & Phụ kiện AI", "Router WiFi 6 công suất lớn, Webcam 4K và thiết bị truyền phát"),
        @("Supplier #1", "NCC001", "Công ty TNHH ASUS Việt Nam", "Liên hệ: Ông Minh Hoàng | SĐT: 02838111222 | Quận 1, TP.HCM"),
        @("Supplier #2", "NCC002", "Công ty TNHH Logitech Đông Nam Á", "Liên hệ: Bà Thanh Thảo | SĐT: 02838333444 | Quận 3, TP.HCM"),
        @("Supplier #3", "NCC003", "Tập đoàn LG Electronics Việt Nam", "Liên hệ: Ông Quốc Bảo | SĐT: 02838555666 | Quận 7, TP.HCM"),
        @("Supplier #4", "NCC004", "Công ty Cổ phần Synnex FPT", "Liên hệ: Bà Ngọc Trâm | SĐT: 02873006666 | Quận Bình Thạnh, TP.HCM"),
        @("Supplier #5", "NCC005", "Tập đoàn Sony Electronics Việt Nam", "Liên hệ: Ông Quang Huy | SĐT: 02838449999 | Quận Tân Bình, TP.HCM"),
        @("Supplier #6", "NCC006", "Công ty TNHH Điện tử Samsung Vina", "Liên hệ: Bà Phương Linh | SĐT: 02839157310 | Quận 1, TP.HCM")
    )))

    [void]$sb.Append((New-WPageBreak))

    # --- BẢNG 6: PRODUCTS ---
    [void]$sb.Append((New-WHeading4 "3.1.4.5. Bảng 6: Products (Danh mục Sản phẩm Công nghệ — Kho D3)"))
    [void]$sb.Append((New-WP -Text "Bảng Products lưu trữ thông tin chi tiết của 16 dòng sản phẩm công nghệ tại SGU Tech. Khi khách hàng gửi phản hồi trên cổng user.html, khách hàng sẽ chọn sản phẩm từ bảng này và hệ thống hiển thị kèm hình ảnh sản phẩm (ImageUrl) trực quan trên cả màn hình Khách hàng lẫn màn hình Người quản lý CRM." -IndentFirst 420))
    [void]$sb.Append((New-WTable -Headers @("STT", "Tên thuộc tính", "Kiểu dữ liệu SQL", "Cho phép NULL", "Ràng buộc (Constraints)", "Mô tả chi tiết ý nghĩa thuộc tính") -ColWidths @(650, 1650, 1600, 1100, 1800, 2800) -Rows @(
        @("1", "ProductId", "INT IDENTITY(1,1)", "NOT NULL", "PRIMARY KEY", "Mã định danh duy nhất của sản phẩm."),
        @("2", "ProductCode", "VARCHAR(50)", "NOT NULL", "UNIQUE", "Mã SKU quản lý sản phẩm (SP001 đến SP016)."),
        @("3", "ProductName", "NVARCHAR(200)", "NOT NULL", "NOT NULL", "Tên thương mại đầy đủ của sản phẩm công nghệ."),
        @("4", "CategoryId", "INT", "NOT NULL", "FK -> Categories", "Khóa ngoại xác định danh mục nhóm sản phẩm."),
        @("5", "SupplierId", "INT", "NOT NULL", "FK -> Suppliers", "Khóa ngoại xác định nhà cung cấp sản phẩm."),
        @("6", "Price", "DECIMAL(18,2)", "NOT NULL", "NOT NULL", "Đơn giá bán lẻ niêm yết (VNĐ)."),
        @("7", "CostPrice", "DECIMAL(18,2)", "NOT NULL", "NOT NULL", "Giá vốn nhập hàng (VNĐ)."),
        @("8", "StockQuantity", "INT", "NOT NULL", "DEFAULT 0", "Số lượng tồn kho hiện tại."),
        @("9", "Unit", "NVARCHAR(20)", "NOT NULL", "Cái / Bộ", "Đơn vị tính của sản phẩm."),
        @("10", "Status", "NVARCHAR(50)", "NOT NULL", "Đang bán / Hết hàng", "Trạng thái kinh doanh của sản phẩm."),
        @("11", "ImageUrl", "NVARCHAR(500)", "NULL", "URL Hình ảnh", "Đường dẫn ảnh minh họa sản phẩm hiển thị trên bảng phản hồi.")
    )))

    # --- BẢNG 7: FEEDBACKS ---
    [void]$sb.Append((New-WHeading4 "3.1.4.6. Bảng 7: Feedbacks (Phản hồi Sản phẩm của Khách hàng & Giải đáp từ Quản lý — Kho D4)"))
    [void]$sb.Append((New-WP -Text "Bảng Feedbacks lưu trữ toàn bộ các lượt đánh giá mức độ hài lòng (Rating 1–5 sao) và nhận xét sản phẩm do khách hàng gửi về, đồng thời lưu câu trả lời giải đáp chính thức (AdminReply) và trạng thái xử lý (Status) của Người quản lý CRM." -IndentFirst 420))
    [void]$sb.Append((New-WTable -Headers @("STT", "Tên thuộc tính", "Kiểu dữ liệu SQL", "Cho phép NULL", "Ràng buộc (Constraints)", "Mô tả chi tiết ý nghĩa thuộc tính") -ColWidths @(650, 1650, 1600, 1100, 1800, 2800) -Rows @(
        @("1", "FeedbackId", "INT IDENTITY(1,1)", "NOT NULL", "PRIMARY KEY", "Mã định danh duy nhất của lượt phản hồi sản phẩm."),
        @("2", "AccountId", "INT", "NOT NULL", "FK -> Accounts (CASCADE)", "Khóa ngoại xác định tài khoản khách hàng gửi phản hồi."),
        @("3", "ProductId", "INT", "NOT NULL", "FK -> Products (CASCADE)", "Khóa ngoại xác định sản phẩm được khách hàng đánh giá."),
        @("4", "Rating", "INT", "NOT NULL", "CHECK (1 <= Rating <= 5)", "Điểm đánh giá mức độ hài lòng từ 1 sao đến 5 sao."),
        @("5", "Comment", "NVARCHAR(1000)", "NOT NULL", "NOT NULL", "Nội dung nhận xét, góp ý hoặc khiếu nại chi tiết của khách hàng."),
        @("6", "AdminReply", "NVARCHAR(1000)", "NULL", "Default NULL", "Nội dung câu trả lời giải đáp từ Người quản lý CRM."),
        @("7", "Status", "NVARCHAR(50)", "NOT NULL", "DEFAULT N'Chờ xử lý'", "Trạng thái xử lý ('Chờ xử lý' hoặc 'Đã tiếp nhận & Xử lý')."),
        @("8", "CreatedAt", "DATETIME", "NOT NULL", "DEFAULT GETDATE()", "Thời điểm khách hàng gửi phản hồi lên hệ thống.")
    )))
    [void]$sb.Append((New-WP -Text "Dữ liệu thực tế đang lưu trữ trong bảng Feedbacks (18 bản ghi giao dịch phản hồi thực tế):" -Bold $true -Size 24 -Color "1E3A8A"))
    [void]$sb.Append((New-WTable -Headers @("ID", "Khách hàng", "Sản phẩm đánh giá", "Sao", "Nội dung phản hồi (Comment)", "Giải đáp từ Người quản lý (AdminReply)", "Trạng thái") -ColWidths @(500, 1250, 1650, 550, 2350, 2250, 1050) -Rows @(
        @("1", "Nguyễn Văn An", "Laptop ASUS ROG Strix G16", "5★", "Laptop ROG Strix chạy cực kỳ mượt, tản nhiệt mát mẻ khi chiến game AAA nặng ở độ phân giải 2K.", "Cảm ơn bạn đã tin tưởng ủng hộ sản phẩm chính hãng tại hệ thống SGU Tech!", "Đã tiếp nhận & Xử lý"),
        @("2", "Lê Thị Bình", "Chuột Logitech MX Master 3S", "4★", "Chuột MX Master 3S cuộn trang vô cực rất êm tay cho công việc văn phòng, pin dùng cả tháng.", "SGU Tech xin cảm ơn đánh giá tích cực từ bạn!", "Đã tiếp nhận & Xử lý"),
        @("3", "Phạm Minh Châu", "Màn hình LG UltraGear 27 2K", "5★", "Màn hình LG UltraGear hiển thị chuẩn màu, tần số quét 180Hz chơi game và làm việc rất sướng mắt.", "Chúc bạn có những trải nghiệm tuyệt vời cùng sản phẩm!", "Đã tiếp nhận & Xử lý"),
        @("4", "Hoàng Đức Dũng", "SSD Samsung 990 Pro 2TB", "5★", "Tốc độ đọc ghi của SSD Samsung 990 Pro cực nhanh, render video đồ họa 4K tiết kiệm rất nhiều thời gian.", "Cảm ơn bạn! Dòng Samsung 990 Pro là đỉnh nhất hiện nay ạ.", "Đã tiếp nhận & Xử lý"),
        @("5", "Bùi Quỳnh Chi", "Màn hình Dell UltraSharp 32 4K", "5★", "Màn hình Dell UltraSharp 32 4K IPS Black màu đen sâu, độ phủ màu chuẩn DCI-P3 98% rất đáng tiền.", "Dòng UltraSharp IPS Black luôn được hỗ trợ bảo hành đổi mới 3 năm bạn nhé!", "Đã tiếp nhận & Xử lý"),
        @("6", "Đỗ Hoàng Long", "Bàn phím Keychron Q1 Max", "5★", "Bàn phím Keychron Q1 Max gõ đầm tay, âm thanh thock trầm rất êm, kết nối không dây 2.4Ghz cực nhạy.", "Cảm ơn bạn đã lựa chọn phiên bản phím cơ nhôm CNC cao cấp tại SGU Tech!", "Đã tiếp nhận & Xử lý"),
        @("7", "Ngô Phương Thảo", "MacBook Pro 14 M3 Pro", "5★", "MacBook Pro 14 M3 Pro pin trâu kinh khủng, dùng cả ngày không cần cắm sạc, màn hình tuyệt đẹp.", "Cảm ơn chị đã mua hàng chính hãng Apple tại SGU Tech!", "Đã tiếp nhận & Xử lý"),
        @("8", "Nguyễn Văn An", "Chuột Logitech G102 Gen 2", "4★", "Chuột G102 bền bỉ, click nảy tốt, mức giá rất vừa túi tiền sinh viên.", "(Chưa trả lời — Đang chờ tiếp nhận)", "Chờ xử lý"),
        @("9", "Đặng Thúy Kiều", "Tai nghe HyperX Cloud II", "4★", "Tai nghe HyperX Cloud II đeo êm tai không bị cấn, mic lọc ồn tốt khi đàm thoại.", "(Chưa trả lời — Đang chờ tiếp nhận)", "Chờ xử lý"),
        @("10", "Vũ Tuấn Kiệt", "Màn hình ASUS ProArt 27 4K", "3★", "Màn hình ProArt màu đẹp nhưng viền hơi dày hơn mong đợi một chút.", "(Chưa trả lời — Đang chờ tiếp nhận)", "Chờ xử lý"),
        @("11", "Trịnh Gia Huy", "RAM Corsair DDR5 64GB", "5★", "RAM Corsair DDR5 64GB mở hàng chục máy ảo Docker chạy mượt mà, LED RGB đồng bộ iCUE đẹp mắt.", "(Chưa trả lời — Đang chờ tiếp nhận)", "Chờ xử lý"),
        @("12", "Mai Anh Tuấn", "Webcam 4K Sony Bravia Cam", "4★", "Webcam Sony 4K nét căng, tự động lấy nét khuôn mặt khi họp online rất tiện lợi.", "(Chưa trả lời — Đang chờ tiếp nhận)", "Chờ xử lý"),
        @("13", "Phạm Minh Châu", "Laptop ASUS ROG Strix G16", "5★", "Máy đẹp, cấu hình khủng, nhân viên tư vấn SGU Tech rất nhiệt tình hỗ trợ cài đặt ban đầu.", "(Chưa trả lời — Đang chờ tiếp nhận)", "Chờ xử lý"),
        @("14", "Đỗ Hoàng Long", "Bàn phím Logitech G Pro X", "2★", "Bàn phím G Pro X gõ tốt nhưng âm thanh clicky của switch hơi ồn khi làm việc ban đêm.", "Bạn có thể ghé showroom SGU Tech để đổi sang phiên bản switch Linear êm hơn nhé!", "Đã tiếp nhận & Xử lý"),
        @("15", "Dương Hoàng Yến", "Router ASUS ROG GT-AX6000", "4★", "Router Asus phát sóng xuyên tường 2 tầng lầu vẫn bắt được sóng WiFi 6 mạnh mẽ.", "(Chưa trả lời — Đang chờ tiếp nhận)", "Chờ xử lý"),
        @("16", "Lê Thị Bình", "Tai nghe Sony WH-1000XM5", "5★", "Chống ồn của Sony XM5 thực sự đỉnh cao, đi xe buýt hay máy bay bật lên là yên tĩnh hoàn toàn.", "(Chưa trả lời — Đang chờ tiếp nhận)", "Chờ xử lý"),
        @("17", "Hoàng Đức Dũng", "Card ASUS TUF RTX 4080 Super", "1★", "Card đồ họa RTX 4080 Super giao đến bị cấn một góc hộp bìa carton bên ngoài do vận chuyển.", "SGU Tech chân thành xin lỗi anh! Quản lý kho đã liên hệ và đổi mới nguyên seal ngay trong hôm nay ạ.", "Đã tiếp nhận & Xử lý"),
        @("18", "Nguyễn Văn An", "SSD Samsung 990 Pro 2TB", "5★", "Mua chiếc SSD thứ hai gắn thêm cho laptop ROG, tốc độ ổn định nhiệt độ chỉ 45 độ C.", "(Chưa trả lời — Đang chờ tiếp nhận)", "Chờ xử lý")
    )))

    [void]$sb.Append((New-WPageBreak))

    # --- BẢNG 8 & 9: SURVEYS & SURVEYRESPONSES ---
    [void]$sb.Append((New-WHeading4 "3.1.4.7. Bảng 8: Surveys (Chiến dịch Bảng Khảo sát — Kho D5) & Bảng 9: SurveyResponses (Phiếu Trả lời Khảo sát — Kho D5)"))
    [void]$sb.Append((New-WP -Text "Cặp bảng Surveys và SurveyResponses hiện thực hóa trọn vẹn nghiệp vụ Tạo bảng khảo sát gửi đến tài khoản khách hàng, Nhận & thực hiện khảo sát, và Thống kê kết quả khảo sát:" -IndentFirst 420))
    [void]$sb.Append((New-WTable -Headers @("Tên Bảng", "Tên thuộc tính", "Kiểu dữ liệu SQL", "Ràng buộc (Constraints)", "Mô tả chi tiết ý nghĩa thuộc tính") -ColWidths @(1550, 1650, 1600, 1800, 3000) -Rows @(
        @("Surveys", "SurveyId", "INT IDENTITY(1,1)", "PRIMARY KEY", "Mã định danh duy nhất của chiến dịch bảng khảo sát."),
        @("Surveys", "Title", "NVARCHAR(200)", "NOT NULL", "Tiêu đề bảng khảo sát hiển thị trên tài khoản khách hàng."),
        @("Surveys", "Description", "NVARCHAR(1000)", "NULL", "Mô tả chi tiết tính năng, công nghệ của sản phẩm cần khảo sát."),
        @("Surveys", "TargetProduct", "NVARCHAR(150)", "NOT NULL", "Tên sản phẩm công nghệ mới dự kiến ra mắt."),
        @("Surveys", "ExpectedPrice", "DECIMAL(18,2)", "NOT NULL", "Mức giá bán dự kiến đưa ra khảo sát (VNĐ)."),
        @("Surveys", "CreatedAt", "DATETIME", "DEFAULT GETDATE()", "Thời điểm Người quản lý phát hành bảng khảo sát."),
        @("Surveys", "IsActive", "BIT", "DEFAULT 1", "Trạng thái mở/khóa khảo sát (1: Đang mở; 0: Đã khóa)."),
        @("Surveys", "ExpiresAt", "DATETIME", "NULL", "Thời hạn kết thúc nhận khảo sát (NULL = Không giới hạn thời gian)."),
        @("SurveyResponses", "ResponseId", "INT IDENTITY(1,1)", "PRIMARY KEY", "Mã định danh duy nhất của phiếu trả lời khảo sát."),
        @("SurveyResponses", "SurveyId", "INT", "FK -> Surveys (CASCADE)", "Khóa ngoại xác định chiến dịch khảo sát được trả lời."),
        @("SurveyResponses", "AccountId", "INT", "FK -> Accounts (CASCADE)", "Khóa ngoại xác định tài khoản khách hàng thực hiện khảo sát."),
        @("SurveyResponses", "Score", "INT", "CHECK (1 <= Score <= 5)", "Điểm đánh giá mức độ quan tâm đối với sản phẩm (1 đến 5 điểm)."),
        @("SurveyResponses", "BuyingIntent", "NVARCHAR(50)", "NOT NULL", "Ý định mua sắm ('Rất muốn mua', 'Đang cân nhắc', 'Không mua')."),
        @("SurveyResponses", "CustomerOpinion", "NVARCHAR(1000)", "NULL", "Ý kiến đóng góp chi tiết của khách hàng về tính năng và mức giá."),
        @("SurveyResponses", "SubmittedAt", "DATETIME", "DEFAULT GETDATE()", "Thời điểm khách hàng hoàn tất và gửi phiếu khảo sát.")
    )))

    [void]$sb.Append((New-WP -Text "Dữ liệu thực tế trong bảng Surveys (05 chiến dịch khảo sát) và bảng SurveyResponses (16 phiếu trả lời):" -Bold $true -Size 24 -Color "1E3A8A"))
    [void]$sb.Append((New-WTable -Headers @("SurveyId", "Tiêu đề Chiến dịch Khảo sát (Title)", "Sản phẩm Khảo sát (TargetProduct)", "Giá dự kiến", "Trạng thái & Hạn", "Số phiếu") -ColWidths @(850, 2950, 2200, 1250, 1450, 900) -Rows @(
        @("1", "Khảo sát nhu cầu dòng Laptop AI Siêu Mỏng Nhẹ 2026", "ASUS Zenbook S16 OLED AI 2026", "36.990.000 đ", "Đang mở (Còn 20 ngày)", "06 phiếu"),
        @("2", "Thăm dò Bàn phím cơ Custom Nhôm CNC Không dây", "Keychron Q1 Max SGU Custom Edition", "4.500.000 đ", "Đang mở (Không hạn)", "04 phiếu"),
        @("3", "Thăm dò Tai nghe chống ồn Hi-Res Thế hệ Mới", "Sony WH-1000XM6 Edition 2026", "7.990.000 đ", "Đang mở (Còn 10 ngày)", "03 phiếu"),
        @("4", "Khảo sát Màn hình Đồ họa 5K Chuyên Dụng Cho Designer", "Dell UltraSharp 32 5K HDR", "24.500.000 đ", "Đang mở (Còn 15 ngày)", "03 phiếu"),
        @("5", "Khảo sát thử nghiệm Màn hình cong Mini-LED 49 inch", "Samsung Odyssey OLED G9", "29.900.000 đ", "Đã đóng (IsActive = 0)", "00 phiếu")
    )))

    [void]$sb.Append((New-WTable -Headers @("Mã Phiếu", "SurveyId", "Khách hàng Thực hiện", "Điểm (1–5)", "Ý định mua (BuyingIntent)", "Ý kiến đóng góp thực tế của Khách hàng (CustomerOpinion)") -ColWidths @(850, 850, 1750, 850, 1400, 3900) -Rows @(
        @("RSP-01", "KS #1", "Nguyễn Văn An (ID 5)", "5 / 5", "Rất muốn mua", "Thiết kế cực kỳ sang trọng, nếu có quà tặng kèm chuột không dây và túi chống sốc tôi sẽ đặt trước ngay."),
        @("RSP-02", "KS #1", "Lê Thị Bình (ID 6)", "4 / 5", "Đang cân nhắc", "Cấu hình chip AI rất ấn tượng nhưng mức giá gần 37 triệu hơi cao đối với nhân viên văn phòng."),
        @("RSP-03", "KS #1", "Phạm Minh Châu (ID 7)", "5 / 5", "Rất muốn mua", "Màn hình OLED 3K và thời lượng pin lâu rất phù hợp cho lập trình viên, mong cửa hàng hỗ trợ trả góp 0%."),
        @("RSP-04", "KS #1", "Trần Quốc Bảo (ID 10)", "5 / 5", "Rất muốn mua", "Máy rất nhẹ phù hợp đi công tác xa, tôi sẵn sàng đặt cọc trước."),
        @("RSP-05", "KS #1", "Vũ Tuấn Kiệt (ID 12)", "3 / 5", "Không mua", "Tôi quen dùng máy tính bàn cấu hình cao hơn là laptop mỏng nhẹ."),
        @("RSP-06", "KS #1", "Ngô Phương Thảo (ID 15)", "4 / 5", "Đang cân nhắc", "Chờ xem bản thực tế ngoài showroom SGU Tech rồi sẽ quyết định mua."),
        @("RSP-07", "KS #2", "Hoàng Đức Dũng (ID 8)", "4 / 5", "Đang cân nhắc", "Bản nhôm CNC rất đầm, nếu shop có sẵn switch tactile tôi sẽ mua ngay."),
        @("RSP-08", "KS #2", "Nguyễn Văn An (ID 5)", "5 / 5", "Rất muốn mua", "Mức giá 4.5 triệu cho bản Q1 Max là quá hợp lý trong phân khúc phím nhôm."),
        @("RSP-09", "KS #2", "Đỗ Hoàng Long (ID 14)", "5 / 5", "Rất muốn mua", "Sẵn sàng mua ngay khi mở bán đợt đầu, mong có màu đen nhám Anodized."),
        @("RSP-10", "KS #2", "Trịnh Gia Huy (ID 16)", "3 / 5", "Không mua", "Đã có bàn phím cơ rồi nên chưa có nhu cầu mua thêm."),
        @("RSP-11", "KS #3", "Lê Thị Bình (ID 6)", "4 / 5", "Đang cân nhắc", "Nếu trọng lượng nhẹ hơn bản XM5 và đệm tai êm hơn tôi sẽ nâng cấp."),
        @("RSP-12", "KS #3", "Đặng Thúy Kiều (ID 11)", "5 / 5", "Rất muốn mua", "Nếu chống ồn AI tốt hơn XM5 thì 8 triệu là mức giá chấp nhận được."),
        @("RSP-13", "KS #3", "Bùi Quỳnh Chi (ID 13)", "4 / 5", "Đang cân nhắc", "Mong đợi chất âm ấm và microphone đàm thoại rõ ràng hơn."),
        @("RSP-14", "KS #4", "Hoàng Đức Dũng (ID 8)", "5 / 5", "Rất muốn mua", "Độ phân giải 5K rất cần cho biên tập ảnh và video, mức giá 24.5 triệu rất cạnh tranh với Apple Studio Display."),
        @("RSP-15", "KS #4", "Bùi Quỳnh Chi (ID 13)", "5 / 5", "Rất muốn mua", "Nếu có chân đế xoay dọc công thái học và cổng sạc Thunderbolt 4 thì hoàn hảo."),
        @("RSP-16", "KS #4", "Mai Anh Tuấn (ID 17)", "4 / 5", "Đang cân nhắc", "Cần kiểm tra độ tương phản thực tế tại showroom SGU Tech.")
    )))

    [void]$sb.Append((New-WPageBreak))
    return $sb.ToString()
}
