# Asegurar que Flutter este en el PATH de la sesion
$env:Path = "C:\src\flutter\bin;$env:Path"

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "    Iniciando One Percent Man - Flutter" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Selecciona el dispositivo de destino:"
Write-Host "[1] Google Chrome (Web) - Recomendado"
Write-Host "[2] Windows Desktop"
Write-Host "[3] Seleccion automatica de Flutter"
Write-Host ""

$choice = Read-Host "Elige una opcion (1, 2 o 3) [defecto 1]"

switch ($choice) {
    "2" {
        Write-Host "Iniciando en Windows Desktop..." -ForegroundColor Yellow
        flutter run -d windows
    }
    "3" {
        Write-Host "Iniciando con seleccion interactiva..." -ForegroundColor Yellow
        flutter run
    }
    Default {
        Write-Host "Iniciando en Google Chrome (http://localhost:5000)..." -ForegroundColor Yellow
        flutter run -d chrome --web-port=5000
    }
}
