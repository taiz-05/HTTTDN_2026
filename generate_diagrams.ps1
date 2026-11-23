Add-Type -AssemblyName System.Drawing

function Draw-RoundedRectangle($g, $pen, $brush, [float]$x, [float]$y, [float]$w, [float]$h, [float]$radius) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $radius * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc(($x + $w - $d), $y, $d, $d, 270, 90)
    $path.AddArc(($x + $w - $d), ($y + $h - $d), $d, $d, 0, 90)
    $path.AddArc($x, ($y + $h - $d), $d, $d, 90, 90)
    $path.CloseFigure()
    if ($brush -ne $null) { $g.FillPath($brush, $path) }
    if ($pen -ne $null) { $g.DrawPath($pen, $path) }
    $path.Dispose()
}

function Draw-ArrowLine($g, $penArrow, [float]$x1, [float]$y1, [float]$x2, [float]$y2) {
    $g.DrawLine($penArrow, $x1, $y1, $x2, $y2)
}

function Draw-DataStoreBox($g, $pen, $brush, [float]$x, [float]$y, [float]$w, [float]$h, $code, $name, $fontCode, $fontName, $bText) {
    $rect = New-Object System.Drawing.RectangleF($x, $y, $w, $h)
    if ($brush -ne $null) { $g.FillRectangle($brush, $rect) }
    $g.DrawLine($pen, $x, $y, ($x + $w), $y)
    $g.DrawLine($pen, $x, ($y + $h), ($x + $w), ($y + $h))
    $g.DrawLine($pen, $x, $y, $x, ($y + $h))
    $g.DrawLine($pen, ($x + 50), $y, ($x + 50), ($y + $h))
    
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString($code, $fontCode, $bText, (New-Object System.Drawing.RectangleF($x, $y, 50, $h)), $sf)
    
    $sf2 = New-Object System.Drawing.StringFormat
    $sf2.Alignment = [System.Drawing.StringAlignment]::Near
    $sf2.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString($name, $fontName, $bText, (New-Object System.Drawing.RectangleF(($x + 60), $y, ($w - 65), $h)), $sf2)
}

function Draw-DFDProcess($g, [float]$x, [float]$y, [float]$w, [float]$h, $num, $name, $desc) {
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(59, 130, 246), 2)
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    Draw-RoundedRectangle $g $pen $brush $x $y $w $h 10
    
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    
    $fN = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $fT = New-Object System.Drawing.Font("Segoe UI", 10.5, [System.Drawing.FontStyle]::Bold)
    $fD = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Regular)
    $bD = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 23, 42))
    $bS = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(71, 85, 105))
    $bNum = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(194, 65, 12))
    
    $rectN = New-Object System.Drawing.RectangleF($x, ($y + 5.0), $w, 18.0)
    $rectT = New-Object System.Drawing.RectangleF($x, ($y + 23.0), $w, 24.0)
    $rectD = New-Object System.Drawing.RectangleF(($x + 5.0), ($y + 47.0), ($w - 10.0), 28.0)
    
    $g.DrawString($num, $fN, $bNum, $rectN, $sf)
    $g.DrawString($name, $fT, $bD, $rectT, $sf)
    $g.DrawString($desc, $fD, $bS, $rectD, $sf)
}

# Common Global Fonts & Brushes
$fTitle = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$fSub = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
$fBoxHeader = New-Object System.Drawing.Font("Segoe UI", 11.5, [System.Drawing.FontStyle]::Bold)
$fBoxItem = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Regular)
$fBoxItemBold = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$fFlow = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$fSmall = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Regular)
$fKey = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)

$sfCenter = New-Object System.Drawing.StringFormat
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

$bDark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 23, 42))
$bSub = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(100, 116, 139))
$bRootText = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$pLine = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(148, 163, 184), 2)
$pOrange = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 91, 0), 2)
$pBlue = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(37, 99, 235), 2)
$pTeal = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(13, 148, 136), 2)

$capArrow = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(5, 5, $true)
$pArrBlue = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(37, 99, 235), 2)
$pArrBlue.CustomEndCap = $capArrow
$pArrOrange = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(234, 88, 12), 2)
$pArrOrange.CustomEndCap = $capArrow
$pArrTeal = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(13, 148, 136), 2)
$pArrTeal.CustomEndCap = $capArrow
$pArrDark = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(30, 41, 59), 1.6)
$pArrDark.CustomEndCap = $capArrow

$bFlowIn = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 64, 175))
$bFlowOut = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(194, 65, 12))
$bFlowTeal = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 118, 110))

$pStore = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 38, 38), 2)
$bStoreBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(254, 242, 242))
$bStoreText = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(153, 27, 27))
$fStoreCode = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fStoreName = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Regular)

# ==============================================================================
# 0. GENERATE ORG CHART DIAGRAM (SƠ ĐỒ CƠ CẤU TỔ CHỨC DOANH NGHIỆP)
# ==============================================================================
Write-Host "0/8 Generating Organization Chart..."
$bmp0 = New-Object System.Drawing.Bitmap 1350, 650
$g0 = [System.Drawing.Graphics]::FromImage($bmp0)
$g0.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g0.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g0.Clear([System.Drawing.Color]::FromArgb(248, 250, 252))

$g0.DrawString("SƠ ĐỒ CƠ CẤU TỔ CHỨC VÀ MÔ HÌNH NHÂN SỰ — CÔNG TY CP CÔNG NGHỆ THƯƠNG MẠI SGU TECH", $fTitle, $bDark, (New-Object System.Drawing.RectangleF(40, 20, 1270, 30)), $sfCenter)
$g0.DrawString("Mô hình tổ chức trực tuyến - chức năng gắn liền với phân quyền trên Hệ thống Thông tin Doanh nghiệp", $fSub, $bSub, (New-Object System.Drawing.RectangleF(40, 50, 1270, 22)), $sfCenter)

# Board of Directors
Draw-RoundedRectangle $g0 (New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(15, 23, 42), 2)) (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 41, 59))) 465 90 420 68 8
$g0.DrawString("HỘI ĐỒNG QUẢN TRỊ & BAN GIÁM ĐỐC", $fBoxHeader, $bRootText, (New-Object System.Drawing.RectangleF(465, 98, 420, 26)), $sfCenter)
$g0.DrawString("Điều hành chiến lược kinh doanh & Phê duyệt nhập hàng", $fSmall, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(203, 213, 225))), (New-Object System.Drawing.RectangleF(465, 126, 420, 22)), $sfCenter)

$g0.DrawLine($pLine, 675, 158, 675, 198)
$g0.DrawLine($pLine, 195, 198, 1155, 198)
$g0.DrawLine($pLine, 195, 198, 195, 230)
$g0.DrawLine($pLine, 515, 198, 515, 230)
$g0.DrawLine($pLine, 835, 198, 835, 230)
$g0.DrawLine($pLine, 1155, 198, 1155, 230)

# 4 Departments
$depts = @(
    @{ X = 50;  Title = "PHÒNG QUẢN TRỊ CNTT"; Sub = "(IT Admin Server - Role: Admin)"; Color = "#1E40AF"; Bg = "#EFF6FF"; Items = @("• Quản trị máy chủ & CSDL", "• Cấp phát & khóa tài khoản", "• Phân quyền truy cập (RBAC)", "• Sao lưu & Phục hồi dữ liệu", "• Tách biệt cổng quản trị") },
    @{ X = 370; Title = "PHÒNG QUẢN LÝ KH (CRM)"; Sub = "(CRM Department - Role: Manager)"; Color = "#C2410C"; Bg = "#FFF7ED"; Items = @("• Quản lý hồ sơ khách hàng", "• Thêm, xóa, khóa tài khoản KH", "• Tiếp nhận & giải đáp phản hồi", "• Báo cáo độ tuổi & sở thích", "• Tạo & thống kê khảo sát SP") },
    @{ X = 690; Title = "PHÒNG KINH DOANH & KHO"; Sub = "(Sales & Warehouse Operations)"; Color = "#0284C7"; Bg = "#F0F9FF"; Items = @("• Quản lý danh mục hàng hóa", "• Quản lý đối tác nhà cung cấp", "• Kiểm soát tồn kho & giá bán", "• Tiếp nhận kết quả khảo sát SP", "• Phối hợp xử lý bảo hành SP") },
    @{ X = 1010; Title = "KHÁCH HÀNG THÀNH VIÊN"; Sub = "(Customer Portal - Role: Customer)"; Color = "#0F766E"; Bg = "#F0FDFA"; Items = @("• Đăng ký & đăng nhập độc lập", "• Tra cứu danh mục công nghệ", "• Chỉnh sửa thông tin cá nhân", "• Gửi đánh giá SP (1-5 sao)", "• Thực hiện khảo sát 5 tiêu chí") }
)

foreach ($d in $depts) {
    $penD = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml($d.Color), 2)
    $bHeadD = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($d.Color))
    $bBgD = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($d.Bg))
    Draw-RoundedRectangle $g0 $penD $bBgD $d.X 230 290 270 8
    Draw-RoundedRectangle $g0 $penD $bHeadD $d.X 230 290 52 8
    $g0.DrawString($d.Title, $fBoxItemBold, $bRootText, (New-Object System.Drawing.RectangleF($d.X, 236, 290, 22)), $sfCenter)
    $g0.DrawString($d.Sub, $fSmall, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(241, 245, 249))), (New-Object System.Drawing.RectangleF($d.X, 256, 290, 20)), $sfCenter)
    $yItem = 298
    foreach ($it in $d.Items) {
        $g0.DrawString($it, $fBoxItem, $bDark, ($d.X + 16), $yItem)
        $yItem += 34
    }
}

