# 📋 Cuestionario Técnico - Proyecto Envii

## 🎯 Cuestionario Completo sobre la Arquitectura y Funcionamiento de Envii

---

## 📱 **1. ESTRUCTURA Y CONFIGURACIÓN GENERAL**

### **1.1 ¿Cuál es el punto de entrada principal de la aplicación Flutter Envii?**
**Respuesta:** El archivo `lib/main.dart` es el punto de entrada principal. Contiene:
- La función `main()` que inicializa Flutter y configura la localización en español
- La clase `MyApp` que extiende `StatelessWidget` y configura el `MultiProvider`
- La configuración del router `GoRouter` con redirecciones automáticas

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  runApp(const MyApp());
}
```

### **1.2 ¿Cómo se configura el manejo de estado global en la aplicación?**
**Respuesta:** Se utiliza el patrón `Provider` con `MultiProvider` en `main.dart`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ],
  child: Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      return MaterialApp.router(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.themeMode,
        routerConfig: _router,
      );
    },
  ),
)
```

### **1.3 ¿Cómo está estructurado el proyecto y qué contiene cada carpeta principal?**
**Respuesta:**
```
Envii/
├── lib/                          # Código fuente principal
│   ├── main.dart                # Punto de entrada
│   ├── providers/               # Manejo de estado global
│   │   ├── auth_provider.dart  # Autenticación
│   │   └── theme_provider.dart # Gestión de temas
│   ├── models/                  # Modelos de datos
│   │   ├── user.dart           # Modelo de usuario
│   │   ├── despacho.dart       # Modelo de despacho
│   │   └── dashboard_metrics.dart # Métricas del dashboard
│   ├── services/                # Servicios principales
│   │   ├── api_service.dart   # API y comunicación
│   │   └── database_helper.dart # Base de datos local
│   ├── screens/                 # Pantallas de la aplicación
│   ├── widgets/                 # Componentes reutilizables
│   ├── utils/                   # Utilidades
│   └── theme/                   # Configuración de temas
├── android/                     # Configuración Android
└── assets/                      # Recursos estáticos
```

---

## 👤 **2. MODELO DE USUARIO Y AUTENTICACIÓN**

### **2.1 ¿Cómo se define la clase User y qué campos contiene?**
**Respuesta:** La clase `User` está definida en `lib/models/user.dart`:

```dart
class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final DateTime createdAt;
  final String? password; // Solo para uso interno

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.createdAt,
    this.password,
  });

  // Getters para verificar roles
  bool get isAdmin => role == 'Administrador';
  bool get isAnalyst => role == 'Analista' || role == 'Administrador';
}
```

### **2.2 ¿Cómo funciona el AuthProvider y qué métodos principales tiene?**
**Respuesta:** El `AuthProvider` (en `lib/providers/auth_provider.dart`) maneja:
- **Estado de autenticación**: `_user`, `_isLoading`, `_error`
- **Métodos principales**:
  - `login(username, password)`: Autentica y guarda sesión
  - `logout()`: Cierra sesión y limpia datos
  - `updateUser(user)`: Actualiza datos del usuario
  - `_loadUser()`: Restaura sesión guardada al iniciar

### **2.3 ¿Cómo se implementa la persistencia de sesión?**
**Respuesta:** Se utiliza `SharedPreferences` para guardar `token` y datos del usuario:

```dart
// En AuthProvider.login()
final prefs = await SharedPreferences.getInstance();
await prefs.setString('token', token);
await prefs.setString('user', json.encode(user.toJson()));

// En _loadUser()
final userJson = prefs.getString('user');
final token = prefs.getString('token');
if (userJson != null && token != null) {
  _user = User.fromJson(json.decode(userJson));
}
```

### **2.4 ¿Cuáles son los usuarios de prueba por defecto?**
**Respuesta:** 
- **Administrador**: username: `admin`, password: `admin`
- **Analista**: username: `test`, password: `test`

Estos usuarios están hardcodeados en `ApiService._isValidOfflineCredentials()`.

---

## 🔐 **3. SISTEMA DE LOGIN Y NAVEGACIÓN**

### **3.1 ¿Cómo se configura el router GoRouter y qué rutas maneja?**
**Respuesta:** En `main.dart` se define el router con:
- **Rutas principales**: `/splash`, `/login`, `/dashboard`, `/my-shipments`, `/users`, `/config`
- **Redirección automática**: Si no está logueado → `/login`, si ya está logueado e intenta acceder a `/login` → `/dashboard`

```dart
final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isAuthenticated;
    // Lógica de redirección...
  },
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    // Más rutas...
  ],
);
```

