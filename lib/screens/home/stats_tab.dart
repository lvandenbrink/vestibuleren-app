import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/feedback_provider.dart';
import '../../models/feedback_entry.dart';

class StatsTab extends ConsumerWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(feedbackProvider);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 64, color: colors.outlineVariant),
            const SizedBox(height: 16),
            Text('Voltooi een sessie\nvoor statistieken.',
                style: text.titleMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    // Group by date, sort chronologically → each date = one session
    final byDate = <String, List<FeedbackEntry>>{};
    for (final e in entries) {
      final key = DateFormat('yyyy-MM-dd').format(e.completedAt);
      byDate.putIfAbsent(key, () => []).add(e);
    }
    final sortedDates = byDate.keys.toList()..sort();

    double? avg(List<num?> values) {
      final v = values.whereType<num>().toList();
      if (v.isEmpty) return null;
      return v.fold(0.0, (s, e) => s + e) / v.length;
    }

    List<FlSpot> spots(double? Function(List<FeedbackEntry>) fn) {
      final spots = <FlSpot>[];
      for (var i = 0; i < sortedDates.length; i++) {
        final val = fn(byDate[sortedDates[i]]!);
        if (val != null) spots.add(FlSpot(i.toDouble() + 1, val));
      }
      return spots;
    }

    final bpmSpots = spots((es) => avg(es.map((e) => e.bpm).toList()));
    final ratingSpots =
        spots((es) => avg(es.map((e) => e.rating).toList()));
    final painSpots =
        spots((es) => avg(es.map((e) => e.painLevel).toList()));
    final effectSpots = spots((es) {
      final vals = es
          .where((e) => e.madeItWorse != null)
          .map((e) => e.madeItWorse! ? 0.0 : 1.0)
          .toList();
      if (vals.isEmpty) return null;
      return vals.reduce((a, b) => a + b) / vals.length;
    });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (bpmSpots.isNotEmpty)
          _ChartCard(
            title: 'BPM per sessie',
            spots: bpmSpots,
            color: colors.secondary,
            minY: 0,
            maxY: 260,
            leftLabel: 'BPM',
          ),
        if (ratingSpots.isNotEmpty)
          _ChartCard(
            title: 'Beoordeling per sessie',
            spots: ratingSpots,
            color: colors.primary,
            minY: 0,
            maxY: 10,
            leftLabel: '/10',
          ),
        if (painSpots.isNotEmpty)
          _ChartCard(
            title: 'Pijn per sessie',
            spots: painSpots,
            color: colors.error,
            minY: 0,
            maxY: 10,
            leftLabel: '/10',
          ),
        if (effectSpots.isNotEmpty)
          _ChartCard(
            title: 'Effect per sessie',
            spots: effectSpots,
            color: Colors.green,
            minY: 0,
            maxY: 1,
            leftLabel: '',
            bottomLabels: const ['Slechter', 'Beter'],
          ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final List<FlSpot> spots;
  final Color color;
  final double minY;
  final double maxY;
  final String leftLabel;
  final List<String>? bottomLabels;

  const _ChartCard({
    required this.title,
    required this.spots,
    required this.color,
    required this.minY,
    required this.maxY,
    required this.leftLabel,
    this.bottomLabels,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final rawMaxX = spots.map((s) => s.x).reduce((a, b) => a > b ? a : b);
    final maxX = rawMaxX < 2 ? 2.0 : rawMaxX;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: Text(title,
                  style:
                      text.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  minX: 1,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: bottomLabels != null ? 54 : 36,
                        interval: bottomLabels != null ? (maxY - minY) : null,
                        getTitlesWidget: (v, _) {
                          if (bottomLabels != null) {
                            if ((v - minY).abs() < 0.001) {
                              return Text(bottomLabels![0],
                                  style: const TextStyle(fontSize: 9));
                            }
                            if ((v - maxY).abs() < 0.001) {
                              return Text(bottomLabels![1],
                                  style: const TextStyle(fontSize: 9));
                            }
                            return const SizedBox.shrink();
                          }
                          return Text(v.toInt().toString(),
                              style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (v, _) => Text(
                          '#${v.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: spots.length > 1,
                      color: color,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        getDotPainter: (spot, _, __, ___) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: color,
                          strokeWidth: 0,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withAlpha(30),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
