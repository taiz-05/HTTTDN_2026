USE master;
GO

-- 1. XÓA CSDL CŨ (NẾU ĐÃ TỒN TẠI) VÀ TẠO MỚI CSDL HTTTDN_DB
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

-- ========================================================================
-- PHẦN I: THIẾT KẾ CƠ SỞ DỮ LIỆU (9 BẢNG CHUẨN MỰC HỆ THỐNG HTTTDN - CRM)
-- ========================================================================

-- 1. Bảng Vai trò (Roles)
CREATE TABLE Roles (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(250) NULL
);
GO

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
GO

-- 3. Bảng Danh mục sản phẩm (Categories)
CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255) NULL
);
GO

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
GO

-- 5. Bảng Sản phẩm (Products) - Tích hợp đầy đủ ImageUrl
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
GO

-- 6. Bảng Hồ sơ khách hàng (CustomerProfiles - Phục vụ Mục 4.1.5 Báo cáo Độ tuổi & Sở thích)
CREATE TABLE CustomerProfiles (
    ProfileId INT IDENTITY(1,1) PRIMARY KEY,
    AccountId INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Accounts(AccountId) ON DELETE CASCADE,
    Age INT NOT NULL,
    Gender NVARCHAR(10) NULL,
    Address NVARCHAR(255) NULL,
    Interest NVARCHAR(100) NULL
);
GO

-- 7. Bảng Phản hồi & Đánh giá của khách hàng (Feedbacks - Phục vụ Mục 4.1.4 & 4.3.3)
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
GO

-- 8. Bảng Khảo sát sản phẩm mới (Surveys - Phục vụ Mục 4.1.6 & 4.3.4)
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
GO

-- 9. Bảng Kết quả khảo sát của khách hàng (SurveyResponses - Phục vụ Mục 4.1.7 & 4.3.4)
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

-- ========================================================================
-- PHẦN II: NẠP DỮ LIỆU DEMO THEO QUY ĐỊNH CHẤM ĐỒ ÁN (ĐẦY ĐỦ TÀI KHOẢN & GIAO DỊCH)
-- ========================================================================

-- 1. Nạp danh sách quyền (Roles) - CHỈ CÒN 3 ROLE: Admin, Manager, Customer
INSERT INTO Roles (RoleName, Description) VALUES
(N'Admin', N'Quản trị viên máy chủ hệ thống'),
(N'Manager', N'Người quản lý phân hệ CRM'),
(N'Customer', N'Khách hàng mua sắm và đánh giá');

-- 2. Nạp tài khoản test (Tất cả mật khẩu mặc định là: 123456)
INSERT INTO Accounts (Username, PasswordHash, FullName, Email, Phone, RoleId, IsActive, CreatedAt) VALUES
('admin', '123456', N'Quản Trị Viên Hệ Thống', 'admin@sgutech.vn', '0901000001', 1, 1, DATEADD(DAY, -30, GETDATE())),
('quanly', '123456', N'Trần Quản Lý CRM', 'crm.manager@sgutech.vn', '0901000002', 2, 1, DATEADD(DAY, -25, GETDATE())),
('khachhang1', '123456', N'Nguyễn Văn An', 'an.nguyen@gmail.com', '0912345671', 3, 1, DATEADD(DAY, -15, GETDATE())),
('khachhang2', '123456', N'Lê Thị Bình', 'binh.le@gmail.com', '0912345672', 3, 1, DATEADD(DAY, -10, GETDATE())),
('khachhang3', '123456', N'Phạm Minh Châu', 'chau.pham@gmail.com', '0912345673', 3, 1, DATEADD(DAY, -5, GETDATE())),
('khachhang4', '123456', N'Hoàng Đức Dũng', 'dung.hoang@gmail.com', '0912345674', 3, 1, DATEADD(DAY, -2, GETDATE())),
('khachhang5', '123456', N'Võ Ngọc Hân (Tài khoản mẫu đã khóa)', 'han.vo@gmail.com', '0912345675', 3, 0, DATEADD(DAY, -1, GETDATE()));

-- 3. Nạp danh mục sản phẩm (Categories)
INSERT INTO Categories (CategoryName, Description) VALUES
(N'Laptop & Macbook', N'Máy tính xách tay phục vụ học tập, văn phòng và gaming'),
(N'Màn hình máy tính', N'Màn hình chuyên dụng độ phân giải cao và tần số quét cao'),
(N'Bàn phím & Phụ kiện', N'Phụ kiện gaming gear, bàn phím cơ và chuột cao cấp');

