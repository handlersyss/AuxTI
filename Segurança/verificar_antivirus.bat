@echo off
setlocal enabledelayedexpansion

:: =============================================================================
:: VERIFICADOR DE ANTIVIRUS E SEGURANCA DO WINDOWS
:: =============================================================================

echo ========================================
echo    VERIFICADOR DE ANTIVIRUS
echo ========================================
echo.

:: Verificar se está rodando como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo AVISO: Para informacoes completas, execute como Administrador.
    echo Algumas verificacoes podem ser limitadas.
    echo.
)

:menu
echo.
echo Selecione uma opcao:
echo.
echo 1. Verificacao rapida de antivirus
echo 2. Verificacao completa de seguranca
echo 3. Status do Windows Defender
echo 4. Listar todos os softwares de seguranca
echo 5. Verificar atualizacoes de definicoes
echo 6. Executar scan rapido do Defender
echo 7. Verificar historico de ameacas
echo 8. Relatorio completo (salvar em arquivo)
echo 9. Sair
echo.
set /p opcao="Digite sua opcao (1-9): "

if "%opcao%"=="1" goto verificacao_rapida
if "%opcao%"=="2" goto verificacao_completa
if "%opcao%"=="3" goto status_defender
if "%opcao%"=="4" goto listar_seguranca
if "%opcao%"=="5" goto verificar_atualizacoes
if "%opcao%"=="6" goto scan_rapido
if "%opcao%"=="7" goto historico_ameacas
if "%opcao%"=="8" goto relatorio_completo
if "%opcao%"=="9" goto sair

echo Opcao invalida!
goto menu

:verificacao_rapida
echo.
echo === VERIFICACAO RAPIDA DE ANTIVIRUS ===
echo.

echo [1/4] Verificando Windows Defender...
powershell -Command "Get-MpPreference | Select-Object DisableRealtimeMonitoring, DisableBehaviorMonitoring" 2>nul
if %errorLevel% neq 0 (
    echo ⚠ Nao foi possivel acessar informacoes do Windows Defender
) else (
    powershell -Command "if ((Get-MpPreference).DisableRealtimeMonitoring -eq $false) { Write-Host '✓ Windows Defender: ATIVO' -ForegroundColor Green } else { Write-Host '✗ Windows Defender: INATIVO' -ForegroundColor Red }" 2>nul
)

echo.
echo [2/4] Verificando Security Center...
wmic /namespace:\\root\SecurityCenter2 path AntiVirusProduct get displayName,productState /format:list 2>nul | findstr /v "^$"

echo.
echo [3/4] Verificando servicos de seguranca...
echo Windows Defender Antivirus Service:
sc query WinDefend | findstr STATE
echo Windows Security Service:
sc query SecurityHealthService | findstr STATE

echo.
echo [4/4] Verificando firewall...
netsh advfirewall show allprofiles state | findstr /i "estado"

echo.
echo === RESUMO DA VERIFICACAO RAPIDA ===
call :avaliar_seguranca

goto menu

:verificacao_completa
echo.
echo === VERIFICACAO COMPLETA DE SEGURANCA ===
echo.

echo [1/8] Informacoes do sistema...
echo Sistema: 
systeminfo | findstr /i "nome do sistema operacional\|versao do sistema operacional"

echo.
echo [2/8] Status do Windows Defender...
powershell -Command "Get-MpComputerStatus | Select-Object AntivirusEnabled, RealTimeProtectionEnabled, BehaviorMonitorEnabled, IoavProtectionEnabled, NISEnabled, QuickScanAge, FullScanAge" 2>nul

echo.
echo [3/8] Produtos antivirus instalados...
wmic /namespace:\\root\SecurityCenter2 path AntiVirusProduct get displayName,productState,pathToSignedProductExe /format:list 2>nul

echo.
echo [4/8] Softwares anti-spyware...
wmic /namespace:\\root\SecurityCenter2 path AntiSpywareProduct get displayName,productState /format:list 2>nul

echo.
echo [5/8] Status dos servicos criticos...
echo.
set servicos=WinDefend SecurityHealthService wscsvc Sense WdNisSvc
for %%s in (%servicos%) do (
    echo Servico %%s:
    sc query %%s 2>nul | findstr "STATE\|SERVICE_NAME" || echo   Servico nao encontrado
    echo.
)

echo.
echo [6/8] Verificando processos de seguranca ativos...
tasklist /fi "imagename eq MsMpEng.exe" /fo table /nh 2>nul | findstr /v "INFO:"
tasklist /fi "imagename eq NisSrv.exe" /fo table /nh 2>nul | findstr /v "INFO:"

echo.
echo [7/8] Configuracoes de UAC...
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA 2>nul | findstr EnableLUA

echo.
echo [8/8] Atualizacoes do Windows...
powershell -Command "Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5 | Format-Table Description, HotFixID, InstalledOn" 2>nul

