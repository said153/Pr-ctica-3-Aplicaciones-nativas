import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// Pantalla de configuración de la aplicación
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return ListView(
            children: [
              // Sección de Apariencia
              const ListTile(
                title: Text(
                  'Apariencia',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              // Modo oscuro
              SwitchListTile(
                title: const Text('Modo oscuro'),
                subtitle: const Text('Usar tema oscuro'),
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleDarkMode(),
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
              ),

              const Divider(),

              // Selector de tema de color
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Color del tema'),
                subtitle: Text(
                  themeProvider.isGuindaTheme ? 'Guinda' : 'Azul',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón Guinda
                    GestureDetector(
                      onTap: () => themeProvider.setTheme(true),
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: ThemeProvider.guindaColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: themeProvider.isGuindaTheme
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: themeProvider.isGuindaTheme
                              ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                              : null,
                        ),
                      ),
                    ),
                    // Botón Azul
                    GestureDetector(
                      onTap: () => themeProvider.setTheme(false),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: ThemeProvider.azulColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: !themeProvider.isGuindaTheme
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: !themeProvider.isGuindaTheme
                              ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Sección de Información
              const ListTile(
                title: Text(
                  'Información',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              // Acerca de
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Acerca de'),
                subtitle: const Text('Practica3 v1.0.0'),
                onTap: () => _showAboutDialog(context),
              ),

              // Ayuda
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Ayuda'),
                subtitle: const Text('Cómo usar la aplicación'),
                onTap: () => _showHelpDialog(context),
              ),

              const Divider(),

              // Sección de Almacenamiento
              const ListTile(
                title: Text(
                  'Almacenamiento',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              // Limpiar caché
              ListTile(
                leading: const Icon(Icons.cleaning_services),
                title: const Text('Limpiar caché'),
                subtitle: const Text('Eliminar archivos temporales'),
                onTap: () => _showClearCacheDialog(context),
              ),

              const Divider(),

              // Sección de Permisos
              const ListTile(
                title: Text(
                  'Permisos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              // Información de permisos
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Gestionar permisos'),
                subtitle: const Text('Cámara, micrófono y almacenamiento'),
                onTap: () => _showPermissionsInfo(context),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Mostrar diálogo "Acerca de"
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Practica3',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.camera_alt,
        size: 48,
        color: Provider.of<ThemeProvider>(context, listen: false).currentThemeColor,
      ),
      children: [
        const Text(
          'Aplicación multimedia con captura de fotos, grabación de audio y galería integrada.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Desarrollado con Flutter 3.x',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  /// Mostrar diálogo de ayuda
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cámara',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Toca el círculo blanco para capturar fotos'),
              Text('• Usa los controles superiores para flash y temporizador'),
              Text('• Cambia entre filtros deslizando horizontalmente'),
              Text('• Alterna entre cámara frontal y trasera'),
              SizedBox(height: 16),
              Text(
                'Audio',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Toca el botón rojo para iniciar grabación'),
              Text('• Pausa y reanuda según necesites'),
              Text('• Configura calidad y temporizador en ajustes'),
              SizedBox(height: 16),
              Text(
                'Galería',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Mantén presionado para selección múltiple'),
              Text('• Toca para ver detalles y editar'),
              Text('• Organiza en álbumes y etiquetas'),
              Text('• Comparte o elimina archivos'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar diálogo de limpiar caché
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar caché'),
        content: const Text(
          '¿Deseas eliminar todos los archivos temporales? '
              'Esta acción no eliminará tus fotos y audios guardados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Caché limpiado correctamente'),
                ),
              );
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar información de permisos
  void _showPermissionsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permisos necesarios'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Cámara'),
                subtitle: Text('Para capturar fotos'),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: Icon(Icons.mic),
                title: Text('Micrófono'),
                subtitle: Text('Para grabar audio'),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: Icon(Icons.storage),
                title: Text('Almacenamiento'),
                subtitle: Text('Para guardar fotos y audios'),
                contentPadding: EdgeInsets.zero,
              ),
              SizedBox(height: 8),
              Text(
                'Puedes gestionar estos permisos desde la configuración de tu dispositivo.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}