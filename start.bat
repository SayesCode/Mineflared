@echo off
:: Check if Chocolatey is already installed
where chocolatey >nul 2>nul
if %errorlevel% equ 0 (
    echo Chocolatey is already installed.
) else (
    echo Installing Chocolatey...
    @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    echo Chocolatey installed successfully.
)

:: Install Java version 17
choco install jdk17 -y

:: Download Cloudflared
echo Downloading Cloudflared...
choco install cloudflared -y

:: Start Cloudflared
start cmd /c "cloudflared tunnel run"

:: Wait for Cloudflared to initialize
echo Waiting for Cloudflared to start...
timeout /t 10 >nul

:: Get the IP address of Cloudflared
echo Checking IP address...
setlocal enabledelayedexpansion
for /f "tokens=*" %%i in ('cloudflared tunnel list') do (
    set "line=%%i"
    echo !line!
)

:: Run Minecraft server
java -Xmx1024M -Xms1024M -jar paper-1.21.1-110.jar nogui

echo Minecraft server started with Cloudflared IP.
pause
