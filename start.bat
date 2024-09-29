@echo off

:: Instalação do Chocolatey
where choco >nul 2>nul
if %errorlevel% neq 0 (
    echo Instalando Chocolatey...
    powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
)

:: Instalando Docker
echo Instalando Docker...
choco install docker-desktop -y

:: Levantar os containers com Docker Compose
echo Iniciando o Docker Compose...
docker-compose build
docker-compose up
