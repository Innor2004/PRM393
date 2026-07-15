import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lesson.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme.dart';
import '../../widgets/interactive_lab.dart';
import '../../widgets/latex_renderer.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  bool? _hasQuestions;

  @override
  void initState() {
    super.initState();
    _checkQuestions();
  }

  Future<void> _checkQuestions() async {
    final hasQ = await context.read<QuizProvider>().hasQuestions(widget.lesson.id);
    if (mounted) setState(() => _hasQuestions = hasQ);
  }

  FormulaType? _getLabType() {
    switch (widget.lesson.id) {
      case 1:
        return FormulaType.uniformMotion;
      case 2:
        return FormulaType.acceleratedMotion;
      case 6:
        return FormulaType.newtonSecondLaw;
      case 9:
        return FormulaType.workFormula;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final labType = _getLabType();
    return Container(
      decoration: BoxDecoration(gradient: AppColors.gradientSurface),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.lesson.title),
          actions: [
            if (_hasQuestions == true)
              IconButton(
                icon: const Icon(Icons.quiz_outlined),
                tooltip: 'Làm bài tập',
                onPressed: () => Navigator.of(context)
                    .pushNamed('/quiz', arguments: widget.lesson),
              ),
            if (_hasQuestions == false)
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                tooltip: 'Hoàn thành',
                onPressed: () => _completeLesson(),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 20),
              _buildContent(context, widget.lesson.contentBody ?? ''),
              if (labType != null) ...[
                const SizedBox(height: 24),
                InteractiveLab(formulaType: labType),
              ],
              const SizedBox(height: 24),
              _buildQuizButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: AppColors.gradientPrimary,
            ),
            child: const Icon(Icons.timer_outlined,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text('${widget.lesson.estimatedMinutes} phút',
              style: TextStyle(
                  color: AppColors.textMain,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.glassFill,
            ),
            child: Row(
              children: [
                Icon(Icons.menu_book,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text('Bài ${widget.lesson.orderIndex}',
                    style: TextStyle(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizButton() {
    if (_hasQuestions == null) return const SizedBox.shrink();

    final isComplete = _hasQuestions == false;
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: isComplete
            ? LinearGradient(colors: [AppColors.success, AppColors.success.withValues(alpha: 0.8)])
            : AppColors.gradientPrimary,
        boxShadow: [
          BoxShadow(
            color: (isComplete ? AppColors.success : AppColors.primary)
                .withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isComplete
            ? _completeLesson
            : () => Navigator.of(context)
                .pushNamed('/quiz', arguments: widget.lesson),
        icon: Icon(isComplete ? Icons.check_circle_outline : Icons.quiz_outlined, size: 20),
        label: Text(isComplete ? 'Hoàn thành bài học' : 'Làm bài tập trắc nghiệm',
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Future<void> _completeLesson() async {
    await context.read<ProgressProvider>().markLessonCompleted(widget.lesson.id);
    if (mounted) Navigator.of(context).pop();
  }

  Widget _buildContent(BuildContext context, String content) {
    final lines = content.split('\n');
    final elements = <Widget>[];
    for (final line in lines) {
      if (line.startsWith('# ')) {
        elements.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(line.substring(2),
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain)),
        ));
      } else if (line.startsWith('## ')) {
        elements.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(line.substring(3),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain)),
        ));
      } else if (line.startsWith('### ')) {
        elements.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(line.substring(4),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain)),
        ));
      } else if (line.startsWith('- ')) {
        elements.add(Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              Expanded(child: _buildRichText(line.substring(2))),
            ],
          ),
        ));
      } else if (line.trim().isEmpty) {
        elements.add(const SizedBox(height: 8));
      } else {
        elements.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildRichText(line),
        ));
      }
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: elements);
  }

  Widget _buildRichText(String text) {
    final latexRegex = RegExp(r'`([^`]+)`');
    if (latexRegex.hasMatch(text)) {
      final parts = <Widget>[];
      int lastEnd = 0;
      for (final match in latexRegex.allMatches(text)) {
        if (match.start > lastEnd) {
          parts.add(Text(
            text.substring(lastEnd, match.start),
            style: TextStyle(
                fontSize: 15, height: 1.7, color: AppColors.textMain),
          ));
        }
        parts.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: LatexRenderer(match.group(1)!),
        ));
        lastEnd = match.end;
      }
      if (lastEnd < text.length) {
        parts.add(Text(
          text.substring(lastEnd),
          style: TextStyle(
              fontSize: 15, height: 1.7, color: AppColors.textMain),
        ));
      }
      return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center, children: parts);
    }
    return Text(text,
        style: TextStyle(
            fontSize: 15, height: 1.7, color: AppColors.textMain));
  }
}
