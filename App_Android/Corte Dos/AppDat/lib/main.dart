import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'widgets/main_navigation.dart';
import 'theme/app_theme.dart';

// Import sqflite con configuración para web
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  
  // Configurar sqflite para cada plataforma
  if (kIsWeb) {
    // Configurar factory para web
    databaseFactory = databaseFactoryFfiWeb;
    print('Configured sqflite for web');
  } else if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    print('Configured sqflite for desktop');
  } else {
    // Para otras plataformas, usar el factory por defecto
    print('Using default sqflite factory');
  }
  
  // Inicializar la base de datos antes de correr la app
  try {
    await DatabaseHelper.initializeDatabase();
  } catch (e) {
    print('Warning: Could not initialize database: $e');
    // Continuar con la app aunque la base de datos falle
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp.router(
        title: 'Envii',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Or ThemeMode.dark if preferred
        routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isAuthenticated;
    final isLoggingIn = state.uri.path == '/login';

    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }
    if (isLoggedIn && isLoggingIn) {
      return '/dashboard';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const MainNavigation(),
    ),
    GoRoute(
      path: '/upload',
      builder: (context, state) => const MainNavigation(),
    ),
    GoRoute(
      path: '/users',
      builder: (context, state) => const MainNavigation(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const MainNavigation(),
    ),
  ],
);

