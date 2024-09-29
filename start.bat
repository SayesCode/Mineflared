@echo off

:: Instalação do Chocolatey
where choco >nul 2>nul
if %errorlevel% neq 0 (
    echo Instalando Chocolatey...
    powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
)

:: Instalação do Docker
echo Instalando Docker...
choco install docker-desktop -y
choco install docker-compose -y

:: Criar um novo terminal para levantar os containers
echo Iniciando o Docker Compose em um novo terminal...
start cmd /k "docker-compose build && docker-compose up"
