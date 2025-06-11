@echo off
title Instalacao de Softwares Basicos
color 0A

echo ================================================
echo         INSTALACAO DE SOFTWARES BASICOS
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

:: Verifica se o Chocolatey está instalado
where choco >nul 2>&1
if %errorLevel% neq 0 (
    echo Chocolatey nao encontrado. Instalando...
    echo.
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    
    if %errorLevel% neq 0 (
        echo Erro ao instalar Chocolatey
        echo Tentando instalacao manual...
        goto manual_install
    )
    
    echo Chocolatey instalado com sucesso!
    echo Reinicie o prompt como administrador para usar o Chocolatey.
    echo.
    pause
    exit /b 0
) else (
    echo Chocolatey ja esta instalado
)

echo.
echo ================================================
echo           SELECIONE OS SOFTWARES
echo ================================================
echo.

echo Softwares disponiveis para instalacao:
echo.
echo NAVEGADORES:
echo [1] Google Chrome
echo [2] Mozilla Firefox
echo [3] Microsoft Edge (Chromium)
echo.
echo COMUNICACAO:
echo [4] WhatsApp Desktop
echo [5] Telegram Desktop
echo [6] Discord
echo [7] Zoom
echo [8] Skype
echo.
echo UTILITARIOS:
echo [9] 7-Zip
echo [10] WinRAR
echo [11] Notepad++
echo [12] Adobe Acrobat Reader
echo [13] VLC Media Player
echo [14] Spotify
echo.
echo PRODUTIVIDADE:
echo [15] Microsoft Office (LibreOffice)
echo [16] Visual Studio Code
echo [17] Git
echo [18] Java Runtime Environment
echo.
echo SISTEMA:
echo [19] CCleaner
echo [20] Malwarebytes
echo [21] Windows Terminal
echo [22] PowerToys
echo.
echo OPCOES ESPECIAIS:
echo [A] Instalar TUDO (Essenciais)
echo [B] Instalar Pacote Escritorio
echo [C] Instalar Pacote Desenvolvedor
echo [D] Instalacao Personalizada
echo.

:menu_selection
set /p selection="Digite os numeros separados por espaco (ex: 1 9 11) ou uma opcao (A/B/C/D): "

if /i "%selection%"=="A" goto install_all
if /i "%selection%"=="B" goto install_office
if /i "%selection%"=="C" goto install_dev
if /i "%selection%"=="D" goto custom_install

:: Processa seleção múltipla
echo.
echo ================================================
echo              INICIANDO INSTALACAO
echo ================================================
echo.

for %%i in (%selection%) do (
    call :install_software %%i
)

goto finish_installation

:install_all
echo.
echo Instalando pacote ESSENCIAL...
echo.
call :install_software 1
call :install_software 9
call :install_software 11
call :install_software 12
call :install_software 13
call :install_software 15
call :install_software 19
goto finish_installation

:install_office
echo.
echo Instalando pacote ESCRITORIO...
echo.
call :install_software 1
call :install_software 9
call :install_software 11
call :install_software 12
call :install_software 15
call :install_software 7
goto finish_installation

:install_dev
echo.
echo Instalando pacote DESENVOLVEDOR...
echo.
call :install_software 1
call :install_software 9
call :install_software 11
call :install_software 16
call :install_software 17
call :install_software 18
call :install_software 21
call :install_software 22
goto finish_installation

:custom_install
echo.
echo Instalacao personalizada:
echo Digite 'S' para instalar ou 'N' para pular cada software:
echo.

set /p chrome="Google Chrome (S/N): "
if /i "%chrome%"=="S" call :install_software 1

set /p firefox="Mozilla Firefox (S/N): "
if /i "%firefox%"=="S" call :install_software 2

set /p whatsapp="WhatsApp Desktop (S/N): "
if /i "%whatsapp%"=="S" call :install_software 4

set /p zip="7-Zip (S/N): "
if /i "%zip%"=="S" call :install_software 9

set /p notepad="Notepad++ (S/N): "
if /i "%notepad%"=="S" call :install_software 11

set /p vlc="VLC Media Player (S/N): "
if /i "%vlc%"=="S" call :install_software 13

set /p office="LibreOffice (S/N): "
if /i "%office%"=="S" call :install_software 15

set /p vscode="Visual Studio Code (S/N): "
if /i "%vscode%"=="S" call :install_software 16

goto finish_installation

:: Função para instalar software baseado no número
:install_software
set software_num=%1

