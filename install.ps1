# ==============================================================================
# Dotfiles Installation Script (install.ps1)
# Function: Establish profile links and initialize system tasks
# ==============================================================================


# ==========================================================
# [Phase 0] Bootstrapping: 路径与环境基础
# ==========================================================

# 检查管理员权限，如果没有则尝试提权运行
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[INFO] Requesting administrative privileges..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 定义路径变量
$targetProfile = $PROFILE
$repoProfile = Join-Path $PSScriptRoot "powershell\Microsoft.PowerShell_profile.ps1"
$functionsPath = Join-Path $PSScriptRoot "powershell\Functions.ps1"

Write-Host "Starting dotfiles environment configuration..." -ForegroundColor Cyan


Write-Host "`n[0/4] Initializing Package Manager and Prerequisites..." -ForegroundColor Magenta

# load functions from the repository profile
if (Test-Path $functionsPath) {
    # Load the profile to make functions available
    . $functionsPath
    Write-Host "[OK] Functions loaded successfully." -ForegroundColor Green
} else {
    Write-Error "Could not find profile in repository: $functionsPath"
    exit
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

# 2. 检查 PowerShell 版本 (作为学生和程序员，强烈建议用 PS7)
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "[INFO] Modern PowerShell (v7+) not detected." -ForegroundColor Yellow
    # 如果你想全自动升级，可以取消下面这行的注释
    # scoop install powershell
}


# ==========================================================
# [Phase 1] Tooling: 使用 Install-ScoopApp 幂等安装
# ==========================================================
Write-Host "`n[1/4] Installing Tooling..." -ForegroundColor Magenta

# 现在你可以愉快地调用函数了！
Install-ScoopApp -AppName "gsudo" -Bucket "extras"
Install-ScoopApp -AppName "git"
Install-ScoopApp -AppName "oh-my-posh"
Install-ScoopApp -AppName "zoxide"
Install-ScoopApp -AppName "JetBrainsMono-NF" -Bucket "nerd-fonts"

# 别忘了更新当前会话的路径
Refresh-Environment

# ==========================================================
# [Phase 2] Symlinks: 建立符号链接
# ==========================================================
Write-Host "`n[2/4] Checking PowerShell Profile link status..." -ForegroundColor Magenta

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


# ==========================================================
# [Phase 3] Post-Install: 初始化任务
# ==========================================================
Write-Host "`n[3/4] Running UWP Network Exemption tasks..." -ForegroundColor Magenta

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

