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

# Common Global Fonts
$fTitle = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$fSub = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
$fBoxHeader = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$fBoxItem = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Regular)
$fBoxItemBold = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$fFlow = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$fSmall = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Regular)
$fKey = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)

# String Format
$sfCenter = New-Object System.Drawing.StringFormat
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

# ==============================================================================
# 1. GENERATE BFD DIAGRAM (SƠ ĐỒ PHÂN RÃ CHỨC NĂNG)
# ==============================================================================
Write-Host "1/4 Generating BFD diagram..."
$bmp1 = New-Object System.Drawing.Bitmap 1400, 860
$g1 = [System.Drawing.Graphics]::FromImage($bmp1)
$g1.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g1.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g1.Clear([System.Drawing.Color]::FromArgb(248, 250, 252))

$bDark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 23, 42))
$bSub = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(100, 116, 139))
$pLine = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(148, 163, 184), 2)
$pOrange = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 91, 0), 2)
$pBlue = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(37, 99, 235), 2)
$pTeal = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(13, 148, 136), 2)

# Title Header
$g1.DrawString("SƠ ĐỒ PHÂN RÃ CHỨC NĂNG (BUSINESS FUNCTION DIAGRAM - BFD)", $fTitle, $bDark, (New-Object System.Drawing.RectangleF(50, 20, 1300, 30)), $sfCenter)
$g1.DrawString("Hệ thống thông tin Quản trị Doanh nghiệp Thương mại SGU Tech - Mô hình Phân hệ CRM và Admin Server", $fSub, $bSub, (New-Object System.Drawing.RectangleF(50, 52, 1300, 20)), $sfCenter)

# Root Box
$bRoot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 41, 59))
$pRoot = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(15, 23, 42), 2)
$bRootText = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
Draw-RoundedRectangle $g1 $pRoot $bRoot 450 85 500 65 8
$g1.DrawString("HỆ THỐNG THÔNG TIN DOANH NGHIỆP SGU TECH", $fBoxHeader, $bRootText, (New-Object System.Drawing.RectangleF(450, 92, 500, 30)), $sfCenter)
$g1.DrawString("(Mô hình quản trị doanh nghiệp và phân hệ CRM)", $fSub, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(203, 213, 225))), (New-Object System.Drawing.RectangleF(450, 120, 500, 25)), $sfCenter)

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
$g1.DrawString("Quản trị hệ thống & Phân quyền", $fSub, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(191, 219, 254))), (New-Object System.Drawing.RectangleF(45, 247, 340, 18)), $sfCenter)

$adminFuncs = @(
    "1.1 Thêm tài khoản mới (Account)",
    "    - Cấp tài khoản nhân viên / quản lý",
    "    - Mã hóa mật khẩu bảo mật BCrypt",
    "1.2 Xóa & Khóa/Mở tài khoản",
    "    - Kiểm soát trạng thái hoạt động",
    "    - Xóa tài khoản an toàn khóa ngoại",
    "1.3 Phân quyền cho Account",
    "    - Gán vai trò (Admin, Manager, Customer)",
    "    - Quản lý ma trận quyền hạn",
    "1.4 Tách biệt hệ thống theo yêu cầu",
    "    - Tách biệt cổng Quản lý nhân sự (HR)",
    "    - Tách biệt Quản lý kho (Warehouse)",
    "    - Tách biệt Quản lý bán hàng (Sales)",
    "    - Lược bỏ tra cứu SP/NCC ở Admin",
    "1.5 Kịch bản Sao lưu & Phục hồi",
    "    - Full Backup định kỳ hàng tuần",
    "    - Differential Backup mỗi ngày",
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
$g1.DrawString("Quản lý Quan hệ Khách hàng (7 chức năng)", $fSub, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(254, 215, 170))), (New-Object System.Drawing.RectangleF(525, 247, 350, 18)), $sfCenter)

