@echo off
setlocal enabledelayedexpansion

:: =============================================================================
:: GERENCIADOR DO FIREWALL DO WINDOWS
:: =============================================================================

echo ========================================
echo    GERENCIADOR FIREWALL WINDOWS
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
echo ATENCAO: Desativar o firewall pode expor seu computador a riscos de seguranca!
echo Use apenas para fins de teste ou diagnostico.
echo.
echo Selecione uma opcao:
echo.
echo 1. Desativar Firewall (todos os perfis)
echo 2. Desativar Firewall (apenas perfil atual)
echo 3. Ativar Firewall (todos os perfis)
echo 4. Mostrar status atual do Firewall
echo 5. Criar regra temporaria (permitir aplicacao)
echo 6. Restaurar configuracoes padrao
echo 7. Sair
echo.
set /p opcao="Digite sua opcao (1-7): "

if "%opcao%"=="1" goto desativar_todos
if "%opcao%"=="2" goto desativar_atual
if "%opcao%"=="3" goto ativar_todos
if "%opcao%"=="4" goto mostrar_status
if "%opcao%"=="5" goto regra_temporaria
if "%opcao%"=="6" goto restaurar_padrao
if "%opcao%"=="7" goto sair

echo Opcao invalida!
goto menu

:desativar_todos
echo.
echo === DESATIVANDO FIREWALL (TODOS OS PERFIS) ===
echo.
echo AVISO: Esta acao ira desativar o firewall para:
echo - Perfil de Dominio
echo - Perfil Privado
echo - Perfil Publico
echo.
set /p confirma="Tem certeza? (S/N): "
if /i not "%confirma%"=="S" goto menu

echo.
echo Desativando firewall...

:: Desativar firewall para todos os perfis
netsh advfirewall set allprofiles state off

if %errorLevel% equ 0 (
    echo.
    echo ✓ Firewall desativado com sucesso para todos os perfis!
    echo.
    echo IMPORTANTE: Lembre-se de reativar o firewall quando nao precisar mais!
) else (
    echo.
    echo ✗ Erro ao desativar o firewall. Verifique as permissoes.
)

goto menu

:desativar_atual
echo.
echo === DESATIVANDO FIREWALL (PERFIL ATUAL) ===
echo.

:: Detectar perfil de rede atual
for /f "tokens=2 delims=:" %%a in ('netsh advfirewall show currentprofile ^| findstr "Perfil"') do set perfil_atual=%%a
set perfil_atual=%perfil_atual:~1%

echo Perfil atual detectado: %perfil_atual%
echo.
set /p confirma="Desativar firewall apenas para este perfil? (S/N): "
if /i not "%confirma%"=="S" goto menu

echo.
echo Desativando firewall para o perfil atual...

netsh advfirewall set currentprofile state off

if %errorLevel% equ 0 (
    echo.
    echo ✓ Firewall desativado para o perfil atual!
) else (
    echo.
    echo ✗ Erro ao desativar o firewall.
)

goto menu

:ativar_todos
echo.
echo === ATIVANDO FIREWALL (TODOS OS PERFIS) ===
echo.

echo Ativando firewall para todos os perfis...

netsh advfirewall set allprofiles state on

if %errorLevel% equ 0 (
    echo.
    echo ✓ Firewall ativado com sucesso para todos os perfis!
) else (
    echo.
    echo ✗ Erro ao ativar o firewall.
)

goto menu

:mostrar_status
echo.
echo === STATUS ATUAL DO FIREWALL ===
echo.

echo Obtendo informacoes do firewall...
echo.

:: Mostrar status detalhado
netsh advfirewall show allprofiles state

echo.
echo --- Resumo dos Perfis ---
for /f "tokens=*" %%a in ('netsh advfirewall show allprofiles state ^| findstr /i "estado"') do echo %%a

goto menu

:regra_temporaria
echo.
echo === CRIAR REGRA TEMPORARIA ===
echo.
echo Esta opcao permite criar uma regra para permitir uma aplicacao
echo especifica atraves do firewall sem desativa-lo completamente.
echo.

set /p app_path="Digite o caminho completo da aplicacao: "
if "%app_path%"=="" goto menu

set /p regra_nome="Digite um nome para a regra: "
if "%regra_nome%"=="" set regra_nome=Regra_Temporaria

echo.
echo Criando regra para: %app_path%
echo Nome da regra: %regra_nome%

netsh advfirewall firewall add rule name="%regra_nome%" dir=in action=allow program="%app_path%"
netsh advfirewall firewall add rule name="%regra_nome%_OUT" dir=out action=allow program="%app_path%"

if %errorLevel% equ 0 (
    echo.
    echo ✓ Regra criada com sucesso!
    echo A aplicacao agora pode se comunicar atraves do firewall.
) else (
    echo.
    echo ✗ Erro ao criar a regra. Verifique o caminho da aplicacao.
)

goto menu

:restaurar_padrao
echo.
echo === RESTAURAR CONFIGURACOES PADRAO ===
echo.
echo Esta opcao ira:
echo - Ativar o firewall para todos os perfis
echo - Restaurar regras padrao
echo - Remover regras personalizadas
echo.
set /p confirma="Tem certeza? (S/N): "
if /i not "%confirma%"=="S" goto menu

echo.
echo Restaurando configuracoes padrao...

:: Resetar firewall para configuracoes padrao
netsh advfirewall reset

if %errorLevel% equ 0 (
    echo.
    echo ✓ Configuracoes do firewall restauradas com sucesso!
    echo O firewall esta agora ativo com configuracoes padrao.
) else (
    echo.
    echo ✗ Erro ao restaurar configuracoes padrao.
)

goto menu

:sair
echo.
echo === LEMBRETE DE SEGURANCA ===
echo.
if exist "%temp%\firewall_disabled.flag" (
    echo ATENCAO: O firewall pode estar desativado!
    echo Considere reativa-lo para manter a seguranca do sistema.
    echo.
)
echo Obrigado por usar o Gerenciador de Firewall.
echo.
pause
exit /b 0