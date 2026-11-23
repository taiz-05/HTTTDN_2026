$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$BuilderDir = "d:\HTTTDN_2026\report_builder"
$OutputPath = "d:\HTTTDN_2026\Report\BAO_CAO_DO_AN_HTTTDN.docx"
$ImageDir   = "d:\HTTTDN_2026\Report\images"

# Load all modular chapter builders
. "$BuilderDir\part0_helpers_and_cover.ps1"
. "$BuilderDir\part1_chapter1_enterprise_survey.ps1"
. "$BuilderDir\part2_chapter2_analysis_usecases.ps1"
. "$BuilderDir\part3_chapter2_bfd_context_dfd.ps1"
. "$BuilderDir\part4_chapter3_database_design.ps1"
. "$BuilderDir\part5_chapter3_ui_design.ps1"
. "$BuilderDir\part6_chapter4_5_and_part2_sql_api.ps1"
. "$BuilderDir\part7_deep_specifications_and_source_walkthrough.ps1"
. "$BuilderDir\part8_ultra_detailed_rubric_sections.ps1"
. "$BuilderDir\part9_deep_ui_and_testcase_specifications.ps1"
. "$BuilderDir\part10_deep_screen_by_screen_and_db_specifications.ps1"

$body = New-Object System.Text.StringBuilder

# 1. Trang bìa, Lời cảm ơn, Phiếu đối chiếu thang điểm, Phân công nhiệm vụ & Kế hoạch 15 tuần
[void]$body.Append((Build-Part0-CoverAndFrontMatter))

# 2. CHƯƠNG 1: Giới thiệu Doanh nghiệp & Khảo sát HTTT (10 điểm)
[void]$body.Append((Build-Part1-Chapter1))
[void]$body.Append((Build-Chapter1-DeepSurveyAnalysis))

# 3. CHƯƠNG 2: Phân tích HTTT của Doanh nghiệp (10 điểm — Phần mấu chốt #1)
[void]$body.Append((Build-Part2-Chapter2-UseCases))
[void]$body.Append((Build-Chapter2-DeepSequenceFlows))
[void]$body.Append((Build-Part3-Chapter2-Diagrams))
[void]$body.Append((Build-Chapter2-DeepBFDAndDataDictionary))
[void]$body.Append((Build-Chapter2-DeepProcessMiniSpecs))

# 4. CHƯƠNG 3: Thiết kế HTTT — Thiết kế CSDL & Thiết kế Giao diện (10 điểm — Phần mấu chốt #2)
[void]$body.Append((Build-Part4-Chapter3-Database))
[void]$body.Append((Build-Chapter3-DeepSqlAndUiWalkthrough))
[void]$body.Append((Build-Chapter3-DeepIntegrityConstraints))
[void]$body.Append((Build-Chapter3-DeepStorageAndValidation))
[void]$body.Append((Build-Part5-Chapter3-UI))
[void]$body.Append((Build-Chapter3-DeepUiFlows))
[void]$body.Append((Build-Chapter3-DeepFunctionalWalkthrough))

# 5. CHƯƠNG 4, CHƯƠNG 5, PHẦN II (Cài đặt CSDL & Backup/Restore) & PHẦN III (RESTful API & Source Code)
[void]$body.Append((Build-Part6-Chapters4ToPart3))
[void]$body.Append((Build-Chapter4-DeepTestExecutionLogs))
[void]$body.Append((Build-Part3-DeepControllersAndFrontendCode))
[void]$body.Append((Build-Part3-DeepModelsAndDtosCode))

# Section Properties (Chuẩn khổ giấy A4, lề chuẩn báo cáo đại học)
$sectPr = @"
<w:sectPr>
    <w:pgSz w:w="11906" w:h="16838"/>
    <w:pgMar w:top="1440" w:right="1134" w:bottom="1440" w:left="1700" w:header="720" w:footer="720" w:gutter="0"/>
</w:sectPr>
"@

$documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
            xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
            xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
            xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
            xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
    <w:body>
        $($body.ToString())
        $sectPr
    </w:body>
</w:document>
"@

$contentTypes = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
    <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
    <Default Extension="xml" ContentType="application/xml"/>
    <Default Extension="png" ContentType="image/png"/>
    <Default Extension="jpg" ContentType="image/jpeg"/>
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

