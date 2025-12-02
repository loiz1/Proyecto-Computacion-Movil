import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/despacho.dart';

// Import correcto para sqflite web
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static bool _isInitializing = false;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    
    // Evitar múltiples inicializaciones concurrentes
    if (_isInitializing) {
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (_database != null && _database!.isOpen) return _database!;
    }
    
    try {
      _isInitializing = true;
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      print('Error initializing database: $e');
      // Intentar una sola vez más en caso de error
      try {
        _database = await _initDatabase();
        return _database!;
      } catch (e2) {
        print('Failed to reinitialize database: $e2');
        throw Exception('No se pudo inicializar la base de datos después de varios intentos: $e2');
      }
    } finally {
      _isInitializing = false;
    }
  }

  Future<Database> _initDatabase() async {
    try {
      String path = kIsWeb ? 'despachos.db' : join(await getDatabasesPath(), 'despachos.db');
      
      print('Initializing database at path: $path');
      
      final database = await openDatabase(
        path,
        version: 3,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) async {
          print('Database opened successfully');
          // Verificar que la tabla existe
          try {
            await db.query('despachos', limit: 1);
            print('Table despachos verified');
          } catch (e) {
            print('Warning: Could not verify table: $e');
          }
        },
      );
      
      print('Database initialized successfully at: $path');
      return database;
    } catch (e) {
      print('Error in _initDatabase: $e');
      // Re-lanzar con más contexto
      throw Exception('No se pudo inicializar la base de datos: $e');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
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
        volumen REAL,
        mes TEXT,
        dia INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE despachos ADD COLUMN mes TEXT');
      await db.execute('ALTER TABLE despachos ADD COLUMN dia INTEGER');
    }
    // Agregar user_id para version 3
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE despachos ADD COLUMN user_id TEXT');
      } catch (e) {
        print('Error adding user_id column: $e');
      }
    }
  }

  Future<void> insertDespacho(Despacho despacho) async {
    final db = await database;
    await db.insert('despachos', despacho.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertDespachos(List<Despacho> despachos) async {
    final db = await database;
    Batch batch = db.batch();
    for (var despacho in despachos) {
      batch.insert('despachos', despacho.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

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

    // Filtrar por user_id para aislar datos por usuario
    if (userId != null) {
      whereClauses.add('user_id = ?');
      whereArgs.add(userId);
    }
    
    if (cliente != null) {
      whereClauses.add('cliente = ?');
      whereArgs.add(cliente);
    }
    if (ciudad != null) {
      whereClauses.add('ciudad = ?');
      whereArgs.add(ciudad);
    }
    if (fechaInicio != null) {
      whereClauses.add('fecha >= ?');
      whereArgs.add(fechaInicio.toIso8601String());
    }
    if (fechaFin != null) {
      whereClauses.add('fecha <= ?');
      whereArgs.add(fechaFin.toIso8601String());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'despachos',
      where: whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return List.generate(maps.length, (i) => Despacho.fromJson(maps[i]));
  }

  Future<void> deleteAllDespachos() async {
    final db = await database;
    await db.delete('despachos');
  }

  Future<void> deleteUserDespachos(String userId) async {
    final db = await database;
    await db.delete('despachos', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('despachos');
    // También limpiar SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Método para inicializar la base de datos de forma segura
  static Future<void> initializeDatabase() async {
    try {
      print('Initializing database helper...');
      final instance = DatabaseHelper();
      await instance.database;
      print('Database helper initialized successfully');
    } catch (e) {
      print('Failed to initialize database helper: $e');
      // No lanzar error para que la app pueda continuar
    }
  }

  Future<int> getDespachosCount() async {
    final db = await database;
    try {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM despachos');
      if (result.isNotEmpty && result.first.containsKey('count')) {
        final countValue = result.first['count'];
        if (countValue is int) {
          return countValue;
        } else if (countValue is num) {
          return countValue.toInt();
        }
      }
      // Fallback: contar manualmente
      final allRecords = await db.query('despachos');
      return allRecords.length;
    } catch (e) {
      print('Error getting despachos count: $e');
      return 0;
    }
  }
}