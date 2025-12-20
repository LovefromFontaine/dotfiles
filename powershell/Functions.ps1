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

# Install-ScoopApp: Idempotently install a Scoop application, optionally adding a bucket
function Install-ScoopApp {
    param(
        [Parameter(Required=$true)][string]$AppName,
        [string]$Bucket = ""
    )
    # 检查 Bucket
    if ($Bucket) {
        $existingBuckets = scoop bucket list
        if (!($existingBuckets -match $Bucket)) {
            Write-Host "[INFO] Adding Scoop bucket: $Bucket" -ForegroundColor Cyan
            scoop bucket add $Bucket
        }
    }
    # 幂等安装逻辑
    if (!(Get-Command $AppName -ErrorAction SilentlyContinue)) {
        Write-Host "[INSTALL] $AppName not found. Installing..." -ForegroundColor Yellow
        scoop install $AppName
    } else {
        Write-Host "[SKIP] $AppName is already installed." -ForegroundColor Gray
    }
}