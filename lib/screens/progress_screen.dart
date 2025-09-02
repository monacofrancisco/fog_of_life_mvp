import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/local_db.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int? _count;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = context.read<AppDatabase>();
    final c = await db.countTiles();
    if (mounted) setState(() => _count = c);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progreso')),
      body: Center(
        child: Text(
          _count == null ? 'Cargando…' : 'Tiles descubiertos: $_count',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
