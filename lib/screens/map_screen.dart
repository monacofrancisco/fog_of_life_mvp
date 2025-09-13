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
  // Nivel de almacenamiento en DB (alta resolución)
  static const int _zTilesStore = 22;

  // Radio de revelado “real” en metros
  static const double _revealRadiusMeters = 40.0;

  // Stadia Maps style (sustituye por tu key si cambias de proyecto)
  static const String _stadiaStyle =
      'https://tiles.stadiamaps.com/styles/alidade_smooth.json?api_key=54b965b4-663d-4b73-920d-8bce96d66366';

  // IDs para la niebla
  static const String _srcFog = 'src-fog';
  static const String _layerFog = 'layer-fog';

  MapLibreMapController? _ctrl;
  StreamSubscription<Position>? _posSub;
  bool _styleReady = false;

  // Última posición conocida (para centrar si hace falta)
  Position? _lastPos;

  // ---- Camera follow (bloqueo en el punto azul) ----
  bool _follow = true; // arrancamos siguiendo para sensación "bloqueo" inmediata

  // ---- Multi-res: control adaptativo por píxeles en pantalla ----
  // No bajar de este zoom de render. Ajusta si quieres
  static const int _minRenderZ = 18;

  // Tamaño CSS base de un tile raster
  static const double _tileCssPx = 256.0;

  // Histeresis: bajar cuando el tile del renderZ actual < 2px; subir cuando > 4px
  static const double _minPxDown = 2.0;
  static const double _minPxUp = 4.0;

  // renderZ actual (el que usamos para dibujar; arranca en el almacenado)
  int _renderZ = _zTilesStore;

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
    final y =
        (1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) / 2 *
            n;
    return y.floor();
  }

  int _metersToTileRadius(double meters, double latDeg, int z) {
    final metersPerTile = math.cos(latDeg * math.pi / 180.0) *
        (2 * math.pi * 6378137.0) /
        math.pow(2, z);
    final tiles = (meters / metersPerTile).ceil();
    return tiles.clamp(1, 400);
  }

  // ------- REVEAL: guardar en DB a _zTilesStore -------
  Future<void> _revealDiscTiles(AppDatabase db, double lat, double lon) async {
    final cx = _lon2tileX(lon, _zTilesStore);
    final cy = _lat2tileY(lat, _zTilesStore);
    final rTiles = _metersToTileRadius(_revealRadiusMeters, lat, _zTilesStore);

    for (int dy = -rTiles; dy <= rTiles; dy++) {
      for (int dx = -rTiles; dx <= rTiles; dx++) {
        if (dx * dx + dy * dy <= rTiles * rTiles) {
          await db.upsertTile(_zTilesStore, cx + dx, cy + dy);
        }
      }
    }
  }

  // ------- RENDER: elegir renderZ por tamaño en pantalla con histeresis -------
  Future<double?> _estimateZoomFromBounds() async {
    try {
      final b = await _ctrl!.getVisibleRegion();
      final sw = b.southwest;
      final ne = b.northeast;

      var lonDelta = (ne.longitude - sw.longitude).abs();
      if (lonDelta <= 1e-7) lonDelta = 1e-7;

      final widthPx = MediaQuery.of(context).size.width;
      // z ≈ log2( (width * 360) / (tileSize * lonDelta) )
      final z = math.log((widthPx * 360.0) / (_tileCssPx * lonDelta)) / math.ln2;
      return z;
    } catch (_) {
      return null;
    }
  }

  double _tileScreenPx(double zoom, int z) {
    // Intuición: si esto baja de ~1–3 px, aparece el “apagón” del agujero.
    return _tileCssPx * math.pow(2.0, zoom - z);
  }

  int _pickRenderZWithHysteresis(double zoom, int currentRenderZ) {
    int z = currentRenderZ;

    // Bajar detalle si el tile del nivel actual cae por debajo de _minPxDown
    while (z > _minRenderZ && _tileScreenPx(zoom, z) < _minPxDown) {
      z -= 1;
    }

    // Subir detalle si hay margen de pantalla
    while (z < _zTilesStore && _tileScreenPx(zoom, z) > _minPxUp) {
      z += 1;
    }

    return z;
  }

  Future<void> _maybeUpdateRenderZ(AppDatabase db) async {
    if (_ctrl == null) return;
    final z = await _estimateZoomFromBounds();
    if (z == null) return;

    final newRenderZ = _pickRenderZWithHysteresis(z, _renderZ);
    if (newRenderZ != _renderZ) {
      _renderZ = newRenderZ;
      await _rebuildFogForRenderZ(db, _renderZ);
    }
  }

  // ------- Construcción del GeoJSON de niebla para un renderZ dado -------
  Future<void> _rebuildFogForRenderZ(AppDatabase db, int targetZ) async {
    if (!_styleReady || _ctrl == null) return;

    final rows = await db.allTiles(); // almacenados a _zTilesStore

    // Polígono exterior (mundo aproximado)
    final List<List<double>> outer = [
      [-179.999, 85.0],
      [179.999, 85.0],
      [179.999, -85.0],
      [-179.999, -85.0],
      [-179.999, 85.0],
    ];

    // Si targetZ == storeZ: agujeros = tiles exactos
    // Si targetZ < storeZ: agrupamos a su "parent" con right-shift (x >> k, y >> k)
    final k = (_zTilesStore - targetZ).clamp(0, 30);
    final Set<String> holesSet = {};
    for (final t in rows) {
      final px = (k == 0) ? t.x : (t.x >> k);
      final py = (k == 0) ? t.y : (t.y >> k);
      holesSet.add('$px:$py'); // evitamos duplicados
    }

    final List<List<List<double>>> holes = [];
    for (final key in holesSet) {
      final parts = key.split(':');
      final x = int.parse(parts[0]);
      final y = int.parse(parts[1]);
      final bb = _tileBBox(x, y, targetZ);
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
      'properties': {},
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

  Future<void> _ensureFogLayer(AppDatabase db) async {
    if (_ctrl == null) return;

    // Fuente GeoJSON
    await _ctrl!.addSource(
      _srcFog,
      const GeojsonSourceProperties(
        data: {
          'type': 'FeatureCollection',
          'features': [],
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

    // Primer render a la resolución de almacenamiento
    _renderZ = _zTilesStore;
    await _rebuildFogForRenderZ(db, _renderZ);
  }

  // ---- Position flow (DB + niebla) ----
  Future<void> _onPosition(AppDatabase db, Position p) async {
    _lastPos = p;
    await _revealDiscTiles(db, p.latitude, p.longitude);
    await _rebuildFogForRenderZ(db, _renderZ); // mantenemos renderZ vigente
  }

  // ---- Camera follow helpers ----
  Future<void> _enableFollow() async {
    if (_ctrl == null) return;
    setState(() => _follow = true);
    // Deja que MapLibre mueva la cámara con su animación nativa hacia el puck.
    await _ctrl!.updateMyLocationTrackingMode(MyLocationTrackingMode.trackingGps);
  }

  Future<void> _disableFollow() async {
    if (_ctrl == null) return;
    setState(() => _follow = false);
    await _ctrl!.updateMyLocationTrackingMode(MyLocationTrackingMode.none);
  }

  Future<void> _toggleFollow() async {
    if (_follow) {
      await _disableFollow();
    } else {
      await _enableFollow();
    }
  }

  // Centrar una vez (sin activar follow)
  Future<void> _centerOnceOnUser() async {
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
            styleString: _stadiaStyle, // Stadia Maps
            initialCameraPosition: const CameraPosition(
              target: LatLng(39.448297, -0.365441), // Home!
              zoom: 17.0,
            ),

            // Hacemos el motor de localización del MAPA más “rápido” en Android
            // (iOS no soporta esta personalización; usa defaults del SDK).
            locationEnginePlatforms: const LocationEnginePlatforms(
              androidPlatform: LocationEngineAndroidProperties(
                interval: 1000, // ms
                displacement: 0, // m
                priority: LocationPriority.highAccuracy,
              ),
            ),

            // Seguimiento inicial según _follow (bloqueo cámara en el punto azul)
            myLocationEnabled: true,
            myLocationTrackingMode:
                _follow ? MyLocationTrackingMode.trackingGps : MyLocationTrackingMode.none,

            // Callbacks de tracking (romper/actualizar estado UI)
            onCameraTrackingDismissed: () {
              // El usuario ha movido/rotado el mapa: salimos del "follow"
              if (_follow) _disableFollow();
            },
            onCameraTrackingChanged: (_) {
              // Mantener el estado en sincronía si el SDK lo cambia
              setState(() {});
            },

            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,

            onMapCreated: (c) async {
              _ctrl = c;
            },

            onStyleLoadedCallback: () async {
              _styleReady = true;
              await _ensureFogLayer(db);

              // Permisos + primera posición
              await Geolocator.requestPermission();

              final pos = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.best,
              );
              await _onPosition(db, pos);

              // Stream de posiciones (revelado continuo a z=22)
              _posSub?.cancel();
              _posSub = Geolocator.getPositionStream(
                locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.best,
                  distanceFilter: 5,
                ),
              ).listen((p) async {
                await _onPosition(db, p);
              });

              // Si el modo seguir está activo al cargar el estilo, asegúralo en el SDK
              if (_follow) {
                await _ctrl!.updateMyLocationTrackingMode(
                  MyLocationTrackingMode.trackingGps,
                );
              }
            },

            // >>> Importante: recalcular renderZ adaptativo cuando termine un gesto
            onCameraIdle: () async {
              await _maybeUpdateRenderZ(db);
            },
          ),

          // --- UI (igual que tenías) ---
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

          // FAB: Seguir / dejar de seguir (camera-lock)
          Positioned(
            right: 16,
            bottom: 24,
            child: FloatingActionButton.extended(
              heroTag: 'follow_toggle',
              onPressed: _toggleFollow,
              icon: Icon(_follow ? Icons.gps_fixed : Icons.my_location),
              label: Text(_follow ? 'Siguiendo' : 'Seguir'),
            ),
          ),
        ],
      ),
    );
  }
}