$mgrFuncs = @(
    "2.1 Thêm một khách hàng mới",
    "    - Nhập thông tin & hồ sơ nhân khẩu học",
    "2.2 Xóa khách hàng",
    "    - Xóa an toàn kèm phản hồi liên kết",
    "2.3 Khóa tài khoản khách hàng",
    "    - Chặn đăng nhập khi có vi phạm",
    "2.4 Tiếp nhận phản hồi của khách hàng",
    "    - Xem đánh giá 1-5 sao theo sản phẩm",
    "    - Gửi lời giải đáp chính thức từ quản lý",
    "2.5 Báo cáo tỷ lệ độ tuổi & sở thích",
    "    - Biểu đồ phân bố độ tuổi (<20, 20-30, >30)",
    "    - Biểu đồ phân loại sở thích tiêu dùng",
    "2.6 Tạo bảng khảo sát gửi đến TK khách hàng",
    "    - Đặt tên SP, giá dự kiến, hạn kết thúc",
    "    - Phân phối phiếu khảo sát tới khách hàng",
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
$g1.DrawString("Cổng thông tin & Trải nghiệm khách hàng", $fSub, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(204, 251, 241))), (New-Object System.Drawing.RectangleF(1015, 247, 340, 18)), $sfCenter)

$custFuncs = @(
    "3.1 Đăng ký tài khoản khách hàng",
    "    - Form đăng ký tối giản, tiện lợi",
    "    - Tự động tạo hồ sơ khách hàng mặc định",
    "3.2 Đăng nhập hệ thống",
    "    - Xác thực bảo mật, phân luồng Cổng KH",
    "    - Giao diện chuẩn VNG Corporation",
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
Write-Host "BFD diagram generated: Report\images\bfd_diagram.png"

# ==============================================================================
# 2. GENERATE CONTEXT DIAGRAM (SƠ ĐỒ NGỮ CẢNH)
# ==============================================================================
Write-Host "2/4 Generating Context Diagram..."
$bmp2 = New-Object System.Drawing.Bitmap 1350, 800
$g2 = [System.Drawing.Graphics]::FromImage($bmp2)
$g2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g2.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g2.Clear([System.Drawing.Color]::FromArgb(248, 250, 252))

$g2.DrawString("SƠ ĐỒ NGỮ CẢNH (CONTEXT DIAGRAM - DFD MỨC NGỮ CẢNH)", $fTitle, $bDark, (New-Object System.Drawing.RectangleF(50, 20, 1250, 30)), $sfCenter)
$g2.DrawString("Mô tả tương tác luồng thông tin giữa Hệ thống Trung tâm và 3 Tác nhân ngoài", $fSub, $bSub, (New-Object System.Drawing.RectangleF(50, 52, 1250, 20)), $sfCenter)

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

# Arrow Pens
$capArrow = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(5, 5, $true)
$pArrBlue = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(37, 99, 235), 2)
$pArrBlue.CustomEndCap = $capArrow
$pArrOrange = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(234, 88, 12), 2)
$pArrOrange.CustomEndCap = $capArrow
$pArrTeal = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(13, 148, 136), 2)
$pArrTeal.CustomEndCap = $capArrow

$bFlowIn = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 64, 175))
$bFlowOut = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(194, 65, 12))

# Admin -> System
Draw-ArrowLine $g2 $pArrBlue 370 150 515 285
$g2.DrawString("(+) Thông tin Account, Lệnh phân quyền, Lệnh khóa/xóa", $fFlow, $bFlowIn, 150, 235)

# System -> Admin
Draw-ArrowLine $g2 $pArrOrange 500 330 350 230
$g2.DrawString("(-) Trạng thái tài khoản, Phân tách hệ thống, Log CSDL", $fFlow, $bFlowOut, 110, 275)

# Customer -> System
Draw-ArrowLine $g2 $pArrTeal 980 150 835 285
$g2.DrawString("(+) Đăng ký tài khoản, Đánh giá sản phẩm (1-5★), Phiếu khảo sát 5 tiêu chí", $fFlow, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 118, 110))), 740, 235)

# System -> Customer
Draw-ArrowLine $g2 $pArrOrange 850 330 1000 230
$g2.DrawString("(-) Danh mục sản phẩm, Lời giải đáp phản hồi, Khảo sát thị trường mới", $fFlow, $bFlowOut, 800, 275)

