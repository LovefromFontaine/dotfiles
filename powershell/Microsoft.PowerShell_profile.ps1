
# ==========================================================
# [Phase 0] Encoding Fix: 强制 UTF-8 环境
# ==========================================================
# 解决中文用户名路径乱码的关键
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ==========================================================
# [Phase 1] 解析真实路径 (解决软链接路径偏移问题)
# ==========================================================
$currentPath = $MyInvocation.MyCommand.Path
$item = Get-Item $currentPath

# 如果是符号链接，则获取它的 Target（真实路径）；否则使用原始路径
if ($item.LinkType -eq "SymbolicLink") {
    $realProfilePath = $item.Target
} else {
    $realProfilePath = $currentPath
}

# 现在的 $ConfigDir 指向的就是你 D:\dotfiles\powershell 目录了
$ConfigDir = Split-Path -Parent $realProfilePath

# ==========================================================
# [Phase 2] 引入基础配置 (Aliases, Functions)
# ==========================================================

. (Join-Path $ConfigDir "Aliases.ps1")
. (Join-Path $ConfigDir "Functions.ps1")

# ==========================================================
# [Phase 3] 增强初始化 (增加路径容错)
# ==========================================================

# 1. 初始化 Oh My Posh
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    # 使用 --print 参数直接输出脚本内容，避免生成带中文路径的临时文件
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Out-String | Invoke-Expression
}

# 2. 初始化 Zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    $zoxideInit = zoxide init powershell
    if ($zoxideInit) {
        $zoxideInit | Invoke-Expression
    }
}

Write-Host "PowerShell Profile Loaded Successfully!" -ForegroundColor Cyan