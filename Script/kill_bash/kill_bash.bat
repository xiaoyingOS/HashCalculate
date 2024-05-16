@echo off
chcp 65001 > nul

:loop
tasklist /FI "IMAGENAME eq bash.exe" 2>NUL | find /I /N "bash.exe" >NUL
if "%ERRORLEVEL%"=="0" (
    taskkill /F /IM bash.exe
    timeout /t 5 /nobreak >nul
    goto loop
)


pause