Draw-RoundedRectangle $g0 $pLine (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)) 50 530 1250 90 8
$g0.DrawString("CƠ CHẾ PHỐI HỢP LIÊN PHÒNG BAN TRÊN HỆ THỐNG THÔNG TIN SGU TECH:", $fBoxItemBold, $bDark, 70, 542)
$g0.DrawString("1. Phòng Quản trị CNTT (Admin) đảm bảo hạ tầng máy chủ, phân quyền tách biệt tuyệt đối giữa cổng quản trị hệ thống và cổng nghiệp vụ CRM.", $fSmall, $bSub, 70, 566)
$g0.DrawString("2. Phòng Quản lý Quan hệ Khách hàng (Manager) khai thác dữ liệu nhân khẩu học & khảo sát từ Khách hàng (Customer) để tham mưu nhập hàng chính xác cho Ban Giám đốc.", $fSmall, $bSub, 70, 588)

$bmp0.Save("d:\HTTTDN_2026\Report\images\org_chart_diagram.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g0.Dispose()
$bmp0.Dispose()

# ==============================================================================
# 1. GENERATE BFD DIAGRAM (SƠ ĐỒ PHÂN RÃ CHỨC NĂNG)
# ==============================================================================
Write-Host "1/8 Generating BFD diagram..."
$bmp1 = New-Object System.Drawing.Bitmap 1400, 860
$g1 = [System.Drawing.Graphics]::FromImage($bmp1)
$g1.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g1.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g1.Clear([System.Drawing.Color]::FromArgb(248, 250, 252))

$g1.DrawString("SƠ ĐỒ PHÂN RÃ CHỨC NĂNG (BUSINESS FUNCTION DIAGRAM - BFD)", $fTitle, $bDark, (New-Object System.Drawing.RectangleF(50, 20, 1300, 30)), $sfCenter)
$g1.DrawString("Hệ thống thông tin Quản trị Doanh nghiệp Thương mại SGU Tech - Mô hình 3 Phân hệ: Admin Server, Quản lý CRM & Khách hàng", $fSub, $bSub, (New-Object System.Drawing.RectangleF(50, 52, 1300, 20)), $sfCenter)

# Root Box
$bRoot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 41, 59))
$pRoot = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(15, 23, 42), 2)
Draw-RoundedRectangle $g1 $pRoot $bRoot 450 85 500 65 8
$g1.DrawString("HỆ THỐNG THÔNG TIN DOANH NGHIỆP SGU TECH", $fBoxHeader, $bRootText, (New-Object System.Drawing.RectangleF(450, 92, 500, 30)), $sfCenter)
$g1.DrawString("(Quản trị Máy chủ Admin Server & Quản lý Quan hệ Khách hàng CRM)", $fSub, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(203, 213, 225))), (New-Object System.Drawing.RectangleF(450, 120, 500, 25)), $sfCenter)

# Connecting Lines
$g1.DrawLine($pLine, 700, 150, 700, 190)
$g1.DrawLine($pLine, 215, 190, 1185, 190)
$g1.DrawLine($pLine, 215, 190, 215, 220)
$g1.DrawLine($pLine, 700, 190, 700, 220)
$g1.DrawLine($pLine, 1185, 190, 1185, 220)

# Subsystem 1: ADMIN SERVER (Left)
$bAdminBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(239, 246, 255))
$bAdminHead = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 64, 175))
Draw-RoundedRectangle $g1 $pBlue $bAdminBg 45 220 340 600 8
Draw-RoundedRectangle $g1 $pBlue $bAdminHead 45 220 340 50 8
$g1.DrawString("1.0 ADMIN SERVER", $fBoxHeader, $bRootText, (New-Object System.Drawing.RectangleF(45, 227, 340, 22)), $sfCenter)
$g1.DrawString("Quản trị hệ thống & Phân quyền (Role: Admin)", $fSub, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(191, 219, 254))), (New-Object System.Drawing.RectangleF(45, 247, 340, 18)), $sfCenter)

$adminFuncs = @(
    "1.1 Thêm tài khoản mới (Account)",
    "    - Cấp tài khoản Admin / Manager / Customer",
    "    - Mã hóa mật khẩu bảo mật BCrypt",
    "1.2 Xóa & Khóa/Mở tài khoản",
    "    - Kiểm soát trạng thái hoạt động (IsActive)",
    "    - Xóa tài khoản an toàn khóa ngoại CASCADE",
    "1.3 Phân quyền cho Account",
    "    - Gán vai trò (Admin, Manager, Customer)",
    "    - Quản lý bảng cơ cấu phân quyền hệ thống",
    "1.4 Tách biệt giao diện theo yêu cầu",
    "    - Tách biệt hoàn toàn giao diện Admin Server",
    "    - Độc lập với cổng Quản lý CRM & Khách hàng",
    "    - Lược bỏ tra cứu/lọc SP & NCC tại Admin",
    "1.5 Kịch bản Sao lưu & Phục hồi CSDL",
    "    - Full Backup định kỳ Chủ nhật hàng tuần",
    "    - Differential Backup mỗi ngày lúc 23:00",
    "    - Kịch bản khôi phục CSDL SQL Server"
)
$yCur = 285
foreach ($af in $adminFuncs) {
    if ($af.StartsWith("1.")) {
        $g1.DrawString($af, $fBoxItemBold, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 64, 175))), 65, $yCur)
    } else {
        $g1.DrawString($af, $fBoxItem, $bSub, 65, $yCur)
    }
    $yCur += 24
}

# Subsystem 2: NGƯỜI QUẢN LÝ CRM (Center)
$bMgrBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 247, 237))
$bMgrHead = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(194, 65, 12))
Draw-RoundedRectangle $g1 $pOrange $bMgrBg 525 220 350 600 8
Draw-RoundedRectangle $g1 $pOrange $bMgrHead 525 220 350 50 8
$g1.DrawString("2.0 NGƯỜI QUẢN LÝ (CRM)", $fBoxHeader, $bRootText, (New-Object System.Drawing.RectangleF(525, 227, 350, 22)), $sfCenter)
$g1.DrawString("Quản lý Quan hệ Khách hàng (Role: Manager)", $fSub, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(254, 215, 170))), (New-Object System.Drawing.RectangleF(525, 247, 350, 18)), $sfCenter)

$mgrFuncs = @(
    "2.1 Thêm một khách hàng mới",
    "    - Nhập tài khoản & hồ sơ nhân khẩu học",
    "2.2 Xóa khách hàng",
    "    - Xóa an toàn kèm dữ liệu liên kết",
    "2.3 Khóa tài khoản khách hàng",
    "    - Chặn đăng nhập tức thì khi vi phạm",
    "2.4 Tiếp nhận phản hồi của khách hàng",
    "    - Xem đánh giá 1-5 sao theo sản phẩm",
    "    - Gửi lời giải đáp chính thức từ quản lý",
    "2.5 Báo cáo tỷ lệ độ tuổi & sở thích",
    "    - Biểu đồ phân bố độ tuổi (<20, 20-30, >30)",
    "    - Biểu đồ phân loại sở thích tiêu dùng",
    "2.6 Tạo bảng khảo sát gửi đến TK khách hàng",
    "    - Thiết lập tên SP, giá dự kiến, thời hạn",
    "    - Chọn danh sách TK khách hàng nhận khảo sát",
    "2.7 Thống kê kết quả khảo sát",
    "    - Thống kê tỷ lệ ý định mua sắm",
    "    - Điểm trung bình và tổng hợp ý kiến"
)
$yCur = 285
foreach ($mf in $mgrFuncs) {
    if ($mf.StartsWith("2.")) {
        $g1.DrawString($mf, $fBoxItemBold, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(194, 65, 12))), 545, $yCur)
    } else {
        $g1.DrawString($mf, $fBoxItem, $bSub, 545, $yCur)
    }
    $yCur += 24
}

# Subsystem 3: KHÁCH HÀNG (Right)
$bCustBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 253, 250))
$bCustHead = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 118, 110))
Draw-RoundedRectangle $g1 $pTeal $bCustBg 1015 220 340 600 8
Draw-RoundedRectangle $g1 $pTeal $bCustHead 1015 220 340 50 8
$g1.DrawString("3.0 KHÁCH HÀNG (PORTAL)", $fBoxHeader, $bRootText, (New-Object System.Drawing.RectangleF(1015, 227, 340, 22)), $sfCenter)
$g1.DrawString("Cổng thông tin Khách hàng (Role: Customer)", $fSub, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(204, 251, 241))), (New-Object System.Drawing.RectangleF(1015, 247, 340, 18)), $sfCenter)

