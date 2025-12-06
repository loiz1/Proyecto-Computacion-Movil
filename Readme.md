# 📦 Envii - Sistema de Gestión y Análisis de Despachos

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-3.0+-074B80?style=for-the-badge&logo=sqlite&logoColor=white)

Envii es una aplicación móvil Flutter para la gestión y análisis de despachos de mercancía a nivel nacional. Permite visualizar, analizar y gestionar información sobre cajas, peso, costo, volumen y clientes mediante dashboards interactivos con gráficos y filtros dinámicos.

## Link de descarga del APK

https://drive.google.com/file/d/1lKg3WGkvbIi3O9-g1HoZWvaGrLb047Uu/view?usp=sharing

## ✨ Características Principales

### 🔐 Sistema de Autenticación
- ✅ Autenticación completa con persistencia de sesión
- ✅ Control de acceso basado en roles (RBAC)
- ✅ 2 roles: Administrador y Analista
- ✅ Recuperación automática de sesión

### 📊 Dashboard de Visualización
- 📈 Métricas en tiempo real (cajas, peso, costo, volumen)
- 📊 Gráficos interactivos: BarChart, LineChart, PieChart
- 🔍 Filtros dinámicos por cliente, ciudad y fechas
- 🎨 Soporte para modo claro y oscuro

### 👥 Gestión de Usuarios
- 👑 **Administradores**: Acceso completo al sistema
  - Gestionar usuarios (crear, editar, eliminar)
  - Ver dashboard completo
  - Limpiar datos del sistema
  - Configuración avanzada

- 📊 **Analistas**: Acceso limitado
  - Ver dashboard completo
  - Gestionar envíos personales
  - Configuración básica
  - Sin acceso a gestión de usuarios

### 💾 Almacenamiento
- 🗄️ Base de datos SQLite local
- 📱 Funciona completamente sin conexión
- 💾 Persistencia de datos garantizada

### 🛠️ Configuración y Personalización
- ⚙️ Panel de configuración intuitivo
- 🎨 Cambio de tema (claro/oscuro)
- 🔒 Información detallada de permisos
- 🧹 Gestión de datos (solo administradores)

---

## 🚀 Tecnologías Utilizadas

### Framework y Lenguaje
- **Flutter 3.0+**: Framework multiplataforma
- **Dart 3.0+**: Lenguaje de programación
- **Material Design 3**: Sistema de diseño

### Estado y Navegación
- **Provider Pattern**: Manejo de estado global
- **GoRouter**: Navegación declarativa
- **SharedPreferences**: Almacenamiento local

### Base de Datos y API
- **SQLite (sqflite)**: Base de datos local
- **Path Provider**: Gestión de rutas del sistema

---

## 📁 Estructura del Proyecto

```
Envii/
│
├── lib/                           # Código fuente principal
│   ├── main.dart                 # Punto de entrada de la aplicación
│   ├── providers/                # Manejo de estado global
│   │   ├── auth_provider.dart   # Autenticación y sesión
│   │   └── theme_provider.dart  # Gestión de temas
│   ├── models/                   # Modelos de datos
│   │   ├── user.dart            # Modelo de usuario
│   │   ├── despacho.dart        # Modelo de despacho
│   │   └── dashboard_metrics.dart # Métricas del dashboard
│   ├── services/                 # Servicios principales
│   │   ├── api_service.dart    # API y comunicación
│   │   └── database_helper.dart # Base de datos local
│   ├── screens/                  # Pantallas de la aplicación
│   │   ├── splash_screen.dart   # Pantalla de carga
│   │   ├── login_screen.dart    # Autenticación
│   │   ├── dashboard_screen.dart # Dashboard principal
│   │   ├── my_shipments_screen.dart # Mis envíos
│   │   ├── users_screen.dart    # Gestión de usuarios
│   │   ├── admin_panel_screen.dart # Panel de administración
│   │   └── config_screen.dart   # Configuración
│   ├── widgets/                  # Componentes reutilizables
│   │   ├── main_navigation.dart # Navegación principal
│   │   └── charts/              # Gráficos del dashboard
│   ├── utils/                    # Utilidades
│   │   ├── permissions.dart     # Control de permisos
│   │   └── number_formatter.dart # Formateo de números
│   └── theme/                    # Temas
│       └── app_theme.dart       # Configuración de temas
│
├── android/                      # Configuración Android
│   ├── app/build.gradle         # Build de Android
│   └── app/src/main/            # Código específico Android
│
├── assets/                       # Recursos estáticos
│   └── images/                  # Imágenes de la aplicación
│
├── pubspec.yaml                 # Dependencias del proyecto
├── especificaciones.md          # Documentación técnica completa
├── Build.md                     # Instrucciones de construcción
├── BaseDeDatos.md              # Documentación de base de datos
└── Informe.md                   # Informe ejecutivo
```

