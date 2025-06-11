@echo off
title Reparo de DNS
color 0C

echo ================================================
echo              REPARO DE DNS
echo ================================================
echo.

:: Verifica se está sendo executado como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERRO: Este script precisa ser executado como Administrador!
    echo Clique com o botao direito no arquivo e selecione "Executar como administrador"
    echo.
    pause
    exit /b 1
)

echo Este script ira executar os seguintes reparos:
echo.
echo 1. Limpar cache DNS
echo 2. Renovar configuracoes IP
echo 3. Redefinir Winsock
echo 4. Redefinir TCP/IP
echo 5. Configurar servidores DNS confiáveis
echo 6. Reiniciar servicos de rede
echo.

set /p confirm="Deseja continuar com o reparo? (S/N): "
if /i not "%confirm%"=="S" (
    echo Operacao cancelada pelo usuario.
    pause
    exit /b 0
)

echo.
echo ================================================
echo              INICIANDO REPARO
echo ================================================
echo.

:: 1. Limpar cache DNS
echo [1/7] Limpando cache DNS...
ipconfig /flushdns
if %errorLevel% equ 0 (
    echo ✓ Cache DNS limpo com sucesso
) else (
    echo ✗ Erro ao limpar cache DNS
)
echo.

:: 2. Renovar IP
echo [2/7] Renovando configuracoes IP...
ipconfig /release >nul 2>&1
ipconfig /renew >nul 2>&1
if %errorLevel% equ 0 (
    echo IP renovado com sucesso
) else (
    echo Erro ao renovar IP
)
echo.

:: 3. Redefinir Winsock
echo [3/7] Redefinindo Winsock...
netsh winsock reset
if %errorLevel% equ 0 (
    echo Winsock redefinido com sucesso
) else (
    echo Erro ao redefinir Winsock
)
echo.

:: 4. Redefinir TCP/IP
echo [4/7] Redefinindo TCP/IP...
netsh int ip reset
if %errorLevel% equ 0 (
    echo TCP/IP redefinido com sucesso
) else (
    echo Erro ao redefinir TCP/IP
)
echo.

:: 5. Redefinir configurações de DNS
echo [5/7] Redefinindo configuracoes DNS...
netsh interface ip set dns "Conexão Local" dhcp >nul 2>&1
netsh interface ip set dns "Wi-Fi" dhcp >nul 2>&1
netsh interface ip set dns "Ethernet" dhcp >nul 2>&1
echo Configuracoes DNS redefinidas
echo.

:: 6. Configurar DNS alternativo (opcional)
echo [6/7] Configurando servidores DNS alternativos...
echo.
echo Opcoes de DNS disponiveis:
echo 1 - Google DNS (8.8.8.8 / 8.8.4.4)
echo 2 - Cloudflare (1.1.1.1 / 1.0.0.1)
echo 3 - OpenDNS (208.67.222.222 / 208.67.220.220)
echo 4 - Manter configuracao automatica (DHCP)
echo.
set /p dns_choice="Escolha uma opcao (1-4): "

if "%dns_choice%"=="1" (
    echo Configurando Google DNS...
    call :set_dns "8.8.8.8" "8.8.4.4"
    echo Google DNS configurado
) else if "%dns_choice%"=="2" (
    echo Configurando Cloudflare DNS...
    call :set_dns "1.1.1.1" "1.0.0.1"
    echo Cloudflare DNS configurado
) else if "%dns_choice%"=="3" (
    echo Configurando OpenDNS...
    call :set_dns "208.67.222.222" "208.67.220.220"
    echo OpenDNS configurado
) else (
    echo Mantendo configuracao automatica (DHCP)
)
echo.

:: 7. Reiniciar serviços de rede
echo [7/7] Reiniciando servicos de rede...
net stop dnscache >nul 2>&1
net start dnscache >nul 2>&1
net stop "DHCP Client" >nul 2>&1
net start "DHCP Client" >nul 2>&1
echo Servicos de rede reiniciados
echo.

:: Teste de conectividade
echo ================================================
echo              TESTE DE CONECTIVIDADE
echo ================================================
echo.
echo Testando conectividade DNS...
ping -n 2 8.8.8.8 >nul 2>&1
if %errorLevel% equ 0 (
    echo Conectividade com servidor DNS: OK
    
    echo Testando resolucao de nomes...
    nslookup google.com >nul 2>&1
    if !errorLevel! equ 0 (
        echo Resolucao de nomes DNS: OK
    ) else (
        echo Resolucao de nomes DNS: FALHA
    )
) else (
    echo Conectividade com servidor DNS: FALHA
)

echo.
echo ================================================
echo                 REPARO CONCLUIDO
echo ================================================
echo.
echo O reparo DNS foi executado. 
echo.
echo IMPORTANTE: Reinicie o computador para garantir que
echo todas as alteracoes sejam aplicadas completamente.
echo.

set /p reboot="Deseja reiniciar o computador agora? (S/N): "
if /i "%reboot%"=="S" (
    echo Reiniciando em 10 segundos...
    echo Pressione Ctrl+C para cancelar
    timeout /t 10
    shutdown /r /t 0
) else (
    echo Lembre-se de reiniciar o computador manualmente.
)

pause
exit /b 0

:: Função para configurar DNS
:set_dns
set primary_dns=%~1
set secondary_dns=%~2

:: Tenta configurar para diferentes interfaces de rede
for /f "tokens=1,2,*" %%i in ('netsh interface show interface ^| findstr /i "conectado"') do (
    if "%%j"=="Conectado" (
        netsh interface ip set dns "%%k" static %primary_dns% >nul 2>&1
        netsh interface ip add dns "%%k" %secondary_dns% index=2 >nul 2>&1
    )
)
goto :eof