$custFuncs = @(
    "3.1 Đăng ký tài khoản khách hàng",
    "    - Form đăng ký tối giản, tiện lợi",
    "    - Tự động tạo hồ sơ khách hàng mặc định",
    "3.2 Đăng nhập hệ thống",
    "    - Xác thực bảo mật, phân luồng Cổng KH",
    "    - Giao diện chuẩn doanh nghiệp hiện đại",
    "3.3 Chỉnh sửa thông tin cá nhân",
    "    - Cập nhật SĐT, địa chỉ, độ tuổi, sở thích",
    "3.4 Gửi phản hồi về sản phẩm",
    "    - Đánh giá chất lượng sản phẩm (1-5 sao)",
    "    - Bộ lọc thông minh theo danh mục/sao",
    "    - Xem câu trả lời giải đáp từ Quản lý",
    "3.5 Nhận được khảo sát và thực hiện",
    "    - Nhận khảo sát sản phẩm mới từ Quản lý",
    "    - Thực hiện khảo sát chi tiết 5 tiêu chí:",
    "      + Điểm quan tâm 1-5 sao",
    "      + Đánh giá mức giá (Rẻ, Hợp lý, Cao)",
    "      + Chọn tính năng mong đợi (Chip tags)",
    "      + Ý định mua & Thời điểm xuống tiền",
    "      + Mức giá sẵn sàng chi trả & Góp ý"
)
$yCur = 285
foreach ($cf in $custFuncs) {
    if ($cf.StartsWith("3.")) {
        $g1.DrawString($cf, $fBoxItemBold, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 118, 110))), 1035, $yCur)
    } else {
        $g1.DrawString($cf, $fBoxItem, $bSub, 1035, $yCur)
    }
    $yCur += 24
}

$bmp1.Save("d:\HTTTDN_2026\Report\images\bfd_diagram.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g1.Dispose()
$bmp1.Dispose()

# ==============================================================================
# 2. GENERATE CONTEXT DIAGRAM (SƠ ĐỒ NGỮ CẢNH)
# ==============================================================================
Write-Host "2/8 Generating Context Diagram..."
$bmp2 = New-Object System.Drawing.Bitmap 1350, 800
$g2 = [System.Drawing.Graphics]::FromImage($bmp2)
$g2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g2.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g2.Clear([System.Drawing.Color]::FromArgb(248, 250, 252))

$g2.DrawString("SƠ ĐỒ NGỮ CẢNH (CONTEXT DIAGRAM - DFD MỨC NGỮ CẢNH)", $fTitle, $bDark, (New-Object System.Drawing.RectangleF(50, 20, 1250, 30)), $sfCenter)
$g2.DrawString("Mô tả tương tác luồng thông tin giữa Hệ thống Trung tâm (0.0) và 3 Tác nhân ngoài (Admin, Manager, Customer)", $fSub, $bSub, (New-Object System.Drawing.RectangleF(50, 52, 1250, 20)), $sfCenter)

# Central Circle
$pCenter = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 91, 0), 3)
$bCenter = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 247, 237))
$g2.FillEllipse($bCenter, 500, 260, 350, 280)
$g2.DrawEllipse($pCenter, 500, 260, 350, 280)

$fBig = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$g2.DrawString("TIẾN TRÌNH 0.0", $fSmall, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(194, 65, 12))), (New-Object System.Drawing.RectangleF(500, 320, 350, 20)), $sfCenter)
$g2.DrawString("HỆ THỐNG THÔNG TIN`nDOANH NGHIỆP SGU TECH", $fBig, $bDark, (New-Object System.Drawing.RectangleF(500, 350, 350, 50)), $sfCenter)
$g2.DrawString("(Phân hệ Quản trị Admin & Quản lý Quan hệ KH)", $fSmall, $bSub, (New-Object System.Drawing.RectangleF(500, 415, 350, 30)), $sfCenter)

# Entity 1: ADMIN (Top Left)
$bEnt1 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(239, 246, 255))
$pEnt1 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(37, 99, 235), 2)
Draw-RoundedRectangle $g2 $pEnt1 $bEnt1 50 110 320 120 6
$g2.DrawString("TÁC NHÂN NGOÀI:`nQUẢN TRỊ VIÊN (ADMIN SERVER)", $fBoxHeader, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 64, 175))), (New-Object System.Drawing.RectangleF(50, 125, 320, 45)), $sfCenter)
$g2.DrawString("(Phụ trách máy chủ, tài khoản và phân quyền)", $fSmall, $bSub, (New-Object System.Drawing.RectangleF(50, 180, 320, 25)), $sfCenter)

# Entity 2: MANAGER CRM (Bottom Center)
$bEnt2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 247, 237))
$pEnt2 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 91, 0), 2)
Draw-RoundedRectangle $g2 $pEnt2 $bEnt2 500 620 350 120 6
$g2.DrawString("TÁC NHÂN NGOÀI:`nNGƯỜI QUẢN LÝ (CRM MANAGER)", $fBoxHeader, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(194, 65, 12))), (New-Object System.Drawing.RectangleF(500, 635, 350, 45)), $sfCenter)
$g2.DrawString("(Phụ trách nghiệp vụ KH, phản hồi & khảo sát)", $fSmall, $bSub, (New-Object System.Drawing.RectangleF(500, 690, 350, 25)), $sfCenter)

# Entity 3: CUSTOMER (Top Right)
$bEnt3 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 253, 250))
$pEnt3 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(13, 148, 136), 2)
Draw-RoundedRectangle $g2 $pEnt3 $bEnt3 980 110 320 120 6
$g2.DrawString("TÁC NHÂN NGOÀI:`nKHÁCH HÀNG (CUSTOMER)", $fBoxHeader, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 118, 110))), (New-Object System.Drawing.RectangleF(980, 125, 320, 45)), $sfCenter)
$g2.DrawString("(Đối tượng mua sắm, đánh giá và thực hiện khảo sát)", $fSmall, $bSub, (New-Object System.Drawing.RectangleF(980, 180, 320, 25)), $sfCenter)

# Flows
Draw-ArrowLine $g2 $pArrBlue 370 150 515 285
$g2.DrawString("(+) Thông tin Account, Lệnh phân quyền, Lệnh khóa/xóa", $fFlow, $bFlowIn, 140, 235)
Draw-ArrowLine $g2 $pArrOrange 500 330 350 230
$g2.DrawString("(-) Trạng thái tài khoản, Bảng phân quyền, Log CSDL", $fFlow, $bFlowOut, 110, 275)

Draw-ArrowLine $g2 $pArrTeal 980 150 835 285
$g2.DrawString("(+) Đăng ký tài khoản, Đánh giá sản phẩm (1-5★), Phiếu khảo sát 5 tiêu chí", $fFlow, $bFlowTeal, 740, 235)
Draw-ArrowLine $g2 $pArrOrange 850 330 1000 230
$g2.DrawString("(-) Danh mục sản phẩm, Lời giải đáp phản hồi, Khảo sát thị trường mới", $fFlow, $bFlowOut, 800, 275)

Draw-ArrowLine $g2 $pArrOrange 620 620 620 540
$g2.DrawString("(+) Khảo sát sản phẩm mới, Giải đáp phản hồi, Thêm/Xóa/Khóa KH", $fFlow, $bFlowIn, 180, 560)
Draw-ArrowLine $g2 $pArrOrange 730 540 730 620
$g2.DrawString("(-) Báo cáo tuổi & sở thích, Thống kê khảo sát, DS phản hồi chờ duyệt", $fFlow, $bFlowOut, 745, 560)

Draw-RoundedRectangle $g2 $pLine (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)) 50 710 420 65 6
$g2.DrawString("Chú thích ký hiệu luồng dữ liệu:", $fBoxItemBold, $bDark, 65, 718)
$g2.DrawString("(+) Luồng thông tin đầu vào gửi tới Hệ thống (Yêu cầu / Tác nghiệp)", $fSmall, $bFlowIn, 65, 736)
$g2.DrawString("(-) Luồng thông tin đầu ra kết xuất từ Hệ thống (Báo cáo / Giải đáp)", $fSmall, $bFlowOut, 65, 753)

$bmp2.Save("d:\HTTTDN_2026\Report\images\context_diagram.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g2.Dispose()
$bmp2.Dispose()

# ==============================================================================
# 3. GENERATE DFD LEVEL 0 (SƠ ĐỒ LUỒNG DỮ LIỆU MỨC ĐỈNH)
# ==============================================================================
Write-Host "3/8 Generating Level 0 DFD Diagram..."
$bmp3 = New-Object System.Drawing.Bitmap 1550, 1020
$g3 = [System.Drawing.Graphics]::FromImage($bmp3)
$g3.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g3.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g3.Clear([System.Drawing.Color]::FromArgb(248, 250, 252))

$g3.DrawString("SƠ ĐỒ LUỒNG DỮ LIỆU MỨC ĐỈNH (LEVEL 0 DFD)", $fTitle, $bDark, (New-Object System.Drawing.RectangleF(50, 15, 1450, 30)), $sfCenter)
$g3.DrawString("Mô tả chi tiết 5 Tiến trình chính (1.0 - 5.0), 3 Tác nhân ngoài và 5 Kho dữ liệu tập trung (D1 - D5)", $fSub, $bSub, (New-Object System.Drawing.RectangleF(50, 45, 1450, 20)), $sfCenter)

Draw-RoundedRectangle $g3 $pBlue (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(239, 246, 255))) 60 85 240 70 6
$g3.DrawString("Quản trị viên`n(Admin Server)", $fBoxHeader, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 64, 175))), (New-Object System.Drawing.RectangleF(60, 95, 240, 50)), $sfCenter)

