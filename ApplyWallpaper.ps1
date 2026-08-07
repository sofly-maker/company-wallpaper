# ApplyWallpaper.ps1

$Log = "C:\ProgramData\CompanyWallpaper\ApplyWallpaper.log"

Start-Transcript -Path $Log -Append

Write-Host "Started: $(Get-Date)"
Write-Host "User: $env:USERNAME"
Write-Host "Identity: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"

$ErrorActionPreference = "Stop"

$Wallpaper = "C:\ProgramData\CompanyWallpaper\connextlogo.jpeg"

if (!(Test-Path $Wallpaper)) {
    Write-Host "Wallpaper not found."
    Stop-Transcript
    exit 1
}

# Wait for Explorer (max 60 seconds)

$Timeout = 60
$Elapsed = 0

while (-not (Get-Process explorer -ErrorAction SilentlyContinue)) {

    if ($Elapsed -ge $Timeout) {
        Write-Host "Explorer did not start within 60 seconds."
        Stop-Transcript
        exit 1
    }

    Start-Sleep -Seconds 2
    $Elapsed += 2
}

Write-Host "Explorer detected."

# Give Explorer a moment to finish initializing
Start-Sleep -Seconds 5

Write-Host "Current Wallpaper Registry Value:"
Write-Host (Get-ItemProperty "HKCU:\Control Panel\Desktop").Wallpaper

Write-Host "Updating registry..."

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

Set-ItemProperty "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value $Wallpaper
Set-ItemProperty "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -Value 10
Set-ItemProperty "HKCU:\Control Panel\Desktop" -Name TileWallpaper -Value 0

Write-Host "Calling SystemParametersInfo..."

[NativeMethods]::SystemParametersInfo(20, 0, $Wallpaper, 3) | Out-Null

Write-Host "Wallpaper applied."

Write-Host "Finished: $(Get-Date)"
Stop-Transcript

exit 0