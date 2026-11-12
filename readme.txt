========================================================================
ĐỒ ÁN HỌC PHẦN: HỆ THỐNG THÔNG TIN DOANH NGHIỆP (MÃ HP: 841065)
HỌC KỲ 1 - NĂM HỌC 2026 - 2027 | TRƯỜNG ĐẠI HỌC SÀI GÒN (SGU)
========================================================================

1. TÊN ĐỀ TÀI:
Xây dựng Hệ thống Thông tin Quản trị Doanh nghiệp Thương mại & Mô phỏng Phân hệ Quản lý Quan hệ Khách hàng (CRM - Mục III.4).

2. DANH SÁCH THÀNH VIÊN NHÓM:
- Thành viên 1: [Họ tên] - MSSV: [MSSV] - Khối lượng: 100% (Nhóm trưởng, Backend, Database)
- Thành viên 2: [Họ tên] - MSSV: [MSSV] - Khối lượng: 100% (Frontend Admin & Manager CRM)
- Thành viên 3: [Họ tên] - MSSV: [MSSV] - Khối lượng: 100% (Frontend Customer, Phân tích BFD/DFD)
- Thành viên 4: [Họ tên] - MSSV: [MSSV] - Khối lượng: 100% (Thiết kế CSDL, Script SQL, Backup/Restore)
- Thành viên 5: [Họ tên] - MSSV: [MSSV] - Khối lượng: 100% (Kiểm thử, Báo cáo Word, Hướng dẫn sử dụng)

3. CẤU TRÚC THƯ MỤC NỘP BÀI:
- /Database/HTTTDN_DB.sql             : Script khởi tạo 9 bảng CSDL, dữ liệu demo và kịch bản Backup/Restore.
- /Backend/HTTTDN.AdminApi            : Mã nguồn ASP.NET Core Web API (.NET 8.0) chạy tại cổng 5000.
- /Frontend_Admin                     : Mã nguồn giao diện HTML5, CSS3, JS tách biệt 3 cổng (Admin, CRM Manager, Customer).
- /Report/BAO_CAO_DO_AN_HTTTDN.docx   : File Báo cáo đồ án Microsoft Word hoàn chỉnh theo đúng quy định của Khoa CNTT - SGU.
- /Report/BAO_CAO_DO_AN_HTTTDN.md     : File Báo cáo định dạng Markdown.
- /start_demo.bat                     : File khởi chạy nhanh toàn bộ hệ thống chỉ với 1 cú nhấp chuột.

4. HƯỚNG DẪN CÀI ĐẶT & CHẠY CHƯƠNG TRÌNH:
- Cách 1 (Chạy nhanh tự động với SQLite tích hợp sẵn):
  + Nhấp đúp vào file "start_demo.bat" ở thư mục gốc, hoặc mở Terminal tại "/Backend/HTTTDN.AdminApi" và chạy lệnh "dotnet run" (Server chạy ở http://localhost:5000, tự động tạo CSDL và nạp sẵn dữ liệu mẫu).
  + Mở "/Frontend_Admin/login.html" (dành cho Admin & Quản lý CRM) hoặc "/Frontend_Admin/customer_login.html" (dành cho Khách hàng).
- Cách 2 (Chạy với Microsoft SQL Server):
  + Mở SQL Server Management Studio (SSMS), chạy toàn bộ file "/Database/HTTTDN_DB.sql".
  + Trong "/Backend/HTTTDN.AdminApi/appsettings.json", đổi "UseSqlServer": true rồi chạy "dotnet run".

5. TÀI KHOẢN DEMO ĐỂ CHẤM ĐIỂM:
- Cổng Quản trị hệ thống (Admin) : Username: admin      | Password: 123456
- Cổng Quản lý CRM (Manager)     : Username: quanly     | Password: 123456
- Cổng Khách hàng (Customer)     : Username: khachhang1 | Password: 123456
                                   Username: khachhang2 | Password: 123456
                                   Username: khachhang3 | Password: 123456
========================================================================