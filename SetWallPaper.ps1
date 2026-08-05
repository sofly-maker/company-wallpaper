# =========================================
# SetWallpaper.ps1
# Runs as the logged-in user
# =========================================

$Wallpaper = "C:\ProgramData\Company\connextlogo.jpeg"

if (!(Test-Path $Wallpaper)) {
    Write-Host "Wallpaper not found: $Wallpaper"
    exit 1
}

# Configure wallpaper style (Fill)
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -Value "10"
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -Value "0"

try {
    # Windows 8/10/11 Desktop Wallpaper API
    $DesktopWallpaper = New-Object -ComObject Microsoft.Windows.DesktopWallpaper
    $DesktopWallpaper.SetWallpaper($null, $Wallpaper)

    Write-Host "Wallpaper applied successfully."
    exit 0
}
catch {
    # Fallback for systems where the COM object isn't available
    Add-Type @"
using System.Runtime.InteropServices;

public class Wallpaper
{
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(
        int uAction,
        int uParam,
        string lpvParam,
        int fuWinIni);
}
"@

    # SPI_SETDESKWALLPAPER = 20
    # SPIF_UPDATEINIFILE | SPIF_SENDCHANGE = 3
    [Wallpaper]::SystemParametersInfo(20, 0, $Wallpaper, 3) | Out-Null

    Write-Host "Wallpaper applied using fallback method."
    exit 0
}