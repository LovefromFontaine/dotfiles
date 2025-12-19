# In dotfiles/powershell/Aliases.ps1
# 直接强制定义，别名优先级高于环境变量中的 .exe
Set-Alias -Name sudo -Value gsudo -Force -ErrorAction SilentlyContinue