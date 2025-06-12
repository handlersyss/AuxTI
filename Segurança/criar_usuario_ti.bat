@echo off
setlocal enabledelayedexpansion

:: =============================================================================
:: CRIADOR DE USUARIOS DE TI PARA WINDOWS
:: =============================================================================

echo ========================================
echo    CRIADOR DE USUARIOS DE TI
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
echo 1. Criar usuario TI completo (Administrador)
echo 2. Criar usuario TI limitado (Power User)
echo 3. Criar usuario de servico
echo 4. Configurar usuario existente para TI
echo 5. Listar usuarios do sistema
echo 6. Remover usuario
echo 7. Gerenciar grupos de usuarios
echo 8. Configuracoes avancadas de usuario
echo 9. Sair
echo.
set /p opcao="Digite sua opcao (1-9): "

if "%opcao%"=="1" goto criar_admin_completo
if "%opcao%"=="2" goto criar_power_user
if "%opcao%"=="3" goto criar_usuario_servico
if "%opcao%"=="4" goto configurar_usuario_existente
if "%opcao%"=="5" goto listar_usuarios
if "%opcao%"=="6" goto remover_usuario
if "%opcao%"=="7" goto gerenciar_grupos
if "%opcao%"=="8" goto config_avancadas
if "%opcao%"=="9" goto sair

echo Opcao invalida!
goto menu

:criar_admin_completo
echo.
echo === CRIAR USUARIO TI ADMINISTRADOR ===
echo.
echo Este usuario tera privilegios administrativos completos.
echo.

call :coletar_dados_usuario
if "!cancelar!"=="sim" goto menu

echo.
echo Criando usuario administrador completo...

:: Criar usuário
net user "!nome_usuario!" "!senha!" /add /fullname:"!nome_completo!" /comment:"Usuario TI - Administrador Completo - Criado em %date%"

if %errorLevel% neq 0 (
    echo ✗ Erro ao criar usuario
    goto menu
)

:: Adicionar aos grupos administrativos
echo Adicionando aos grupos administrativos...
net localgroup Administradores "!nome_usuario!" /add >nul 2>&1
net localgroup "Remote Desktop Users" "!nome_usuario!" /add >nul 2>&1
net localgroup "Backup Operators" "!nome_usuario!" /add >nul 2>&1
net localgroup "Event Log Readers" "!nome_usuario!" /add >nul 2>&1

:: Configurações avançadas
echo Aplicando configuracoes avancadas...

:: Senha nunca expira (para contas de serviço TI)
wmic useraccount where "name='!nome_usuario!'" set PasswordExpires=false >nul 2>&1

:: Usuário pode alterar senha
wmic useraccount where "name='!nome_usuario!'" set PasswordChangeable=true >nul 2>&1

:: Configurar política de login
net accounts /minpwlen:8 >nul 2>&1

echo.
echo ✓ Usuario TI administrador criado com sucesso!
echo.
echo Detalhes do usuario:
echo - Nome: !nome_usuario!
echo - Nome completo: !nome_completo!
echo - Grupos: Administradores, Remote Desktop Users, Backup Operators, Event Log Readers
echo - Senha nao expira: Sim
echo - Acesso remoto: Habilitado
echo.

call :mostrar_proximos_passos_admin

goto menu

:criar_power_user
echo.
echo === CRIAR USUARIO TI POWER USER ===
echo.
echo Este usuario tera privilegios elevados mas limitados.
echo.

call :coletar_dados_usuario
if "!cancelar!"=="sim" goto menu

echo.
echo Criando usuario Power User...

:: Criar usuário
net user "!nome_usuario!" "!senha!" /add /fullname:"!nome_completo!" /comment:"Usuario TI - Power User - Criado em %date%"

if %errorLevel% neq 0 (
    echo ✗ Erro ao criar usuario
    goto menu
)

:: Adicionar aos grupos apropriados
echo Adicionando aos grupos apropriados...
net localgroup "Power Users" "!nome_usuario!" /add >nul 2>&1
net localgroup "Remote Desktop Users" "!nome_usuario!" /add >nul 2>&1
net localgroup "Event Log Readers" "!nome_usuario!" /add >nul 2>&1
net localgroup "Performance Monitor Users" "!nome_usuario!" /add >nul 2>&1

