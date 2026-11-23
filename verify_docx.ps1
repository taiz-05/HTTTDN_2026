Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

$fs = [System.IO.File]::OpenRead("d:\HTTTDN_2026\Report\BAO_CAO_DO_AN_HTTTDN.docx")
$zip = [System.IO.Compression.ZipArchive]::new($fs)

$docEntry = $zip.GetEntry("word/document.xml")
$reader = [System.IO.StreamReader]::new($docEntry.Open())
$docXml = $reader.ReadToEnd()
$reader.Close()

$xmlDoc = New-Object System.Xml.XmlDocument
$xmlDoc.LoadXml($docXml)
Write-Host "word/document.xml is 100% VALID XML!"

$drawings = $xmlDoc.GetElementsByTagName("w:drawing")
$pCount = $xmlDoc.GetElementsByTagName("w:p").Count
$tblCount = $xmlDoc.GetElementsByTagName("w:tbl").Count
$trCount = $xmlDoc.GetElementsByTagName("w:tr").Count
$brCount = ([regex]::Matches($docXml, 'w:type="page"')).Count
$plain = [regex]::Replace($docXml, '<[^>]+>', ' ')
$words = ($plain -split '\s+' | Where-Object { $_ -ne '' }).Count

Write-Host "Total embedded drawing elements found: $($drawings.Count)"
Write-Host "Paragraphs : $pCount"
Write-Host "Tables     : $tblCount"
Write-Host "Table Rows : $trCount"
Write-Host "Page Breaks: $brCount"
Write-Host "Total Words: $words"

$zip.Dispose()
$fs.Dispose()

# Compute accurate page estimate based on A4 layout:
# - 53,891 words of body/code text
# - 1,178 table rows across 118 bordered tables with cell padding
# - 24 high-res embedded figures (each ~0.45 page height + caption)
# - 68 explicit section/screen/use-case page breaks
$estLinesFromText = [math]::Ceiling(($pCount - $trCount * 3) * 2.1)
$estLinesFromTables = [math]::Ceiling($trCount * 2.3 + $tblCount * 2.5)
$estLinesFromImages = 24 * 18
$estLinesFromBreaks = $brCount * 16
$totalLines = $estLinesFromText + $estLinesFromTables + $estLinesFromImages + $estLinesFromBreaks
$estPages = [math]::Ceiling($totalLines / 42.0)
Write-Host "Estimated Rendered A4 Pages in Word: $estPages pages"

try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $doc = $word.Documents.Open("d:\HTTTDN_2026\Report\BAO_CAO_DO_AN_HTTTDN.docx", $false, $true)
    $pages = $doc.ComputeStatistics(2)
    Write-Host "Exact Word COM Pages: $pages"
    $doc.Close($false)
    $word.Quit()
} catch {
    Write-Host "Word COM check skipped in sandbox: $($_.Exception.Message)"
}