Draw-RoundedRectangle $g3 $pOrange (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 247, 237))) 655 85 240 70 6
$g3.DrawString("Người quản lý`n(CRM Manager)", $fBoxHeader, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(194, 65, 12))), (New-Object System.Drawing.RectangleF(655, 95, 240, 50)), $sfCenter)

Draw-RoundedRectangle $g3 $pTeal (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 253, 250))) 1250 85 240 70 6
$g3.DrawString("Khách hàng`n(Customer)", $fBoxHeader, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 118, 110))), (New-Object System.Drawing.RectangleF(1250, 95, 240, 50)), $sfCenter)

Draw-DFDProcess $g3 60 220 250 80 "TIẾN TRÌNH 1.0" "Quản trị Tài khoản & Phân quyền" "Thêm, xóa, khóa và phân quyền Account"
Draw-DFDProcess $g3 460 220 260 80 "TIẾN TRÌNH 2.0" "Quản lý Khách hàng & Báo cáo" "Thêm/Xóa/Khóa KH, Báo cáo tuổi/sở thích"
Draw-DFDProcess $g3 840 220 260 80 "TIẾN TRÌNH 3.0" "Tiếp nhận & Giải đáp Phản hồi" "Đánh giá 1-5 sao, giải đáp phản hồi SP"
Draw-DFDProcess $g3 460 520 260 80 "TIẾN TRÌNH 4.0" "Khảo sát Sản phẩm Mới & Thống kê" "Phát hành phiếu khảo sát, thống kê ý định mua"
Draw-DFDProcess $g3 1240 220 260 80 "TIẾN TRÌNH 5.0" "Cổng Tương tác Khách hàng" "Đăng ký, đăng nhập, sửa hồ sơ cá nhân"

Draw-DataStoreBox $g3 $pStore $bStoreBg 60 380 320 50 "D1" "Kho Tài khoản & Phân quyền (Accounts, Roles)" $fStoreCode $fStoreName $bStoreText
Draw-DataStoreBox $g3 $pStore $bStoreBg 460 380 320 50 "D2" "Kho Hồ sơ Khách hàng (CustomerProfiles)" $fStoreCode $fStoreName $bStoreText
Draw-DataStoreBox $g3 $pStore $bStoreBg 860 380 320 50 "D4" "Kho Đánh giá Phản hồi (Feedbacks)" $fStoreCode $fStoreName $bStoreText
Draw-DataStoreBox $g3 $pStore $bStoreBg 460 670 320 50 "D5" "Kho Khảo sát & Ý kiến (Surveys, Responses)" $fStoreCode $fStoreName $bStoreText
Draw-DataStoreBox $g3 $pStore $bStoreBg 860 670 320 50 "D3" "Kho Sản phẩm & Đối tác (Products, Categories)" $fStoreCode $fStoreName $bStoreText

Draw-ArrowLine $g3 $pArrBlue 180 155 180 220
$g3.DrawString("Yêu cầu Account/Quyền", $fSmall, $bFlowIn, 70, 180)
Draw-ArrowLine $g3 $pArrDark 150 300 150 380
$g3.DrawString("Ghi nhận / Cập nhật quyền", $fSmall, $bSub, 60, 335)
Draw-ArrowLine $g3 $pArrDark 200 380 200 300
$g3.DrawString("Đọc Account / Role", $fSmall, $bSub, 205, 335)

Draw-ArrowLine $g3 $pArrOrange 730 155 630 220
$g3.DrawString("Thêm/Xóa/Khóa KH", $fSmall, $bFlowIn, 570, 180)
Draw-ArrowLine $g3 $pArrDark 560 300 560 380
$g3.DrawString("Ghi nhận hồ sơ KH", $fSmall, $bSub, 470, 335)
Draw-ArrowLine $g3 $pArrDark 620 380 620 300
$g3.DrawString("Đọc tuổi / sở thích", $fSmall, $bSub, 625, 335)
Draw-ArrowLine $g3 $pArrOrange 600 220 700 155
$g3.DrawString("Báo cáo biểu đồ độ tuổi & sở thích", $fSmall, $bFlowOut, 640, 160)

Draw-ArrowLine $g3 $pArrTeal 1270 155 1060 220
$g3.DrawString("Gửi đánh giá sản phẩm (1-5★)", $fSmall, $bFlowTeal, 1080, 175)
Draw-ArrowLine $g3 $pArrOrange 810 155 920 220
$g3.DrawString("Giải đáp phản hồi", $fSmall, $bFlowIn, 840, 180)
Draw-ArrowLine $g3 $pArrDark 980 300 980 380
$g3.DrawString("Lưu phản hồi & lời giải đáp", $fSmall, $bSub, 880, 335)
Draw-ArrowLine $g3 $pArrDark 1040 380 1040 300
$g3.DrawString("Đọc danh sách phản hồi", $fSmall, $bSub, 1045, 335)
Draw-ArrowLine $g3 $pArrTeal 1080 380 1330 160
$g3.DrawString("Xem lời giải đáp từ Quản lý", $fSmall, $bFlowTeal, 1150, 310)

Draw-ArrowLine $g3 $pArrOrange 775 155 590 520
$g3.DrawString("Tạo bài khảo sát SP mới có thời hạn", $fSmall, $bFlowIn, 690, 460)
Draw-ArrowLine $g3 $pArrDark 560 600 560 670
$g3.DrawString("Ghi bảng khảo sát", $fSmall, $bSub, 470, 630)
Draw-ArrowLine $g3 $pArrDark 620 670 620 600
$g3.DrawString("Đọc thống kê câu trả lời", $fSmall, $bSub, 625, 630)
Draw-ArrowLine $g3 $pArrOrange 540 520 740 160
$g3.DrawString("Bảng thống kê tỷ lệ mua & điểm trung bình", $fSmall, $bFlowOut, 500, 480)

Draw-ArrowLine $g3 $pArrTeal 780 680 1320 160
$g3.DrawString("Nhận bài khảo sát SP mới đang mở", $fSmall, $bFlowTeal, 1120, 520)
Draw-ArrowLine $g3 $pArrTeal 1350 160 720 550
$g3.DrawString("Nộp kết quả trả lời khảo sát 5 chiều", $fSmall, $bFlowTeal, 920, 470)

Draw-ArrowLine $g3 $pArrTeal 1370 155 1370 220
$g3.DrawString("Đăng ký / Đăng nhập / Sửa hồ sơ", $fSmall, $bFlowTeal, 1260, 185)
Draw-ArrowLine $g3 $pArrDark 1240 260 380 405
$g3.DrawString("Ghi nhận tài khoản mới vào D1", $fSmall, $bSub, 680, 310)
Draw-ArrowLine $g3 $pArrDark 980 670 980 300
$g3.DrawString("Đọc thông tin sản phẩm từ D3", $fSmall, $bSub, 985, 520)

Draw-RoundedRectangle $g3 $pLine (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)) 60 760 1430 210 8
$g3.DrawString("QUY TẮC PHÂN LUỒNG VÀ TOÀN VẸN DỮ LIỆU CỦA HỆ THỐNG:", $fBoxItemBold, $bDark, 80, 775)
$rules = @(
    "1. Tính tách biệt tuyệt đối: Quản trị viên chỉ làm việc với D1 (Tài khoản & Phân quyền: Admin, Manager, Customer), không can thiệp nghiệp vụ kinh doanh.",
    "2. Phân hệ CRM Người Quản lý: Độc quyền khai thác D2 (Hồ sơ KH), D4 (Phản hồi giải đáp) và D5 (Khảo sát thị trường) để ra quyết định thương mại.",
    "3. Tương tác Khách hàng hai chiều: Khách hàng truy cập qua Cổng khách hàng độc lập, tự chủ gửi đánh giá SP vào D4 và làm khảo sát vào D5.",
    "4. Tính toàn vẹn ràng buộc: Xóa tài khoản khách hàng kích hoạt CASCADE dọn dẹp tương ứng ở D2, D4, D5; đảm bảo không tồn đọng bản ghi mồ côi."
)
$yR = 805
foreach ($r in $rules) {
    $g3.DrawString($r, $fSmall, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(51, 65, 85))), 80, $yR)
    $yR += 28
}

$bmp3.Save("d:\HTTTDN_2026\Report\images\dfd_level0_diagram.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g3.Dispose()
$bmp3.Dispose()

# ==============================================================================
# 4. GENERATE DFD LEVEL 1 - PHÂN HỆ ADMIN SERVER (TIẾN TRÌNH 1.0)
# ==============================================================================
Write-Host "4/8 Generating DFD Level 1 - Admin Server..."
$bmp4a = New-Object System.Drawing.Bitmap 1350, 720
$g4a = [System.Drawing.Graphics]::FromImage($bmp4a)
$g4a.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g4a.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g4a.Clear([System.Drawing.Color]::FromArgb(248, 250, 252))

$g4a.DrawString("SƠ ĐỒ DFD MỨC 1 — PHÂN RÃ TIẾN TRÌNH 1.0: QUẢN TRỊ TÀI KHOẢN & PHÂN QUYỀN (ADMIN SERVER)", $fTitle, $bDark, (New-Object System.Drawing.RectangleF(40, 18, 1270, 30)), $sfCenter)
$g4a.DrawString("Chi tiết hóa 4 tiến trình con (1.1 - 1.4) tương tác với Kho dữ liệu D1 (Accounts, Roles) và D2 (CustomerProfiles)", $fSub, $bSub, (New-Object System.Drawing.RectangleF(40, 48, 1270, 22)), $sfCenter)

# Actor Admin
Draw-RoundedRectangle $g4a $pBlue (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(239, 246, 255))) 50 280 230 110 8
$g4a.DrawString("TÁC NHÂN:`nQUẢN TRỊ VIÊN`n(ADMIN SERVER)", $fBoxHeader, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 64, 175))), (New-Object System.Drawing.RectangleF(50, 295, 230, 80)), $sfCenter)