# Manager -> System
Draw-ArrowLine $g2 $pArrOrange 620 620 620 540
$g2.DrawString("(+) Khảo sát sản phẩm mới, Giải đáp phản hồi, Thêm/Xóa/Khóa KH", $fFlow, $bFlowIn, 180, 560)

# System -> Manager
Draw-ArrowLine $g2 $pArrOrange 730 540 730 620
$g2.DrawString("(-) Báo cáo tuổi & sở thích, Thống kê khảo sát, DS phản hồi chờ duyệt", $fFlow, $bFlowOut, 745, 560)

# Legend
Draw-RoundedRectangle $g2 $pLine (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)) 50 710 400 65 6
$g2.DrawString("Chú thích:", $fBoxItemBold, $bDark, 65, 718)
$g2.DrawString("(+) Luồng thông tin gửi vào Hệ thống (Dữ liệu tác nghiệp/yêu cầu)", $fSmall, $bFlowIn, 65, 736)
$g2.DrawString("(-) Luồng thông tin kết xuất từ Hệ thống (Báo cáo, danh mục, giải đáp)", $fSmall, $bFlowOut, 65, 753)

$bmp2.Save("d:\HTTTDN_2026\Report\images\context_diagram.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g2.Dispose()
$bmp2.Dispose()
Write-Host "Context diagram generated: Report\images\context_diagram.png"

# ==============================================================================
# 3. GENERATE DFD LEVEL 0 (SƠ ĐỒ LUỒNG DỮ LIỆU MỨC ĐỈNH)
# ==============================================================================
Write-Host "3/4 Generating Level 0 DFD Diagram..."
$bmp3 = New-Object System.Drawing.Bitmap 1550, 1020
$g3 = [System.Drawing.Graphics]::FromImage($bmp3)
$g3.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g3.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g3.Clear([System.Drawing.Color]::FromArgb(248, 250, 252))

$g3.DrawString("SƠ ĐỒ LUỒNG DỮ LIỆU MỨC ĐỈNH (LEVEL 0 DFD)", $fTitle, $bDark, (New-Object System.Drawing.RectangleF(50, 15, 1450, 30)), $sfCenter)
$g3.DrawString("Mô tả chi tiết 5 Tiến trình chính, 3 Tác nhân ngoài và 5 Kho dữ liệu tập trung (D1 - D5)", $fSub, $bSub, (New-Object System.Drawing.RectangleF(50, 45, 1450, 20)), $sfCenter)

# 3 Entities
Draw-RoundedRectangle $g3 $pBlue (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(239, 246, 255))) 60 85 240 70 6
$g3.DrawString("Quản trị viên`n(Admin Server)", $fBoxHeader, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 64, 175))), (New-Object System.Drawing.RectangleF(60, 95, 240, 50)), $sfCenter)

Draw-RoundedRectangle $g3 $pOrange (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 247, 237))) 655 85 240 70 6
$g3.DrawString("Người quản lý`n(CRM Manager)", $fBoxHeader, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(194, 65, 12))), (New-Object System.Drawing.RectangleF(655, 95, 240, 50)), $sfCenter)

Draw-RoundedRectangle $g3 $pTeal (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 253, 250))) 1250 85 240 70 6
$g3.DrawString("Khách hàng`n(Customer)", $fBoxHeader, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 118, 110))), (New-Object System.Drawing.RectangleF(1250, 95, 240, 50)), $sfCenter)

# Helper for Process Drawing
function Draw-DFDProcess($g, [float]$x, [float]$y, [float]$w, [float]$h, $num, $name, $desc) {
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(59, 130, 246), 2)
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    Draw-RoundedRectangle $g $pen $brush $x $y $w $h 10
    
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    
    $fN = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $fT = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $fD = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Regular)
    $bD = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 23, 42))
    $bS = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(71, 85, 105))
    $bNum = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(194, 65, 12))
    
    $rectN = New-Object System.Drawing.RectangleF($x, ($y + 6.0), $w, 18.0)
    $rectT = New-Object System.Drawing.RectangleF($x, ($y + 24.0), $w, 24.0)
    $rectD = New-Object System.Drawing.RectangleF(($x + 5.0), ($y + 48.0), ($w - 10.0), 25.0)
    
    $g.DrawString($num, $fN, $bNum, $rectN, $sf)
    $g.DrawString($name, $fT, $bD, $rectT, $sf)
    $g.DrawString($desc, $fD, $bS, $rectD, $sf)
}

