$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$OutputPath = "d:\HTTTDN_2026\Report\BAO_CAO_DO_AN_HTTTDN.docx"
$ImageDir = "d:\HTTTDN_2026\Report\images"

function Escape-Xml([string]$s) {
    if ($null -eq $s) { return "" }
    return [System.Security.SecurityElement]::Escape($s)
}

function New-WP {
    param(
        [string]$Text = "",
        [bool]$Bold = $false,
        [bool]$Italic = $false,
        [int]$Size = 26,
        [string]$Align = "both",
        [string]$Color = "000000",
        [int]$SpaceBefore = 80,
        [int]$SpaceAfter = 120,
        [int]$IndentFirst = 0,
        [string]$Shading = "",
        [string]$Font = "Times New Roman"
    )
    $pPr = "<w:jc w:val=`"$Align`"/><w:spacing w:before=`"$SpaceBefore`" w:after=`"$SpaceAfter`" w:line=`"312`" w:lineRule=`"auto`"/>"
    if ($IndentFirst -gt 0) {
        $pPr += "<w:ind w:firstLine=`"$IndentFirst`"/>"
    }
    if ($Shading -ne "") {
        $pPr += "<w:shd w:val=`"clear`" w:color=`"auto`" w:fill=`"$Shading`"/>"
        $pPr += "<w:pBdr><w:left w:val=`"single`" w:sz=`"18`" w:space=`"8`" w:color=`"1D4ED8`"/></w:pBdr>"
    }

    $rPr = "<w:rFonts w:ascii=`"$Font`" w:hAnsi=`"$Font`" w:cs=`"$Font`"/><w:sz w:val=`"$Size`"/><w:szCs w:val=`"$Size`"/><w:color w:val=`"$Color`"/>"
    if ($Bold) { $rPr += "<w:b/><w:bCs/>" }
    if ($Italic) { $rPr += "<w:i/><w:iCs/>" }

    $lines = $Text -split "`n"
    $runs = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($i -gt 0) {
            [void]$runs.Append("<w:r><w:br/></w:r>")
        }
        $escaped = Escape-Xml $lines[$i]
        [void]$runs.Append("<w:r><w:rPr>$rPr</w:rPr><w:t xml:space=`"preserve`">$escaped</w:t></w:r>")
    }
    return "<w:p><w:pPr>$pPr</w:pPr>$($runs.ToString())</w:p>"
}

function New-WBullet([string]$Label, [string]$Text, [int]$Size = 26) {
    $pPr = "<w:jc w:val=`"both`"/><w:spacing w:before=`"60`" w:after=`"90`" w:line=`"300`" w:lineRule=`"auto`"/><w:ind w:left=`"360`" w:hanging=`"240`"/>"
    $rPrBold = "<w:rFonts w:ascii=`"Times New Roman`" w:hAnsi=`"Times New Roman`" w:cs=`"Times New Roman`"/><w:b/><w:bCs/><w:sz w:val=`"$Size`"/><w:szCs w:val=`"$Size`"/><w:color w:val=`"0F172A`"/>"
    $rPrNorm = "<w:rFonts w:ascii=`"Times New Roman`" w:hAnsi=`"Times New Roman`" w:cs=`"Times New Roman`"/><w:sz w:val=`"$Size`"/><w:szCs w:val=`"$Size`"/><w:color w:val=`"000000`"/>"
    $escLabel = Escape-Xml $Label
    $escText = Escape-Xml $Text
    if ($Label -ne "") {
        return "<w:p><w:pPr>$pPr</w:pPr><w:r><w:rPr>$rPrBold</w:rPr><w:t xml:space=`"preserve`">• $escLabel </w:t></w:r><w:r><w:rPr>$rPrNorm</w:rPr><w:t xml:space=`"preserve`">$escText</w:t></w:r></w:p>"
    } else {
        return "<w:p><w:pPr>$pPr</w:pPr><w:r><w:rPr>$rPrNorm</w:rPr><w:t xml:space=`"preserve`">• $escText</w:t></w:r></w:p>"
    }
}

function New-WImage {
    param(
        [string]$RelId,
        [long]$WidthEmu = 5486400,
        [long]$HeightEmu = 3400000,
        [string]$Caption = "",
        [int]$DocPrId = 1
    )
    $capXml = ""
    if ($Caption -ne "") {
        $escCap = Escape-Xml $Caption
        $capXml = "<w:p><w:pPr><w:jc w:val=`"center`"/><w:spacing w:before=`"60`" w:after=`"180`"/></w:pPr><w:r><w:rPr><w:rFonts w:ascii=`"Times New Roman`" w:hAnsi=`"Times New Roman`"/><w:sz w:val=`"22`"/><w:i/><w:color w:val=`"1E3A8A`"/><w:b/></w:rPr><w:t xml:space=`"preserve`">$escCap</w:t></w:r></w:p>"
    }
    return @"
<w:p>
    <w:pPr>
        <w:jc w:val="center"/>
        <w:spacing w:before="140" w:after="60"/>
    </w:pPr>
    <w:r>
        <w:drawing>
            <wp:inline distT="0" distB="0" distL="0" distR="0">
                <wp:extent cx="$WidthEmu" cy="$HeightEmu"/>
                <wp:docPr id="$DocPrId" name="Picture $DocPrId"/>
                <wp:cNvGraphicFramePr>
                    <a:graphicFrameLocks xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" noChangeAspect="1"/>
                </wp:cNvGraphicFramePr>
                <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
                    <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                        <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
                            <pic:nvPicPr>
                                <pic:cNvPr id="$DocPrId" name="Picture $DocPrId"/>
                                <pic:cNvPicPr/>
                            </pic:nvPicPr>
                            <pic:blipFill>
                                <a:blip r:embed="$RelId"/>
                                <a:stretch>
                                    <a:fillRect/>
                                </a:stretch>
                            </pic:blipFill>
                            <pic:spPr>
                                <a:xfrm>
                                    <a:off x="0" y="0"/>
                                    <a:ext cx="$WidthEmu" cy="$HeightEmu"/>
                                </a:xfrm>
                                <a:prstGeom prst="rect">
                                    <a:avLst/>
                                </a:prstGeom>
                            </pic:spPr>
                        </pic:pic>
                    </a:graphicData>
                </a:graphic>
            </wp:inline>
        </w:drawing>
    </w:r>
</w:p>
$capXml
"@
}

function New-WPageBreak {
    return "<w:p><w:r><w:br w:type=`"page`"/></w:r></w:p>"
}

function New-WHr {
    return "<w:p><w:pPr><w:pBdr><w:bottom w:val=`"single`" w:sz=`"12`" w:space=`"4`" w:color=`"CBD5E1`"/></w:pBdr><w:spacing w:before=`"80`" w:after=`"160`"/></w:pPr></w:p>"
}

function New-WTable {
    param(
        [string[]]$Headers,
        [array]$Rows,
        [int[]]$ColWidths,
        [string]$HeaderFill = "1E3A8A"
    )
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append(@"
<w:tbl>
    <w:tblPr>
        <w:tblW w:w="5000" w:type="pct"/>
        <w:tblBorders>
            <w:top w:val="single" w:sz="6" w:space="0" w:color="94A3B8"/>
            <w:left w:val="single" w:sz="6" w:space="0" w:color="94A3B8"/>
            <w:bottom w:val="single" w:sz="6" w:space="0" w:color="94A3B8"/>
            <w:right w:val="single" w:sz="6" w:space="0" w:color="94A3B8"/>
            <w:insideH w:val="single" w:sz="4" w:space="0" w:color="CBD5E1"/>
            <w:insideV w:val="single" w:sz="4" w:space="0" w:color="CBD5E1"/>
        </w:tblBorders>
        <w:tblCellMar>
            <w:top w:w="90" w:type="dxa"/>
            <w:left w:w="120" w:type="dxa"/>
            <w:bottom w:w="90" w:type="dxa"/>
            <w:right w:w="120" w:type="dxa"/>
        </w:tblCellMar>
    </w:tblPr>
"@)

    [void]$sb.Append("<w:tr><w:trPr><w:tblHeader/></w:trPr>")
    for ($i = 0; $i -lt $Headers.Count; $i++) {
        $wPct = if ($ColWidths -and $i -lt $ColWidths.Count) { $ColWidths[$i] } else { [int](5000 / $Headers.Count) }
        $cellP = New-WP -Text $Headers[$i] -Bold $true -Size 23 -Align "center" -Color "FFFFFF" -SpaceBefore 40 -SpaceAfter 40
        [void]$sb.Append("<w:tc><w:tcPr><w:tcW w:w=`"$wPct`" w:type=`"pct`"/><w:shd w:val=`"clear`" w:color=`"auto`" w:fill=`"$HeaderFill`"/><w:vAlign w:val=`"center`"/></w:tcPr>$cellP</w:tc>")
    }
    [void]$sb.Append("</w:tr>")

    for ($rIdx = 0; $rIdx -lt $Rows.Count; $rIdx++) {
        $row = $Rows[$rIdx]
        $fill = if ($rIdx % 2 -eq 1) { "F8FAFC" } else { "FFFFFF" }
        [void]$sb.Append("<w:tr>")
        for ($cIdx = 0; $cIdx -lt $row.Count; $cIdx++) {
            $wPct = if ($ColWidths -and $cIdx -lt $ColWidths.Count) { $ColWidths[$cIdx] } else { [int](5000 / $Headers.Count) }
            $valStr = [string]$row[$cIdx]
            $isBold = ($cIdx -eq 0)
            $align = if ($cIdx -eq 0 -and $valStr.Length -le 12) { "center" } else { "left" }
            $cellP = New-WP -Text $valStr -Bold $isBold -Size 23 -Align $align -Color "0F172A" -SpaceBefore 35 -SpaceAfter 35
            [void]$sb.Append("<w:tc><w:tcPr><w:tcW w:w=`"$wPct`" w:type=`"pct`"/><w:shd w:val=`"clear`" w:color=`"auto`" w:fill=`"$fill`"/><w:vAlign w:val=`"center`"/></w:tcPr>$cellP</w:tc>")
        }
        [void]$sb.Append("</w:tr>")
    }
    [void]$sb.Append("</w:tbl><w:p><w:pPr><w:spacing w:before=`"40`" w:after=`"80`"/></w:pPr></w:p>")
    return $sb.ToString()
}

$b = New-Object System.Text.StringBuilder

# ==============================================================================
# TRANG BÌA ĐỒ ÁN
# ==============================================================================
[void]$b.Append((New-WP -Text "UBND THÀNH PHỐ HỒ CHÍ MINH" -Bold $true -Size 28 -Align "center" -SpaceBefore 120 -SpaceAfter 40))
[void]$b.Append((New-WP -Text "TRƯỜNG ĐẠI HỌC SÀI GÒN (SGU)" -Bold $true -Size 30 -Align "center" -Color "1E3A8A" -SpaceBefore 0 -SpaceAfter 40))
[void]$b.Append((New-WP -Text "KHOA CÔNG NGHỆ THÔNG TIN" -Bold $true -Size 28 -Align "center" -SpaceBefore 0 -SpaceAfter 200))
[void]$b.Append((New-WHr))

[void]$b.Append((New-WP -Text "BÁO CÁO ĐỒ ÁN MÔN HỌC" -Bold $true -Size 40 -Align "center" -Color "1E3A8A" -SpaceBefore 360 -SpaceAfter 80))
[void]$b.Append((New-WP -Text "HỌC PHẦN: HỆ THỐNG THÔNG TIN DOANH NGHIỆP" -Bold $true -Size 30 -Align "center" -Color "0F172A" -SpaceBefore 40 -SpaceAfter 40))
[void]$b.Append((New-WP -Text "(Mã học phần: 841065 — Học kỳ 1, Năm học 2026 – 2027)" -Italic $true -Size 26 -Align "center" -Color "334155" -SpaceBefore 0 -SpaceAfter 300))

