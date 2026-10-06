@echo off
setlocal

:: Asegurar que Flutter este en el PATH de la sesion
set "PATH=C:\src\flutter\bin;%PATH%"

echo ===================================================
echo     Iniciando One Percent Man - Flutter
echo ===================================================
echo.
echo Selecciona el dispositivo de destino:
echo [1] Google Chrome (Web) - Recomendado
echo [2] Windows Desktop
echo [3] Seleccion automatica / interactiva de Flutter
echo.

set /p choice="Elige una opcion (1, 2 o 3) [defecto 1]: "

if "%choice%"=="2" (
    echo Iniciando en Windows Desktop...
    flutter run -d windows
) else if "%choice%"=="3" (
    echo Iniciando con seleccion de dispositivo...
    flutter run
) else (
    echo Iniciando en Google Chrome (http://localhost:5000)...
    flutter run -d chrome --web-port=5000
)

pause
