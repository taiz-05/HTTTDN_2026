================================================================================
ĐỒ ÁN HỌC PHẦN: HỆ THỐNG THÔNG TIN DOANH NGHIỆP (MÃ HỌC PHẦN: 841065)
HỌC KỲ 1 - NĂM HỌC 2026 - 2027 | KHOA CNTT - TRƯỜNG ĐẠI HỌC SÀI GÒN (SGU)
================================================================================

1. THÔNG TIN ĐỀ TÀI:
- Tên đề tài: Xây dựng Hệ thống Thông tin Quản trị Doanh nghiệp Thương mại SGU Tech
  và Mô phỏng Phân hệ Quản lý Quan hệ Khách hàng (CRM - Mục III.4).
- Phạm vi thực hiện:
  + Phần I (40 điểm): Báo cáo khảo sát HTTT (20 câu hỏi), phân tích BFD, Context Diagram,
    DFD Mức 0 & Mức 1, Thiết kế CSDL 9 bảng chuẩn 3NF, Thiết kế Giao diện & Hướng dẫn sử dụng.
  + Phần II (30 điểm): Cài đặt CSDL & Kịch bản Sao lưu/Phục hồi (10đ) + Giao diện Admin Server
    tách biệt hoàn toàn, thêm/xóa/khóa và phân quyền cho Account với 3 vai trò chuẩn (20đ).
  + Phần III - Mục 4.1 (20 điểm): Phân hệ Người Quản lý CRM (Thêm khách hàng mới, Xóa khách hàng,
    Khóa tài khoản khách hàng, Tiếp nhận & giải đáp phản hồi, Báo cáo tỷ lệ độ tuổi & sở thích,
    Tạo bảng khảo sát gửi đến tài khoản khách hàng, Thống kê kết quả khảo sát).
  + Phần III - Mục 4.3 (10 điểm): Phân hệ Khách hàng (Đăng ký tài khoản, Đăng nhập, Chỉnh sửa
    thông tin cá nhân, Gửi phản hồi về sản phẩm, Nhận được khảo sát và thực hiện 5 tiêu chí).

--------------------------------------------------------------------------------
2. DANH SÁCH THÀNH VIÊN NHÓM & PHÂN CÔNG NHIỆM VỤ:
--------------------------------------------------------------------------------
1) Huỳnh Tuấn Tài      | MSSV: 3123411261 | Nhóm trưởng | Hoàn thành: 100% | Tự đánh giá: 10/10
   - Phụ trách: Khảo sát HTTT doanh nghiệp, xây dựng Backend ASP.NET Core 8.0 Web API,
     tích hợp Entity Framework Core (SQL Server & SQLite), kiểm thử toàn hệ thống.

2) Hoàng Thái Thanh    | MSSV: 3123411267 | Thành viên  | Hoàn thành: 100% | Tự đánh giá: 10/10
   - Phụ trách: Thiết kế và lập trình Giao diện Cổng Admin Server (admin.html) và
     Phân hệ Người Quản lý CRM 5 Tab (manager_crm.html), biểu đồ thống kê Chart.js, biên soạn Báo cáo.

3) Lê Nguyễn Phú Hải   | MSSV: 3123411080 | Thành viên  | Hoàn thành: 100% | Tự đánh giá: 10/10
   - Phụ trách: Phân tích hệ thống (vẽ sơ đồ BFD, Context Diagram, DFD Mức 0 & Mức 1),
     lập trình Cổng Khách hàng (customer_login.html, user.html), viết tài liệu Hướng dẫn sử dụng.

4) Nguyễn Đăng Khoa    | MSSV: 3123411157 | Thành viên  | Hoàn thành: 100% | Tự đánh giá: 10/10
   - Phụ trách: Thiết kế lược đồ CSDL 9 bảng chuẩn 3NF (ERD), viết Script SQL khởi tạo
     và nạp dữ liệu mẫu (HTTTDN_DB.sql), xây dựng kịch bản Sao lưu & Phục hồi (Backup/Restore).

--------------------------------------------------------------------------------
3. CẤU TRÚC THƯ MỤC NỘP BÀI:
--------------------------------------------------------------------------------
- /readme.txt                         : Tập tin thông tin nhóm, tài khoản test và hướng dẫn cài đặt.
- /start_demo.bat                     : Tập tin khởi chạy nhanh toàn bộ hệ thống chỉ với 1 cú nhấp chuột.
- /Database/HTTTDN_DB.sql             : Script T-SQL khởi tạo 9 bảng CSDL, nạp dữ liệu demo và Backup/Restore.
- /Backend/HTTTDN.AdminApi            : Mã nguồn máy chủ ASP.NET Core 8.0 Web API (chạy tại cổng 5000).
- /Frontend_Admin/login.html          : Cổng đăng nhập nội bộ (dành cho Admin Server và Quản lý CRM).
- /Frontend_Admin/admin.html          : Giao diện Quản trị viên Hệ thống (Admin Server).
- /Frontend_Admin/manager_crm.html    : Giao diện Người Quản lý Quan hệ Khách hàng (CRM Manager - 5 Tab).
- /Frontend_Admin/customer_login.html : Cổng Đăng nhập & Đăng ký dành riêng cho Khách hàng.
- /Frontend_Admin/user.html           : Giao diện Cổng Trải nghiệm Khách hàng (SGU Tech Store).
- /Report/BAO_CAO_DO_AN_HTTTDN.docx   : Báo cáo đồ án định dạng Microsoft Word chuẩn in ấn.
- /Report/BAO_CAO_DO_AN_HTTTDN.md     : Báo cáo đồ án định dạng Markdown.
- /Report/images/                     : Thư mục chứa 9 sơ đồ kỹ thuật và toàn bộ ảnh chụp màn hình thực tế.