echo.
echo === AVALIACAO COMPLETA ===
call :avaliar_seguranca_completa

goto menu

:status_defender
echo.
echo === STATUS DETALHADO DO WINDOWS DEFENDER ===
echo.

echo Obtendo informacoes detalhadas do Windows Defender...
echo.

powershell -Command "
try {
    $status = Get-MpComputerStatus
    $prefs = Get-MpPreference
    
    Write-Host '=== STATUS GERAL ===' -ForegroundColor Cyan
    Write-Host ('Antivirus habilitado: ' + $status.AntivirusEnabled)
    Write-Host ('Protecao em tempo real: ' + $status.RealTimeProtectionEnabled)
    Write-Host ('Protecao comportamental: ' + $status.BehaviorMonitorEnabled)
    Write-Host ('Protecao IOAV: ' + $status.IoavProtectionEnabled)
    Write-Host ('Network Inspection Service: ' + $status.NISEnabled)
    
    Write-Host '' 
    Write-Host '=== SCANS RECENTES ===' -ForegroundColor Cyan
    Write-Host ('Ultimo scan rapido: ' + $status.QuickScanAge) 
    Write-Host ('Ultimo scan completo: ' + $status.FullScanAge)
    Write-Host ('Versao do antivirus: ' + $status.AntivirusSignatureVersion)
    Write-Host ('Versao NIS: ' + $status.NISSignatureVersion)
    
    Write-Host '' 
    Write-Host '=== CONFIGURACOES ===' -ForegroundColor Cyan
    Write-Host ('Exclusoes de arquivos: ' + $prefs.ExclusionPath.Count)
    Write-Host ('Exclusoes de processos: ' + $prefs.ExclusionProcess.Count)
    Write-Host ('Scan de arquivos baixados: ' + (-not $prefs.DisableIOAVProtection))
    
} catch {
    Write-Host 'Erro ao obter informacoes do Windows Defender' -ForegroundColor Red
}
" 2>nul

if %errorLevel% neq 0 (
    echo ⚠ Nao foi possivel obter informacoes detalhadas do Windows Defender
    echo Isso pode indicar que o Defender nao esta instalado ou ativo.
)

goto menu

:listar_seguranca
echo.
echo === TODOS OS SOFTWARES DE SEGURANCA ===
echo.

echo [1/3] Produtos antivirus registrados...
echo.
wmic /namespace:\\root\SecurityCenter2 path AntiVirusProduct get displayName,productState,pathToSignedProductExe,timestamp /format:table 2>nul

echo.
echo [2/3] Produtos anti-spyware registrados...
echo.
wmic /namespace:\\root\SecurityCenter2 path AntiSpywareProduct get displayName,productState,pathToSignedProductExe /format:table 2>nul

echo.
echo [3/3] Programas de seguranca instalados (via registro)...
echo.
echo Procurando por software de seguranca conhecido...

set software_seguranca=Norton Kaspersky McAfee Avast AVG Bitdefender ESET Malwarebytes Avira Sophos Trend
for %%s in (%software_seguranca%) do (
    reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "%%s" 2>nul | findstr "DisplayName" | head -1
)

goto menu

:verificar_atualizacoes
echo.
echo === VERIFICACAO DE ATUALIZACOES ===
echo.

echo [1/2] Verificando definicoes do Windows Defender...
powershell -Command "
try {
    $status = Get-MpComputerStatus
    Write-Host 'Versao das definicoes de virus: ' $status.AntivirusSignatureVersion
    Write-Host 'Data da ultima atualizacao: ' $status.AntivirusSignatureLastUpdated
    Write-Host 'Versao do engine: ' $status.AMEngineVersion
    
    Write-Host ''
    Write-Host 'Iniciando verificacao de atualizacoes...'
    Update-MpSignature
    Write-Host 'Verificacao de atualizacoes concluida!'
    
} catch {
    Write-Host 'Erro ao verificar/atualizar definicoes' -ForegroundColor Red
}
" 2>nul

echo.
echo [2/2] Status do Windows Update...
powershell -Command "Get-Service wuauserv | Select-Object Name, Status" 2>nul

goto menu

:scan_rapido
echo.
echo === EXECUTANDO SCAN RAPIDO ===
echo.

echo ATENCAO: Esta operacao pode demorar alguns minutos...
echo.

powershell -Command "
Write-Host 'Iniciando scan rapido do Windows Defender...'
try {
    Start-MpScan -ScanType QuickScan
    Write-Host 'Scan rapido concluido com sucesso!' -ForegroundColor Green
} catch {
    Write-Host 'Erro ao executar scan rapido: ' $_.Exception.Message -ForegroundColor Red
}
" 2>nul

if %errorLevel% neq 0 (
    echo ⚠ Nao foi possivel executar o scan rapido
    echo Verifique se o Windows Defender esta ativo e funcionando
)

goto menu

:historico_ameacas
echo.
echo === HISTORICO DE AMEACAS ===
echo.

