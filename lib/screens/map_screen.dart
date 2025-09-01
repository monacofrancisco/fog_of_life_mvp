// lib/screens/map_screen.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';

import '../data/local_db.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // ----- Config -----
  static const int _zTiles = 22; // tiles pequeños (puedes ajustar)
  static const double _revealRadiusMeters = 40.0;

  // Stadia Maps style (sustituye la API key)
  static const String _stadiaStyle =
      'https://tiles.stadiamaps.com/styles/alidade_smooth.json?api_key=54b965b4-663d-4b73-920d-8bce96d66366';

  // IDs para la niebla
  static const String _srcFog = 'src-fog';
  static const String _layerFog = 'layer-fog';

  MapLibreMapController? _ctrl;
  StreamSubscription<Position>? _posSub;
  bool _styleReady = false;

  // Última posición conocida (para centrar)
  Position? _lastPos;

  // ---- Helpers matemáticos ----
  double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2.0;

  double _tile2lat(int y, int z) {
    final n = math.pi * (1 - 2 * y / math.pow(2, z));
    return (180.0 / math.pi) * math.atan(_sinh(n));
  }

  double _tileX2lon(int x, int z) {
    final n = math.pow(2, z).toDouble();
    return x / n * 360.0 - 180.0;
  }

  Map<String, double> _tileBBox(int x, int y, int z) {
    final west = _tileX2lon(x, z);
    final east = _tileX2lon(x + 1, z);
    final north = _tile2lat(y, z);
    final south = _tile2lat(y + 1, z);
    return {'w': west, 'e': east, 'n': north, 's': south};
  }

  int _lon2tileX(double lon, int z) {
    final n = math.pow(2, z).toDouble();
    return ((lon + 180.0) / 360.0 * n).floor();
  }

  int _lat2tileY(double lat, int z) {
    final n = math.pow(2, z).toDouble();
    final latRad = lat * math.pi / 180.0;
    final y = (1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) / 2 * n;
    return y.floor();
  }

  int _metersToTileRadius(double meters, double latDeg, int z) {
    final metersPerTile =
        math.cos(latDeg * math.pi / 180.0) * (2 * math.pi * 6378137.0) / math.pow(2, z);
    final tiles = (meters / metersPerTile).ceil();
    return tiles.clamp(1, 200);
  }

  // ---- DB -> reconstruir niebla (agujeros) ----
  Future<void> _rebuildFogFromDb(AppDatabase db) async {
    if (!_styleReady || _ctrl == null) return;

    final rows = await db.allTiles();

    // Polígono exterior (mundo aproximado)
    final outer = <List<double>>[
      [-179.999, 85.0],
      [179.999, 85.0],
      [179.999, -85.0],
      [-179.999, -85.0],
      [-179.999, 85.0],
    ];

    // Agujeros por cada tile visitado
    final holes = <List<List<double>>>[];
    for (final t in rows) {
      final bb = _tileBBox(t.x, t.y, t.z);
      final ring = <List<double>>[
        [bb['w']!, bb['s']!],
        [bb['e']!, bb['s']!],
        [bb['e']!, bb['n']!],
        [bb['w']!, bb['n']!],
        [bb['w']!, bb['s']!],
      ];
      holes.add(ring);
    }

    final fogPolygon = {
      'type': 'Feature',
      'properties': <String, dynamic>{},
      'geometry': {
        'type': 'Polygon',
        'coordinates': [outer, ...holes],
      },
    };

    final fogFc = {
      'type': 'FeatureCollection',
      'features': [fogPolygon],
    };

    await _ctrl!.setGeoJsonSource(_srcFog, fogFc);
  }

  // ---- Revelar disco de tiles alrededor de lat/lon ----
  Future<void> _revealDiscTiles(AppDatabase db, double lat, double lon) async {
    final cx = _lon2tileX(lon, _zTiles);
    final cy = _lat2tileY(lat, _zTiles);
    final rTiles = _metersToTileRadius(_revealRadiusMeters, lat, _zTiles);

    for (int dy = -rTiles; dy <= rTiles; dy++) {
      for (int dx = -rTiles; dx <= rTiles; dx++) {
        if (dx * dx + dy * dy <= rTiles * rTiles) {
          await db.upsertTile(_zTiles, cx + dx, cy + dy);
        }
      }
    }
  }

  // ---- Crear fuente y capa (compatible con 0.22.0) ----
  Future<void> _ensureFogLayer(AppDatabase db) async {
    if (_ctrl == null) return;

    // Fuente GeoJSON
    await _ctrl!.addSource(
      _srcFog,
      GeojsonSourceProperties(
        data: {
          'type': 'FeatureCollection',
          'features': <dynamic>[],
        },
      ),
    );

    // Capa de relleno (negro semitransparente)
    await _ctrl!.addFillLayer(
      _srcFog,
      _layerFog,
      const FillLayerProperties(
        fillColor: '#000000',
        fillOpacity: 0.95,
      ),
    );

    await _rebuildFogFromDb(db);
  }

  Future<void> _onPosition(AppDatabase db, Position p) async {
    _lastPos = p;
    await _revealDiscTiles(db, p.latitude, p.longitude);
    await _rebuildFogFromDb(db);
  }

  Future<void> _centerOnUser() async {
    final p = _lastPos;
    if (_ctrl != null && p != null) {
      await _ctrl!.animateCamera(
        CameraUpdate.newLatLng(LatLng(p.latitude, p.longitude)),
      );
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          MapLibreMap(
            styleString: _stadiaStyle, // Stadia Maps (con tu API key)
            initialCameraPosition: const CameraPosition(
              target: LatLng(39.448297, -0.365441), // Home!
              zoom: 17.0,
            ),
            onMapCreated: (c) async {
              _ctrl = c;
            },
            onStyleLoadedCallback: () async {
              _styleReady = true;
              await _ensureFogLayer(db);

              // Permisos + primera posición
              await Geolocator.requestPermission();
              var perm = await Geolocator.checkPermission();
if (perm == LocationPermission.denied) {
  perm = await Geolocator.requestPermission();
}
if (perm == LocationPermission.whileInUse) {
  // iOS: para subir a “Always” hay que llevar al usuario a Ajustes
  // (iOS solo muestra el segundo diálogo después de usar la app un rato).
  // Le abrimos ajustes si quiere.
  // Puedes envolverlo en un diálogo tuyo si prefieres.
  await Geolocator.openAppSettings();
}
              final pos = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.best,
              );
              await _onPosition(db, pos);

              _posSub?.cancel();
_posSub = Geolocator.getPositionStream(
  locationSettings: AppleSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 5,                       // ajusta si quieres ahorrar batería
    allowBackgroundLocationUpdates: true,    // <- CLAVE
    pauseLocationUpdatesAutomatically: false,
    activityType: ActivityType.fitness,      // walking/running → menos pausas
    showBackgroundLocationIndicator: true,   // circulito azul en status bar
  ),
).listen((p) async {
  await _onPosition(db, p);
});
            },
            myLocationEnabled: true,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
          ),

          // --- UI ligera (recuperada) ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botón Progreso
                  Material(
                    color: Colors.black.withOpacity(0.35),
                    shape: const StadiumBorder(),
                    child: IconButton(
                      tooltip: 'Progreso',
                      icon: const Icon(Icons.flag, color: Colors.white),
                      onPressed: () => Navigator.of(context).pushNamed('/progress'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón Settings
                  Material(
                    color: Colors.black.withOpacity(0.35),
                    shape: const StadiumBorder(),
                    child: IconButton(
                      tooltip: 'Ajustes',
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () => Navigator.of(context).pushNamed('/settings'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // FAB de centrar
          Positioned(
            right: 16,
            bottom: 24,
            child: FloatingActionButton.extended(
              heroTag: 'center_me',
              onPressed: _centerOnUser,
              icon: const Icon(Icons.my_location),
              label: const Text('Centrar'),
            ),
          ),
        ],
      ),
    );
  }
}