[void]$b.Append((New-WP -Text "ĐỀ TÀI:" -Bold $true -Size 28 -Align "center" -Color "1E3A8A" -SpaceBefore 120 -SpaceAfter 60))
[void]$b.Append((New-WP -Text "XÂY DỰNG HỆ THỐNG THÔNG TIN QUẢN TRỊ DOANH NGHIỆP THƯƠNG MẠI SGU TECH`nVÀ MÔ PHỎNG PHÂN HỆ QUẢN LÝ QUAN HỆ KHÁCH HÀNG (CRM - MỤC III.4)" -Bold $true -Size 30 -Align "center" -Color "0F172A" -SpaceBefore 40 -SpaceAfter 360 -Shading "EFF6FF"))

[void]$b.Append((New-WTable -Headers @("Thông tin Đồ án", "Chi tiết thực hiện") -ColWidths @(1600, 3400) -Rows @(
    ,@("Đơn vị đào tạo", "Khoa Công nghệ Thông tin – Trường Đại học Sài Gòn (SGU)")
    ,@("Tên học phần", "Hệ thống thông tin doanh nghiệp (Mã HP: 841065)")
    ,@("Phân hệ lựa chọn", "Phần I (Báo cáo 40đ) + Phần II (CSDL & Admin Server 30đ) + Phần III.4 (Hệ thống CRM: 4.1 Quản lý 20đ & 4.3 Khách hàng 10đ)")
    ,@("Công nghệ thực hiện", "Backend ASP.NET Core 8.0 Web API, Entity Framework Core, SQL Server / SQLite, Frontend HTML5/CSS3/JS (Chart.js)")
    ,@("Thời gian bảo vệ", "Tuần 10 – Tuần 11 (Từ ngày 09/11/2026 đến ngày 22/11/2026)")
)))

[void]$b.Append((New-WP -Text "TP. HỒ CHÍ MINH — NĂM 2026" -Bold $true -Size 26 -Align "center" -SpaceBefore 360 -SpaceAfter 0))
[void]$b.Append((New-WPageBreak))

# ==============================================================================
# PHẦN MỞ ĐẦU: KẾ HOẠCH 15 TUẦN & TỰ ĐÁNH GIÁ
# ==============================================================================
[void]$b.Append((New-WP -Text "PHẦN MỞ ĐẦU: KẾ HOẠCH LÀM VIỆC 15 TUẦN & TỰ ĐÁNH GIÁ CỦA NHÓM" -Bold $true -Size 32 -Align "center" -Color "1E3A8A" -SpaceBefore 120 -SpaceAfter 160))

[void]$b.Append((New-WP -Text "1. Bảng Phân công Công việc và Tự đánh giá Mức độ Đóng góp Thành viên" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 120 -SpaceAfter 100))
[void]$b.Append((New-WTable -Headers @("STT", "MSSV", "Họ và Tên Sinh viên", "Nhiệm vụ được phân công thực hiện", "Tỷ lệ hoàn thành", "Điểm tự đánh giá") -ColWidths @(350, 750, 1100, 1700, 550, 550) -Rows @(
    ,@("1", "3121410xxx", "[Họ tên Sinh viên 1 - Nhóm trưởng]", "Khảo sát HTTT doanh nghiệp (15 câu hỏi), viết bài toán mô tả nghiệp vụ, quản lý tiến độ chung và tích hợp hệ thống.", "100%", "10 / 10")
    ,@("2", "3121410xxx", "[Họ tên Sinh viên 2]", "Phân tích hệ thống, thiết kế Sơ đồ phân rã chức năng (BFD), Sơ đồ Ngữ cảnh (Context) và Sơ đồ DFD mức đỉnh (Level 0).", "100%", "10 / 10")
    ,@("3", "3121410xxx", "[Họ tên Sinh viên 3]", "Thiết kế CSDL quan hệ 9 bảng, chuẩn hóa 3NF, viết kịch bản Backup/Restore SQL Server và lập trình Backend ASP.NET Core API.", "100%", "10 / 10")
    ,@("4", "3121410xxx", "[Họ tên Sinh viên 4]", "Lập trình Giao diện Cổng Admin Server (admin.html) và Phân hệ Quản lý CRM (manager_crm.html), tích hợp biểu đồ Chart.js.", "100%", "10 / 10")
    ,@("5", "3121410xxx", "[Họ tên Sinh viên 5]", "Lập trình Giao diện Cổng Khách hàng (user.html, customer_login.html), kiểm thử toàn diện và biên soạn báo cáo Word.", "100%", "10 / 10")
)))

[void]$b.Append((New-WP -Text "2. Bảng Kế hoạch Làm việc Chi tiết của Nhóm trong 15 Tuần Học kỳ 1 (2026 – 2027)" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 160 -SpaceAfter 100))
[void]$b.Append((New-WTable -Headers @("Tuần học", "Nội dung công việc triển khai", "Sản phẩm bàn giao (Deliverables)", "Trạng thái") -ColWidths @(650, 2150, 1400, 800) -Rows @(
    ,@("Tuần 1 – 2", "Nhận đề tài đồ án HP 841065, họp nhóm phân công nhiệm vụ, lựa chọn doanh nghiệp SGU Tech và phân hệ CRM (Mục III.4).", "Biên bản thành lập nhóm & Đề cương đề tài", "Hoàn thành 100%")
    ,@("Tuần 3 – 4", "Khảo sát thực tế mô hình tổ chức, nhân sự và hoạt động kinh doanh của SGU Tech; xây dựng phiếu khảo sát 15 câu hỏi HTTT.", "Bảng kết quả khảo sát 15 câu hỏi & Kết luận", "Hoàn thành 100%")
    ,@("Tuần 5 – 6", "Đặc tả bài toán mô tả chi tiết các luồng nghiệp vụ Admin, Quản lý CRM và Khách hàng; vẽ sơ đồ phân rã chức năng (BFD).", "Đặc tả bài toán & Sơ đồ BFD hoàn chỉnh", "Hoàn thành 100%")
    ,@("Tuần 7 – 8", "Thiết kế Sơ đồ Ngữ cảnh (Context Diagram) và Sơ đồ Luồng dữ liệu mức đỉnh (DFD Level 0) với 5 tiến trình và 5 kho dữ liệu.", "Sơ đồ Context & DFD mức 0 chuẩn xác", "Hoàn thành 100%")
    ,@("Tuần 9 – 10", "Thiết kế lược đồ CSDL 9 bảng (Roles, Accounts, Categories, Suppliers, Products, CustomerProfiles, Feedbacks, Surveys, SurveyResponses) & viết script SQL.", "File HTTTDN_DB.sql & Kịch bản Backup/Restore", "Hoàn thành 100%")
    ,@("Tuần 11 – 12", "Xây dựng Backend ASP.NET Core 8.0 Web API (7 Controllers) và lập trình Giao diện Cổng Admin Server + Cổng Quản lý CRM.", "Source code Backend API & Admin/CRM UI", "Hoàn thành 100%")
    ,@("Tuần 13 – 14", "Lập trình Cổng Trải nghiệm Khách hàng, nạp dữ liệu mẫu thực tế (12 sản phẩm, 5 NCC, 8 tài khoản, 10 đánh giá, 4 khảo sát) và kiểm thử.", "Hệ thống Web chạy ổn định, đồng bộ tức thì", "Hoàn thành 100%")
    ,@("Tuần 15", "Rà soát toàn bộ tiêu chí chấm điểm, hoàn thiện quyển Báo cáo Word (.docx), file readme.txt và chuẩn bị bảo vệ trước Hội đồng.", "Hồ sơ đồ án hoàn chỉnh (Code + DB + Word)", "Hoàn thành 100%")
)))

[void]$b.Append((New-WP -Text "3. Đối chiếu Ma trận Tiêu chí Đánh giá Đồ án theo Quy định của Khoa CNTT – SGU (Thang điểm 100)" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 160 -SpaceAfter 100))
[void]$b.Append((New-WTable -Headers @("Mục đánh giá", "Nội dung chi tiết theo Phiếu chấm điểm của Khoa CNTT", "Điểm tối đa", "Kết quả đáp ứng trong Đồ án") -ColWidths @(650, 2250, 600, 1500) -Rows @(
    ,@("I.1 (10đ)", "Giới thiệu doanh nghiệp, mô hình nhân sự (5đ) + Khảo sát HTTT tối thiểu 15 câu hỏi kèm tổng kết, kết luận (5đ).", "10 điểm", "Đầy đủ tại Chương I (Mục 1 & Mục 2 - 15 câu hỏi Q01..Q15).")
    ,@("I.2 (10đ)", "Bài toán mô tả chi tiết (2đ) + Sơ đồ BFD (2đ) + Sơ đồ Ngữ cảnh (2đ) + Sơ đồ DFD mức đỉnh Level 0 (4đ).", "10 điểm", "Đầy đủ tại Chương II kèm 3 sơ đồ đồ họa PNG trực quan chuẩn xác.")
    ,@("I.3 (10đ)", "Thiết kế CSDL & mô tả các bảng/thuộc tính (5đ) + Thiết kế giao diện & giải thích chi tiết chức năng phần mềm (5đ).", "10 điểm", "Đầy đủ tại Chương III: Lược đồ ERD + 9 bảng CSDL + 7 hình ảnh giao diện thực tế của đồ án.")
    ,@("I.4 (5đ)", "Phương án cài đặt, bảo trì, chuyển đổi hệ thống và Tài liệu hướng dẫn sử dụng chi tiết có hình ảnh minh họa thực tế.", "5 điểm", "Đầy đủ tại Chương IV: Quy trình chuyển đổi + Hướng dẫn chi tiết từng vai trò kèm ảnh chụp thực tế đồ án.")
    ,@("I.5 (5đ)", "Tổng kết kết quả đạt được, ưu/nhược điểm và hướng phát triển tương lai.", "5 điểm", "Đầy đủ tại Chương V.")
    ,@("II.1 (10đ)", "Cơ sở dữ liệu đầy đủ các bảng (5đ) + Phương án Sao lưu và Phục hồi (Backup & Restore) trong báo cáo (5đ).", "10 điểm", "9 bảng CSDL + Script T-SQL Full/Diff Backup & Restore.")
    ,@("II.2 (20đ)", "Giao diện Admin server tách biệt với giao diện quản lý nhân sự, quản lý kho, quản lý bán hàng; Admin thêm, xóa, phân quyền cho account (đã bỏ chức năng lọc SP/NCC theo yêu cầu).", "20 điểm", "Cổng Admin Server (admin.html) đáp ứng 100% chức năng.")
    ,@("III.4.1 (20đ)", "Người quản lý: (1) Thêm một khách hàng mới, (2) Xóa khách hàng, (3) Khóa tài khoản khách hàng, (4) Tiếp nhận phản hồi của khách hàng, (5) Báo cáo về khách hàng, tỷ lệ độ tuổi, sở thích, (6) Tạo bảng khảo sát và gửi đến tài khoản khách hàng, (7) Thống kê kết quả khảo sát.", "20 điểm", "Cổng Người quản lý (manager_crm.html) hoàn thành đủ 7/7 mục.")
    ,@("III.4.3 (10đ)", "Khách hàng: (1) Đăng ký tài khoản khách hàng, (2) Đăng nhập, (3) Chỉnh sửa thông tin, (4) Gửi phản hồi về sản phẩm, (5) Nhận được khảo sát và thực hiện.", "10 điểm", "Cổng Khách hàng (customer_login.html & user.html) đủ 5/5 mục.")
    ,@("TỔNG CỘNG", "Tổng điểm toàn bộ Đồ án Học phần Hệ thống Thông tin Doanh nghiệp (841065)", "100 điểm", "Đáp ứng 100% yêu cầu Lý thuyết, CSDL và Phần mềm.")
)))
[void]$b.Append((New-WPageBreak))

