@echo off
setlocal enabledelayedexpansion

:: =============================================================================
:: CONFIGURADOR DE PROXY PARA WINDOWS
:: =============================================================================

echo ========================================
echo    CONFIGURADOR DE PROXY WINDOWS
echo ========================================
echo.

:: Verificar se está rodando como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERRO: Este script precisa ser executado como Administrador.
    echo Clique com o botao direito e selecione "Executar como administrador"
    echo.
    pause
    exit /b 1
)

:menu
echo.
echo Selecione uma opcao:
echo.
echo 1. Configurar Proxy HTTP/HTTPS
echo 2. Configurar Proxy SOCKS
echo 3. Remover configuracao de Proxy
echo 4. Mostrar configuracao atual
echo 5. Configurar excecoes de proxy
echo 6. Sair
echo.
set /p opcao="Digite sua opcao (1-6): "

if "%opcao%"=="1" goto config_http
if "%opcao%"=="2" goto config_socks
if "%opcao%"=="3" goto remover_proxy
if "%opcao%"=="4" goto mostrar_config
if "%opcao%"=="5" goto config_excecoes
if "%opcao%"=="6" goto sair

echo Opcao invalida!
goto menu

:config_http
echo.
echo === CONFIGURACAO PROXY HTTP/HTTPS ===
echo.
set /p servidor="Digite o endereco do servidor proxy: "
set /p porta="Digite a porta do proxy: "
set /p usuario="Digite o usuario (deixe vazio se nao houver): "

if not "%usuario%"=="" (
    set /p senha="Digite a senha: "
    set proxy_url=http://%usuario%:%senha%@%servidor%:%porta%
) else (
    set proxy_url=http://%servidor%:%porta%
)

echo.
echo Configurando proxy HTTP/HTTPS...

:: Configurar proxy no registro do Windows
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "%servidor%:%porta%" /f >nul

:: Configurar variaveis de ambiente
setx HTTP_PROXY "%proxy_url%" >nul
setx HTTPS_PROXY "%proxy_url%" >nul

echo Proxy HTTP/HTTPS configurado com sucesso!
echo Servidor: %servidor%:%porta%
goto menu

:config_socks
echo.
echo === CONFIGURACAO PROXY SOCKS ===
echo.
set /p servidor="Digite o endereco do servidor SOCKS: "
set /p porta="Digite a porta do SOCKS: "

echo.
echo Configurando proxy SOCKS...

:: Configurar proxy SOCKS no registro
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "socks=%servidor%:%porta%" /f >nul

echo Proxy SOCKS configurado com sucesso!
echo Servidor: %servidor%:%porta%
goto menu

:remover_proxy
echo.
echo === REMOVENDO CONFIGURACAO DE PROXY ===
echo.

:: Desabilitar proxy no registro
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /f >nul 2>nul

:: Remover variaveis de ambiente
setx HTTP_PROXY "" >nul
setx HTTPS_PROXY "" >nul
setx FTP_PROXY "" >nul
setx SOCKS_PROXY "" >nul

echo Configuracao de proxy removida com sucesso!
goto menu

:mostrar_config
echo.
echo === CONFIGURACAO ATUAL ===
echo.

:: Verificar status do proxy no registro
for /f "tokens=3" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable 2^>nul') do set proxy_enabled=%%a
for /f "tokens=3*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer 2^>nul') do set proxy_server=%%a %%b

if "%proxy_enabled%"=="0x1" (
    echo Status: ATIVO
    echo Servidor: %proxy_server%
) else (
    echo Status: DESATIVADO
)

echo.
echo Variaveis de ambiente:
echo HTTP_PROXY: %HTTP_PROXY%
echo HTTPS_PROXY: %HTTPS_PROXY%
echo FTP_PROXY: %FTP_PROXY%
echo SOCKS_PROXY: %SOCKS_PROXY%

goto menu

:config_excecoes
echo.
echo === CONFIGURAR EXCECOES DE PROXY ===
echo.
echo Digite os enderecos que nao devem usar proxy (separados por ponto e virgula)
echo Exemplo: localhost;127.0.0.1;*.local;intranet.empresa.com
echo.
set /p excecoes="Excecoes (deixe vazio para limpar): "

if "%excecoes%"=="" (
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /f >nul 2>nul
    echo Excecoes removidas.
) else (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "%excecoes%" /f >nul
    echo Excecoes configuradas: %excecoes%
)

goto menu

:sair
echo.
echo NOTA: Algumas aplicacoes podem precisar ser reiniciadas
echo para que as mudancas tenham efeito.
echo.
echo Pressione qualquer tecla para sair...
pause >nul
exit /b 0