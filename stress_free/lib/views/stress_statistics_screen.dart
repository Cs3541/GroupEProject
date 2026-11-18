import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/journal_store.dart';

//Shows the signed-in user's saved stress ratings from Firestore.
//Journals without a saved rating are excluded from statistics.
class StressStatisticsScreen extends StatefulWidget {
  const StressStatisticsScreen({super.key, this.store});

  /// Optional for tests; normally the same JournalStore used by the journal UI.
  final JournalStore? store;

  @override
  State<StressStatisticsScreen> createState() =>
      _StressStatisticsScreenState();
}

class _StressStatisticsScreenState extends State<StressStatisticsScreen> {
  late final JournalStore _store;
  bool _loading = true;
  String? _error;
  List<MapEntry<String, int>> _dailyRatings = [];

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? JournalStore();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // The Firestore-backed JournalStore returns {YYYY-MM-DD: 0..10}.
      final ratings = await _store.loadAllStressRatings();
      final sorted = ratings.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      if (!mounted) return;
      setState(() {
        _dailyRatings = sorted;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Could not load stress statistics: $error');
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your ratings. Check Firebase login and '
            'Firestore permissions, then try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratings = _dailyRatings;
    final average = ratings.isEmpty
        ? null
        : ratings.fold<int>(0, (total, entry) => total + entry.value) /
            ratings.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stress Statistics'),
        actions: [
          IconButton(
            tooltip: 'Refresh statistics',
            onPressed: _loading ? null : _loadRatings,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 36),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadRatings,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text('Your stress overview',
                          style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Average Stress Level',
                                  style: theme.textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text(
                                average == null
                                    ? '-- / 10'
                                    : '${average.toStringAsFixed(1)} / 10',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ratings.isEmpty
                                    ? 'No saved stress ratings yet.'
                                    : 'Based on ${ratings.length} rated '
                                        '${ratings.length == 1 ? 'journal' : 'journals'}.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Daily stress trend',
                          style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: ratings.isEmpty
                              ? const SizedBox(
                                  height: 220,
                                  child: Center(
                                    child: Text(
                                      'No ratings to graph yet.\n'
                                      'Rate a journal and save it to see a point here.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text('Stress level (0–10)',
                                        style: theme.textTheme.bodySmall),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 270,
                                      child: _StressLineChart(
                                        ratings: ratings,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Date (YYYY-MM-DD)',
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodySmall),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Each point shows a saved rating for one journal date. '
                        'Only journals with a rating are included.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
    );
  }
}

///Uses Flutter's built-in drawing APIs; no extra chart package required.
//Dates are ordered chronologically and plotted as equally spaced categories.
class _StressLineChart extends StatelessWidget {
  const _StressLineChart({required this.ratings});

  final List<MapEntry<String, int>> ratings;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = math.max(
          constraints.maxWidth,
          math.max(320.0, ratings.length * 76.0 + 48.0),
        );

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: contentWidth,
            height: 270,
            child: CustomPaint(
              painter: _StressChartPainter(
                ratings: ratings,
                lineColor: colors.primary,
                gridColor: colors.outlineVariant,
                textColor: colors.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StressChartPainter extends CustomPainter {
  const _StressChartPainter({
    required this.ratings,
    required this.lineColor,
    required this.gridColor,
    required this.textColor,
  });

  final List<MapEntry<String, int>> ratings;
  final Color lineColor;
  final Color gridColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 38.0;
    const right = 24.0;
    const top = 22.0;
    const bottom = 54.0;
    final plotWidth = size.width - left - right;
    final plotHeight = size.height - top - bottom;
    final baseline = top + plotHeight;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = textColor
      ..strokeWidth = 1.2;

    double yFor(int rating) => top + (10 - rating) * plotHeight / 10;
    double xFor(int index) => ratings.length == 1
        ? left + plotWidth / 2
        : left + index * plotWidth / (ratings.length - 1);

    // Y-axis ticks and horizontal guides: 0, 2, 4, 6, 8, 10.
    for (int value = 0; value <= 10; value += 2) {
      final y = yFor(value);
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), gridPaint);
      _drawText(
        canvas,
        '$value',
        Offset(left - 10, y),
        align: TextAlign.right,
        anchor: _TextAnchor.rightCenter,
      );
    }

    canvas.drawLine(Offset(left, top), Offset(left, baseline), axisPaint);
    canvas.drawLine(
      Offset(left, baseline),
      Offset(size.width - right, baseline),
      axisPaint,
    );

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()..color = lineColor;

    final path = Path();
    for (var i = 0; i < ratings.length; i++) {
      final point = Offset(xFor(i), yFor(ratings[i].value));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, linePaint);

    for (var i = 0; i < ratings.length; i++) {
      final date = ratings[i].key;
      final value = ratings[i].value;
      final x = xFor(i);
      final y = yFor(value);
      canvas.drawCircle(Offset(x, y), 4.7, dotPaint);

      // Show the saved numeric rating alongside each dot.
      _drawText(
        canvas,
        '$value',
        Offset(x, value >= 9 ? y + 9 : y - 9),
        align: TextAlign.center,
        anchor: value >= 9 ? _TextAnchor.topCenter : _TextAnchor.bottomCenter,
      );

      // Split the full YYYY-MM-DD date across two lines to avoid overlap.
      final parts = date.split('-');
      final label = parts.length == 3
          ? '${parts[1]}-${parts[2]}\n${parts[0]}'
          : date;
      _drawText(
        canvas,
        label,
        Offset(x, baseline + 8),
        align: TextAlign.center,
        anchor: _TextAnchor.topCenter,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset anchorPoint, {
    required TextAlign align,
    required _TextAnchor anchor,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: textColor, fontSize: 11, height: 1.15),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();

    late Offset offset;
    if (anchor == _TextAnchor.topCenter) {
      offset = Offset(anchorPoint.dx - painter.width / 2, anchorPoint.dy);
    } else if (anchor == _TextAnchor.bottomCenter) {
      offset = Offset(
        anchorPoint.dx - painter.width / 2,
        anchorPoint.dy - painter.height,
      );
    } else {
      offset = Offset(
        anchorPoint.dx - painter.width,
        anchorPoint.dy - painter.height / 2,
      );
    }
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _StressChartPainter oldDelegate) =>
      oldDelegate.ratings != ratings ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.textColor != textColor;
}

enum _TextAnchor { topCenter, bottomCenter, rightCenter }
