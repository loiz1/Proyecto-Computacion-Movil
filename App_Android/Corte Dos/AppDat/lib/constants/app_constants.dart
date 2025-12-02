import 'package:flutter/material.dart';

class AppConstants {
  // Clientes oficiales del sistema
  static const List<String> clientesOficiales = [
    'BMW',
    'FERRARI',
    'MERCEDEZ',
    'BYD',
    'MCLAREN',
  ];

  // Colores de marca
  static const Map<String, Color> clientColors = {
    'BMW': Color(0xFF0066B1), // BMW Blue
    'FERRARI': Color(0xFFFF2800), // Ferrari Red
    'MERCEDEZ': Color(0xFFC0C0C0), // Mercedes Silver
    'BYD': Color(0xFF00A3E0), // BYD Blue/Teal
    'MCLAREN': Color(0xFFFF8000), // McLaren Orange
  };

  static Color getClientColor(String client) {
    return clientColors[client] ?? Colors.grey;
  }

  // Ciudades de Colombia
  static const List<String> ciudadesColombia = [
    'Bogotá',
    'Medellín',
    'Cali',
    'Barranquilla',
    'Cartagena',
    'Cúcuta',
    'Bucaramanga',
    'Pereira',
    'Santa Marta',
    'Ibagué',
    'Manizales',
    'Villavicencio',
    'Pasto',
    'Montería',
    'Valledupar',
    'Sincelejo',
    'Popayán',
    'Neiva',
    'Riohacha',
    'Armenia',
    'Tunja',
    'Florencia',
    'Yopal',
    'Quibdó',
    'Mocoa',
    'San Andrés',
    'Leticia',
    'Inírida',
    'San José del Guaviare',
    'Mitú',
    'Carurú',
    'Taraira',
    'Pacoa',
    'Cahianoyá',
    'Yavarate',
  ];

  // Permisos por rol
  static bool puedeCrearEnvios(String rol) {
    return rol == 'Administrador' || rol == 'Analista';
  }

  static bool esAdmin(String rol) {
    return rol == 'Administrador';
  }

  static bool esAnalista(String rol) {
    return rol == 'Analista' || rol == 'Administrador';
  }
}