### **3.2 ¿Cómo funciona la pantalla de login y qué validación implementa?**
**Respuesta:** La `LoginScreen` (en `lib/screens/login_screen.dart`):
- **Formulario con validación**: Campos de usuario y contraseña requeridos
- **Animaciones**: Fade, slide y form animations
- **Proceso de login**: Llama a `AuthProvider.login()` y redirige al dashboard en caso de éxito
- **Manejo de errores**: Muestra SnackBar con errores de autenticación

### **3.3 ¿Cómo se conecta el login con el dashboard después de una autenticación exitosa?**
**Respuesta:** En `LoginScreen._handleLogin()`:

```dart
Future<void> _handleLogin() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final success = await authProvider.login(
    _usernameController.text.trim(),
    _passwordController.text,
  );

  if (success && mounted) {
    context.go('/dashboard'); // Redirección automática
  }
}
```

El router también maneja redirecciones automáticas basándose en el estado de autenticación.

---

## 🎛️ **4. NAVEGACIÓN Y CONTROL DE ACCESO**

### **4.1 ¿Cómo funciona MainNavigation y cómo se adapta según el rol del usuario?**
**Respuesta:** El `MainNavigation` (en `lib/widgets/main_navigation.dart`):
- **Navegación dinámica**: Solo muestra la pestaña "Usuarios" si el usuario es administrador
- **IndexedStack**: Maneja múltiples pantallas en una sola widget
- **NavigationBar**: Configuración adaptativa de destinos

```dart
// Solo muestra Usuarios si es admin
if (user?.isAdmin ?? false)
  const NavigationDestination(
    icon: Icon(Icons.people_outline),
    label: 'Usuarios',
  ),
```

### **4.2 ¿Cómo se implementa el control de permisos basado en roles?**
**Respuesta:** El sistema de permisos está en `lib/utils/permissions.dart`:

```dart
enum Permission {
  viewDashboard,
  createShipment,
  manageUsers,
  viewSettings,
}

class PermissionsManager {
  static bool hasPermission(User user, Permission permission) {
    switch (user.role) {
      case 'Administrador':
        return true; // Todos los permisos
      case 'Analista':
        // Solo permisos específicos
        switch (permission) {
          case Permission.manageUsers:
            return false; // Analistas NO pueden gestionar usuarios
          default:
            return true;
        }
    }
  }
}
```

### **4.3 ¿Qué diferencias de acceso tienen los roles Administrador y Analista?**
**Respuesta:**
- **Administrador**: 
  - ✅ Acceso completo al dashboard
  - ✅ Gestión de usuarios (crear, editar, eliminar)
  - ✅ Limpiar datos del sistema
  - ✅ Todas las pantallas disponibles
- **Analista**:
  - ✅ Acceso al dashboard
  - ✅ Gestión de envíos personales
  - ❌ NO puede gestionar usuarios
  - ✅ Configuración básica

---

## 💾 **5. BASE DE DATOS Y MODO OFFLINE**

### **5.1 ¿Cómo se configura la base de datos SQLite y qué tablas contiene?**
**Respuesta:** En `lib/services/database_helper.dart`:
- **Inicialización**: Singleton pattern con `_instance`
- **Tablas principales**:
  - `despachos`: Datos de envíos
  - `users`: Usuarios para modo offline

```dart
// Tabla de despachos
await db.execute('''
  CREATE TABLE despachos(
    id TEXT PRIMARY KEY,
    user_id TEXT,
    cliente TEXT,
    ciudad TEXT,
    fecha TEXT,
    cajas INTEGER,
    peso REAL,
    costo REAL,
    volumen REAL
  )
''');

// Tabla de usuarios offline
await db.execute('''
  CREATE TABLE users(
    id TEXT PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    email TEXT NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL
  )
''');
```

### **5.2 ¿Cómo funciona el modo offline y el fallback automático?**
**Respuesta:** En `ApiService`:
- **Login offline**: Si falla la conexión al servidor, verifica credenciales locales
- **Fallback automático**: Todas las operaciones intentan servidor primero, luego base de datos local
- **Usuarios por defecto**: Se insertan automáticamente al crear la BD

```dart
// En ApiService.login()
try {
  final response = await _dio.post('/auth/login', data: {...});
  return response.data;
} catch (serverError) {
  // Fallback a modo offline
  if (_isValidOfflineCredentials(username, password)) {
    return _createOfflineUserResponse(username);
  }
}
```

