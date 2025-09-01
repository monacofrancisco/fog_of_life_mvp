// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_db.dart';

// ignore_for_file: type=lint
class $VisitedTilesTable extends VisitedTiles
    with TableInfo<$VisitedTilesTable, VisitedTile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitedTilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _zMeta = const VerificationMeta('z');
  @override
  late final GeneratedColumn<int> z = GeneratedColumn<int>(
      'z', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<int> x = GeneratedColumn<int>(
      'x', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<int> y = GeneratedColumn<int>(
      'y', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  @override
  List<GeneratedColumn> get $columns => [z, x, y, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visited_tiles';
  @override
  VerificationContext validateIntegrity(Insertable<VisitedTile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('z')) {
      context.handle(_zMeta, z.isAcceptableOrUnknown(data['z']!, _zMeta));
    } else if (isInserting) {
      context.missing(_zMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {z, x, y};
  @override
  VisitedTile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitedTile(
      z: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}z'])!,
      x: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}x'])!,
      y: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}y'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $VisitedTilesTable createAlias(String alias) {
    return $VisitedTilesTable(attachedDatabase, alias);
  }
}

class VisitedTile extends DataClass implements Insertable<VisitedTile> {
  final int z;
  final int x;
  final int y;
  final DateTime createdAt;
  const VisitedTile(
      {required this.z,
      required this.x,
      required this.y,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['z'] = Variable<int>(z);
    map['x'] = Variable<int>(x);
    map['y'] = Variable<int>(y);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VisitedTilesCompanion toCompanion(bool nullToAbsent) {
    return VisitedTilesCompanion(
      z: Value(z),
      x: Value(x),
      y: Value(y),
      createdAt: Value(createdAt),
    );
  }

  factory VisitedTile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitedTile(
      z: serializer.fromJson<int>(json['z']),
      x: serializer.fromJson<int>(json['x']),
      y: serializer.fromJson<int>(json['y']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'z': serializer.toJson<int>(z),
      'x': serializer.toJson<int>(x),
      'y': serializer.toJson<int>(y),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VisitedTile copyWith({int? z, int? x, int? y, DateTime? createdAt}) =>
      VisitedTile(
        z: z ?? this.z,
        x: x ?? this.x,
        y: y ?? this.y,
        createdAt: createdAt ?? this.createdAt,
      );
  VisitedTile copyWithCompanion(VisitedTilesCompanion data) {
    return VisitedTile(
      z: data.z.present ? data.z.value : this.z,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitedTile(')
          ..write('z: $z, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(z, x, y, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitedTile &&
          other.z == this.z &&
          other.x == this.x &&
          other.y == this.y &&
          other.createdAt == this.createdAt);
}

class VisitedTilesCompanion extends UpdateCompanion<VisitedTile> {
  final Value<int> z;
  final Value<int> x;
  final Value<int> y;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VisitedTilesCompanion({
    this.z = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitedTilesCompanion.insert({
    required int z,
    required int x,
    required int y,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : z = Value(z),
        x = Value(x),
        y = Value(y);
  static Insertable<VisitedTile> custom({
    Expression<int>? z,
    Expression<int>? x,
    Expression<int>? y,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (z != null) 'z': z,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitedTilesCompanion copyWith(
      {Value<int>? z,
      Value<int>? x,
      Value<int>? y,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return VisitedTilesCompanion(
      z: z ?? this.z,
      x: x ?? this.x,
      y: y ?? this.y,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (z.present) {
      map['z'] = Variable<int>(z.value);
    }
    if (x.present) {
      map['x'] = Variable<int>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<int>(y.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitedTilesCompanion(')
          ..write('z: $z, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VisitedTilesTable visitedTiles = $VisitedTilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [visitedTiles];
}

typedef $$VisitedTilesTableCreateCompanionBuilder = VisitedTilesCompanion
    Function({
  required int z,
  required int x,
  required int y,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$VisitedTilesTableUpdateCompanionBuilder = VisitedTilesCompanion
    Function({
  Value<int> z,
  Value<int> x,
  Value<int> y,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$VisitedTilesTableFilterComposer
    extends Composer<_$AppDatabase, $VisitedTilesTable> {
  $$VisitedTilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get z => $composableBuilder(
      column: $table.z, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get x => $composableBuilder(
      column: $table.x, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get y => $composableBuilder(
      column: $table.y, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$VisitedTilesTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitedTilesTable> {
  $$VisitedTilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get z => $composableBuilder(
      column: $table.z, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get x => $composableBuilder(
      column: $table.x, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get y => $composableBuilder(
      column: $table.y, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$VisitedTilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitedTilesTable> {
  $$VisitedTilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get z =>
      $composableBuilder(column: $table.z, builder: (column) => column);

  GeneratedColumn<int> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<int> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VisitedTilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VisitedTilesTable,
    VisitedTile,
    $$VisitedTilesTableFilterComposer,
    $$VisitedTilesTableOrderingComposer,
    $$VisitedTilesTableAnnotationComposer,
    $$VisitedTilesTableCreateCompanionBuilder,
    $$VisitedTilesTableUpdateCompanionBuilder,
    (
      VisitedTile,
      BaseReferences<_$AppDatabase, $VisitedTilesTable, VisitedTile>
    ),
    VisitedTile,
    PrefetchHooks Function()> {
  $$VisitedTilesTableTableManager(_$AppDatabase db, $VisitedTilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitedTilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitedTilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitedTilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> z = const Value.absent(),
            Value<int> x = const Value.absent(),
            Value<int> y = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VisitedTilesCompanion(
            z: z,
            x: x,
            y: y,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int z,
            required int x,
            required int y,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VisitedTilesCompanion.insert(
            z: z,
            x: x,
            y: y,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VisitedTilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VisitedTilesTable,
    VisitedTile,
    $$VisitedTilesTableFilterComposer,
    $$VisitedTilesTableOrderingComposer,
    $$VisitedTilesTableAnnotationComposer,
    $$VisitedTilesTableCreateCompanionBuilder,
    $$VisitedTilesTableUpdateCompanionBuilder,
    (
      VisitedTile,
      BaseReferences<_$AppDatabase, $VisitedTilesTable, VisitedTile>
    ),
    VisitedTile,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VisitedTilesTableTableManager get visitedTiles =>
      $$VisitedTilesTableTableManager(_db, _db.visitedTiles);
}
