# Usage: .\demo-loop.ps1 http://127.0.0.1:PORT
param([Parameter(Mandatory)][string]$Url)

while ($true) {
    $t = Get-Date -Format HH:mm:ss
    try {
        $r = Invoke-RestMethod "$Url/version" -TimeoutSec 2
        Write-Host "$t  version=$($r.version)  pod=$($r.pod)"
    } catch {
        Write-Host "$t  FAILED" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 500
}