### **5.3 ¿Qué métodos principales tiene DatabaseHelper para manejo de datos?**
**Respuesta:**
- **Usuarios**: `insertUser()`, `getUsers()`, `getUserByUsername()`, `updateUser()`, `deleteUser()`
- **Despachos**: `insertDespacho()`, `getDespachos()`, `deleteDespachoById()`
- **Utilidades**: `clearAllData()`, `getDespachosCount()`

---

## 📊 **6. DASHBOARD Y MÉTRICAS**

### **6.1 ¿Cómo se cargan y muestran los datos en el Dashboard?**
**Respuesta:** En `lib/screens/dashboard_screen.dart`:
- **Carga de datos**: `_loadData()` obtiene despachos y métricas en paralelo
- **Filtros dinámicos**: Cliente, ciudad, rango de fechas
- **FutureBuilder**: Manejo asíncrono de datos

```dart
Future<void> _loadData() async {
  final [despachos, metrics] = await Future.wait([
    _apiService.getDespachos(
      cliente: _selectedCliente,
      ciudad: _selectedCiudad,
    ),
    _apiService.getDashboardMetrics(
      cliente: _selectedCliente,
      ciudad: _selectedCiudad,
    ),
  ]);
}
```

### **6.2 ¿Cómo se calculan las métricas del dashboard?**
**Respuesta:** Las métricas se calculan desde la base de datos local:

```dart
final totalCajas = despachos.fold<int>(0, (sum, d) => sum + d.cajas);
final totalPeso = despachos.fold<double>(0.0, (sum, d) => sum + d.peso);
final totalCosto = despachos.fold<double>(0.0, (sum, d) => sum + d.costo);
final totalVolumen = despachos.fold<double>(0.0, (sum, d) => sum + d.volumen);

return DashboardMetrics(
  totalCajas: totalCajas,
  totalPeso: totalPeso,
  totalCosto: totalCosto,
  totalVolumen: totalVolumen,
);
```

### **6.3 ¿Qué tipos de gráficos se muestran en el dashboard?**
**Respuesta:** Utilizando `fl_chart`:
- **BarCharts**: Cajas, costo, volumen, peso por cliente
- **PieCharts**: Distribución de volumen por ciudad, porcentajes por cliente
- **Métricas en tiempo real**: Tarjetas con totales generales

---

## 🔧 **7. CONFIGURACIÓN Y TEMAS**

### **7.1 ¿Cómo se implementa el sistema de temas (claro/oscuro)?**
**Respuesta:** 
- **ThemeProvider**: Maneja el estado del tema actual
- **AppTheme**: Define `lightTheme` y `darkTheme` con Material Design 3
- **Configuración**: En `main.dart` se aplica el `themeMode`

```dart
// En main.dart
theme: AppTheme.lightTheme,
darkTheme: AppTheme.darkTheme,
themeMode: themeProvider.themeMode,
```

### **7.2 ¿Cómo se maneja la localización en español?**
**Respuesta:** En `main.dart`:
```dart
await initializeDateFormatting('es');
```
Se configuran las fechas y números en español para toda la aplicación.

---

## 📦 **8. CONSTRUCCIÓN Y DESPLIEGUE**

### **8.1 ¿Cuáles son los comandos principales para construir la aplicación?**
**Respuesta:**
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

### **8.2 ¿Dónde se genera el APK y cuál es el package name?**
**Respuesta:**
- **Ubicación**: `build/app-release.apk`
- **Package Name**: `com.envii.app`
- **Tamaño**: ~69.4 MB

### **8.3 ¿Cómo se solucionan errores comunes de instalación?**
**Respuesta:**
```bash
# Error: INSTALL_FAILED_UPDATE_INCOMPATIBLE
adb uninstall com.envii.app
adb install -r -d build/app-release.apk
```

---

## 🏗️ **9. ARQUITECTURA Y PATRONES DE DISEÑO**

### **9.1 ¿Qué patrones de diseño se utilizan en la aplicación?**
**Respuesta:**
- **Provider Pattern**: Para manejo de estado global
- **Singleton Pattern**: En `DatabaseHelper`
- **Repository Pattern**: A través de `ApiService`
- **Factory Pattern**: En modelos con `fromJson()`
- **Observer Pattern**: Con `ChangeNotifier` en providers

### **9.2 ¿Cómo fluye la datos en la aplicación?**
**Respuesta:**
```
Usuario → AuthProvider → ApiService → DatabaseHelper → SQLite
    ↓
SharedPreferences (sesión)
    ↓
UI Screens (actualización automática)
```