# 5 Processes
Draw-DFDProcess $g3 60 220 250 80 "TIẾN TRÌNH 1.0" "Quản trị Tài khoản & Phân quyền" "Thêm, xóa, khóa và phân quyền Account"
Draw-DFDProcess $g3 460 220 260 80 "TIẾN TRÌNH 2.0" "Quản lý Khách hàng & Báo cáo" "Thêm/Xóa/Khóa KH, Báo cáo tuổi/sở thích"
Draw-DFDProcess $g3 840 220 260 80 "TIẾN TRÌNH 3.0" "Tiếp nhận & Giải đáp Phản hồi" "Đánh giá 1-5 sao, giải đáp phản hồi SP"
Draw-DFDProcess $g3 460 520 260 80 "TIẾN TRÌNH 4.0" "Khảo sát Sản phẩm Mới & Thống kê" "Phát hành phiếu khảo sát, thống kê ý định mua"
Draw-DFDProcess $g3 1240 220 260 80 "TIẾN TRÌNH 5.0" "Cổng Tương tác Khách hàng" "Đăng ký, đăng nhập, sửa hồ sơ cá nhân"

# 5 Data Stores
$pStore = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 38, 38), 2)
$bStoreBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(254, 242, 242))
$bStoreText = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(153, 27, 27))
$fStoreCode = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fStoreName = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Regular)

Draw-DataStoreBox $g3 $pStore $bStoreBg 60 380 320 50 "D1" "Kho Tài khoản & Phân quyền (Accounts, Roles)" $fStoreCode $fStoreName $bStoreText
Draw-DataStoreBox $g3 $pStore $bStoreBg 460 380 320 50 "D2" "Kho Hồ sơ Khách hàng (CustomerProfiles)" $fStoreCode $fStoreName $bStoreText
Draw-DataStoreBox $g3 $pStore $bStoreBg 860 380 320 50 "D4" "Kho Đánh giá Phản hồi (Feedbacks)" $fStoreCode $fStoreName $bStoreText
Draw-DataStoreBox $g3 $pStore $bStoreBg 460 670 320 50 "D5" "Kho Khảo sát & Ý kiến (Surveys, Responses)" $fStoreCode $fStoreName $bStoreText
Draw-DataStoreBox $g3 $pStore $bStoreBg 860 670 320 50 "D3" "Kho Sản phẩm & Đối tác (Products, Categories)" $fStoreCode $fStoreName $bStoreText

# Arrows
$pArrDark = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(30, 41, 59), 1.5)
$pArrDark.CustomEndCap = $capArrow

# Admin -> P1
Draw-ArrowLine $g3 $pArrBlue 180 155 180 220
$g3.DrawString("Yêu cầu Account/Quyền", $fSmall, $bFlowIn, 70, 180)

# P1 <-> D1
Draw-ArrowLine $g3 $pArrDark 150 300 150 380
$g3.DrawString("Ghi nhận / Cập nhật quyền", $fSmall, $bSub, 60, 335)
Draw-ArrowLine $g3 $pArrDark 200 380 200 300
$g3.DrawString("Đọc Account / Role", $fSmall, $bSub, 205, 335)

# Manager -> P2
Draw-ArrowLine $g3 $pArrOrange 730 155 630 220
$g3.DrawString("Thêm/Xóa/Khóa KH", $fSmall, $bFlowIn, 570, 180)

# P2 <-> D2
Draw-ArrowLine $g3 $pArrDark 560 300 560 380
$g3.DrawString("Ghi nhận hồ sơ KH", $fSmall, $bSub, 470, 335)
Draw-ArrowLine $g3 $pArrDark 620 380 620 300
$g3.DrawString("Đọc tuổi / sở thích", $fSmall, $bSub, 625, 335)

