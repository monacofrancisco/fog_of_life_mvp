import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final double minStepMeters; // throttle distance
  Position? _lastSaved;
  StreamSubscription<Position>? _sub;

  LocationService({this.minStepMeters = 10});

  Future<bool> ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  Stream<Position> startForeground() {
    _sub?.cancel();
    final controller = StreamController<Position>.broadcast();

    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 1),
    ).listen((pos) {
      if (_lastSaved == null ||
          Geolocator.distanceBetween(
                  _lastSaved!.latitude, _lastSaved!.longitude, pos.latitude, pos.longitude) >=
              minStepMeters) {
        _lastSaved = pos;
        controller.add(pos);
      }
    });

    controller.onCancel = () => _sub?.cancel();
    return controller.stream;
  }

  Future<void> stop() async => _sub?.cancel();
}