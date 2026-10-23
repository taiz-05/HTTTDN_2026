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

-- 1. Bảng Roles
CREATE TABLE Roles (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(250) NULL
);

-- 2. Bảng Accounts
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

-- 3. Bảng Categories
CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255) NULL
);

-- 4. Bảng Suppliers
CREATE TABLE Suppliers (
    SupplierId INT IDENTITY(1,1) PRIMARY KEY,
    SupplierCode VARCHAR(20) NOT NULL UNIQUE,
    SupplierName NVARCHAR(150) NOT NULL,
    ContactName NVARCHAR(100) NULL,
    Phone VARCHAR(20) NULL,
    Email VARCHAR(100) NULL,
    Address NVARCHAR(255) NULL
);

-- 5. Bảng Products
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
    Status NVARCHAR(50) NOT NULL
);

-- 6. Bảng CustomerProfiles (Mục 4.1.5)
CREATE TABLE CustomerProfiles (
    ProfileId INT IDENTITY(1,1) PRIMARY KEY,
    AccountId INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Accounts(AccountId) ON DELETE CASCADE,
    Age INT NOT NULL,
    Gender NVARCHAR(10) NULL,
    Address NVARCHAR(255) NULL,
    Interest NVARCHAR(100) NULL
);

-- 7. Bảng Feedbacks (Mục 4.1.4 & 4.3.3)
CREATE TABLE Feedbacks (
    FeedbackId INT IDENTITY(1,1) PRIMARY KEY,
    AccountId INT NOT NULL FOREIGN KEY REFERENCES Accounts(AccountId) ON DELETE CASCADE,
    ProductId INT NOT NULL FOREIGN KEY REFERENCES Products(ProductId),
    Rating INT NOT NULL CHECK (Rating >= 1 AND Rating <= 5),
    Comment NVARCHAR(1000) NOT NULL,
    AdminReply NVARCHAR(1000) NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT N'Chờ xử lý',
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

-- 8. Bảng Surveys (Mục 4.1.6 & 4.3.4)
CREATE TABLE Surveys (
    SurveyId INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NULL,
    TargetProduct NVARCHAR(150) NOT NULL,
    ExpectedPrice DECIMAL(18,2) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1
);

-- 9. Bảng SurveyResponses (Mục 4.1.7 & 4.3.4)
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

-- =============================================
-- NẠP DỮ LIỆU DEMO PHONG PHÚ
-- =============================================

INSERT INTO Roles (RoleName, Description) VALUES
(N'Admin', N'Quản trị viên hệ thống Server'),
(N'Manager', N'Người quản lý hệ thống CRM'),
(N'Customer', N'Khách hàng mua sắm và đánh giá'),
(N'Warehouse', N'Nhân viên quản lý kho'),
(N'Sales', N'Nhân viên bán hàng'),
(N'HR', N'Nhân viên quản lý nhân sự');

-- Mật khẩu mặc định '123456'
INSERT INTO Accounts (Username, PasswordHash, FullName, Email, Phone, RoleId, IsActive) VALUES
('admin', '123456', N'Quản Trị Viên Hệ Thống', 'admin@sgutech.vn', '0901000001', 1, 1),
('quanly', '123456', N'Trần Quản Lý CRM', 'crm.manager@sgutech.vn', '0901000002', 2, 1),
('khachhang1', '123456', N'Nguyễn Văn An', 'an.nguyen@gmail.com', '0912345671', 3, 1),
('khachhang2', '123456', N'Lê Thị Bình', 'binh.le@gmail.com', '0912345672', 3, 1),
('khachhang3', '123456', N'Phạm Minh Châu', 'chau.pham@gmail.com', '0912345673', 3, 1),
('khachhang4', '123456', N'Hoàng Đức Dũng', 'dung.hoang@gmail.com', '0912345674', 3, 1),
('khachhang5', '123456', N'Võ Ngọc Hân', 'han.vo@gmail.com', '0912345675', 3, 0); -- Tài khoản mẫu đang bị khóa

INSERT INTO Categories (CategoryName, Description) VALUES
(N'Laptop & Macbook', N'Máy tính xách tay phục vụ học tập, gaming và đồ họa'),
(N'Màn hình máy tính', N'Màn hình chuyên dụng độ phân giải cao'),
(N'Bàn phím & Chuột', N'Phụ kiện gear cao cấp');

INSERT INTO Suppliers (SupplierCode, SupplierName, ContactName, Phone, Email, Address) VALUES
('NCC001', N'Công ty Phân phối ASUS Việt Nam', N'Ông Minh Hoàng', '02838111222', 'contact@asus.vn', N'Quận 1, TP.HCM'),
('NCC002', N'Công ty TNHH Logitech Đông Nam Á', N'Bà Thanh Thảo', '02838333444', 'sales@logitech.com', N'Quận 3, TP.HCM'),
('NCC003', N'Tập đoàn LG Electronics VN', N'Ông Quốc Bảo', '02838555666', 'b2b@lge.com', N'Quận 7, TP.HCM');

INSERT INTO Products (ProductCode, ProductName, CategoryId, SupplierId, Price, CostPrice, StockQuantity, Unit, Status) VALUES
('SP001', N'Laptop ASUS ROG Strix G16', 1, 1, 32990000, 28500000, 15, N'Cái', N'Đang bán'),
('SP002', N'Màn hình LG UltraGear 27 inch 2K 180Hz', 2, 3, 7490000, 6100000, 25, N'Cái', N'Đang bán'),
('SP003', N'Chuột không dây Logitech MX Master 3S', 3, 2, 2490000, 1850000, 40, N'Cái', N'Đang bán'),
('SP004', N'Bàn phím cơ Logitech G Pro X TKL', 3, 2, 3990000, 3100000, 0, N'Bộ', N'Hết hàng');

-- Hồ sơ khách hàng rải đều các độ tuổi (<20, 20-30, >30) và sở thích
INSERT INTO CustomerProfiles (AccountId, Age, Gender, Address, Interest) VALUES
(3, 19, N'Nam', N'273 An Dương Vương, Quận 5, TP.HCM', N'Gaming'),
(4, 24, N'Nữ', N'120 Nguyễn Thị Minh Khai, Quận 3, TP.HCM', N'Văn phòng'),
(5, 28, N'Nam', N'45 Lê Văn Việt, TP. Thủ Đức, TP.HCM', N'Lập trình'),
(6, 35, N'Nam', N'88 Cộng Hòa, Quận Tân Bình, TP.HCM', N'Đồ họa'),
(7, 22, N'Nữ', N'15 Trần Hưng Đạo, Quận 1, TP.HCM', N'Gaming');

-- Dữ liệu Phản hồi sản phẩm
INSERT INTO Feedbacks (AccountId, ProductId, Rating, Comment, AdminReply, Status) VALUES
(3, 1, 5, N'Máy chạy rất mượt, tản nhiệt mát khi chơi game nặng.', N'Cảm ơn bạn đã tin tưởng ủng hộ SGU Tech!', N'Đã tiếp nhận & Xử lý'),
(4, 3, 4, N'Chuột cầm êm tay, cuộn vô cực rất thích nhưng giá hơi cao.', NULL, N'Chờ xử lý'),
(5, 2, 5, N'Màn hình màu sắc chuẩn, tần số quét 180Hz dùng code và giải trí đều tuyệt.', N'SGU Tech rất vui vì bạn hài lòng với sản phẩm!', N'Đã tiếp nhận & Xử lý');

-- Dữ liệu Khảo sát sản phẩm chuẩn bị ra mắt
INSERT INTO Surveys (Title, Description, TargetProduct, ExpectedPrice, IsActive) VALUES
(N'Khảo sát ra mắt Laptop AI Thế hệ mới 2026', N'Đánh giá nhu cầu trang bị chip NPU AI chuyên dụng cho lập trình và đồ họa siêu mỏng nhẹ.', N'ASUS Zenbook S16 OLED AI 2026', 36990000, 1),
(N'Thăm dò bàn phím cơ Custom Không dây', N'Khảo sát mức giá mong muốn cho dòng bàn phím nhôm CNC 3 chế độ kết nối.', N'Keychron Q1 Max SGU Edition', 4500000, 1);

-- Dữ liệu Kết quả khảo sát mẫu
INSERT INTO SurveyResponses (SurveyId, AccountId, Score, BuyingIntent, CustomerOpinion) VALUES
(1, 3, 5, N'Rất muốn mua', N'Thiết kế quá đẹp, nếu tặng kèm balo và chuột không dây ở mức giá 35 triệu tôi sẽ đặt cọc ngay.'),
(1, 4, 4, N'Đang cân nhắc', N'Cấu hình tốt nhưng mức giá 36.990.000đ hơi cao so với sinh viên và nhân viên văn phòng.'),
(1, 5, 5, N'Rất muốn mua', N'Pin lâu và màn OLED rất hợp để code, mong có chương trình trả góp 0%.'),
(2, 6, 3, N'Không mua', N'Tôi thích bàn phím full-size có cụm phím số Numpad hơn bản 75%.');
GO