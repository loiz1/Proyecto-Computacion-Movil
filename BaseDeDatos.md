# Documentación: Base de Datos Envii

## Estructura de la Base de Datos

La aplicación Envii utiliza una base de datos SQLite local para almacenamiento persistente de datos. La base de datos se inicializa automáticamente al iniciar la aplicación.

La aplicación funciona completamente en modo offline, utilizando la base de datos SQLite local para:

- **Autenticación:** Los usuarios pueden iniciar sesión con credenciales locales
- **Gestión de despachos:** Crear, consultar y eliminar despachos
- **Persistencia de datos:** Todos los datos se guardan localmente


### Tabla: `despachos`
Almacena la información de pedidos/despachos de envíos.

```sql
CREATE TABLE despachos(
  id TEXT PRIMARY KEY,
  user_id TEXT,
  cliente TEXT,
  ciudad TEXT,
  fecha TEXT,
  cajas INTEGER,
  peso REAL,
  costo REAL,
  volumen REAL,
  mes TEXT,
  dia INTEGER
)
```

### Tabla: `users`
Almacena la información de usuarios del sistema (modo offline).

```sql
CREATE TABLE users(
  id TEXT PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL,
  created_at TEXT NOT NULL,
  is_offline INTEGER DEFAULT 1
)
```

## Creación de Usuarios

### Usuarios por Defecto
Al inicializar la base de datos por primera vez, se crean automáticamente estos usuarios:

1. **Administrador**
   - Username: `admin`
   - Password: `admin`
   - Email: `admin@envii.com`
   - Role: `Administrador`

2. **Analista de Prueba**
   - Username: `test`
   - Password: `test`
   - Email: `test@envii.com`
   - Role: `Analista`

### Creación de Nuevos Usuarios

Los usuarios pueden ser creados localmente:

```dart
final newUser = User(
  id: 'local_user_${DateTime.now().millisecondsSinceEpoch}',
  username: userData['username'] ?? '',
  email: userData['email'] ?? '',
  role: userData['role'] ?? 'Analista',
  createdAt: DateTime.now(),
);

final dbHelper = DatabaseHelper();
await dbHelper.insertUser(newUser, password);
```

### Métodos de Gestión de Usuarios

**Obtener todos los usuarios:**
```dart
Future<List<User>> getUsers() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('users');
  return maps.map((map) => User.fromJson(map)).toList();
}
```

**Obtener usuario por nombre de usuario:**
```dart
Future<User?> getUserByUsername(String username) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'users',
    where: 'username = ?',
    whereArgs: [username],
  );
  return maps.isNotEmpty ? User.fromJson(maps.first) : null;
}
```

**Actualizar usuario:**
```dart
Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
  final db = await database;
  await db.update(
    'users',
    userData,
    where: 'id = ?',
    whereArgs: [userId],
  );
}
```

**Eliminar usuario:**
```dart
Future<void> deleteUser(String userId) async {
  final db = await database;
  await db.delete(
    'users',
    where: 'id = ?',
    whereArgs: [userId],
  );
}

## Creación de Pedidos/Despachos

### Estructura del Objeto Despacho

```dart
class Despacho {
  final String id;
  final String? userId;
  final String cliente;
  final String ciudad;
  final DateTime fecha;
  final int cajas;
  final double peso;
  final double costo;
  final double volumen;
  final String? mes;
  final int? dia;
}
```

### Proceso de Creación de un Despacho

#### 1. Generación de ID único
```dart
String generateDespachoId() {
  return 'despacho_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
}
```

#### 2. Extracción automática de metadatos
```dart
Despacho createDespacho({
  required String userId,
  required String cliente,
  required String ciudad,
  required DateTime fecha,
  required int cajas,
  required double peso,
  required double costo,
  required double volumen,
}) {
  return Despacho(
    id: generateDespachoId(),
    userId: userId,
    cliente: cliente,
    ciudad: ciudad,
    fecha: fecha,
    cajas: cajas,
    peso: peso,
    costo: costo,
    volumen: volumen,
    mes: DateFormat('MMMM', 'es').format(fecha), // Enero, Febrero, etc.
    dia: fecha.day,
  );
}
```

#### 3. Inserción en Base de Datos
```dart
Future<void> insertDespacho(Despacho despacho) async {
  final db = await database;
  await db.insert('despachos', despacho.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
}
```

### Métodos de Gestión de Despachos

**Insertar un despacho individual:**
```dart
Future<void> insertDespacho(Despacho despacho) async {
  final db = await database;
  await db.insert('despachos', despacho.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
}
```



**Consultar despachos con filtros:**
```dart
Future<List<Despacho>> getDespachos({
  String? userId,
  String? cliente,
  String? ciudad,
  DateTime? fechaInicio,
  DateTime? fechaFin,
}) async {
  final db = await database;
  List<String> whereClauses = [];
  List<dynamic> whereArgs = [];

  // Aplicar filtros
  if (userId != null) {
    whereClauses.add('user_id = ?');
    whereArgs.add(userId);
  }
  
  if (cliente != null) {
    whereClauses.add('cliente = ?');
    whereArgs.add(cliente);
  }

  final List<Map<String, dynamic>> maps = await db.query(
    'despachos',
    where: whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null,
    whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
  );

  return List.generate(maps.length, (i) => Despacho.fromJson(maps[i]));
}
```

**Eliminar despachos por usuario:**
```dart
Future<void> deleteUserDespachos(String userId) async {
  final db = await database;
  await db.delete('despachos', where: 'user_id = ?', whereArgs: [userId]);
}
```

**Eliminar despacho específico:**
```dart
Future<void> deleteDespachoById(String despachoId) async {
  final db = await database;
  await db.delete('despachos', where: 'id = ?', whereArgs: [despachoId]);
}
```

