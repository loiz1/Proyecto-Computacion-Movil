import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/user.dart';
import '../models/despacho.dart';
import '../models/dashboard_metrics.dart';
import 'database_helper.dart';

class ApiService {
  static const String baseUrl = 'https://api.despachos.com';
  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('token');
            await prefs.remove('user');
          }
          return handler.next(error);
        },
      ),
    );

    _initDemoData();
  }

  Future<void> _initDemoData() async {
    // NO cargar datos automáticamente
    // La aplicación debe estar vacía al inicio
    print('App initialized without demo data');
    
    // NO limpiar datos automáticamente para evitar errores de concurrencia
    // Los datos se limpiarán solo cuando el usuario lo solicite explícitamente
  }

  Future<List<Despacho>> _loadCsvFromAssets() async {
    try {
      print('Loading CSV from assets/datos V3.csv...');
      final content = await rootBundle.loadString('assets/datos V3.csv');
      print('CSV content loaded, length: ${content.length}');
      print('First 100 chars: ${content.substring(0, content.length < 100 ? content.length : 100)}');
      
      // Parsear CSV manualmente con el delimitador correcto (;)
      final lines = content.split('\n');
      final csvTable = <List<String>>[];
      
      for (String line in lines) {
        if (line.trim().isNotEmpty) {
          final columns = line.split(';');
          csvTable.add(columns);
          if (csvTable.length <= 5) { // Debug primeras líneas
            print('Row ${csvTable.length}: ${columns.length} columns - ${columns.join(', ')}');
          }
        }
      }
      print('CSV parsed, total rows: ${csvTable.length}');
      if (csvTable.isNotEmpty) {
        print('Header: ${csvTable[0].join(', ')}');
      }

      // Función auxiliar para parsear números con coma decimal
      double parseNumber(String value) {
        final normalized = value.replaceAll(',', '.');
        return double.tryParse(normalized) ?? 0.0;
      }

      final despachos = <Despacho>[];
      for (int i = 1; i < csvTable.length; i++) { // skip header
        final row = csvTable[i];
        
        try {
          print('Processing row $i: ${row.length} columns - ${row.join(', ')}');
          
          if (row.length >= 9) { // Asegurar que tenga suficientes columnas
            String cliente = row[0].toString().trim();
            
            // Mapeo de nombres de clientes antiguos a nuevos
            final clientMap = {
              'VOLVO': 'BMW',
              'ITALO': 'FERRARI',
              'AUDI': 'MERCEDEZ',
              'RENAULT': 'BYD',
              'MAZDA': 'MCLAREN',
            };
            
            // Si el cliente está en el mapa, usar el nuevo nombre
            // Si no, asignar uno de los nuevos basado en el hash del nombre original para consistencia
            if (clientMap.containsKey(cliente.toUpperCase())) {
              cliente = clientMap[cliente.toUpperCase()]!;
            } else if (!['BMW', 'FERRARI', 'MERCEDEZ', 'BYD', 'MCLAREN'].contains(cliente)) {
              // Asignación determinista para otros nombres
              final newClients = ['BMW', 'FERRARI', 'MERCEDEZ', 'BYD', 'MCLAREN'];
              final index = cliente.codeUnits.fold(0, (p, c) => p + c) % newClients.length;
              cliente = newClients[index];
            }
            final ciudad = row[1].toString().trim();
            final cajas = int.tryParse(row[2].toString()) ?? 0;
            final peso = parseNumber(row[3].toString());
            final volumen = parseNumber(row[4].toString());
            final costo = parseNumber(row[5].toString());
            final mesStr = row[6].toString().trim(); // MES
            final fechaStr = row[7].toString().trim(); // FECHA B (dd/MM/yyyy)
            final diaStr = row[8].toString().trim(); // DIA
            
            print('Row data parsed - Cliente: $cliente, Ciudad: $ciudad, Cajas: $cajas, Peso: $peso, Volumen: $volumen, Costo: $costo, Fecha: $fechaStr');
            
            DateTime fecha;
            try {
              // Parsear fecha en formato dd/MM/yyyy
              fecha = DateFormat('dd/MM/yyyy').parse(fechaStr);
              print('Fecha parsed successfully: $fecha');
            } catch (e) {
              print('Error parsing date $fechaStr: $e');
              // Si falla, intentar otros formatos
              fecha = DateTime.tryParse(fechaStr.replaceAll('/', '-')) ?? DateTime.now();
              print('Using fallback date: $fecha');
            }

            // Crear un ID único más robusto
            final cleanFecha = fechaStr.replaceAll('/', '').replaceAll('-', '');
            final cleanCosto = row[5].toString().trim().replaceAll(',', '');
            final uniqueId = '${cliente}_${ciudad}_${cleanFecha}_${cleanCosto}_$i';
            
            final despacho = Despacho(
              id: uniqueId,
              userId: null, // Se asignará el user_id al momento de insertar
              cliente: cliente,
              ciudad: ciudad,
              fecha: fecha,
              cajas: int.tryParse(row[2].toString()) ?? 0,
              peso: parseNumber(row[3].toString()),
              volumen: parseNumber(row[4].toString()),
              costo: parseNumber(row[5].toString()),
              mes: mesStr.isNotEmpty ? mesStr : null,
              dia: int.tryParse(diaStr) ?? null,
            );
            
            despachos.add(despacho);
            
            if (i <= 5) { // Debug primeras filas
              print('Processed row $i: ${despacho.cliente} - ${despacho.ciudad} - ${despacho.costo}');
            }
          }
        } catch (e) {
          print('Error processing row $i: $e');
          print('Row data: ${row.join(', ')}');
        }
      }

      print('Successfully loaded ${despachos.length} despachos from CSV');
      return despachos;
    } catch (e) {
      print('Error loading CSV: $e');
      // Si hay error, devolver lista vacía
      return [];
    }
  }

  // Autenticación
  Future<Map<String, dynamic>> login(String username, String password) async {
    // Simulación para demo - en producción usar el backend real
    await Future.delayed(const Duration(seconds: 1)); // Simular delay de red

    // Credenciales de demo
    if ((username == 'admin' && password == 'admin') ||
        (username == 'analista' && password == 'analista') ||
        (username == 'usuario' && password == 'usuario')) {

      String role = 'Normal';
      if (username == 'admin') role = 'Administrador';
      if (username == 'analista') role = 'Analista';

      return {
        'token': 'demo_token_${username}',
        'user': {
          'id': '1',
          'username': username,
          'email': '$username@demo.com',
          'role': role,
          'createdAt': DateTime.now().toIso8601String(),
        },
      };
    }

    // Verificar usuarios creados
    final prefs = await SharedPreferences.getInstance();
    final credentials = prefs.getString('demo_credentials') ?? '{}';
    final credsMap = json.decode(credentials) as Map<String, dynamic>;
    if (credsMap.containsKey(username) && credsMap[username] == password) {
      // Encontrar el usuario
      final users = await getUsers();
      final user = users.firstWhere((u) => u.username == username);
      return {
        'token': 'demo_token_${username}',
        'user': user.toJson(),
      };
    }

    throw Exception('Credenciales inválidas');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  Future<User> getCurrentUser() async {
    // Simulación para demo
    await Future.delayed(const Duration(milliseconds: 300));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.startsWith('demo_token_')) {
      final username = token.replaceFirst('demo_token_', '');

      // Buscar en usuarios demo
      if (username == 'admin' || username == 'analista' || username == 'usuario') {
        String role = 'Normal';
        if (username == 'admin') role = 'Administrador';
        if (username == 'analista') role = 'Analista';

        return User(
          id: '1',
          username: username,
          email: '$username@demo.com',
          role: role,
          createdAt: DateTime.now(),
        );
      }

      // Buscar en usuarios creados
      final users = await getUsers();
      final user = users.firstWhere((u) => u.username == username);
      return user;
    }

    throw Exception('Usuario no autenticado');
  }

  // Usuarios
  Future<List<User>> getUsers() async {
    // Simulación para demo
    await Future.delayed(const Duration(milliseconds: 300));

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList('demo_users') ?? [];

    final defaultUsers = [
      User(
        id: '1',
        username: 'admin',
        email: 'admin@demo.com',
        role: 'Administrador',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      User(
        id: '2',
        username: 'analista',
        email: 'analista@demo.com',
        role: 'Analista',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      User(
        id: '3',
        username: 'usuario',
        email: 'usuario@demo.com',
        role: 'Normal',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

    final createdUsers = usersJson.map((jsonStr) => User.fromJson(json.decode(jsonStr))).toList();

    return [...defaultUsers, ...createdUsers];
  }

  Future<User> getUserById(String id) async {
    try {
      final response = await _dio.get('/users/$id');
      return User.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> createUser(Map<String, dynamic> userData) async {
    // Simulación para demo
    await Future.delayed(const Duration(milliseconds: 500));

    final username = userData['username'] as String;
    final email = userData['email'] as String;
    final role = userData['role'] as String;
    final password = userData['password'] as String? ?? username; // default password = username

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      email: email,
      role: role,
      createdAt: DateTime.now(),
    );

    // Guardar en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList('demo_users') ?? [];
    usersJson.add(json.encode(newUser.toJson()));
    await prefs.setStringList('demo_users', usersJson);

    // Guardar credenciales
    final credentials = prefs.getString('demo_credentials') ?? '{}';
    final credsMap = json.decode(credentials) as Map<String, dynamic>;
    credsMap[username] = password;
    await prefs.setString('demo_credentials', json.encode(credsMap));

    return newUser;
  }

  Future<User> updateUser(String id, Map<String, dynamic> userData) async {
    // Simulación para demo
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList('demo_users') ?? [];
    final users = usersJson.map((jsonStr) => User.fromJson(json.decode(jsonStr))).toList();

    final index = users.indexWhere((u) => u.id == id);
    if (index == -1) throw Exception('Usuario no encontrado');

    final oldUser = users[index];
    final newUsername = userData['username'] ?? oldUser.username;
    final newEmail = userData['email'] ?? oldUser.email;
    final newRole = userData['role'] ?? oldUser.role;

    final updatedUser = User(
      id: id,
      username: newUsername,
      email: newEmail,
      role: newRole,
      createdAt: oldUser.createdAt,
    );

    users[index] = updatedUser;
    final updatedUsersJson = users.map((u) => json.encode(u.toJson())).toList();
    await prefs.setStringList('demo_users', updatedUsersJson);

    // Actualizar credenciales si cambió username o password
    final credentials = prefs.getString('demo_credentials') ?? '{}';
    final credsMap = json.decode(credentials) as Map<String, dynamic>;
    if (userData.containsKey('password')) {
      credsMap[newUsername] = userData['password'];
    } else if (newUsername != oldUser.username) {
      credsMap.remove(oldUser.username);
      credsMap[newUsername] = credsMap[oldUser.username] ?? newUsername;
    }
    await prefs.setString('demo_credentials', json.encode(credsMap));

    return updatedUser;
  }

  Future<void> deleteUser(String id) async {
    // Simulación para demo
    await Future.delayed(const Duration(milliseconds: 500));

    // No permitir eliminar usuarios por defecto
    if (id == '1' || id == '2' || id == '3') {
      throw Exception('No se pueden eliminar usuarios del sistema por defecto');
    }

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList('demo_users') ?? [];
    final users = usersJson.map((jsonStr) => User.fromJson(json.decode(jsonStr))).toList();

    final index = users.indexWhere((u) => u.id == id);
    if (index == -1) throw Exception('Usuario no encontrado');

    final userToDelete = users[index];
    users.removeAt(index);

    final updatedUsersJson = users.map((u) => json.encode(u.toJson())).toList();
    await prefs.setStringList('demo_users', updatedUsersJson);

    // Remover credenciales
    final credentials = prefs.getString('demo_credentials') ?? '{}';
    final credsMap = json.decode(credentials) as Map<String, dynamic>;
    credsMap.remove(userToDelete.username);
    await prefs.setString('demo_credentials', json.encode(credsMap));
  }

  // Despachos
  Future<List<Despacho>> getDespachos({
    String? cliente,
    String? ciudad,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    // Obtener el usuario actual para filtrar sus datos
    final currentUser = await getCurrentUser();
    
    return await DatabaseHelper().getDespachos(
      userId: currentUser.id,
      cliente: cliente,
      ciudad: ciudad,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
    );
  }

  Future<DashboardMetrics> getDashboardMetrics({
    String? cliente,
    String? ciudad,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    // Simulación para demo
    await Future.delayed(const Duration(milliseconds: 300));

    // Obtener despachos filtrados
    final despachos = await getDespachos(
      cliente: cliente,
      ciudad: ciudad,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
    );

    final totalCajas = despachos.fold<int>(0, (sum, d) => sum + d.cajas);
    final totalPeso = despachos.fold<double>(0, (sum, d) => sum + d.peso);
    final totalCosto = despachos.fold<double>(0, (sum, d) => sum + d.costo);
    final totalVolumen = despachos.fold<double>(0, (sum, d) => sum + d.volumen);

    final promedioCajas = despachos.isNotEmpty ? totalCajas / despachos.length : 0.0;
    final promedioPeso = despachos.isNotEmpty ? totalPeso / despachos.length : 0.0;

    return DashboardMetrics(
      totalCajas: totalCajas,
      totalPeso: totalPeso,
      totalCosto: totalCosto,
      totalVolumen: totalVolumen,
      promedioCajas: promedioCajas,
      promedioPeso: promedioPeso,
    );
  }

  // Carga de archivos
  Future<Map<String, dynamic>> uploadFile(Uint8List bytes, String filename) async {
    try {
      print('Uploading file: $filename');
      print('Bytes length: ${bytes.length}');
      
      // Intentar decodificar con UTF-8 primero
      String content;
      try {
        content = utf8.decode(bytes);
      } catch (e) {
        // Si falla UTF-8, intentar con latin1 (ISO-8859-1)
        print('UTF-8 decode failed, trying latin1');
        content = latin1.decode(bytes);
      }
      
      print('Content length: ${content.length}');
      print('First 200 chars: ${content.substring(0, content.length < 200 ? content.length : 200)}');
      
      // Parsear CSV manualmente con el delimitador correcto (;)
      final lines = content.split('\n');
      final csvTable = <List<String>>[];
      
      for (int i = 0; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isNotEmpty) {
          final columns = line.split(';');
          csvTable.add(columns);
          if (i < 5) { // Debug primeras líneas
            print('Line $i: ${columns.length} columns - ${columns.join(', ')}');
          }
        }
      }

      print('Total CSV rows: ${csvTable.length}');

      // Función auxiliar para parsear números con coma decimal
      double parseNumber(String value) {
        final normalized = value.replaceAll(',', '.');
        return double.tryParse(normalized) ?? 0.0;
      }

      final despachos = <Despacho>[];
      int processedCount = 0;
      int errorCount = 0;
      
      for (int i = 1; i < csvTable.length; i++) { // skip header
        final row = csvTable[i];
        
        try {
          print('Processing row $i: ${row.length} columns - ${row.join(', ')}');
          
          if (row.length >= 9) { // Asegurar que tenga suficientes columnas
            final cliente = row[0].toString().trim();
            final ciudad = row[1].toString().trim();
            final cajas = int.tryParse(row[2].toString()) ?? 0;
            final peso = parseNumber(row[3].toString());
            final volumen = parseNumber(row[4].toString());
            final costo = parseNumber(row[5].toString());
            final mesStr = row[6].toString().trim(); // MES
            final fechaStr = row[7].toString().trim(); // FECHA B (dd/MM/yyyy)
            final diaStr = row[8].toString().trim(); // DIA
            
            print('Row data parsed - Cliente: $cliente, Ciudad: $ciudad, Cajas: $cajas, Peso: $peso, Volumen: $volumen, Costo: $costo, Fecha: $fechaStr');
            
            DateTime fecha;
            try {
              // Parsear fecha en formato dd/MM/yyyy
              fecha = DateFormat('dd/MM/yyyy').parse(fechaStr);
              print('Fecha parsed successfully: $fecha');
            } catch (e) {
              print('Error parsing date $fechaStr: $e');
              // Si falla, intentar otros formatos
              fecha = DateTime.tryParse(fechaStr.replaceAll('/', '-')) ?? DateTime.now();
              print('Using fallback date: $fecha');
            }

            // Crear un ID único más robusto
            final cleanFecha = fechaStr.replaceAll('/', '').replaceAll('-', '');
            final cleanCosto = row[5].toString().trim().replaceAll(',', '');
            final uniqueId = '${cliente}_${ciudad}_${cleanFecha}_${cleanCosto}_$i';
            
            final despacho = Despacho(
              id: uniqueId, // Usar ID único para evitar duplicados
              userId: null, // Se asignará el user_id al momento de insertar
              cliente: cliente,
              ciudad: ciudad,
              fecha: fecha,
              cajas: int.tryParse(row[2].toString()) ?? 0,
              peso: parseNumber(row[3].toString()),
              volumen: parseNumber(row[4].toString()),
              costo: parseNumber(row[5].toString()),
              mes: mesStr.isNotEmpty ? mesStr : null,
              dia: int.tryParse(diaStr) ?? null,
            );
            
            despachos.add(despacho);
            processedCount++;
            
            if (i <= 5) { // Debug primeras filas procesadas
              print('Processed row $i: ${despacho.cliente} - ${despacho.ciudad} - ${despacho.costo}');
            }
          } else {
            print('Warning: Row $i has only ${row.length} columns, expected at least 8');
            errorCount++;
          }
        } catch (e) {
          print('Error processing row $i: $e');
          print('Row data: ${row.join(', ')}');
          errorCount++;
        }
      }

      print('Successfully processed $processedCount rows, $errorCount errors');
      print('Total despachos to insert: ${despachos.length}');

      if (despachos.isNotEmpty) {
        // Obtener el usuario actual para asociar los datos
        final currentUser = await getCurrentUser();
        
        // Asociar cada despacho al usuario actual creando nuevas instancias
        final userDespachos = despachos.map((despacho) => Despacho(
          id: despacho.id,
          userId: currentUser.id,
          cliente: despacho.cliente,
          ciudad: despacho.ciudad,
          fecha: despacho.fecha,
          cajas: despacho.cajas,
          peso: despacho.peso,
          costo: despacho.costo,
          volumen: despacho.volumen,
          mes: despacho.mes,
          dia: despacho.dia,
        )).toList();
        
        await DatabaseHelper().insertDespachos(userDespachos);
        print('Inserted ${userDespachos.length} despachos into database for user ${currentUser.id}');
      }

      return {
        'success': true,
        'recordsCount': despachos.length,
        'message': 'Archivo procesado correctamente: $processedCount filas procesadas, $errorCount errores',
      };
    } catch (e) {
      print('Error in uploadFile: $e');
      return {
        'success': false,
        'message': 'Error al procesar el archivo: $e',
      };
    }
  }

  Future<List<Map<String, dynamic>>> getUploadHistory() async {
    // No devolver datos de prueba
    await Future.delayed(const Duration(milliseconds: 300));

    return [];
  }

  Future<Map<String, dynamic>> reloadCsvData() async {
    try {
      final csvData = await _loadCsvFromAssets();
      if (csvData.isNotEmpty) {
        // Obtener el usuario actual para asociar los datos
        final currentUser = await getCurrentUser();
        
        // Asociar cada despacho al usuario actual
        final userDespachos = csvData.map((despacho) => Despacho(
          id: despacho.id,
          userId: currentUser.id,
          cliente: despacho.cliente,
          ciudad: despacho.ciudad,
          fecha: despacho.fecha,
          cajas: despacho.cajas,
          peso: despacho.peso,
          costo: despacho.costo,
          volumen: despacho.volumen,
          mes: despacho.mes,
          dia: despacho.dia,
        )).toList();
        
        await DatabaseHelper().insertDespachos(userDespachos);
        return {
          'success': true,
          'recordsCount': userDespachos.length,
          'message': 'Datos agregados correctamente al sistema',
        };
      } else {
        return {
          'success': false,
          'message': 'No se encontraron datos en el archivo CSV',
        };
      }
    } catch (e) {
      print('Error in reloadCsvData: $e');
      return {
        'success': false,
        'message': 'Error al recargar datos: $e',
      };
    }
  }

  Future<void> clearAllData() async {
    try {
      await DatabaseHelper().clearAllData();
    } catch (e) {
      print('Error clearing data: $e');
      throw Exception('Error al borrar los datos: $e');
    }
  }

  // Configuración
  Future<User> updateProfile(Map<String, dynamic> data) async {
    // Simulación para demo
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.startsWith('demo_token_')) {
      final username = token.replaceFirst('demo_token_', '');
      String role = 'Normal';
      if (username == 'admin') role = 'Administrador';
      if (username == 'analista') role = 'Analista';

      // Simular actualización
      final updatedUsername = data['username'] ?? username;
      final updatedEmail = data['email'] ?? '$username@demo.com';

      final updatedUser = User(
        id: '1',
        username: updatedUsername,
        email: updatedEmail,
        role: role,
        createdAt: DateTime.now(),
      );

      // Guardar el usuario actualizado en SharedPreferences
      await prefs.setString('user', json.encode(updatedUser.toJson()));

      return updatedUser;
    }

    throw Exception('Usuario no autenticado');
  }

  Future<void> insertSimulatedDespacho(Despacho despacho) async {
    try {
      // Insertar directamente en la base de datos
      await DatabaseHelper().insertDespacho(despacho);
    } catch (e) {
      throw Exception('Error al insertar despacho simulado: $e');
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        return error.response?.data['message'] ?? 'Error en la petición';
      } else {
        return 'Error de conexión';
      }
    }
    return 'Error desconocido';
  }
}