# ==============================================================================
# CHƯƠNG I: GIỚI THIỆU DN & KHẢO SÁT HTTT
# ==============================================================================
[void]$b.Append((New-WP -Text "CHƯƠNG I: GIỚI THIỆU DOANH NGHIỆP VÀ KHẢO SÁT HỆ THỐNG THÔNG TIN (10 ĐIỂM)" -Bold $true -Size 32 -Align "left" -Color "1E3A8A" -SpaceBefore 120 -SpaceAfter 140))
[void]$b.Append((New-WP -Text "1.1. Giới thiệu Tổng quan về Doanh nghiệp, Hoạt động Kinh doanh và Mô hình Nhân sự (5 điểm)" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 100 -SpaceAfter 80))
[void]$b.Append((New-WP -Text "Công ty Cổ phần Công nghệ Thương mại SGU Tech (SGU Tech Commercial Joint Stock Company) là doanh nghiệp hoạt động chuyên sâu trong lĩnh vực nhập khẩu, phân phối bán buôn và bán lẻ các sản phẩm phần cứng công nghệ thông tin, máy tính xách tay hiệu năng cao (Laptop AI, Laptop Gaming, Ultrabook doanh nhân), màn hình đồ họa chuyên nghiệp, linh kiện lưu trữ tốc độ cao và phụ kiện công nghệ chính hãng tại thị trường TP. Hồ Chí Minh và khu vực phía Nam." -Size 26 -IndentFirst 420))

[void]$b.Append((New-WBullet "Tên pháp lý doanh nghiệp:" "CÔNG TY CỔ PHẦN CÔNG NGHỆ THƯƠNG MẠI SGU TECH (SGU TECH JSC)."))
[void]$b.Append((New-WBullet "Mã số doanh nghiệp:" "0318941065 — Trụ sở chính: 273 An Dương Vương, Phường 3, Quận 5, TP. Hồ Chí Minh."))
[void]$b.Append((New-WBullet "Mô hình kinh doanh (Business Model):" "Kết hợp mô hình B2C (Bán lẻ trực tiếp cho khách hàng cá nhân, sinh viên, kỹ sư lập trình, game thủ) và B2B (Cung cấp thiết bị công nghệ định kỳ cho các doanh nghiệp vừa và nhỏ). Doanh nghiệp hợp tác trực tiếp với 5 nhà phân phối chiến lược gồm ASUS Việt Nam, Dell Indochina, Samsung Vina, Logitech Đông Nam Á và LG Electronics Việt Nam."))
[void]$b.Append((New-WBullet "Cơ cấu tổ chức & Mô hình nhân sự:" "Doanh nghiệp được tổ chức theo mô hình chức năng chuyên môn hóa gồm 5 phòng ban cốt lõi dưới sự điều hành trực tiếp của Ban Giám đốc:"))

[void]$b.Append((New-WTable -Headers @("Phòng ban / Bộ phận", "Chức năng & Nhiệm vụ chính trong Doanh nghiệp", "Vai trò trên HTTT") -ColWidths @(1200, 2600, 1200) -Rows @(
    ,@("1. Ban Giám đốc (Board of Directors)", "Hoạch định chiến lược kinh doanh, phê duyệt ngân sách nhập hàng dựa trên báo cáo phân tích thị trường và nhân khẩu học khách hàng.", "Xem báo cáo tổng hợp Admin & CRM")
    ,@("2. Phòng Quản trị Hệ thống (IT Admin Server)", "Quản lý máy chủ cơ sở dữ liệu, đảm bảo an toàn thông tin, thực hiện sao lưu/phục hồi định kỳ, cấp phát tài khoản và phân quyền truy cập hệ thống cho các bộ phận.", "Role: Admin (Cổng Admin Server)")
    ,@("3. Phòng Quản lý Quan hệ Khách hàng (CRM & Marketing)", "Quản lý hồ sơ khách hàng, tiếp nhận và giải đáp phản hồi đánh giá sản phẩm, thống kê cơ cấu độ tuổi/sở thích, phát hành khảo sát thăm dò sản phẩm mới trước khi nhập hàng.", "Role: Manager (Cổng Quản lý CRM)")
    ,@("4. Phòng Kinh doanh & Kho vận (Sales & Warehouse)", "Cập nhật thông tin hàng hóa, kiểm soát số lượng tồn kho, trạng thái sản phẩm (Đang bán / Hết hàng) và làm việc với các nhà cung cấp.", "Cập nhật danh mục SP & Nhà cung cấp")
    ,@("5. Khách hàng Thành viên (Customers)", "Người tiêu dùng đăng ký tài khoản trên cổng trực tuyến để tra cứu sản phẩm, gửi đánh giá chất lượng (1-5 sao), nhận phản hồi từ quản lý và tham gia khảo sát sản phẩm mới.", "Role: Customer (Cổng Khách hàng)")
)))

[void]$b.Append((New-WP -Text "1.2. Khảo sát Hệ thống Thông tin Hiện tại của Doanh nghiệp (5 điểm)" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 160 -SpaceAfter 80))
[void]$b.Append((New-WP -Text "Để nắm bắt chính xác hiện trạng vận hành và các điểm nghẽn thông tin tại SGU Tech JSC, nhóm thực hiện đồ án đã tiến hành khảo sát trực tiếp các phòng ban và khách hàng thông qua bộ Phiếu khảo sát gồm 15 câu hỏi chuyên sâu gắn liền với nghiệp vụ Hệ thống thông tin doanh nghiệp:" -Size 26 -IndentFirst 420))

[void]$b.Append((New-WTable -Headers @("Mã câu", "Nội dung Câu hỏi Khảo sát Hệ thống Thông tin", "Đối tượng trả lời", "Kết quả thu thập thực tế tại Doanh nghiệp") -ColWidths @(400, 1750, 900, 1950) -Rows @(
    ,@("Q01", "Hiện tại doanh nghiệp đang lưu trữ danh mục hàng hóa, nhà cung cấp và hồ sơ khách hàng bằng công cụ gì?", "Ban Giám đốc / Quản lý", "Lưu trữ phân tán trên nhiều file Excel rời rạc và Google Sheets, dễ xảy ra trùng lặp mã sản phẩm và sai lệch số lượng tồn kho.")
    ,@("Q02", "Khách hàng gửi đánh giá, khiếu nại hoặc góp ý về chất lượng sản phẩm qua những kênh nào?", "Bộ phận CSKH", "Qua bình luận Facebook, Zalo hoặc gọi điện thoại; thông tin bị trôi, không gắn kết trực tiếp với từng mã sản phẩm trong kho.")
    ,@("Q03", "Thời gian trung bình để bộ phận Quản lý tiếp nhận và phản hồi lại một ý kiến đánh giá của khách hàng là bao lâu?", "Khách hàng / Quản lý CRM", "Mất từ 24h – 48h do phải kiểm tra thủ công, thậm chí nhiều bình luận của khách hàng bị bỏ sót không được giải đáp.")
    ,@("Q04", "Doanh nghiệp có nắm được tỷ lệ phân bố độ tuổi (Dưới 20, 20-30, Trên 30) của tập khách hàng hiện tại không?", "Trưởng phòng CRM", "Chưa có thống kê tự động; nhân viên phải lọc thủ công từng dòng dữ liệu nên số liệu luôn chậm trễ và thiếu chính xác.")
    ,@("Q05", "Làm thế nào doanh nghiệp phân loại được sở thích tiêu dùng (Gaming, Văn phòng, Đồ họa, Lập trình) của khách hàng?", "Bộ phận Marketing", "Chỉ phỏng đoán cảm tính của nhân viên bán hàng, chưa có trường dữ liệu sở thích chuẩn hóa trong hồ sơ khách hàng.")
    ,@("Q06", "Trước khi quyết định nhập khẩu một dòng sản phẩm công nghệ mới giá trị cao, doanh nghiệp thăm dò nhu cầu thị trường bằng cách nào?", "Ban Giám đốc / Phòng Thu mua", "Tạo biểu mẫu khảo sát rời bên ngoài, không gửi trực tiếp vào tài khoản khách hàng thành viên nên tỷ lệ phản hồi rất thấp.")
    ,@("Q07", "Khi thực hiện khảo sát sản phẩm mới, doanh nghiệp cần thu thập những chỉ số định lượng nào từ khách hàng?", "Trưởng phòng CRM", "Cần thu thập: Điểm quan tâm (1–5 sao), Ý định mua sắm (Rất muốn mua / Đang cân nhắc / Không mua) và Ý kiến về mức giá dự kiến.")
    ,@("Q08", "Hệ thống khảo sát có cần cơ chế giới hạn thời gian hiệu lực (theo số ngày hoặc ngày hết hạn cố định) không?", "Trưởng phòng CRM", "Rất cần thiết để khóa khảo sát tự động khi kết thúc đợt thăm dò và chốt số liệu báo cáo cho Ban Giám đốc.")
    ,@("Q09", "Giao diện làm việc của Quản trị viên hệ thống (Admin Server) và Quản lý nghiệp vụ (CRM Manager) cần được tổ chức như thế nào?", "Quản trị viên IT", "Bắt buộc phải tách biệt hoàn toàn giao diện và quyền hạn: Admin chuyên quản trị hạ tầng/tài khoản, Manager chuyên xử lý nghiệp vụ CRM.")
    ,@("Q10", "Quản trị viên cần những công cụ gì để tra cứu và kiểm soát nhanh hàng trăm mặt hàng công nghệ?", "Quản trị viên / Thủ kho", "Cần chức năng tìm kiếm theo mã/tên, lọc nâng cao theo Danh mục, Nhà cung cấp, Trạng thái, Khoảng giá (Min-Max) và sắp xếp tự động.")
    ,@("Q11", "Khi phát hiện tài khoản khách hàng hoặc nhân viên có dấu hiệu vi phạm hoặc nghỉ việc, hệ thống cần xử lý ra sao?", "Quản trị viên / Quản lý CRM", "Cần chức năng Khóa/Mở khóa tài khoản tức thì (IsActive) để chặn đăng nhập mà không làm mất lịch sử dữ liệu, hoặc Xóa an toàn.")
    ,@("Q12", "Mật khẩu của người dùng nội bộ và khách hàng cần được bảo vệ theo tiêu chuẩn nào trong cơ sở dữ liệu?", "Quản trị viên IT", "Cần băm mật khẩu một chiều bằng thuật toán BCrypt (PasswordHash) để đảm bảo an toàn thông tin doanh nghiệp.")
    ,@("Q13", "Khách hàng có nhu cầu tự đăng ký tài khoản, cập nhật hồ sơ cá nhân và theo dõi lịch sử phản hồi của chính mình không?", "Khách hàng thành viên", "92% khách hàng được hỏi mong muốn có Cổng khách hàng riêng biệt, giao diện thân thiện, không lẫn lộn với các menu quản trị nội bộ.")
    ,@("Q14", "Doanh nghiệp yêu cầu quy trình Sao lưu và Phục hồi cơ sở dữ liệu (Backup & Restore) như thế nào để phòng chống rủi ro?", "Quản trị viên IT", "Yêu cầu kết hợp Sao lưu toàn phần (Full Backup) hàng tuần và Sao lưu vi sai (Differential Backup) hàng ngày trên SQL Server.")
    ,@("Q15", "Định hướng mở rộng hệ thống thông tin của doanh nghiệp trong 1 – 2 năm tới là gì?", "Ban Giám đốc", "Xây dựng nền tảng CSDL chuẩn hóa để dễ dàng tích hợp thêm phân hệ Quản lý Kho (MRP), Quản lý Bán hàng và Nhân sự (HRM).")
)))

