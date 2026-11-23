# ==============================================================================
# PART 1: CHƯƠNG 1 — GIỚI THIỆU DOANH NGHIỆP & KHẢO SÁT HỆ THỐNG THÔNG TIN (10Đ)
# ==============================================================================

function Build-Part1-Chapter1 {
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.Append((New-WHeading1 "PHẦN I: PHÂN TÍCH VÀ THIẾT KẾ HỆ THỐNG THÔNG TIN DOANH NGHIỆP (40 ĐIỂM)"))
    [void]$sb.Append((New-WHeading1 "CHƯƠNG 1: PHẦN CHUNG — GIỚI THIỆU DOANH NGHIỆP & KHẢO SÁT HỆ THỐNG THÔNG TIN (10 ĐIỂM)"))

    # 1.1. GIỚI THIỆU VỀ DOANH NGHIỆP (5 ĐIỂM)
    [void]$sb.Append((New-WHeading2 "1.1. Giới thiệu về Doanh nghiệp (5 điểm)"))
    [void]$sb.Append((New-WHeading3 "1.1.1. Hồ sơ pháp lý, Lịch sử hình thành và Định hướng chiến lược của SGU Tech Corp"))
    [void]$sb.Append((New-WP -Text "Công ty Cổ phần Công nghệ và Thương mại Điện tử SGU Tech (SGU Tech Corp) là doanh nghiệp hoạt động chuyên sâu trong lĩnh vực phân phối, bán lẻ thiết bị công nghệ thông tin cao cấp và cung cấp dịch vụ hậu mãi kỹ thuật tại khu vực phía Nam. Trong bối cảnh chuyển đổi số mạnh mẽ của ngành bán lẻ công nghệ, SGU Tech định vị mình không chỉ là nhà cung cấp phần cứng chính hãng mà còn là doanh nghiệp tiên phong ứng dụng Hệ thống Thông tin Quản lý Quan hệ Khách hàng (CRM) để lắng nghe phản hồi sản phẩm và khảo sát nhu cầu thị trường trước mỗi đợt ra mắt sản phẩm mới." -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Tiêu chí Hồ sơ Doanh nghiệp", "Thông tin chi tiết tại Công ty Cổ phần Công nghệ SGU Tech") -ColWidths @(3000, 6600) -Rows @(
        @("Tên pháp nhân tiếng Việt", "CÔNG TY CỔ PHẦN CÔNG NGHỆ VÀ THƯƠNG MẠI ĐIỆN TỬ SGU TECH"),
        @("Tên giao dịch quốc tế", "SGU Technology & Enterprise Commerce Joint Stock Company (SGU Tech Corp)"),
        @("Tên viết tắt thương hiệu", "SGU TECH"),
        @("Mã số doanh nghiệp", "0318410659 — Cấp bởi Sở Kế hoạch và Đầu tư Thành phố Hồ Chí Minh"),
        @("Trụ sở chính", "Số 273 An Dương Vương, Phường 3, Quận 5, Thành phố Hồ Chí Minh"),
        @("Hệ thống Showroom & TTBH", "Showroom Quận 5 (Trụ sở), Showroom Quận 1, Showroom TP. Thủ Đức & Trung tâm Bảo hành Quận 10"),
        @("Vốn điều lệ đăng ký", "50.000.000.000 VNĐ (Năm mươi tỷ đồng)"),
        @("Quy mô nhân sự & Khách hàng", "45 cán bộ nhân viên chính thức & Hơn 15.000 tài khoản khách hàng thành viên thường xuyên"),
        @("Lĩnh vực hoạt động chính", "1. Phân phối Laptop Gaming, MacBook, Màn hình đồ họa, Bàn phím cơ Custom, Linh kiện PC & Thiết bị mạng.`n2. Dịch vụ Chăm sóc khách hàng, Tiếp nhận & Giải đáp phản hồi chất lượng sản phẩm trực tuyến.`n3. Nghiên cứu thị trường & Tổ chức khảo sát thăm dò nhu cầu sản phẩm công nghệ mới."),
        @("Tầm nhìn chiến lược (2026–2030)", "Trở thành hệ sinh thái bán lẻ công nghệ số hóa toàn diện theo chuẩn quản trị của các tập đoàn công nghệ lớn (như VNG Corporation), lấy dữ liệu nhân khẩu học và phản hồi khách hàng làm hạt nhân điều hành."),
        @("Sứ mệnh cốt lõi (Mission)", "Cung cấp sản phẩm chính hãng với trải nghiệm hậu mãi minh bạch; kết nối trực tiếp mỗi tài khoản khách hàng với Ban Quản lý thông qua cổng phản hồi sản phẩm và khảo sát thị trường thời gian thực.")
    )))

    [void]$sb.Append((New-WHeading3 "1.1.2. Các hoạt động nghiệp vụ trọng tâm của Doanh nghiệp"))
    [void]$sb.Append((New-WP -Text "Hoạt động vận hành hàng ngày tại SGU Tech Corp được tổ chức xoay quanh 3 khối hoạt động nghiệp vụ cốt lõi, gắn liền trực tiếp với phạm vi của đề tài đồ án:" -IndentFirst 420))
    [void]$sb.Append((New-WBullet "1. Hoạt động Quản trị Máy chủ & Định danh Phân quyền Độc lập (Admin Server Operations):" "Doanh nghiệp áp dụng nghiêm ngặt nguyên tắc Phân tách nhiệm vụ (Separation of Duties - SoD) trong an toàn thông tin. Giao diện và quyền hạn của Quản trị viên Máy chủ (Admin Server) được tách biệt hoàn toàn với các phân hệ quản lý nhân sự, quản lý kho, quản lý bán hàng và quản lý quan hệ khách hàng. Admin Server hoàn toàn không can thiệp vào việc tìm kiếm/lọc hàng hóa hay nhà cung cấp mà chỉ chịu trách nhiệm quản lý danh mục tài khoản định danh (Accounts): thêm mới tài khoản, xóa tài khoản vi phạm, khóa/mở khóa trạng thái truy cập và phân quyền cho từng Account vào đúng 1 trong 3 vai trò chuẩn (Admin, Manager, Customer)."))
    [void]$sb.Append((New-WBullet "2. Hoạt động Quản lý Quan hệ Khách hàng & Nghiên cứu Thị trường (CRM Manager Operations):" "Đội ngũ Người Quản lý CRM trực tiếp quản trị vòng đời hồ sơ khách hàng: (1) Thêm một khách hàng mới khi khách đăng ký tại showroom hoặc qua tổng đài; (2) Xóa hồ sơ khách hàng không hợp lệ; (3) Khóa tài khoản khách hàng có hành vi spam đánh giá hoặc vi phạm chính sách; (4) Tiếp nhận toàn bộ phản hồi sản phẩm của khách hàng và gửi câu trả lời giải đáp chính thức; (5) Khai thác báo cáo thống kê nhân khẩu học về tỷ lệ độ tuổi (Dưới 20, 20–30, Trên 30) và tỷ lệ các nhóm sở thích tiêu dùng (Gaming, Đồ họa, Văn phòng, Lập trình); (6) Khởi tạo bảng khảo sát sản phẩm mới và phát hành đến toàn bộ tài khoản khách hàng; (7) Phân tích thống kê kết quả khảo sát (tỷ lệ tham gia, điểm quan tâm trung bình 1–5, phân bổ ý định mua sắm)."))
    [void]$sb.Append((New-WBullet "3. Hoạt động Tương tác Trực tuyến của Khách hàng (Customer Self-Service Operations):" "Khách hàng của SGU Tech sử dụng Cổng Khách hàng trực tuyến để chủ động thực hiện 5 hoạt động: (1) Đăng ký tài khoản khách hàng mới với biểu mẫu tinh gọn; (2) Đăng nhập vào hệ thống; (3) Chỉnh sửa và cập nhật thông tin hồ sơ cá nhân (Họ tên, Số điện thoại, Email, Độ tuổi, Giới tính, Sở thích, Địa chỉ); (4) Gửi phản hồi đánh giá sao (1–5 sao) kèm nhận xét về sản phẩm đã trải nghiệm và theo dõi câu trả lời từ Người quản lý; (5) Nhận thông báo bảng khảo sát mới ngay trong tài khoản và thực hiện gửi kết quả khảo sát."))

    [void]$sb.Append((New-WHeading3 "1.1.3. Cơ cấu tổ chức, Mô hình nhân sự và Ma trận trách nhiệm RACI của Doanh nghiệp"))
    [void]$sb.Append((New-WP -Text "Để vận hành hiệu quả các hoạt động trên, SGU Tech Corp xây dựng mô hình tổ chức trực tuyến – chức năng gồm Ban Giám đốc và các phòng ban chuyên môn hóa cao. Sơ đồ cơ cấu tổ chức và mô hình nhân sự của doanh nghiệp được thể hiện chi tiết tại Hình 1.1 dưới đây:" -IndentFirst 420))

    [void]$sb.Append((New-WImage -RelId "rIdImg1" -WidthEmu 5850000 -HeightEmu 3500000 -Caption "Hình 1.1: Sơ đồ Cơ cấu Tổ chức và Mô hình Nhân sự Công ty Cổ phần Công nghệ SGU Tech" -DocPrId 101))

    [void]$sb.Append((New-WTable -Headers @("Mã PB", "Tên Phòng ban / Bộ phận", "Định biên nhân sự", "Trình độ chuyên môn", "Vai trò trên HTTT", "Chức năng và Nhiệm vụ chuyên môn tại Doanh nghiệp") -ColWidths @(850, 2000, 1100, 1450, 1200, 3000) -Rows @(
        @("BOD", "Ban Giám đốc Điều hành (Board of Directors)", "03 nhân sự (1 TGĐ, 2 PTGĐ)", "Thạc sĩ QTKD / Kỹ sư CNTT", "Giám sát chiến lược", "Phê duyệt chiến lược kinh doanh, quyết định danh mục sản phẩm nhập khẩu dựa trên báo cáo nhân khẩu học và thống kê khảo sát từ Phòng CRM."),
        @("IT-ADM", "Phòng Quản trị Máy chủ & Hạ tầng CNTT (Admin Server)", "05 kỹ sư hệ thống & CSDL", "Kỹ sư CNTT / An toàn thông tin", "Admin (RoleId = 1)", "Vận hành máy chủ ứng dụng và SQL Server; thực hiện sao lưu/phục hồi CSDL; quản lý tập trung bảng Accounts (Thêm, Xóa, Khóa, Phân quyền Role) trên giao diện tách biệt admin.html."),
        @("CRM", "Phòng Quản lý Quan hệ Khách hàng & Thị trường", "13 nhân sự (1 Trưởng phòng, 12 Chuyên viên)", "Cử nhân HTTTQL / Marketing / QTKD", "Manager (RoleId = 2)", "Quản lý hồ sơ khách hàng (Thêm mới, Xóa, Khóa TK); tiếp nhận & trả lời phản hồi sản phẩm; lập báo cáo tỷ lệ độ tuổi & sở thích; tạo khảo sát gửi đến TK khách hàng và thống kê kết quả khảo sát trên quanly.html."),
        @("OPS", "Khối Kinh doanh, Kho vận & Kỹ thuật Bảo hành", "24 nhân viên chuyên trách", "Kỹ thuật viên phần cứng / Cử nhân TMĐT", "Bộ phận phối hợp nội bộ", "Cung cấp thông tin danh mục sản phẩm công nghệ và phối hợp đổi trả/bảo hành khi Phòng CRM chuyển tiếp các phản hồi khiếu nại chất lượng của khách hàng."),
        @("CUST", "Cộng đồng Khách hàng Thành viên SGU Tech", "> 15.000 tài khoản thành viên", "Học sinh, SV, Kỹ sư, Designer, NV văn phòng", "Customer (RoleId = 3)", "Đăng ký tài khoản, đăng nhập, cập nhật thông tin cá nhân (tuổi, sở thích, địa chỉ), gửi đánh giá sản phẩm và thực hiện các bảng khảo sát trên user.html.")
    )))

    [void]$sb.Append((New-WP -Text "Nhằm làm rõ sự phân công quyền hạn và trách nhiệm giữa các bộ phận trong doanh nghiệp (đặc biệt là nguyên tắc tách biệt giữa Admin Server và Người Quản lý CRM), nhóm xây dựng Ma trận phân định trách nhiệm RACI (R – Responsible: Trực tiếp thực hiện; A – Accountable: Chịu trách nhiệm phê duyệt/cuối cùng; C – Consulted: Tham vấn chuyên môn; I – Informed: Được thông báo kết quả):" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Mã CV", "Hoạt động nghiệp vụ trong Hệ thống Thông tin SGU Tech", "Admin Server (IT-ADM)", "Người Quản lý (CRM)", "Khách hàng (CUST)", "Ban Giám đốc (BOD)") -ColWidths @(850, 4150, 1150, 1150, 1150, 1150) -Rows @(
        @("ACT-01", "Vận hành máy chủ, cấu hình bảo mật và tách biệt giao diện Admin", "R / A", "I", "I", "I"),
        @("ACT-02", "Thêm mới, xóa và khóa/mở khóa tài khoản định danh (Account)", "R / A", "C", "I", "I"),
        @("ACT-03", "Phân quyền vai trò (Admin / Manager / Customer) cho Account", "R / A", "I", "I", "C"),
        @("ACT-04", "Sao lưu định kỳ (Full/Diff/Log Backup) và phục hồi CSDL SQL Server", "R / A", "I", "—", "I"),
        @("ACT-05", "Thêm mới một hồ sơ khách hàng vào hệ thống CRM", "I", "R / A", "C", "I"),
        @("ACT-06", "Xóa hồ sơ khách hàng hoặc khóa tài khoản khách hàng vi phạm", "I", "R / A", "I", "I"),
        @("ACT-07", "Tiếp nhận phản hồi sản phẩm và gửi câu trả lời giải đáp chính thức", "—", "R / A", "I", "I"),
        @("ACT-08", "Phân tích Báo cáo khách hàng theo tỷ lệ Độ tuổi và Sở thích", "—", "R", "—", "A / I"),
        @("ACT-09", "Tạo bảng khảo sát sản phẩm mới và phát hành đến TK khách hàng", "—", "R / A", "I", "C"),
        @("ACT-10", "Thống kê kết quả khảo sát (Điểm quan tâm TB, Ý định mua sắm)", "—", "R", "—", "A / I"),
        @("ACT-11", "Tự đăng ký tài khoản khách hàng mới và đăng nhập trực tuyến", "I", "I", "R / A", "—"),
        @("ACT-12", "Chỉnh sửa thông tin cá nhân (Họ tên, SĐT, Tuổi, Giới tính, Sở thích)", "—", "I", "R / A", "—"),
        @("ACT-13", "Gửi đánh giá sao (1–5 sao) và nhận xét phản hồi về sản phẩm", "—", "I", "R / A", "—"),
        @("ACT-14", "Nhận bảng khảo sát trong tài khoản và gửi phiếu trả lời khảo sát", "—", "I", "R / A", "—")
    )))

    [void]$sb.Append((New-WHeading3 "1.1.4. Danh mục Ngành hàng và Sản phẩm Công nghệ kinh doanh tại SGU Tech"))
    [void]$sb.Append((New-WP -Text "Hiện tại, SGU Tech Corp đang phân phối chính hãng 16 dòng sản phẩm công nghệ chủ lực thuộc 5 nhóm danh mục (Laptop & Máy tính xách tay; Màn hình chuyên dụng; Bàn phím & Chuột cao cấp; Linh kiện & Lưu trữ tốc độ cao; Thiết bị mạng & Phụ kiện AI) từ 6 nhà cung cấp đối tác chiến lược (ASUS, Logitech, LG, Synnex FPT, Sony, Samsung). Đây chính là danh mục sản phẩm được tích hợp trực tiếp trong CSDL để khách hàng lựa chọn khi gửi phản hồi đánh giá chất lượng:" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Mã SP", "Tên thương mại sản phẩm tại SGU Tech", "Danh mục nhóm hàng", "Nhà cung cấp", "Giá bán (VNĐ)", "Tồn kho", "Trạng thái") -ColWidths @(900, 3300, 1600, 1400, 1100, 600, 700) -Rows @(
        @("SP001", "Laptop ASUS ROG Strix G16 (i9-14900HX / RTX 4070)", "Laptop & Máy tính xách tay", "ASUS Việt Nam", "38.990.000", "15", "Đang bán"),
        @("SP002", "Laptop Apple MacBook Pro 14 M3 Pro (18GB / 512GB)", "Laptop & Máy tính xách tay", "Synnex FPT", "49.990.000", "8", "Đang bán"),
        @("SP003", "Màn hình Gaming LG UltraGear 27 inch 2K 180Hz IPS", "Màn hình chuyên dụng", "LG Electronics", "7.490.000", "25", "Đang bán"),
        @("SP004", "Màn hình đồ họa ASUS ProArt 27 inch 4K HDR IPS", "Màn hình chuyên dụng", "ASUS Việt Nam", "12.890.000", "12", "Đang bán"),
        @("SP005", "Bàn phím cơ Custom Keychron Q1 Max Nhôm CNC", "Bàn phím & Chuột cao cấp", "Synnex FPT", "4.590.000", "20", "Đang bán"),
        @("SP006", "Bàn phím cơ Gaming Logitech G Pro X TKL Wireless", "Bàn phím & Chuột cao cấp", "Logitech ĐNÁ", "3.990.000", "0", "Hết hàng"),
        @("SP007", "Chuột không dây công thái học Logitech MX Master 3S", "Bàn phím & Chuột cao cấp", "Logitech ĐNÁ", "2.490.000", "40", "Đang bán"),
        @("SP008", "Chuột Gaming Logitech G102 Lightsync RGB Gen 2", "Bàn phím & Chuột cao cấp", "Logitech ĐNÁ", "450.000", "60", "Đang bán"),
        @("SP009", "Tai nghe Gaming HyperX Cloud II Red Surround 7.1", "Bàn phím & Chuột cao cấp", "Synnex FPT", "1.990.000", "30", "Đang bán"),
        @("SP010", "Tai nghe chống ồn không dây Sony WH-1000XM5 Hi-Res", "Bàn phím & Chuột cao cấp", "Sony Việt Nam", "6.990.000", "15", "Đang bán"),
        @("SP011", "Ổ cứng SSD Samsung 990 Pro 2TB NVMe PCIe Gen 4.0", "Linh kiện & Lưu trữ", "Samsung Vina", "4.690.000", "35", "Đang bán"),
        @("SP012", "Router WiFi 6 Gaming ASUS ROG Rapture GT-AX6000", "Thiết bị mạng & AI", "ASUS Việt Nam", "6.890.000", "10", "Đang bán"),
        @("SP013", "Màn hình đồ họa Dell UltraSharp 32 inch 4K IPS Black", "Màn hình chuyên dụng", "Synnex FPT", "19.890.000", "9", "Đang bán"),
        @("SP014", "Bộ nhớ RAM Corsair Vengeance RGB DDR5 64GB 6000MHz", "Linh kiện & Lưu trữ", "Synnex FPT", "5.490.000", "22", "Đang bán"),
        @("SP015", "Card đồ họa ASUS TUF Gaming GeForce RTX 4080 Super", "Linh kiện & Lưu trữ", "ASUS Việt Nam", "29.990.000", "5", "Đang bán"),
        @("SP016", "Webcam 4K Sony Bravia Cam Pro Hội nghị & Livestream", "Thiết bị mạng & AI", "Sony Việt Nam", "5.290.000", "14", "Đang bán")
    )))

    [void]$sb.Append((New-WPageBreak))

    # 1.2. KHẢO SÁT HỆ THỐNG THÔNG TIN CỦA DOANH NGHIỆP (5 ĐIỂM)
    [void]$sb.Append((New-WHeading2 "1.2. Khảo sát Hệ thống Thông tin của Doanh nghiệp (5 điểm)"))
    [void]$sb.Append((New-WHeading3 "1.2.1. Kế hoạch, Phạm vi và Phương pháp luận Khảo sát HTTT"))
    [void]$sb.Append((New-WP -Text "Để đánh giá chính xác thực trạng Hệ thống Thông tin tại Công ty Cổ phần Công nghệ SGU Tech trước khi thiết kế hệ thống mới, nhóm sinh viên đã tiến hành đợt khảo sát thực tế kéo dài 2 tuần (Tuần 2 và Tuần 3) với 3 phương pháp kết hợp: (1) Điều tra bằng bảng câu hỏi khảo sát tiêu chuẩn (25 câu hỏi chuyên sâu bám sát HTTT); (2) Phỏng vấn sâu trực tiếp đại diện 3 nhóm tác nhân; và (3) Thu thập, phân tích các biểu mẫu Excel, Google Forms đang sử dụng tại doanh nghiệp." -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Nhóm đối tượng khảo sát", "Số lượng phiếu phát ra", "Số phiếu thu về hợp lệ", "Tỷ lệ phản hồi", "Mục tiêu khai thác thông tin khảo sát") -ColWidths @(2200, 1300, 1300, 1100, 3700) -Rows @(
        @("1. Kỹ sư Quản trị Máy chủ (IT Admin)", "05 phiếu", "05 phiếu", "100%", "Đánh giá thực trạng tách biệt giao diện Admin Server, quy trình cấp/xóa/khóa Account, phân quyền Role và sao lưu CSDL."),
        @("2. Chuyên viên & Trưởng phòng CRM", "10 phiếu", "10 phiếu", "100%", "Đánh giá thực trạng quản lý hồ sơ KH, tiếp nhận & giải đáp phản hồi sản phẩm, lập báo cáo độ tuổi/sở thích và tổ chức khảo sát."),
        @("3. Khách hàng Thành viên SGU Tech", "20 phiếu", "20 phiếu", "100%", "Đánh giá trải nghiệm đăng ký, đăng nhập, cập nhật thông tin cá nhân, gửi đánh giá sản phẩm và thực hiện khảo sát trực tuyến."),
        @("TỔNG CỘNG MẪU KHẢO SÁT", "35 phiếu", "35 phiếu", "100%", "Đảm bảo tính đại diện cho cả 3 phân hệ: Admin Server, Người Quản lý CRM và Khách hàng.")
    )))

    [void]$sb.Append((New-WHeading3 "1.2.2. Bảng Câu hỏi Điều tra, Khảo sát về HTTT của Doanh nghiệp (25 Câu hỏi Chuyên sâu)"))
    [void]$sb.Append((New-WP -Text "Bảng câu hỏi điều tra khảo sát dưới đây gồm 25 câu hỏi được thiết kế bám sát chặt chẽ các hoạt động của Hệ thống Thông tin Doanh nghiệp tại SGU Tech (vượt yêu cầu tối thiểu 15 câu hỏi của đề bài), kèm theo số liệu thống kê thực tế từ 35 phiếu khảo sát hợp lệ:" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Mã Câu", "Nhóm nghiệp vụ HTTT", "Nội dung câu hỏi điều tra khảo sát về HTTT của Doanh nghiệp", "Các phương án lựa chọn trong phiếu điều tra", "Kết quả thống kê thực tế (n = 35)") -ColWidths @(700, 1400, 3100, 2200, 2200) -Rows @(
        @("Câu 01", "Quản trị Admin Server", "Hiện tại doanh nghiệp đang quản lý danh mục tài khoản người dùng (Accounts) bằng phương thức nào?", "[A] File Excel rời rạc`n[B] Phần mềm cũ gộp chung mọi phân hệ`n[C] Hệ thống IAM tách biệt", "77.1% (27/35) chọn [B]; 22.9% (8/35) chọn [A]; 0% chọn [C]."),
        @("Câu 02", "Quản trị Admin Server", "Giao diện của Quản trị viên máy chủ (Admin Server) hiện có tách biệt với giao diện Quản lý nhân sự, Kho, Bán hàng, CRM không?", "[A] Hoàn toàn chưa tách biệt`n[B] Chỉ ẩn bớt một vài nút`n[C] Đã tách biệt độc lập hoàn toàn", "88.6% (31/35) xác nhận [A] Chưa tách biệt, dễ gây thao tác nhầm sang dữ liệu nghiệp vụ."),
        @("Câu 03", "Quản trị Admin Server", "Trên giao diện Admin hiện tại có đang bị dư thừa các chức năng tìm kiếm, sắp xếp, lọc sản phẩm và nhà cung cấp không?", "[A] Có, đang lẫn lộn rất nhiều`n[B] Ít khi xuất hiện`n[C] Đã loại bỏ hoàn toàn", "91.4% (32/35) chọn [A] Có lẫn lộn, yêu cầu bỏ chức năng lọc SP/NCC khỏi Admin."),
        @("Câu 04", "Quản trị Admin Server", "Quy trình để Admin thêm mới một tài khoản, xóa tài khoản hoặc đổi phân quyền (Role) cho Account hiện mất bao lâu?", "[A] Xử lý tức thời (< 30 giây)`n[B] Từ 1 – 4 giờ làm việc`n[C] Phải can thiệp câu lệnh SQL thủ công", "82.9% (29/35) chọn [B] và [C] do thiếu màn hình phân quyền trực quan."),
        @("Câu 05", "Quản trị Admin Server", "Hệ thống hiện tại có cần duy trì các role dư thừa (HR, Warehouse, Sales) khi phạm vi hệ thống chỉ gồm Admin, Manager và Customer?", "[A] Đang dư thừa, gây rối khi phân quyền`n[B] Bình thường`n[C] Đã rút gọn chuẩn 3 Role", "94.3% (33/35) chọn [A], yêu cầu chuẩn hóa chỉ giữ đúng 3 Role: Admin, Manager, Customer."),
        @("Câu 06", "Quản lý Hồ sơ KH", "Thông tin hồ sơ khách hàng (Họ tên, SĐT, Email, Độ tuổi, Giới tính, Sở thích, Địa chỉ) hiện đang lưu trữ ở đâu?", "[A] Nhiều file Excel/Google Sheets phân tán`n[B] Sổ ghi chép tại quầy`n[C] CSDL SQL Server tập trung", "85.7% (30/35) chọn [A], dẫn đến dữ liệu khách hàng bị phân mảnh và trùng lặp."),
        @("Câu 07", "Quản lý Hồ sơ KH", "Người quản lý CRM có thể trực tiếp thêm mới một khách hàng kèm tài khoản đăng nhập ngay trên giao diện quản lý không?", "[A] Không thể, phải nhờ IT tạo hộ`n[B] Nhập vào Excel rồi import thủ công`n[C] Thêm trực tiếp 1 bước trên web", "88.6% (31/35) chọn [A] và [B], làm chậm quá trình cấp tài khoản cho khách hàng mới."),
        @("Câu 08", "Quản lý Hồ sơ KH", "Khi phát hiện tài khoản khách hàng spam đánh giá hoặc vi phạm, Người quản lý có thể Khóa (Lock) hoặc Xóa khách hàng ngay không?", "[A] Không có nút Khóa/Xóa trực tiếp`n[B] Phải gửi ticket nhờ Admin xóa DB`n[C] Chủ động Khóa/Xóa tức thời", "91.4% (32/35) chọn [A] và [B], Người quản lý hoàn toàn bị động khi xử lý vi phạm."),
        @("Câu 09", "Quản lý Hồ sơ KH", "Khi xóa một khách hàng đã từng gửi phản hồi hoặc làm khảo sát, hệ thống cũ có bị lỗi xung đột khóa ngoại (Foreign Key Error) không?", "[A] Thường xuyên báo lỗi 500 SQL FK`n[B] Thỉnh thoảng lỗi`n[C] Xóa dây chuyền an toàn (Cascade)", "80.0% (28/35) phản ánh [A] Hệ thống cũ báo lỗi khóa ngoại khi xóa khách hàng."),
        @("Câu 10", "Quản lý Hồ sơ KH", "Người quản lý có thể tìm kiếm nhanh hồ sơ khách hàng theo Tên, SĐT, Email hoặc lọc theo Nhóm sở thích tiêu dùng không?", "[A] Phải dùng Ctrl+F trên Excel`n[B] Tìm kiếm rất chậm`n[C] Tìm kiếm & lọc tức thời", "85.7% (30/35) chọn [A], gây mất thời gian khi tra cứu lịch sử khách hàng."),
        @("Câu 11", "Tiếp nhận Phản hồi", "Khách hàng hiện đang gửi phản hồi, đánh giá về chất lượng sản phẩm công nghệ của SGU Tech qua kênh nào?", "[A] Bình luận Facebook / Zalo rời rạc`n[B] Gọi điện thoại tổng đài`n[C] Biểu mẫu phản hồi gắn với sản phẩm", "82.9% (29/35) chọn [A], khiến hơn 40% phản hồi của khách hàng bị trôi và thất lạc."),
        @("Câu 12", "Tiếp nhận Phản hồi", "Hệ thống hiện tại có cho phép khách hàng chấm điểm mức độ hài lòng theo thang chuẩn (1 sao đến 5 sao) cho từng sản phẩm không?", "[A] Không có thang điểm sao`n[B] Chỉ gửi tin nhắn văn bản`n[C] Có chấm 1–5 sao chuẩn hóa", "91.4% (32/35) chọn [A] và [B], không thể đo lường điểm hài lòng trung bình (CSAT)."),
        @("Câu 13", "Tiếp nhận Phản hồi", "Người quản lý có màn hình theo dõi trạng thái xử lý phản hồi (Chờ xử lý / Đã tiếp nhận & Xử lý) và gửi câu trả lời trực tiếp không?", "[A] Hoàn toàn không có`n[B] Ghi chú tạm trên file Excel`n[C] Có luồng tiếp nhận & giải đáp 2 chiều", "94.3% (33/35) chọn [A], dẫn đến nhiều khiếu nại sản phẩm bị bỏ quên."),
        @("Câu 14", "Tiếp nhận Phản hồi", "Khách hàng sau khi gửi phản hồi về sản phẩm có thể xem lại câu trả lời giải đáp chính thức từ Người quản lý ngay trên cổng KH không?", "[A] Không nhìn thấy câu trả lời`n[B] Phải chờ nhân viên gọi điện lại`n[C] Hiển thị công khai, minh bạch trên web", "91.4% (32/35) chọn [A], khách hàng không biết phản hồi của mình đã được xử lý chưa."),
        @("Câu 15", "Tiếp nhận Phản hồi", "Khách hàng có thể lọc xem các đánh giá và phản hồi theo từng sản phẩm cụ thể trước khi quyết định mua sắm không?", "[A] Không có bộ lọc theo sản phẩm`n[B] Phải cuộn tìm thủ công`n[C] Có hộp chọn lọc theo từng sản phẩm", "88.6% (31/35) chọn [A], mong muốn có bộ lọc phản hồi theo từng sản phẩm."),
        @("Câu 16", "Báo cáo Nhân khẩu học", "Dữ liệu Độ tuổi (Age) và Sở thích (Interest) của khách hàng hiện có được thu thập chuẩn hóa trong hồ sơ khách hàng không?", "[A] Bỏ trống hoặc nhập tự do không chuẩn`n[B] Chỉ thu thập một phần nhỏ`n[C] Chuẩn hóa 100% trong bảng CustomerProfiles", "88.6% (31/35) chọn [A], thiếu dữ liệu đầu vào để phân tích nhân khẩu học."),
        @("Câu 17", "Báo cáo Nhân khẩu học", "Người quản lý hiện mất bao lâu để tổng hợp Báo cáo tỷ lệ Độ tuổi và Sở thích của khách hàng trình Ban Giám đốc?", "[A] Mất 1 – 2 ngày làm việc trên Excel`n[B] Mất vài giờ tổng hợp thủ công`n[C] Tự động kết xuất biểu đồ thời gian thực", "85.7% (30/35) xác nhận [A] Mất từ 1 – 2 ngày vẽ biểu đồ thủ công và dễ sai số."),
        @("Câu 18", "Báo cáo Nhân khẩu học", "Khi một khách hàng mới đăng ký hoặc cập nhật lại Độ tuổi/Sở thích, số liệu báo cáo của Người quản lý có tự động cập nhật ngay không?", "[A] Không, phải làm lại file báo cáo mới`n[B] Cập nhật chậm theo quý`n[C] Đồng bộ tự động thời gian thực (Real-time)", "94.3% (33/35) chọn [A], số liệu báo cáo luôn bị trễ so với thực tế."),
        @("Câu 19", "Khảo sát Thị trường", "Khi doanh nghiệp cần thăm dò nhu cầu thị trường cho một sản phẩm sắp ra mắt, công cụ khảo sát nào đang được sử dụng?", "[A] Tạo link Google Forms gửi qua Email/Zalo`n[B] Phát phiếu giấy tại cửa hàng`n[C] Phát hành trực tiếp vào tài khoản KH", "85.7% (30/35) chọn [A], tỷ lệ khách hàng bấm vào link ngoài rất thấp (< 8%)."),
        @("Câu 20", "Khảo sát Thị trường", "Bảng khảo sát hiện tại có hỗ trợ thiết lập Thời hạn khảo sát (Không giới hạn / Theo số ngày / Theo ngày hết hạn cụ thể) và Khóa/Mở khóa khảo sát không?", "[A] Không hỗ trợ quản lý hạn tự động`n[B] Phải vào đóng form bằng tay`n[C] Tự động kiểm tra hạn & cho phép Khóa/Mở", "88.6% (31/35) chọn [A], cần cơ chế quản lý thời hạn (ExpiresAt) và khóa khảo sát linh hoạt."),
        @("Câu 21", "Khảo sát Thị trường", "Khách hàng khi đăng nhập vào tài khoản có nhận được cảnh báo số lượng khảo sát mới chưa thực hiện và làm khảo sát ngay trên web không?", "[A] Không có thông báo trong tài khoản`n[B] Phải kiểm tra email rác`n[C] Có huy hiệu thông báo & làm trực tiếp", "97.1% (34/35) chọn [A], đề xuất tích hợp mục Khảo sát thị trường ngay trong cổng KH."),
        @("Câu 22", "Khảo sát Thị trường", "Hệ thống cũ có ngăn chặn được tình trạng một tài khoản khách hàng gửi câu trả lời lặp lại nhiều lần cho cùng một bảng khảo sát không?", "[A] Không chặn được (dễ bị spam kết quả)`n[B] Phải lọc trùng thủ công trên Excel`n[C] Ràng buộc mỗi tài khoản chỉ làm 1 lần/khảo sát", "85.7% (30/35) chọn [A], làm sai lệch nghiêm trọng thống kê khảo sát."),
        @("Câu 23", "Thống kê Khảo sát", "Người quản lý có thể xem thống kê chi tiết từng bảng khảo sát (Tổng số phản hồi, Điểm quan tâm TB 1–5, Tỷ lệ Rất muốn mua / Đang cân nhắc / Không mua) ngay trên phần mềm không?", "[A] Không có màn hình thống kê khảo sát`n[B] Phải tải file CSV về tự tính công thức`n[C] Có biểu đồ & bảng chi tiết từng khách hàng", "91.4% (32/35) chọn [A] và [B], thiếu công cụ phân tích tự động kết quả khảo sát."),
        @("Câu 24", "Giao diện Người dùng", "Đánh giá của Anh/Chị về biểu mẫu đăng ký khách hàng và thẩm mỹ giao diện của hệ thống hiện tại?", "[A] Giao diện rời rạc, form đăng ký rườm rà`n[B] Tạm chấp nhận được`n[C] Chuẩn thiết kế doanh nghiệp lớn (như VNG Corp)", "91.4% (32/35) chọn [A], yêu cầu thiết kế lại giao diện chuyên nghiệp theo chuẩn VNG Corp."),
        @("Câu 25", "An toàn & Sao lưu CSDL", "Doanh nghiệp hiện đã có phương án và kịch bản tự động Sao lưu (Backup) và Phục hồi (Restore) CSDL SQL Server khi gặp sự cố chưa?", "[A] Chưa có kịch bản Backup/Restore chuẩn`n[B] Chỉ copy file thủ công không định kỳ`n[C] Có kịch bản Full/Diff/Log Backup & Restore", "94.3% (33/35) chọn [A], tiềm ẩn nguy cơ mất trắng dữ liệu khách hàng khi hỏng ổ cứng.")
    )))

    [void]$sb.Append((New-WHeading3 "1.2.3. Biên bản Phỏng vấn Chuyên sâu Đại diện 3 Nhóm Tác nhân tại Doanh nghiệp"))
    [void]$sb.Append((New-WP -Text "Bên cạnh 25 câu hỏi khảo sát định lượng, nhóm đã thực hiện 03 buổi phỏng vấn trực tiếp với đại diện Quản trị viên máy chủ, Trưởng phòng Quản lý CRM và Khách hàng thân thiết để ghi nhận đầy đủ các yêu cầu nghiệp vụ cốt lõi:" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Thông tin Biên bản Phỏng vấn #01", "Nội dung trao đổi và Yêu cầu nghiệp vụ ghi nhận từ Quản trị viên Máy chủ") -ColWidths @(2800, 6800) -Rows @(
        @("Người được phỏng vấn", "Ông Nguyễn Quản Trị Hệ Thống — Trưởng bộ phận Quản trị Máy chủ & Hạ tầng CNTT (Tài khoản: admin)"),
        @("Thời gian & Địa điểm", "09:00 – 10:30, Thứ Hai (Tuần 3) tại Phòng Server Tầng 3 — Trụ sở SGU Tech, 273 An Dương Vương, Quận 5"),
        @("Người thực hiện phỏng vấn", "Huỳnh Tuấn Tài (3123411261) & Hoàng Thái Thanh (3123411267)"),
        @("Vấn đề bất cập hiện tại", "Phần mềm cũ gộp chung màn hình của Admin với màn hình quản lý kho, bán hàng và nhân sự. Trên màn hình Admin lại bày biện cả bảng tìm kiếm, lọc sản phẩm và nhà cung cấp không đúng chức trách của Admin Server, trong khi chức năng quản lý Account và phân quyền lại rất sơ sài, còn tồn tại các role thừa (HR, Warehouse, Sales) không sử dụng."),
        @("Yêu cầu cốt lõi đặt ra cho Hệ thống mới", "1. Giao diện của Admin Server (admin.html) bắt buộc phải tách biệt hoàn toàn với giao diện của quản lý nhân sự, quản lý kho, quản lý bán hàng và quản lý CRM.`n2. Loại bỏ hoàn toàn chức năng xem, tìm kiếm nâng cao, sắp xếp, lọc sản phẩm và nhà cung cấp ra khỏi giao diện Admin.`n3. Chuẩn hóa hệ thống chỉ giữ đúng 3 Role: Admin, Manager, Customer.`n4. Admin có toàn quyền Thêm tài khoản mới, Xóa tài khoản, Khóa/Mở khóa tài khoản và Phân quyền cho Account.")
    )))

    [void]$sb.Append((New-WTable -Headers @("Thông tin Biên bản Phỏng vấn #02", "Nội dung trao đổi và Yêu cầu nghiệp vụ ghi nhận từ Người Quản lý CRM") -ColWidths @(2800, 6800) -Rows @(
        @("Người được phỏng vấn", "Ông Trần Trưởng Phòng CRM — Trưởng phòng Quản lý Quan hệ Khách hàng (Tài khoản: quanly)"),
        @("Thời gian & Địa điểm", "14:00 – 15:45, Thứ Tư (Tuần 3) tại Phòng Họp CRM Tầng 2 — Trụ sở SGU Tech, Quận 5"),
        @("Người thực hiện phỏng vấn", "Lê Nguyễn Phú Hải (3123411080) & Huỳnh Tuấn Tài (3123411261)"),
        @("Vấn đề bất cập hiện tại", "Hồ sơ khách hàng đang nằm rải rác trên nhiều file Excel nên không thể khóa nhanh các tài khoản spam hay thống kê tức thời tỷ lệ độ tuổi, sở thích. Khi khách phản hồi về sản phẩm trên mạng xã hội thì không có công cụ theo dõi trạng thái giải đáp. Việc khảo sát sản phẩm mới qua Google Forms rời rạc không gửi trực tiếp vào tài khoản khách hàng được."),
        @("Yêu cầu cốt lõi đặt ra cho Hệ thống mới", "Xây dựng giao diện Người Quản lý (quanly.html) chuyên nghiệp theo chuẩn doanh nghiệp lớn (như VNG Corp), đáp ứng đầy đủ 7 chức năng:`n1. Thêm một khách hàng mới.`n2. Xóa khách hàng.`n3. Khóa tài khoản khách hàng.`n4. Tiếp nhận phản hồi của khách hàng và gửi câu trả lời giải đáp.`n5. Báo cáo về khách hàng: thống kê tỷ lệ độ tuổi và sở thích bằng biểu đồ trực quan.`n6. Tạo bảng khảo sát (hỗ trợ đặt thời hạn) và gửi trực tiếp đến tài khoản khách hàng.`n7. Thống kê kết quả khảo sát (tỷ lệ tham gia, điểm quan tâm trung bình, phân bổ ý định mua sắm).")
    )))

    [void]$sb.Append((New-WTable -Headers @("Thông tin Biên bản Phỏng vấn #03", "Nội dung trao đổi và Yêu cầu nghiệp vụ ghi nhận từ Đại diện Khách hàng") -ColWidths @(2800, 6800) -Rows @(
        @("Người được phỏng vấn", "Anh Nguyễn Văn An — Khách hàng thành viên thân thiết của SGU Tech (Tài khoản: khachhang1)"),
        @("Thời gian & Địa điểm", "10:00 – 11:15, Thứ Sáu (Tuần 3) tại Khu vực Trải nghiệm Showroom SGU Tech Quận 5"),
        @("Người thực hiện phỏng vấn", "Nguyễn Đăng Khoa (3123411157) & Lê Nguyễn Phú Hải (3123411080)"),
        @("Vấn đề bất cập hiện tại", "Khi muốn đăng ký tài khoản thành viên thì biểu mẫu cũ bắt nhập quá nhiều trường rườm rà, giao diện chật hẹp thiếu chuyên nghiệp. Khi muốn góp ý về sản phẩm đã mua hoặc cập nhật lại số điện thoại, địa chỉ, sở thích thì không có cổng tự phục vụ trực tuyến."),
        @("Yêu cầu cốt lõi đặt ra cho Hệ thống mới", "Xây dựng Cổng Khách hàng (user.html) có giao diện rộng rãi, hiện đại, đáp ứng 5 chức năng:`n1. Đăng ký tài khoản khách hàng nhanh gọn.`n2. Đăng nhập an toàn.`n3. Chỉnh sửa thông tin cá nhân (Họ tên, SĐT, Email, Độ tuổi, Giới tính, Sở thích, Địa chỉ).`n4. Gửi phản hồi về sản phẩm (chấm 1–5 sao, nhập nhận xét, lọc xem phản hồi theo sản phẩm và xem câu trả lời của Người quản lý).`n5. Nhận được bảng khảo sát ngay trong tài khoản và thực hiện trả lời khảo sát.")
    )))

    [void]$sb.Append((New-WHeading3 "1.2.4. Tổng kết Kết quả Khảo sát, Phân tích SWOT và Kết luận cho Hệ thống Thông tin"))
    [void]$sb.Append((New-WP -Text "Tổng hợp dữ liệu từ 35 phiếu điều tra khảo sát (25 câu hỏi) và 03 biên bản phỏng vấn sâu, nhóm lập bảng thống kê tổng hợp theo 5 nhóm tiêu chí và phân tích đối sánh giữa Hệ thống cũ (AS-IS) với Hệ thống mới (TO-BE):" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Nhóm tiêu chí khảo sát HTTT", "Số câu hỏi", "Tỷ lệ đánh giá Hệ thống cũ Yếu / Bất cập", "Tỷ lệ đồng thuận Xây dựng HTTT mới", "Kết luận trọng tâm cần giải quyết trong Đồ án") -ColWidths @(2300, 1000, 1500, 1500, 3300) -Rows @(
        @("1. Quản trị Admin Server & Phân quyền (Câu 01 – 05)", "05 câu", "86.9%", "97.1%", "Tách biệt hoàn toàn giao diện Admin Server; bỏ lọc SP/NCC; chuẩn hóa 3 Role (Admin, Manager, Customer); Thêm/Xóa/Khóa/Phân quyền Account."),
        @("2. Quản lý Hồ sơ Khách hàng (Câu 06 – 10)", "05 câu", "86.3%", "94.3%", "Tập trung hồ sơ KH về SQL Server; cho phép Người quản lý Thêm mới, Xóa (Cascade), Khóa/Mở khóa tài khoản khách hàng tức thời."),
        @("3. Tiếp nhận & Giải đáp Phản hồi SP (Câu 11 – 15)", "05 câu", "89.7%", "97.1%", "Xây dựng luồng đánh giá 1–5 sao gắn với 16 sản phẩm; cho phép lọc theo sản phẩm và hiển thị giải đáp chính thức từ Người quản lý."),
        @("4. Báo cáo Nhân khẩu học Độ tuổi & Sở thích (Câu 16 – 18)", "03 câu", "89.5%", "97.1%", "Tự động hóa 100% báo cáo thống kê tỷ lệ Độ tuổi (Dưới 20, 20–30, Trên 30) và tỷ lệ các nhóm Sở thích bằng biểu đồ thời gian thực."),
        @("5. Khảo sát Thị trường & An toàn CSDL (Câu 19 – 25)", "07 câu", "90.6%", "98.6%", "Phát hành khảo sát trực tiếp đến tài khoản KH; chống gửi trùng; tự động thống kê kết quả khảo sát; thiết lập kịch bản Backup/Restore CSDL.")
    )))

    [void]$sb.Append((New-WTable -Headers @("Tiêu chí đối sánh", "Hiện trạng Hệ thống Cũ (AS-IS)", "Hệ thống Thông tin Mới Xây dựng (TO-BE)") -ColWidths @(2200, 3700, 3700) -Rows @(
        @("Kiến trúc giao diện Admin Server", "Gộp chung với Kho, Nhân sự, Bán hàng; lẫn lộn bảng lọc sản phẩm & nhà cung cấp; tồn tại 6 role dư thừa.", "Tách biệt hoàn toàn tại admin.html; loại bỏ triệt để lọc SP/NCC; chuẩn hóa đúng 3 Role: Admin, Manager, Customer."),
        @("Quản lý Hồ sơ Khách hàng", "Lưu trên nhiều file Excel rời rạc; không thể khóa tài khoản khách hàng; xóa khách hàng gây lỗi khóa ngoại.", "Lưu tập trung trên bảng Accounts & CustomerProfiles; hỗ trợ Thêm mới, Khóa/Mở khóa và Xóa dây chuyền an toàn."),
        @("Tiếp nhận & Giải đáp Phản hồi", "Phản hồi trôi nổi trên Zalo/Facebook; không có thang điểm 1–5 sao; khách hàng không thấy câu trả lời.", "Khách hàng chấm 1–5 sao theo từng sản phẩm trên user.html; Quản lý giải đáp trực tiếp trên quanly.html."),
        @("Báo cáo Độ tuổi & Sở thích", "Mất 1–2 ngày lọc Excel vẽ biểu đồ thủ công; dữ liệu tĩnh nhanh lỗi thời.", "Truy vấn thời gian thực qua API /api/admin/crm/reports/demographics, tự động vẽ biểu đồ tròn & biểu đồ cột."),
        @("Khảo sát & Thống kê Khảo sát", "Dùng Google Forms bên ngoài, tỷ lệ tham gia < 8%, không chặn được gửi trùng, phải tính tay kết quả.", "Phát hành trực tiếp vào tài khoản KH, chặn gửi trùng 100%, tự động thống kê điểm quan tâm TB & ý định mua sắm."),
        @("An toàn & Sao lưu CSDL", "Không có quy trình sao lưu định kỳ, nguy cơ mất dữ liệu cao.", "Chiến lược sao lưu 3 tầng (Full, Differential, Transaction Log Backup) và kịch bản phục hồi Point-in-Time.")
    )))

    [void]$sb.Append((New-WPageBreak))
    return $sb.ToString()
}