### **9.3 ¿Cómo se maneja el estado de la aplicación?**
**Respuesta:**
- **AuthProvider**: Estado de autenticación y usuario actual
- **ThemeProvider**: Configuración de tema (claro/oscuro)
- **SharedPreferences**: Persistencia de sesión y configuración
- **SQLite**: Almacenamiento local de datos de aplicación

---

## 🎯 **10. FUNCIONALIDADES ESPECÍFICAS**

### **10.1 ¿Cómo se implementa la simulación de envíos?**
**Respuesta:** A través de `SimulationScreen`:
- **FloatingActionButton**: Solo visible para usuarios con permisos
- **Formulario**: Cliente, ciudad, datos de envío
- **Guardado**: En base de datos local via `ApiService.insertSimulatedDespacho()`

### **10.2 ¿Cómo funciona la gestión de usuarios (solo administradores)?**
**Respuesta:** En `UsersScreen`:
- **CRUD completo**: Crear, leer, actualizar, eliminar usuarios
- **Control de acceso**: Verificación de permisos antes de mostrar
- **Roles**: Asignación de Administrador/Analista
- **Validación**: Datos requeridos y formato de email

### **10.3 ¿Cómo se implementa la limpieza de datos del sistema?**
**Respuesta:** En `ConfigScreen`:
- **clearAllData()**: Limpia todos los despachos
- **clearLocalData()**: Limpia base de datos local
- **clearUserDespachos()**: Limpia datos del usuario actual
- **Solo administradores**: Pueden acceder a estas funciones

---

## 🔍 **11. DEBUGGING Y LOGGING**

### **11.1 ¿Cómo se implementa el sistema de logging?**
**Respuesta:** En `ApiService` se usa `AppLogger`:
```dart
class AppLogger {
  static void debug(String message) {...}
  static void info(String message) {...}
  static void warning(String message) {...}
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {...}
}
```

### **11.2 ¿Qué herramientas de debugging se utilizan?**
**Respuesta:**
- **debugPrint()**: Para logging básico
- **developer.log()**: Para logging avanzado con tags
- **try-catch**: Manejo robusto de errores
- **ScaffoldMessenger**: Feedback visual de errores

---

## 📈 **12. RENDIMIENTO Y OPTIMIZACIÓN**

### **12.1 ¿Cómo se optimiza el rendimiento de la aplicación?**
**Respuesta:**
- **Future.wait()**: Carga paralela de datos
- **IndexedStack**: Evita recreación de widgets
- **Singleton DatabaseHelper**: Evita múltiples conexiones BD
- **FutureBuilder**: Carga asíncrona eficiente
- **List.generate()**: Conversión eficiente de mapas a listas

### **12.2 ¿Cómo se maneja la memoria y el estado?**
**Respuesta:**
- **ChangeNotifier**: Notificación eficiente de cambios
- **Consumer**: Rebuild selectivo de widgets
- **Dispose**: Liberación de controladores y recursos
- **WeakReference**: Evita memory leaks

---

## 📝 **RESUMEN EJECUTIVO**

### **Arquitectura Principal:**
- **Flutter 3.0+** con **Dart 3.0+**
- **Provider Pattern** para estado global
- **SQLite** para almacenamiento local
- **GoRouter** para navegación
- **Material Design 3** para UI

### **Flujo de Autenticación:**
1. **LoginScreen** → Formulario de credenciales
2. **AuthProvider.login()** → Validación de credenciales
3. **ApiService** → Fallback offline automático
4. **SharedPreferences** → Persistencia de sesión
5. **Router** → Redirección automática al dashboard

### **Funcionalidades Principales:**
- ✅ **Autenticación robusta** con roles y permisos
- ✅ **Dashboard interactivo** con gráficos en tiempo real
- ✅ **Gestión de usuarios** (solo administradores)
- ✅ **Modo offline completo** con SQLite
- ✅ **Control de acceso basado en roles (RBAC)**
- ✅ **Navegación adaptativa** según permisos
- ✅ **Temas claro/oscuro**
- ✅ **Localización en español**

### **Usuarios de Prueba:**
- **Administrador**: `admin`/`admin`
- **Analista**: `test`/`test`

### **Estado del Proyecto:**
- **Versión**: 1.0.1
- **Fecha de Entrega**: 06-12-2025
- **Estado**: ✅ **PRODUCCIÓN - COMPLETADO**
- **Cobertura**: 100% de funcionalidades implementadas

---

*Este cuestionario cubre todos los aspectos técnicos principales del proyecto Envii, desde la arquitectura hasta la implementación específica de cada funcionalidad.*