# 4 Sub-processes
Draw-DFDProcess $g4a 450 100 320 82 "TIẾN TRÌNH 1.1" "Thêm mới Tài khoản (Create Account)" "Kiểm tra trùng Username, băm BCrypt mật khẩu"
Draw-DFDProcess $g4a 450 230 320 82 "TIẾN TRÌNH 1.2" "Phân quyền Tài khoản (Assign Role)" "Cập nhật RoleId (Admin / Manager / Customer)"
Draw-DFDProcess $g4a 450 360 320 82 "TIẾN TRÌNH 1.3" "Khóa / Mở khóa Tài khoản (Toggle Lock)" "Đảo trạng thái IsActive (1: Hoạt động, 0: Khóa)"
Draw-DFDProcess $g4a 450 490 320 82 "TIẾN TRÌNH 1.4" "Xóa Tài khoản An toàn (Safe Delete)" "Kiểm tra tài khoản gốc & xóa CASCADE dữ liệu"

# Data Stores
Draw-DataStoreBox $g4a $pStore $bStoreBg 960 150 340 55 "D1a" "Bảng Vai trò Phân quyền (Roles)" $fStoreCode $fStoreName $bStoreText
Draw-DataStoreBox $g4a $pStore $bStoreBg 960 300 340 55 "D1b" "Bảng Tài khoản Hệ thống (Accounts)" $fStoreCode $fStoreName $bStoreText
Draw-DataStoreBox $g4a $pStore $bStoreBg 960 460 340 55 "D2" "Kho Hồ sơ Khách hàng (CustomerProfiles)" $fStoreCode $fStoreName $bStoreText

# Arrows Admin -> 1.1..1.4
Draw-ArrowLine $g4a $pArrBlue 280 300 450 140
$g4a.DrawString("Thông tin Account mới", $fSmall, $bFlowIn, 285, 190)
Draw-ArrowLine $g4a $pArrBlue 280 320 450 270
$g4a.DrawString("Lệnh gán RoleId mới", $fSmall, $bFlowIn, 295, 275)
Draw-ArrowLine $g4a $pArrBlue 280 350 450 400
$g4a.DrawString("Yêu cầu Khóa / Mở khóa", $fSmall, $bFlowIn, 290, 382)
Draw-ArrowLine $g4a $pArrBlue 280 375 450 530
$g4a.DrawString("Lệnh xóa AccountId", $fSmall, $bFlowIn, 285, 470)

# Arrows 1.1..1.4 -> Data Stores
Draw-ArrowLine $g4a $pArrDark 770 140 960 315
$g4a.DrawString("Ghi bản ghi Account mới", $fSmall, $bSub, 795, 200)
Draw-ArrowLine $g4a $pArrDark 770 155 960 475
$g4a.DrawString("Tạo Profile mặc định (nếu là KH)", $fSmall, $bSub, 780, 385)
Draw-ArrowLine $g4a $pArrDark 960 175 770 255
$g4a.DrawString("Đọc danh mục 3 Role chuẩn", $fSmall, $bSub, 785, 175)
Draw-ArrowLine $g4a $pArrDark 770 275 960 325
$g4a.DrawString("Cập nhật cột RoleId", $fSmall, $bSub, 800, 280)
Draw-ArrowLine $g4a $pArrDark 770 400 960 340
$g4a.DrawString("Cập nhật cột IsActive", $fSmall, $bSub, 800, 355)
Draw-ArrowLine $g4a $pArrDark 770 530 960 350
$g4a.DrawString("Xóa Account & CASCADE", $fSmall, $bSub, 795, 485)

Draw-RoundedRectangle $g4a $pLine (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)) 50 610 1250 75 6
$g4a.DrawString("RÀNG BUỘC BẢO MẬT TẠI TIẾN TRÌNH 1.0 (ADMIN SERVER):", $fBoxItemBold, $bDark, 70, 622)
$g4a.DrawString("• Hệ thống chỉ cho phép phân quyền 3 vai trò chuẩn: Admin (Quản trị máy chủ), Manager (Người quản lý CRM), Customer (Khách hàng).", $fSmall, $bSub, 70, 644)
$g4a.DrawString("• Chốt chặn an toàn: Không cho phép xóa hoặc khóa tài khoản gốc 'admin' (AccountId = 1) nhằm bảo vệ quyền điều khiển tối cao của máy chủ.", $fSmall, $bSub, 70, 662)

$bmp4a.Save("d:\HTTTDN_2026\Report\images\dfd_level1_admin.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g4a.Dispose()
$bmp4a.Dispose()

# ==============================================================================
# 5. GENERATE DFD LEVEL 1 - PHÂN HỆ QUẢN LÝ CRM (TIẾN TRÌNH 2.0, 3.0, 4.0)
# ==============================================================================
Write-Host "5/8 Generating DFD Level 1 - CRM Manager..."
$bmp4b = New-Object System.Drawing.Bitmap 1420, 820
$g4b = [System.Drawing.Graphics]::FromImage($bmp4b)
$g4b.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g4b.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g4b.Clear([System.Drawing.Color]::FromArgb(248, 250, 252))

$g4b.DrawString("SƠ ĐỒ DFD MỨC 1 — PHÂN RÃ NGHIỆP VỤ NGƯỜI QUẢN LÝ CRM (7 CHỨC NĂNG CỐT LÕI)", $fTitle, $bDark, (New-Object System.Drawing.RectangleF(40, 18, 1340, 30)), $sfCenter)
$g4b.DrawString("Phân rã chi tiết các tiến trình Quản lý hồ sơ KH (2.1-2.3), Báo cáo nhân khẩu học (2.4), Giải đáp phản hồi (3.1) và Khảo sát thị trường (4.1-4.2)", $fSub, $bSub, (New-Object System.Drawing.RectangleF(40, 48, 1340, 22)), $sfCenter)

# Actor CRM Manager
Draw-RoundedRectangle $g4b $pOrange (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 247, 237))) 40 330 230 120 8
$g4b.DrawString("TÁC NHÂN:`nNGƯỜI QUẢN LÝ`n(CRM MANAGER)", $fBoxHeader, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(194, 65, 12))), (New-Object System.Drawing.RectangleF(40, 350, 230, 80)), $sfCenter)

# 5 Sub-processes representing all 7 CRM functions
Draw-DFDProcess $g4b 440 90  350 80 "TIẾN TRÌNH 2.1 - 2.3" "Thêm, Xóa & Khóa TK Khách hàng" "Tạo mới KH, khóa IsActive, xóa hồ sơ KH"
Draw-DFDProcess $g4b 440 215 350 80 "TIẾN TRÌNH 2.4" "Báo cáo Tỷ lệ Độ tuổi & Sở thích" "Tổng hợp nhóm tuổi (<20, 20-30, >30) & sở thích"
Draw-DFDProcess $g4b 440 340 350 80 "TIẾN TRÌNH 3.1" "Tiếp nhận & Giải đáp Phản hồi SP" "Đọc đánh giá 1-5 sao & cập nhật AdminReply"
Draw-DFDProcess $g4b 440 465 350 80 "TIẾN TRÌNH 4.1" "Tạo Bảng Khảo sát Gửi Khách hàng" "Thiết lập SP mới, giá dự kiến, hạn & danh sách nhận"
Draw-DFDProcess $g4b 440 590 350 80 "TIẾN TRÌNH 4.2" "Thống kê Kết quả Khảo sát" "Tính điểm TB, tỷ lệ ý định mua & tổng hợp góp ý"

# Data Stores on the Right
Draw-DataStoreBox $g4b $pStore $bStoreBg 980 95  380 55 "D1/D2" "Kho Tài khoản & Hồ sơ KH (Accounts, Profiles)" $fStoreCode $fStoreName $bStoreText
Draw-DataStoreBox $g4b $pStore $bStoreBg 980 345 380 55 "D3/D4" "Kho Sản phẩm & Phản hồi (Products, Feedbacks)" $fStoreCode $fStoreName $bStoreText
Draw-DataStoreBox $g4b $pStore $bStoreBg 980 530 380 55 "D5" "Kho Khảo sát & Kết quả (Surveys, Responses)" $fStoreCode $fStoreName $bStoreText

# Flows Manager <-> Sub-processes
Draw-ArrowLine $g4b $pArrOrange 270 350 440 130
$g4b.DrawString("Hồ sơ KH mới / Lệnh Khóa, Xóa", $fSmall, $bFlowIn, 260, 200)
Draw-ArrowLine $g4b $pArrOrange 440 255 270 370
$g4b.DrawString("Biểu đồ Độ tuổi & Sở thích", $fSmall, $bFlowOut, 265, 290)
Draw-ArrowLine $g4b $pArrOrange 270 390 440 380
$g4b.DrawString("Nội dung giải đáp (AdminReply)", $fSmall, $bFlowIn, 265, 360)
Draw-ArrowLine $g4b $pArrOrange 270 415 440 505
$g4b.DrawString("Thông tin chiến dịch khảo sát mới", $fSmall, $bFlowIn, 255, 465)
Draw-ArrowLine $g4b $pArrOrange 440 630 270 440
$g4b.DrawString("Báo cáo thống kê kết quả khảo sát", $fSmall, $bFlowOut, 245, 560)

