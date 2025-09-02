import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Nombre del callback para registrar el isolate en iOS
const String _isolateName = 'LocatorIsolate';

class BgLocationService {
  static final BgLocationService _instance = BgLocationService._internal();
  factory BgLocationService() => _instance;
  BgLocationService._internal();

  bool _initialized = false;

  /// Debe ser top-level o static porque iOS lo re-llama en background.
  static void callback(LocationDto data) async {
    // Aquí guardamos el punto (z/x/y) o lo que necesites.
    // Como ejemplo, escribimos un log en un archivo para verificar que corre en background.

    final dir = await getApplicationDocumentsDirectory();
    final f = File('${dir.path}/bg_log.txt');
    final line = '${DateTime.now().toIso8601String()}|${data.latitude},${data.longitude}\n';
    await f.writeAsString(line, mode: FileMode.append, flush: true);

    // TODO: aquí puedes llamar a un método que traduzca (lat,lon) -> tile y
    // use tu AppDatabase para insertar sin bloquear (mejor colas simples).
  }

  /// Llamado por iOS al inicializar el isolate en background
  static void initCallback() {}

  /// Llamado cuando se detiene
  static void disposeCallback() {}

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    IsolateNameServer.removePortNameMapping(_isolateName);
    _initialized = await BackgroundLocator.initialize();
  }

  Future<void> start({int distanceFilterMeters = 10}) async {
    await ensureInitialized();

    final alreadyRunning = await BackgroundLocator.isServiceRunning();
    if (alreadyRunning) return;

    await BackgroundLocator.registerLocationUpdate(
      callback,
      initCallback: initCallback,
      disposeCallback: disposeCallback,
      iosSettings: IOSSettings(
        accuracy: LocationAccuracy.NAVIGATION, // alta precisión
        distanceFilter: distanceFilterMeters,
        showsBackgroundLocationIndicator: true, // puntito azul en status bar
        pauseLocationUpdatesAutomatically: false,
        activityType: ActivityType.FITNESS, // o .OTHER_NAVIGATION
      ),
      autoStop: false,
      androidSettings: const AndroidSettings(
        // Ignorado en iOS, pero lo dejamos definido
        accuracy: LocationAccuracy.NAVIGATION,
        distanceFilter: 10,
        interval: 5,
        androidNotificationSettings: AndroidNotificationSettings(
          notificationChannelName: 'bg_location',
          notificationTitle: 'Fog of Life',
          notificationMsg: 'Tracking in background',
          notificationIcon: '',
          notificationIconColor: 0,
          notificationTapCallback: null,
        ),
      ),
    );
  }

  Future<void> stop() async {
    final running = await BackgroundLocator.isServiceRunning();
    if (running) {
      await BackgroundLocator.unRegisterLocationUpdate();
    }
  }
}
