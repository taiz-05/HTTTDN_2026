# ==============================================================================
# PART 0: XML HELPERS, COVER PAGE, TOC, LIST OF FIGURES/TABLES & 15-WEEK PLAN
# ==============================================================================

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
        [int]$SpaceBefore = 90,
        [int]$SpaceAfter = 140,
        [int]$IndentFirst = 0,
        [string]$Shading = "",
        [string]$Font = "Times New Roman"
    )
    $pPr = "<w:jc w:val=`"$Align`"/><w:spacing w:before=`"$SpaceBefore`" w:after=`"$SpaceAfter`" w:line=`"336`" w:lineRule=`"auto`"/>"
    if ($IndentFirst -gt 0) {
        $pPr += "<w:ind w:firstLine=`"$IndentFirst`"/>"
    }
    if ($Shading -ne "") {
        $pPr += "<w:shd w:val=`"clear`" w:color=`"auto`" w:fill=`"$Shading`"/>"
        $pPr += "<w:pBdr><w:left w:val=`"single`" w:sz=`"24`" w:space=`"10`" w:color=`"1D4ED8`"/></w:pBdr>"
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

function New-WPageBreak {
    return "<w:p><w:r><w:br w:type=`"page`"/></w:r></w:p>"
}

function New-WHeading1([string]$Text) {
    $esc = Escape-Xml $Text
    return @"
<w:p>
    <w:pPr>
        <w:keepNext/>
        <w:shd w:val="clear" w:color="auto" w:fill="0F172A"/>
        <w:pBdr>
            <w:bottom w:val="single" w:sz="24" w:space="6" w:color="F97316"/>
        </w:pBdr>
        <w:spacing w:before="280" w:after="200" w:line="320" w:lineRule="auto"/>
        <w:jc w:val="left"/>
    </w:pPr>
    <w:r>
        <w:rPr>
            <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
            <w:b/><w:bCs/>
            <w:color w:val="FFFFFF"/>
            <w:sz w:val="30"/><w:szCs w:val="30"/>
        </w:rPr>
        <w:t xml:space="preserve">  $esc</w:t>
    </w:r>
</w:p>
"@
}

function New-WHeading2([string]$Text) {
    $esc = Escape-Xml $Text
    return @"
<w:p>
    <w:pPr>
        <w:keepNext/>
        <w:pBdr>
            <w:bottom w:val="single" w:sz="12" w:space="4" w:color="1D4ED8"/>
        </w:pBdr>
        <w:spacing w:before="240" w:after="140" w:line="312" w:lineRule="auto"/>
        <w:jc w:val="left"/>
    </w:pPr>
    <w:r>
        <w:rPr>
            <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
            <w:b/><w:bCs/>
            <w:color w:val="1E3A8A"/>
            <w:sz w:val="28"/><w:szCs w:val="28"/>
        </w:rPr>
        <w:t xml:space="preserve">$esc</w:t>
    </w:r>
</w:p>
"@
}

function New-WHeading3([string]$Text) {
    $esc = Escape-Xml $Text
    return @"
<w:p>
    <w:pPr>
        <w:keepNext/>
        <w:spacing w:before="180" w:after="100" w:line="300" w:lineRule="auto"/>
        <w:jc w:val="left"/>
    </w:pPr>
    <w:r>
        <w:rPr>
            <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
            <w:b/><w:bCs/>
            <w:color w:val="0F172A"/>
            <w:sz w:val="26"/><w:szCs w:val="26"/>
        </w:rPr>
        <w:t xml:space="preserve">$esc</w:t>
    </w:r>
</w:p>
"@
}

function New-WHeading4([string]$Text) {
    $esc = Escape-Xml $Text
    return @"
<w:p>
    <w:pPr>
        <w:keepNext/>
        <w:spacing w:before="140" w:after="80" w:line="288" w:lineRule="auto"/>
        <w:jc w:val="left"/>
    </w:pPr>
    <w:r>
        <w:rPr>
            <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
            <w:b/><w:bCs/><w:i/><w:iCs/>
            <w:color w:val="9A3412"/>
            <w:sz w:val="25"/><w:szCs w:val="25"/>
        </w:rPr>
        <w:t xml:space="preserve">$esc</w:t>
    </w:r>
</w:p>
"@
}

function New-WBullet([string]$Label, [string]$Text, [int]$Size = 26) {
    $pPr = "<w:jc w:val=`"both`"/><w:spacing w:before=`"70`" w:after=`"100`" w:line=`"324`" w:lineRule=`"auto`"/><w:ind w:left=`"360`" w:hanging=`"240`"/>"
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

function New-WCodeBlock([string]$CodeText, [string]$Title = "") {
    $sb = New-Object System.Text.StringBuilder
    if ($Title -ne "") {
        [void]$sb.Append((New-WP -Text $Title -Bold $true -Size 23 -Color "1E3A8A" -SpaceBefore 120 -SpaceAfter 40))
    }
    $lines = $CodeText -split "`n"
    $runs = New-Object System.Text.StringBuilder
    $rPr = "<w:rFonts w:ascii=`"Consolas`" w:hAnsi=`"Consolas`" w:cs=`"Consolas`"/><w:sz w:val=`"20`"/><w:szCs w:val=`"20`"/><w:color w:val=`"0F172A`"/>"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($i -gt 0) { [void]$runs.Append("<w:r><w:br/></w:r>") }
        $esc = Escape-Xml ($lines[$i].TrimEnd("`r"))
        [void]$runs.Append("<w:r><w:rPr>$rPr</w:rPr><w:t xml:space=`"preserve`">$esc</w:t></w:r>")
    }
    $pPr = "<w:jc w:val=`"left`"/><w:spacing w:before=`"80`" w:after=`"140`" w:line=`"260`" w:lineRule=`"auto`"/><w:shd w:val=`"clear`" w:color=`"auto`" w:fill=`"F1F5F9`"/><w:pBdr><w:top w:val=`"single`" w:sz=`"6`" w:space=`"4`" w:color=`"CBD5E1`"/><w:left w:val=`"single`" w:sz=`"18`" w:space=`"8`" w:color=`"334155`"/><w:bottom w:val=`"single`" w:sz=`"6`" w:space=`"4`" w:color=`"CBD5E1`"/><w:right w:val=`"single`" w:sz=`"6`" w:space=`"4`" w:color=`"CBD5E1`"/></w:pBdr>"
    [void]$sb.Append("<w:p><w:pPr>$pPr</w:pPr>$($runs.ToString())</w:p>")
    return $sb.ToString()
}

function New-WTable {
    param(
        [string[]]$Headers,
        [array]$Rows,
        [int[]]$ColWidths = @(),
        [string]$HeaderFill = "1E3A8A",
        [int]$FontSize = 23
    )
    $colCount = $Headers.Count
    if ($ColWidths.Count -ne $colCount) {
        $w = [int](9600 / $colCount)
        $ColWidths = @()
        for ($i = 0; $i -lt $colCount; $i++) { $ColWidths += $w }
    }

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append(@"
<w:tbl>
    <w:tblPr>
        <w:tblW w:w="5000" w:type="pct"/>
        <w:jc w:val="center"/>
        <w:tblBorders>
            <w:top w:val="single" w:sz="8" w:space="0" w:color="94A3B8"/>
            <w:left w:val="single" w:sz="8" w:space="0" w:color="94A3B8"/>
            <w:bottom w:val="single" w:sz="8" w:space="0" w:color="94A3B8"/>
            <w:right w:val="single" w:sz="8" w:space="0" w:color="94A3B8"/>
            <w:insideH w:val="single" w:sz="6" w:space="0" w:color="CBD5E1"/>
            <w:insideV w:val="single" w:sz="6" w:space="0" w:color="CBD5E1"/>
        </w:tblBorders>
        <w:tblCellMar>
            <w:top w:w="90" w:type="dxa"/>
            <w:left w:w="120" w:type="dxa"/>
            <w:bottom w:w="90" w:type="dxa"/>
            <w:right w:w="120" w:type="dxa"/>
        </w:tblCellMar>
    </w:tblPr>
    <w:tblGrid>
"@)
    foreach ($cw in $ColWidths) {
        [void]$sb.Append("<w:gridCol w:w=`"$cw`"/>")
    }
    [void]$sb.Append("</w:tblGrid>")

    # Header Row
    [void]$sb.Append("<w:tr><w:trPr><w:tblHeader/></w:trPr>")
    for ($c = 0; $c -lt $colCount; $c++) {
        $hText = Escape-Xml $Headers[$c]
        $cw = $ColWidths[$c]
        [void]$sb.Append(@"
<w:tc>
    <w:tcPr>
        <w:tcW w:w="$cw" w:type="dxa"/>
        <w:shd w:val="clear" w:color="auto" w:fill="$HeaderFill"/>
        <w:vAlign w:val="center"/>
    </w:tcPr>
    <w:p>
        <w:pPr><w:jc w:val="center"/><w:spacing w:before="50" w:after="50" w:line="260" w:lineRule="auto"/></w:pPr>
        <w:r>
            <w:rPr>
                <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
                <w:b/><w:bCs/>
                <w:color w:val="FFFFFF"/>
                <w:sz w:val="$FontSize"/><w:szCs w:val="$FontSize"/>
            </w:rPr>
            <w:t xml:space="preserve">$hText</w:t>
        </w:r>
    </w:p>
</w:tc>
"@)
    }
    [void]$sb.Append("</w:tr>")

    # Data Rows
    $rIdx = 0
    foreach ($row in $Rows) {
        $fill = if ($rIdx % 2 -eq 1) { "F8FAFC" } else { "FFFFFF" }
        [void]$sb.Append("<w:tr>")
        for ($c = 0; $c -lt $colCount; $c++) {
            $cellVal = if ($c -lt $row.Count) { [string]$row[$c] } else { "" }
            $cw = $ColWidths[$c]
            $isBoldCell = ($c -eq 0)
            $align = if ($c -eq 0 -and $cellVal.Length -le 22) { "center" } else { "left" }
            $bTag = if ($isBoldCell) { "<w:b/><w:bCs/>" } else { "" }

            $lines = $cellVal -split "`n"
            $runs = New-Object System.Text.StringBuilder
            for ($li = 0; $li -lt $lines.Count; $li++) {
                if ($li -gt 0) { [void]$runs.Append("<w:r><w:br/></w:r>") }
                $escLine = Escape-Xml ($lines[$li].TrimEnd("`r"))
                [void]$runs.Append(@"
<w:r>
    <w:rPr>
        <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
        $bTag
        <w:color w:val="0F172A"/>
        <w:sz w:val="$FontSize"/><w:szCs w:val="$FontSize"/>
    </w:rPr>
    <w:t xml:space="preserve">$escLine</w:t>
</w:r>
"@)
            }

            [void]$sb.Append(@"
<w:tc>
    <w:tcPr>
        <w:tcW w:w="$cw" w:type="dxa"/>
        <w:shd w:val="clear" w:color="auto" w:fill="$fill"/>
        <w:vAlign w:val="center"/>
    </w:tcPr>
    <w:p>
        <w:pPr><w:jc w:val="$align"/><w:spacing w:before="45" w:after="45" w:line="268" w:lineRule="auto"/></w:pPr>
        $($runs.ToString())
    </w:p>
</w:tc>
"@)
        }
        [void]$sb.Append("</w:tr>")
        $rIdx++
    }

    [void]$sb.Append("</w:tbl>")
    [void]$sb.Append("<w:p><w:pPr><w:spacing w:before=`"40`" w:after=`"90`"/></w:pPr></w:p>")
    return $sb.ToString()
}

function New-WImage {
    param(
        [string]$RelId,
        [long]$WidthEmu = 5850000,
        [long]$HeightEmu = 3600000,
        [string]$Caption = "",
        [int]$DocPrId = 1
    )
    $capXml = ""
    if ($Caption -ne "") {
        $escCap = Escape-Xml $Caption
        $capXml = "<w:p><w:pPr><w:jc w:val=`"center`"/><w:spacing w:before=`"80`" w:after=`"200`"/></w:pPr><w:r><w:rPr><w:rFonts w:ascii=`"Times New Roman`" w:hAnsi=`"Times New Roman`"/><w:sz w:val=`"24`"/><w:i/><w:color w:val=`"1E3A8A`"/><w:b/></w:rPr><w:t xml:space=`"preserve`">$escCap</w:t></w:r></w:p>"
    }
    return @"
<w:p>
    <w:pPr>
        <w:jc w:val="center"/>
        <w:spacing w:before="160" w:after="60"/>
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
                                <a:stretch><a:fillRect/></a:stretch>
                            </pic:blipFill>
                            <pic:spPr>
                                <a:xfrm>
                                    <a:off x="0" y="0"/>
                                    <a:ext cx="$WidthEmu" cy="$HeightEmu"/>
                                </a:xfrm>
                                <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
                                <a:ln w="12700">
                                    <a:solidFill><a:srgbClr val="94A3B8"/></a:solidFill>
                                </a:ln>
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

function Build-Part0-CoverAndFrontMatter {
    $sb = New-Object System.Text.StringBuilder

    # 1. TRANG BÌA (COVER PAGE)
    [void]$sb.Append((New-WP -Text "UBND THÀNH PHỐ HỒ CHÍ MINH" -Bold $true -Size 28 -Align "center" -Color "0F172A" -SpaceBefore 40 -SpaceAfter 40))
    [void]$sb.Append((New-WP -Text "TRƯỜNG ĐẠI HỌC SÀI GÒN" -Bold $true -Size 32 -Align "center" -Color "1E3A8A" -SpaceBefore 20 -SpaceAfter 40))
    [void]$sb.Append((New-WP -Text "KHOA CÔNG NGHỆ THÔNG TIN" -Bold $true -Size 28 -Align "center" -Color "0F172A" -SpaceBefore 20 -SpaceAfter 120))
    [void]$sb.Append((New-WP -Text "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -Bold $true -Size 26 -Align "center" -Color "F97316" -SpaceBefore 20 -SpaceAfter 220))

    [void]$sb.Append((New-WP -Text "BÁO CÁO ĐỒ ÁN MÔN HỌC" -Bold $true -Size 38 -Align "center" -Color "1E3A8A" -SpaceBefore 120 -SpaceAfter 80))
    [void]$sb.Append((New-WP -Text "HỆ THỐNG THÔNG TIN DOANH NGHIỆP" -Bold $true -Size 42 -Align "center" -Color "9A3412" -SpaceBefore 40 -SpaceAfter 60))
    [void]$sb.Append((New-WP -Text "(MÃ HỌC PHẦN: 841065)" -Bold $true -Size 28 -Align "center" -Color "334155" -SpaceBefore 20 -SpaceAfter 180))

    [void]$sb.Append((New-WP -Text "ĐỀ TÀI CHỦ ĐỀ 2: PHÂN TÍCH, THIẾT KẾ VÀ XÂY DỰNG HỆ THỐNG THÔNG TIN QUẢN TRỊ MÁY CHỦ ĐỘC LẬP (ADMIN SERVER) & QUẢN LÝ QUAN HỆ KHÁCH HÀNG (CRM) TẠI CÔNG TY CỔ PHẦN CÔNG NGHỆ SGU TECH" -Bold $true -Size 30 -Align "center" -Color "0F172A" -SpaceBefore 100 -SpaceAfter 180 -Shading "F8FAFC"))

    [void]$sb.Append((New-WTable -Headers @("STT", "Họ và Tên Sinh viên thực hiện", "Mã số Sinh viên", "Vai trò trong nhóm", "Lớp / Khóa") -ColWidths @(800, 3200, 1900, 1900, 1800) -Rows @(
        @("1", "Huỳnh Tuấn Tài", "3123411261", "Nhóm trưởng", "DCT123 — K23"),
        @("2", "Hoàng Thái Thanh", "3123411267", "Thành viên", "DCT123 — K23"),
        @("3", "Lê Nguyễn Phú Hải", "3123411080", "Thành viên", "DCT123 — K23"),
        @("4", "Nguyễn Đăng Khoa", "3123411157", "Thành viên", "DCT123 — K23")
    )))

    [void]$sb.Append((New-WP -Text "Nền tảng Công nghệ: ASP.NET Core 8.0 Web API • Entity Framework Core 8.0 • Microsoft SQL Server (9 Bảng Chuẩn 3NF) • Giao diện VNG Enterprise Design System" -Italic $true -Size 24 -Align "center" -Color "334155" -SpaceBefore 180 -SpaceAfter 200))
    [void]$sb.Append((New-WP -Text "Thành phố Hồ Chí Minh — Năm học 2025 – 2026" -Bold $true -Size 26 -Align "center" -Color "1E3A8A" -SpaceBefore 120 -SpaceAfter 60))

    [void]$sb.Append((New-WPageBreak))

    # 2. LỜI CẢM ƠN & CAM ĐOAN + PHIẾU CHẤM ĐIỂM THEO THANG ĐIỂM CHUẨN
    [void]$sb.Append((New-WHeading1 "LỜI CẢM ƠN VÀ CAM ĐOAN CỦA NHÓM THỰC HIỆN"))
    [void]$sb.Append((New-WP -Text "Lời đầu tiên, nhóm sinh viên thực hiện đồ án xin gửi lời cảm ơn chân thành và sâu sắc nhất đến Quý Thầy/Cô Khoa Công nghệ Thông tin – Trường Đại học Sài Gòn, đặc biệt là Giảng viên phụ trách học phần Hệ thống Thông tin Doanh nghiệp (Mã học phần: 841065). Trong suốt 15 tuần học tập và thực hiện đồ án, những kiến thức nền tảng và chuyên sâu mà Thầy/Cô truyền đạt về khảo sát hiện trạng doanh nghiệp, phân tích quy trình nghiệp vụ, mô hình hóa Sơ đồ Chức năng (BFD), Sơ đồ Ngữ cảnh (Context Diagram), Sơ đồ Luồng dữ liệu (DFD), thiết kế Cơ sở dữ liệu chuẩn hóa 3NF (ERD), phương án sao lưu – phục hồi dữ liệu và kiến trúc phần mềm doanh nghiệp đã giúp nhóm hoàn thành trọn vẹn đề tài này." -IndentFirst 420))
    [void]$sb.Append((New-WP -Text "Đề tài của nhóm tập trung giải quyết bài toán thực tiễn tại Công ty Cổ phần Công nghệ và Thương mại Điện tử SGU Tech (SGU Tech Corp) thông qua việc xây dựng Hệ thống Thông tin Quản trị Máy chủ Độc lập (Admin Server) và Quản lý Quan hệ Khách hàng (CRM). Toàn bộ hệ thống được thiết kế tuân thủ nghiêm ngặt yêu cầu tách biệt hoàn toàn giao diện Admin Server khỏi các phân hệ khác, đồng thời đáp ứng đầy đủ 100% các nghiệp vụ của Admin Server, Người Quản lý CRM và Khách hàng." -IndentFirst 420))
    [void]$sb.Append((New-WP -Text "Nhóm chúng em xin cam đoan toàn bộ nội dung phân tích, các sơ đồ kỹ thuật (BFD, Context, DFD Mức 0, DFD Mức 1, ERD, Kiến trúc 3 tầng), cơ sở dữ liệu SQL Server 9 bảng, mã nguồn Backend ASP.NET Core 8.0 và bộ giao diện thực tế trong báo cáo này là sản phẩm do chính 4 thành viên trong nhóm trực tiếp nghiên cứu, thiết kế và lập trình." -IndentFirst 420))

    [void]$sb.Append((New-WHeading2 "PHIẾU ĐÁNH GIÁ VÀ ĐỐI CHIẾU THANG ĐIỂM ĐỒ ÁN MÔN HỌC (100 ĐIỂM)"))
    [void]$sb.Append((New-WTable -Headers @("Mục", "Nội dung tiêu chí đánh giá theo yêu cầu đồ án", "Điểm tối đa", "Vị trí trình bày trong Báo cáo & Đồ án", "Điểm chấm") -ColWidths @(800, 4100, 1100, 2600, 1000) -Rows @(
        @("I.1", "Phần chung: Giới thiệu về DN (hoạt động, mô hình, nhân sự) (5đ) + Khảo sát HTTT của DN (bảng câu hỏi >= 15 câu, tổng kết & kết luận) (5đ)", "10 điểm", "Chương 1 (Mục 1.1 & Mục 1.2 — 25 câu hỏi khảo sát + 3 biên bản phỏng vấn)", ""),
        @("I.2", "Phân tích HTTT của DN: Bài toán mô tả chi tiết (2đ) + Sơ đồ chức năng BFD (2đ) + Sơ đồ ngữ cảnh (2đ) + Sơ đồ luồng dữ liệu mức đỉnh & mức 1 (4đ)", "10 điểm", "Chương 2 (Mục 2.1, 2.2, 2.3, 2.4 — 15 Use Cases + 5 sơ đồ BFD/Context/DFD)", ""),
        @("I.3", "Thiết kế HTTT: Thiết kế CSDL dựa vào các kho dữ liệu, ERD & bảng mô tả thuộc tính (5đ) + Thiết kế giao diện kèm hình ảnh thực tế & giới thiệu chi tiết chức năng (5đ)", "10 điểm", "Chương 3 (Mục 3.1 ERD 9 bảng & Data Dictionary + Mục 3.2 13 màn hình thực tế)", ""),
        @("I.4", "Cài đặt và bảo trì HTTT, phương án chuyển đổi hệ thống cũ sang mới, tài liệu hướng dẫn sử dụng hệ thống & kịch bản kiểm thử", "5 điểm", "Chương 4 (Mục 4.1, 4.2, 4.3, 4.4 — Hướng dẫn 3 vai trò + 30 Test Cases)", ""),
        @("I.5", "Tổng kết và hướng phát triển hệ thống: Những gì đã làm được, ưu nhược điểm của HTTT vừa xây dựng, hướng phát triển tương lai", "5 điểm", "Chương 5 (Mục 5.1, 5.2, 5.3 — Đối chiếu kết quả, Ưu/Nhược điểm & Lộ trình)", ""),
        @("II.1", "Cài đặt CSDL: CSDL được thiết kế với đầy đủ 9 bảng chuẩn 3NF (5đ) + Phương án sao lưu và phục hồi CSDL trong báo cáo (5đ)", "10 điểm", "Phần II (Mục II.1 & II.2 — Kịch bản DDL/DML + Backup/Restore 3 tầng T-SQL)", ""),
        @("II.2", "Dữ liệu Demo trong CSDL: Đầy đủ dữ liệu trong các bảng (19 TK, 15 KH, 16 SP), đã tạo sẵn tài khoản test và các giao dịch phản hồi (18), khảo sát (5 chiến dịch, 16 phiếu)", "20 điểm", "Phần II (Mục II.3) & File Database/HTTTDN_DB.sql + DbInitializer.cs", ""),
        @("III", "Xây dựng ứng dụng phần mềm: Đầy đủ chức năng của Admin Server tách biệt, Người Quản lý CRM (7 chức năng) và Khách hàng (5 chức năng)", "30 điểm", "Phần III (Đặc tả 21 API & Source Code Backend/Frontend thực tế)", ""),
        @("TỔNG", "TỔNG CỘNG ĐIỂM ĐÁNH GIÁ ĐỒ ÁN HỌC PHẦN HỆ THỐNG THÔNG TIN DOANH NGHIỆP", "100 điểm", "Đáp ứng đầy đủ 100% yêu cầu Báo cáo, CSDL, Source Code và readme.txt", "")
    )))

    [void]$sb.Append((New-WPageBreak))

    # 3. BẢNG PHÂN CÔNG NHIỆM VỤ CHI TIẾT & TỰ ĐÁNH GIÁ ĐIỂM CỦA TỪNG THÀNH VIÊN
    [void]$sb.Append((New-WHeading1 "BẢNG PHÂN CÔNG NỘI DUNG CÔNG VIỆC ĐÃ LÀM VÀ TỰ ĐÁNH GIÁ ĐIỂM TỪNG THÀNH VIÊN"))
    [void]$sb.Append((New-WP -Text "Thực hiện đúng quy định của học phần về việc ghi rõ nội dung công việc của từng thành viên đã làm và tự đánh giá điểm đóng góp, nhóm đã họp tổng kết và thống nhất bảng đánh giá chi tiết khối lượng công việc của 4 thành viên như sau:" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("STT", "Họ tên & MSSV", "Chức trách", "Danh mục chi tiết nội dung công việc thành viên đã trực tiếp thực hiện", "Tỷ lệ hoàn thành", "Tự đánh giá điểm") -ColWidths @(600, 1800, 1100, 4100, 1000, 1000) -Rows @(
        @("1", "Huỳnh Tuấn Tài`nMSSV: 3123411261", "Nhóm trưởng`n(System Architect & Backend Lead)", "1. Chủ trì khảo sát doanh nghiệp SGU Tech, xây dựng cơ cấu tổ chức và ma trận RACI.`n2. Phân tích nghiệp vụ tổng thể, viết đặc tả 20 quy tắc nghiệp vụ (BR-01..BR-20) và 15 hồ sơ Use Case (UC-01..UC-15).`n3. Thiết kế Sơ đồ Chức năng (BFD), Sơ đồ Ngữ cảnh (Context Diagram), Sơ đồ DFD Mức Đỉnh (Level 0) và 3 Sơ đồ DFD Mức 1.`n4. Lập trình Backend ASP.NET Core 8.0 cho phân hệ xác thực (AuthController.cs) và Admin Server (AccountsController.cs).`n5. Tổng hợp, biên tập và kiểm định chất lượng toàn bộ báo cáo đồ án.", "100%", "10.0 / 10"),
        @("2", "Hoàng Thái Thanh`nMSSV: 3123411267", "Thành viên`n(Database Architect & CRM API)", "1. Thiết kế bảng câu hỏi điều tra khảo sát HTTT (25 câu hỏi chuyên sâu) và tổng hợp thống kê 35 phiếu khảo sát.`n2. Thiết kế CSDL mức quan niệm & vật lý: ánh xạ 5 kho dữ liệu D1–D5 sang 9 bảng chuẩn 3NF, vẽ Lược đồ ERD.`n3. Viết kịch bản SQL Server (HTTTDN_DB.sql), bộ khởi tạo dữ liệu tự động (DbInitializer.cs) và kịch bản Sao lưu – Phục hồi CSDL (Full/Diff/Log Backup & Restore).`n4. Lập trình Backend API cho phân hệ Người Quản lý CRM (CrmAdminController.cs: Quản lý KH, Tiếp nhận phản hồi, Báo cáo độ tuổi & sở thích).`n5. Biên soạn Chương 3 (Mục 3.1 Thiết kế CSDL) và Phần II trong báo cáo.", "100%", "10.0 / 10"),
        @("3", "Lê Nguyễn Phú Hải`nMSSV: 3123411080", "Thành viên`n(Frontend Lead Admin & CRM)", "1. Nghiên cứu chuẩn giao diện doanh nghiệp VNG Corporation, xây dựng hệ thống CSS (styles.css) chuyên nghiệp, tách biệt hoàn toàn giao diện Admin Server.`n2. Thiết kế và lập trình Cổng Đăng nhập (login.html) và Giao diện Admin Server (admin.html, app.js): Thêm, Xóa, Khóa/Mở khóa và Phân quyền 3 vai trò (Admin, Manager, Customer).`n3. Thiết kế và lập trình Giao diện Người Quản lý CRM (quanly.html, manager_crm.js) gồm 5 tab nghiệp vụ và 6 biểu đồ thống kê (Chart.js + Offline Canvas Renderer).`n4. Biên soạn Chương 3 (Mục 3.2 Thiết kế giao diện Admin & CRM) trong báo cáo.", "100%", "10.0 / 10"),
        @("4", "Nguyễn Đăng Khoa`nMSSV: 3123411157", "Thành viên`n(Customer Portal, Survey API & QA)", "1. Lập trình Backend API cho Cổng Khách hàng (CustomerPortalController.cs: Đăng ký, Đăng nhập, Hồ sơ cá nhân, Gửi phản hồi sản phẩm, Nhận & gửi phiếu khảo sát).`n2. Thiết kế và lập trình Giao diện Cổng Khách hàng (user.html, user.js) đáp ứng đầy đủ 5 chức năng của Khách hàng.`n3. Xây dựng bộ dữ liệu Demo phong phú (19 tài khoản, 15 khách hàng, 16 sản phẩm, 18 phản hồi, 5 khảo sát, 16 phiếu trả lời).`n4. Thực hiện kiểm thử 30 Test Cases (TC-01..TC-30), viết Chương 4 (Cài đặt, Chuyển đổi, Hướng dẫn sử dụng), Chương 5 và tệp readme.txt.", "100%", "10.0 / 10")
    )))

    [void]$sb.Append((New-WPageBreak))

    # 4. BẢNG KẾ HOẠCH LÀM VIỆC CHI TIẾT 15 TUẦN CỦA NHÓM (15 WEEKS WORK PLAN)
    [void]$sb.Append((New-WHeading1 "BẢNG KẾ HOẠCH LÀM VIỆC CHI TIẾT CỦA CÁC SINH VIÊN TRONG NHÓM (15 TUẦN)"))
    [void]$sb.Append((New-WP -Text "Kế hoạch triển khai đồ án của nhóm được lập chi tiết xuyên suốt 15 tuần học kỳ theo mô hình phát triển phần mềm lặp và tăng trưởng (Iterative & Incremental Development), đảm bảo mọi giai đoạn từ khảo sát, phân tích, thiết kế CSDL, lập trình Backend/Frontend đến kiểm thử và viết báo cáo đều hoàn thành đúng hạn 100%:" -IndentFirst 420))

    [void]$sb.Append((New-WTable -Headers @("Tuần", "Giai đoạn", "Nội dung công việc chi tiết thực hiện trong tuần", "Thành viên thực hiện", "Sản phẩm bàn giao & Tiêu chí nghiệm thu", "Tiến độ") -ColWidths @(750, 1350, 3600, 1300, 1800, 800) -Rows @(
        @("Tuần 01", "Khởi động dự án", "Họp nhóm, bầu nhóm trưởng, phân tích yêu cầu đề tài Chủ đề 2; xác định phạm vi tách biệt Admin Server, Người Quản lý CRM và Khách hàng; thiết lập kho lưu trữ mã nguồn Git.", "Cả nhóm (Tài chủ trì)", "Biên bản họp nhóm số 01, Đề cương chi tiết đề tài & Quy ước làm việc nhóm.", "100%"),
        @("Tuần 02", "Khảo sát DN", "Khảo sát thực tế mô hình hoạt động tại SGU Tech Corp: cơ cấu phòng ban, định biên nhân sự, danh mục 16 sản phẩm công nghệ và luồng xử lý thông tin hiện tại (AS-IS).", "Huỳnh Tuấn Tài,`nHoàng Thái Thanh", "Báo cáo Mục 1.1: Giới thiệu doanh nghiệp, Sơ đồ tổ chức & Ma trận RACI.", "100%"),
        @("Tuần 03", "Điều tra HTTT", "Thiết kế phiếu điều tra khảo sát hiện trạng HTTT gồm 25 câu hỏi chuyên sâu; tiến hành phát phiếu khảo sát cho 35 đối tượng (5 IT Admin, 10 CRM, 20 Khách hàng) và phỏng vấn trực tiếp.", "Hoàng Thái Thanh,`nNguyễn Đăng Khoa", "Bộ phiếu câu hỏi 25 câu, 35 phiếu trả lời hợp lệ & 03 Biên bản phỏng vấn sâu.", "100%"),
        @("Tuần 04", "Phân tích khảo sát", "Tổng hợp số liệu thống kê 35 phiếu khảo sát theo 5 nhóm tiêu chí; phân tích ma trận SWOT, đối sánh AS-IS vs. TO-BE; xác lập 20 quy tắc nghiệp vụ (BR-01..BR-20).", "Huỳnh Tuấn Tài,`nLê Nguyễn Phú Hải", "Báo cáo Mục 1.2 & Mục 2.1: Tổng kết khảo sát & Đặc tả quy tắc nghiệp vụ.", "100%"),
        @("Tuần 05", "Đặc tả Use Case & BFD", "Viết hồ sơ đặc tả chi tiết cho 15 quy trình nghiệp vụ cốt lõi (UC-01 đến UC-15); vẽ Sơ đồ Phân rã Chức năng (BFD) 3 nhánh độc lập và đặc tả 17 chức năng lá.", "Huỳnh Tuấn Tài,`nHoàng Thái Thanh", "Báo cáo Mục 2.1, Mục 2.2 & Hình vẽ sơ đồ bfd_diagram.png.", "100%"),
        @("Tuần 06", "Sơ đồ Ngữ cảnh", "Xây dựng Sơ đồ Ngữ cảnh (Context Diagram); đặc tả chi tiết 3 tác nhân ngoài (Admin Server, Quản lý CRM, Khách hàng) và cấu trúc 16 luồng dữ liệu vào/ra.", "Huỳnh Tuấn Tài,`nLê Nguyễn Phú Hải", "Báo cáo Mục 2.3 & Hình vẽ sơ đồ context_diagram.png.", "100%"),
        @("Tuần 07", "Sơ đồ DFD Mức 0 & 1", "Vẽ Sơ đồ Luồng dữ liệu Mức Đỉnh (Level 0 DFD) với 5 tiến trình (1.0–5.0) và 5 kho dữ liệu (D1–D5); phân rã 3 Sơ đồ DFD Mức 1 cho Admin, CRM, Khách hàng và lập ma trận CRUD.", "Huỳnh Tuấn Tài,`nHoàng Thái Thanh", "Báo cáo Mục 2.4 & Bộ 4 sơ đồ dfd_level0_diagram.png, dfd_level1_*.png.", "100%"),
        @("Tuần 08", "Thiết kế CSDL 3NF", "Ánh xạ 5 kho dữ liệu sang 9 bảng thực thể; chứng minh chuẩn hóa 1NF -> 2NF -> 3NF; vẽ Lược đồ ERD và biên soạn Từ điển dữ liệu (Data Dictionary) cho toàn bộ 9 bảng.", "Hoàng Thái Thanh,`nHuỳnh Tuấn Tài", "Báo cáo Mục 3.1 & Hình vẽ lược đồ erd_diagram.png.", "100%"),
        @("Tuần 09", "Cài đặt SQL & Backup", "Viết kịch bản khởi tạo CSDL SQL Server (HTTTDN_DB.sql) và lớp DbInitializer.cs; xây dựng phương án Sao lưu & Phục hồi CSDL 3 tầng (Full, Differential, Log Backup & Restore).", "Hoàng Thái Thanh", "Tệp Database/HTTTDN_DB.sql, DbInitializer.cs & Mục II.1, II.2 trong báo cáo.", "100%"),
        @("Tuần 10", "Xây dựng Backend API", "Khởi tạo dự án ASP.NET Core 8.0 (HTTTDN.AdminApi); lập trình AppDbContext, Models, DTOs và 21 RESTful API Endpoints trong AuthController, AccountsController, CrmAdminController, CustomerPortalController.", "Huỳnh Tuấn Tài,`nHoàng Thái Thanh,`nNguyễn Đăng Khoa", "Source code Backend biên dịch thành công 0 lỗi, kiểm thử Swagger UI trên cổng 5000.", "100%"),
        @("Tuần 11", "Giao diện Admin Server", "Thiết kế và lập trình Cổng Đăng nhập (login.html) và Giao diện Admin Server (admin.html, app.js) tách biệt hoàn toàn, chỉ giữ đúng 3 vai trò (Admin, Manager, Customer).", "Lê Nguyễn Phú Hải,`nHuỳnh Tuấn Tài", "Giao diện login.html và admin.html (2 tab Quản lý Account & Cơ cấu RBAC).", "100%"),
        @("Tuần 12", "Giao diện Quản lý CRM", "Thiết kế và lập trình Giao diện Người Quản lý CRM (quanly.html, manager_crm.js) với 5 tab nghiệp vụ: Hồ sơ KH, Tiếp nhận Phản hồi, Báo cáo Độ tuổi/Sở thích, Tạo Khảo sát, Thống kê Khảo sát.", "Lê Nguyễn Phú Hải", "Giao diện quanly.html tích hợp đầy đủ 6 biểu đồ thống kê trực quan.", "100%"),
        @("Tuần 13", "Giao diện Khách hàng", "Thiết kế và lập trình Cổng Khách hàng (user.html, user.js): Đăng ký tối giản, Đăng nhập, Chỉnh sửa hồ sơ cá nhân, Gửi phản hồi sản phẩm (kèm lọc theo SP), Nhận & làm khảo sát.", "Nguyễn Đăng Khoa,`nLê Nguyễn Phú Hải", "Giao diện user.html kết nối đồng bộ thời gian thực với Backend API.", "100%"),
        @("Tuần 14", "Kiểm thử & Dữ liệu Demo", "Nạp đầy đủ dữ liệu Demo (19 tài khoản, 15 khách hàng, 16 sản phẩm, 18 phản hồi, 5 khảo sát, 16 phiếu trả lời); thực thi 30 kịch bản kiểm thử (TC-01..TC-30).", "Nguyễn Đăng Khoa,`nHoàng Thái Thanh", "Báo cáo Kiểm thử 30 Test Cases đạt 100% PASS & Dữ liệu Demo hoàn chỉnh.", "100%"),
        @("Tuần 15", "Hoàn thiện Báo cáo", "Chụp hình ảnh thực tế toàn bộ 13 màn hình/tab của phần mềm; biên tập hoàn chỉnh Báo cáo Word (>115 trang), Báo cáo Markdown, readme.txt và đóng gói toàn bộ hồ sơ nộp bài.", "Cả nhóm (4 thành viên)", "Hồ sơ đồ án hoàn chỉnh: BAO_CAO_DO_AN_HTTTDN.docx, Source Code, SQL, readme.txt.", "100%")
    )))

    [void]$sb.Append((New-WPageBreak))

    # 5. MỤC LỤC CHI TIẾT & DANH MỤC HÌNH VẼ / BẢNG BIỂU
    [void]$sb.Append((New-WHeading1 "MỤC LỤC CHI TIẾT BÁO CÁO ĐỒ ÁN"))
    [void]$sb.Append((New-WTable -Headers @("Chương / Mục", "Tên Chương / Mục nội dung chi tiết trong Báo cáo", "Thang điểm") -ColWidths @(1600, 6600, 1400) -Rows @(
        @("MỞ ĐẦU", "Lời cảm ơn, Phiếu đối chiếu thang điểm, Bảng phân công nhiệm vụ & Kế hoạch làm việc 15 tuần", "Bắt buộc"),
        @("CHƯƠNG 1", "PHẦN CHUNG: GIỚI THIỆU VỀ DOANH NGHIỆP & KHẢO SÁT HỆ THỐNG THÔNG TIN", "10.0 điểm"),
        @("Mục 1.1", "Giới thiệu chung về Doanh nghiệp SGU Tech, các hoạt động nghiệp vụ, cơ cấu tổ chức, mô hình nhân sự & ma trận RACI", "5.0 điểm"),
        @("Mục 1.2", "Khảo sát HTTT của Doanh nghiệp: Bảng 25 câu hỏi điều tra khảo sát, 3 biên bản phỏng vấn, thống kê kết quả & kết luận", "5.0 điểm"),
        @("CHƯƠNG 2", "PHÂN TÍCH HỆ THỐNG THÔNG TIN CỦA DOANH NGHIỆP", "10.0 điểm"),
        @("Mục 2.1", "Bài toán mô tả chi tiết và đầy đủ cho các hoạt động của HTTT DN (20 Quy tắc nghiệp vụ & 15 Hồ sơ Use Case chi tiết)", "2.0 điểm"),
        @("Mục 2.2", "Sơ đồ Chức năng (Business Function Diagram – BFD) & Đặc tả chi tiết 17 chức năng nghiệp vụ lá", "2.0 điểm"),
        @("Mục 2.3", "Sơ đồ Ngữ cảnh (Context Diagram) & Đặc tả chi tiết 3 tác nhân ngoài cùng 16 luồng dữ liệu ngữ cảnh", "2.0 điểm"),
        @("Mục 2.4", "Sơ đồ Luồng dữ liệu Mức Đỉnh (Level 0 DFD), 3 Sơ đồ Phân rã Mức 1 (Admin, CRM, Customer) & Ma trận CRUD", "4.0 điểm"),
        @("CHƯƠNG 3", "THIẾT KẾ HỆ THỐNG THÔNG TIN TRONG HỆ THỐNG ĐỂ XÂY DỰNG PHẦN MỀM", "10.0 điểm"),
        @("Mục 3.1", "Thiết kế Cơ sở dữ liệu: Chuẩn hóa 3NF, Lược đồ ERD 9 bảng, Từ điển dữ liệu & Toàn bộ dữ liệu thực tế trong 9 bảng", "5.0 điểm"),
        @("Mục 3.2", "Thiết kế Giao diện: Hình ảnh thực tế 13 màn hình/tab, giới thiệu chi tiết các chức năng, bảng Controls & hoạt động phần mềm", "5.0 điểm"),
        @("CHƯƠNG 4", "CÀI ĐẶT VÀ BẢO TRÌ HTTT, PHƯƠNG ÁN CHUYỂN ĐỔI & TÀI LIỆU HƯỚNG DẪN SỬ DỤNG HỆ THỐNG", "5.0 điểm"),
        @("Mục 4.1 – 4.2", "Kiến trúc triển khai 3 tầng, quy trình cài đặt, phương án chuyển đổi hệ thống cũ sang mới & quy trình bảo trì SLA", "2.5 điểm"),
        @("Mục 4.3 – 4.4", "Tài liệu hướng dẫn sử dụng chi tiết theo 3 vai trò (Admin, Manager, Customer) & 30 Kịch bản kiểm thử (Test Cases)", "2.5 điểm"),
        @("CHƯƠNG 5", "TỔNG KẾT VÀ HƯỚNG PHÁT TRIỂN HỆ THỐNG TRONG TƯƠNG LAI", "5.0 điểm"),
        @("Mục 5.1 – 5.3", "Những kết quả đã làm được, đánh giá ưu nhược điểm của HTTT vừa xây dựng & định hướng nâng cấp hệ thống", "5.0 điểm"),
        @("PHẦN II", "XÂY DỰNG VÀ CÀI ĐẶT CƠ SỞ DỮ LIỆU & PHƯƠNG ÁN SAO LƯU, PHỤC HỒI CSDL", "30.0 điểm"),
        @("Mục II.1 – II.3", "Kịch bản cài đặt CSDL 9 bảng, Phương án Sao lưu & Phục hồi CSDL 3 tầng (Backup/Restore) & Chuẩn bị dữ liệu Demo", "30.0 điểm"),
        @("PHẦN III", "ĐẶC TẢ KIẾN TRÚC RESTFUL API & MÃ NGUỒN CÀI ĐẶT PHẦN MỀM THỰC TẾ", "30.0 điểm")
    )))

    [void]$sb.Append((New-WHeading2 "DANH MỤC 24 SƠ ĐỒ KỸ THUẬT VÀ HÌNH ẢNH GIAO DIỆN THỰC TẾ TRONG BÁO CÁO"))
    [void]$sb.Append((New-WTable -Headers @("Số hiệu Hình", "Tên Sơ đồ kỹ thuật / Hình ảnh chụp màn hình thực tế của đồ án", "Tệp hình ảnh gốc") -ColWidths @(1400, 5600, 2600) -Rows @(
        @("Hình 1.1", "Sơ đồ Cơ cấu Tổ chức và Mô hình Nhân sự Công ty Cổ phần Công nghệ SGU Tech", "org_chart_diagram.png"),
        @("Hình 2.1", "Sơ đồ Phân rã Chức năng (Business Function Diagram – BFD) của Hệ thống SGU Tech", "bfd_diagram.png"),
        @("Hình 2.2", "Sơ đồ Ngữ cảnh Hệ thống (System Context Diagram – Tiến trình 0.0 & 3 Tác nhân)", "context_diagram.png"),
        @("Hình 2.3", "Sơ đồ Luồng Dữ liệu Mức Đỉnh (Level 0 DFD – 5 Tiến trình & 5 Kho dữ liệu D1..D5)", "dfd_level0_diagram.png"),
        @("Hình 2.4", "Sơ đồ DFD Mức 1 — Phân rã Tiến trình 1.0: Phân hệ Quản trị Máy chủ (Admin Server)", "dfd_level1_admin.png"),
        @("Hình 2.5", "Sơ đồ DFD Mức 1 — Phân rã Nghiệp vụ Người Quản lý Quan hệ Khách hàng (CRM Manager)", "dfd_level1_crm.png"),
        @("Hình 2.6", "Sơ đồ DFD Mức 1 — Phân rã Nghiệp vụ Cổng Tương tác Khách hàng (Customer Portal)", "dfd_level1_customer.png"),
        @("Hình 3.1", "Lược đồ Quan hệ Thực thể Cơ sở Dữ liệu (ERD) 9 Bảng Chuẩn hóa 3NF", "erd_diagram.png"),
        @("Hình 3.2", "Giao diện Cổng Đăng nhập Nội bộ & Điều hướng Phân quyền Tự động (login.html)", "ui_guide_login.png"),
        @("Hình 3.3", "Giao diện Admin Server — Tab 1: Quản trị Tài khoản & 4 Chỉ số KPI Máy chủ (admin.html)", "ui_guide_admin.png"),
        @("Hình 3.4", "Giao diện Admin Server — Bảng Thao tác Phân quyền 3 Vai trò, Khóa & Xóa Account", "ui_admin_server.jpg"),
        @("Hình 3.5", "Giao diện Admin Server — Tab 2: Cơ cấu Phân quyền 3 Vai trò & Ma trận RBAC", "ui_admin_tab2_roles.png"),
        @("Hình 3.6", "Giao diện Người Quản lý CRM — Tab 1: Quản lý Hồ sơ Khách hàng (Thêm, Xóa, Khóa TK)", "ui_crm_tab1_customers.png"),
        @("Hình 3.7", "Giao diện Người Quản lý CRM — Tab 2: Tiếp nhận & Giải đáp Phản hồi kèm Biểu đồ Sao", "ui_crm_tab2_feedbacks.png"),
        @("Hình 3.8", "Giao diện Người Quản lý CRM — Tab 3: Báo cáo Tỷ lệ Độ tuổi & Sở thích Khách hàng", "ui_crm_tab3_demographics.png"),
        @("Hình 3.9", "Giao diện Người Quản lý CRM — Tab 4: Tạo & Phát hành Bảng Khảo sát gửi đến TK Khách hàng", "ui_crm_tab4_surveys.png"),
        @("Hình 3.10", "Giao diện Người Quản lý CRM — Tab 5: Thống kê & Đo lường Kết quả Khảo sát", "ui_crm_tab5_surveystats.png"),
        @("Hình 3.11", "Giao diện Cổng Khách hàng — Biểu mẫu Đăng ký Tài khoản Khách hàng mới (user.html)", "ui_customer_register.png"),
        @("Hình 3.12", "Giao diện Cổng Khách hàng — Màn hình Đăng nhập Tài khoản Khách hàng (user.html)", "ui_guide_cust_login.png"),
        @("Hình 3.13", "Giao diện Cổng Khách hàng — Tab 1: Gửi Phản hồi về Sản phẩm & Xem Giải đáp từ Quản lý", "ui_customer_feedback.jpg"),
        @("Hình 3.14", "Giao diện Cổng Khách hàng — Bộ lọc Xem Đánh giá & Phản hồi theo từng Sản phẩm", "ui_guide_user_full.png"),
        @("Hình 3.15", "Giao diện Cổng Khách hàng — Tab 2: Nhận được Khảo sát trong Tài khoản & Thực hiện", "ui_customer_survey.jpg"),
        @("Hình 3.16", "Giao diện Cổng Khách hàng — Tab 3: Chỉnh sửa Thông tin Hồ sơ Cá nhân Khách hàng", "ui_customer_profile.jpg"),
        @("Hình 4.1", "Sơ đồ Kiến trúc Triển khai Hệ thống 3 Tầng (Presentation – Business API – SQL Server)", "system_architecture_diagram.png")
    )))

    [void]$sb.Append((New-WPageBreak))
    return $sb.ToString()
}
