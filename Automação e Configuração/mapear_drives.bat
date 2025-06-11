@echo off
title Mapeamento de Drives de Rede
color 0B

echo ================================================
echo          MAPEAMENTO DE DRIVES DE REDE
echo ================================================
echo.

:: Menu principal
:main_menu
echo Escolha uma opcao:
echo.
echo 1 - Mapear novo drive
echo 2 - Listar drives mapeados
echo 3 - Desconectar drive
echo 4 - Desconectar todos os drives
echo 5 - Mapear drives predefinidos
echo 6 - Testar conectividade
echo 7 - Salvar/Carregar configuracao
echo 0 - Sair
echo.
set /p choice="Digite sua opcao (0-7): "

if "%choice%"=="1" goto map_drive
if "%choice%"=="2" goto list_drives
if "%choice%"=="3" goto disconnect_drive
if "%choice%"=="4" goto disconnect_all
if "%choice%"=="5" goto predefined_drives
if "%choice%"=="6" goto test_connectivity
if "%choice%"=="7" goto save_load_config
if "%choice%"=="0" goto exit_script

echo Opcao invalida. Tente novamente.
echo.
goto main_menu

:map_drive
echo.
echo ================================================
echo              MAPEAR NOVO DRIVE
echo ================================================
echo.

:: Mostra letras disponíveis
echo Letras de drive disponiveis:
for %%d in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if not exist %%d:\ echo %%d:
)

echo.
set /p drive_letter="Digite a letra do drive (ex: Z): "
set /p network_path="Digite o caminho de rede (ex: \\servidor\pasta): "

echo.
set /p persistent="Manter mapeamento apos reinicializar? (S/N): "
if /i "%persistent%"=="S" (
    set persist_flag=/persistent:yes
) else (
    set persist_flag=/persistent:no
)

echo.
set /p use_credentials="Deseja usar credenciais especificas? (S/N): "
if /i "%use_credentials%"=="S" (
    set /p username="Usuario: "
    set /p password="Senha: "
    echo.
    echo Mapeando %drive_letter%: para %network_path%...
    net use %drive_letter%: "%network_path%" %persist_flag% /user:%username% %password%
) else (
    echo.
    echo Mapeando %drive_letter%: para %network_path%...
    net use %drive_letter%: "%network_path%" %persist_flag%
)

if %errorLevel% equ 0 (
    echo ✓ Drive %drive_letter%: mapeado com sucesso!
    echo Testando acesso...
    dir %drive_letter%:\ >nul 2>&1
    if !errorLevel! equ 0 (
        echo ✓ Acesso ao drive confirmado
    ) else (
        echo ⚠ Drive mapeado mas acesso pode estar limitado
    )
) else (
    echo ✗ Erro ao mapear drive
    echo Verifique o caminho de rede e credenciais
)

echo.
pause
goto main_menu

:list_drives
echo.
echo ================================================
echo           DRIVES MAPEADOS ATUALMENTE
echo ================================================
echo.

net use | findstr /C:"OK" /C:"Unavailable" /C:"Disconnected"
if %errorLevel% neq 0 (
    echo Nenhum drive de rede mapeado encontrado.
)

echo.
echo Detalhes completos:
net use

echo.
pause
goto main_menu

:disconnect_drive
echo.
echo ================================================
echo             DESCONECTAR DRIVE
echo ================================================
echo.

echo Drives atualmente mapeados:
net use | findstr /C:"OK" /C:"Unavailable" /C:"Disconnected"

echo.
set /p drive_to_disconnect="Digite a letra do drive para desconectar (ex: Z): "

echo.
echo Desconectando drive %drive_to_disconnect%:...
net use %drive_to_disconnect%: /delete

if %errorLevel% equ 0 (
    echo ✓ Drive %drive_to_disconnect%: desconectado com sucesso!
) else (
    echo ✗ Erro ao desconectar drive %drive_to_disconnect%:
)

echo.
pause
goto main_menu

:disconnect_all
echo.
echo ================================================
echo        DESCONECTAR TODOS OS DRIVES
echo ================================================
echo.

echo ATENCAO: Esta operacao ira desconectar TODOS os drives mapeados!
echo.
net use | findstr /C:"OK" /C:"Unavailable" /C:"Disconnected"
echo.

set /p confirm_all="Tem certeza que deseja continuar? (S/N): "
if /i not "%confirm_all%"=="S" (
    echo Operacao cancelada.
    echo.
    pause
    goto main_menu
)