echo [1/2] Ameacas detectadas recentemente...
powershell -Command "
try {
    $threats = Get-MpThreatDetection | Sort-Object InitialDetectionTime -Descending | Select-Object -First 10
    if ($threats) {
        $threats | Format-Table ThreatName, InitialDetectionTime, ActionSuccess, Resources -AutoSize
    } else {
        Write-Host 'Nenhuma ameaca detectada recentemente.' -ForegroundColor Green
    }
} catch {
    Write-Host 'Nao foi possivel acessar o historico de ameacas'
}
" 2>nul

echo.
echo [2/2] Verificando logs do sistema...
echo Eventos recentes do Windows Defender:
wevtutil qe "Microsoft-Windows-Windows Defender/Operational" /c:5 /rd:true /f:text 2>nul | findstr /i "ameaca\|threat\|virus\|malware" | head -5

goto menu

:relatorio_completo
echo.
echo === GERANDO RELATORIO COMPLETO ===
echo.

set relatorio=%USERPROFILE%\Desktop\relatorio_antivirus_%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%.txt
set relatorio=%relatorio: =0%

echo Gerando relatorio completo...
echo Local: %relatorio%
echo.

(
echo ========================================
echo RELATORIO DE VERIFICACAO DE ANTIVIRUS
echo Data: %date% %time%
echo Sistema: %COMPUTERNAME%
echo ========================================
echo.

echo === INFORMACOES DO SISTEMA ===
systeminfo | findstr /i "nome do sistema operacional\|versao\|fabricante"

echo.
echo === PRODUTOS ANTIVIRUS ===
wmic /namespace:\\root\SecurityCenter2 path AntiVirusProduct get displayName,productState,pathToSignedProductExe /format:list 2>nul

echo.
echo === STATUS WINDOWS DEFENDER ===
powershell -Command "Get-MpComputerStatus | Format-List" 2>nul

echo.
echo === SERVICOS DE SEGURANCA ===
sc query WinDefend
sc query SecurityHealthService
sc query wscsvc

echo.
echo === CONFIGURACOES DE FIREWALL ===
netsh advfirewall show allprofiles state

echo.
echo === ATUALIZACOES RECENTES ===
powershell -Command "Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10 | Format-Table" 2>nul

echo.
echo === PROCESSOS DE SEGURANCA ===
tasklist | findstr /i "defender\|antivirus\|security"

echo.
echo ========================================
echo Relatorio gerado em: %date% %time%
echo ========================================
) > "%relatorio%"

if exist "%relatorio%" (
    echo ✓ Relatorio gerado com sucesso!
    echo Arquivo: %relatorio%
    echo.
    set /p abrir="Deseja abrir o relatorio? (S/N): "
    if /i "!abrir!"=="S" notepad "%relatorio%"
) else (
    echo ✗ Erro ao gerar relatorio
)

goto menu

:avaliar_seguranca
echo.
set /a pontuacao=0

:: Verificar Windows Defender
powershell -Command "if ((Get-MpPreference).DisableRealtimeMonitoring -eq $false) { exit 0 } else { exit 1 }" 2>nul
if %errorLevel% equ 0 (
    echo ✓ Windows Defender ativo [+2 pontos]
    set /a pontuacao+=2
) else (
    echo ✗ Windows Defender inativo [-2 pontos]
    set /a pontuacao-=2
)

:: Verificar firewall
for /f %%a in ('netsh advfirewall show allprofiles state ^| findstr /i "ativado" ^| find /c "ativado"') do (
    if %%a gtr 0 (
        echo ✓ Firewall ativo [+1 ponto]
        set /a pontuacao+=1
    ) else (
        echo ✗ Firewall inativo [-1 ponto]
        set /a pontuacao-=1
    )
)

:: Avaliar pontuação
echo.
echo Pontuacao de seguranca: %pontuacao%
if %pontuacao% geq 3 (
    echo Status: ✓ BOM - Sistema bem protegido
) else if %pontuacao% geq 1 (
    echo Status: ⚠ REGULAR - Melhorias recomendadas
) else (
    echo Status: ✗ RUIM - Seguranca comprometida
)

goto :eof

:avaliar_seguranca_completa
echo.
echo Baseado na verificacao completa:
echo - Verifique se todos os servicos de seguranca estao ativos
echo - Mantenha as definicoes de virus atualizadas
echo - Execute scans regulares do sistema
echo - Mantenha o Windows atualizado
echo.
goto :eof

:sair
echo.
echo === RESUMO FINAL ===
echo.
call :avaliar_seguranca
echo.
echo Recomendacoes gerais:
echo - Mantenha o antivirus sempre ativo
echo - Execute scans regulares
echo - Mantenha as definicoes atualizadas
echo - Use sempre um firewall ativo
echo - Mantenha o Windows atualizado
echo.
echo Obrigado por usar o Verificador de Antivirus!
echo.
pause
exit /b 0