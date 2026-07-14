import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/progress.dart';
import '../theme.dart';

class ScoreChart extends StatelessWidget {
  final List<Progress> progressList;
  final Map<int, String>? lessonTooltips;

  const ScoreChart({super.key, required this.progressList, this.lessonTooltips});

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
      padding: const EdgeInsets.all(12),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(colors: [
                    AppColors.accent,
                    Color(0xFF06B6D4),
                  ]),
                ),
                child: const Icon(Icons.show_chart,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Text('Biểu đồ điểm số',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
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
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 2,
                      getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style:
                              TextStyle(color: AppColors.textMuted, fontSize: 10)),
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
                        .map((spot) {
                          final idx = spot.x.toInt();
                          final lid = scores[idx].lessonId;
                          final label = lessonTooltips?[lid] ?? 'Bài ${idx + 1}';
                          return LineTooltipItem(
                            '$label\nĐiểm: ${spot.y.toStringAsFixed(1)}/10',
                            const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11),
                          );
                        }).toList(),
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
