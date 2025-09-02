import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/local_db.dart';
import 'screens/map_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/settings_screen.dart';

class FogApp extends StatefulWidget {
  const FogApp({super.key});
  @override
  State<FogApp> createState() => _FogAppState();
}

class _FogAppState extends State<FogApp> {
  late final AppDatabase _db;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AppDatabase>.value(
      value: _db,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fog of Life',
        theme: ThemeData(
          colorSchemeSeed: Colors.green,
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        routes: {
          '/': (_) => const MapScreen(),
          '/progress': (_) => const ProgressScreen(),
          '/settings': (_) => const SettingsScreen(),   // <- RESTAURADA
        },
        initialRoute: '/',
      ),
    );
  }
}
