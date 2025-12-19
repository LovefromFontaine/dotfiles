# My Dotfiles

A modular PowerShell-based dotfiles environment.

## Directory Structure

```text
dotfiles/
├── .gitignore
├── README.md
├── install.ps1           # Installation entry point
├── bin/                  # Compiled tools and binaries
├── configs/              # Software configurations
│   ├── git/
│   ├── nvim/
│   └── vscode/
├── modules/              # External git modules
├── powershell/           # Core PowerShell settings
│   ├── Aliases.ps1       # Command aliases
│   ├── Functions.ps1     # Custom functions (e.g., Unlock-UWP)
│   └── Microsoft.PowerShell_profile.ps1 # Profile entry
└── scripts/              # Script categories
    ├── backup/
    ├── utils/
    └── vpn/              # VPN and Proxy scripts (Clash JS)
```