# P2 -> Manager
Draw-ArrowLine $g3 $pArrOrange 600 220 700 155
$g3.DrawString("Báo cáo biểu đồ độ tuổi & sở thích", $fSmall, $bFlowOut, 640, 160)

# Customer -> P3
Draw-ArrowLine $g3 $pArrTeal 1270 155 1060 220
$g3.DrawString("Gửi đánh giá sản phẩm (1-5★)", $fSmall, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 118, 110))), 1080, 175)

# Manager -> P3
Draw-ArrowLine $g3 $pArrOrange 810 155 920 220
$g3.DrawString("Giải đáp phản hồi", $fSmall, $bFlowIn, 840, 180)

# P3 <-> D4
Draw-ArrowLine $g3 $pArrDark 980 300 980 380
$g3.DrawString("Lưu phản hồi & lời giải đáp", $fSmall, $bSub, 880, 335)
Draw-ArrowLine $g3 $pArrDark 1040 380 1040 300
$g3.DrawString("Đọc danh sách phản hồi", $fSmall, $bSub, 1045, 335)

# D4 -> Customer
Draw-ArrowLine $g3 $pArrTeal 1080 380 1330 160
$g3.DrawString("Xem lời giải đáp từ Quản lý", $fSmall, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 118, 110))), 1150, 310)

# Manager -> P4
Draw-ArrowLine $g3 $pArrOrange 775 155 590 520
$g3.DrawString("Tạo bài khảo sát SP mới có thời hạn", $fSmall, $bFlowIn, 690, 460)

# P4 <-> D5
Draw-ArrowLine $g3 $pArrDark 560 600 560 670
$g3.DrawString("Ghi bảng khảo sát", $fSmall, $bSub, 470, 630)
Draw-ArrowLine $g3 $pArrDark 620 670 620 600
$g3.DrawString("Đọc thống kê câu trả lời", $fSmall, $bSub, 625, 630)

# P4 -> Manager
Draw-ArrowLine $g3 $pArrOrange 540 520 740 160
$g3.DrawString("Bảng thống kê tỷ lệ mua & điểm trung bình", $fSmall, $bFlowOut, 500, 480)

# D5 -> Customer
Draw-ArrowLine $g3 $pArrTeal 780 680 1320 160
$g3.DrawString("Nhận bài khảo sát SP mới đang mở", $fSmall, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 118, 110))), 1120, 520)

# Customer -> P4
Draw-ArrowLine $g3 $pArrTeal 1350 160 720 550
$g3.DrawString("Nộp kết quả trả lời khảo sát 5 chiều", $fSmall, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 118, 110))), 920, 470)

# Customer <-> P5
Draw-ArrowLine $g3 $pArrTeal 1370 155 1370 220
$g3.DrawString("Đăng ký / Đăng nhập / Sửa hồ sơ", $fSmall, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 118, 110))), 1260, 185)

# P5 <-> D1 & D2
Draw-ArrowLine $g3 $pArrDark 1240 260 380 405
$g3.DrawString("Ghi nhận tài khoản mới vào D1", $fSmall, $bSub, 680, 310)

# D3 -> P3 & P5
Draw-ArrowLine $g3 $pArrDark 980 670 980 300
$g3.DrawString("Đọc thông tin sản phẩm từ D3", $fSmall, $bSub, 985, 520)