$docRels = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
    <Relationship Id="rIdStyles" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
    <Relationship Id="rIdImg1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/org_chart_diagram.png"/>
    <Relationship Id="rIdImg2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/bfd_diagram.png"/>
    <Relationship Id="rIdImg3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/context_diagram.png"/>
    <Relationship Id="rIdImg4" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/dfd_level0_diagram.png"/>
    <Relationship Id="rIdImg5" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/dfd_level1_admin.png"/>
    <Relationship Id="rIdImg6" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/dfd_level1_crm.png"/>
    <Relationship Id="rIdImg7" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/dfd_level1_customer.png"/>
    <Relationship Id="rIdImg8" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/erd_diagram.png"/>
    <Relationship Id="rIdImg9" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/system_architecture_diagram.png"/>
    <Relationship Id="rIdImg10" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_guide_login.png"/>
    <Relationship Id="rIdImg11" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_guide_admin.png"/>
    <Relationship Id="rIdImg12" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_admin_server.jpg"/>
    <Relationship Id="rIdImg13" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_admin_tab2_roles.png"/>
    <Relationship Id="rIdImg14" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_crm_tab1_customers.png"/>
    <Relationship Id="rIdImg15" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_crm_tab2_feedbacks.png"/>
    <Relationship Id="rIdImg16" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_crm_tab3_demographics.png"/>
    <Relationship Id="rIdImg17" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_crm_tab4_surveys.png"/>
    <Relationship Id="rIdImg18" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_crm_tab5_surveystats.png"/>
    <Relationship Id="rIdImg19" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_guide_user_full.png"/>
    <Relationship Id="rIdImg20" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_customer_register.png"/>
    <Relationship Id="rIdImg21" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_guide_cust_login.png"/>
    <Relationship Id="rIdImg22" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_customer_feedback.jpg"/>
    <Relationship Id="rIdImg23" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_customer_survey.jpg"/>
    <Relationship Id="rIdImg24" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ui_customer_profile.jpg"/>
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
            </w:rPr>
        </w:rPrDefault>
    </w:docDefaults>
</w:styles>
"@

if (Test-Path $OutputPath) {
    Remove-Item $OutputPath -Force
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$fs = New-Object System.IO.FileStream($OutputPath, [System.IO.FileMode]::Create)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)

function Add-ZipTextEntry($archive, [string]$entryPath, [string]$textContent, $encoding) {
    $entry = $archive.CreateEntry($entryPath, [System.IO.Compression.CompressionLevel]::Optimal)
    $stream = $entry.Open()
    $bytes = $encoding.GetBytes($textContent)
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Close()
}

function Add-ZipBinaryEntry($archive, [string]$entryPath, [string]$filePath) {
    if (Test-Path $filePath) {
        $entry = $archive.CreateEntry($entryPath, [System.IO.Compression.CompressionLevel]::Optimal)
        $stream = $entry.Open()
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $stream.Write($bytes, 0, $bytes.Length)
        $stream.Close()
    } else {
        Write-Warning "File not found: $filePath"
    }
}

Add-ZipTextEntry $zip "[Content_Types].xml" $contentTypes $utf8NoBom
Add-ZipTextEntry $zip "_rels/.rels" $rels $utf8NoBom
Add-ZipTextEntry $zip "word/_rels/document.xml.rels" $docRels $utf8NoBom
Add-ZipTextEntry $zip "word/styles.xml" $stylesXml $utf8NoBom
Add-ZipTextEntry $zip "word/document.xml" $documentXml $utf8NoBom

$mediaFiles = @(
    "org_chart_diagram.png",
    "bfd_diagram.png",
    "context_diagram.png",
    "dfd_level0_diagram.png",
    "dfd_level1_admin.png",
    "dfd_level1_crm.png",
    "dfd_level1_customer.png",
    "erd_diagram.png",
    "system_architecture_diagram.png",
    "ui_guide_login.png",
    "ui_guide_admin.png",
    "ui_admin_server.jpg",
    "ui_admin_tab2_roles.png",
    "ui_crm_tab1_customers.png",
    "ui_crm_tab2_feedbacks.png",
    "ui_crm_tab3_demographics.png",
    "ui_crm_tab4_surveys.png",
    "ui_crm_tab5_surveystats.png",
    "ui_guide_user_full.png",
    "ui_customer_register.png",
    "ui_guide_cust_login.png",
    "ui_customer_feedback.jpg",
    "ui_customer_survey.jpg",
    "ui_customer_profile.jpg"
)

foreach ($mf in $mediaFiles) {
    Add-ZipBinaryEntry $zip "word/media/$mf" (Join-Path $ImageDir $mf)
}

$zip.Dispose()
$fs.Close()

Write-Host "SUCCESS! Generated Word document at: $OutputPath"
Write-Host "File size: $((Get-Item $OutputPath).Length) bytes"
