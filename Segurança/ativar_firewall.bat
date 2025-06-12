@echo off
setlocal enabledelayedexpansion

:: =============================================================================
:: ATIVADOR E CONFIGURADOR DO FIREWALL DO WINDOWS
:: =============================================================================

echo ========================================
echo    ATIVADOR FIREWALL WINDOWS
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
echo 1. Ativar Firewall (todos os perfis)
echo 2. Ativar Firewall (perfil atual apenas)
echo 3. Ativar com configuracao recomendada
echo 4. Verificar e corrigir configuracao
echo 5. Mostrar status detalhado
echo 6. Configurar regras basicas
echo 7. Backup das configuracoes atuais
echo 8. Sair
echo.
set /p opcao="Digite sua opcao (1-8): "

if "%opcao%"=="1" goto ativar_todos
if "%opcao%"=="2" goto ativar_atual
if "%opcao%"=="3" goto config_recomendada
if "%opcao%"=="4" goto verificar_corrigir
if "%opcao%"=="5" goto status_detalhado
if "%opcao%"=="6" goto config_regras
if "%opcao%"=="7" goto backup_config
if "%opcao%"=="8" goto sair

echo Opcao invalida!
goto menu

:ativar_todos
echo.
echo === ATIVANDO FIREWALL (TODOS OS PERFIS) ===
echo.

echo Ativando firewall para todos os perfis...
echo.

:: Ativar firewall para todos os perfis
netsh advfirewall set allprofiles state on

if %errorLevel% equ 0 (
    echo ✓ Firewall ativado com sucesso para todos os perfis!
    echo.
    echo Status atual:
    netsh advfirewall show allprofiles state | findstr /i "estado"
    echo.
    echo ✓ Sistema protegido pelo firewall!
) else (
    echo ✗ Erro ao ativar o firewall. Codigo de erro: %errorLevel%
)

goto menu

:ativar_atual
echo.
echo === ATIVANDO FIREWALL (PERFIL ATUAL) ===
echo.

:: Detectar perfil de rede atual
echo Detectando perfil de rede atual...
for /f "tokens=*" %%a in ('netsh advfirewall show currentprofile ^| findstr /i "perfil"') do echo Perfil detectado: %%a

echo.
echo Ativando firewall para o perfil atual...

netsh advfirewall set currentprofile state on

if %errorLevel% equ 0 (
    echo.
    echo ✓ Firewall ativado para o perfil atual!
) else (
    echo.
    echo ✗ Erro ao ativar o firewall para o perfil atual.
)

goto menu

:config_recomendada
echo.
echo === CONFIGURACAO RECOMENDADA DE SEGURANCA ===
echo.

echo Aplicando configuracoes recomendadas de seguranca...
echo.

:: Ativar firewall
echo [1/6] Ativando firewall para todos os perfis...
netsh advfirewall set allprofiles state on

:: Configurar comportamento padrão
echo [2/6] Configurando comportamento padrao (bloquear entrada, permitir saida)...
netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound

:: Ativar notificações
echo [3/6] Ativando notificacoes de bloqueio...
netsh advfirewall set allprofiles settings inboundusernotification enable

:: Ativar log
echo [4/6] Configurando log de eventos...
netsh advfirewall set allprofiles logging droppedconnections enable
netsh advfirewall set allprofiles logging allowedconnections disable

:: Regras básicas essenciais
echo [5/6] Configurando regras basicas essenciais...

:: Permitir ICMP (ping) apenas para diagnóstico
netsh advfirewall firewall add rule name="ICMP Echo Request (Ping)" protocol=icmpv4:8,any dir=in action=allow

:: Permitir DNS
netsh advfirewall firewall add rule name="DNS (TCP-Out)" protocol=TCP dir=out localport=53 action=allow
netsh advfirewall firewall add rule name="DNS (UDP-Out)" protocol=UDP dir=out localport=53 action=allow

:: Permitir HTTP/HTTPS para navegação
netsh advfirewall firewall add rule name="HTTP (TCP-Out)" protocol=TCP dir=out localport=80 action=allow
netsh advfirewall firewall add rule name="HTTPS (TCP-Out)" protocol=TCP dir=out localport=443 action=allow

echo [6/6] Verificando configuracao final...

if %errorLevel% equ 0 (
    echo.
    echo ✓ Configuracao recomendada aplicada com sucesso!
    echo.
    echo Configuracoes aplicadas:
    echo - Firewall ativo em todos os perfis
    echo - Bloqueio de entrada por padrao
    echo - Permissao de saida por padrao
    echo - Notificacoes ativadas
    echo - Log de conexoes bloqueadas ativo
    echo - Regras basicas para navegacao web
    echo.
    echo ✓ Sistema agora possui protecao robusta!
) else (
    echo.
    echo ⚠ Algumas configuracoes podem nao ter sido aplicadas.
    echo Execute "Verificar e corrigir configuracao" para mais detalhes.
)

goto menu

:verificar_corrigir
echo.
echo === VERIFICACAO E CORRECAO DE CONFIGURACAO ===
echo.

echo Verificando configuracao atual do firewall...
echo.

:: Verificar se firewall está ativo
set /a problemas=0

echo [Verificacao 1] Status do firewall por perfil:
netsh advfirewall show allprofiles state | findstr /i "estado"

for /f %%a in ('netsh advfirewall show allprofiles state ^| findstr /i "desativado" ^| find /c "desativado"') do (
    if %%a gtr 0 (
        echo ⚠ Encontrados perfis com firewall desativado!
        set /a problemas+=1
    )
)

echo.
echo [Verificacao 2] Configuracoes de politica:
netsh advfirewall show allprofiles | findstr /i "politica"

