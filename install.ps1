# ==============================================================================
# Dotfiles Installation Script (install.ps1)
# Function: Establish profile links and initialize system tasks
# ==============================================================================


# ==========================================================
# Part 0: Environment & Package Manager Setup (Scoop)
# ==========================================================
# --- Configuration Variables ---
$targetProfile = $PROFILE
$repoProfile = Join-Path $PSScriptRoot "powershell\Microsoft.PowerShell_profile.ps1"

Write-Host "Starting dotfiles environment configuration..." -ForegroundColor Cyan


Write-Host "`n[0/3] Initializing Package Manager and Prerequisites..." -ForegroundColor Magenta

# 增强版环境刷新函数：处理变量展开，确保 Scoop 路径立即可用
function Refresh-Environment {
    Write-Host "[INFO] Refreshing environment variables..." -ForegroundColor Gray
    $rawMachinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $rawUserPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    # 展开 %LocalAppData% 等变量，防止路径无法识别
    $env:Path = [System.Environment]::ExpandEnvironmentVariables("$rawMachinePath;$rawUserPath")
}

# 1. 检查并安装 Scoop
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "[INFO] Scoop not found. Installing Scoop..." -ForegroundColor Yellow
    
    # 设置执行策略以允许脚本运行
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    
    # 下载并执行 Scoop 安装脚本
    try {
        Invoke-RestMethod -Uri get.scoop.sh | Invoke-Expression
        Refresh-Environment
        Write-Host "[OK] Scoop installed successfully." -ForegroundColor Green
    } catch {
        Write-Error "Failed to install Scoop. Please check your network connection."
        exit 1
    }
} else {
    Write-Host "[SKIP] Scoop is already installed." -ForegroundColor Gray
}

# 2. 使用 Scoop 安装 gsudo (替代 winget)
if (!(Get-Command gsudo -ErrorAction SilentlyContinue)) {
    Write-Host "[INFO] gsudo not found. Installing via Scoop..." -ForegroundColor Yellow
    
    # 首先添加 extras bucket (gsudo 在这里)
    scoop bucket add extras | Out-Null
    
    scoop install gsudo
    
    if ($LASTEXITCODE -eq 0) {
        Refresh-Environment
        Write-Host "[OK] gsudo installed via Scoop." -ForegroundColor Green
    } else {
        Write-Error "Failed to install gsudo via Scoop."
        exit 1
    }
}



# 3. 检查 PowerShell 版本 (作为学生和程序员，强烈建议用 PS7)
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "[INFO] Modern PowerShell (v7+) not detected." -ForegroundColor Yellow
    # 如果你想全自动升级，可以取消下面这行的注释
    # scoop install powershell
}


# --- Part 1: Symbolic Link Management ---
Write-Host "`n[1/3] Checking PowerShell Profile link status..." -ForegroundColor Magenta

# Ensure the parent directory exists
$profileDir = Split-Path $targetProfile
if (!(Test-Path $profileDir)) { 
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

if (Test-Path $targetProfile) {
    $item = Get-Item $targetProfile
    
    # CASE A: Already a symbolic link pointing to the correct repo file
    if ($item.LinkType -eq "SymbolicLink" -and $item.Target -eq $repoProfile) {
        Write-Host "[SKIP] Profile is already correctly linked to this repository." -ForegroundColor Gray
    } 
    # CASE B: Exists but is an old link, a different link, or a regular file
    else {
        $itemType = if ($item.LinkType -eq "SymbolicLink") { "existing symbolic link" } else { "regular file" }
        Write-Host "[UPDATE] Found $itemType. Backing up and replacing..." -ForegroundColor Yellow
        
        # Backup: Append a precise timestamp to prevent overwriting previous backups
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupPath = "$targetProfile.$timestamp.bak"
        Move-Item $targetProfile $backupPath -Force
        
        New-Item -ItemType SymbolicLink -Path $targetProfile -Value $repoProfile -Force | Out-Null
        Write-Host "[OK] Link updated. Old config backed up to: $(Split-Path $backupPath -Leaf)" -ForegroundColor Green
    }
} else {
    # CASE C: Target path does not exist at all
    New-Item -ItemType SymbolicLink -Path $targetProfile -Value $repoProfile -Force | Out-Null
    Write-Host "[OK] Created new Profile symbolic link." -ForegroundColor Green
}

# --- Part 2: Load Environment (Dot Sourcing) ---
Write-Host "`n[2/3] Loading repository configuration functions..." -ForegroundColor Magenta
if (Test-Path $repoProfile) {
    # Load the profile to make "Unlock-UWP" available in the current session
    . $repoProfile
    Write-Host "[OK] Functions loaded successfully." -ForegroundColor Green
} else {
    Write-Error "Could not find profile in repository: $repoProfile"
    exit
}

# --- Part 3: Initialization Tasks ---
Write-Host "`n[3/3] Running UWP Network Exemption tasks..." -ForegroundColor Magenta

$AppsToUnlock = @(
    "WindowsStore", 
    "YourPhone", 
    "CloudExperienceHost", 
    "AAD.BrokerPlugin"
)

foreach ($app in $AppsToUnlock) {
    # Calling the function defined in your Functions.ps1
    Unlock-UWP -AppName $app 
}

Write-Host "`nAll configurations applied! Please restart PowerShell." -ForegroundColor Cyan