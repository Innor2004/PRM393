import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chapter.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme.dart';

class ChapterLessonsScreen extends StatefulWidget {
  final Chapter chapter;
  const ChapterLessonsScreen({super.key, required this.chapter});

  @override
  State<ChapterLessonsScreen> createState() => _ChapterLessonsScreenState();
}

class _ChapterLessonsScreenState extends State<ChapterLessonsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().loadLessons(widget.chapter.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lessons = context.watch<LessonProvider>().currentLessons;
    final progressProv = context.watch<ProgressProvider>();

    return Container(
      decoration: BoxDecoration(gradient: AppColors.gradientSurface),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.chapter.title)),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: lessons.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book, size: 48, color: AppColors.textDim),
                          const SizedBox(height: 16),
                          Text('Không có bài học nào',
                              style: TextStyle(color: AppColors.textMuted)),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 650;
                        if (isWide) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 3.6,
                            ),
                            itemCount: lessons.length,
                            itemBuilder: (context, index) {
                              final lesson = lessons[index];
                              final completed = progressProv.isLessonCompleted(lesson.id);
                              final hasQuiz = completed ? progressProv.hasLessonQuiz(lesson.id) : true;
                              final score = progressProv.getLessonScore(lesson.id);

                              return _buildLessonCard(lesson, completed, score, hasQuiz: hasQuiz, margin: EdgeInsets.zero);
                            },
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: lessons.length,
                          itemBuilder: (context, index) {
                            final lesson = lessons[index];
                            final completed = progressProv.isLessonCompleted(lesson.id);
                            final hasQuiz = completed ? progressProv.hasLessonQuiz(lesson.id) : true;
                            final score = progressProv.getLessonScore(lesson.id);

                            return _buildLessonCard(lesson, completed, score, hasQuiz: hasQuiz);
                          },
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCard(dynamic lesson, bool completed, double score, {bool hasQuiz = true, EdgeInsetsGeometry? margin}) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border(
          top: BorderSide(
            color: completed
                ? AppColors.success.withValues(alpha: 0.5)
                : AppColors.primary.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).pushNamed(
              '/lesson-detail', arguments: lesson),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: completed
                        ? LinearGradient(colors: [
                            AppColors.success,
                            Color(0xFF059669),
                          ])
                        : AppColors.gradientPrimary,
                  ),
                  child: Icon(
                    completed ? Icons.check : Icons.menu_book,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Bài ${lesson.orderIndex}: ${lesson.title}',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMain)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Độ khó: ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          Text('⭐' * lesson.difficultyStars, style: TextStyle(color: AppColors.warning, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text('${lesson.estimatedMinutes} phút',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 12)),
                          if (completed && hasQuiz) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.star,
                                size: 14, color: AppColors.warning),
                            const SizedBox(width: 4),
                            Text('${score.toInt()}/10',
                                  style: TextStyle(
                                      color: AppColors.warning, fontSize: 12)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.glassFill,
                  ),
                  child: Icon(Icons.chevron_right,
                      color: AppColors.textMuted, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