-- 4. Nạp nhà cung cấp (Suppliers)
INSERT INTO Suppliers (SupplierCode, SupplierName, ContactName, Phone, Email, Address) VALUES
('NCC001', N'Công ty Phân phối ASUS Việt Nam', N'Ông Minh Hoàng', '02838111222', 'contact@asus.vn', N'Quận 1, TP.HCM'),
('NCC002', N'Công ty TNHH Logitech Đông Nam Á', N'Bà Thanh Thảo', '02838333444', 'sales@logitech.com', N'Quận 3, TP.HCM'),
('NCC003', N'Tập đoàn LG Electronics VN', N'Ông Quốc Bảo', '02838555666', 'b2b@lge.com', N'Quận 7, TP.HCM');

-- 5. Nạp danh mục sản phẩm chi tiết kèm hình ảnh rõ đẹp trực quan
INSERT INTO Products (ProductCode, ProductName, CategoryId, SupplierId, Price, CostPrice, StockQuantity, Unit, Status, ImageUrl) VALUES
('SP001', N'Laptop ASUS ROG Strix G16 (Core i9 / RTX 4070)', 1, 1, 38990000, 33500000, 15, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600&auto=format&fit=crop&q=80'),
('SP002', N'Chuột Gaming Logitech G102 Lightsync RGB', 3, 2, 450000, 320000, 50, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=600&auto=format&fit=crop&q=80'),
('SP003', N'Bộ nhớ RAM Corsair Vengeance RGB DDR5 32GB', 3, 1, 3190000, 2500000, 30, N'Bộ', N'Đang bán', 'https://images.unsplash.com/photo-1562976540-1502c2145186?w=600&auto=format&fit=crop&q=80'),
('SP004', N'Màn hình Gaming LG UltraGear 27 inch 2K 180Hz', 2, 3, 7490000, 6100000, 25, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=600&auto=format&fit=crop&q=80'),
('SP005', N'Ổ cứng SSD Samsung 990 Pro 1TB NVMe PCIe 4.0', 3, 3, 3150000, 2600000, 40, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=600&auto=format&fit=crop&q=80'),
('SP006', N'Router ASUS ROG Rapture GT-AX6000 WiFi 6 Dual-Band', 3, 1, 6890000, 5600000, 10, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?w=600&auto=format&fit=crop&q=80'),
('SP007', N'Chuột Không dây Logitech MX Master 3S Cao cấp', 3, 2, 2490000, 1850000, 35, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=600&auto=format&fit=crop&q=80'),
('SP008', N'Tai nghe Gaming HyperX Cloud II Red Surround 7.1', 3, 2, 1990000, 1500000, 20, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=600&auto=format&fit=crop&q=80'),
('SP009', N'Bàn phím cơ Logitech G Pro X TKL Lightspeed Wireless', 3, 2, 3990000, 3100000, 0, N'Bộ', N'Hết hàng', 'https://images.unsplash.com/photo-1599669454699-248893623440?w=600&auto=format&fit=crop&q=80');

-- 6. Nạp hồ sơ khách hàng (Đầy đủ các phân nhóm độ tuổi <20, 20-30, >30 và sở thích)
INSERT INTO CustomerProfiles (AccountId, Age, Gender, Address, Interest) VALUES
(3, 19, N'Nam', N'273 An Dương Vương, Quận 5, TP.HCM', N'Gaming'),
(4, 24, N'Nữ', N'120 Nguyễn Thị Minh Khai, Quận 3, TP.HCM', N'Văn phòng'),
(5, 28, N'Nam', N'45 Lê Văn Việt, TP. Thủ Đức, TP.HCM', N'Lập trình'),
(6, 35, N'Nam', N'88 Cộng Hòa, Quận Tân Bình, TP.HCM', N'Đồ họa'),
(7, 22, N'Nữ', N'15 Trần Hưng Đạo, Quận 1, TP.HCM', N'Gaming');

-- 7. Nạp dữ liệu Phản hồi & Đánh giá rải đều các ngày gần nhất (Phục vụ biểu đồ theo ngày và độ hài lòng)
INSERT INTO Feedbacks (AccountId, ProductId, Rating, Comment, AdminReply, Status, CreatedAt) VALUES
(3, 1, 5, N'Laptop ROG Strix chạy cực kỳ mượt, tản nhiệt mát mẻ khi chiến game AAA nặng.', N'Cảm ơn bạn đã tin tưởng ủng hộ sản phẩm tại hệ thống SGU Tech!', N'Đã tiếp nhận & Xử lý', DATEADD(DAY, -6, GETDATE())),
(4, 7, 4, N'Chuột MX Master 3S cuộn trang vô cực rất êm tay cho công việc văn phòng.', N'SGU Tech xin cảm ơn đánh giá tích cực từ bạn!', N'Đã tiếp nhận & Xử lý', DATEADD(DAY, -4, GETDATE())),
(5, 4, 5, N'Màn hình LG UltraGear hiển thị chuẩn màu, tần số quét 180Hz chơi game rất sướng.', N'Chúc bạn có những trải nghiệm tuyệt vời cùng sản phẩm!', N'Đã tiếp nhận & Xử lý', DATEADD(DAY, -3, GETDATE())),
(6, 5, 5, N'Tốc độ đọc ghi của SSD Samsung 990 Pro cực nhanh, render video đồ họa tiết kiệm rất nhiều thời gian.', NULL, N'Chờ xử lý', DATEADD(DAY, -2, GETDATE())),
(3, 2, 4, N'Chuột G102 bền bỉ, click nảy tốt, mức giá rất sinh viên.', NULL, N'Chờ xử lý', DATEADD(DAY, -1, GETDATE())),
(4, 1, 5, N'Máy đẹp, cấu hình khủng, nhân viên tư vấn nhiệt tình.', NULL, N'Chờ xử lý', GETDATE());

-- 8. Nạp dữ liệu Khảo sát sản phẩm mới (Bao gồm khảo sát đang mở và khảo sát có thời hạn)
INSERT INTO Surveys (Title, Description, TargetProduct, ExpectedPrice, CreatedAt, IsActive, ExpiresAt) VALUES
(N'Khảo sát nhu cầu dòng Laptop AI Siêu Mỏng Nhẹ 2026', N'Đánh giá nhu cầu trang bị NPU AI chuyên dụng hỗ trợ lập trình viên và sáng tạo nội dung.', N'ASUS Zenbook S16 OLED AI 2026', 36990000, DATEADD(DAY, -5, GETDATE()), 1, DATEADD(DAY, 25, GETDATE())),
(N'Thăm dò Bàn phím cơ Custom Nhôm CNC Không dây', N'Khảo sát mức giá mong muốn cho dòng bàn phím cơ kết nối 3 chế độ không dây độ trễ thấp.', N'Keychron Q1 Max SGU Custom Edition', 4500000, DATEADD(DAY, -3, GETDATE()), 1, NULL),
(N'Khảo sát thử nghiệm Màn hình cong Mini-LED 49 inch (Đã đóng)', N'Chương trình thăm dò giai đoạn thử nghiệm ban đầu.', N'Samsung Odyssey OLED G9', 29900000, DATEADD(DAY, -20, GETDATE()), 0, DATEADD(DAY, -5, GETDATE()));

-- 9. Nạp dữ liệu Kết quả khảo sát mẫu từ khách hàng
INSERT INTO SurveyResponses (SurveyId, AccountId, Score, BuyingIntent, CustomerOpinion, SubmittedAt) VALUES
(1, 3, 5, N'Rất muốn mua', N'Thiết kế cực kỳ sang trọng, nếu có quà tặng kèm chuột không dây và túi chống sốc tôi sẽ đặt trước ngay.', DATEADD(DAY, -4, GETDATE())),
(1, 4, 4, N'Đang cân nhắc', N'Cấu hình chip AI rất ấn tượng nhưng mức giá gần 37 triệu hơi cao đối với nhân viên văn phòng.', DATEADD(DAY, -3, GETDATE())),
(1, 5, 5, N'Rất muốn mua', N'Màn hình OLED 3K và thời lượng pin lâu rất phù hợp cho lập trình, mong cửa hàng hỗ trợ trả góp 0%.', DATEADD(DAY, -2, GETDATE())),
(2, 6, 3, N'Không mua', N'Tôi làm việc kế toán nên cần bàn phím Full-size có cụm phím số Numpad hơn là bản layout 75%.', DATEADD(DAY, -1, GETDATE()));
GO

-- ========================================================================
-- PHẦN III: PHƯƠNG ÁN SAO LƯU & PHỤC HỒI CƠ SỞ DỮ LIỆU (5 ĐIỂM BÁO CÁO & CSDL)
-- ========================================================================
/*
-- 1. KỊCH BẢN SAO LƯU TOÀN PHẦN (FULL BACKUP):
BACKUP DATABASE [HTTTDN_DB]
TO DISK = N'C:\Backup\HTTTDN_DB_Full.bak'
WITH FORMAT, INIT,
     NAME = N'HTTTDN_DB - Full Database Backup',
     SKIP, NOREWIND, NOUNLOAD, STATS = 10;
GO

-- 2. KỊCH BẢN SAO LƯU VI SAI (DIFFERENTIAL BACKUP):
BACKUP DATABASE [HTTTDN_DB]
TO DISK = N'C:\Backup\HTTTDN_DB_Diff.bak'
WITH DIFFERENTIAL,
     NAME = N'HTTTDN_DB - Differential Database Backup',
     SKIP, NOREWIND, NOUNLOAD, STATS = 10;
GO

-- 3. KỊCH BẢN PHỤC HỒI CƠ SỞ DỮ LIỆU (RESTORE DATABASE):
USE master;
ALTER DATABASE [HTTTDN_DB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE [HTTTDN_DB]
FROM DISK = N'C:\Backup\HTTTDN_DB_Full.bak'
WITH REPLACE, RECOVERY;

ALTER DATABASE [HTTTDN_DB] SET MULTI_USER;
GO
*/
