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
Write-Host "Total embedded drawing elements found: $($drawings.Count)"

$zip.Dispose()
$fs.Dispose()

