@echo off
echo ==========================================
echo    LIMPEZA DA FILA DE IMPRESSAO
echo ==========================================
echo.

echo Parando o servico de spooler de impressao...
net stop spooler

echo.
echo Aguardando o servico parar completamente...
timeout /t 3 /nobreak >nul

echo.
echo Limpando arquivos da fila de impressao...
del /q /f %systemroot%\System32\spool\PRINTERS\*.*

echo.
echo Reiniciando o servico de spooler de impressao...
net start spooler

echo.
echo ==========================================
echo    LIMPEZA CONCLUIDA COM SUCESSO!
echo ==========================================
echo.

echo Pressione qualquer tecla para fechar...
pause >nul