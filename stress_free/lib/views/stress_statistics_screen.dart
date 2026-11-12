import 'package:flutter/material.dart';

// Stress statistics screen for the Stress-Free app.
class StressStatisticsScreen extends StatelessWidget {
  const StressStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stress Statistics'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Your stress overview', style: textTheme.headlineSmall),
            const SizedBox(height: 16),

            // Placeholder for the average of all saved stress ratings.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Average Stress Level', style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      '-- / 10',
                      style: textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('No stress ratings connected yet.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
// Daily stress trend section.
            Text('Daily stress trend', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // The chart is only a labeled placeholder for now.
                    const SizedBox(
                      height: 285,
                      child: _StressChartPlaceholder(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'X-axis: Date  |  Y-axis: Stress level (0–10)',
                      style: textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This screen is a layout placeholder. A later commit can '
              'calculate the average and plot saved journal ratings.',
            ),
          ],
        ),
      ),
    );
  }
}
// Placeholder widget for the daily stress trend chart.
class _StressChartPlaceholder extends StatelessWidget {
  const _StressChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              const RotatedBox(
                quarterTurns: 3,
                child: Text('Stress level'),
              ),
              const SizedBox(width: 8),
              const SizedBox(
                width: 24,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('10'),
                    Text('8'),
                    Text('6'),
                    Text('4'),
                    Text('2'),
                    Text('0'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ChartGridPainter(
                          gridColor: colors.outlineVariant,
                          axisColor: colors.outline,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.show_chart),
                          SizedBox(height: 6),
                          Text('Chart placeholder'),
                          SizedBox(height: 4),
                          Text(
                            'Daily ratings will appear here',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.only(left: 70),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Earlier dates'),
              Text('Recent dates'),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text('Date'),
      ],
    );
  }
}

// Custom painter for the chart grid.

class _ChartGridPainter extends CustomPainter {
  const _ChartGridPainter({
    required this.gridColor,
    required this.axisColor,
  });

  final Color gridColor;
  final Color axisColor;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final axis = Paint()
      ..color = axisColor
      ..strokeWidth = 1.5;

    // Six horizontal lines mark stress values 10, 8, 6, 4, 2, 0.
    for (var i = 0; i <= 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Y-axis and X-axis.
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), axis);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      axis,
    );
  }

  @override
  bool shouldRepaint(covariant _ChartGridPainter oldDelegate) {
    return oldDelegate.gridColor != gridColor ||
        oldDelegate.axisColor != axisColor;
  }
}
