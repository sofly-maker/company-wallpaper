# ApplyWallpaper.ps1

$ErrorActionPreference = "Stop"

$Wallpaper = "C:\ProgramData\CompanyWallpaper\connextlogo.jpeg"

if (!(Test-Path $Wallpaper)) {
    exit 1
}

# Wait for Explorer (max 60 seconds)
$Timeout = 60
$Elapsed = 0

while (-not (Get-Process explorer -ErrorAction SilentlyContinue)) {
    if ($Elapsed -ge $Timeout) {
        exit 1
    }

    Start-Sleep -Seconds 2
    $Elapsed += 2
}

# Give Explorer a moment to finish initializing
Start-Sleep -Seconds 5

Set-ItemProperty "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value $Wallpaper
Set-ItemProperty "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -Value 10
Set-ItemProperty "HKCU:\Control Panel\Desktop" -Name TileWallpaper -Value 0

Add-Type @"
using System.Runtime.InteropServices;

public class NativeMethods
{
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(
        int uAction,
        int uParam,
        string lpvParam,
        int fuWinIni);
}
"@

# Apply the wallpaper
[NativeMethods]::SystemParametersInfo(20, 0, $Wallpaper, 3) | Out-Null

exit 0