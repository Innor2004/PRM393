import 'package:flutter/material.dart';
import '../../models/quiz_attempt.dart';
import '../../theme.dart';
import 'package:intl/intl.dart';

class QuizHistoryDetailScreen extends StatelessWidget {
  final QuizAttempt attempt;
  const QuizHistoryDetailScreen({super.key, required this.attempt});

  @override
  Widget build(BuildContext context) {
    final passed = attempt.score >= 5;
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(attempt.createdAt.toLocal());

    return Container(
      decoration: BoxDecoration(gradient: AppColors.gradientSurface),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết bài làm'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text('Nộp lúc: $dateStr',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                const SizedBox(height: 20),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: passed
                        ? LinearGradient(colors: [
                            AppColors.warning,
                            Color(0xFFFCD34D),
                          ])
                        : LinearGradient(colors: [
                            AppColors.primary,
                            AppColors.primaryGlow,
                          ]),
                    boxShadow: passed
                        ? [
                            BoxShadow(
                              color: AppColors.warning.withValues(alpha: 0.4),
                              blurRadius: 40,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              blurRadius: 30,
                              offset: const Offset(0, 8),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Icon(
                      passed ? Icons.emoji_events : Icons.assignment,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(passed ? 'Đạt' : 'Chưa đạt',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMain)),
                const SizedBox(height: 12),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.gradientAccent.createShader(bounds),
                  child: Text('${attempt.score.toStringAsFixed(1)}/10',
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                ),
                const SizedBox(height: 4),
                Text('Đúng ${attempt.correctCount}/${attempt.totalQuestions} câu',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                const SizedBox(height: 24),
                ...List.generate(attempt.details.length, (i) {
                  final d = attempt.details[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.bgDark.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    foregroundDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        top: BorderSide(
                          color: d.isCorrect
                              ? AppColors.success.withValues(alpha: 0.5)
                              : Colors.red.withValues(alpha: 0.5),
                          width: 3,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                  d.isCorrect
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: d.isCorrect
                                      ? AppColors.success
                                      : Colors.red,
                                  size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text('Câu ${i + 1}: ${d.questionText}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textMain))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('Bạn chọn: ${d.selectedOption ?? "Không chọn"}',
                              style: TextStyle(
                                  color: d.isCorrect ? AppColors.success : Colors.red,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Đáp án đúng: ${d.correctOption}',
                              style: TextStyle(color: AppColors.textMuted)),
                          if (d.explanation != null && d.explanation!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Giải thích: ${d.explanation}',
                                style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontStyle: FontStyle.italic)),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