--------------------------------------------------------------------------------
4. DỮ LIỆU DEMO & DANH SÁCH TÀI KHOẢN TEST ĐÃ TẠO SẴN:
--------------------------------------------------------------------------------
Hệ thống đã được chuẩn bị sẵn dữ liệu mẫu phong phú trong 9 bảng:
- 03 Vai trò chuẩn (Roles): Admin, Manager, Customer.
- 19 Tài khoản (Accounts): 02 Admin, 02 Manager, 15 Khách hàng (13 đang hoạt động, 02 đang tạm khóa).
- 15 Hồ sơ nhân khẩu học (CustomerProfiles): Đầy đủ độ tuổi (<20, 20-30, >30) và sở thích (Gaming, Văn phòng, Đồ họa, Lập trình).
- 04 Danh mục (Categories), 05 Nhà cung cấp (Suppliers), 15 Sản phẩm công nghệ (Products).
- 10 Phản hồi đánh giá sản phẩm (Feedbacks): Đầy đủ điểm 1-5 sao và nội dung giải đáp từ Quản lý.
- 05 Chiến dịch khảo sát sản phẩm mới (Surveys) & 16 Phiếu trả lời khảo sát chi tiết (SurveyResponses).

DANH SÁCH TÀI KHOẢN ĐĂNG NHẬP ĐỂ KIỂM THỬ / DEMO:
a) Vai trò Quản trị viên (Đăng nhập tại /Frontend_Admin/login.html -> vào admin.html):
   - Tài khoản 1 : Username: admin        | Password: 123456
   - Tài khoản 2 : Username: admin2       | Password: 123456

b) Vai trò Người Quản lý CRM (Đăng nhập tại /Frontend_Admin/login.html -> vào manager_crm.html):
   - Tài khoản 1 : Username: quanly       | Password: 123456
   - Tài khoản 2 : Username: quanly_cskh  | Password: 123456

c) Vai trò Khách hàng (Đăng nhập tại /Frontend_Admin/customer_login.html -> vào user.html):
   - Khách hàng 1: Username: khachhang1   | Password: 123456 (Nguyễn Văn An - 19 tuổi - Gaming)
   - Khách hàng 2: Username: khachhang2   | Password: 123456 (Lê Thị Bình - 24 tuổi - Văn phòng)
   - Khách hàng 3: Username: khachhang3   | Password: 123456 (Phạm Minh Châu - 27 tuổi - Đồ họa)
   - Khách hàng 4: Username: khachhang4   | Password: 123456 (Hoàng Đức Dũng - 35 tuổi - Gaming)
   - Khách hàng 5: Username: khachhang5   | Password: 123456 (Tài khoản đang bị khóa để test chặn đăng nhập)
   - Các tài khoản khác từ khachhang6 đến khachhang15 cùng mật khẩu: 123456.

--------------------------------------------------------------------------------
5. HƯỚNG DẪN CÀI ĐẶT & KHỞI CHẠY PHẦN MỀM:
--------------------------------------------------------------------------------
* CÁCH 1: KHỞI CHẠY NHANH TỰ ĐỘNG (KHUYÊN DÙNG KHI DEMO - KHÔNG CẦN CẤU HÌNH SQL SERVER)
  - Bước 1: Nhấp đúp vào tập tin "start_demo.bat" tại thư mục gốc, hoặc mở Terminal tại thư mục
            "Backend/HTTTDN.AdminApi" và chạy lệnh:
            dotnet run
  - Bước 2: Máy chủ Backend sẽ khởi chạy tại địa chỉ http://localhost:5000 và tự động nạp sẵn
            toàn bộ 9 bảng dữ liệu mẫu vào tệp SQLite (htttdn.db).
  - Bước 3: Mở trình duyệt tại "/Frontend_Admin/login.html" (cho Admin & Quản lý CRM) hoặc
            "/Frontend_Admin/customer_login.html" (cho Khách hàng) để trải nghiệm.

* CÁCH 2: KHỞI CHẠY VỚI HỆ QUẢN TRỊ MICROSOFT SQL SERVER (SSMS)
  - Bước 1: Mở SQL Server Management Studio (SSMS), mở tập tin "/Database/HTTTDN_DB.sql" và nhấn
            Execute (F5) để tạo CSDL HTTTDN_DB cùng toàn bộ 9 bảng và dữ liệu mẫu.
  - Bước 2: Mở tập tin "/Backend/HTTTDN.AdminApi/appsettings.json", chỉnh sửa cấu hình:
            "UseSqlServer": true
            và kiểm tra chuỗi kết nối "DefaultConnection" trỏ đúng về tên SQL Server của máy.
  - Bước 3: Chạy lệnh "dotnet run" tại thư mục "Backend/HTTTDN.AdminApi".
================================================================================