---

## 🏃‍♂️ Instalación y Configuración

### Prerrequisitos
- Flutter SDK 3.0+ instalado
- Dart SDK 3.0+
- Android Studio / VS Code con extensiones de Flutter
- Dispositivo Android o emulador

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone [URL_DEL_REPOSITORIO]
cd Envii
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar en modo desarrollo**
```bash
flutter run
```

4. **Construir APK para producción**
```bash
flutter build apk --release
```

### 🗄️ Base de Datos

La aplicación utiliza SQLite para almacenamiento local. Se inicializa automáticamente al primer uso.

**Usuarios de Prueba**:
- **Administrador**: username: `admin`, password: `admin`
- **Analista**: username: `test`, password: `test`

---

## 📱 Construcción y Despliegue

### Comandos de Construcción

```bash
# Limpiar proyecto
flutter clean
cd android && ./gradlew clean && cd ..

# Obtener dependencias
flutter pub get

# Construir APK
flutter build apk --release

# Para dispositivos con problemas
flutter build apk --release --no-tree-shake-icons --no-shrink
```

### 📍 Ubicación del APK

El APK generado se encuentra en:
```
build/app-release.apk
```

### 🚫 Solución de Errores de Instalación

**Error: INSTALL_FAILED_UPDATE_INCOMPATIBLE**

```bash
# Desinstalar versión anterior
adb uninstall com.envii.app

# Instalar APK con reemplazo
adb install -r -d build/app-release.apk
```


## ✅ Funcionalidades Implementadas

### ✅ Sistema Completo
- [x] Autenticación robusta con persistencia
- [x] Control de permisos estricto por roles
- [x] Dashboard con métricas y gráficos interactivos
- [x] Gestión completa de usuarios (solo administradores)
- [x] Navegación adaptativa según permisos
- [x] Modo oscuro/claro
- [x] Diseño responsive para diferentes pantallas

### 📊 Dashboard
- [x] Tarjetas de métricas en tiempo real
- [x] Gráficos interactivos (BarChart, LineChart, PieChart)
- [x] Filtros dinámicos por fecha, cliente y ciudad
- [x] Actualización automática de datos
- [x] Indicadores de carga y estados de error

### 👥 Gestión de Usuarios
- [x] Crear, editar, eliminar usuarios
- [x] Asignación de roles (Administrador/Analista)
- [x] Control de acceso basado en permisos
- [x] Validación de datos de entrada
- [x] Historial de usuarios creados

### 💾 Almacenamiento
- [x] Base de datos SQLite
- [x] CRUD completo para usuarios y despachos

---

## 🎯 Casos de Uso Principales

### 👑 Para Administradores
1. **Login**: Acceso con credenciales `admin/admin`
2. **Dashboard**: Visualización completa de métricas y gráficos
3. **Gestión de Usuarios**: Crear, editar, eliminar usuarios
4. **Panel de Administración**: Configuración avanzada del sistema
5. **Configuración**: Cambio de tema, limpieza de datos
6. **Navegación**: Acceso completo a todas las secciones

### 📊 Para Analistas
1. **Login**: Acceso con credenciales `test/test`
2. **Dashboard**: Visualización completa de métricas
3. **Mis Envíos**: Gestión de envíos personales
4. **Configuración**: Cambio de tema (funcionalidad básica)
5. **Navegación**: Sin acceso a gestión de usuarios



## 📈 Métricas del Proyecto

- **Líneas de Código**: ~2,500+ líneas
- **Archivos**: 25+ archivos Dart
- **Pantallas**: 7 pantallas principales
- **Dependencias**: 12 dependencias principales
- **Tamaño del APK**: ~69.4 MB
- **Tiempo de Desarrollo**: 4 semanas
- **Cobertura de Funcionalidades**: 100%
