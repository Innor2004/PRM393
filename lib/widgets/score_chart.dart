import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/progress.dart';
import '../theme.dart';

class ScoreChart extends StatelessWidget {
  final List<Progress> progressList;

  const ScoreChart({super.key, required this.progressList});

  @override
  Widget build(BuildContext context) {
    final scores = progressList
        .where((p) => p.quizScore > 0)
        .toList()
      ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));

    if (scores.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.bgDark.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          children: [
            Icon(Icons.show_chart, size: 36, color: AppColors.textDim),
            const SizedBox(height: 12),
            Text('Chưa có dữ liệu bài kiểm tra',
                style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }

    final maxY = 10.0;
    final spots = scores.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.quizScore);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(colors: [
                    AppColors.accent,
                    Color(0xFF06B6D4),
                  ]),
                ),
                child: const Icon(Icons.show_chart,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Biểu đồ điểm số',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.glassBorder,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < scores.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('${idx + 1}',
                                style:
                                    const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 2,
                      getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style:
                              const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (scores.length - 1).toDouble().clamp(0, double.infinity),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: AppColors.bgDark,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) => touchedSpots
                        .map((spot) => LineTooltipItem(
                              'Bài ${spot.x.toInt() + 1}: ${spot.y.toStringAsFixed(1)}/10',
                              const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
