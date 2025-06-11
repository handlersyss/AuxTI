@echo off
title Diagnostico Completo do PC
color 0F

echo ================================================
echo           DIAGNOSTICO COMPLETO DO PC
echo ================================================
echo.

:: Verifica se está sendo executado como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo AVISO: Executando sem privilegios de administrador
    echo Alguns diagnosticos podem ser limitados.
    echo Para diagnostico completo, execute como administrador.
    echo.
)

echo Este script ira executar um diagnostico completo incluindo:
echo.
echo - Informacoes do sistema
echo - Status de hardware
echo - Memoria e armazenamento
echo - Rede e conectividade
echo - Servicos e processos
echo - Verificacao de integridade
echo - Temperatura e performance
echo.

set /p confirm="Deseja iniciar o diagnostico? (S/N): "
if /i not "%confirm%"=="S" (
    echo Diagnostico cancelado pelo usuario.
    pause
    exit /b 0
)

:: Cria pasta para relatórios
if not exist "DiagnosticoPc" mkdir DiagnosticoPc
set report_dir=DiagnosticoPc
set timestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set timestamp=%timestamp: =0%

echo.
echo ================================================
echo          1. INFORMACOES DO SISTEMA
echo ================================================
echo.

echo Coletando informacoes basicas do sistema...
systeminfo | findstr /C:"Nome do host" /C:"Nome do SO" /C:"Versão do SO" /C:"Fabricante do sistema" /C:"Modelo do sistema" /C:"Tipo de sistema" /C:"Processador" /C:"Memoria fisica total"

echo.
echo Versao do Windows:
ver

echo.
echo Tempo de atividade do sistema:
systeminfo | findstr /C:"Tempo de inicializacao do sistema"

echo.
echo ================================================
echo             2. STATUS DE HARDWARE
echo ================================================
echo.

echo Informacoes da CPU:
wmic cpu get name,maxclockspeed,numberofcores,numberoflogicalprocessors /format:table

echo.
echo Informacoes da memoria RAM:
wmic memorychip get capacity,speed,manufacturer /format:table

echo.
echo Informacoes da placa mae:
wmic baseboard get manufacturer,product,version /format:table

echo.
echo Placas de video:
wmic path win32_VideoController get name,adapterram /format:table

echo.
echo ================================================
echo          3. MEMORIA E ARMAZENAMENTO
echo ================================================
echo.

echo Status da memoria:
wmic OS get TotalVisibleMemorySize,FreePhysicalMemory /format:table

echo.
echo Uso de memoria detalhado:
for /f "skip=1" %%i in ('wmic OS get FreePhysicalMemory /value') do if "%%i" neq "" set free_mem=%%i
for /f "skip=1" %%i in ('wmic OS get TotalVisibleMemorySize /value') do if "%%i" neq "" set total_mem=%%i
set /a used_mem=%total_mem% - %free_mem%
set /a mem_percent=(%used_mem% * 100) / %total_mem%
echo Memoria usada: %mem_percent%%%

echo.
echo Informacoes dos discos:
wmic diskdrive get size,model,status /format:table

echo.
echo Espaco em disco:
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%d:\ (
        echo.
        echo Disco %%d:
        dir %%d:\ | findstr /C:"bytes livres"
    )
)

echo.
echo ================================================
echo           4. REDE E CONECTIVIDADE
echo ================================================
echo.

echo Configuracao de rede:
ipconfig /all | findstr /C:"Adaptador" /C:"IPv4" /C:"Gateway" /C:"DNS"

echo.
echo Teste de conectividade:
ping -n 2 8.8.8.8 >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Conectividade com internet: OK
) else (
    echo ✗ Conectividade com internet: FALHA
)

echo.
echo Portas de rede ativas:
netstat -an | findstr LISTENING | findstr :80 >nul && echo Porta 80 (HTTP): Ativa
netstat -an | findstr LISTENING | findstr :443 >nul && echo Porta 443 (HTTPS): Ativa
netstat -an | findstr LISTENING | findstr :3389 >nul && echo Porta 3389 (RDP): Ativa

echo.
echo ================================================
echo          5. SERVICOS E PROCESSOS
echo ================================================
echo.

echo Servicos criticos:
sc query "Themes" | findstr STATE
sc query "AudioSrv" | findstr STATE
sc query "BITS" | findstr STATE
sc query "Dhcp" | findstr STATE
sc query "Dnscache" | findstr STATE
sc query "EventLog" | findstr STATE
sc query "lanmanserver" | findstr STATE
sc query "LanmanWorkstation" | findstr STATE
sc query "RpcSs" | findstr STATE
sc query "Schedule" | findstr STATE
sc query "W32Time" | findstr STATE
sc query "Winmgmt" | findstr STATE
sc query "WSearch" | findstr STATE

