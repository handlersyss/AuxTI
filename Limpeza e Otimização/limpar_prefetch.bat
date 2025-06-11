@echo off
title Limpeza de Prefetch
color 0A

echo ================================================
echo          LIMPEZA DE ARQUIVOS PREFETCH
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

:: Exibe informações antes da limpeza
echo Verificando arquivos prefetch...
echo.

:: Conta quantos arquivos existem
for /f %%i in ('dir /b "%SystemRoot%\Prefetch\*.pf" 2^>nul ^| find /c /v ""') do set count=%%i

if %count% equ 0 (
    echo Nenhum arquivo prefetch encontrado para limpar.
    echo.
    pause
    exit /b 0
)

echo Encontrados %count% arquivo(s) prefetch para limpeza.
echo.

:: Confirmação do usuário
set /p confirm="Deseja continuar com a limpeza? (S/N): "
if /i not "%confirm%"=="S" (
    echo Operacao cancelada pelo usuario.
    pause
    exit /b 0
)

echo.
echo Iniciando limpeza...
echo.

:: Limpa os arquivos prefetch
del /q "%SystemRoot%\Prefetch\*.pf" 2>nul

:: Verifica se a limpeza foi bem-sucedida
if %errorLevel% equ 0 (
    echo ✓ Limpeza concluida com sucesso!
    echo ✓ %count% arquivo(s) prefetch removido(s).
) else (
    echo ✗ Erro durante a limpeza dos arquivos prefetch.
    echo Alguns arquivos podem estar em uso pelo sistema.
)

echo.
echo ================================================
echo                   CONCLUIDO
echo ================================================
echo.
pause