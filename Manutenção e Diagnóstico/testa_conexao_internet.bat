@echo off
title Teste de Conexao com Internet
color 0B

echo ================================================
echo          TESTE DE CONEXAO COM INTERNET
echo ================================================
echo.

:: Lista de servidores para teste
set servers=8.8.8.8 1.1.1.1 google.com microsoft.com
set /a total_tests=0
set /a successful_tests=0

echo Iniciando testes de conectividade...
echo.

:: Testa cada servidor
for %%s in (%servers%) do (
    echo Testando conexao com %%s...
    ping -n 3 -w 3000 %%s >nul 2>&1
    set /a total_tests+=1
    
    if !errorlevel! equ 0 (
        echo ✓ %%s - CONECTADO
        set /a successful_tests+=1
    ) else (
        echo ✗ %%s - FALHA NA CONEXAO
    )
)

echo.
echo ================================================
echo                 TESTE DETALHADO
echo ================================================
echo.

:: Teste detalhado com Google DNS
echo Executando teste detalhado com Google DNS (8.8.8.8)...
echo.
ping -n 4 8.8.8.8

echo.
echo ================================================
echo              INFORMACOES DE REDE
echo ================================================
echo.

:: Mostra configuração de rede
echo Configuracao de rede atual:
echo.
ipconfig | findstr /i "IPv4 Gateway DNS"

echo.
echo ================================================
echo                  RESULTADOS
echo ================================================
echo.

:: Calcula porcentagem de sucesso
set /a success_rate=(%successful_tests% * 100) / %total_tests%

echo Testes realizados: %total_tests%
echo Testes bem-sucedidos: %successful_tests%
echo Taxa de sucesso: %success_rate%%%
echo.

:: Diagnóstico final
if %successful_tests% equ %total_tests% (
    echo ✓ STATUS: CONEXAO COM INTERNET OK
    echo Sua conexao com a internet esta funcionando normalmente.
) else if %successful_tests% gtr 0 (
    echo ⚠ STATUS: CONEXAO INSTAVEL
    echo Alguns testes falharam. Verifique sua conexao.
) else (
    echo ✗ STATUS: SEM CONEXAO COM INTERNET
    echo Nenhum teste foi bem-sucedido. Verifique:
    echo - Cabo de rede / WiFi
    echo - Configuracoes de rede
    echo - Firewall / Antivirus
    echo - Provedor de internet
)

echo.
echo ================================================
echo              OPCOES ADICIONAIS
echo ================================================
echo.

set /p advanced="Deseja executar diagnosticos avancados? (S/N): "
if /i "%advanced%"=="S" (
    echo.
    echo Executando diagnosticos avancados...
    echo.
    
    echo 1. Testando resolucao DNS...
    nslookup google.com
    
    echo.
    echo 2. Traceroute para Google...
    tracert -h 10 google.com
    
    echo.
    echo 3. Verificando tabela de roteamento...
    route print | findstr /i "0.0.0.0"
)

echo.
echo ================================================
echo                   CONCLUIDO
echo ================================================
echo.

:: Opção para repetir teste
set /p repeat="Deseja repetir o teste? (S/N): "
if /i "%repeat%"=="S" (
    cls
    goto :eof
)

pause