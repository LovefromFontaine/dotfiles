# In dotfiles/powershell/Aliases.ps1
if (Get-Command gsudo -ErrorAction SilentlyContinue) {
    Set-Alias -Name sudo -Value gsudo
}