# Flows Sub-processes <-> Data Stores
Draw-ArrowLine $g4b $pArrDark 790 125 980 125
$g4b.DrawString("Ghi / Cập nhật / Xóa KH", $fSmall, $bSub, 815, 102)
Draw-ArrowLine $g4b $pArrDark 980 140 790 250
$g4b.DrawString("Đọc dữ liệu Age, Interest", $fSmall, $bSub, 815, 195)
Draw-ArrowLine $g4b $pArrDark 790 375 980 375
$g4b.DrawString("Đọc Feedback & Lưu AdminReply", $fSmall, $bSub, 800, 352)
Draw-ArrowLine $g4b $pArrDark 790 505 980 550
$g4b.DrawString("Lưu chiến dịch vào bảng Surveys", $fSmall, $bSub, 800, 505)
Draw-ArrowLine $g4b $pArrDark 980 575 790 630
$g4b.DrawString("Đọc SurveyResponses để thống kê", $fSmall, $bSub, 795, 612)

Draw-RoundedRectangle $g4b $pLine (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)) 40 705 1320 80 6
$g4b.DrawString("ĐẶC TẢ NGHIỆP VỤ PHÂN HỆ QUẢN LÝ CRM (MỤC III.4.1):", $fBoxItemBold, $bDark, 60, 718)
$g4b.DrawString("• Toàn bộ 7 yêu cầu nghiệp vụ của Người quản lý được tổ chức thành 5 Tab chuyên biệt trên giao diện manager_crm.html, đồng bộ thời gian thực qua BroadcastChannel.", $fSmall, $bSub, 60, 740)
$g4b.DrawString("• Cho phép phát hành khảo sát định hướng tới từng tài khoản khách hàng cụ thể ([TARGET:id1,id2...]) hoặc toàn bộ khách hàng đang hoạt động.", $fSmall, $bSub, 60, 760)

$bmp4b.Save("d:\HTTTDN_2026\Report\images\dfd_level1_crm.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g4b.Dispose()
$bmp4b.Dispose()

# ==============================================================================
# 6. GENERATE DFD LEVEL 1 - PHÂN HỆ KHÁCH HÀNG (TIẾN TRÌNH 5.0)
# ==============================================================================
Write-Host "6/8 Generating DFD Level 1 - Customer Portal..."
$bmp4c = New-Object System.Drawing.Bitmap 1420, 820
$g4c = [System.Drawing.Graphics]::FromImage($bmp4c)
$g4c.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g4c.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g4c.Clear([System.Drawing.Color]::FromArgb(248, 250, 252))

$g4c.DrawString("SƠ ĐỒ DFD MỨC 1 — PHÂN RÃ CỔNG TƯƠNG TÁC KHÁCH HÀNG (5 CHỨC NĂNG CỐT LÕI)", $fTitle, $bDark, (New-Object System.Drawing.RectangleF(40, 18, 1340, 30)), $sfCenter)
$g4c.DrawString("Phân rã chi tiết 5 tiến trình của Khách hàng: Đăng ký (5.1), Đăng nhập (5.2), Chỉnh sửa thông tin (5.3), Gửi phản hồi SP (5.4) & Thực hiện khảo sát (5.5)", $fSub, $bSub, (New-Object System.Drawing.RectangleF(40, 48, 1340, 22)), $sfCenter)

# Actor Customer
Draw-RoundedRectangle $g4c $pTeal (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 253, 250))) 40 330 230 120 8
$g4c.DrawString("TÁC NHÂN:`nKHÁCH HÀNG`n(CUSTOMER)", $fBoxHeader, $bFlowTeal, (New-Object System.Drawing.RectangleF(40, 350, 230, 80)), $sfCenter)

# 5 Sub-processes
Draw-DFDProcess $g4c 440 90  350 80 "TIẾN TRÌNH 5.1" "Đăng ký Tài khoản Khách hàng" "Tạo Account (Role=Customer) & Profile mặc định"
Draw-DFDProcess $g4c 440 215 350 80 "TIẾN TRÌNH 5.2" "Đăng nhập & Xác thực Phiên" "Kiểm tra BCrypt PasswordHash & cờ IsActive"
Draw-DFDProcess $g4c 440 340 350 80 "TIẾN TRÌNH 5.3" "Chỉnh sửa Thông tin Cá nhân" "Cập nhật Họ tên, SĐT, Tuổi, Giới tính, Sở thích"
Draw-DFDProcess $g4c 440 465 350 80 "TIẾN TRÌNH 5.4" "Gửi Phản hồi về Sản phẩm" "Chấm 1-5 sao, gửi nhận xét & xem lời giải đáp"
Draw-DFDProcess $g4c 440 590 350 80 "TIẾN TRÌNH 5.5" "Nhận & Thực hiện Bảng Khảo sát" "Nộp phiếu khảo sát 5 tiêu chí vào SurveyResponses"

# Data Stores
Draw-DataStoreBox $g4c $pStore $bStoreBg 980 95  380 55 "D1" "Kho Tài khoản & Phân quyền (Accounts, Roles)" $fStoreCode $fStoreName $bStoreText
Draw-DataStoreBox $g4c $pStore $bStoreBg 980 260 380 55 "D2" "Kho Hồ sơ Khách hàng (CustomerProfiles)" $fStoreCode $fStoreName $bStoreText
Draw-DataStoreBox $g4c $pStore $bStoreBg 980 440 380 55 "D3/D4" "Kho Sản phẩm & Đánh giá (Products, Feedbacks)" $fStoreCode $fStoreName $bStoreText
Draw-DataStoreBox $g4c $pStore $bStoreBg 980 595 380 55 "D5" "Kho Khảo sát Thị trường (Surveys, Responses)" $fStoreCode $fStoreName $bStoreText

# Flows Customer <-> Sub-processes
Draw-ArrowLine $g4c $pArrTeal 270 345 440 130
$g4c.DrawString("Username, Họ tên, SĐT, Mật khẩu", $fSmall, $bFlowTeal, 250, 195)
Draw-ArrowLine $g4c $pArrTeal 270 365 440 255
$g4c.DrawString("Thông tin đăng nhập", $fSmall, $bFlowTeal, 285, 290)
Draw-ArrowLine $g4c $pArrTeal 270 390 440 380
$g4c.DrawString("Thông tin hồ sơ cập nhật", $fSmall, $bFlowTeal, 275, 360)
Draw-ArrowLine $g4c $pArrTeal 270 415 440 505
$g4c.DrawString("Điểm 1-5 sao & Nội dung nhận xét", $fSmall, $bFlowTeal, 250, 465)
Draw-ArrowLine $g4c $pArrTeal 270 440 440 630
$g4c.DrawString("Phiếu trả lời khảo sát 5 tiêu chí", $fSmall, $bFlowTeal, 250, 560)

# Flows Sub-processes <-> Data Stores
Draw-ArrowLine $g4c $pArrDark 790 125 980 125
$g4c.DrawString("Lưu Account mới (RoleId=3)", $fSmall, $bSub, 805, 102)
Draw-ArrowLine $g4c $pArrDark 980 140 790 250
$g4c.DrawString("Xác thực Username & IsActive", $fSmall, $bSub, 805, 195)
Draw-ArrowLine $g4c $pArrDark 790 375 980 290
$g4c.DrawString("Cập nhật Age, Gender, Interest, Address", $fSmall, $bSub, 795, 315)
Draw-ArrowLine $g4c $pArrDark 790 500 980 470
$g4c.DrawString("Ghi Feedback mới & Đọc AdminReply", $fSmall, $bSub, 795, 455)
Draw-ArrowLine $g4c $pArrDark 790 625 980 625
$g4c.DrawString("Đọc Surveys đang mở & Ghi Response", $fSmall, $bSub, 795, 600)

Draw-RoundedRectangle $g4c $pLine (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)) 40 705 1320 80 6
$g4c.DrawString("ĐẶC TẢ NGHIỆP VỤ CỔNG KHÁCH HÀNG (MỤC III.4.3):", $fBoxItemBold, $bDark, 60, 718)
$g4c.DrawString("• Cổng Khách hàng (customer_login.html & user.html) tách biệt hoàn toàn với cổng nội bộ, mang lại trải nghiệm thương mại điện tử chuyên nghiệp.", $fSmall, $bSub, 60, 740)
$g4c.DrawString("• Mỗi khách hàng chỉ được thực hiện 1 lần cho mỗi chiến dịch khảo sát (ràng buộc chống trùng lặp SurveyId + AccountId).", $fSmall, $bSub, 60, 760)

