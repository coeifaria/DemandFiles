# Change the current directory to the 'data' folder, one level up from 'LMA Data'
#Set-Location -Path (Join-Path (Get-Location) "..\data")

$xlsFiles = Get-ChildItem -Path . -Filter '*.xls' -File

if ($xlsFiles.Count -eq 0) {
    Write-Host "No .xls files found. Exiting."
    exit 0
}

$excel = New-Object -ComObject Excel.Application
$excel.Visible        = $false
$excel.DisplayAlerts = $false

foreach ($file in $xlsFiles) {
    $inputPath  = $file.FullName
    # The outputPath will now correctly point to the current directory (which is /data)
    $outputPath = Join-Path $file.DirectoryName ($file.BaseName + '.xlsx')

    Write-Host "Converting:`n  $inputPath`nto`n  $outputPath"

    $wb = $excel.Workbooks.Open($inputPath)
    $wb.SaveAs($outputPath, 51)

    $wb.Close($false)
}

$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null

Write-Host "Done converting $($xlsFiles.Count) file(s)."