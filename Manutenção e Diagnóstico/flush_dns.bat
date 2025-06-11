@echo off
title Flush DNS Cache
color 0E

echo ================================================
echo              FLUSH DNS CACHE
echo ================================================
echo.

:: Verifica se está sendo executado como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo AVISO: Executando sem privilegios de administrador
    echo Algumas operacoes podem falhar.
    echo Para melhor resultado, execute como administrador.
    echo.
)

echo Este script ira limpar completamente o cache DNS.
echo.
echo Operacoes que serao executadas:
echo - Exibir cache DNS atual
echo - Limpar cache DNS do sistema
echo - Reiniciar servico DNS Client
echo - Verificar limpeza
echo.

set /p confirm="Deseja continuar? (S/N): "
if /i not "%confirm%"=="S" (
    echo Operacao cancelada pelo usuario.
    pause
    exit /b 0
)

echo.
echo ================================================
echo            INFORMACOES ATUAIS
echo ================================================
echo.

:: Mostra informações do cache DNS atual
echo Cache DNS atual:
ipconfig /displaydns | findstr /i "Record Name" | find /c "Record Name" > temp_count.txt
set /p dns_count=<temp_count.txt
del temp_count.txt >nul 2>&1

if %dns_count% gtr 0 (
    echo Encontradas %dns_count% entradas no cache DNS
) else (
    echo Cache DNS parece estar vazio
)

echo.
echo Exemplo de entradas no cache:
ipconfig /displaydns | findstr /i "Record Name" | more +0 | head -5 2>nul

echo.
echo ================================================
echo              LIMPANDO CACHE DNS
echo ================================================
echo.

:: Executa o flush DNS
echo Executando flush DNS...
ipconfig /flushdns

if %errorLevel% equ 0 (
    echo Cache DNS limpo com sucesso!
) else (
    echo Erro ao limpar cache DNS
    echo Codigo de erro: %errorLevel%
)

echo.

:: Reinicia o serviço DNS Client (se executado como admin)
echo Tentando reiniciar servico DNS Client...
net stop dnscache >nul 2>&1
if %errorLevel% equ 0 (
    net start dnscache >nul 2>&1
    if !errorLevel! equ 0 (
        echo Servico DNS Client reiniciado
    ) else (
        echo Erro ao iniciar servico DNS Client
    )
) else (
    echo Nao foi possivel reiniciar servico (privilegios insuficientes)
)

echo.
echo ================================================
echo              VERIFICACAO
echo ================================================
echo.

:: Verifica se o cache foi realmente limpo
echo Verificando limpeza do cache...
ipconfig /displaydns | findstr /i "Record Name" | find /c "Record Name" > temp_count2.txt
set /p new_dns_count=<temp_count2.txt
del temp_count2.txt >nul 2>&1

if %new_dns_count% equ 0 (
    echo Cache DNS completamente limpo
) else (
    echo Ainda existem %new_dns_count% entradas no cache
    echo Isso e normal - algumas entradas sao recriadas automaticamente
)

echo.
echo ================================================
echo              TESTE DE DNS
echo ================================================
echo.

:: Teste rápido de resolução DNS
echo Testando resolucao DNS...
nslookup google.com >nul 2>&1
if %errorLevel% equ 0 (
    echo Resolucao DNS funcionando normalmente
    
    :: Mostra tempo de resposta
    echo.
    echo Teste de conectividade:
    ping -n 1 8.8.8.8 | findstr /i "tempo"
) else (
    echo Problema na resolucao DNS
    echo Verifique sua conexao com a internet
)

echo.
echo ================================================
echo              INFORMACOES UTEIS
echo ================================================
echo.
echo QUANDO FAZER FLUSH DNS:
echo - Sites nao carregam mas internet funciona
echo - Mudanca de servidor DNS
echo - Problemas de navegacao apos alteracoes de rede
echo - Erro "Nao foi possivel encontrar o servidor"
echo.
echo COMANDOS RELACIONADOS:
echo - ipconfig /flushdns    ^| Limpa cache DNS
echo - ipconfig /displaydns  ^| Mostra cache atual
echo - nslookup [site]       ^| Testa resolucao de nome
echo.

echo ================================================
echo                  CONCLUIDO
echo ================================================
echo.
echo Flush DNS executado com sucesso!
echo.
echo DICA: Se ainda houver problemas de DNS, considere:
echo 1. Reiniciar o navegador
echo 2. Trocar servidor DNS (ex: 8.8.8.8 ou 1.1.1.1)
echo 3. Reiniciar o computador
echo.

pause