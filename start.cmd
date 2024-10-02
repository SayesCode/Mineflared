@echo off

:: Function to check if a package is installed
:check_installed
where %1 >nul 2>nul
if %errorlevel% neq 0 (
    echo %1 not found. Attempting installation...
    goto :install_package
)
echo %1 is installed.
exit /b 0

:: Function to install a package if not found
:install_package
:: Install Chocolatey if not present
where choco >nul 2>nul
if %errorlevel% neq 0 (
    echo Installing Chocolatey...
    powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
)

:: Attempt to install Docker via Chocolatey
echo Installing Docker via Chocolatey...
choco install docker-desktop -y
choco install docker-compose -y
call :check_installed docker
if %errorlevel% equ 0 goto :docker_installed

:: Attempt to install Docker via Winget
echo Trying to install Docker via Winget...
winget install Docker.DockerDesktop -y
winget install Docker.DockerCompose -y
call :check_installed docker
if %errorlevel% equ 0 goto :docker_installed

:: Attempt to install Docker via Scoop
echo Trying to install Docker via Scoop...
scoop install docker-desktop
scoop install docker-compose
call :check_installed docker
if %errorlevel% equ 0 goto :docker_installed

:: If all installations fail, open Docker's official website
echo Docker installation failed. Please install Docker manually from the official site.
start https://www.docker.com/products/docker-desktop
goto :eof

:docker_installed
:: Create a new terminal to start the containers
echo Docker installed successfully. Starting Docker Compose...
start cmd /k "docker-compose build && docker-compose up"