[void]$b.Append((New-WP -Text "1.3. Tổng kết Kết quả Khảo sát và Kết luận Xây dựng Hệ thống Thông tin" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 140 -SpaceAfter 80))
[void]$b.Append((New-WBullet "Tổng kết bất cập cốt lõi:" "Quy trình quản lý hàng hóa, nhà cung cấp và chăm sóc khách hàng thủ công tại SGU Tech đang gây thất thoát thông tin phản hồi, thiếu dữ liệu nhân khẩu học (độ tuổi, sở thích) dẫn đến rủi ro nhập hàng tồn đọng vốn, đồng thời chưa có sự phân quyền tách biệt rõ ràng giữa quản trị hệ thống và quản lý nghiệp vụ."))
[void]$b.Append((New-WBullet "Kết luận đề xuất giải pháp:" "Xây dựng Hệ thống Thông tin Doanh nghiệp SGU Tech trên nền tảng Web API tập trung với 3 phân hệ tách biệt rõ ràng: (1) Phân hệ Máy chủ Admin quản lý hàng hóa, nhà cung cấp, tài khoản và phân quyền; (2) Phân hệ Quản lý CRM quản lý vòng đời khách hàng, giải đáp phản hồi, báo cáo độ tuổi/sở thích và khảo sát thị trường; (3) Cổng Trải nghiệm Khách hàng trực quan, minh bạch."))
[void]$b.Append((New-WPageBreak))

# ==============================================================================
# CHƯƠNG II: PHÂN TÍCH HỆ THỐNG THÔNG TIN
# ==============================================================================
[void]$b.Append((New-WP -Text "CHƯƠNG II: PHÂN TÍCH HỆ THỐNG THÔNG TIN DOANH NGHIỆP (10 ĐIỂM)" -Bold $true -Size 32 -Align "left" -Color "1E3A8A" -SpaceBefore 120 -SpaceAfter 140))

[void]$b.Append((New-WP -Text "2.1. Bài toán Mô tả Chi tiết Hoạt động của Hệ thống Thông tin (2 điểm)" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 100 -SpaceAfter 80))
[void]$b.Append((New-WP -Text "Quy trình vận hành của Hệ thống Thông tin Doanh nghiệp SGU Tech được mô tả chi tiết qua 3 luồng tác nghiệp liên thông nhưng phân quyền độc lập như sau:" -Size 26 -IndentFirst 420))
[void]$b.Append((New-WBullet "1. Nghiệp vụ Quản trị Hệ thống (Admin Server):" "Quản trị viên đăng nhập vào cổng nội bộ (login.html) với quyền Admin. Giao diện của Admin Server (admin.html) được thiết kế tách biệt hoàn toàn với giao diện của quản lý nhân sự (HR), quản lý kho (Warehouse), quản lý bán hàng (Sales) và người quản lý khách hàng (Manager). Theo đúng yêu cầu điều chỉnh đồ án, chức năng xem, tìm kiếm, tìm kiếm nâng cao, sắp xếp và lọc sản phẩm/nhà cung cấp được lược bỏ khỏi giao diện Admin Server; Admin Server tập trung chuyên trách: thêm mới account, xóa account, khóa/mở khóa trạng thái và phân quyền trực tiếp (Role Assignment: Admin, Manager, Customer, HR, Warehouse, Sales). Ngoài ra, Admin phụ trách thiết lập kịch bản sao lưu và phục hồi CSDL định kỳ."))
[void]$b.Append((New-WBullet "2. Nghiệp vụ Người Quản lý (CRM Manager):" "Người quản lý đăng nhập vào hệ thống với quyền Manager và được điều hướng tới giao diện chuyên biệt (manager_crm.html). Tại đây, Người quản lý thực hiện đầy đủ 7 chức năng theo đúng yêu cầu: (1) Thêm một khách hàng mới kèm hồ sơ nhân khẩu học; (2) Xóa khách hàng an toàn toàn vẹn dữ liệu; (3) Khóa/mở khóa tài khoản khách hàng khi có vi phạm; (4) Tiếp nhận phản hồi đánh giá sản phẩm của khách hàng và gửi câu trả lời giải đáp chính thức; (5) Báo cáo về khách hàng với biểu đồ tỷ lệ độ tuổi (<20, 20-30, >30 tuổi) và tỷ lệ sở thích tiêu dùng (Gaming, Văn phòng, Đồ họa, Lập trình); (6) Tạo bảng khảo sát sản phẩm mới (tên SP, giá dự kiến, hạn sử dụng) và gửi đến tài khoản khách hàng; (7) Thống kê kết quả khảo sát trên một tab độc lập."))
[void]$b.Append((New-WBullet "3. Nghiệp vụ Khách hàng (Customer Portal):" "Khách hàng truy cập cổng dành riêng cho khách hàng (customer_login.html và user.html) tách biệt hoàn toàn với hệ thống nội bộ. Khách hàng thực hiện đầy đủ 5 chức năng: (1) Đăng ký tài khoản khách hàng với form tối giản; (2) Đăng nhập hệ thống; (3) Chỉnh sửa thông tin cá nhân (Họ tên, SĐT, Email, Tuổi, Giới tính, Sở thích, Địa chỉ); (4) Gửi phản hồi đánh giá chất lượng sản phẩm (1–5 sao kèm nhận xét) với bộ lọc sản phẩm thông minh và theo dõi giải đáp từ Quản lý; (5) Nhận được bài khảo sát sản phẩm mới và thực hiện khảo sát chuyên sâu 5 tiêu chí."))

# 2.2 BFD DIAGRAM
[void]$b.Append((New-WP -Text "2.2. Sơ đồ Phân rã Chức năng (BFD – Business Function Diagram) (2 điểm)" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 160 -SpaceAfter 80))
[void]$b.Append((New-WP -Text "Hệ thống Thông tin Doanh nghiệp SGU Tech được phân rã chức năng theo mô hình phân cấp dạng cây (Tree Structure). Cấu trúc chức năng gồm 3 nhánh độc lập tương ứng với 3 phân hệ người dùng chính: Admin Server, Người quản lý CRM và Cổng Khách hàng:" -Size 26 -IndentFirst 420))

[void]$b.Append((New-WImage -RelId "rIdImgBFD" -WidthEmu 5600000 -HeightEmu 3440000 -Caption "Hình 2.1: Sơ đồ Phân rã Chức năng (Business Function Diagram - BFD) Hệ thống SGU Tech" -DocPrId 1))

[void]$b.Append((New-WP -Text "Giải thích phân cấp chức năng trong Sơ đồ BFD:" -Bold $true -Size 26 -Color "0F172A" -SpaceBefore 80 -SpaceAfter 40))
[void]$b.Append((New-WBullet "1.0 Phân hệ Admin Server:" "Tập trung vào 4 nhóm chức năng kỹ trị: Thêm mới tài khoản (1.1), Xóa & Khóa/Mở tài khoản (1.2), Phân quyền trực tiếp Role (1.3), Tách biệt hoàn toàn cổng quản lý nhân sự, kho, bán hàng và lược bỏ xem/lọc SP/NCC theo yêu cầu đề bài; Quản lý kịch bản sao lưu & phục hồi CSDL (1.4). Giao diện Admin Server hoàn toàn độc lập và không chứa chức năng nghiệp vụ của các phòng ban khác."))
[void]$b.Append((New-WBullet "2.0 Phân hệ Người Quản lý (CRM):" "Bao gồm trọn vẹn 7 chức năng nghiệp vụ quản trị khách hàng: Thêm khách hàng mới (2.1), Xóa khách hàng (2.2), Khóa tài khoản (2.3), Tiếp nhận & giải đáp phản hồi (2.4), Báo cáo nhân khẩu học độ tuổi & sở thích (2.5), Tạo bảng khảo sát gửi tới tài khoản khách hàng (2.6) và Thống kê kết quả khảo sát (2.7)."))
[void]$b.Append((New-WBullet "3.0 Phân hệ Khách hàng (Portal):" "Gồm 5 chức năng tương tác khách hàng: Đăng ký tài khoản (3.1), Đăng nhập (3.2), Chỉnh sửa hồ sơ cá nhân (3.3), Gửi phản hồi đánh giá sản phẩm kèm bộ lọc thông minh (3.4) và Nhận/thực hiện khảo sát thị trường 5 tiêu chí (3.5)."))

# 2.3 CONTEXT DIAGRAM
[void]$b.Append((New-WP -Text "2.3. Sơ đồ Ngữ cảnh (Context Diagram – DFD Mức 0 Cảnh) (2 điểm)" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 160 -SpaceAfter 80))
[void]$b.Append((New-WP -Text "Sơ đồ Ngữ cảnh xác định ranh giới tương tác thông tin giữa Tiến trình Trung tâm (0.0 Hệ thống Thông tin Doanh nghiệp SGU Tech) và 3 Tác nhân ngoài (External Entities): Quản trị viên (Admin Server), Người Quản lý (CRM Manager) và Khách hàng (Customer):" -Size 26 -IndentFirst 420))

[void]$b.Append((New-WImage -RelId "rIdImgContext" -WidthEmu 5600000 -HeightEmu 3318000 -Caption "Hình 2.2: Sơ đồ Ngữ cảnh (Context Diagram) Hệ thống Thông tin Doanh nghiệp SGU Tech" -DocPrId 2))

[void]$b.Append((New-WP -Text "Mô tả chi tiết các luồng thông tin vào / ra trên Sơ đồ Ngữ cảnh:" -Bold $true -Size 26 -Color "0F172A" -SpaceBefore 80 -SpaceAfter 40))
[void]$b.Append((New-WBullet "Tác nhân Quản trị viên (Admin Server):" "Luồng vào: Thông tin cấp mới tài khoản, lệnh phân quyền (Role Assignment), lệnh khóa/mở khóa và lệnh xóa tài khoản. Luồng ra: Trạng thái tài khoản, báo cáo phân quyền, nhật ký sao lưu và trạng thái an toàn CSDL."))
[void]$b.Append((New-WBullet "Tác nhân Người Quản lý (CRM Manager):" "Luồng vào: Hồ sơ khách hàng mới, lệnh khóa/xóa khách hàng, nội dung giải đáp phản hồi sản phẩm, bài khảo sát sản phẩm mới kèm thời hạn kết thúc. Luồng ra: Danh sách phản hồi cần giải đáp, báo cáo phân loại độ tuổi & sở thích, bảng thống kê tỷ lệ ý định mua và điểm đánh giá trung bình."))
[void]$b.Append((New-WBullet "Tác nhân Khách hàng (Customer):" "Luồng vào: Thông tin đăng ký tài khoản, hồ sơ cá nhân cập nhật, đánh giá sản phẩm (1–5 sao và nhận xét), kết quả trả lời khảo sát 5 chiều. Luồng ra: Thông báo xác thực đăng nhập, danh mục sản phẩm kinh doanh, câu trả lời giải đáp từ Quản lý và danh sách phiếu khảo sát sản phẩm mới."))

# 2.4 DFD LEVEL 0
[void]$b.Append((New-WP -Text "2.4. Sơ đồ Luồng Dữ liệu Mức Đỉnh (Level 0 DFD) (4 điểm)" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 160 -SpaceAfter 80))
[void]$b.Append((New-WP -Text "Tại mức đỉnh, Tiến trình trung tâm 0.0 được phân rã chi tiết thành 5 Tiến trình chức năng chính (1.0 đến 5.0) kết nối chặt chẽ với 5 Kho dữ liệu tập trung (D1 đến D5):" -Size 26 -IndentFirst 420))

[void]$b.Append((New-WImage -RelId "rIdImgDFD" -WidthEmu 5600000 -HeightEmu 3685000 -Caption "Hình 2.3: Sơ đồ Luồng Dữ liệu Mức Đỉnh (Level 0 DFD) với 5 Tiến trình và 5 Kho dữ liệu (D1–D5)" -DocPrId 3))