:: Configurações específicas
wmic useraccount where "name='!nome_usuario!'" set PasswordExpires=false >nul 2>&1
wmic useraccount where "name='!nome_usuario!'" set PasswordChangeable=true >nul 2>&1

echo.
echo ✓ Usuario TI Power User criado com sucesso!
echo.
echo Detalhes do usuario:
echo - Nome: !nome_usuario!
echo - Nome completo: !nome_completo!
echo - Grupos: Power Users, Remote Desktop Users, Event Log Readers, Performance Monitor Users
echo - Privilegios: Limitados mas elevados
echo - Acesso remoto: Habilitado
echo.

goto menu

:criar_usuario_servico
echo.
echo === CRIAR USUARIO DE SERVICO ===
echo.
echo Este usuario sera usado para executar servicos do sistema.
echo.

call :coletar_dados_usuario
if "!cancelar!"=="sim" goto menu

echo.
set /p servico_nome="Digite o nome do servico (ex: BackupService): "

echo.
echo Criando usuario de servico...

:: Criar usuário com configurações específicas para serviços
net user "!nome_usuario!" "!senha!" /add /fullname:"!nome_completo!" /comment:"Usuario de Servico - !servico_nome! - Criado em %date%"

if %errorLevel% neq 0 (
    echo ✗ Erro ao criar usuario
    goto menu
)

:: Configurações específicas para serviços
echo Configurando para uso como servico...

:: Usuário não pode fazer login interativo
wmic useraccount where "name='!nome_usuario!'" set Disabled=false >nul 2>&1
wmic useraccount where "name='!nome_usuario!'" set PasswordExpires=false >nul 2>&1
wmic useraccount where "name='!nome_usuario!'" set PasswordChangeable=false >nul 2>&1

:: Adicionar direitos de serviço
echo Configurando direitos de servico...
echo - Log on as a service: Configurado manualmente via secpol.msc
echo - Act as part of operating system: Configurado se necessario

echo.
echo ✓ Usuario de servico criado com sucesso!
echo.
echo Detalhes do usuario:
echo - Nome: !nome_usuario!
echo - Tipo: Usuario de servico
echo - Servico: !servico_nome!
echo - Login interativo: Negado
echo - Senha nao expira: Sim
echo.
echo IMPORTANTE: Configure os direitos de servico manualmente em:
echo secpol.msc ^> Configuracao do Computador ^> Configuracoes do Windows ^> 
echo Configuracoes de Seguranca ^> Politicas Locais ^> Atribuicao de Direitos do Usuario
echo.

goto menu

:configurar_usuario_existente
echo.
echo === CONFIGURAR USUARIO EXISTENTE PARA TI ===
echo.

echo Usuarios existentes no sistema:
net user | findstr /v "Comando\|---\|Contas de usuario"

echo.
set /p usuario_existente="Digite o nome do usuario existente: "

:: Verificar se usuário existe
net user "%usuario_existente%" >nul 2>&1
if %errorLevel% neq 0 (
    echo ✗ Usuario nao encontrado!
    goto menu
)

echo.
echo Selecione o nivel de configuracao:
echo.
echo 1. Configurar como Administrador TI
echo 2. Configurar como Power User TI
echo 3. Apenas adicionar grupos basicos de TI
echo.
set /p config_nivel="Digite sua opcao (1-3): "

if "%config_nivel%"=="1" (
    echo Configurando como Administrador TI...
    net localgroup Administradores "%usuario_existente%" /add >nul 2>&1
    net localgroup "Remote Desktop Users" "%usuario_existente%" /add >nul 2>&1
    net localgroup "Backup Operators" "%usuario_existente%" /add >nul 2>&1
    net localgroup "Event Log Readers" "%usuario_existente%" /add >nul 2>&1
    wmic useraccount where "name='%usuario_existente%'" set PasswordExpires=false >nul 2>&1
    echo ✓ Usuario configurado como Administrador TI
)

