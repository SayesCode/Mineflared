@echo off
setlocal enabledelayedexpansion

:: Função para verificar e instalar o Cloudflared
:install_cloudflared
where cloudflared >nul 2>nul
if %errorlevel% equ 0 (
    echo Cloudflared já está instalado.
) else (
    echo Instalando Cloudflared...
    choco install cloudflared -y
)

:: Instalar o Java versão 17
echo Instalando Java versão 17...
choco install jdk17 -y

:: Configurar e iniciar o Cloudflared
echo Configurando o Cloudflared...
start cmd /c "cloudflared tunnel --url localhost:25565"

:: Aguardar a inicialização do Cloudflared
echo Aguardando o Cloudflared iniciar...
timeout /t 10 >nul

:: Obter o IP do Cloudflared
echo Verificando o IP do Cloudflared...
set "cldflr_url="
for /f "tokens=*" %%i in ('cloudflared tunnel list') do (
    set "line=%%i"
    if "!line!" neq "" (
        set "cldflr_url=!line!"
        echo URL do Cloudflared encontrado: !cldflr_url!
    )
)

:: Iniciar o servidor Minecraft
echo Iniciando o servidor Minecraft...
java -Xmx1024M -Xms1024M -jar paper-1.21.1-110.jar nogui

echo Servidor Minecraft iniciado com IP do Cloudflared: !cldflr_url!
pause
