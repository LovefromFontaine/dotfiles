# Unlock-UWP: Enable loopback exemption for UWP apps
function Unlock-UWP ($AppName) {
    $packages = Get-AppxPackage *$AppName*
    
    if ($packages) {
        $packages | ForEach-Object {
            CheckNetIsolation.exe LoopbackExempt -a -n="$($_.PackageFamilyName)"
          
            Write-Host "[OK] Unlocked: $($_.Name)" -ForegroundColor Green
        }
    } else {
       
        Write-Host "[Error] App '$AppName' not found." -ForegroundColor Red
    }
}