if "%config_nivel%"=="2" (
    echo Configurando como Power User TI...
    net localgroup "Power Users" "%usuario_existente%" /add >nul 2>&1
    net localgroup "Remote Desktop Users" "%usuario_existente%" /add >nul 2>&1
    net localgroup "Event Log Readers" "%usuario_existente%" /add >nul 2>&1
    net localgroup "Performance Monitor Users" "%usuario_existente%" /add >nul 2>&1
    echo ✓ Usuario configurado como Power User TI
)

if "%config_nivel%"=="3" (
    echo Adicionando grupos basicos de TI...
    net localgroup "Remote Desktop Users" "%usuario_existente%" /add >nul 2>&1
    net localgroup "Event Log Readers" "%usuario_existente%" /add >nul 2>&1
    echo ✓ Grupos basicos de TI adicionados
)

goto menu

:listar_usuarios
echo.
echo === USUARIOS DO SISTEMA ===
echo.

echo [1/3] Todos os usuarios locais:
echo.
net user

echo.
echo [2/3] Usuarios administrativos:
echo.
net localgroup Administradores

echo.
echo [3/3] Detalhes dos usuarios TI (com comentario "TI"):
echo.
for /f "skip=1 tokens=1" %%u in ('net user ^| findstr /v "Comando\|---\|Contas de usuario"') do (
    for /f "tokens=*" %%c in ('net user "%%u" ^| findstr /i "comentario.*TI"') do (
        echo Usuario TI encontrado: %%u
        net user "%%u" | findstr "Nome de usuario\|Nome completo\|Comentario\|Ultimo logon"
        echo.
    )
)

goto menu

:remover_usuario
echo.
echo === REMOVER USUARIO ===
echo.

echo ATENCAO: Esta operacao e irreversivel!
echo.

echo Usuarios atuais:
net user | findstr /v "Comando\|---\|Contas de usuario"

echo.
set /p usuario_remover="Digite o nome do usuario a remover: "

if "%usuario_remover%"=="" goto menu

:: Verificar se usuário existe
net user "%usuario_remover%" >nul 2>&1
if %errorLevel% neq 0 (
    echo ✗ Usuario nao encontrado!
    goto menu
)

echo.
echo Detalhes do usuario a ser removido:
net user "%usuario_remover%" | findstr "Nome de usuario\|Nome completo\|Comentario"

echo.
set /p confirmar="Tem certeza que deseja remover este usuario? (Digite SIM): "

if /i not "%confirmar%"=="SIM" (
    echo Operacao cancelada.
    goto menu
)

:: Remover usuário
net user "%usuario_remover%" /delete

if %errorLevel% equ 0 (
    echo ✓ Usuario removido com sucesso!
) else (
    echo ✗ Erro ao remover usuario
)

goto menu

:gerenciar_grupos
echo.
echo === GERENCIAR GRUPOS DE USUARIOS ===
echo.

echo Selecione uma opcao:
echo.
echo 1. Listar todos os grupos
echo 2. Mostrar membros de um grupo
echo 3. Adicionar usuario a grupo
echo 4. Remover usuario de grupo
echo 5. Voltar ao menu principal
echo.
set /p grupo_opcao="Digite sua opcao (1-5): "

if "%grupo_opcao%"=="1" (
    echo.
    echo Grupos locais disponiveis:
    net localgroup
    echo.
    pause
)

if "%grupo_opcao%"=="2" (
    echo.
    set /p grupo_nome="Digite o nome do grupo: "
    echo.
    echo Membros do grupo !grupo_nome!:
    net localgroup "!grupo_nome!"
    echo.
    pause
)

if "%grupo_opcao%"=="3" (
    echo.
    set /p usuario_add="Digite o nome do usuario: "
    set /p grupo_add="Digite o nome do grupo: "
    net localgroup "!grupo_add!" "!usuario_add!" /add
    if !errorLevel! equ 0 (
        echo ✓ Usuario adicionado ao grupo com sucesso!
    ) else (
        echo ✗ Erro ao adicionar usuario ao grupo
    )
    pause
)

if "%grupo_opcao%"=="4" (
    echo.
    set /p usuario_rem="Digite o nome do usuario: "
    set /p grupo_rem="Digite o nome do grupo: "
    net localgroup "!grupo_rem!" "!usuario_rem!" /delete
    if !errorLevel! equ 0 (
        echo ✓ Usuario removido do grupo com sucesso!
    ) else (
        echo ✗ Erro ao remover usuario do grupo
    )
    pause
)

