# Construcción de APK en Flutter

```bash
# PASO 1: Limpiar completamente
flutter clean
cd android
./gradlew clean
cd ..

# PASO 2: Obtener dependencias
flutter pub get

# PASO 3: Construir APK
flutter build apk --release
```

### **Comando Alternativo Más Robusto**

Si el comando anterior falla, usar:

```bash
flutter build apk --release --no-tree-shake-icons --no-shrink
```


## Ubicación del APK Generado

El APK se genera en:
```
build/app-release.apk
```

## 🚫 Solución a Error de Instalación - Conflicto con Paquete

Si al instalar el APK aparece el error "INSTALL_FAILED_UPDATE_INCOMPATIBLE" o similar:

### **Opción 1: Desinstalar App Anterior**
```bash
# Ver aplicaciones instaladas
adb shell pm list packages | grep envii

# Desinstalar app específica
adb uninstall com.envii.app

# O desinstalar todas las apps del desarrollador
adb shell pm uninstall --user 0 com.envii.app
```

### **Opción 2: Instalar con Flag de Reemplazo**
```bash
# Instalar permitiendo downgrades
adb install -r -d build/app-release.apk

# O forzar reemplazo
adb install -r build/app-release.apk
```

### **Opción 3: Limpiar Datos de la App (si está debuggeando)**
```bash
# Limpiar datos de la app
adb shell pm clear com.envii.app

# Instalar nuevamente
adb install build/app-release.apk
```

### **Script de Instalación Automática**
Para mayor facilidad, usa los scripts incluidos:

**En Windows:**
```cmd
cd Envii
install_apk.bat
```

**En Linux/Mac:**
```bash
cd Envii
chmod +x install_apk.sh
./install_apk.sh
```

### **Comando Completo Recomendado**
```bash
# 1. Verificar dispositivo conectado
adb devices

# 2. Desinstalar versión anterior si existe
adb uninstall com.envii.app 2>/dev/null || true

# 3. Instalar APK nuevo
adb install -r -d build/app-release.apk
```

### **Información del Proyecto**
- **Package Name:** `com.envii.app`
- **APK Location:** `build/app-release.apk`
- **Tamaño:** ~69.4 MB
- **Scripts de instalación:** `install_apk.bat` (Windows), `install_apk.sh` (Linux/Mac)
