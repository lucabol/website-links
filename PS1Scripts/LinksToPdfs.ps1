param($linksFile)
$links = Get-Content $linksFile
$links = $links | Select-Object -Unique
$digits = 0
$links | ForEach-Object {
    $dig = '{0:d4}' -f [int]$digits
    $option = [System.StringSplitOptions]::RemoveEmptyEntries
    $pdfName = "$PSScriptRoot/" + $dig + "-" + $_.Split('/', $option)[-1].Split(".")[-2] + ".pdf"
    $urlFile = $_
    $chrome = "C:\Program Files (x86)\Google\Chrome\Application\Chrome.exe"
    Start-Process -FilePath $chrome -ArgumentList $urlFile, "--enable-logging", "--headless","--run-all-compositor-stages-before-draw", "--disable-gpu","--print-to-pdf=$pdfName"
    Start-Sleep -Seconds 10
    $digits += 1
}