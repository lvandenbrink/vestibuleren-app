import 'package:flutter/services.dart';
import '../models/exercise.dart';

List<Exercise> exerciseCatalog = [];

Future<void> loadExerciseCatalog() async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  final paths = manifest.listAssets()
      .where((p) => p.startsWith('assets/exercises/') && p.endsWith('.md'))
      .toList()
    ..sort();
  exerciseCatalog = await Future.wait(paths.map(_parseExercise));
}

Future<Exercise> _parseExercise(String path) async {
  final raw = await rootBundle.loadString(path);
  final meta = _parseFrontmatter(raw);
  return Exercise(
    id: meta['id'] ?? '',
    title: meta['title'] ?? '',
    description: meta['description'] ?? '',
    contentPath: path,
    defaultBpm: int.tryParse(meta['bpm'] ?? '') ?? 0,
  );
}

Map<String, String> _parseFrontmatter(String content) {
  if (!content.startsWith('---\n')) return {};
  final end = content.indexOf('\n---', 4);
  if (end == -1) return {};
  return Map.fromEntries(
    content.substring(4, end).split('\n').map((line) {
      final colon = line.indexOf(':');
      if (colon == -1) return const MapEntry('', '');
      return MapEntry(
        line.substring(0, colon).trim(),
        line.substring(colon + 1).trim(),
      );
    }).where((e) => e.key.isNotEmpty),
  );
}
