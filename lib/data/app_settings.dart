// lib/data/app_settings.dart
import 'package:flutter/foundation.dart';
import '../services/location_service.dart';

/// Preferencias simples de la app.
/// Ojo: ahora ya no pasamos distanceFilterMeters al servicio en start().
class AppSettings extends ChangeNotifier {
  bool _backgroundTracking = false;

  // Conservamos el valor para UI, pero el servicio ya no lo recibe aquí.
  int _distanceFilterMeters = 20;

  bool get backgroundTracking => _backgroundTracking;
  int get distanceFilterMeters => _distanceFilterMeters;

  /// Cambia el tracking en segundo plano.
  Future<void> setBackgroundTracking(
    bool value, {
    required LocationService svc,
  }) async {
    _backgroundTracking = value;
    notifyListeners();

    if (value) {
      // Asegura permisos y arranca foreground/background según tu LocationService.
      final ok = await svc.ensurePermission();
      if (!ok) {
        _backgroundTracking = false;
        notifyListeners();
        return;
      }
      // Arranca sin parámetros (el filtro se gestiona dentro del servicio o al construirlo).
      svc.startForeground(); // no await para no bloquear UI
    } else {
      await svc.stop();
    }
  }

  /// Ajusta el filtro de distancia que muestra la UI.
  /// Si quieres que afecte al tracking en caliente, añade un setter en LocationService.
  Future<void> setDistanceFilterMeters(
    int meters, {
    LocationService? svc,
  }) async {
    _distanceFilterMeters = meters;
    notifyListeners();

    // Si más adelante expones algo como svc.setMinStepMeters(meters), lo llamas aquí.
    // if (svc != null) svc.setMinStepMeters(meters);
  }
}
