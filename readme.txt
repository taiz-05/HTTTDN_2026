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
- /Database/HTTTDN_DB.sql       : Script khởi tạo 9 bảng CSDL, dữ liệu demo và kịch bản Backup/Restore.
- /Backend/HTTTDN.AdminApi      : Mã nguồn ASP.NET Core Web API (.NET 8.0) chạy tại cổng 5000.
- /Frontend_Admin               : Mã nguồn giao diện HTML5, CSS3, JS tách biệt 3 cổng.
- /Report/BaoCao_HTTTDN_CRM.pdf : Báo cáo đồ án hoàn chỉnh.

4. HƯỚNG DẪN CÀI ĐẶT & CHẠY CHƯƠNG TRÌNH:
- Bước 1: Mở SQL Server Management Studio (SSMS), kết nối tới Server ".\SQLEXPRESS" và chạy toàn bộ file "/Database/HTTTDN_DB.sql".
- Bước 2: Mở Terminal tại "/Backend/HTTTDN.AdminApi", chạy lệnh "dotnet run" (Server chạy ở http://localhost:5000).
- Bước 3: Mở thư mục "/Frontend_Admin" bằng VS Code, chạy Live Server tại file "login.html" (http://127.0.0.1:5500/login.html).

5. TÀI KHOẢN DEMO ĐỂ CHẤM ĐIỂM:
- Cổng Quản trị hệ thống (Admin) : Username: admin      | Password: 123456
- Cổng Quản lý CRM (Manager)     : Username: quanly     | Password: 123456
- Cổng Khách hàng (Customer)     : Username: khachhang1 | Password: 123456
                                   Username: khachhang2 | Password: 123456
                                   Username: khachhang3 | Password: 123456
========================================================================