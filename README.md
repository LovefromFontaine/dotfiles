dotfiles/
├── .gitignore
├── README.md
├── install.ps1           # 安装入口
├── bin/                  # 放编译好的小工具
├── configs/              # 放软件配置
│   ├── git/
│   ├── nvim/
│   └── vscode/
├── modules/              # 外部模块
├── powershell/           # PowerShell 核心
│   ├── Aliases.ps1       # 别名（如：ls -> eza）
│   ├── Functions.ps1     # 自定义函数
│   └── Microsoft.PowerShell_profile.ps1 # 配置文件入口
└── scripts/              # 脚本分类
    ├── backup/
    ├── utils/
    └── vpn/ 
        ├── Connect-VPN.ps1      # Your PS connection logic
        └── clash-script.js      # Your Clash Verge JS config             