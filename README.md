# One Percent Man - Life OS

Una aplicación de productividad y gestión de estilo de vida moderna y minimalista, diseñada para ayudarte a ser un 1% mejor cada día.

## 🚀 Inicio Rápido

Sigue estos pasos para ejecutar el proyecto en tu entorno local.

### Requisitos Previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.
- Un emulador de Android/iOS o un navegador (Chrome) para la ejecución.

### Instalación y Ejecución

1.  **Obtener las dependencias**
    Ejecuta el siguiente comando en la raíz del proyecto para descargar todos los paquetes necesarios:

    ```bash
    flutter pub get
    ```

2.  **Ejecutar la aplicación**
    Para iniciar el proyecto, utiliza:
    _Si tienes múltiples dispositivos conectados, puedes listar los IDs con `flutter devices` y ejecutar con `flutter run -d <DEVICE_ID>`._

### Generar APK (Android)

Para generar el archivo ejecutable para Android, utiliza el siguiente comando:

1.  **Build Estándar**:

    ```bash
    flutter build apk --release
    ```

2.  **Build Optimizado (Split by ABI)**:
    Si deseas reducir el tamaño del archivo generando APKs específicos para cada arquitectura (arm64, armeabi, x64):
    ```bash
    flutter build apk --split-per-abi
    ```

_El archivo resultante se encontrará en: `build/app/outputs/flutter-apk/app-release.apk`_

## ✨ Características Principales

- **Dashboard**: Vista centralizada de tu progreso diario.
- **Horarios**: Gestión de actividades y bloques de tiempo.
- **Notas**: Espacio para tus ideas y reflexiones.
- **Metas**: Seguimiento de objetivos a corto y largo plazo.
- **Comunidad**: Participa en el "Consejo de Hombres".
- **Rachas y Leaderboard**: Gamificación del progreso personal.

## 🛠️ Stack Tecnológico

- **Framework**: Flutter
- **Estado**: Riverpod
- **Iconografía**: Lucide Icons
- **Tipografía**: Google Fonts (Inter/Outfit)

---

_Diseñado para la excelencia y el crecimiento constante._
