import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'providers/theme_provider.dart';
import 'providers/camera_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/gallery_provider.dart';
import 'database/database_helper.dart';
import 'screens/home_screen.dart';

void main() async {
  // Asegurar inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar base de datos
  await DatabaseHelper.instance.database;

  // Solicitar permisos iniciales
  await _requestPermissions();

  runApp(const Practica3App());
}

/// Solicita los permisos necesarios para la aplicación
Future<void> _requestPermissions() async {
  await [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
    Permission.photos,
  ].request();
}

class Practica3App extends StatelessWidget {
  const Practica3App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CameraProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Practica3',
            debugShowCheckedModeBanner: false,

            // Tema claro
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: themeProvider.currentThemeColor,
                brightness: Brightness.light,
              ),
              appBarTheme: AppBarTheme(
                elevation: 0,
                centerTitle: true,
                backgroundColor: themeProvider.currentThemeColor,
                foregroundColor: Colors.white,
              ),
            ),

            // Tema oscuro
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: themeProvider.currentThemeColor,
                brightness: Brightness.dark,
              ),
              appBarTheme: AppBarTheme(
                elevation: 0,
                centerTitle: true,
                backgroundColor: themeProvider.currentThemeColor.withOpacity(0.8),
              ),
            ),

            // Usar modo oscuro según configuración
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}