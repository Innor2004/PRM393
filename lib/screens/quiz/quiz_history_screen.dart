import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lesson.dart';
import '../../models/quiz_attempt.dart';
import '../../providers/quiz_provider.dart';
import '../../theme.dart';
import 'package:intl/intl.dart';

class QuizHistoryScreen extends StatefulWidget {
  final Lesson lesson;
  const QuizHistoryScreen({super.key, required this.lesson});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  bool _isLoading = true;
  List<QuizAttempt> _attempts = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await context.read<QuizProvider>().getQuizHistory(widget.lesson.id);
    if (mounted) {
      setState(() {
        _attempts = history;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.gradientSurface),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Lịch sử: ${widget.lesson.title}'),
        ),
        body: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _attempts.isEmpty
                  ? Center(
                      child: Text('Chưa có lịch sử làm bài',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 650;
                        if (isWide) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 450,
                              mainAxisExtent: 110,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                            itemCount: _attempts.length,
                            itemBuilder: (context, index) {
                              return _buildAttemptCard(context, index, margin: EdgeInsets.zero);
                            },
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _attempts.length,
                          itemBuilder: (context, index) {
                            return _buildAttemptCard(context, index);
                          },
                        );
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildAttemptCard(BuildContext context, int index, {EdgeInsetsGeometry? margin}) {
    final attempt = _attempts[index];
    final passed = attempt.score >= 5;
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(attempt.createdAt.toLocal());

    return Card(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      color: AppColors.bgDark.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.glassBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: passed
                ? AppColors.success.withValues(alpha: 0.2)
                : Colors.red.withValues(alpha: 0.2),
            border: Border.all(
              color: passed ? AppColors.success : Colors.red,
            ),
          ),
          child: Center(
            child: Text(
              attempt.score.toStringAsFixed(1),
              style: TextStyle(
                color: passed ? AppColors.success : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        title: Text('Lần làm bài ${_attempts.length - index}',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textMain)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 2),
            Text('Ngày nộp: $dateStr',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            Text('Đúng ${attempt.correctCount}/${attempt.totalQuestions} câu',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/quiz-history-detail',
            arguments: attempt,
          );
        },
      ),
    );
  }
}