[void]$b.Append((New-WP -Text "Bảng mô tả ma trận Tiến trình và Kho Dữ liệu trên Sơ đồ Luồng Dữ liệu Mức Đỉnh:" -Bold $true -Size 26 -Color "0F172A" -SpaceBefore 80 -SpaceAfter 40))
[void]$b.Append((New-WTable -Headers @("Tiến trình / Kho DL", "Tên thành phần", "Tác nhân tương tác", "Kho dữ liệu liên quan", "Mô tả nghiệp vụ dữ liệu") -ColWidths @(850, 1350, 950, 950, 900) -Rows @(
    ,@("Tiến trình 1.0", "Quản trị Hệ thống & Phân quyền", "Admin Server", "D1: Accounts & Roles", "Thêm tài khoản, gán quyền Role, khóa và xóa an toàn khóa ngoại.")
    ,@("Tiến trình 2.0", "Quản lý Khách hàng & Báo cáo", "Người quản lý CRM", "D1, D2: CustomerProfiles", "Thêm/Xóa/Khóa KH; kết xuất biểu đồ cơ cấu độ tuổi và sở thích tiêu dùng.")
    ,@("Tiến trình 3.0", "Tiếp nhận & Giải đáp Phản hồi", "Khách hàng, Quản lý CRM", "D3: Products, D4: Feedbacks", "Ghi nhận đánh giá 1-5 sao của KH; lưu nội dung giải đáp từ Quản lý CRM.")
    ,@("Tiến trình 4.0", "Khảo sát Sản phẩm Mới & Thống kê", "Người quản lý CRM, Khách hàng", "D5: Surveys & Responses", "Phát hành khảo sát có thời hạn; thu thập câu trả lời và tính toán thống kê.")
    ,@("Tiến trình 5.0", "Cổng Tương tác Khách hàng", "Khách hàng", "D1, D2, D3, D4, D5", "Xử lý đăng ký, đăng nhập, tra cứu sản phẩm và chỉnh sửa hồ sơ cá nhân.")
    ,@("Kho D1", "Kho Tài khoản & Phân quyền", "Admin, Quản lý, KH", "Bảng Accounts, Roles", "Lưu trữ định danh người dùng và vai trò bảo mật.")
    ,@("Kho D2", "Kho Hồ sơ Khách hàng", "Quản lý CRM, KH", "Bảng CustomerProfiles", "Lưu trữ dữ liệu nhân khẩu học: tuổi, giới tính, sở thích, địa chỉ.")
    ,@("Kho D3", "Kho Hàng hóa & Đối tác", "Khách hàng, Admin", "Products, Categories, Suppliers", "Lưu trữ thông tin sản phẩm công nghệ và danh mục kinh doanh.")
    ,@("Kho D4", "Kho Đánh giá Phản hồi", "Khách hàng, Quản lý CRM", "Bảng Feedbacks", "Lưu trữ nội dung đánh giá 1-5 sao và phản hồi từ phía doanh nghiệp.")
    ,@("Kho D5", "Kho Khảo sát & Ý kiến thị trường", "Quản lý CRM, KH", "Surveys, SurveyResponses", "Lưu trữ các bài khảo sát sản phẩm mới và kết quả phản hồi của khách hàng.")
)))
[void]$b.Append((New-WPageBreak))

# ==============================================================================
# CHƯƠNG III: THIẾT KẾ CSDL & GIAO DIỆN
# ==============================================================================
[void]$b.Append((New-WP -Text "CHƯƠNG III: THIẾT KẾ CƠ SỞ DỮ LIỆU VÀ GIAO DIỆN PHẦN MỀM (10 ĐIỂM)" -Bold $true -Size 32 -Align "left" -Color "1E3A8A" -SpaceBefore 120 -SpaceAfter 140))

# 3.1 CSDL & ERD
[void]$b.Append((New-WP -Text "3.1. Thiết kế Cơ sở Dữ liệu Quan hệ Thực thể & Bảng Từ điển Thuộc tính (5 điểm)" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 100 -SpaceAfter 80))
[void]$b.Append((New-WP -Text "Dựa trên 5 kho dữ liệu D1 – D5 đã phân tích ở sơ đồ DFD mức đỉnh, Cơ sở dữ liệu của Hệ thống Thông tin Doanh nghiệp SGU Tech được chuẩn hóa đạt dạng chuẩn 3 (3NF) gồm 8 bảng quan hệ thực thể chặt chẽ:" -Size 26 -IndentFirst 420))

[void]$b.Append((New-WImage -RelId "rIdImgERD" -WidthEmu 5600000 -HeightEmu 3900000 -Caption "Hình 3.1: Lược đồ Cơ sở Dữ liệu Quan hệ Thực thể (Relational Schema / ERD) Chuẩn hóa 3NF" -DocPrId 4))

[void]$b.Append((New-WP -Text "Bảng Từ điển Dữ liệu Chi tiết các Bảng và Thuộc tính trong CSDL (Data Dictionary):" -Bold $true -Size 26 -Color "0F172A" -SpaceBefore 80 -SpaceAfter 40))

# Bảng Roles & Accounts
[void]$b.Append((New-WP -Text "a) Bảng Roles (Vai trò người dùng) & Bảng Accounts (Tài khoản người dùng - Kho D1):" -Bold $true -Size 25 -Color "1E3A8A" -SpaceBefore 60 -SpaceAfter 30))
[void]$b.Append((New-WTable -Headers @("Tên Bảng", "Tên Cột", "Kiểu Dữ liệu", "Ràng buộc (Constraints)", "Ý nghĩa & Mô tả") -ColWidths @(850, 950, 850, 1050, 1300) -Rows @(
    ,@("Roles", "RoleId", "INT", "PK, IDENTITY(1,1)", "Mã định danh duy nhất của vai trò")
    ,@("Roles", "RoleName", "NVARCHAR(50)", "NOT NULL, UNIQUE", "Tên quyền (Admin, Manager, Customer, Warehouse, Sales, HR)")
    ,@("Roles", "Description", "NVARCHAR(250)", "NULL", "Mô tả chi tiết phạm vi quyền hạn")
    ,@("Accounts", "AccountId", "INT", "PK, IDENTITY(1,1)", "Mã định danh duy nhất của tài khoản")
    ,@("Accounts", "Username", "VARCHAR(50)", "NOT NULL, UNIQUE", "Tên đăng nhập hệ thống")
    ,@("Accounts", "PasswordHash", "NVARCHAR(255)", "NOT NULL", "Mật khẩu băm một chiều an toàn bằng thuật toán BCrypt")
    ,@("Accounts", "FullName", "NVARCHAR(100)", "NOT NULL", "Họ và tên người dùng")
    ,@("Accounts", "Email / Phone", "VARCHAR(100/20)", "NULL", "Địa chỉ Email và Số điện thoại liên lạc")
    ,@("Accounts", "RoleId", "INT", "FK -> Roles(RoleId)", "Khóa ngoại liên kết vai trò phân quyền")
    ,@("Accounts", "IsActive", "BIT", "NOT NULL, DEFAULT 1", "Trạng thái tài khoản (1: Hoạt động, 0: Đã khóa)")
    ,@("Accounts", "CreatedAt", "DATETIME", "DEFAULT GETDATE()", "Thời điểm khởi tạo tài khoản")
)))

# Bảng CustomerProfiles & Feedbacks
[void]$b.Append((New-WP -Text "b) Bảng CustomerProfiles (Hồ sơ KH - Kho D2) & Bảng Feedbacks (Đánh giá phản hồi - Kho D4):" -Bold $true -Size 25 -Color "1E3A8A" -SpaceBefore 80 -SpaceAfter 30))
[void]$b.Append((New-WTable -Headers @("Tên Bảng", "Tên Cột", "Kiểu Dữ liệu", "Ràng buộc (Constraints)", "Ý nghĩa & Mô tả") -ColWidths @(850, 950, 850, 1050, 1300) -Rows @(
    ,@("CustomerProfiles", "ProfileId", "INT", "PK, IDENTITY(1,1)", "Mã định danh hồ sơ khách hàng")
    ,@("CustomerProfiles", "AccountId", "INT", "FK, UNIQUE, CASCADE -> Accounts", "Khóa ngoại liên kết 1-1 với tài khoản khách hàng")
    ,@("CustomerProfiles", "Age", "INT", "NOT NULL", "Độ tuổi khách hàng phục vụ phân khúc thị trường")
    ,@("CustomerProfiles", "Gender", "NVARCHAR(10)", "NULL", "Giới tính (Nam, Nữ, Khác)")
    ,@("CustomerProfiles", "Interest", "NVARCHAR(100)", "NOT NULL", "Sở thích tiêu dùng (Gaming, Văn phòng, Đồ họa, Lập trình)")
    ,@("CustomerProfiles", "Address", "NVARCHAR(255)", "NULL", "Địa chỉ liên hệ giao hàng")
    ,@("Feedbacks", "FeedbackId", "INT", "PK, IDENTITY(1,1)", "Mã định danh lượt đánh giá sản phẩm")
    ,@("Feedbacks", "AccountId", "INT", "FK, CASCADE -> Accounts", "Khách hàng gửi nhận xét")
    ,@("Feedbacks", "ProductId", "INT", "FK, CASCADE -> Products", "Sản phẩm được nhận xét")
    ,@("Feedbacks", "Rating", "INT", "CHECK (Rating >= 1 AND <= 5)", "Điểm đánh giá độ hài lòng (1 đến 5 sao)")
    ,@("Feedbacks", "Comment", "NVARCHAR(1000)", "NOT NULL", "Nội dung nhận xét chi tiết của khách hàng")
    ,@("Feedbacks", "AdminReply", "NVARCHAR(1000)", "NULL", "Lời giải đáp chính thức từ Người quản lý CRM")
    ,@("Feedbacks", "Status", "NVARCHAR(50)", "DEFAULT N'Chờ xử lý'", "Trạng thái (Chờ xử lý / Đã tiếp nhận & Xử lý)")
)))

# Bảng Surveys & SurveyResponses
[void]$b.Append((New-WP -Text "c) Bảng Surveys (Khảo sát sản phẩm mới) & SurveyResponses (Kết quả khảo sát - Kho D5):" -Bold $true -Size 25 -Color "1E3A8A" -SpaceBefore 80 -SpaceAfter 30))
[void]$b.Append((New-WTable -Headers @("Tên Bảng", "Tên Cột", "Kiểu Dữ liệu", "Ràng buộc (Constraints)", "Ý nghĩa & Mô tả") -ColWidths @(850, 950, 850, 1050, 1300) -Rows @(
    ,@("Surveys", "SurveyId", "INT", "PK, IDENTITY(1,1)", "Mã định danh chương trình khảo sát")
    ,@("Surveys", "Title", "NVARCHAR(200)", "NOT NULL", "Tiêu đề chiến dịch thăm dò thị trường")
    ,@("Surveys", "Description", "NVARCHAR(1000)", "NULL", "Mô tả tính năng công nghệ mới của sản phẩm")
    ,@("Surveys", "TargetProduct", "NVARCHAR(150)", "NOT NULL", "Tên thiết bị sản phẩm dự kiến nhập kho")
    ,@("Surveys", "ExpectedPrice", "DECIMAL(18,2)", "NOT NULL", "Đơn giá dự kiến niêm yết (VNĐ)")
    ,@("Surveys", "IsActive", "BIT", "NOT NULL, DEFAULT 1", "Trạng thái mở (1) hoặc khóa đóng (0)")
    ,@("Surveys", "ExpiresAt", "DATETIME", "NULL", "Thời hạn kết thúc tự động khảo sát")
    ,@("SurveyResponses", "ResponseId", "INT", "PK, IDENTITY(1,1)", "Mã định danh lượt trả lời khảo sát")
    ,@("SurveyResponses", "SurveyId", "INT", "FK, CASCADE -> Surveys", "Bài khảo sát tương ứng")
    ,@("SurveyResponses", "AccountId", "INT", "FK, CASCADE -> Accounts", "Khách hàng tham gia khảo sát")
    ,@("SurveyResponses", "Score", "INT", "CHECK (Score >= 1 AND <= 5)", "Điểm đánh giá mức độ quan tâm (1 đến 5)")
    ,@("SurveyResponses", "BuyingIntent", "NVARCHAR(50)", "NOT NULL", "Ý định mua sắm (Rất muốn mua / Đang cân nhắc / Không mua)")
    ,@("SurveyResponses", "CustomerOpinion", "NVARCHAR(1000)", "NULL", "Ý kiến đóng góp chi tiết về tính năng và mức giá")
    ,@("SurveyResponses", "SubmittedAt", "DATETIME", "DEFAULT GETDATE()", "Thời điểm nộp phiếu khảo sát")
)))

