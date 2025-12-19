# 获取当前配置文件所在的真实目录
$ConfigDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 1. 引入别名 (用绝对路径，并强制全局作用域)
$AliasFile = Join-Path $ConfigDir "Aliases.ps1"
if (Test-Path $AliasFile) {
    . $AliasFile
}

# 2. 引入函数
$FunctionsFile = Join-Path $ConfigDir "Functions.ps1"
if (Test-Path $FunctionsFile) {
    . $FunctionsFile
}

Write-Host "PowerShell Profile Loaded!" -ForegroundColor Cyan