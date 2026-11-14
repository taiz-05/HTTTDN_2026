using HTTTDN.AdminApi.Models;
using Microsoft.EntityFrameworkCore;

namespace HTTTDN.AdminApi.Data
{
    public static class DbInitializer
    {
        public static void Initialize(AppDbContext context)
        {
            context.Database.EnsureCreated();

            // Luôn kiểm tra và dọn dẹp các vai trò không còn sử dụng (Warehouse, Sales, HR)
            var obsoleteRoles = context.Roles.Where(r => r.RoleName == "Warehouse" || r.RoleName == "Sales" || r.RoleName == "HR").ToList();
            if (obsoleteRoles.Any())
            {
                var obsoleteRoleIds = obsoleteRoles.Select(r => r.RoleId).ToList();
                var obsoleteAccounts = context.Accounts.Where(a => obsoleteRoleIds.Contains(a.RoleId)).ToList();
                if (obsoleteAccounts.Any())
                {
                    context.Accounts.RemoveRange(obsoleteAccounts);
                }
                context.Roles.RemoveRange(obsoleteRoles);
                context.SaveChanges();
            }

            // Nếu dữ liệu đã đủ phong phú (>= 16 sản phẩm và >= 15 tài khoản) và đúng 3 roles thì không nạp lại
            if (context.Products.Count() >= 16 && context.Accounts.Count() >= 15 && context.Feedbacks.Count() >= 14 && context.Roles.Count() == 3) return;

            // Xóa dữ liệu cũ để đồng bộ sạch sẽ toàn bộ tiêu chí
            if (context.SurveyResponses.Any()) context.SurveyResponses.RemoveRange(context.SurveyResponses);
            if (context.Surveys.Any()) context.Surveys.RemoveRange(context.Surveys);
            if (context.Feedbacks.Any()) context.Feedbacks.RemoveRange(context.Feedbacks);
            if (context.CustomerProfiles.Any()) context.CustomerProfiles.RemoveRange(context.CustomerProfiles);
            if (context.Products.Any()) context.Products.RemoveRange(context.Products);
            if (context.Suppliers.Any()) context.Suppliers.RemoveRange(context.Suppliers);
            if (context.Categories.Any()) context.Categories.RemoveRange(context.Categories);
            if (context.Accounts.Any()) context.Accounts.RemoveRange(context.Accounts);
            if (context.Roles.Any()) context.Roles.RemoveRange(context.Roles);
            context.SaveChanges();

            // 1. Khởi tạo danh sách Roles: CHỈ CÒN 3 ROLE: Admin, Manager, Customer
            var roles = new List<Role>
            {
                new Role { RoleName = "Admin", Description = "Quản trị viên máy chủ hệ thống" },
                new Role { RoleName = "Manager", Description = "Người quản lý phân hệ CRM" },
                new Role { RoleName = "Customer", Description = "Khách hàng mua sắm và đánh giá" }
            };
            context.Roles.AddRange(roles);
            context.SaveChanges();

            var adminRole = roles.First(r => r.RoleName == "Admin");
            var managerRole = roles.First(r => r.RoleName == "Manager");
            var customerRole = roles.First(r => r.RoleName == "Customer");

            // 2. Khởi tạo danh sách Tài khoản mẫu phong phú (Mật khẩu: 123456)
            var accounts = new List<Account>
            {
                // Cán bộ Quản trị & Nghiệp vụ nội bộ (Admin & Manager)
                new Account { Username = "admin", PasswordHash = "123456", FullName = "Nguyễn Quản Trị Hệ Thống", Email = "admin@sgutech.vn", Phone = "0901000001", RoleId = adminRole.RoleId, IsActive = true, CreatedAt = DateTime.Now.AddDays(-60) },
                new Account { Username = "admin2", PasswordHash = "123456", FullName = "Lê Hoàng Nam (Bảo mật IT)", Email = "nam.le@sgutech.vn", Phone = "0901000003", RoleId = adminRole.RoleId, IsActive = true, CreatedAt = DateTime.Now.AddDays(-45) },
                new Account { Username = "quanly", PasswordHash = "123456", FullName = "Trần Trưởng Phòng CRM", Email = "crm.manager@sgutech.vn", Phone = "0901000002", RoleId = managerRole.RoleId, IsActive = true, CreatedAt = DateTime.Now.AddDays(-55) },
                new Account { Username = "quanly_cskh", PasswordHash = "123456", FullName = "Nguyễn Thu Trang (Phó phòng CSKH)", Email = "trang.nguyen@sgutech.vn", Phone = "0901000004", RoleId = managerRole.RoleId, IsActive = true, CreatedAt = DateTime.Now.AddDays(-40) },

                // 15 Khách hàng thành viên phân bố độ tuổi & sở thích
                new Account { Username = "khachhang1", PasswordHash = "123456", FullName = "Nguyễn Văn An", Email = "an.nguyen@gmail.com", Phone = "0912345671", RoleId = customerRole.RoleId, IsActive = true, CreatedAt = DateTime.Now.AddDays(-25) },
                new Account { Username = "khachhang2", PasswordHash = "123456", FullName = "Lê Thị Bình", Email = "binh.le@gmail.com", Phone = "0912345672", RoleId = customerRole.RoleId, IsActive = true, CreatedAt = DateTime.Now.AddDays(-22) },
                new Account { Username = "khachhang3", PasswordHash = "123456", FullName = "Phạm Minh Châu", Email = "chau.pham@gmail.com", Phone = "0912345673", RoleId = customerRole.RoleId, IsActive = true, CreatedAt = DateTime.Now.AddDays(-20) },
                new Account { Username = "khachhang4", PasswordHash = "123456", FullName = "Hoàng Đức Dũng", Email = "dung.hoang@gmail.com", Phone = "0912345674", RoleId = customerRole.RoleId, IsActive = true, CreatedAt = DateTime.Now.AddDays(-18) },
                new Account { Username = "khachhang5", PasswordHash = "123456", FullName = "Võ Ngọc Hân (Tài khoản vi phạm - Đã khóa)", Email = "han.vo@gmail.com", Phone = "0912345675", RoleId = customerRole.RoleId, IsActive = false, CreatedAt = DateTime.Now.AddDays(-16) },
                new Account { Username = "khachhang6", PasswordHash = "123456", FullName = "Trần Quốc Bảo", Email = "bao.tran@gmail.com", Phone = "0912345676", RoleId = customerRole.RoleId, IsActive = true, CreatedAt = DateTime.Now.AddDays(-14) },
                new Account { Username = "khachhang7", PasswordHash = "123456", FullName = "Đặng Thúy Kiều", Email = "kieu.dang@gmail.com", Phone = "0912345677", RoleId = customerRole.RoleId, IsActive = true, CreatedAt = DateTime.Now.AddDays(-12) },
                new Account { Username = "khachhang8", PasswordHash = "123456", FullName = "Vũ Tuấn Kiệt", Email = "kiet.vu@gmail.com", Phone = "0912345678", RoleId = customerRole.RoleId, IsActive = true, CreatedAt = DateTime.Now.AddDays(-10) },
                new Account { Username = "khachhang9", PasswordHash = "123456", FullName = "Bùi Quỳnh Chi", Email = "chi.bui@gmail.com", Phone = "0912345679", RoleId = customerRole.RoleId, IsActive = true, CreatedAt = DateTime.Now.AddDays(-8) },
                new Account { Username = "khachhang10", PasswordHash = "123456", FullName = "Đỗ Hoàng Long", Email = "long.do@gmail.com", Phone = "0912345680", RoleId = customerRole.RoleId, IsActive = true, CreatedAt = DateTime.Now.AddDays(-7) },
                new Account { Username = "khachhang11", PasswordHash = "123456", FullName = "Ngô Phương Thảo", Email = "thao.ngo@gmail.com", Phone = "0912345681", RoleId = customerRole.RoleId, IsActive = true, CreatedAt = DateTime.Now.AddDays(-5) },
                new Account { Username = "khachhang12", PasswordHash = "123456", FullName = "Trịnh Gia Huy", Email = "huy.trinh@gmail.com", Phone = "0912345682", RoleId = customerRole.RoleId, IsActive = true, CreatedAt = DateTime.Now.AddDays(-4) },
                new Account { Username = "khachhang13", PasswordHash = "123456", FullName = "Mai Anh Tuấn", Email = "tuan.mai@gmail.com", Phone = "0912345683", RoleId = customerRole.RoleId, IsActive = true, CreatedAt = DateTime.Now.AddDays(-3) },
                new Account { Username = "khachhang14", PasswordHash = "123456", FullName = "Dương Hoàng Yến", Email = "yen.duong@gmail.com", Phone = "0912345684", RoleId = customerRole.RoleId, IsActive = true, CreatedAt = DateTime.Now.AddDays(-2) },
                new Account { Username = "khachhang15", PasswordHash = "123456", FullName = "Phan Thành Đạt (Tạm ngưng giao dịch)", Email = "dat.phan@gmail.com", Phone = "0912345685", RoleId = customerRole.RoleId, IsActive = false, CreatedAt = DateTime.Now.AddDays(-1) }
            };
            context.Accounts.AddRange(accounts);
            context.SaveChanges();

            var customers = accounts.Where(a => a.RoleId == customerRole.RoleId).ToList();

            // 3. Khởi tạo danh mục sản phẩm (Categories)
            var categories = new List<Category>
            {
                new Category { CategoryName = "Laptop & Máy tính xách tay", Description = "Dòng máy phục vụ học tập, văn phòng, đồ họa và gaming đỉnh cao" },
                new Category { CategoryName = "Màn hình chuyên dụng", Description = "Màn hình độ phân giải cao 2K/4K/5K và tần số quét cao lên đến 180Hz" },
                new Category { CategoryName = "Bàn phím & Chuột cao cấp", Description = "Bàn phím cơ Custom, chuột công thái học và phụ kiện gaming gear" },
                new Category { CategoryName = "Linh kiện & Lưu trữ tốc độ cao", Description = "Ổ cứng SSD NVMe Gen 4, RAM DDR5 tản nhiệt và Card đồ họa" },
                new Category { CategoryName = "Thiết bị mạng & Phụ kiện AI", Description = "Router WiFi 6 công suất lớn, Webcam 4K và thiết bị truyền phát" }
            };
            context.Categories.AddRange(categories);
            context.SaveChanges();

            // 4. Khởi tạo 6 nhà cung cấp (Suppliers)
            var suppliers = new List<Supplier>
            {
                new Supplier { SupplierCode = "NCC001", SupplierName = "Công ty TNHH ASUS Việt Nam", ContactName = "Ông Minh Hoàng", Phone = "02838111222", Email = "contact@asus.vn", Address = "Quận 1, TP.HCM" },
                new Supplier { SupplierCode = "NCC002", SupplierName = "Công ty TNHH Logitech Đông Nam Á", ContactName = "Bà Thanh Thảo", Phone = "02838333444", Email = "sales@logitech.com", Address = "Quận 3, TP.HCM" },
                new Supplier { SupplierCode = "NCC003", SupplierName = "Tập đoàn LG Electronics Việt Nam", ContactName = "Ông Quốc Bảo", Phone = "02838555666", Email = "b2b@lge.com", Address = "Quận 7, TP.HCM" },
                new Supplier { SupplierCode = "NCC004", SupplierName = "Công ty Cổ phần Synnex FPT", ContactName = "Bà Ngọc Trâm", Phone = "02873006666", Email = "distribution@synnexfpt.com", Address = "Quận Bình Thạnh, TP.HCM" },
                new Supplier { SupplierCode = "NCC005", SupplierName = "Tập đoàn Sony Electronics Việt Nam", ContactName = "Ông Quang Huy", Phone = "02838449999", Email = "support@sony.com.vn", Address = "Quận Tân Bình, TP.HCM" },
                new Supplier { SupplierCode = "NCC006", SupplierName = "Công ty TNHH Điện tử Samsung Vina", ContactName = "Bà Phương Linh", Phone = "02839157310", Email = "b2b.vietnam@samsung.com", Address = "Quận 1, TP.HCM" }
            };
            context.Suppliers.AddRange(suppliers);
            context.SaveChanges();

            // 5. Khởi tạo 16 sản phẩm chi tiết
            var products = new List<Product>
            {
                new Product { ProductCode = "SP001", ProductName = "Laptop ASUS ROG Strix G16 (Core i9-14900HX / RTX 4070)", CategoryId = categories[0].CategoryId, SupplierId = suppliers[0].SupplierId, Price = 38990000, CostPrice = 33500000, StockQuantity = 15, Unit = "Cái", Status = "Đang bán", ImageUrl = "https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600&auto=format&fit=crop&q=80" },
                new Product { ProductCode = "SP002", ProductName = "Laptop Apple MacBook Pro 14 M3 Pro (18GB / 512GB SSD)", CategoryId = categories[0].CategoryId, SupplierId = suppliers[3].SupplierId, Price = 49990000, CostPrice = 44000000, StockQuantity = 8, Unit = "Cái", Status = "Đang bán", ImageUrl = "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&auto=format&fit=crop&q=80" },
                new Product { ProductCode = "SP003", ProductName = "Màn hình Gaming LG UltraGear 27 inch 2K 180Hz 1ms IPS", CategoryId = categories[1].CategoryId, SupplierId = suppliers[2].SupplierId, Price = 7490000, CostPrice = 6100000, StockQuantity = 25, Unit = "Cái", Status = "Đang bán", ImageUrl = "https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=600&auto=format&fit=crop&q=80" },
                new Product { ProductCode = "SP004", ProductName = "Màn hình đồ họa ASUS ProArt 27 inch 4K HDR IPS", CategoryId = categories[1].CategoryId, SupplierId = suppliers[0].SupplierId, Price = 12890000, CostPrice = 10500000, StockQuantity = 12, Unit = "Cái", Status = "Đang bán", ImageUrl = "https://images.unsplash.com/photo-1585792180666-f7347c490ee2?w=600&auto=format&fit=crop&q=80" },
                new Product { ProductCode = "SP005", ProductName = "Bàn phím cơ Custom Keychron Q1 Max Nhôm CNC Không dây", CategoryId = categories[2].CategoryId, SupplierId = suppliers[3].SupplierId, Price = 4590000, CostPrice = 3700000, StockQuantity = 20, Unit = "Bộ", Status = "Đang bán", ImageUrl = "https://images.unsplash.com/photo-1595225476474-87563907a212?w=600&auto=format&fit=crop&q=80" },
                new Product { ProductCode = "SP006", ProductName = "Bàn phím cơ Gaming Logitech G Pro X TKL Lightspeed Wireless", CategoryId = categories[2].CategoryId, SupplierId = suppliers[1].SupplierId, Price = 3990000, CostPrice = 3100000, StockQuantity = 0, Unit = "Bộ", Status = "Hết hàng", ImageUrl = "https://images.unsplash.com/photo-1599669454699-248893623440?w=600&auto=format&fit=crop&q=80" },
                new Product { ProductCode = "SP007", ProductName = "Chuột không dây công thái học Logitech MX Master 3S", CategoryId = categories[2].CategoryId, SupplierId = suppliers[1].SupplierId, Price = 2490000, CostPrice = 1850000, StockQuantity = 40, Unit = "Cái", Status = "Đang bán", ImageUrl = "https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=600&auto=format&fit=crop&q=80" },
                new Product { ProductCode = "SP008", ProductName = "Chuột Gaming Logitech G102 Lightsync RGB Gen 2", CategoryId = categories[2].CategoryId, SupplierId = suppliers[1].SupplierId, Price = 450000, CostPrice = 320000, StockQuantity = 60, Unit = "Cái", Status = "Đang bán", ImageUrl = "https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=600&auto=format&fit=crop&q=80" },
                new Product { ProductCode = "SP009", ProductName = "Tai nghe Gaming HyperX Cloud II Red Surround 7.1", CategoryId = categories[2].CategoryId, SupplierId = suppliers[3].SupplierId, Price = 1990000, CostPrice = 1500000, StockQuantity = 30, Unit = "Cái", Status = "Đang bán", ImageUrl = "https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=600&auto=format&fit=crop&q=80" },
                new Product { ProductCode = "SP010", ProductName = "Tai nghe chống ồn không dây Sony WH-1000XM5 Hi-Res", CategoryId = categories[2].CategoryId, SupplierId = suppliers[4].SupplierId, Price = 6990000, CostPrice = 5700000, StockQuantity = 15, Unit = "Cái", Status = "Đang bán", ImageUrl = "https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=600&auto=format&fit=crop&q=80" },
                new Product { ProductCode = "SP011", ProductName = "Ổ cứng SSD Samsung 990 Pro 2TB NVMe PCIe Gen 4.0", CategoryId = categories[3].CategoryId, SupplierId = suppliers[5].SupplierId, Price = 4690000, CostPrice = 3800000, StockQuantity = 35, Unit = "Cái", Status = "Đang bán", ImageUrl = "https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=600&auto=format&fit=crop&q=80" },
                new Product { ProductCode = "SP012", ProductName = "Router WiFi 6 Gaming ASUS ROG Rapture GT-AX6000", CategoryId = categories[4].CategoryId, SupplierId = suppliers[0].SupplierId, Price = 6890000, CostPrice = 5600000, StockQuantity = 10, Unit = "Cái", Status = "Đang bán", ImageUrl = "https://images.unsplash.com/photo-1544197150-b99a580bb7a8?w=600&auto=format&fit=crop&q=80" },
                new Product { ProductCode = "SP013", ProductName = "Màn hình chuyên đồ họa Dell UltraSharp 32 inch 4K IPS Black", CategoryId = categories[1].CategoryId, SupplierId = suppliers[3].SupplierId, Price = 19890000, CostPrice = 16800000, StockQuantity = 9, Unit = "Cái", Status = "Đang bán", ImageUrl = "https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=600&auto=format&fit=crop&q=80" },
                new Product { ProductCode = "SP014", ProductName = "Bộ nhớ RAM Corsair Vengeance RGB DDR5 64GB (2x32GB) 6000MHz", CategoryId = categories[3].CategoryId, SupplierId = suppliers[3].SupplierId, Price = 5490000, CostPrice = 4300000, StockQuantity = 22, Unit = "Bộ", Status = "Đang bán", ImageUrl = "https://images.unsplash.com/photo-1562976540-1502c2145186?w=600&auto=format&fit=crop&q=80" },
                new Product { ProductCode = "SP015", ProductName = "Card đồ họa ASUS TUF Gaming GeForce RTX 4080 Super 16GB", CategoryId = categories[3].CategoryId, SupplierId = suppliers[0].SupplierId, Price = 29990000, CostPrice = 25500000, StockQuantity = 5, Unit = "Cái", Status = "Đang bán", ImageUrl = "https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=600&auto=format&fit=crop&q=80" },
                new Product { ProductCode = "SP016", ProductName = "Webcam 4K Sony Bravia Cam Pro Hội nghị & Livestream", CategoryId = categories[4].CategoryId, SupplierId = suppliers[4].SupplierId, Price = 5290000, CostPrice = 4100000, StockQuantity = 14, Unit = "Cái", Status = "Đang bán", ImageUrl = "https://images.unsplash.com/photo-1588508065123-287b28e013da?w=600&auto=format&fit=crop&q=80" }
            };
            context.Products.AddRange(products);
            context.SaveChanges();

            // 6. Khởi tạo 15 hồ sơ khách hàng đầy đủ nhân khẩu học
            var profiles = new List<CustomerProfile>
            {
                new CustomerProfile { AccountId = customers[0].AccountId, Age = 19, Gender = "Nam", Address = "273 An Dương Vương, Quận 5, TP.HCM", Interest = "Gaming" },
                new CustomerProfile { AccountId = customers[1].AccountId, Age = 24, Gender = "Nữ", Address = "120 Nguyễn Thị Minh Khai, Quận 3, TP.HCM", Interest = "Văn phòng" },
                new CustomerProfile { AccountId = customers[2].AccountId, Age = 28, Gender = "Nam", Address = "45 Lê Văn Việt, TP. Thủ Đức, TP.HCM", Interest = "Lập trình" },
                new CustomerProfile { AccountId = customers[3].AccountId, Age = 35, Gender = "Nam", Address = "88 Cộng Hòa, Quận Tân Bình, TP.HCM", Interest = "Đồ họa" },
                new CustomerProfile { AccountId = customers[4].AccountId, Age = 22, Gender = "Nữ", Address = "15 Trần Hưng Đạo, Quận 1, TP.HCM", Interest = "Gaming" },
                new CustomerProfile { AccountId = customers[5].AccountId, Age = 31, Gender = "Nam", Address = "102 Võ Văn Ngân, TP. Thủ Đức, TP.HCM", Interest = "Văn phòng" },
                new CustomerProfile { AccountId = customers[6].AccountId, Age = 18, Gender = "Nữ", Address = "334 Nguyễn Trãi, Quận 5, TP.HCM", Interest = "Gaming" },
                new CustomerProfile { AccountId = customers[7].AccountId, Age = 42, Gender = "Nam", Address = "56 Điện Biên Phủ, Quận Bình Thạnh, TP.HCM", Interest = "Lập trình" },
                new CustomerProfile { AccountId = customers[8].AccountId, Age = 26, Gender = "Nữ", Address = "182 Hai Bà Trưng, Quận 1, TP.HCM", Interest = "Đồ họa" },
                new CustomerProfile { AccountId = customers[9].AccountId, Age = 29, Gender = "Nam", Address = "65 Hoàng Hoa Thám, Quận Phú Nhuận, TP.HCM", Interest = "Gaming" },
                new CustomerProfile { AccountId = customers[10].AccountId, Age = 23, Gender = "Nữ", Address = "210 Cách Mạng Tháng 8, Quận 10, TP.HCM", Interest = "Văn phòng" },
                new CustomerProfile { AccountId = customers[11].AccountId, Age = 19, Gender = "Nam", Address = "99 Nguyễn Tri Phương, Quận 5, TP.HCM", Interest = "Lập trình" },
                new CustomerProfile { AccountId = customers[12].AccountId, Age = 38, Gender = "Nam", Address = "14 Phan Xích Long, Quận Phú Nhuận, TP.HCM", Interest = "Đồ họa" },
                new CustomerProfile { AccountId = customers[13].AccountId, Age = 25, Gender = "Nữ", Address = "72 Ba Tháng Hai, Quận 10, TP.HCM", Interest = "Văn phòng" },
                new CustomerProfile { AccountId = customers[14].AccountId, Age = 45, Gender = "Nam", Address = "415 Lê Hồng Phong, Quận 5, TP.HCM", Interest = "Gaming" }
            };
            context.CustomerProfiles.AddRange(profiles);
            context.SaveChanges();

            // 7. Khởi tạo 18 phản hồi đánh giá sản phẩm (đầy đủ điểm 1-5 sao, trạng thái tiếp nhận & giải đáp)
            var feedbacks = new List<Feedback>
            {
                new Feedback { AccountId = customers[0].AccountId, ProductId = products[0].ProductId, Rating = 5, Comment = "Laptop ROG Strix chạy cực kỳ mượt, tản nhiệt mát mẻ khi chiến game AAA nặng ở độ phân giải 2K.", AdminReply = "Cảm ơn bạn đã tin tưởng ủng hộ sản phẩm chính hãng tại hệ thống SGU Tech!", Status = "Đã tiếp nhận & Xử lý", CreatedAt = DateTime.Now.AddDays(-10) },
                new Feedback { AccountId = customers[1].AccountId, ProductId = products[6].ProductId, Rating = 4, Comment = "Chuột MX Master 3S cuộn trang vô cực rất êm tay cho công việc văn phòng, pin dùng cả tháng.", AdminReply = "SGU Tech xin cảm ơn đánh giá tích cực từ bạn!", Status = "Đã tiếp nhận & Xử lý", CreatedAt = DateTime.Now.AddDays(-9) },
                new Feedback { AccountId = customers[2].AccountId, ProductId = products[2].ProductId, Rating = 5, Comment = "Màn hình LG UltraGear hiển thị chuẩn màu, tần số quét 180Hz chơi game và làm việc rất sướng mắt.", AdminReply = "Chúc bạn có những trải nghiệm tuyệt vời cùng sản phẩm!", Status = "Đã tiếp nhận & Xử lý", CreatedAt = DateTime.Now.AddDays(-8) },
                new Feedback { AccountId = customers[3].AccountId, ProductId = products[10].ProductId, Rating = 5, Comment = "Tốc độ đọc ghi của SSD Samsung 990 Pro cực nhanh, render video đồ họa 4K tiết kiệm rất nhiều thời gian.", AdminReply = "Cảm ơn bạn! Dòng Samsung 990 Pro là đỉnh nhất hiện nay ạ.", Status = "Đã tiếp nhận & Xử lý", CreatedAt = DateTime.Now.AddDays(-7) },
                new Feedback { AccountId = customers[8].AccountId, ProductId = products[12].ProductId, Rating = 5, Comment = "Màn hình Dell UltraSharp 32 4K IPS Black màu đen sâu, độ phủ màu chuẩn DCI-P3 98% rất đáng tiền cho dân thiết kế.", AdminReply = "Dòng UltraSharp IPS Black chuyên dụng cho đồ họa cao cấp luôn được hỗ trợ bảo hành đổi mới 3 năm bạn nhé!", Status = "Đã tiếp nhận & Xử lý", CreatedAt = DateTime.Now.AddDays(-6) },
                new Feedback { AccountId = customers[9].AccountId, ProductId = products[4].ProductId, Rating = 5, Comment = "Bàn phím Keychron Q1 Max gõ đầm tay, âm thanh thock trầm rất êm, kết nối không dây 2.4Ghz cực nhạy.", AdminReply = "Cảm ơn bạn đã lựa chọn phiên bản phím cơ nhôm CNC cao cấp tại SGU Tech!", Status = "Đã tiếp nhận & Xử lý", CreatedAt = DateTime.Now.AddDays(-5) },
                new Feedback { AccountId = customers[10].AccountId, ProductId = products[1].ProductId, Rating = 5, Comment = "MacBook Pro 14 M3 Pro pin trâu kinh khủng, dùng cả ngày không cần cắm sạc, màn hình Liquid Retina XDR tuyệt đẹp.", AdminReply = "Cảm ơn chị đã mua hàng chính hãng Apple tại SGU Tech!", Status = "Đã tiếp nhận & Xử lý", CreatedAt = DateTime.Now.AddDays(-5) },
                new Feedback { AccountId = customers[0].AccountId, ProductId = products[7].ProductId, Rating = 4, Comment = "Chuột G102 bền bỉ, click nảy tốt, mức giá rất vừa túi tiền sinh viên.", AdminReply = null, Status = "Chờ xử lý", CreatedAt = DateTime.Now.AddDays(-4) },
                new Feedback { AccountId = customers[6].AccountId, ProductId = products[8].ProductId, Rating = 4, Comment = "Tai nghe HyperX Cloud II đeo êm tai không bị cấn, mic lọc ồn tốt khi đàm thoại.", AdminReply = null, Status = "Chờ xử lý", CreatedAt = DateTime.Now.AddDays(-4) },
                new Feedback { AccountId = customers[7].AccountId, ProductId = products[3].ProductId, Rating = 3, Comment = "Màn hình ProArt màu đẹp nhưng viền hơi dày hơn mong đợi một chút.", AdminReply = null, Status = "Chờ xử lý", CreatedAt = DateTime.Now.AddDays(-3) },
                new Feedback { AccountId = customers[11].AccountId, ProductId = products[13].ProductId, Rating = 5, Comment = "RAM Corsair DDR5 64GB mở hàng chục máy ảo Docker chạy mượt mà, LED RGB đồng bộ iCUE đẹp mắt.", AdminReply = null, Status = "Chờ xử lý", CreatedAt = DateTime.Now.AddDays(-3) },
                new Feedback { AccountId = customers[12].AccountId, ProductId = products[15].ProductId, Rating = 4, Comment = "Webcam Sony 4K nét căng, tự động lấy nét khuôn mặt khi họp online rất tiện lợi.", AdminReply = null, Status = "Chờ xử lý", CreatedAt = DateTime.Now.AddDays(-2) },
                new Feedback { AccountId = customers[2].AccountId, ProductId = products[0].ProductId, Rating = 5, Comment = "Máy đẹp, cấu hình khủng, nhân viên tư vấn SGU Tech rất nhiệt tình hỗ trợ cài đặt ban đầu.", AdminReply = null, Status = "Chờ xử lý", CreatedAt = DateTime.Now.AddDays(-2) },
                new Feedback { AccountId = customers[9].AccountId, ProductId = products[5].ProductId, Rating = 2, Comment = "Bàn phím G Pro X gõ tốt nhưng âm thanh clicky của switch hơi ồn khi làm việc ban đêm.", AdminReply = "Dòng G Pro X dùng switch cơ chuyên cho game thủ nên tiếng clicky khá đanh, bạn có thể ghé cửa hàng để nhân viên tư vấn đổi sang phiên bản switch Linear êm hơn nhé!", Status = "Đã tiếp nhận & Xử lý", CreatedAt = DateTime.Now.AddDays(-2) },
                new Feedback { AccountId = customers[13].AccountId, ProductId = products[11].ProductId, Rating = 4, Comment = "Router Asus phát sóng xuyên tường 2 tầng lầu vẫn bắt được sóng WiFi 6 mạnh mẽ.", AdminReply = null, Status = "Chờ xử lý", CreatedAt = DateTime.Now.AddDays(-1) },
                new Feedback { AccountId = customers[1].AccountId, ProductId = products[9].ProductId, Rating = 5, Comment = "Chống ồn của Sony XM5 thực sự đỉnh cao, đi xe buýt hay máy bay bật lên là yên tĩnh hoàn toàn.", AdminReply = null, Status = "Chờ xử lý", CreatedAt = DateTime.Now.AddDays(-1) },
                new Feedback { AccountId = customers[3].AccountId, ProductId = products[14].ProductId, Rating = 1, Comment = "Card đồ họa RTX 4080 Super giao đến bị cấn một góc hộp bìa carton bên ngoài do vận chuyển.", AdminReply = "SGU Tech chân thành xin lỗi anh về sự cố khâu vận chuyển! Quản lý kho đã liên hệ và đổi mới nguyên seal cho anh ngay trong hôm nay ạ.", Status = "Đã tiếp nhận & Xử lý", CreatedAt = DateTime.Now },
                new Feedback { AccountId = customers[0].AccountId, ProductId = products[10].ProductId, Rating = 5, Comment = "Mua chiếc SSD thứ hai gắn thêm cho laptop ROG, tốc độ ổn định nhiệt độ chỉ 45 độ C.", AdminReply = null, Status = "Chờ xử lý", CreatedAt = DateTime.Now }
            };
            context.Feedbacks.AddRange(feedbacks);
            context.SaveChanges();

            // 8. Khởi tạo 5 bài khảo sát sản phẩm mới
            var surveys = new List<Survey>
            {
                new Survey { Title = "Khảo sát nhu cầu dòng Laptop AI Siêu Mỏng Nhẹ 2026", Description = "Đánh giá nhu cầu trang bị chip NPU AI chuyên dụng hỗ trợ lập trình viên và sáng tạo nội dung đa nhiệm.", TargetProduct = "ASUS Zenbook S16 OLED AI 2026", ExpectedPrice = 36990000, CreatedAt = DateTime.Now.AddDays(-10), IsActive = true, ExpiresAt = DateTime.Now.AddDays(20) },
                new Survey { Title = "Thăm dò Bàn phím cơ Custom Nhôm CNC Không dây", Description = "Khảo sát mức giá mong muốn cho dòng bàn phím cơ kết nối 3 chế độ không dây độ trễ thấp.", TargetProduct = "Keychron Q1 Max SGU Custom Edition", ExpectedPrice = 4500000, CreatedAt = DateTime.Now.AddDays(-8), IsActive = true, ExpiresAt = null },
                new Survey { Title = "Thăm dò Tai nghe chống ồn Hi-Res Thế hệ Mới", Description = "Khảo sát tính năng khử tiếng ồn chủ động bằng AI và thời lượng pin 40 giờ.", TargetProduct = "Sony WH-1000XM6 Edition 2026", ExpectedPrice = 7990000, CreatedAt = DateTime.Now.AddDays(-5), IsActive = true, ExpiresAt = DateTime.Now.AddDays(10) },
                new Survey { Title = "Khảo sát Màn hình Đồ họa 5K Chuyên Dụng Cho Designer", Description = "Khảo sát nhu cầu trang bị màn hình 5K độ phân giải siêu nét dành cho giới làm đồ họa chuyên nghiệp.", TargetProduct = "Dell UltraSharp 32 5K HDR", ExpectedPrice = 24500000, CreatedAt = DateTime.Now.AddDays(-3), IsActive = true, ExpiresAt = DateTime.Now.AddDays(15) },
                new Survey { Title = "Khảo sát thử nghiệm Màn hình cong Mini-LED 49 inch (Đã đóng)", Description = "Chương trình thăm dò giai đoạn thử nghiệm ban đầu.", TargetProduct = "Samsung Odyssey OLED G9", ExpectedPrice = 29900000, CreatedAt = DateTime.Now.AddDays(-25), IsActive = false, ExpiresAt = DateTime.Now.AddDays(-5) }
            };
            context.Surveys.AddRange(surveys);
            context.SaveChanges();

            // 9. Khởi tạo 16 câu trả lời khảo sát mẫu phong phú
            var surveyResponses = new List<SurveyResponse>
            {
                new SurveyResponse { SurveyId = surveys[0].SurveyId, AccountId = customers[0].AccountId, Score = 5, BuyingIntent = "Rất muốn mua", CustomerOpinion = "Thiết kế cực kỳ sang trọng, nếu có quà tặng kèm chuột không dây và túi chống sốc tôi sẽ đặt trước ngay.", SubmittedAt = DateTime.Now.AddDays(-9) },
                new SurveyResponse { SurveyId = surveys[0].SurveyId, AccountId = customers[1].AccountId, Score = 4, BuyingIntent = "Đang cân nhắc", CustomerOpinion = "Cấu hình chip AI rất ấn tượng nhưng mức giá gần 37 triệu hơi cao đối với nhân viên văn phòng.", SubmittedAt = DateTime.Now.AddDays(-7) },
                new SurveyResponse { SurveyId = surveys[0].SurveyId, AccountId = customers[2].AccountId, Score = 5, BuyingIntent = "Rất muốn mua", CustomerOpinion = "Màn hình OLED 3K và thời lượng pin lâu rất phù hợp cho lập trình viên, mong cửa hàng hỗ trợ trả góp 0%.", SubmittedAt = DateTime.Now.AddDays(-6) },
                new SurveyResponse { SurveyId = surveys[0].SurveyId, AccountId = customers[5].AccountId, Score = 5, BuyingIntent = "Rất muốn mua", CustomerOpinion = "Máy rất nhẹ phù hợp đi công tác xa, tôi sẵn sàng đặt cọc trước.", SubmittedAt = DateTime.Now.AddDays(-4) },
                new SurveyResponse { SurveyId = surveys[0].SurveyId, AccountId = customers[7].AccountId, Score = 3, BuyingIntent = "Không mua", CustomerOpinion = "Tôi quen dùng máy tính bàn cấu hình cao hơn là laptop mỏng nhẹ.", SubmittedAt = DateTime.Now.AddDays(-3) },
                new SurveyResponse { SurveyId = surveys[0].SurveyId, AccountId = customers[10].AccountId, Score = 4, BuyingIntent = "Đang cân nhắc", CustomerOpinion = "Chờ xem bản thực tế ngoài showroom SGU Tech rồi sẽ quyết định mua.", SubmittedAt = DateTime.Now.AddDays(-2) },
                
                new SurveyResponse { SurveyId = surveys[1].SurveyId, AccountId = customers[3].AccountId, Score = 4, BuyingIntent = "Đang cân nhắc", CustomerOpinion = "Bản nhôm CNC rất đầm, nếu shop có sẵn switch tactile tôi sẽ mua ngay.", SubmittedAt = DateTime.Now.AddDays(-5) },
                new SurveyResponse { SurveyId = surveys[1].SurveyId, AccountId = customers[0].AccountId, Score = 5, BuyingIntent = "Rất muốn mua", CustomerOpinion = "Mức giá 4.5 triệu cho bản Q1 Max là quá hợp lý trong phân khúc phím nhôm.", SubmittedAt = DateTime.Now.AddDays(-4) },
                new SurveyResponse { SurveyId = surveys[1].SurveyId, AccountId = customers[9].AccountId, Score = 5, BuyingIntent = "Rất muốn mua", CustomerOpinion = "Sẵn sàng mua ngay khi mở bán đợt đầu, mong có màu đen nhám Anodized.", SubmittedAt = DateTime.Now.AddDays(-3) },
                new SurveyResponse { SurveyId = surveys[1].SurveyId, AccountId = customers[11].AccountId, Score = 3, BuyingIntent = "Không mua", CustomerOpinion = "Đã có bàn phím cơ rồi nên chưa có nhu cầu mua thêm.", SubmittedAt = DateTime.Now.AddDays(-1) },

                new SurveyResponse { SurveyId = surveys[2].SurveyId, AccountId = customers[1].AccountId, Score = 4, BuyingIntent = "Đang cân nhắc", CustomerOpinion = "Nếu trọng lượng nhẹ hơn bản XM5 và đệm tai êm hơn tôi sẽ nâng cấp.", SubmittedAt = DateTime.Now.AddDays(-3) },
                new SurveyResponse { SurveyId = surveys[2].SurveyId, AccountId = customers[6].AccountId, Score = 5, BuyingIntent = "Rất muốn mua", CustomerOpinion = "Nếu chống ồn AI tốt hơn XM5 thì 8 triệu là mức giá chấp nhận được.", SubmittedAt = DateTime.Now.AddDays(-2) },
                new SurveyResponse { SurveyId = surveys[2].SurveyId, AccountId = customers[8].AccountId, Score = 4, BuyingIntent = "Đang cân nhắc", CustomerOpinion = "Mong đợi chất âm ấm và microphone đàm thoại rõ ràng hơn.", SubmittedAt = DateTime.Now.AddDays(-1) },

                new SurveyResponse { SurveyId = surveys[3].SurveyId, AccountId = customers[3].AccountId, Score = 5, BuyingIntent = "Rất muốn mua", CustomerOpinion = "Độ phân giải 5K rất cần cho biên tập ảnh và video, mức giá 24.5 triệu rất cạnh tranh với Apple Studio Display.", SubmittedAt = DateTime.Now.AddDays(-2) },
                new SurveyResponse { SurveyId = surveys[3].SurveyId, AccountId = customers[8].AccountId, Score = 5, BuyingIntent = "Rất muốn mua", CustomerOpinion = "Nếu có chân đế xoay dọc công thái học và cổng sạc Thunderbolt 4 thì hoàn hảo.", SubmittedAt = DateTime.Now.AddDays(-1) },
                new SurveyResponse { SurveyId = surveys[3].SurveyId, AccountId = customers[12].AccountId, Score = 4, BuyingIntent = "Đang cân nhắc", CustomerOpinion = "Cần kiểm tra độ tương phản thực tế tại showroom SGU Tech.", SubmittedAt = DateTime.Now }
            };
            context.SurveyResponses.AddRange(surveyResponses);
            context.SaveChanges();
        }
    }
}
