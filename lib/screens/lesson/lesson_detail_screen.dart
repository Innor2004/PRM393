import 'package:flutter/material.dart';
import '../../models/lesson.dart';
import '../../services/offline_service.dart';
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
  bool _isSaved = false;
  bool _isLoadingSave = false;

  @override
  void initState() {
    super.initState();
    _checkSaved();
  }

  Future<void> _checkSaved() async {
    final saved = await OfflineService().isSaved(widget.lesson.id);
    if (mounted) setState(() => _isSaved = saved);
  }

  Future<void> _toggleSave() async {
    setState(() => _isLoadingSave = true);
    final service = OfflineService();
    if (_isSaved) {
      await service.removeLesson(widget.lesson.id);
    } else {
      await service.saveLesson(widget.lesson);
    }
    if (mounted) {
      setState(() {
        _isSaved = !_isSaved;
        _isLoadingSave = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isSaved ? 'Đã lưu bài học để đọc offline' : 'Đã xóa khỏi offline'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.bgDarker, AppColors.bgDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.lesson.title),
          actions: [
            _isLoadingSave
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton(
                    icon: Icon(_isSaved
                        ? Icons.download_done
                        : Icons.download_outlined),
                    tooltip: _isSaved ? 'Đã lưu offline' : 'Lưu offline',
                    onPressed: _toggleSave,
                  ),
            IconButton(
              icon: const Icon(Icons.quiz_outlined),
              tooltip: 'Làm bài tập',
              onPressed: () => Navigator.of(context)
                  .pushNamed('/quiz', arguments: widget.lesson),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
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
                        style: const TextStyle(
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
                              style:
                                  TextStyle(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildContent(context, widget.lesson.contentBody ?? ''),
              if (labType != null) ...[
                const SizedBox(height: 24),
                InteractiveLab(formulaType: labType),
              ],
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
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
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context)
                      .pushNamed('/quiz', arguments: widget.lesson),
                  icon: const Icon(Icons.quiz_outlined),
                  label: const Text('Làm bài tập trắc nghiệm',
                      style: TextStyle(
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
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, String content) {
    final lines = content.split('\n');
    final elements = <Widget>[];
    for (final line in lines) {
      if (line.startsWith('# ')) {
        elements.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(line.substring(2),
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain)),
        ));
      } else if (line.startsWith('## ')) {
        elements.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(line.substring(3),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain)),
        ));
      } else if (line.startsWith('### ')) {
        elements.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(line.substring(4),
              style: const TextStyle(
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
            style: const TextStyle(
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
          style: const TextStyle(
              fontSize: 15, height: 1.7, color: AppColors.textMain),
        ));
      }
      return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center, children: parts);
    }
    return Text(text,
        style: const TextStyle(
            fontSize: 15, height: 1.7, color: AppColors.textMain));
  }
}
