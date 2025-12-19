# ==============================================================================
# Dotfiles Installation Script (install.ps1)
# Function: Establish profile links and initialize system tasks
# ==============================================================================

# --- Configuration Variables ---
$targetProfile = $PROFILE
$repoProfile = Join-Path $PSScriptRoot "powershell\Microsoft.PowerShell_profile.ps1"

Write-Host "Starting dotfiles environment configuration..." -ForegroundColor Cyan

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