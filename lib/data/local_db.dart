import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'local_db.g.dart';

class VisitedTiles extends Table {
  IntColumn get z => integer()();
  IntColumn get x => integer()();
  IntColumn get y => integer()();

  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {z, x, y};
}

@DriftDatabase(tables: [VisitedTiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  static Future<AppDatabase> open() async => AppDatabase();

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(visitedTiles);
          }
        },
      );

  // API
  Future<void> upsertTile(int z, int x, int y) async {
    final row = VisitedTilesCompanion.insert(z: z, x: x, y: y);
    await into(visitedTiles).insertOnConflictUpdate(row);
  }

  Future<List<VisitedTile>> allTiles({int? limit}) {
    final q = select(visitedTiles)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (limit != null) q.limit(limit);
    return q.get();
  }

  Future<int> countTiles() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS c FROM visited_tiles;',
      readsFrom: {visitedTiles},
    ).getSingle();
    final value = row.data['c'];
    if (value is int) return value;
    if (value is BigInt) return value.toInt();
    if (value is num) return value.toInt();
    return 0;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'database.sqlite3'));
    return NativeDatabase(file);
  });
}
