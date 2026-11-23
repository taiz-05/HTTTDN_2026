$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

$docxPath = "d:\HTTTDN_2026\Report\BAO_CAO_DO_AN_HTTTDN.docx"
$mdPath   = "d:\HTTTDN_2026\Report\BAO_CAO_DO_AN_HTTTDN.md"

$fs = [System.IO.File]::Open($docxPath, 'Open', 'Read', 'ReadWrite')
$zip = New-Object System.IO.Compression.ZipArchive($fs, 'Read')

$relsEntry = $zip.GetEntry("word/_rels/document.xml.rels")
$relsReader = New-Object System.IO.StreamReader($relsEntry.Open())
$relsXml = [xml]$relsReader.ReadToEnd()
$relsReader.Close()

$relMap = @{}
foreach ($rel in $relsXml.Relationships.Relationship) {
    $relMap[$rel.Id] = $rel.Target
}

$docEntry = $zip.GetEntry("word/document.xml")
$docReader = New-Object System.IO.StreamReader($docEntry.Open())
$docXml = [xml]$docReader.ReadToEnd()
$docReader.Close()
$zip.Dispose()
$fs.Close()

$ns = New-Object System.Xml.XmlNamespaceManager($docXml.NameTable)
$ns.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
$ns.AddNamespace("a", "http://schemas.openxmlformats.org/drawingml/2006/main")
$ns.AddNamespace("r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships")

$sb = New-Object System.Text.StringBuilder
$body = $docXml.SelectSingleNode("//w:body", $ns)

foreach ($node in $body.ChildNodes) {
    if ($node.LocalName -eq "p") {
        $blip = $node.SelectSingleNode(".//a:blip", $ns)
        if ($null -ne $blip) {
            $embedId = $blip.GetAttribute("embed", "http://schemas.openxmlformats.org/officeDocument/2006/relationships")
            if ($relMap.ContainsKey($embedId)) {
                $imgFile = [System.IO.Path]::GetFileName($relMap[$embedId])
                [void]$sb.AppendLine("![Hình minh họa](images/$imgFile)")
                [void]$sb.AppendLine()
            }
            continue
        }

        $textNodes = $node.SelectNodes(".//w:t", $ns)
        $lineText = ""
        foreach ($tn in $textNodes) {
            $lineText += $tn.InnerText
        }
        $lineText = $lineText.Trim()
        if ([string]::IsNullOrWhiteSpace($lineText)) {
            continue
        }

        $szNode = $node.SelectSingleNode(".//w:sz", $ns)
        $szVal = if ($null -ne $szNode) { [int]$szNode.GetAttribute("val", "http://schemas.openxmlformats.org/wordprocessingml/2006/main") } else { 24 }
        $fontNode = $node.SelectSingleNode(".//w:rFonts", $ns)
        $fontVal = if ($null -ne $fontNode) { $fontNode.GetAttribute("ascii", "http://schemas.openxmlformats.org/wordprocessingml/2006/main") } else { "Times New Roman" }

        if ($fontVal -eq "Consolas") {
            [void]$sb.AppendLine("    " + $lineText)
        }
        elseif ($szVal -ge 30) {
            [void]$sb.AppendLine("# " + $lineText)
            [void]$sb.AppendLine()
        }
        elseif ($szVal -eq 28) {
            [void]$sb.AppendLine("## " + $lineText)
            [void]$sb.AppendLine()
        }
        elseif ($szVal -eq 26) {
            [void]$sb.AppendLine("### " + $lineText)
            [void]$sb.AppendLine()
        }
        else {
            [void]$sb.AppendLine($lineText)
            [void]$sb.AppendLine()
        }
    }
    elseif ($node.LocalName -eq "tbl") {
        $rows = $node.SelectNodes("./w:tr", $ns)
        $rIdx = 0
        foreach ($tr in $rows) {
            $cells = $tr.SelectNodes("./w:tc", $ns)
            $cellTexts = @()
            foreach ($tc in $cells) {
                $tNodes = $tc.SelectNodes(".//w:t", $ns)
                $cText = ""
                foreach ($tn in $tNodes) { $cText += $tn.InnerText + " " }
                $cText = ($cText -replace '\|', '/' -replace '\r?\n', ' ').Trim()
                $cellTexts += $cText
            }
            [void]$sb.AppendLine("| " + ($cellTexts -join " | ") + " |")
            if ($rIdx -eq 0) {
                $sep = @()
                for ($i = 0; $i -lt $cellTexts.Count; $i++) { $sep += "---" }
                [void]$sb.AppendLine("| " + ($sep -join " | ") + " |")
            }
            $rIdx++
        }
        [void]$sb.AppendLine()
    }
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($mdPath, $sb.ToString(), $utf8NoBom)
Write-Host "Synchronized Markdown report at: $mdPath ($((Get-Item $mdPath).Length) bytes)"
