[CmdLetBinding()]
param(
    [parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $startingUrl,

    [parameter(Mandatory = $false)]
    [int]
    $levels = 10

)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function RecurGetLinks {

    param($url, $lev)
    if($lev -gt 0) {
        $response = (Invoke-WebRequest -Uri $url)
        $links = $response.Links | Select-Object -ExpandProperty href
        Write-verbose "Found $($links.Count) links"
        $links = $links | Where-Object { $_ -and $_.href -and `
            (-not ($_.href.StartsWith("http") -or $_.href.StartsWith("/")))}

        $links = $links | Select-Object -ExpandProperty href -Unique
        Write-Verbose $links
        $links # yields all first level links first

        $links | ForEach-Object {
            RecurGetLinks $_ ($lev - 1)
        } 
    }
}

RecurGetLinks $startingUrl levels