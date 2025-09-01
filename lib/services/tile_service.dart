import 'dart:math' as math;

class TileService {
  /// Converts lat/lon (degrees) to slippy tile x/y at zoom z.
  static (int x, int y) latLonToTile(double latDeg, double lonDeg, int z) {
    final latRad = latDeg * math.pi / 180.0;
    final n = math.pow(2.0, z);
    final x = ((lonDeg + 180.0) / 360.0 * n).floor();
    final y = ((1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) / 2.0 * n).floor();
    return (x, y);
  }
}