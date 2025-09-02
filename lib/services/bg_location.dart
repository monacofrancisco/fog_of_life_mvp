// lib/services/bg_location.dart
// Stub temporal: evita errores de compilación mientras ajustamos la lib real
// para background tracking en iOS. Las llamadas desde Settings no harán nada.

class BgLocationService {
  static final BgLocationService _i = BgLocationService._();
  BgLocationService._();
  factory BgLocationService() => _i;

  bool get isRunning => false;

  Future<bool> isSupported() async {
    // En iOS real hace falta: Permiso Always + Background Modes (Location Updates)
    return false;
  }

  Future<void> start() async {
    // No-op por ahora
  }

  Future<void> stop() async {
    // No-op por ahora
  }
}
