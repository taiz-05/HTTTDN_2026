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
-- PHẦN II: NẠP DỮ LIỆU DEMO DOANH NGHIỆP PHONG PHÚ (22 TÀI KHOẢN, 16 SẢN PHẨM, 18 PHẢN HỒI, 5 KHẢO SÁT)
-- ========================================================================

-- 1. Nạp danh sách quyền (Roles) - CHỈ CÒN 3 ROLE: Admin, Manager, Customer
INSERT INTO Roles (RoleName, Description) VALUES
(N'Admin', N'Quản trị viên máy chủ hệ thống'),
(N'Manager', N'Người quản lý phân hệ CRM'),
(N'Customer', N'Khách hàng mua sắm và đánh giá');

-- 2. Nạp tài khoản test (Tất cả mật khẩu mặc định: 123456)
INSERT INTO Accounts (Username, PasswordHash, FullName, Email, Phone, RoleId, IsActive, CreatedAt) VALUES
('admin', '123456', N'Nguyễn Quản Trị Hệ Thống', 'admin@sgutech.vn', '0901000001', 1, 1, DATEADD(DAY, -60, GETDATE())),
('admin2', '123456', N'Lê Hoàng Nam (Bảo mật IT)', 'nam.le@sgutech.vn', '0901000003', 1, 1, DATEADD(DAY, -45, GETDATE())),
('quanly', '123456', N'Trần Trưởng Phòng CRM', 'crm.manager@sgutech.vn', '0901000002', 2, 1, DATEADD(DAY, -55, GETDATE())),
('quanly_cskh', '123456', N'Nguyễn Thu Trang (Phó phòng CSKH)', 'trang.nguyen@sgutech.vn', '0901000004', 2, 1, DATEADD(DAY, -40, GETDATE())),
('khachhang1', '123456', N'Nguyễn Văn An', 'an.nguyen@gmail.com', '0912345671', 3, 1, DATEADD(DAY, -25, GETDATE())),
('khachhang2', '123456', N'Lê Thị Bình', 'binh.le@gmail.com', '0912345672', 3, 1, DATEADD(DAY, -22, GETDATE())),
('khachhang3', '123456', N'Phạm Minh Châu', 'chau.pham@gmail.com', '0912345673', 3, 1, DATEADD(DAY, -20, GETDATE())),
('khachhang4', '123456', N'Hoàng Đức Dũng', 'dung.hoang@gmail.com', '0912345674', 3, 1, DATEADD(DAY, -18, GETDATE())),
('khachhang5', '123456', N'Võ Ngọc Hân (Tài khoản vi phạm - Đã khóa)', 'han.vo@gmail.com', '0912345675', 3, 0, DATEADD(DAY, -16, GETDATE())),
('khachhang6', '123456', N'Trần Quốc Bảo', 'bao.tran@gmail.com', '0912345676', 3, 1, DATEADD(DAY, -14, GETDATE())),
('khachhang7', '123456', N'Đặng Thúy Kiều', 'kieu.dang@gmail.com', '0912345677', 3, 1, DATEADD(DAY, -12, GETDATE())),
('khachhang8', '123456', N'Vũ Tuấn Kiệt', 'kiet.vu@gmail.com', '0912345678', 3, 1, DATEADD(DAY, -10, GETDATE())),
('khachhang9', '123456', N'Bùi Quỳnh Chi', 'chi.bui@gmail.com', '0912345679', 3, 1, DATEADD(DAY, -8, GETDATE())),
('khachhang10', '123456', N'Đỗ Hoàng Long', 'long.do@gmail.com', '0912345680', 3, 1, DATEADD(DAY, -7, GETDATE())),
('khachhang11', '123456', N'Ngô Phương Thảo', 'thao.ngo@gmail.com', '0912345681', 3, 1, DATEADD(DAY, -5, GETDATE())),
('khachhang12', '123456', N'Trịnh Gia Huy', 'huy.trinh@gmail.com', '0912345682', 3, 1, DATEADD(DAY, -4, GETDATE())),
('khachhang13', '123456', N'Mai Anh Tuấn', 'tuan.mai@gmail.com', '0912345683', 3, 1, DATEADD(DAY, -3, GETDATE())),
('khachhang14', '123456', N'Dương Hoàng Yến', 'yen.duong@gmail.com', '0912345684', 3, 1, DATEADD(DAY, -2, GETDATE())),
('khachhang15', '123456', N'Phan Thành Đạt (Tạm ngưng giao dịch)', 'dat.phan@gmail.com', '0912345685', 3, 0, DATEADD(DAY, -1, GETDATE()));