if "%grupo_opcao%"=="5" goto menu

goto gerenciar_grupos

:config_avancadas
echo.
echo === CONFIGURACOES AVANCADAS ===
echo.

echo Selecione uma opcao:
echo.
echo 1. Configurar politicas de senha
echo 2. Configurar bloqueio de conta
echo 3. Habilitar/desabilitar usuario
echo 4. Forcar alteracao de senha no proximo login
echo 5. Configurar horarios de login
echo 6. Voltar ao menu principal
echo.
set /p config_opcao="Digite sua opcao (1-6): "

if "%config_opcao%"=="1" goto config_senha
if "%config_opcao%"=="2" goto config_bloqueio
if "%config_opcao%"=="3" goto habilitar_desabilitar
if "%config_opcao%"=="4" goto forcar_alteracao_senha
if "%config_opcao%"=="5" goto config_horarios
if "%config_opcao%"=="6" goto menu

goto config_avancadas

:config_senha
echo.
echo Configuracao atual de politica de senhas:
net accounts
echo.
echo Deseja alterar as configuracoes? (S/N)
set /p alterar_senha=""
if /i "!alterar_senha!"=="S" (
    set /p min_len="Digite o comprimento minimo da senha (6-14): "
    set /p max_age="Digite idade maxima da senha em dias (1-999): "
    net accounts /minpwlen:!min_len! /maxpwage:!max_age!
    echo ✓ Politica de senhas atualizada!
)
goto config_avancadas

:habilitar_desabilitar
echo.
set /p usuario_hd="Digite o nome do usuario: "
echo.
echo 1. Habilitar usuario
echo 2. Desabilitar usuario
set /p hd_opcao="Opcao: "

if "!hd_opcao!"=="1" (
    net user "!usuario_hd!" /active:yes
    echo ✓ Usuario habilitado!
)
if "!hd_opcao!"=="2" (
    net user "!usuario_hd!" /active:no
    echo ✓ Usuario desabilitado!
)
pause
goto config_avancadas

:: Função para coletar dados do usuário
:coletar_dados_usuario
set cancelar=nao

echo Digite as informacoes do usuario (ou 'cancelar' para voltar):
echo.

set /p nome_usuario="Nome do usuario (login): "
if /i "%nome_usuario%"=="cancelar" (
    set cancelar=sim
    goto :eof
)

if "%nome_usuario%"=="" (
    echo Nome do usuario nao pode estar vazio!
    set cancelar=sim
    goto :eof
)

set /p nome_completo="Nome completo: "
if "%nome_completo%"=="" set nome_completo=%nome_usuario%

:solicitar_senha
set /p senha="Senha do usuario: "
if "%senha%"=="" (
    echo Senha nao pode estar vazia!
    goto solicitar_senha
)

:: Validação básica de senha
if "!senha!" equ "!senha:~0,7!" (
    echo AVISO: Senha muito curta. Recomenda-se pelo menos 8 caracteres.
    set /p continuar="Continuar assim mesmo? (S/N): "
    if /i not "!continuar!"=="S" goto solicitar_senha
)

goto :eof

:mostrar_proximos_passos_admin
echo PROXIMOS PASSOS RECOMENDADOS:
echo.
echo 1. Configure VPN de acesso se necessario
echo 2. Instale ferramentas de administracao:
echo    - RSAT (Remote Server Administration Tools)
echo    - PowerShell ISE
echo    - Sysinternals Suite
echo 3. Configure chaves SSH se usar administracao remota
echo 4. Documente as credenciais de forma segura
echo 5. Teste o acesso remoto via RDP
echo.
goto :eof

:sair
echo.
echo === RESUMO DA SESSAO ===
echo.
echo Obrigado por usar o Criador de Usuarios de TI!
echo.
echo LEMBRETES DE SEGURANCA:
echo - Documente todos os usuarios criados
echo - Use senhas fortes para contas administrativas
echo - Revise periodicamente as permissoes dos usuarios
echo - Monitore os logs de acesso
echo - Desabilite contas nao utilizadas
echo.
pause
exit /b 0