if "%software_num%"=="1" (
    echo Instalando Google Chrome...
    choco install googlechrome -y
) else if "%software_num%"=="2" (
    echo Instalando Mozilla Firefox...
    choco install firefox -y
) else if "%software_num%"=="3" (
    echo Instalando Microsoft Edge...
    choco install microsoft-edge -y
) else if "%software_num%"=="4" (
    echo Instalando WhatsApp Desktop...
    choco install whatsapp -y
) else if "%software_num%"=="5" (
    echo Instalando Telegram Desktop...
    choco install telegram -y
) else if "%software_num%"=="6" (
    echo Instalando Discord...
    choco install discord -y
) else if "%software_num%"=="7" (
    echo Instalando Zoom...
    choco install zoom -y
) else if "%software_num%"=="8" (
    echo Instalando Skype...
    choco install skype -y
) else if "%software_num%"=="9" (
    echo Instalando 7-Zip...
    choco install 7zip -y
) else if "%software_num%"=="10" (
    echo Instalando WinRAR...
    choco install winrar -y
) else if "%software_num%"=="11" (
    echo Instalando Notepad++...
    choco install notepadplusplus -y
) else if "%software_num%"=="12" (
    echo Instalando Adobe Acrobat Reader...
    choco install adobereader -y
) else if "%software_num%"=="13" (
    echo Instalando VLC Media Player...
    choco install vlc -y
) else if "%software_num%"=="14" (
    echo Instalando Spotify...
    choco install spotify -y
) else if "%software_num%"=="15" (
    echo Instalando LibreOffice...
    choco install libreoffice-fresh -y
) else if "%software_num%"=="16" (
    echo Instalando Visual Studio Code...
    choco install vscode -y
) else if "%software_num%"=="17" (
    echo Instalando Git...
    choco install git -y
) else if "%software_num%"=="18" (
    echo Instalando Java Runtime Environment...
    choco install javaruntime -y
) else if "%software_num%"=="19" (
    echo Instalando CCleaner...
    choco install ccleaner -y
) else if "%software_num%"=="20" (
    echo Instalando Malwarebytes...
    choco install malwarebytes -y
) else if "%software_num%"=="21" (
    echo Instalando Windows Terminal...
    choco install microsoft-windows-terminal -y
) else if "%software_num%"=="22" (
    echo Instalando PowerToys...
    choco install powertoys -y
) else (
    echo Software numero %software_num% nao reconhecido
)

echo.
goto :eof

:finish_installation
echo.
echo ================================================
echo            INSTALACAO CONCLUIDA
echo ================================================
echo.

echo Verificando softwares instalados...
echo.

:: Verifica alguns softwares principais
where chrome >nul 2>&1 && echo ✓ Google Chrome instalado
where firefox >nul 2>&1 && echo ✓ Mozilla Firefox instalado
where "C:\Program Files\7-Zip\7z.exe" >nul 2>&1 && echo ✓ 7-Zip instalado
where notepad++ >nul 2>&1 && echo ✓ Notepad++ instalado
where vlc >nul 2>&1 && echo ✓ VLC Media Player instalado
where code >nul 2>&1 && echo ✓ Visual Studio Code instalado
where git >nul 2>&1 && echo ✓ Git instalado

echo.
echo ================================================
echo              RESUMO DA INSTALACAO
echo ================================================
echo.

echo SOFTWARES INSTALADOS COM SUCESSO!
echo.
echo PROXIMOS PASSOS:
echo 1. Reinicie o computador se necessario
echo 2. Configure os softwares instalados
echo 3. Verifique se todas as licencas estao em ordem
echo 4. Crie atalhos na area de trabalho se desejar
echo.

echo COMANDOS UTEIS:
echo - choco list --local-only    (lista softwares instalados)
echo - choco upgrade all          (atualiza todos os softwares)
echo - choco uninstall [software] (desinstala software)
echo.

echo ATENCAO:
echo - Alguns softwares podem necessitar de reinicializacao
echo - Verifique se o Windows Defender nao bloqueou nada
echo - Configure os softwares conforme suas necessidades
echo.

set /p open_folder="Deseja abrir o Menu Iniciar para ver os programas? (S/N): "
if /i "%open_folder%"=="S" (
    start "" shell:AppsFolder
)

echo.
echo ================================================
echo                  CONCLUIDO
echo ================================================
echo.
echo Instalacao de softwares basicos finalizada!
echo Obrigado por usar este script.
echo.
pause
exit /b 0

:manual_install
echo.
echo ================================================
echo           INSTALACAO MANUAL
echo ================================================
echo.
echo O Chocolatey nao pode ser instalado automaticamente.
echo.
echo INSTRUCOES PARA INSTALACAO MANUAL:
echo.
echo 1. Abra o PowerShell como Administrador
echo 2. Execute o comando:
echo    Set-ExecutionPolicy Bypass -Scope Process -Force
echo 3. Execute o comando:
echo    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
echo 4. Reinicie este script apos a instalacao
echo.
echo ALTERNATIVA - Downloads manuais:
echo - Chrome: https://www.google.com/chrome/
echo - Firefox: https://www.mozilla.org/firefox/
echo - 7-Zip: https://www.7-zip.org/
echo - Notepad++: https://notepad-plus-plus.org/
echo - VLC: https://www.videolan.org/vlc/
echo.
pause
exit /b 1