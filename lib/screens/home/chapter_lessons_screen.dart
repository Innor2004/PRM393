import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chapter.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme.dart';
import '../../utils/responsive.dart';

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
                    final cols = Responsive.getGridColumnCount(constraints.maxWidth);
                    if (cols > 1) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 420,
                          mainAxisExtent: 124,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Bài ${lesson.orderIndex}: ${lesson.title}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textMain),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Độ khó: ',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              Text('⭐' * lesson.difficultyStars,
                                  style: TextStyle(color: AppColors.warning, fontSize: 10)),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer_outlined,
                                  size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 3),
                              Text('${lesson.estimatedMinutes} phút',
                                  style: TextStyle(
                                      color: AppColors.textMuted, fontSize: 11)),
                            ],
                          ),
                          if (completed && hasQuiz)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star,
                                    size: 12, color: AppColors.warning),
                                const SizedBox(width: 3),
                                Text('${score.toInt()}/10',
                                    style: TextStyle(
                                        color: AppColors.warning,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.glassFill,
                  ),
                  child: Icon(Icons.chevron_right,
                      color: AppColors.textMuted, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