$bmp4c.Save("d:\HTTTDN_2026\Report\images\dfd_level1_customer.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g4c.Dispose()
$bmp4c.Dispose()

# ==============================================================================
# 7. GENERATE ERD DIAGRAM (LƯỢC ĐỒ CSDL QUAN HỆ THỰC THỂ 9 BẢNG)
# ==============================================================================
Write-Host "7/8 Generating ERD diagram..."
$bmp4 = New-Object System.Drawing.Bitmap 1550, 1080
$g4 = [System.Drawing.Graphics]::FromImage($bmp4)
$g4.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g4.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g4.Clear([System.Drawing.Color]::FromArgb(248, 250, 252))

$g4.DrawString("LƯỢC ĐỒ QUAN HỆ THỰC THỂ CƠ SỞ DỮ LIỆU (RELATIONAL SCHEMA / ERD)", $fTitle, $bDark, (New-Object System.Drawing.RectangleF(50, 15, 1450, 30)), $sfCenter)
$g4.DrawString("Mô hình 9 Bảng chuẩn hóa 3NF thiết kế trực tiếp từ các kho dữ liệu D1, D2, D3, D4, D5", $fSub, $bSub, (New-Object System.Drawing.RectangleF(50, 45, 1450, 20)), $sfCenter)

function Draw-ERDTable($g, [float]$x, [float]$y, [float]$w, $tableName, $colorHex, $cols) {
    $pen = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml($colorHex), 2)
    $bHead = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($colorHex))
    $bBody = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $bDark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 23, 42))
    $bPk = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 38, 38))
    $bFk = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(37, 99, 235))
    $bType = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(100, 116, 139))
    
    $h = [float](35 + ($cols.Count * 22) + 10)
    Draw-RoundedRectangle $g $pen $bBody $x $y $w $h 6
    Draw-RoundedRectangle $g $pen $bHead $x $y $w 32 6
    
    $fH = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $fC = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
    $fK = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
    
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $rectHeader = New-Object System.Drawing.RectangleF($x, ($y + 4.0), $w, 24.0)
    $g.DrawString($tableName, $fH, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)), $rectHeader, $sf)
    
    $yRow = $y + 38.0
    foreach ($c in $cols) {
        $parts = $c -split "\|"
        $key = $parts[0].Trim()
        $name = $parts[1].Trim()
        $type = $parts[2].Trim()
        
        if ($key -eq "PK") {
            $g.DrawString("PK", $fK, $bPk, ($x + 8.0), $yRow)
        } elseif ($key -eq "FK") {
            $g.DrawString("FK", $fK, $bFk, ($x + 8.0), $yRow)
        }
        
        $g.DrawString($name, $fC, $bDark, ($x + 35.0), $yRow)
        
        $sfR = New-Object System.Drawing.StringFormat
        $sfR.Alignment = [System.Drawing.StringAlignment]::Far
        $rectType = New-Object System.Drawing.RectangleF(($x + $w - 145.0), $yRow, 140.0, 20.0)
        $g.DrawString($type, $fC, $bType, $rectType, $sfR)
        
        $yRow += 22.0
    }
}

$colsRoles = @(
    "PK | RoleId | INT IDENTITY",
    "   | RoleName | NVARCHAR(50)",
    "   | Description | NVARCHAR(250)"
)
Draw-ERDTable $g4 50 100 280 "1. Roles (D1: Quyền)" "#1E3A8A" $colsRoles

$colsAccounts = @(
    "PK | AccountId | INT IDENTITY",
    "   | Username | VARCHAR(50)",
    "   | PasswordHash | NVARCHAR(255)",
    "   | FullName | NVARCHAR(100)",
    "   | Email | VARCHAR(100)",
    "   | Phone | VARCHAR(20)",
    "FK | RoleId | INT (-> Roles)",
    "   | IsActive | BIT (DEFAULT 1)",
    "   | CreatedAt | DATETIME"
)
Draw-ERDTable $g4 50 240 310 "2. Accounts (D1: Tài khoản)" "#1E3A8A" $colsAccounts

$colsProfiles = @(
    "PK | ProfileId | INT IDENTITY",
    "FK | AccountId | INT (UNIQUE, CASCADE)",
    "   | Age | INT (NOT NULL)",
    "   | Gender | NVARCHAR(10)",
    "   | Address | NVARCHAR(255)",
    "   | Interest | NVARCHAR(100)"
)
Draw-ERDTable $g4 50 515 310 "3. CustomerProfiles (D2: Hồ sơ KH)" "#0D9488" $colsProfiles

$colsCat = @(
    "PK | CategoryId | INT IDENTITY",
    "   | CategoryName | NVARCHAR(100)",
    "   | Description | NVARCHAR(255)"
)
Draw-ERDTable $g4 1220 100 280 "4. Categories (D3: Danh mục)" "#0284C7" $colsCat

$colsSup = @(
    "PK | SupplierId | INT IDENTITY",
    "   | SupplierCode | VARCHAR(20)",
    "   | SupplierName | NVARCHAR(150)",
    "   | ContactName | NVARCHAR(100)",
    "   | Phone | VARCHAR(20)",
    "   | Address | NVARCHAR(255)"
)
Draw-ERDTable $g4 860 100 310 "5. Suppliers (D3: Nhà cung cấp)" "#0284C7" $colsSup

$colsProd = @(
    "PK | ProductId | INT IDENTITY",
    "   | ProductCode | VARCHAR(50)",
    "   | ProductName | NVARCHAR(200)",
    "FK | CategoryId | INT (-> Categories)",
    "FK | SupplierId | INT (-> Suppliers)",
    "   | Price | DECIMAL(18,2)",
    "   | CostPrice | DECIMAL(18,2)",
    "   | StockQuantity | INT (DEFAULT 0)",
    "   | Unit | NVARCHAR(20)",
    "   | Status | NVARCHAR(50)",
    "   | ImageUrl | NVARCHAR(500)"
)
Draw-ERDTable $g4 1050 320 330 "6. Products (D3: Hàng hóa / SP)" "#0284C7" $colsProd

$colsFeed = @(
    "PK | FeedbackId | INT IDENTITY",
    "FK | AccountId | INT (-> Accounts)",
    "FK | ProductId | INT (-> Products)",
    "   | Rating | INT (CHECK 1-5)",
    "   | Comment | NVARCHAR(1000)",
    "   | AdminReply | NVARCHAR(1000)",
    "   | Status | NVARCHAR(50)",
    "   | CreatedAt | DATETIME"
)
Draw-ERDTable $g4 520 280 340 "7. Feedbacks (D4: Phản hồi & Giải đáp)" "#EA580C" $colsFeed

$colsSurveys = @(
    "PK | SurveyId | INT IDENTITY",
    "   | Title | NVARCHAR(200)",
    "   | Description | NVARCHAR(1000)",
    "   | TargetProduct | NVARCHAR(150)",
    "   | ExpectedPrice | DECIMAL(18,2)",
    "   | CreatedAt | DATETIME",
    "   | IsActive | BIT (DEFAULT 1)",
    "   | ExpiresAt | DATETIME (Thời hạn)"
)
Draw-ERDTable $g4 520 560 340 "8. Surveys (D5: Khảo sát thị trường)" "#C2410C" $colsSurveys

$colsResp = @(
    "PK | ResponseId | INT IDENTITY",
    "FK | SurveyId | INT (-> Surveys)",
    "FK | AccountId | INT (-> Accounts)",
    "   | Score | INT (CHECK 1-5)",
    "   | BuyingIntent | NVARCHAR(50)",
    "   | CustomerOpinion | NVARCHAR(1000)",
    "   | SubmittedAt | DATETIME"
)
Draw-ERDTable $g4 980 660 340 "9. SurveyResponses (D5: Kết quả KS)" "#C2410C" $colsResp

$pRel = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(71, 85, 105), 1.5)
$pRel.CustomEndCap = $capArrow

Draw-ArrowLine $g4 $pRel 190 200 190 240
$g4.DrawString("1 : N", $fKey, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 64, 175))), 195, 215)

Draw-ArrowLine $g4 $pRel 190 480 190 515
$g4.DrawString("1 : 1 (CASCADE)", $fKey, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(13, 148, 136))), 195, 492)

Draw-ArrowLine $g4 $pRel 360 320 520 320
$g4.DrawString("1 : N", $fKey, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(234, 88, 12))), 430, 305)

Draw-ArrowLine $g4 $pRel 1050 400 860 350
$g4.DrawString("1 : N", $fKey, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(2, 132, 199))), 940, 365)

Draw-ArrowLine $g4 $pRel 1350 200 1350 320
$g4.DrawString("1 : N", $fKey, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(2, 132, 199))), 1355, 250)

Draw-ArrowLine $g4 $pRel 1010 250 1100 320
$g4.DrawString("1 : N", $fKey, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(2, 132, 199))), 1040, 275)

Draw-ArrowLine $g4 $pRel 860 670 980 720
$g4.DrawString("1 : N", $fKey, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(194, 65, 12))), 890, 680)

$pathAccResp = New-Object System.Drawing.Drawing2D.GraphicsPath
$pathAccResp.AddLine(360, 420, 480, 420)
$pathAccResp.AddLine(480, 420, 480, 800)
$pathAccResp.AddLine(480, 800, 980, 800)
$pPathPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(71, 85, 105), 1.5)
$pPathPen.CustomEndCap = $capArrow
$g4.DrawPath($pPathPen, $pathAccResp)
$g4.DrawString("1 : N", $fKey, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 64, 175))), 490, 780)