# 3.2 THIẾT KẾ GIAO DIỆN
[void]$b.Append((New-WP -Text "3.2. Thiết kế Giao diện, Hình ảnh Minh chứng và Giới thiệu Chi tiết Chức năng (5 điểm)" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 160 -SpaceAfter 80))
[void]$b.Append((New-WP -Text "Hệ thống được thiết kế theo kiến trúc chuẩn doanh nghiệp công nghệ hiện đại (Enterprise Architecture), lấy cảm hứng từ phong cách tập đoàn VNG Corporation với tông màu thương hiệu cam công nghệ (#FF5B00), xanh doanh nghiệp (#1E3A8A), bố cục thẻ card thoáng đạt, trực quan và tách biệt hoàn toàn giữa các vai trò:" -Size 26 -IndentFirst 420))

# 1. Admin Server
[void]$b.Append((New-WP -Text "1. Giao diện Phân hệ Quản trị Hệ thống - Admin Server (admin.html - Mục II.2):" -Bold $true -Size 26 -Color "1E3A8A" -SpaceBefore 100 -SpaceAfter 40))
[void]$b.Append((New-WBullet "Nguyên tắc thiết kế tách biệt:" "Giao diện Admin Server hoàn toàn tách biệt với giao diện của Quản lý Nhân sự (HR), Quản lý Kho (Warehouse), Quản lý Bán hàng (Sales) và Người Quản lý Khách hàng (Manager). Chức năng xem/tìm kiếm/lọc sản phẩm và nhà cung cấp đã được lược bỏ khỏi Admin theo đúng yêu cầu đề bài."))
[void]$b.Append((New-WBullet "Chức năng thực hiện:" "Admin quản lý danh sách toàn bộ tài khoản; bảng quản trị thông minh gộp thông tin người dùng vào cột định danh chuyên nghiệp; hỗ trợ Thêm mới account (kèm phân quyền), Phân quyền trực tiếp bằng Dropdown phân vai trò, Khóa/Mở khóa tài khoản ngay lập tức và Xóa tài khoản an toàn."))

[void]$b.Append((New-WImage -RelId "rIdImgAdmin" -WidthEmu 5600000 -HeightEmu 2800000 -Caption "Hình 3.2: Giao diện Phân hệ Quản trị Hệ thống - Admin Server (Quản lý tài khoản, phân quyền, khóa và xóa)" -DocPrId 5))

# 2. Manager CRM
[void]$b.Append((New-WP -Text "2. Giao diện Phân hệ Người Quản lý CRM (manager_crm.html - Mục III.4.1):" -Bold $true -Size 26 -Color "1E3A8A" -SpaceBefore 100 -SpaceAfter 40))
[void]$b.Append((New-WBullet "Thực hiện trọn vẹn 7 chức năng theo đúng đề tài:" ""))
[void]$b.Append((New-WBullet "(1) Thêm một khách hàng mới:" "Form thêm khách hàng nhập họ tên, username, mật khẩu, SĐT, email, độ tuổi, giới tính và sở thích tiêu dùng."))
[void]$b.Append((New-WBullet "(2) Xóa khách hàng & (3) Khóa tài khoản khách hàng:" "Nút thao tác nhanh trên từng dòng bảng khách hàng; hỗ trợ lọc theo nhóm tuổi và nhóm sở thích."))
[void]$b.Append((New-WBullet "(4) Tiếp nhận phản hồi của khách hàng:" "Theo dõi đánh giá 1-5 sao của khách hàng theo từng mã sản phẩm; nhập nội dung giải đáp chính thức từ quản lý."))
[void]$b.Append((New-WBullet "(5) Báo cáo khách hàng, tỷ lệ độ tuổi & sở thích:" "Tự động thống kê với 2 biểu đồ trực quan Chart.js (Độ tuổi: <20, 20-30, >30; Sở thích: Gaming, Văn phòng, Đồ họa, Lập trình)."))
[void]$b.Append((New-WBullet "(6) Tạo bảng khảo sát gửi đến TK khách hàng:" "Phát hành bài khảo sát kèm mô tả, giá dự kiến và thời hạn; phân phối tự động tới tài khoản khách hàng."))
[void]$b.Append((New-WBullet "(7) Thống kê kết quả khảo sát:" "Tab độc lập hiển thị biểu đồ phân bố điểm quan tâm 1-5 sao, tỷ lệ ý định mua sắm và bảng chi tiết câu trả lời."))

[void]$b.Append((New-WImage -RelId "rIdImgManager" -WidthEmu 5600000 -HeightEmu 2500000 -Caption "Hình 3.3: Giao diện Người Quản lý CRM (Quản lý khách hàng, theo dõi chỉ số và thực hiện 7 nghiệp vụ CRM)" -DocPrId 6))

# 3. Customer Home & Register
[void]$b.Append((New-WP -Text "3. Giao diện Trang chủ Cổng Khách hàng & Cổng Đăng ký / Đăng nhập (user.html & customer_login.html):" -Bold $true -Size 26 -Color "1E3A8A" -SpaceBefore 100 -SpaceAfter 40))
[void]$b.Append((New-WBullet "Trang chủ phong cách VNG Corporation:" "Hero Banner nhận diện thương hiệu công nghệ hiện đại; bộ 3 Thẻ điều hướng danh tiếng (Sản phẩm - Products, Khảo sát - People, Đánh giá - Impacts) giúp khách hàng truy cập nhanh các dịch vụ."))
[void]$b.Append((New-WBullet "Đăng ký & Đăng nhập tối giản:" "Giao diện đăng nhập và đăng ký được thiết kế riêng biệt tại customer_login.html, form tinh gọn, trực quan, hỗ trợ khách hàng tạo tài khoản chỉ trong vài giây."))

[void]$b.Append((New-WImage -RelId "rIdImgCustPortal" -WidthEmu 5600000 -HeightEmu 3500000 -Caption "Hình 3.4: Giao diện Trang chủ Cổng Khách hàng SGU Tech Store (Thiết kế phong cách VNG với 3 thẻ điều hướng thương hiệu)" -DocPrId 7))
[void]$b.Append((New-WImage -RelId "rIdImgCustReg" -WidthEmu 4000000 -HeightEmu 4200000 -Caption "Hình 3.5: Cổng Đăng nhập & Đăng ký Khách hàng tối giản, chuyên nghiệp" -DocPrId 8))

# 4. Customer Feedback & Smart Filter
[void]$b.Append((New-WP -Text "4. Giao diện Gửi Phản hồi Sản phẩm & Bộ lọc Thông minh (Mục III.4.3 - Chức năng 4):" -Bold $true -Size 26 -Color "1E3A8A" -SpaceBefore 100 -SpaceAfter 40))
[void]$b.Append((New-WBullet "Gửi đánh giá chất lượng:" "Khách hàng chọn sản phẩm, chấm điểm 1–5 sao và nhập nhận xét chi tiết."))
[void]$b.Append((New-WBullet "Bộ lọc phản hồi thông minh (Smart Filter Toolbar):" "Thay thế hoàn toàn dropdown truyền thống bằng thanh công cụ tìm kiếm trực tiếp + các nút lọc danh mục (Laptop, Màn hình, Bàn phím, Linh kiện) + nút lọc đánh giá 5★ và phản hồi đã được Quản lý giải đáp."))

[void]$b.Append((New-WImage -RelId "rIdImgCustFeed" -WidthEmu 5600000 -HeightEmu 3200000 -Caption "Hình 3.6: Giao diện Gửi phản hồi sản phẩm và Bộ lọc đánh giá thông minh" -DocPrId 9))

# 5. Customer Survey & Profile
[void]$b.Append((New-WP -Text "5. Biểu mẫu Thực hiện Khảo sát 5 Tiêu chí & Chỉnh sửa Thông tin Cá nhân (Mục III.4.3 - Chức năng 3 & 5):" -Bold $true -Size 26 -Color "1E3A8A" -SpaceBefore 100 -SpaceAfter 40))
[void]$b.Append((New-WBullet "Phiếu khảo sát thị trường 5 chiều chuyên sâu:" "Gồm 5 tiêu chí khảo sát toàn diện: (1) Thang điểm quan tâm 1-5 sao dạng Card tương tác; (2) Đánh giá mức giá (Rẻ, Hợp lý, Hơi cao, Quá đắt); (3) Chọn tính năng mong đợi dạng thẻ Chip; (4) Ý định mua & Thời điểm xuống tiền; (5) Mức giá sẵn sàng chi trả kèm góp ý chi tiết."))
[void]$b.Append((New-WBullet "Chỉnh sửa thông tin tài khoản:" "Khách hàng dễ dàng xem thẻ thành viên và cập nhật Họ tên, SĐT, Email, Tuổi, Giới tính, Sở thích và Địa chỉ."))

[void]$b.Append((New-WImage -RelId "rIdImgCustSurv" -WidthEmu 4200000 -HeightEmu 4000000 -Caption "Hình 3.7: Biểu mẫu Khảo sát sản phẩm mới với 5 tiêu chí thăm dò thị trường chuyên nghiệp" -DocPrId 10))
[void]$b.Append((New-WImage -RelId "rIdImgCustProf" -WidthEmu 5600000 -HeightEmu 2700000 -Caption "Hình 3.8: Giao diện Chỉnh sửa thông tin hồ sơ cá nhân của khách hàng" -DocPrId 11))

# 3.3 BACKUP & RESTORE
[void]$b.Append((New-WP -Text "3.3. Kịch bản Sao lưu và Phục hồi Cơ sở Dữ liệu (Backup & Restore - Mục II.1 - 5 điểm)" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 160 -SpaceAfter 80))
[void]$b.Append((New-WP -Text "Doanh nghiệp xây dựng quy chế sao lưu an toàn CSDL trên Microsoft SQL Server như sau:" -Size 26 -IndentFirst 420))
[void]$b.Append((New-WBullet "1. Sao lưu toàn phần (Full Backup):" "Thực hiện định kỳ vào 00:00 Chủ Nhật hàng tuần ra tệp HTTTDN_DB_Full.bak."))
[void]$b.Append((New-WBullet "2. Sao lưu vi sai (Differential Backup):" "Thực hiện định kỳ vào 23:00 mỗi ngày trong tuần ra tệp HTTTDN_DB_Diff.bak."))
[void]$b.Append((New-WBullet "3. Quy trình Phục hồi Cơ sở Dữ liệu (Restore Database):" "Khôi phục dữ liệu tức thì khi gặp sự cố phần cứng hoặc thảm họa máy chủ."))

$sqlText = @"
-- 1. LỆNH SAO LƯU TOÀN PHẦN (FULL BACKUP)
BACKUP DATABASE [HTTTDN_DB]
TO DISK = N'C:\Backup\HTTTDN_DB_Full.bak'
WITH FORMAT, INIT, NAME = N'HTTTDN_DB - Full Database Backup', STATS = 10;