echo.
echo [Verificacao 3] Status dos servicos relacionados:
sc query MpsSvc | findstr STATE
sc query BFE | findstr STATE

echo.
if %problemas% gtr 0 (
    echo ⚠ Foram detectados %problemas% problema(s) na configuracao.
    echo.
    set /p corrigir="Deseja tentar corrigir automaticamente? (S/N): "
    if /i "!corrigir!"=="S" (
        echo.
        echo Corrigindo problemas detectados...
        
        :: Iniciar serviços necessários
        echo Iniciando servicos necessarios...
        net start MpsSvc >nul 2>&1
        net start BFE >nul 2>&1
        
        :: Ativar firewall
        echo Ativando firewall...
        netsh advfirewall set allprofiles state on
        
        :: Configurar políticas padrão
        echo Configurando politicas padrao...
        netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound
        
        echo.
        echo ✓ Correcoes aplicadas! Execute esta opcao novamente para verificar.
    )
) else (
    echo ✓ Nenhum problema detectado na configuracao atual!
)

goto menu

:status_detalhado
echo.
echo === STATUS DETALHADO DO FIREWALL ===
echo.

echo Coletando informacoes detalhadas...
echo.

echo ==========================================
echo STATUS POR PERFIL
echo ==========================================
netsh advfirewall show allprofiles

echo.
echo ==========================================
echo REGRAS ATIVAS (ULTIMAS 10)
echo ==========================================
netsh advfirewall firewall show rule name=all | findstr /i "nome\|acao\|direcao" | head -30

echo.
echo ==========================================
echo SERVICOS RELACIONADOS
echo ==========================================
echo Firewall do Windows (MpsSvc):
sc query MpsSvc
echo.
echo Base Filtering Engine (BFE):
sc query BFE

echo.
echo ==========================================
echo CONFIGURACOES DE LOG
echo ==========================================
netsh advfirewall show allprofiles | findstr /i "log"

goto menu

:config_regras
echo.
echo === CONFIGURACAO DE REGRAS BASICAS ===
echo.
echo Selecione o tipo de regra a configurar:
echo.
echo 1. Permitir aplicacao especifica
echo 2. Permitir porta especifica
echo 3. Bloquear aplicacao especifica
echo 4. Bloquear porta especifica
echo 5. Regras para servidor web (80, 443)
echo 6. Regras para compartilhamento de arquivos
echo 7. Voltar ao menu principal
echo.
set /p regra_opcao="Digite sua opcao (1-7): "

if "%regra_opcao%"=="1" goto regra_app_permitir
if "%regra_opcao%"=="2" goto regra_porta_permitir
if "%regra_opcao%"=="3" goto regra_app_bloquear
if "%regra_opcao%"=="4" goto regra_porta_bloquear
if "%regra_opcao%"=="5" goto regras_web
if "%regra_opcao%"=="6" goto regras_compartilhamento
if "%regra_opcao%"=="7" goto menu

goto config_regras

:regra_app_permitir
echo.
set /p app_path="Digite o caminho completo da aplicacao: "
set /p regra_nome="Digite um nome para a regra: "
if "%regra_nome%"=="" set regra_nome=App_Permitida

netsh advfirewall firewall add rule name="%regra_nome%" dir=in action=allow program="%app_path%"
netsh advfirewall firewall add rule name="%regra_nome%_OUT" dir=out action=allow program="%app_path%"

echo ✓ Regra criada para permitir a aplicacao!
goto config_regras

:regra_porta_permitir
echo.
set /p porta="Digite o numero da porta: "
set /p protocolo="Digite o protocolo (TCP/UDP): "
set regra_nome=Porta_%porta%_%protocolo%

netsh advfirewall firewall add rule name="%regra_nome%_IN" dir=in action=allow protocol=%protocolo% localport=%porta%

echo ✓ Regra criada para permitir a porta %porta%/%protocolo%!
goto config_regras

:regras_web
echo.
echo Configurando regras para servidor web...
netsh advfirewall firewall add rule name="HTTP_Server" dir=in action=allow protocol=TCP localport=80
netsh advfirewall firewall add rule name="HTTPS_Server" dir=in action=allow protocol=TCP localport=443
echo ✓ Regras para servidor web (portas 80 e 443) configuradas!
goto config_regras

:backup_config
echo.
echo === BACKUP DAS CONFIGURACOES ===
echo.

set backup_file=%USERPROFILE%\Desktop\firewall_backup_%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%.wfw
set backup_file=%backup_file: =0%

echo Criando backup das configuracoes atuais...
echo Local: %backup_file%

netsh advfirewall export "%backup_file%"

if %errorLevel% equ 0 (
    echo.
    echo ✓ Backup criado com sucesso!
    echo Arquivo: %backup_file%
    echo.
    echo Para restaurar este backup no futuro, use o comando:
    echo netsh advfirewall import "%backup_file%"
) else (
    echo.
    echo ✗ Erro ao criar backup.
)

goto menu

:sair
echo.
echo === VERIFICACAO FINAL ===
echo.

:: Verificação final do status
for /f %%a in ('netsh advfirewall show allprofiles state ^| findstr /i "ativado" ^| find /c "ativado"') do set perfis_ativos=%%a

if %perfis_ativos% geq 1 (
    echo ✓ Firewall esta ATIVO e protegendo o sistema!
    echo Perfis ativos: %perfis_ativos%
) else (
    echo ⚠ ATENCAO: Firewall pode estar DESATIVADO!
    echo Recomenda-se ativar o firewall antes de sair.
)

echo.
echo Obrigado por usar o Ativador de Firewall.
echo Mantenha sempre seu sistema protegido!
echo.
pause
exit /b 0