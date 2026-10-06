#!/bin/bash

# Asegurar que Flutter este en el PATH
export PATH="/c/src/flutter/bin:$PATH"

echo "==================================================="
echo "    Iniciando One Percent Man - Flutter"
echo "==================================================="
echo ""
echo "Selecciona el dispositivo de destino:"
echo "1) Google Chrome (Web) - Recomendado"
echo "2) Windows Desktop"
echo "3) Seleccion automatica de Flutter"
echo ""

read -p "Elige una opcion (1, 2 o 3) [defecto 1]: " choice

case "$choice" in
  2)
    echo "Iniciando en Windows Desktop..."
    flutter run -d windows
    ;;
  3)
    echo "Iniciando..."
    flutter run
    ;;
  *)
    echo "Iniciando en Google Chrome (http://localhost:5000)..."
    flutter run -d chrome --web-port=5000
    ;;
esac
