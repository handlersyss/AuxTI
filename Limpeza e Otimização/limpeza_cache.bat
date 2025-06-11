@echo off
echo ==========================================
echo    LIMPEZA DE CACHE DO SISTEMA
echo ==========================================
echo.

echo Iniciando limpeza de cache...
echo.

echo [1/8] Limpando arquivos temporarios do Windows...
del /q /f /s %temp%\*.* 2>nul
for /d %%i in (%temp%\*) do rd /s /q "%%i" 2>nul

echo [2/8] Limpando arquivos temporarios do sistema...
del /q /f /s C:\Windows\Temp\*.* 2>nul
for /d %%i in (C:\Windows\Temp\*) do rd /s /q "%%i" 2>nul

echo [3/8] Limpando cache de prefetch...
del /q /f /s C:\Windows\Prefetch\*.* 2>nul

echo [4/8] Limpando arquivos de log temporarios...
del /q /f /s C:\Windows\Logs\*.log 2>nul

echo [5/8] Limpando cache do Windows Update...
net stop wuauserv >nul 2>&1
del /q /f /s C:\Windows\SoftwareDistribution\Download\*.* 2>nul
for /d %%i in (C:\Windows\SoftwareDistribution\Download\*) do rd /s /q "%%i" 2>nul
net start wuauserv >nul 2>&1

echo [6/8] Limpando cache DNS...
ipconfig /flushdns >nul

echo [7/8] Limpando Lixeira...
rd /s /q C:\$Recycle.Bin 2>nul

echo [8/8] Executando limpeza de disco do sistema...
cleanmgr /sagerun:1 /verylowdisk

echo.
echo ==========================================
echo    LIMPEZA DE CACHE CONCLUIDA!
echo ==========================================
echo.

echo Estatisticas da limpeza:
echo - Arquivos temporarios: Removidos
echo - Cache de prefetch: Limpo
echo - Cache DNS: Renovado
echo - Cache Windows Update: Limpo
echo - Lixeira: Esvaziada
echo.

echo Pressione qualquer tecla para fechar...
pause >nul