# Rules notes
Draw-RoundedRectangle $g3 $pLine (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)) 60 760 1430 210 8
$g3.DrawString("QUY TẮC PHÂN LUỒNG VÀ TOÀN VẸN DỮ LIỆU CỦA HỆ THỐNG:", $fBoxItemBold, $bDark, 80, 775)
$rules = @(
    "1. Tính tách biệt tuyệt đối: Quản trị viên chỉ làm việc với D1 (Tài khoản & Phân quyền), không can thiệp nghiệp vụ kinh doanh hay tra cứu SP/NCC.",
    "2. Phân hệ CRM Người Quản lý: Độc quyền khai thác D2 (Hồ sơ KH), D4 (Phản hồi giải đáp) và D5 (Khảo sát thị trường) để ra quyết định thương mại.",
    "3. Tương tác Khách hàng hai chiều: Khách hàng chỉ truy cập qua Cổng khách hàng độc lập, tự chủ gửi đánh giá SP vào D4 và làm khảo sát vào D5.",
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
Write-Host "DFD Level 0 diagram generated: Report\images\dfd_level0_diagram.png"

# ==============================================================================
# 4. GENERATE ERD DIAGRAM (LƯỢC ĐỒ CSDL QUAN HỆ THỰC THỂ)
# ==============================================================================
Write-Host "4/4 Generating ERD diagram..."
$bmp4 = New-Object System.Drawing.Bitmap 1550, 1080
$g4 = [System.Drawing.Graphics]::FromImage($bmp4)
$g4.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g4.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g4.Clear([System.Drawing.Color]::FromArgb(248, 250, 252))

$g4.DrawString("LƯỢC ĐỒ QUAN HỆ THỰC THỂ CƠ SỞ DỮ LIỆU (RELATIONAL SCHEMA / ERD)", $fTitle, $bDark, (New-Object System.Drawing.RectangleF(50, 15, 1450, 30)), $sfCenter)
$g4.DrawString("Mô hình 8 Bảng chuẩn hóa 3NF thiết kế trực tiếp từ các kho dữ liệu D1, D2, D3, D4, D5", $fSub, $bSub, (New-Object System.Drawing.RectangleF(50, 45, 1450, 20)), $sfCenter)

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

# 1. Roles
$colsRoles = @(
    "PK | RoleId | INT IDENTITY",
    "   | RoleName | NVARCHAR(50)",
    "   | Description | NVARCHAR(250)"
)
Draw-ERDTable $g4 50 100 280 "Roles (D1: Quyền)" "#1E3A8A" $colsRoles

# 2. Accounts
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
Draw-ERDTable $g4 50 240 310 "Accounts (D1: Tài khoản)" "#1E3A8A" $colsAccounts

# 3. CustomerProfiles
$colsProfiles = @(
    "PK | ProfileId | INT IDENTITY",
    "FK | AccountId | INT (UNIQUE, CASCADE)",
    "   | Age | INT (NOT NULL)",
    "   | Gender | NVARCHAR(10)",
    "   | Address | NVARCHAR(255)",
    "   | Interest | NVARCHAR(100)"
)
Draw-ERDTable $g4 50 515 310 "CustomerProfiles (D2: Hồ sơ KH)" "#0D9488" $colsProfiles

# 4. Categories
$colsCat = @(
    "PK | CategoryId | INT IDENTITY",
    "   | CategoryName | NVARCHAR(100)",
    "   | Description | NVARCHAR(255)"
)
Draw-ERDTable $g4 1220 100 280 "Categories (D3: Danh mục)" "#0284C7" $colsCat

# 5. Suppliers
$colsSup = @(
    "PK | SupplierId | INT IDENTITY",
    "   | SupplierCode | VARCHAR(20)",
    "   | SupplierName | NVARCHAR(150)",
    "   | ContactName | NVARCHAR(100)",
    "   | Phone | VARCHAR(20)",
    "   | Address | NVARCHAR(255)"
)
Draw-ERDTable $g4 860 100 310 "Suppliers (D3: Nhà cung cấp)" "#0284C7" $colsSup

# 6. Products
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
Draw-ERDTable $g4 1050 320 330 "Products (D3: Hàng hóa / SP)" "#0284C7" $colsProd

# 7. Feedbacks
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
Draw-ERDTable $g4 520 280 340 "Feedbacks (D4: Phản hồi & Giải đáp)" "#EA580C" $colsFeed

# 8. Surveys
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
Draw-ERDTable $g4 520 560 340 "Surveys (D5: Khảo sát thị trường)" "#C2410C" $colsSurveys

# 9. SurveyResponses
$colsResp = @(
    "PK | ResponseId | INT IDENTITY",
    "FK | SurveyId | INT (-> Surveys)",
    "FK | AccountId | INT (-> Accounts)",
    "   | Score | INT (CHECK 1-5)",
    "   | BuyingIntent | NVARCHAR(50)",
    "   | CustomerOpinion | NVARCHAR(1000)",
    "   | SubmittedAt | DATETIME"
)
Draw-ERDTable $g4 980 660 340 "SurveyResponses (D5: Kết quả KS)" "#C2410C" $colsResp

# Relationships
$pRel = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(71, 85, 105), 1.5)
$pRel.CustomEndCap = $capArrow