echo.
echo Desconectando todos os drives...
net use * /delete /yes

if %errorLevel% equ 0 (
    echo ✓ Todos os drives foram desconectados!
) else (
    echo ⚠ Alguns drives podem nao ter sido desconectados
)

echo.
pause
goto main_menu

:predefined_drives
echo.
echo ================================================
echo           DRIVES PREDEFINIDOS
echo ================================================
echo.

echo Configure seus drives mais utilizados:
echo.
echo 1 - Servidor de arquivos (\\servidor\arquivos → H:)
echo 2 - Pasta compartilhada (\\servidor\compartilhada → S:)
echo 3 - Backup (\\servidor\backup → B:)
echo 4 - Projetos (\\servidor\projetos → P:)
echo 5 - Configuracao personalizada
echo 0 - Voltar ao menu principal
echo.

set /p predefined_choice="Escolha uma opcao: "

if "%predefined_choice%"=="1" (
    set drive_letter=H
    set network_path=\\servidor\arquivos
    goto execute_predefined
)
if "%predefined_choice%"=="2" (
    set drive_letter=S
    set network_path=\\servidor\compartilhada
    goto execute_predefined
)
if "%predefined_choice%"=="3" (
    set drive_letter=B
    set network_path=\\servidor\backup
    goto execute_predefined
)
if "%predefined_choice%"=="4" (
    set drive_letter=P
    set network_path=\\servidor\projetos
    goto execute_predefined
)
if "%predefined_choice%"=="5" goto custom_predefined
if "%predefined_choice%"=="0" goto main_menu

echo Opcao invalida.
pause
goto predefined_drives

:custom_predefined
echo.
echo Configure seu drive personalizado:
set /p drive_letter="Letra do drive: "
set /p network_path="Caminho de rede: "

:execute_predefined
echo.
echo Mapeando %drive_letter%: para %network_path%...
net use %drive_letter%: "%network_path%" /persistent:yes

if %errorLevel% equ 0 (
    echo ✓ Drive predefinido mapeado com sucesso!
) else (
    echo ✗ Erro ao mapear drive predefinido
)

echo.
pause
goto main_menu

:test_connectivity
echo.
echo ================================================
echo           TESTAR CONECTIVIDADE
echo ================================================
echo.

set /p test_server="Digite o servidor para testar (ex: servidor ou IP): "

echo.
echo Testando conectividade com %test_server%...
echo.

echo 1. Teste de PING...
ping -n 3 %test_server%
echo.

echo 2. Teste de conectividade SMB (porta 445)...
telnet %test_server% 445 2>nul
if %errorLevel% equ 0 (
    echo ✓ Porta 445 (SMB) acessivel
) else (
    echo ✗ Porta 445 (SMB) nao acessivel
)

echo.
echo 3. Tentando listar compartilhamentos...
net view \\%test_server%

echo.
pause
goto main_menu

:save_load_config
echo.
echo ================================================
echo        SALVAR/CARREGAR CONFIGURACAO
echo ================================================
echo.

echo 1 - Salvar configuracao atual
echo 2 - Carregar configuracao salva
echo 0 - Voltar
echo.

set /p config_choice="Escolha: "

if "%config_choice%"=="1" goto save_config
if "%config_choice%"=="2" goto load_config
if "%config_choice%"=="0" goto main_menu

goto save_load_config

:save_config
echo.
echo Salvando configuracao atual...
net use > drives_config.txt
echo ✓ Configuracao salva em drives_config.txt
echo.
pause
goto main_menu

:load_config
echo.
echo Carregando configuracao...
if not exist drives_config.txt (
    echo ✗ Arquivo de configuracao nao encontrado!
    pause
    goto main_menu
)

echo Configuracao encontrada:
type drives_config.txt
echo.
echo Esta funcionalidade requer configuracao manual.
echo Use o arquivo drives_config.txt como referencia.
echo.
pause
goto main_menu

:exit_script
echo.
echo ================================================
echo                  RESUMO FINAL
echo ================================================
echo.
echo Drives atualmente mapeados:
net use | findstr /C:"OK" /C:"Unavailable" /C:"Disconnected"
if %errorLevel% neq 0 (
    echo Nenhum drive mapeado.
)

echo.
echo DICAS IMPORTANTES:
echo - Drives persistentes serao remapeados automaticamente
echo - Use credenciais de dominio quando necessario
echo - Teste a conectividade antes de mapear
echo - Mantenha senhas seguras
echo.

echo Script finalizado. Obrigado por usar!
pause
exit /b 0