-- 3. Nạp danh mục sản phẩm (Categories)
INSERT INTO Categories (CategoryName, Description) VALUES
(N'Laptop & Máy tính xách tay', N'Dòng máy phục vụ học tập, văn phòng, đồ họa và gaming đỉnh cao'),
(N'Màn hình chuyên dụng', N'Màn hình độ phân giải cao 2K/4K/5K và tần số quét cao lên đến 180Hz'),
(N'Bàn phím & Chuột cao cấp', N'Bàn phím cơ Custom, chuột công thái học và phụ kiện gaming gear'),
(N'Linh kiện & Lưu trữ tốc độ cao', N'Ổ cứng SSD NVMe Gen 4, RAM DDR5 tản nhiệt và Card đồ họa'),
(N'Thiết bị mạng & Phụ kiện AI', N'Router WiFi 6 công suất lớn, Webcam 4K và thiết bị truyền phát');

-- 4. Nạp nhà cung cấp (Suppliers)
INSERT INTO Suppliers (SupplierCode, SupplierName, ContactName, Phone, Email, Address) VALUES
('NCC001', N'Công ty TNHH ASUS Việt Nam', N'Ông Minh Hoàng', '02838111222', 'contact@asus.vn', N'Quận 1, TP.HCM'),
('NCC002', N'Công ty TNHH Logitech Đông Nam Á', N'Bà Thanh Thảo', '02838333444', 'sales@logitech.com', N'Quận 3, TP.HCM'),
('NCC003', N'Tập đoàn LG Electronics Việt Nam', N'Ông Quốc Bảo', '02838555666', 'b2b@lge.com', N'Quận 7, TP.HCM'),
('NCC004', N'Công ty Cổ phần Synnex FPT', N'Bà Ngọc Trâm', '02873006666', 'distribution@synnexfpt.com', N'Quận Bình Thạnh, TP.HCM'),
('NCC005', N'Tập đoàn Sony Electronics Việt Nam', N'Ông Quang Huy', '02838449999', 'support@sony.com.vn', N'Quận Tân Bình, TP.HCM'),
('NCC006', N'Công ty TNHH Điện tử Samsung Vina', N'Bà Phương Linh', '02839157310', 'b2b.vietnam@samsung.com', N'Quận 1, TP.HCM');

