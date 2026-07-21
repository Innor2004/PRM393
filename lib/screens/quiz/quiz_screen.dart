import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lesson.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme.dart';

class QuizScreen extends StatefulWidget {
  final Lesson lesson;
  const QuizScreen({super.key, required this.lesson});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Timer? _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final quiz = context.read<QuizProvider>();
      await quiz.loadQuestions(widget.lesson.id);
      if (!mounted) return;
      final totalSeconds = quiz.totalQuestions * 60;
      setState(() => _secondsRemaining = totalSeconds);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer?.cancel();
            if (!context.read<QuizProvider>().isSubmitted) {
              context.read<QuizProvider>().submitToBackend(widget.lesson.id);
            }
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeDisplay {
    final m = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _timerColor {
    if (_secondsRemaining > 120) return AppColors.primary;
    if (_secondsRemaining > 60) return AppColors.warning;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();

    if (quiz.isLoading) {
      return _buildScaffold(
        isSubmitted: false,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (quiz.questions.isEmpty) {
      return _buildScaffold(
        isSubmitted: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz_outlined, size: 48, color: AppColors.textDim),
              const SizedBox(height: 16),
              Text('Chưa có câu hỏi cho bài học này',
                  style: TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    return _buildScaffold(
      isSubmitted: quiz.isSubmitted,
      appBarActions: [
        if (!quiz.isSubmitted)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _timerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _timerColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: _timerColor),
                    const SizedBox(width: 4),
                    Text(_timeDisplay,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: _timerColor)),
                  ],
                ),
              ),
            ),
          ),
      ],
      child: Column(
        children: [
          if (!quiz.isSubmitted)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: AppColors.gradientPrimary,
                    ),
                    child: Text(
                        'Câu ${quiz.currentIndex + 1}/${quiz.totalQuestions}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 13)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (quiz.currentIndex + 1) / quiz.totalQuestions,
                        minHeight: 8,
                        backgroundColor: AppColors.bgDark,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: quiz.isSubmitted
                ? _buildResult(context, quiz)
                : _buildQuestion(context, quiz),
          ),
        ],
      ),
    );
  }

  Widget _buildScaffold({
    required Widget child,
    required bool isSubmitted,
    List<Widget>? appBarActions,
  }) {
    return PopScope(
      // Chặn back hoàn toàn khi đã nộp bài, tránh quay lại sửa đáp án
      canPop: !isSubmitted,
      child: Container(
        decoration: BoxDecoration(gradient: AppColors.gradientSurface),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Bài tập: ${widget.lesson.title}'),
            // Ẩn nút back trên AppBar khi đã có điểm
            automaticallyImplyLeading: !isSubmitted,
            actions: appBarActions,
          ),
          body: child,
        ),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context, QuizProvider quiz) {
    final question = quiz.questions[quiz.currentIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primaryGlow.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Text(question.questionText,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain)),
          ),
          const SizedBox(height: 20),
          ..._buildOptions(quiz, question.optionA, 'A'),
          ..._buildOptions(quiz, question.optionB, 'B'),
          ..._buildOptions(quiz, question.optionC, 'C'),
          ..._buildOptions(quiz, question.optionD, 'D'),
          const SizedBox(height: 24),
          Row(
            children: [
              if (quiz.currentIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: quiz.previousQuestion,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.glassBorder),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      foregroundColor: AppColors.textMain,
                    ),
                    child: const Text('Câu trước'),
                  ),
                ),
              if (quiz.currentIndex > 0) const SizedBox(width: 12),
              Expanded(
                child: _buildGradientButton(
                  onPressed: quiz.selectedAnswer == null
                      ? null
                      : () {
                          if (quiz.currentIndex ==
                              quiz.totalQuestions - 1) {
                            _showConfirmSubmit(context, quiz);
                          } else {
                            quiz.nextQuestion();
                          }
                        },
                  child: Text(
                    quiz.currentIndex == quiz.totalQuestions - 1
                        ? 'Nộp bài'
                        : 'Câu tiếp',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOptions(QuizProvider quiz, String text, String letter) {
    final isSelected = quiz.selectedAnswer == letter;
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () => quiz.selectAnswer(letter),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.glassBorder,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(14),
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.bgDark.withValues(alpha: 0.3),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected
                        ? AppColors.gradientPrimary
                        : LinearGradient(colors: [
                            AppColors.glassFill,
                            AppColors.glassBorder,
                          ]),
                  ),
                  child: Center(
                    child: Text(letter,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textMuted,
                        )),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(text,
                            style: TextStyle(
                                fontSize: 15, color: AppColors.textMain))),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildGradientButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppColors.gradientPrimary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: AppColors.glassFill,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: child,
      ),
    );
  }

  void _showConfirmSubmit(BuildContext context, QuizProvider quiz) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận nộp bài'),
        content: Text(
            'Bạn đã trả lời ${quiz.totalQuestions} câu hỏi. Còn $_timeDisplay trước khi hết giờ. Bạn có chắc muốn nộp bài?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              _timer?.cancel();
              await quiz.submitToBackend(widget.lesson.id);
              if (context.mounted) {
                await context.read<ProgressProvider>().updatePendingCount();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context, QuizProvider quiz) {
    final score = quiz.score;
    final progressProv = context.read<ProgressProvider>();
    final passed = score >= 5;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Tooltip(
            message: passed ? '' : 'Nhấn để làm lại từ đầu',
            child: GestureDetector(
              onTap: passed
                  ? null
                  : () async {
                      // Reset quiz và load lại câu hỏi để làm lại từ đầu
                      await quiz.loadQuestions(widget.lesson.id);
                    },
              child: Container(
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
                    passed ? Icons.emoji_events : Icons.replay,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(passed ? 'Chúc mừng!' : 'Cố gắng hơn!',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain)),
          const SizedBox(height: 12),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.gradientAccent.createShader(bounds),
            child: Text('${score.toStringAsFixed(1)}/10',
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
          ),
          const SizedBox(height: 4),
          Text('Đúng ${quiz.correctCount}/${quiz.totalQuestions} câu',
              style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
          const SizedBox(height: 24),
          ...List.generate(quiz.questions.length, (i) {
            final q = quiz.questions[i];
            final correct = quiz.isAnswerCorrect(i);
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
                    color: correct
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
                            correct
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: correct
                                ? AppColors.success
                                : Colors.red,
                            size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text('Câu ${i + 1}: ${q.questionText}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMain))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Đáp án đúng: ${q.correctOption}',
                        style: TextStyle(color: AppColors.textMuted)),
                    if (q.explanation != null) ...[
                      const SizedBox(height: 4),
                      Text('Giải thích: ${q.explanation}',
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          _buildGradientButton(
            onPressed: () {
              progressProv.markLessonCompleted(widget.lesson.id, score: score);
              if (passed) {
                Navigator.of(context).popUntil(ModalRoute.withName('/chapter-lessons'));
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(
              passed ? 'Hoàn thành và quay lại' : 'Quay lại bài học',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
