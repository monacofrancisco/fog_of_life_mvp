class VisitedTileKey {
  final int z;
  final int x;
  final int y;
  const VisitedTileKey(this.z, this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is VisitedTileKey && other.z == z && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(z, x, y);
}