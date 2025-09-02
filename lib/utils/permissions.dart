// lib/utils/permissions.dart
import 'package:geolocator/geolocator.dart';

class PermissionHelper {
  /// Asegura permiso de localización "Always" en iOS 13+ con fallback a Ajustes.
  static Future<LocationPermission> ensureAlwaysPermission() async {
    // 1) Comprobar estado actual
    var p = await Geolocator.checkPermission();

    // 2) Si está denegado, pedir el diálogo inicial (normalmente WhileInUse)
    if (p == LocationPermission.denied || p == LocationPermission.deniedForever) {
      p = await Geolocator.requestPermission();
    }

    // 3) Si tenemos WhileInUse, intentamos “upgrade” a Always
    if (p == LocationPermission.whileInUse) {
      // Un segundo requestPermission puede disparar el banner de “Change to Always Allow”
      p = await Geolocator.requestPermission();

      // 4) Si sigue sin ser Always, llevar a Ajustes con una explicación previa en UI
      if (p != LocationPermission.always) {
        await Geolocator.openAppSettings();
        // Tras volver de ajustes, re-comprobar (no bloqueante)
        p = await Geolocator.checkPermission();
      }
    }

    return p;
  }

  /// Verifica que el servicio de localización del sistema esté activo.
  static Future<bool> ensureServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    return enabled;
  }
}