echo.
echo Top 10 processos por uso de CPU:
wmic process get name,processid,percentprocessortime /format:table 2>nul | more +1 | head -10

echo.
echo Processos usando mais memoria:
tasklist /fo table | sort /r /+5 | more +3 | head -10

echo.
echo ================================================
echo        6. VERIFICACAO DE INTEGRIDADE
echo ================================================
echo.

echo Verificando integridade dos arquivos do sistema...
echo (Esta operacao pode levar alguns minutos)
sfc /verifyonly >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Integridade dos arquivos do sistema: OK
) else (
    echo ⚠ Problemas encontrados na integridade dos arquivos
    echo Execute "sfc /scannow" como administrador para corrigir
)

echo.
echo Verificando saude do disco C:
chkdsk C: /f /v >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Disco C: parece estar saudavel
) else (
    echo ⚠ Problemas potenciais no disco C:
    echo Execute "chkdsk C: /f" como administrador para verificar
)

echo.
echo ================================================
echo        7. TEMPERATURA E PERFORMANCE
echo ================================================
echo.

echo Informacoes de temperatura (via WMI):
wmic /namespace:\\root\wmi path MSAcpi_ThermalZoneTemperature get CurrentTemperature 2>nul
if %errorLevel% neq 0 (
    echo Informacoes de temperatura nao disponiveis via WMI
)

echo.
echo Performance do sistema:
wmic cpu get loadpercentage /value | findstr LoadPercentage

echo.
echo Informacoes de energia:
powercfg /query | findstr /C:"Esquema de energia ativo"

echo.
echo ================================================
echo             8. EVENTOS DO SISTEMA
echo ================================================
echo.

echo Verificando eventos criticos recentes...
wevtutil qe System /c:5 /rd:true /f:text /q:"*[System[(Level=1 or Level=2)]]" 2>nul
if %errorLevel% neq 0 (
    echo Nenhum evento critico recente encontrado
)

echo.
echo Verificando eventos de aplicacao...
wevtutil qe Application /c:3 /rd:true /f:text /q:"*[System[Level=2]]" 2>nul
if %errorLevel% neq 0 (
    echo Nenhum erro de aplicacao recente encontrado
)

echo.
echo ================================================
echo               RELATORIO FINAL
echo ================================================
echo.

:: Gera relatório resumido
echo Gerando relatorio resumido...
(
    echo DIAGNOSTICO PC - %date% %time%
    echo ================================
    echo.
    systeminfo | findstr /C:"Nome do host" /C:"Nome do SO" /C:"Processador" /C:"Memoria fisica total"
    echo.
    echo STATUS GERAL:
    ping -n 1 8.8.8.8 >nul 2>&1 && echo ✓ Internet: OK || echo ✗ Internet: PROBLEMA
    sfc /verifyonly >nul 2>&1 && echo ✓ Integridade: OK || echo ⚠ Integridade: VERIFICAR
    echo.
    echo RECURSOS:
    for /f "skip=1" %%i in ('wmic OS get FreePhysicalMemory /value') do if "%%i" neq "" set free_mem=%%i
    for /f "skip=1" %%i in ('wmic OS get TotalVisibleMemorySize /value') do if "%%i" neq "" set total_mem=%%i
    set /a used_mem=!total_mem! - !free_mem!
    set /a mem_percent=^(!used_mem! * 100^) / !total_mem!
    echo Memoria usada: !mem_percent!%%
    echo.
) > "%report_dir%\diagnostico_%timestamp%.txt"

echo ✓ Relatorio salvo em: %report_dir%\diagnostico_%timestamp%.txt

echo.
echo RESUMO DO DIAGNOSTICO:
echo - Informacoes do sistema coletadas
echo - Hardware verificado
echo - Memoria e armazenamento analisados
echo - Rede testada
echo - Servicos verificados
echo - Integridade checada
echo - Performance avaliada
echo - Eventos do sistema revisados
echo.

echo ================================================
echo             DIAGNOSTICO CONCLUIDO
echo ================================================
echo.
echo O diagnostico foi concluido com sucesso!
echo.
echo PROXIMOS PASSOS RECOMENDADOS:
echo 1. Revisar o relatorio gerado
echo 2. Corrigir problemas identificados
echo 3. Executar limpeza se necessario
echo 4. Monitorar performance nos proximos dias
echo.

set /p view_report="Deseja abrir o relatorio agora? (S/N): "
if /i "%view_report%"=="S" (
    notepad "%report_dir%\diagnostico_%timestamp%.txt"
)

pause