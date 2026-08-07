# ApplyWallpaper.ps1
# Runs at user logon

$ErrorActionPreference = "SilentlyContinue"

$Wallpaper = "C:\ProgramData\CompanyWallpaper\connextlogo.jpeg"

if (!(Test-Path $Wallpaper)) {
    exit 1
}

$current = (Get-ItemProperty "HKCU:\Control Panel\Desktop").Wallpaper

if ($current -ieq $Wallpaper) {
    exit 0
}

Set-ItemProperty "HKCU:\Control Panel\Desktop" Wallpaper $Wallpaper
Set-ItemProperty "HKCU:\Control Panel\Desktop" WallpaperStyle 10
Set-ItemProperty "HKCU:\Control Panel\Desktop" TileWallpaper 0

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

# SPI_SETDESKWALLPAPER
[NativeMethods]::SystemParametersInfo(20, 0, $Wallpaper, 3) | Out-Null

exit 0
