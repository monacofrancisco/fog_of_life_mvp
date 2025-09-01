import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _keepAwake = true; // por defecto activo durante desarrollo

  @override
  void initState() {
    super.initState();
    // Sincroniza con wakelock real (por si vienes del Map y ya está activo)
    WakelockPlus.enabled.then((v) => setState(() => _keepAwake = v));
  }

  Future<void> _toggleKeepAwake(bool v) async {
    setState(() => _keepAwake = v);
    if (v) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          SwitchListTile.adaptive(
            title: const Text('Mantener pantalla encendida'),
            subtitle: const Text('Útil durante el desarrollo y pruebas'),
            value: _keepAwake,
            onChanged: _toggleKeepAwake,
          ),
          const Divider(),
          ListTile(
            title: const Text('Permisos de ubicación'),
            subtitle: const Text('Abre Ajustes del sistema para revisarlos'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // En iOS abrir ajustes de la app:
              // showDialog/nota: para abrir ajustes puedes usar
              // app_settings (paquete) si lo añades a pubspec:
              // app_settings: ^5.1.1
              // AppSettings.openAppSettings();
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('Abrir ajustes'),
                  content: Text(
                      'Para abrir Ajustes desde la app añade el paquete app_settings y llama a AppSettings.openAppSettings().'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