-- 5. Nạp danh mục sản phẩm chi tiết kèm hình ảnh rõ đẹp trực quan
INSERT INTO Products (ProductCode, ProductName, CategoryId, SupplierId, Price, CostPrice, StockQuantity, Unit, Status, ImageUrl) VALUES
('SP001', N'Laptop ASUS ROG Strix G16 (Core i9-14900HX / RTX 4070)', 1, 1, 38990000, 33500000, 15, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600&auto=format&fit=crop&q=80'),
('SP002', N'Laptop Apple MacBook Pro 14 M3 Pro (18GB / 512GB SSD)', 1, 4, 49990000, 44000000, 8, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&auto=format&fit=crop&q=80'),
('SP003', N'Màn hình Gaming LG UltraGear 27 inch 2K 180Hz 1ms IPS', 2, 3, 7490000, 6100000, 25, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=600&auto=format&fit=crop&q=80'),
('SP004', N'Màn hình đồ họa ASUS ProArt 27 inch 4K HDR IPS', 2, 1, 12890000, 10500000, 12, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1585792180666-f7347c490ee2?w=600&auto=format&fit=crop&q=80'),
('SP005', N'Bàn phím cơ Custom Keychron Q1 Max Nhôm CNC Không dây', 3, 4, 4590000, 3700000, 20, N'Bộ', N'Đang bán', 'https://images.unsplash.com/photo-1595225476474-87563907a212?w=600&auto=format&fit=crop&q=80'),
('SP006', N'Bàn phím cơ Gaming Logitech G Pro X TKL Lightspeed Wireless', 3, 2, 3990000, 3100000, 0, N'Bộ', N'Hết hàng', 'https://images.unsplash.com/photo-1599669454699-248893623440?w=600&auto=format&fit=crop&q=80'),
('SP007', N'Chuột không dây công thái học Logitech MX Master 3S', 3, 2, 2490000, 1850000, 40, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=600&auto=format&fit=crop&q=80'),
('SP008', N'Chuột Gaming Logitech G102 Lightsync RGB Gen 2', 3, 2, 450000, 320000, 60, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=600&auto=format&fit=crop&q=80'),
('SP009', N'Tai nghe Gaming HyperX Cloud II Red Surround 7.1', 3, 4, 1990000, 1500000, 30, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=600&auto=format&fit=crop&q=80'),
('SP010', N'Tai nghe chống ồn không dây Sony WH-1000XM5 Hi-Res', 3, 5, 6990000, 5700000, 15, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=600&auto=format&fit=crop&q=80'),
('SP011', N'Ổ cứng SSD Samsung 990 Pro 2TB NVMe PCIe Gen 4.0', 4, 6, 4690000, 3800000, 35, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=600&auto=format&fit=crop&q=80'),
('SP012', N'Router WiFi 6 Gaming ASUS ROG Rapture GT-AX6000', 5, 1, 6890000, 5600000, 10, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?w=600&auto=format&fit=crop&q=80'),
('SP013', N'Màn hình chuyên đồ họa Dell UltraSharp 32 inch 4K IPS Black', 2, 4, 19890000, 16800000, 9, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=600&auto=format&fit=crop&q=80'),
('SP014', N'Bộ nhớ RAM Corsair Vengeance RGB DDR5 64GB (2x32GB) 6000MHz', 4, 4, 5490000, 4300000, 22, N'Bộ', N'Đang bán', 'https://images.unsplash.com/photo-1562976540-1502c2145186?w=600&auto=format&fit=crop&q=80'),
('SP015', N'Card đồ họa ASUS TUF Gaming GeForce RTX 4080 Super 16GB', 4, 1, 29990000, 25500000, 5, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=600&auto=format&fit=crop&q=80'),
('SP016', N'Webcam 4K Sony Bravia Cam Pro Hội nghị & Livestream', 5, 5, 5290000, 4100000, 14, N'Cái', N'Đang bán', 'https://images.unsplash.com/photo-1588508065123-287b28e013da?w=600&auto=format&fit=crop&q=80');

-- 6. Nạp 15 hồ sơ khách hàng đầy đủ nhân khẩu học (Độ tuổi & Sở thích)
INSERT INTO CustomerProfiles (AccountId, Age, Gender, Address, Interest) VALUES
(8, 19, N'Nam', N'273 An Dương Vương, Quận 5, TP.HCM', N'Gaming'),
(9, 24, N'Nữ', N'120 Nguyễn Thị Minh Khai, Quận 3, TP.HCM', N'Văn phòng'),
(10, 28, N'Nam', N'45 Lê Văn Việt, TP. Thủ Đức, TP.HCM', N'Lập trình'),
(11, 35, N'Nam', N'88 Cộng Hòa, Quận Tân Bình, TP.HCM', N'Đồ họa'),
(12, 22, N'Nữ', N'15 Trần Hưng Đạo, Quận 1, TP.HCM', N'Gaming'),
(13, 31, N'Nam', N'102 Võ Văn Ngân, TP. Thủ Đức, TP.HCM', N'Văn phòng'),
(14, 18, N'Nữ', N'334 Nguyễn Trãi, Quận 5, TP.HCM', N'Gaming'),
(15, 42, N'Nam', N'56 Điện Biên Phủ, Quận Bình Thạnh, TP.HCM', N'Lập trình'),
(16, 26, N'Nữ', N'182 Hai Bà Trưng, Quận 1, TP.HCM', N'Đồ họa'),
(17, 29, N'Nam', N'65 Hoàng Hoa Thám, Quận Phú Nhuận, TP.HCM', N'Gaming'),
(18, 23, N'Nữ', N'210 Cách Mạng Tháng 8, Quận 10, TP.HCM', N'Văn phòng'),
(19, 19, N'Nam', N'99 Nguyễn Tri Phương, Quận 5, TP.HCM', N'Lập trình'),
(20, 38, N'Nam', N'14 Phan Xích Long, Quận Phú Nhuận, TP.HCM', N'Đồ họa'),
(21, 25, N'Nữ', N'72 Ba Tháng Hai, Quận 10, TP.HCM', N'Văn phòng'),
(22, 45, N'Nam', N'415 Lê Hồng Phong, Quận 5, TP.HCM', N'Gaming');

-- 7. Nạp 18 dữ liệu Phản hồi & Đánh giá rải đều các mức sao (1-5 sao)
INSERT INTO Feedbacks (AccountId, ProductId, Rating, Comment, AdminReply, Status, CreatedAt) VALUES
(8, 1, 5, N'Laptop ROG Strix chạy cực kỳ mượt, tản nhiệt mát mẻ khi chiến game AAA nặng ở độ phân giải 2K.', N'Cảm ơn bạn đã tin tưởng ủng hộ sản phẩm chính hãng tại hệ thống SGU Tech!', N'Đã tiếp nhận & Xử lý', DATEADD(DAY, -10, GETDATE())),
(9, 7, 4, N'Chuột MX Master 3S cuộn trang vô cực rất êm tay cho công việc văn phòng, pin dùng cả tháng.', N'SGU Tech xin cảm ơn đánh giá tích cực từ bạn!', N'Đã tiếp nhận & Xử lý', DATEADD(DAY, -9, GETDATE())),
(10, 3, 5, N'Màn hình LG UltraGear hiển thị chuẩn màu, tần số quét 180Hz chơi game và làm việc rất sướng mắt.', N'Chúc bạn có những trải nghiệm tuyệt vời cùng sản phẩm!', N'Đã tiếp nhận & Xử lý', DATEADD(DAY, -8, GETDATE())),
(11, 11, 5, N'Tốc độ đọc ghi của SSD Samsung 990 Pro cực nhanh, render video đồ họa 4K tiết kiệm rất nhiều thời gian.', N'Cảm ơn bạn! Dòng Samsung 990 Pro là đỉnh nhất hiện nay ạ.', N'Đã tiếp nhận & Xử lý', DATEADD(DAY, -7, GETDATE())),
(16, 13, 5, N'Màn hình Dell UltraSharp 32 4K IPS Black màu đen sâu, độ phủ màu chuẩn DCI-P3 98% rất đáng tiền cho dân thiết kế.', N'Dòng UltraSharp IPS Black chuyên dụng cho đồ họa cao cấp luôn được hỗ trợ bảo hành đổi mới 3 năm bạn nhé!', N'Đã tiếp nhận & Xử lý', DATEADD(DAY, -6, GETDATE())),
(17, 5, 5, N'Bàn phím Keychron Q1 Max gõ đầm tay, âm thanh thock trầm rất êm, kết nối không dây 2.4Ghz cực nhạy.', N'Cảm ơn bạn đã lựa chọn phiên bản phím cơ nhôm CNC cao cấp tại SGU Tech!', N'Đã tiếp nhận & Xử lý', DATEADD(DAY, -5, GETDATE())),
(18, 2, 5, N'MacBook Pro 14 M3 Pro pin trâu kinh khủng, dùng cả ngày không cần cắm sạc, màn hình Liquid Retina XDR tuyệt đẹp.', N'Cảm ơn chị đã mua hàng chính hãng Apple tại SGU Tech!', N'Đã tiếp nhận & Xử lý', DATEADD(DAY, -5, GETDATE())),
(8, 8, 4, N'Chuột G102 bền bỉ, click nảy tốt, mức giá rất vừa túi tiền sinh viên.', NULL, N'Chờ xử lý', DATEADD(DAY, -4, GETDATE())),
(14, 9, 4, N'Tai nghe HyperX Cloud II đeo êm tai không bị cấn, mic lọc ồn tốt khi đàm thoại.', NULL, N'Chờ xử lý', DATEADD(DAY, -4, GETDATE())),
(15, 4, 3, N'Màn hình ProArt màu đẹp nhưng viền hơi dày hơn mong đợi một chút.', NULL, N'Chờ xử lý', DATEADD(DAY, -3, GETDATE())),
(19, 14, 5, N'RAM Corsair DDR5 64GB mở hàng chục máy ảo Docker chạy mượt mà, LED RGB đồng bộ iCUE đẹp mắt.', NULL, N'Chờ xử lý', DATEADD(DAY, -3, GETDATE())),
(20, 16, 4, N'Webcam Sony 4K nét căng, tự động lấy nét khuôn mặt khi họp online rất tiện lợi.', NULL, N'Chờ xử lý', DATEADD(DAY, -2, GETDATE())),
(10, 1, 5, N'Máy đẹp, cấu hình khủng, nhân viên tư vấn SGU Tech rất nhiệt tình hỗ trợ cài đặt ban đầu.', NULL, N'Chờ xử lý', DATEADD(DAY, -2, GETDATE())),
(17, 6, 2, N'Bàn phím G Pro X gõ tốt nhưng âm thanh clicky của switch hơi ồn khi làm việc ban đêm.', N'Dòng G Pro X dùng switch cơ chuyên cho game thủ nên tiếng clicky khá đanh, bạn có thể ghé showroom SGU Tech để đổi sang phiên bản switch Linear êm hơn nhé!', N'Đã tiếp nhận & Xử lý', DATEADD(DAY, -2, GETDATE())),
(21, 12, 4, N'Router Asus phát sóng xuyên tường 2 tầng lầu vẫn bắt được sóng WiFi 6 mạnh mẽ.', NULL, N'Chờ xử lý', DATEADD(DAY, -1, GETDATE())),
(9, 10, 5, N'Chống ồn của Sony XM5 thực sự đỉnh cao, đi xe buýt hay máy bay bật lên là yên tĩnh hoàn toàn.', NULL, N'Chờ xử lý', DATEADD(DAY, -1, GETDATE())),
(11, 15, 1, N'Card đồ họa RTX 4080 Super giao đến bị cấn một góc hộp bìa carton bên ngoài do vận chuyển.', N'SGU Tech chân thành xin lỗi anh về sự cố khâu vận chuyển! Quản lý kho đã liên hệ và đổi mới nguyên seal cho anh ngay trong hôm nay ạ.', N'Đã tiếp nhận & Xử lý', GETDATE()),
(8, 11, 5, N'Mua chiếc SSD thứ hai gắn thêm cho laptop ROG, tốc độ ổn định nhiệt độ chỉ 45 độ C.', NULL, N'Chờ xử lý', GETDATE());

-- 8. Nạp 5 dữ liệu Khảo sát sản phẩm mới
INSERT INTO Surveys (Title, Description, TargetProduct, ExpectedPrice, CreatedAt, IsActive, ExpiresAt) VALUES
(N'Khảo sát nhu cầu dòng Laptop AI Siêu Mỏng Nhẹ 2026', N'Đánh giá nhu cầu trang bị chip NPU AI chuyên dụng hỗ trợ lập trình viên và sáng tạo nội dung đa nhiệm.', N'ASUS Zenbook S16 OLED AI 2026', 36990000, DATEADD(DAY, -10, GETDATE()), 1, DATEADD(DAY, 20, GETDATE())),
(N'Thăm dò Bàn phím cơ Custom Nhôm CNC Không dây', N'Khảo sát mức giá mong muốn cho dòng bàn phím cơ kết nối 3 chế độ không dây độ trễ thấp.', N'Keychron Q1 Max SGU Custom Edition', 4500000, DATEADD(DAY, -8, GETDATE()), 1, NULL),
(N'Thăm dò Tai nghe chống ồn Hi-Res Thế hệ Mới', N'Khảo sát tính năng khử tiếng ồn chủ động bằng AI và thời lượng pin 40 giờ.', N'Sony WH-1000XM6 Edition 2026', 7990000, DATEADD(DAY, -5, GETDATE()), 1, DATEADD(DAY, 10, GETDATE())),
(N'Khảo sát Màn hình Đồ họa 5K Chuyên Dụng Cho Designer', N'Khảo sát nhu cầu trang bị màn hình 5K độ phân giải siêu nét dành cho giới làm đồ họa chuyên nghiệp.', N'Dell UltraSharp 32 5K HDR', 24500000, DATEADD(DAY, -3, GETDATE()), 1, DATEADD(DAY, 15, GETDATE())),
(N'Khảo sát thử nghiệm Màn hình cong Mini-LED 49 inch (Đã đóng)', N'Chương trình thăm dò giai đoạn thử nghiệm ban đầu.', N'Samsung Odyssey OLED G9', 29900000, DATEADD(DAY, -25, GETDATE()), 0, DATEADD(DAY, -5, GETDATE()));

-- 9. Nạp 16 kết quả khảo sát mẫu phong phú
INSERT INTO SurveyResponses (SurveyId, AccountId, Score, BuyingIntent, CustomerOpinion, SubmittedAt) VALUES
(1, 8, 5, N'Rất muốn mua', N'Thiết kế cực kỳ sang trọng, nếu có quà tặng kèm chuột không dây và túi chống sốc tôi sẽ đặt trước ngay.', DATEADD(DAY, -9, GETDATE())),
(1, 9, 4, N'Đang cân nhắc', N'Cấu hình chip AI rất ấn tượng nhưng mức giá gần 37 triệu hơi cao đối với nhân viên văn phòng.', DATEADD(DAY, -7, GETDATE())),
(1, 10, 5, N'Rất muốn mua', N'Màn hình OLED 3K và thời lượng pin lâu rất phù hợp cho lập trình viên, mong cửa hàng hỗ trợ trả góp 0%.', DATEADD(DAY, -6, GETDATE())),
(1, 13, 5, N'Rất muốn mua', N'Máy rất nhẹ phù hợp đi công tác xa, tôi sẵn sàng đặt cọc trước.', DATEADD(DAY, -4, GETDATE())),
(1, 15, 3, N'Không mua', N'Tôi quen dùng máy tính bàn cấu hình cao hơn là laptop mỏng nhẹ.', DATEADD(DAY, -3, GETDATE())),
(1, 18, 4, N'Đang cân nhắc', N'Chờ xem bản thực tế ngoài showroom SGU Tech rồi sẽ quyết định mua.', DATEADD(DAY, -2, GETDATE())),
(2, 11, 4, N'Đang cân nhắc', N'Bản nhôm CNC rất đầm, nếu shop có sẵn switch tactile tôi sẽ mua ngay.', DATEADD(DAY, -5, GETDATE())),
(2, 8, 5, N'Rất muốn mua', N'Mức giá 4.5 triệu cho bản Q1 Max là quá hợp lý trong phân khúc phím nhôm.', DATEADD(DAY, -4, GETDATE())),
(2, 17, 5, N'Rất muốn mua', N'Sẵn sàng mua ngay khi mở bán đợt đầu, mong có màu đen nhám Anodized.', DATEADD(DAY, -3, GETDATE())),
(2, 19, 3, N'Không mua', N'Đã có bàn phím cơ rồi nên chưa có nhu cầu mua thêm.', DATEADD(DAY, -1, GETDATE())),
(3, 9, 4, N'Đang cân nhắc', N'Nếu trọng lượng nhẹ hơn bản XM5 và đệm tai êm hơn tôi sẽ nâng cấp.', DATEADD(DAY, -3, GETDATE())),
(3, 14, 5, N'Rất muốn mua', N'Nếu chống ồn AI tốt hơn XM5 thì 8 triệu là mức giá chấp nhận được.', DATEADD(DAY, -2, GETDATE())),
(3, 16, 4, N'Đang cân nhắc', N'Mong đợi chất âm ấm và microphone đàm thoại rõ ràng hơn.', DATEADD(DAY, -1, GETDATE())),
(4, 11, 5, N'Rất muốn mua', N'Độ phân giải 5K rất cần cho biên tập ảnh và video, mức giá 24.5 triệu rất cạnh tranh với Apple Studio Display.', DATEADD(DAY, -2, GETDATE())),
(4, 16, 5, N'Rất muốn mua', N'Nếu có chân đế xoay dọc công thái học và cổng sạc Thunderbolt 4 thì hoàn hảo.', DATEADD(DAY, -1, GETDATE())),
(4, 20, 4, N'Đang cân nhắc', N'Cần kiểm tra độ tương phản thực tế tại showroom SGU Tech.', GETDATE());
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

