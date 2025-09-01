import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'app.dart';
import 'data/local_db.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await AppDatabase.open();

  // Mantener pantalla encendida solo durante desarrollo
  if (!kReleaseMode) {
    await WakelockPlus.enable();
  }

  runApp(
    Provider<AppDatabase>.value(
      value: db,
      child: const FogApp(),
    ),
  );
}