# Roles (1) -> (N) Accounts
Draw-ArrowLine $g4 $pRel 190 200 190 240
$g4.DrawString("1 : N", $fKey, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 64, 175))), 195, 215)

# Accounts (1) -> (1) CustomerProfiles
Draw-ArrowLine $g4 $pRel 190 480 190 515
$g4.DrawString("1 : 1 (CASCADE)", $fKey, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(13, 148, 136))), 195, 492)

# Accounts (1) -> (N) Feedbacks
Draw-ArrowLine $g4 $pRel 360 320 520 320
$g4.DrawString("1 : N", $fKey, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(234, 88, 12))), 430, 305)

# Products (1) -> (N) Feedbacks
Draw-ArrowLine $g4 $pRel 1050 400 860 350
$g4.DrawString("1 : N", $fKey, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(2, 132, 199))), 940, 365)

# Categories (1) -> (N) Products
Draw-ArrowLine $g4 $pRel 1350 200 1350 320
$g4.DrawString("1 : N", $fKey, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(2, 132, 199))), 1355, 250)

# Suppliers (1) -> (N) Products
Draw-ArrowLine $g4 $pRel 1010 250 1100 320
$g4.DrawString("1 : N", $fKey, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(2, 132, 199))), 1040, 275)

# Surveys (1) -> (N) SurveyResponses
Draw-ArrowLine $g4 $pRel 860 670 980 720
$g4.DrawString("1 : N", $fKey, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(194, 65, 12))), 890, 680)

# Accounts (1) -> (N) SurveyResponses (Segmented path)
$pathAccResp = New-Object System.Drawing.Drawing2D.GraphicsPath
$pathAccResp.AddLine(360, 420, 480, 420)
$pathAccResp.AddLine(480, 420, 480, 800)
$pathAccResp.AddLine(480, 800, 980, 800)
$pPathPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(71, 85, 105), 1.5)
$pPathPen.CustomEndCap = $capArrow
$g4.DrawPath($pPathPen, $pathAccResp)
$g4.DrawString("1 : N", $fKey, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 64, 175))), 490, 780)

# ERD Legend Box
Draw-RoundedRectangle $g4 $pLine (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)) 50 880 1450 160 8
$g4.DrawString("GHI CHÚ CHUẨN HÓA DỮ LIỆU & RÀNG BUỘC TOÀN VẸN (3NF DATA INTEGRITY):", $fBoxItemBold, $bDark, 70, 895)
$erdNotes = @(
    "1. Đạt chuẩn 3NF: Mọi thuộc tính không khóa đều phụ thuộc trực tiếp vào khóa chính PK, không có thuộc tính phụ thuộc bắc cầu.",
    "2. Khóa ngoại CASCADE: Xóa tài khoản khách hàng ở bảng Accounts sẽ tự động dọn dẹp CustomerProfiles, Feedbacks và SurveyResponses tương ứng.",
    "3. Quản trị vòng đời khảo sát: Cột ExpiresAt tại bảng Surveys cho phép đóng khảo sát tự động mà không cần can thiệp thủ công từ quản trị viên.",
    "4. Tính độc lập phân hệ: CSDL phục vụ phân hệ Quản lý Quan hệ Khách hàng CRM và Quản trị Admin, sẵn sàng mở rộng liên kết với Kho (Warehouse) và Nhân sự (HR)."
)
$yE = 922
foreach ($en in $erdNotes) {
    $g4.DrawString($en, $fSmall, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(71, 85, 105))), 70, $yE)
    $yE += 26
}

$bmp4.Save("d:\HTTTDN_2026\Report\images\erd_diagram.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g4.Dispose()
$bmp4.Dispose()
Write-Host "ERD diagram generated: Report\images\erd_diagram.png"
Write-Host "ALL 4 DIAGRAMS GENERATED WITH 0 ERRORS!"
