import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/score_chart.dart';
import '../../widgets/search_bar.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final lessonProv = context.read<LessonProvider>();
      final progressProv = context.read<ProgressProvider>();
      await lessonProv.loadChapters();
      lessonProv.loadAllLessons(lessonProv.chapters);
      progressProv
        ..setUserId(auth.user?.id ?? 1)
        ..loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isAdmin = user?.role == 'Admin';

    if (isAdmin) {
      return const AdminDashboard();
    }

    final screens = [
      _buildHomeTab(context),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Trang chủ'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Hồ sơ'),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final progress = context.watch<ProgressProvider>();
    final lessonProv = context.watch<LessonProvider>();
    final completedLessonIds = progress.progressList
        .where((p) => p.isCompleted)
        .map((p) => p.lessonId)
        .toSet();
    final chapterOrder = <int, int>{};
    for (final ch in lessonProv.chapters) {
      chapterOrder[ch.id] = ch.orderIndex;
    }
    final lessonTooltips = <int, String>{};
    for (final p in progress.progressList) {
      final lesson = lessonProv.lessonMap[p.lessonId];
      if (lesson != null) {
        final chIdx = chapterOrder[lesson.chapterId] ?? 0;
        lessonTooltips[p.lessonId] = 'Chương $chIdx - Bài ${lesson.orderIndex}';
      }
    }

    return Container(
      decoration: BoxDecoration(gradient: AppColors.gradientSurface),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 160,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryGlow],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Chào ${user?.name ?? 'Bạn'}!',
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                const SizedBox(height: 4),
                                Text('Hôm nay học tiếp bài mới nhé!',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withValues(alpha: 0.9))),
                              ],
                            ),
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                            child: const Icon(Icons.auto_stories, color: Colors.white, size: 22),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                const SearchButton(),
                IconButton(
                  icon: Icon(context.watch<ThemeProvider>().isDarkMode ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 600;
                        if (isWide) {
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _buildProgressCard(progress, isWide: true),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ScoreChart(progressList: progress.progressList, lessonTooltips: lessonTooltips),
                                ),
                              ],
                            ),
                          );
                        }
                        return Column(
                          children: [
                            _buildProgressCard(progress, isWide: false),
                            const SizedBox(height: 16),
                            ScoreChart(progressList: progress.progressList, lessonTooltips: lessonTooltips),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _chapterHeader(lessonProv),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: (MediaQuery.of(context).size.width >= 600
                  ? SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 3.5,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final ch = lessonProv.chapters[index];
                          return _buildChapterCard(ch, lessonProv.isChapterFullyCompleted(ch.id, completedLessonIds.toList()));
                        },
                        childCount: lessonProv.chapters.length,
                      ),
                    )
                  : SliverList.separated(
                      itemBuilder: (context, index) {
                        final ch = lessonProv.chapters[index];
                        return _buildChapterCard(ch, lessonProv.isChapterFullyCompleted(ch.id, completedLessonIds.toList()));
                      },
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemCount: lessonProv.chapters.length,
                    )),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: child,
    );
  }

  Widget _buildProgressCard(ProgressProvider progress, {bool isWide = false}) {
    final circleSize = isWide ? 140.0 : 100.0;
    final strokeW = isWide ? 8.0 : 8.0;
    final fontSize = isWide ? 30.0 : 26.0;
    return _buildGlassCard(
      child: Row(
        children: [
          SizedBox(
            width: circleSize,
            height: circleSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: progress.overallPercent / 100,
                    strokeWidth: strokeW,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppColors.glassBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                Text(
                  '${progress.overallPercent.toInt()}%',
                  style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMain),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Tiến độ tổng thể',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain)),
                const SizedBox(height: 4),
                Text(
                    'Đã hoàn thành ${progress.progressList.length} bài học',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chapterHeader(LessonProvider lessonProv) {
    return Row(
      children: [
        Text('Chương trình học',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain)),
        const Spacer(),
        Text('${lessonProv.chapters.length} chương',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
      ],
    );
  }

  Widget _buildChapterCard(dynamic chapter, bool isCompleted) {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border(
          top: BorderSide(
            color: isCompleted
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.textDim.withValues(alpha: 0.3),
            width: 3,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).pushNamed(
            '/chapter-lessons',
            arguments: chapter,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: isCompleted
                        ? AppColors.gradientAccent
                        : LinearGradient(colors: [
                            AppColors.textDim,
                            AppColors.textMuted,
                          ]),
                  ),
                  child: Center(
                    child: Text(
                      '${chapter.orderIndex}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chương ${chapter.orderIndex}: ${chapter.title}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMain),
                      ),
                      if (chapter.description != null &&
                          chapter.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            chapter.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 12),
                          ),
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