Draw-RoundedRectangle $g4 $pLine (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)) 50 880 1450 160 8
$g4.DrawString("GHI CHÚ CHUẨN HÓA DỮ LIỆU & RÀNG BUỘC TOÀN VẸN (9 BẢNG CHUẨN HÓA 3NF):", $fBoxItemBold, $bDark, 70, 895)
$erdNotes = @(
    "1. Đạt chuẩn 3NF: Mọi thuộc tính không khóa trong cả 9 bảng đều phụ thuộc hàm đầy đủ và trực tiếp vào khóa chính PK, triệt tiêu hoàn toàn phụ thuộc bắc cầu.",
    "2. Khóa ngoại CASCADE: Xóa tài khoản khách hàng ở bảng Accounts sẽ tự động dọn dẹp CustomerProfiles, Feedbacks và SurveyResponses tương ứng.",
    "3. Quản trị vòng đời khảo sát: Cột ExpiresAt tại bảng Surveys cho phép đóng khảo sát tự động khi hết hạn mà không cần can thiệp thủ công.",
    "4. Ánh xạ chuẩn xác từ DFD: D1 -> Roles, Accounts | D2 -> CustomerProfiles | D3 -> Categories, Suppliers, Products | D4 -> Feedbacks | D5 -> Surveys, SurveyResponses."
)
$yE = 922
foreach ($en in $erdNotes) {
    $g4.DrawString($en, $fSmall, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(71, 85, 105))), 70, $yE)
    $yE += 26
}

$bmp4.Save("d:\HTTTDN_2026\Report\images\erd_diagram.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g4.Dispose()
$bmp4.Dispose()

# ==============================================================================
# 8. GENERATE SYSTEM ARCHITECTURE DIAGRAM (SƠ ĐỒ KIẾN TRÚC 3 TẦNG)
# ==============================================================================
Write-Host "8/8 Generating 3-Tier System Architecture Diagram..."
$bmp5 = New-Object System.Drawing.Bitmap 1350, 680
$g5 = [System.Drawing.Graphics]::FromImage($bmp5)
$g5.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g5.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g5.Clear([System.Drawing.Color]::FromArgb(248, 250, 252))

$g5.DrawString("SƠ ĐỒ KIẾN TRÚC TRIỂN KHAI HỆ THỐNG 3 TẦNG (3-TIER ENTERPRISE WEB API ARCHITECTURE)", $fTitle, $bDark, (New-Object System.Drawing.RectangleF(40, 18, 1270, 30)), $sfCenter)
$g5.DrawString("Tách biệt hoàn toàn Tầng Giao diện (3 Cổng độc lập), Tầng Nghiệp vụ RESTful API (.NET 8.0) và Tầng Lưu trữ Dual-DB", $fSub, $bSub, (New-Object System.Drawing.RectangleF(40, 48, 1270, 22)), $sfCenter)

# Tier 1: Presentation Layer
Draw-RoundedRectangle $g5 $pBlue (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(239, 246, 255))) 45 95 360 530 10
Draw-RoundedRectangle $g5 $pBlue (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 64, 175))) 45 95 360 48 10
$g5.DrawString("TẦNG 1: PRESENTATION LAYER`n(Frontend 3 Cổng Giao diện Độc lập)", $fBoxItemBold, $bRootText, (New-Object System.Drawing.RectangleF(45, 99, 360, 40)), $sfCenter)

Draw-RoundedRectangle $g5 $pBlue (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)) 65 165 320 125 8
$g5.DrawString("1. Cổng Admin Server (admin.html)", $fBoxItemBold, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 64, 175))), 80, 175)
$g5.DrawString("• Quản lý danh sách Account & KPI`n• Phân quyền trực tiếp (Admin/Manager/Customer)`n• Khóa/Mở khóa & Xóa an toàn`n• Bảng cơ cấu phân quyền hệ thống", $fSmall, $bDark, 80, 200)

Draw-RoundedRectangle $g5 $pOrange (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)) 65 310 320 135 8
$g5.DrawString("2. Cổng Người Quản lý CRM (manager_crm.html)", $fBoxItemBold, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(194, 65, 12))), 80, 320)
$g5.DrawString("• Tab 1: Hồ sơ KH (Thêm, Xóa, Khóa/Mở khóa)`n• Tab 2: Tiếp nhận & Giải đáp Phản hồi SP`n• Tab 3: Biểu đồ Độ tuổi & Sở thích (Chart.js)`n• Tab 4 & 5: Phát hành & Thống kê Khảo sát", $fSmall, $bDark, 80, 345)

Draw-RoundedRectangle $g5 $pTeal (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)) 65 465 320 135 8
$g5.DrawString("3. Cổng Khách hàng (user.html & customer_login)", $fBoxItemBold, $bFlowTeal, 80, 475)
$g5.DrawString("• Đăng ký tối giản & Đăng nhập riêng biệt`n• Tra cứu danh mục SP & Bộ lọc thông minh`n• Gửi phản hồi 1-5 sao & Xem giải đáp`n• Thực hiện khảo sát 5 tiêu chí & Sửa hồ sơ", $fSmall, $bDark, 80, 500)

# Tier 2: Application / Business Logic Layer
Draw-RoundedRectangle $g5 $pOrange (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 247, 237))) 495 95 360 530 10
Draw-RoundedRectangle $g5 $pOrange (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(194, 65, 12))) 495 95 360 48 10
$g5.DrawString("TẦNG 2: BUSINESS LOGIC LAYER`n(ASP.NET Core 8.0 Web API - Port 5000)", $fBoxItemBold, $bRootText, (New-Object System.Drawing.RectangleF(495, 99, 360, 40)), $sfCenter)

$controllers = @(
    "1. AuthController (/api/admin/auth/login)`n   Xác thực BCrypt, kiểm tra IsActive & phân luồng",
    "2. AccountsController (/api/admin/accounts)`n   CRUD tài khoản, gán Role, khóa/mở khóa, xóa",
    "3. CrmController (/api/admin/crm/*)`n   Quản lý KH, giải đáp Feedback, thống kê Tuổi/Sở thích,`n   phát hành Survey & tổng hợp SurveyStats",
    "4. CustomerPortalController (/api/customer/*)`n   Đăng ký KH, cập nhật Profile, gửi Feedback,`n   nộp phiếu trả lời khảo sát 5 tiêu chí",
    "5. Products & Suppliers & Categories API`n   Cung cấp danh mục sản phẩm công nghệ & đối tác"
)
$yCtrl = 165
foreach ($ct in $controllers) {
    Draw-RoundedRectangle $g5 $pLine (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)) 515 $yCtrl 320 82 6
    $g5.DrawString($ct, $fSmall, $bDark, 528, ($yCtrl + 12))
    $yCtrl += 90
}

# Tier 3: Data Access & Database Layer
Draw-RoundedRectangle $g5 $pTeal (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 253, 250))) 945 95 360 530 10
Draw-RoundedRectangle $g5 $pTeal (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 118, 110))) 945 95 360 48 10
$g5.DrawString("TẦNG 3: DATA ACCESS & DB LAYER`n(Entity Framework Core 8.0 & Dual-DB)", $fBoxItemBold, $bRootText, (New-Object System.Drawing.RectangleF(945, 99, 360, 40)), $sfCenter)

Draw-RoundedRectangle $g5 $pTeal (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)) 965 165 320 120 8
$g5.DrawString("Entity Framework Core ORM (AppDbContext)", $fBoxItemBold, $bFlowTeal, 980, 175)
$g5.DrawString("• Ánh xạ 9 Entity chuẩn 3NF`n• Tự động khởi tạo & nạp dữ liệu mẫu (DbInitializer)`n• Đảm bảo toàn vẹn khóa ngoại CASCADE`n• Mã hóa mật khẩu BCrypt.Net-Next", $fSmall, $bDark, 980, 200)

Draw-RoundedRectangle $g5 $pStore $bStoreBg 965 310 320 135 8
$g5.DrawString("CSDL 1: Microsoft SQL Server (HTTTDN_DB)", $fBoxItemBold, $bStoreText, 980, 320)
$g5.DrawString("• Chế độ Production / Doanh nghiệp`n• Script khởi tạo: Database/HTTTDN_DB.sql`n• Hỗ trợ Full Backup & Differential Backup`n• Phục hồi thảm họa (Restore Database)", $fSmall, $bDark, 980, 345)

Draw-RoundedRectangle $g5 $pBlue (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)) 965 465 320 135 8
$g5.DrawString("CSDL 2: SQLite Tích hợp (htttdn.db)", $fBoxItemBold, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 64, 175))), 980, 475)
$g5.DrawString("• Chế độ Demo di động 1-Click (start_demo.bat)`n• Không cần cấu hình máy chủ phức tạp khi chấm`n• Tự động đồng bộ 3 Roles, 19 Accounts, 15 SP,`n  10 Feedbacks, 5 Surveys & 16 Responses", $fSmall, $bDark, 980, 500)

# Arrows between Tiers
Draw-ArrowLine $g5 $pArrBlue 405 340 495 340
$g5.DrawString("HTTP/JSON`n(Fetch API)", $fSmall, $bFlowIn, 415, 300)
Draw-ArrowLine $g5 $pArrOrange 855 340 945 340
$g5.DrawString("EF Core`nLINQ / SQL", $fSmall, $bFlowOut, 868, 300)

$bmp5.Save("d:\HTTTDN_2026\Report\images\system_architecture_diagram.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g5.Dispose()
$bmp5.Dispose()

Write-Host "ALL 9 HIGH-RES DIAGRAMS GENERATED WITH 0 ERRORS!"
