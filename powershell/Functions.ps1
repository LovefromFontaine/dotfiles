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
        [Parameter(Mandatory=$true)][string]$AppName,
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

# Refresh-Environment: Refresh environment variables, expanding any embedded variables
function Refresh-Environment {
    Write-Host "[INFO] Refreshing environment variables..." -ForegroundColor Gray
    $rawMachinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $rawUserPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    # 展开 %LocalAppData% 等变量，防止路径无法识别
    $env:Path = [System.Environment]::ExpandEnvironmentVariables("$rawMachinePath;$rawUserPath")
}