-- 2. LỆNH SAO LƯU VI SAI HÀNG NGÀY (DIFFERENTIAL BACKUP)
BACKUP DATABASE [HTTTDN_DB]
TO DISK = N'C:\Backup\HTTTDN_DB_Diff.bak'
WITH DIFFERENTIAL, NAME = N'HTTTDN_DB - Differential Backup', STATS = 10;

-- 3. LỆNH PHỤC HỒI CƠ SỞ DỮ LIỆU KHI CÓ SỰ CỐ (RESTORE DATABASE)
USE master;
ALTER DATABASE [HTTTDN_DB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
RESTORE DATABASE [HTTTDN_DB] FROM DISK = N'C:\Backup\HTTTDN_DB_Full.bak' WITH REPLACE, RECOVERY;
ALTER DATABASE [HTTTDN_DB] SET MULTI_USER;
"@
[void]$b.Append((New-WP -Text $sqlText -Size 21 -Align "left" -Color "0F172A" -Shading "F8FAFC" -Font "Consolas"))
[void]$b.Append((New-WPageBreak))

# ==============================================================================
# CHƯƠNG IV: CÀI ĐẶT, BẢO TRÌ & HƯỚNG DẪN SỬ DỤNG
# ==============================================================================
[void]$b.Append((New-WP -Text "CHƯƠNG IV: PHƯƠNG ÁN CÀI ĐẶT, BẢO TRÌ, CHUYỂN ĐỔI HỆ THỐNG VÀ HƯỚNG DẪN SỬ DỤNG (5 ĐIỂM)" -Bold $true -Size 32 -Align "left" -Color "1E3A8A" -SpaceBefore 120 -SpaceAfter 140))

[void]$b.Append((New-WP -Text "4.1. Phương án Cài đặt, Bảo trì và Chuyển đổi Hệ thống (System Conversion Plan)" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 100 -SpaceAfter 80))
[void]$b.Append((New-WBullet "Phương án chuyển đổi hệ thống:" "Doanh nghiệp áp dụng phương pháp Chuyển đổi Song song (Parallel Conversion) kết hợp Chuyển đổi theo Giai đoạn (Phased Conversion) trong vòng 4 tuần:"))
[void]$b.Append((New-WBullet "Giai đoạn 1 (Tuần 1 – Tuần 2): Chuẩn hóa và Chuyển giao Dữ liệu:" "Import toàn bộ danh mục sản phẩm, nhà cung cấp và danh sách khách hàng từ các tệp Excel cũ vào CSDL HTTTDN_DB; thiết lập phân quyền tài khoản cho Admin và Quản lý CRM."))
[void]$b.Append((New-WBullet "Giai đoạn 2 (Tuần 3): Vận hành Song song và Đào tạo:" "Hệ thống Web mới chạy song song với quy trình ghi nhận cũ để đối chiếu độ chính xác của số lượng tồn kho, tỷ lệ độ tuổi/sở thích và luồng phản hồi đánh giá sản phẩm."))
[void]$b.Append((New-WBullet "Giai đoạn 3 (Từ Tuần 4): Chuyển đổi Chính thức (Cut-over) & Bảo trì Định kỳ:" "Ngừng hoàn toàn việc quản lý rời rạc trên Excel; 100% nghiệp vụ Admin, CRM và tương tác khách hàng vận hành trên hệ thống mới. Đội ngũ IT bảo trì định kỳ hàng tuần, kiểm tra log API và thực hiện lịch trình Backup tự động."))

[void]$b.Append((New-WP -Text "4.2. Tài liệu Hướng dẫn Cài đặt & Khởi chạy Nhanh Phần mềm" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 140 -SpaceAfter 80))
[void]$b.Append((New-WBullet "Yêu cầu môi trường:" "Hệ điều hành Windows 10/11, đã cài đặt .NET 8.0 SDK (máy chủ tích hợp sẵn SQLite tự động nạp 100% dữ liệu mẫu phong phú ngay khi khởi chạy)."))
[void]$b.Append((New-WBullet "Cách 1 (Khởi chạy tự động 1-Click):" "Nhấp đúp vào tệp start_demo.bat tại thư mục gốc d:\HTTTDN_2026 để tự động bật máy chủ Backend API (cổng 5000) và mở trình duyệt."))
[void]$b.Append((New-WBullet "Cách 2 (Khởi chạy bằng dòng lệnh):" "Mở Terminal tại thư mục Backend/HTTTDN.AdminApi và chạy lệnh: dotnet run (Backend lắng nghe tại http://localhost:5000). Sau đó mở các tệp giao diện trong thư mục Frontend_Admin bằng trình duyệt."))

# --- 4.3 HƯỚNG DẪN SỬ DỤNG CHI TIẾT THEO VAI TRÒ (CÓ ẢNH THẬT CỦA ĐỒ ÁN) ---
[void]$b.Append((New-WP -Text "4.3. Hướng dẫn Sử dụng Chi tiết Theo Từng Vai trò (Minh họa bằng Hình ảnh Thực tế của Đồ án)" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 140 -SpaceAfter 80))
[void]$b.Append((New-WP -Text "Dưới đây là tài liệu hướng dẫn vận hành chi tiết cho 3 nhóm đối tượng người dùng, minh họa bằng 100% ảnh chụp thực tế từ các phân hệ của đồ án:" -Size 26 -IndentFirst 420))

# 4.3.1 ADMIN SERVER
[void]$b.Append((New-WP -Text "4.3.1. Hướng dẫn Vận hành Dành cho Quản trị viên (Admin Server)" -Bold $true -Size 26 -Color "1E3A8A" -SpaceBefore 100 -SpaceAfter 40))
[void]$b.Append((New-WBullet "Bước 1 - Đăng nhập nội bộ:" "Quản trị viên mở trang login.html, nhập tài khoản admin và mật khẩu 123456. Hệ thống kiểm tra mật khẩu mã hóa BCrypt và điều hướng vào Cổng Quản trị."))

[void]$b.Append((New-WImage -RelId "rIdImgGuideLogin" -WidthEmu 5400000 -HeightEmu 3375000 -Caption "Hình 4.1: Cổng Đăng nhập Hệ thống Quản trị Nội bộ dành riêng cho Admin và Quản lý" -DocPrId 12))

[void]$b.Append((New-WBullet "Bước 2 - Thao tác Quản trị Tài khoản & Phân quyền:" "Trên giao diện admin.html, Quản trị viên theo dõi 4 thẻ chỉ số KPI, bấm nút '+ Thêm tài khoản' để cấp tài khoản mới, chọn quyền trực tiếp từ Dropdown (Admin, Manager, Customer, HR, Warehouse, Sales), bấm 'Khóa' để tạm ngưng truy cập hoặc bấm 'Xóa Account' để thu hồi tài khoản."))

[void]$b.Append((New-WImage -RelId "rIdImgGuideAdmin" -WidthEmu 5600000 -HeightEmu 3500000 -Caption "Hình 4.2: Giao diện Tác nghiệp của Admin Server — Quản lý Danh sách Tài khoản & Phân quyền trực tiếp" -DocPrId 13))

# 4.3.2 MANAGER CRM
[void]$b.Append((New-WP -Text "4.3.2. Hướng dẫn Vận hành Dành cho Người Quản lý (CRM Manager)" -Bold $true -Size 26 -Color "1E3A8A" -SpaceBefore 120 -SpaceAfter 40))
[void]$b.Append((New-WBullet "Bước 1 - Đăng nhập phân hệ CRM:" "Người quản lý đăng nhập tại login.html với tài khoản quanly / 123456. Hệ thống tự động phân luồng và mở giao diện manager_crm.html."))
[void]$b.Append((New-WBullet "Bước 2 - Thực hiện 7 Nghiệp vụ CRM:" ""))
[void]$b.Append((New-WBullet "• Tab 1 (Hồ sơ Khách hàng):" "Thực hiện: (1) Bấm nút '+ Thêm một khách hàng mới' để nhập hồ sơ thành viên; (2) Bấm 'Xóa' để xóa khách hàng; (3) Bấm 'Khóa' để chặn đăng nhập tài khoản vi phạm."))
[void]$b.Append((New-WBullet "• Tab 2 (Tiếp nhận Phản hồi):" "(4) Xem phản hồi đánh giá sản phẩm 1–5 sao của khách hàng, nhập câu trả lời giải đáp chính thức từ doanh nghiệp."))
[void]$b.Append((New-WBullet "• Tab 3 (Báo cáo Nhân khẩu học):" "(5) Xem biểu đồ tỷ lệ độ tuổi (<20, 20-30, >30) và tỷ lệ sở thích (Gaming, Văn phòng, Đồ họa, Lập trình)."))
[void]$b.Append((New-WBullet "• Tab 4 (Khảo sát Thị trường):" "(6) Bấm '+ Tạo khảo sát mới', nhập tên sản phẩm, giá dự kiến, thời hạn kết thúc để tự động phân phối phiếu khảo sát tới tài khoản khách hàng."))
[void]$b.Append((New-WBullet "• Tab 5 (Thống kê Kết quả):" "(7) Theo dõi trực quan tỷ lệ ý định mua sắm, điểm số quan tâm trung bình và danh sách ý kiến đóng góp của khách hàng."))

[void]$b.Append((New-WImage -RelId "rIdImgManager" -WidthEmu 5600000 -HeightEmu 2500000 -Caption "Hình 4.3: Giao diện Người Quản lý CRM — Thực hiện 7 nghiệp vụ quản lý khách hàng và thống kê" -DocPrId 14))

# 4.3.3 CUSTOMER PORTAL
[void]$b.Append((New-WP -Text "4.3.3. Hướng dẫn Sử dụng Dành cho Khách hàng (Customer Portal)" -Bold $true -Size 26 -Color "1E3A8A" -SpaceBefore 120 -SpaceAfter 40))
[void]$b.Append((New-WBullet "Bước 1 - Đăng ký & Đăng nhập:" "Khách hàng truy cập customer_login.html (tách biệt hoàn toàn cổng nội bộ). Khách hàng có thể tự đăng ký tài khoản với form tối giản hoặc đăng nhập bằng tài khoản khachhang1 / 123456."))

[void]$b.Append((New-WImage -RelId "rIdImgCustLogin" -WidthEmu 5400000 -HeightEmu 3580000 -Caption "Hình 4.4: Cổng Đăng nhập và Đăng ký Tài khoản Khách hàng SGU Tech Store" -DocPrId 15))

[void]$b.Append((New-WBullet "Bước 2 - Trải nghiệm Trang chủ SGU Tech Store:" "Giao diện trang chủ user.html được thiết kế theo phong cách doanh nghiệp công nghệ VNG với Hero Banner nhận diện và 3 Thẻ điều hướng danh tiếng (Products - People - Impacts)."))

[void]$b.Append((New-WImage -RelId "rIdImgCustPortal" -WidthEmu 5600000 -HeightEmu 3500000 -Caption "Hình 4.5: Giao diện Trang chủ Cổng Khách hàng SGU Tech Store (Phong cách Tập đoàn VNG)" -DocPrId 16))

[void]$b.Append((New-WBullet "Bước 3 - Gửi Đánh giá Sản phẩm & Bộ lọc Thông minh:" "Khách hàng chọn sản phẩm, chấm 1–5 sao và gửi nhận xét. Bảng theo dõi phản hồi tích hợp Smart Filter Toolbar giúp lọc nhanh theo danh mục (Laptop, Màn hình, Bàn phím, Linh kiện) hoặc lọc đánh giá 5★ và xem lời giải đáp từ Người quản lý."))

[void]$b.Append((New-WImage -RelId "rIdImgCustFeed" -WidthEmu 5600000 -HeightEmu 3200000 -Caption "Hình 4.6: Thao tác Gửi phản hồi sản phẩm và Theo dõi lời giải đáp từ Người quản lý" -DocPrId 17))

[void]$b.Append((New-WBullet "Bước 4 - Thực hiện Khảo sát Sản phẩm Mới 5 Tiêu chí:" "Khi doanh nghiệp phát hành khảo sát, khách hàng bấm 'Thực hiện khảo sát' để tham gia đánh giá theo 5 tiêu chí: Điểm quan tâm 1-5, Đánh giá mức giá, Chọn tính năng mong đợi dạng thẻ Chip, Ý định mua sắm & thời điểm, Mức giá sẵn sàng chi trả kèm góp ý."))

[void]$b.Append((New-WImage -RelId "rIdImgCustSurv" -WidthEmu 4200000 -HeightEmu 4000000 -Caption "Hình 4.7: Thao tác Thực hiện bảng khảo sát sản phẩm mới với 5 tiêu chí thăm dò thị trường" -DocPrId 18))

[void]$b.Append((New-WBullet "Bước 5 - Chỉnh sửa Thông tin Hồ sơ Cá nhân:" "Khách hàng xem thẻ thành viên và cập nhật Họ tên, SĐT, Email, Tuổi, Giới tính, Sở thích và Địa chỉ. Dữ liệu này tự động đồng bộ sang báo cáo nhân khẩu học của Người quản lý CRM."))

[void]$b.Append((New-WImage -RelId "rIdImgCustProf" -WidthEmu 5600000 -HeightEmu 2700000 -Caption "Hình 4.8: Thao tác Chỉnh sửa thông tin hồ sơ cá nhân của khách hàng" -DocPrId 19))

# ==============================================================================
# CHƯƠNG V: TỔNG KẾT & HƯỚNG PHÁT TRIỂN
# ==============================================================================
[void]$b.Append((New-WPageBreak))
[void]$b.Append((New-WP -Text "CHƯƠNG V: TỔNG KẾT ĐỒ ÁN VÀ HƯỚNG PHÁT TRIỂN TRONG TƯƠNG LAI (5 ĐIỂM)" -Bold $true -Size 32 -Align "left" -Color "1E3A8A" -SpaceBefore 180 -SpaceAfter 120))

[void]$b.Append((New-WP -Text "5.1. Tổng kết Những Kết quả Đạt được" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 80 -SpaceAfter 60))
[void]$b.Append((New-WBullet "Về mặt Phân tích & Thiết kế HTTT:" "Hoàn thành đầy đủ quy trình khảo sát 15 câu hỏi thực tế, đặc tả chi tiết bài toán, xây dựng bộ sơ đồ BFD, Context Diagram, DFD mức đỉnh và thiết kế CSDL 8/9 bảng chuẩn hóa 3NF kèm kịch bản Backup/Restore."))
[void]$b.Append((New-WBullet "Về mặt Phần mềm & Giao diện:" "Xây dựng hoàn chỉnh hệ thống Web API (.NET 8.0) và 3 phân hệ giao diện tách biệt (Admin Server, Quản lý CRM, Cổng Khách hàng) với thiết kế chuẩn doanh nghiệp lấy cảm hứng từ VNG Tech, đồng bộ dữ liệu thời gian thực và đáp ứng trọn vẹn 100% tiêu chí chấm điểm của học phần."))

[void]$b.Append((New-WP -Text "5.2. Đánh giá Ưu điểm và Hạn chế của Hệ thống" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 100 -SpaceAfter 60))
[void]$b.Append((New-WBullet "Ưu điểm nổi bật:" "Kiến trúc Dual-Database linh hoạt; giao diện doanh nghiệp hiện đại, trực quan với hệ thống biểu đồ phân tích thời gian thực; kiểm soát chặt chẽ toàn vẹn khóa ngoại và bảo mật mật khẩu bằng BCrypt."))
[void]$b.Append((New-WBullet "Hạn chế hiện tại:" "Hệ thống hiện tập trung chuyên sâu vào Phân hệ Quản trị trung tâm và Phân hệ CRM (Mục III.4), chưa tích hợp cổng thanh toán trực tuyến."))

[void]$b.Append((New-WP -Text "5.3. Hướng Phát triển Mở rộng trong Tương lai" -Bold $true -Size 28 -Align "left" -Color "1E3A8A" -SpaceBefore 100 -SpaceAfter 60))
[void]$b.Append((New-WBullet "1. Tích hợp thành Hệ thống ERP Toàn diện:" "Phát triển nối tiếp Phân hệ Quản lý Kho & Dự báo Nguyên vật liệu (MRP - Mục III.5), Phân hệ Bán hàng (Mục III.2) và Phân hệ Quản lý Nhân sự (HRM - Mục III.3) trên cùng một cơ sở dữ liệu trung tâm."))
[void]$b.Append((New-WBullet "2. Ứng dụng Trí tuệ Nhân tạo (AI Recommendation):" "Sử dụng dữ liệu Độ tuổi, Sở thích và Lịch sử đánh giá trong bảng CustomerProfiles & Feedbacks để tự động gợi ý sản phẩm phù hợp cho từng khách hàng và dự báo số lượng hàng cần nhập theo mùa vụ."))

[void]$b.Append((New-WHr))
[void]$b.Append((New-WP -Text "XÁC NHẬN CỦA NHÓM SINH VIÊN THỰC HIỆN ĐỒ ÁN" -Bold $true -Size 26 -Align "center" -Color "1E3A8A" -SpaceBefore 160 -SpaceAfter 40))
[void]$b.Append((New-WP -Text "(Ký tên và ghi rõ họ tên từng thành viên khi nộp bản in)" -Italic $true -Size 24 -Align "center" -Color "475569" -SpaceBefore 0 -SpaceAfter 120))

# ==============================================================================
# XÂY DỰNG TỆP OPENXML DOCX HOÀN CHỈNH KÈM MEDIA
# ==============================================================================
$contentTypes = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
    <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
    <Default Extension="xml" ContentType="application/xml"/>
    <Default Extension="png" ContentType="image/png"/>
    <Default Extension="jpg" ContentType="image/jpeg"/>
    <Default Extension="jpeg" ContentType="image/jpeg"/>
    <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
    <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>
"@

$rels = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
    <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>
"@

# Document relationships with styles and all real project media images
$docRels = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
    <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
    <Relationship Id="rIdImgBFD" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/bfd_diagram.png"/>
    <Relationship Id="rIdImgContext" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/context_diagram.png"/>
    <Relationship Id="rIdImgDFD" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/dfd_level0_diagram.png"/>
    <Relationship Id="rIdImgERD" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/erd_diagram.png"/>
    <Relationship Id="rIdImgAdmin" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_admin_server.jpg"/>
    <Relationship Id="rIdImgManager" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_manager_crm.png"/>
    <Relationship Id="rIdImgCustPortal" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_guide_user_full.png"/>
    <Relationship Id="rIdImgCustReg" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_customer_register.png"/>
    <Relationship Id="rIdImgCustLogin" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_guide_cust_login.png"/>
    <Relationship Id="rIdImgCustFeed" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_customer_feedback.jpg"/>
    <Relationship Id="rIdImgCustSurv" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_customer_survey.jpg"/>
    <Relationship Id="rIdImgCustProf" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_customer_profile.jpg"/>
    <Relationship Id="rIdImgGuideLogin" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_guide_login.png"/>
    <Relationship Id="rIdImgGuideAdmin" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_guide_admin.png"/>
</Relationships>
"@

$stylesXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
    <w:docDefaults>
        <w:rPrDefault>
            <w:rPr>
                <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
                <w:sz w:val="26"/>
                <w:szCs w:val="26"/>
                <w:lang w:val="vi-VN"/>
            </w:rPr>
        </w:rPrDefault>
    </w:docDefaults>
</w:styles>
"@

$documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
            xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
            xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
            xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
            xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
    <w:body>
        $($b.ToString())
        <w:sectPr>
            <w:pgSz w:w="11906" w:h="16838"/>
            <w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1417" w:header="708" w:footer="708" w:gutter="0"/>
        </w:sectPr>
    </w:body>
</w:document>
"@

$dir = [System.IO.Path]::GetDirectoryName($OutputPath)
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}
if (Test-Path $OutputPath) {
    Remove-Item $OutputPath -Force
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$fs = [System.IO.File]::Open($OutputPath, [System.IO.FileMode]::Create)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)

function Add-ZipTextEntry($zipArchive, [string]$entryPath, [string]$content, $encoding) {
    $entry = $zipArchive.CreateEntry($entryPath)
    $stream = $entry.Open()
    $bytes = $encoding.GetBytes($content)
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Close()
}

function Add-ZipBinaryEntry($zipArchive, [string]$entryPath, [string]$filePath) {
    if (Test-Path $filePath) {
        $entry = $zipArchive.CreateEntry($entryPath)
        $entryStream = $entry.Open()
        $fileStream = [System.IO.File]::OpenRead($filePath)
        $fileStream.CopyTo($entryStream)
        $fileStream.Close()
        $entryStream.Close()
        Write-Host "Added media: $entryPath"
    } else {
        Write-Warning "File not found for media entry: $filePath"
    }
}

Add-ZipTextEntry $zip "[Content_Types].xml" $contentTypes $utf8NoBom
Add-ZipTextEntry $zip "_rels/.rels" $rels $utf8NoBom
Add-ZipTextEntry $zip "word/_rels/document.xml.rels" $docRels $utf8NoBom
Add-ZipTextEntry $zip "word/styles.xml" $stylesXml $utf8NoBom
Add-ZipTextEntry $zip "word/document.xml" $documentXml $utf8NoBom

# Add all authentic media images
Add-ZipBinaryEntry $zip "word/media/bfd_diagram.png" (Join-Path $ImageDir "bfd_diagram.png")
Add-ZipBinaryEntry $zip "word/media/context_diagram.png" (Join-Path $ImageDir "context_diagram.png")
Add-ZipBinaryEntry $zip "word/media/dfd_level0_diagram.png" (Join-Path $ImageDir "dfd_level0_diagram.png")
Add-ZipBinaryEntry $zip "word/media/erd_diagram.png" (Join-Path $ImageDir "erd_diagram.png")
Add-ZipBinaryEntry $zip "word/media/ui_admin_server.jpg" (Join-Path $ImageDir "ui_admin_server.jpg")
Add-ZipBinaryEntry $zip "word/media/ui_manager_crm.png" (Join-Path $ImageDir "ui_manager_crm.png")
Add-ZipBinaryEntry $zip "word/media/ui_guide_user_full.png" (Join-Path $ImageDir "ui_guide_user_full.png")
Add-ZipBinaryEntry $zip "word/media/ui_customer_register.png" (Join-Path $ImageDir "ui_customer_register.png")
Add-ZipBinaryEntry $zip "word/media/ui_guide_cust_login.png" (Join-Path $ImageDir "ui_guide_cust_login.png")
Add-ZipBinaryEntry $zip "word/media/ui_customer_feedback.jpg" (Join-Path $ImageDir "ui_customer_feedback.jpg")
Add-ZipBinaryEntry $zip "word/media/ui_customer_survey.jpg" (Join-Path $ImageDir "ui_customer_survey.jpg")
Add-ZipBinaryEntry $zip "word/media/ui_customer_profile.jpg" (Join-Path $ImageDir "ui_customer_profile.jpg")
Add-ZipBinaryEntry $zip "word/media/ui_guide_login.png" (Join-Path $ImageDir "ui_guide_login.png")
Add-ZipBinaryEntry $zip "word/media/ui_guide_admin.png" (Join-Path $ImageDir "ui_guide_admin.png")

$zip.Dispose()
$fs.Close()

Write-Host "SUCCESS! Generated Word document at: $OutputPath"
Write-Host "File size: $((Get-Item $OutputPath).Length) bytes"
