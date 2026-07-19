import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/chapter.dart';
import '../../models/lesson.dart';
import '../../models/question.dart';
import '../../services/backend_service.dart';
import '../../theme.dart';
import '../../providers/auth_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final BackendService _backend = BackendService();
  int _selectedIndex = 0;
  List<Chapter> _chapters = [];
  Map<int, List<Lesson>> _lessons = {};
  Map<int, List<Question>> _questions = {};
  int _totalUsers = 0;
  int _totalChapters = 0;
  int _totalLessons = 0;
  int _totalQuestions = 0;
  List<Map<String, dynamic>> _userGrowth = [];
  List<Map<String, dynamic>> _lessonScores = [];
  List<Map<String, dynamic>> _students = [];
  Map<String, dynamic>? _selectedStudent;
  Map<String, dynamic>? _studentProgress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadChapters(), _loadStats(), _loadStudents()]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadStudents() async {
    try {
      final data = await _backend.getOne('/admin/users');
      _students = (data['data'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
    } catch (e) {
      debugPrint('Admin load students error: $e');
    }
  }

  Future<void> _loadChapters() async {
    try {
      final data = await _backend.getList('/chapters');
      _chapters = data.map((j) => Chapter.fromJson(Map<String, dynamic>.from(j))).toList();
      for (final ch in _chapters) {
        await _loadLessonsForChapter(ch.id);
      }
    } catch (e) {
      debugPrint('Admin load chapters error: $e');
    }
  }

  Future<void> _loadLessonsForChapter(int chapterId) async {
    try {
      final data = await _backend.getList('/chapters/$chapterId/lessons');
      _lessons[chapterId] = data.map((j) => Lesson.fromJson(Map<String, dynamic>.from(j))).toList();
      for (final l in _lessons[chapterId]!) {
        await _loadQuestionsForLesson(l.id);
      }
    } catch (e) {
      debugPrint('Admin load lessons error: $e');
    }
  }

  Future<void> _loadQuestionsForLesson(int lessonId) async {
    try {
      final data = await _backend.getList('/lessons/$lessonId/questions');
      _questions[lessonId] = data.map((j) => Question.fromJson(Map<String, dynamic>.from(j))).toList();
    } catch (e) {
      debugPrint('Admin load questions error: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _backend.getOne('/admin/stats');
      _totalUsers = (stats['totalUsers'] as num?)?.toInt() ?? 0;
      _totalChapters = (stats['totalChapters'] as num?)?.toInt() ?? 0;
      _totalLessons = (stats['totalLessons'] as num?)?.toInt() ?? 0;
      _totalQuestions = (stats['totalQuestions'] as num?)?.toInt() ?? 0;

      final growth = await _backend.getOne('/admin/stats/user-growth');
      _userGrowth = (growth['data'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];

      final scores = await _backend.getOne('/admin/stats/lesson-scores');
      _lessonScores = (scores['data'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
    } catch (e) {
      debugPrint('Admin load stats error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    final screens = [
      _buildOverview(),
      _buildChapterManager(),
      _buildStudentManager(),
    ];

    Widget bodyContent;
    if (_isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_selectedStudent != null) {
      bodyContent = _buildStudentDetail();
    } else {
      bodyContent = screens[_selectedIndex];
    }

    return Container(
      decoration: BoxDecoration(gradient: AppColors.gradientSurface),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(_selectedStudent != null
              ? 'Chi tiết học sinh'
              : 'Admin Panel'),
          leading: _selectedStudent != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() {
                    _selectedStudent = null;
                    _studentProgress = null;
                  }),
                )
              : null,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(user?.name ?? '',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
              ),
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
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: bodyContent,
            ),
          ),
        ),
        bottomNavigationBar: _selectedStudent != null
            ? null
            : NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) => setState(() => _selectedIndex = i),
                destinations: const [
                  NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: 'Tổng quan'),
                  NavigationDestination(
                      icon: Icon(Icons.library_books_outlined),
                      selectedIcon: Icon(Icons.library_books),
                      label: 'Quản lý'),
                  NavigationDestination(
                      icon: Icon(Icons.people_outlined),
                      selectedIcon: Icon(Icons.people),
                      label: 'Học sinh'),
                ],
              ),
      ),
    );
  }

  Widget _buildStudentManager() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Text('Danh sách học sinh',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const Spacer(),
              Text('${_students.length} học sinh',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _students.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline, size: 48, color: AppColors.textDim),
                      const SizedBox(height: 8),
                      Text('Chưa có học sinh nào', style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 750;
                    if (isWide) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 4.2,
                        ),
                        itemCount: _students.length,
                        itemBuilder: (_, i) => _buildStudentCard(_students[i], margin: EdgeInsets.zero),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _students.length,
                      itemBuilder: (_, i) => _buildStudentCard(_students[i]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, {EdgeInsetsGeometry? margin}) {
    final name = student['name'] as String? ?? '';
    final email = student['email'] as String? ?? '';
    final completed = (student['completedLessons'] as num?)?.toInt() ?? 0;
    final avgScore = (student['averageScore'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showStudentDetail(student),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradientPrimary,
              ),
              child: Center(
                child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMain)),
                  Text(email, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: avgScore >= 5 ? AppColors.success.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15),
              ),
              child: Text('${avgScore.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: avgScore >= 5 ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  )),
            ),
            const SizedBox(width: 8),
            Text('$completed bài',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: AppColors.textDim, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showStudentDetail(Map<String, dynamic> student) async {
    setState(() => _isLoading = true);
    try {
      final id = student['id'] as num;
      final data = await _backend.getOne('/admin/users/$id/progress');
      setState(() {
        _selectedStudent = student;
        _studentProgress = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Load student progress error: $e');
    }
  }

  Widget _buildStudentDetail() {
    final progress = _studentProgress;
    final userInfo = progress?['user'] as Map<String, dynamic>? ?? {};
    final rawChapters = (progress?['chapters'] as List<dynamic>?) ?? [];
    final chapters = <Map<String, dynamic>>[];
    for (final ch in rawChapters) {
      if (ch is Map<String, dynamic>) chapters.add(ch);
    }
    int completedCount = 0;
    int totalLessons = 0;
    for (final ch in chapters) {
      final rawLessons = (ch['lessons'] as List<dynamic>?) ?? [];
      for (final l in rawLessons) {
        if (l is Map<String, dynamic>) {
          totalLessons++;
          final p = l['progress'] as Map<String, dynamic>?;
          if (p != null && p['isCompleted'] == true) {
            completedCount++;
          }
        }
      }
    }

    final name = userInfo['name'] as String? ?? '';
    final email = userInfo['email'] as String? ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgDark.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.gradientPrimary,
                  ),
                  child: Center(
                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textMain)),
                      Text(email, style: TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _progressChip('$completedCount/$totalLessons bài', AppColors.primary),
                          const SizedBox(width: 8),
                          _progressChip('${totalLessons > 0 ? (completedCount * 100 ~/ totalLessons) : 0}%', AppColors.success),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...chapters.map((ch) => _buildChapterProgressCard(ch)),
        ],
      ),
    );
  }

  Widget _progressChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.15),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  Widget _buildChapterProgressCard(Map<String, dynamic> chapter) {
    final title = chapter['title'] as String? ?? '';
    final lessons = (chapter['lessons'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.bgDark,
          ),
        ),
        child: ExpansionTile(
          leading: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: AppColors.gradientPrimary,
            ),
            child: Center(child: Icon(Icons.book, color: Colors.white, size: 20)),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMain)),
          subtitle: Text('${lessons.length} bài học',
              style: TextStyle(color: AppColors.textMuted)),
          iconColor: AppColors.textMuted,
          collapsedIconColor: AppColors.textMuted,
          children: [
            ...lessons.map((l) => _buildLessonProgressCard(l)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonProgressCard(Map<String, dynamic> lesson) {
    final lessonTitle = lesson['title'] as String? ?? '';
    final orderIndex = (lesson['orderIndex'] as num?)?.toInt() ?? 0;
    final progress = lesson['progress'] as Map<String, dynamic>?;
    final isCompleted = progress?['isCompleted'] as bool? ?? false;
    final quizScore = (progress?['quizScore'] as num?)?.toDouble();
    final updatedAt = progress?['updatedAt'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(12),
        border: isCompleted ? Border.all(color: AppColors.success.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? AppColors.success.withValues(alpha: 0.15) : AppColors.textDim.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 16,
                color: isCompleted ? AppColors.success : AppColors.textDim,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bài $orderIndex: $lessonTitle',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                    )),
                if (updatedAt.isNotEmpty)
                  Text(updatedAt.substring(0, 10),
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          if (quizScore != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: quizScore >= 5
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.warning.withValues(alpha: 0.15),
              ),
              child: Text('${quizScore.toStringAsFixed(1)}/10',
                  style: TextStyle(
                    color: quizScore >= 5 ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  )),
            )
          else if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.textDim.withValues(alpha: 0.15),
              ),
              child: Text('Chưa quiz',
                  style: TextStyle(color: AppColors.textDim, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng quan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textMain)),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final spacing = 12.0;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _statCard('Chương', '$_totalChapters', Icons.library_books, AppColors.primary)),
                    SizedBox(width: spacing),
                    Expanded(child: _statCard('Bài học', '$_totalLessons', Icons.menu_book, AppColors.accent)),
                    SizedBox(width: spacing),
                    Expanded(child: _statCard('Câu hỏi', '$_totalQuestions', Icons.quiz, AppColors.warning)),
                    SizedBox(width: spacing),
                    Expanded(child: _statCard('Học sinh', '$_totalUsers', Icons.people, AppColors.success)),
                  ],
                );
              }
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(width: (constraints.maxWidth - spacing) / 2, child: _statCard('Chương', '$_totalChapters', Icons.library_books, AppColors.primary)),
                  SizedBox(width: (constraints.maxWidth - spacing) / 2, child: _statCard('Bài học', '$_totalLessons', Icons.menu_book, AppColors.accent)),
                  SizedBox(width: (constraints.maxWidth - spacing) / 2, child: _statCard('Câu hỏi', '$_totalQuestions', Icons.quiz, AppColors.warning)),
                  SizedBox(width: (constraints.maxWidth - spacing) / 2, child: _statCard('Học sinh', '$_totalUsers', Icons.people, AppColors.success)),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _buildUserGrowthChart()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildLessonScoreChart()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildUserGrowthChart(),
                  const SizedBox(height: 16),
                  _buildLessonScoreChart(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserGrowthChart() {
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
              _buildIconBadge(
                  gradient: LinearGradient(colors: [AppColors.accent, Color(0xFF06B6D4)]),
                  icon: Icons.trending_up),
              const SizedBox(width: 10),
              Text('Tăng trưởng người học',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _userGrowth.isEmpty
                ? Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: AppColors.textMuted)))
                : _buildGrowthLineChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthLineChart() {
    final spots = _userGrowth.asMap().entries.map((e) {
      final count = (e.value['count'] as num).toDouble();
      return FlSpot(e.key.toDouble(), count);
    }).toList();

    final maxY = spots.fold(0.0, (max, s) => s.y > max ? s.y : max) + 1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 4 ? (maxY / 4).ceilToDouble() : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.glassBorder,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _userGrowth.length > 10 ? (_userGrowth.length / 10).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < _userGrowth.length) {
                  final date = _userGrowth[idx]['date'] as String? ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(date.length >= 10 ? date.substring(5, 10) : date,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: maxY > 4 ? (maxY / 4).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (spots.length - 1).toDouble().clamp(0, double.infinity),
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.accent,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.accent,
                strokeWidth: 2,
                strokeColor: AppColors.bgDark,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.accent.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              final idx = spot.x.toInt();
              final date = idx >= 0 && idx < _userGrowth.length
                  ? (_userGrowth[idx]['date'] as String? ?? '')
                  : '';
              return LineTooltipItem(
                '$date: ${spot.y.toInt()} người',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonScoreChart() {
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
              _buildIconBadge(
                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryGlow]),
                  icon: Icons.bar_chart),
              const SizedBox(width: 10),
              Text('Điểm trung bình mỗi bài học',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _lessonScores.isEmpty
                ? Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: AppColors.textMuted)))
                : _buildScoreBarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBarChart() {
    final labels = _lessonScores
        .map((s) => s['lessonId'].toString())
        .toList();
    final bars = _lessonScores.asMap().entries.map((e) {
      final score = (e.value['averageScore'] as num).toDouble();
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: score,
            color: AppColors.primary,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
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
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Bài ${labels[idx]}',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 2,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 10,
        barGroups: bars,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final idx = group.x.toInt();
              final count = idx >= 0 && idx < _lessonScores.length
                  ? (_lessonScores[idx]['attemptCount'] as num?)?.toInt() ?? 0
                  : 0;
              return BarTooltipItem(
                'Bài ${idx + 1}: ${rod.toY.toStringAsFixed(1)}/10\n($count lượt)',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIconBadge({required Gradient gradient, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: gradient,
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border(top: BorderSide(color: color.withValues(alpha: 0.5), width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildChapterManager() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Text('Danh sách chương',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: AppColors.gradientPrimary,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _showChapterDialog(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _chapters.length,
            itemBuilder: (_, i) => _buildChapterCard(_chapters[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildChapterCard(Chapter chapter) {
    final lessons = _lessons[chapter.id] ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.bgDark,
          ),
        ),
        child: ExpansionTile(
          leading: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: AppColors.gradientPrimary,
            ),
            child: Center(child: Text('${chapter.orderIndex}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
          ),
          title: Text(chapter.title, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMain)),
          subtitle: Text('${lessons.length} bài học', style: TextStyle(color: AppColors.textMuted)),
          iconColor: AppColors.textMuted,
          collapsedIconColor: AppColors.textMuted,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showChapterDialog(chapter: chapter),
                  icon: Icon(Icons.edit, size: 16, color: AppColors.accent),
                  label: Text('Sửa', style: TextStyle(color: AppColors.accent, fontSize: 13)),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDeleteChapter(chapter),
                  icon: const Icon(Icons.delete, size: 16, color: Colors.redAccent),
                  label: const Text('Xóa', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                ),
                TextButton.icon(
                  onPressed: () => _showLessonDialog(chapter.id),
                  icon: Icon(Icons.add, size: 16, color: AppColors.primary),
                  label: Text('Thêm bài', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                ),
                const SizedBox(width: 8),
              ],
            ),
            ...lessons.map((lesson) => _buildLessonCard(chapter.id, lesson)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(int chapterId, Lesson lesson) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showQuestionManager(lesson),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bài ${lesson.orderIndex}: ${lesson.title}',
                      style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w500)),
                  Text('${lesson.estimatedMinutes} phút',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
            color: AppColors.bgDark,
            onSelected: (v) {
              if (v == 'edit') _showLessonDialog(chapterId, lesson: lesson);
              if (v == 'questions') _showQuestionManager(lesson);
              if (v == 'delete') _confirmDeleteLesson(chapterId, lesson);
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text('Sửa', style: TextStyle(color: AppColors.textMain))),
              PopupMenuItem(value: 'questions', child: Text('Quản lý câu hỏi', style: TextStyle(color: AppColors.textMain))),
              const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.redAccent))),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _refreshChapter(int chapterId) async {
    try {
      final data = await _backend.getList('/chapters/$chapterId/lessons');
      _lessons[chapterId] = data.map((j) => Lesson.fromJson(Map<String, dynamic>.from(j))).toList();
      for (final l in _lessons[chapterId]!) {
        final qData = await _backend.getList('/lessons/${l.id}/questions');
        _questions[l.id] = qData.map((j) => Question.fromJson(Map<String, dynamic>.from(j))).toList();
      }
    } catch (_) {}
  }

  void _showChapterDialog({Chapter? chapter}) {
    final titleCtrl = TextEditingController(text: chapter?.title ?? '');
    final descCtrl = TextEditingController(text: chapter?.description ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(chapter != null ? 'Sửa chương' : 'Thêm chương'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Tên chương'),
              style: TextStyle(color: AppColors.textMain),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 2,
              style: TextStyle(color: AppColors.textMain),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              try {
                if (chapter != null) {
                  await _backend.put('/admin/chapters/${chapter.id}', body: {
                    'title': titleCtrl.text.trim(),
                    'description': descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                  });
                } else {
                  await _backend.post('/admin/chapters', body: {
                    'bookId': 1,
                    'title': titleCtrl.text.trim(),
                    'description': descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                    'orderIndex': _chapters.length + 1,
                  });
                }
                Navigator.pop(ctx);
                await _loadData();
                setState(() {});
              } catch (e) {
                debugPrint('Chapter save error: $e');
              }
            },
            child: Text(chapter != null ? 'Lưu' : 'Thêm'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteChapter(Chapter chapter) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa chương'),
        content: Text('Xóa "${chapter.title}" và tất cả bài học bên trong?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              try {
                await _backend.delete('/admin/chapters/${chapter.id}');
                Navigator.pop(ctx);
                await _loadData();
                setState(() {});
              } catch (e) {
                debugPrint('Chapter delete error: $e');
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showLessonDialog(int chapterId, {Lesson? lesson}) {
    final titleCtrl = TextEditingController(text: lesson?.title ?? '');
    final minCtrl = TextEditingController(text: '${lesson?.estimatedMinutes ?? 15}');
    final contentCtrl = TextEditingController(text: lesson?.contentBody ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lesson != null ? 'Sửa bài học' : 'Thêm bài học'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Tên bài học'),
                style: TextStyle(color: AppColors.textMain),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: minCtrl,
                decoration: const InputDecoration(labelText: 'Số phút'),
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.textMain),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                decoration: const InputDecoration(labelText: 'Nội dung (Markdown)'),
                maxLines: 5,
                style: TextStyle(color: AppColors.textMain),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              final minutes = int.tryParse(minCtrl.text.trim()) ?? 15;
              try {
                if (lesson != null) {
                  await _backend.put('/admin/lessons/${lesson.id}', body: {
                    'title': titleCtrl.text.trim(),
                    'estimatedMinutes': minutes,
                    'contentBody': contentCtrl.text.trim().isEmpty ? null : contentCtrl.text.trim(),
                  });
                } else {
                  final existing = _lessons[chapterId] ?? [];
                  await _backend.post('/admin/lessons', body: {
                    'chapterId': chapterId,
                    'title': titleCtrl.text.trim(),
                    'orderIndex': existing.length + 1,
                    'estimatedMinutes': minutes,
                    'contentBody': contentCtrl.text.trim().isEmpty ? null : contentCtrl.text.trim(),
                  });
                }
                Navigator.pop(ctx);
                await _refreshChapter(chapterId);
                setState(() {});
              } catch (e) {
                debugPrint('Lesson save error: $e');
              }
            },
            child: Text(lesson != null ? 'Lưu' : 'Thêm'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteLesson(int chapterId, Lesson lesson) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa bài học'),
        content: Text('Xóa "${lesson.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              try {
                await _backend.delete('/admin/lessons/${lesson.id}');
                Navigator.pop(ctx);
                await _refreshChapter(chapterId);
                setState(() {});
              } catch (e) {
                debugPrint('Lesson delete error: $e');
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showQuestionManager(Lesson lesson) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgDarker,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _QuestionManagerSheet(
        backend: _backend,
        lesson: lesson,
        onChanged: () async {
          await _refreshChapter(lesson.chapterId);
          setState(() {});
        },
      ),
    );
  }
}

class _QuestionManagerSheet extends StatefulWidget {
  final BackendService backend;
  final Lesson lesson;
  final VoidCallback onChanged;

  const _QuestionManagerSheet({
    required this.backend,
    required this.lesson,
    required this.onChanged,
  });

  @override
  State<_QuestionManagerSheet> createState() => _QuestionManagerSheetState();
}

class _QuestionManagerSheetState extends State<_QuestionManagerSheet> {
  late List<Question> questions;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final data = await widget.backend.getList('/lessons/${widget.lesson.id}/questions');
      if (mounted) {
        setState(() {
          questions = data.map((j) => Question.fromJson(Map<String, dynamic>.from(j))).toList();
        });
      }
    } catch (e) {
      if (mounted) setState(() => questions = []);
    }
  }

  void _refresh() {
    _loadQuestions();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 10, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Câu hỏi - ${widget.lesson.title}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: AppColors.gradientPrimary,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    onPressed: () => _showQuestionDialog(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.glassBorder),
          Expanded(
            child: questions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.quiz_outlined, size: 48, color: AppColors.textDim),
                        const SizedBox(height: 8),
                        Text('Chưa có câu hỏi nào', style: TextStyle(color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        TextButton(onPressed: () => _showQuestionDialog(), child: const Text('Thêm câu hỏi đầu tiên')),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(12),
                    itemCount: questions.length,
                    itemBuilder: (_, i) => _buildQuestionCard(questions[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.gradientPrimary,
                ),
                child: Center(child: Text('${q.id}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.questionText, style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    _optionRow('A', q.optionA, q.correctOption == 'A'),
                    _optionRow('B', q.optionB, q.correctOption == 'B'),
                    _optionRow('C', q.optionC, q.correctOption == 'C'),
                    _optionRow('D', q.optionD, q.correctOption == 'D'),
                    if (q.explanation != null && q.explanation!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('Giải thích: ${q.explanation}',
                          style: TextStyle(color: AppColors.textDim, fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 18, color: AppColors.accent),
                    onPressed: () => _showQuestionDialog(question: q),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                    onPressed: () async {
                      try {
                        await widget.backend.delete('/admin/questions/${q.id}');
                        _refresh();
                      } catch (e) {
                        debugPrint('Delete question error: $e');
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _optionRow(String label, String text, bool correct) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: correct ? Colors.green.withValues(alpha: 0.2) : Colors.transparent,
              border: Border.all(color: correct ? Colors.green : AppColors.textDim),
            ),
            child: Center(
              child: Text(label,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                      color: correct ? Colors.green : AppColors.textDim)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 13,
                    color: correct ? Colors.green : AppColors.textMuted,
                    fontWeight: correct ? FontWeight.w600 : FontWeight.normal)),
          ),
          if (correct) const Icon(Icons.check_circle, size: 14, color: Colors.green),
        ],
      ),
    );
  }

  void _showQuestionDialog({Question? question}) {
    final textCtrl = TextEditingController(text: question?.questionText ?? '');
    final aCtrl = TextEditingController(text: question?.optionA ?? '');
    final bCtrl = TextEditingController(text: question?.optionB ?? '');
    final cCtrl = TextEditingController(text: question?.optionC ?? '');
    final dCtrl = TextEditingController(text: question?.optionD ?? '');
    String correctOpt = question?.correctOption ?? 'A';
    final explCtrl = TextEditingController(text: question?.explanation ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(question != null ? 'Sửa câu hỏi' : 'Thêm câu hỏi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: textCtrl, decoration: const InputDecoration(labelText: 'Câu hỏi'),
                    maxLines: 2, style: TextStyle(color: AppColors.textMain)),
                const SizedBox(height: 10),
                TextField(controller: aCtrl, decoration: const InputDecoration(labelText: 'Đáp án A'),
                    style: TextStyle(color: AppColors.textMain)),
                const SizedBox(height: 8),
                TextField(controller: bCtrl, decoration: const InputDecoration(labelText: 'Đáp án B'),
                    style: TextStyle(color: AppColors.textMain)),
                const SizedBox(height: 8),
                TextField(controller: cCtrl, decoration: const InputDecoration(labelText: 'Đáp án C'),
                    style: TextStyle(color: AppColors.textMain)),
                const SizedBox(height: 8),
                TextField(controller: dCtrl, decoration: const InputDecoration(labelText: 'Đáp án D'),
                    style: TextStyle(color: AppColors.textMain)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: correctOpt,
                  dropdownColor: AppColors.bgDark,
                  decoration: const InputDecoration(labelText: 'Đáp án đúng'),
                  items: ['A', 'B', 'C', 'D']
                      .map((o) => DropdownMenuItem(value: o, child: Text(o, style: TextStyle(color: AppColors.textMain))))
                      .toList(),
                  onChanged: (v) => setDialogState(() => correctOpt = v!),
                  style: TextStyle(color: AppColors.textMain),
                ),
                const SizedBox(height: 10),
                TextField(controller: explCtrl, decoration: const InputDecoration(labelText: 'Giải thích (không bắt buộc)'),
                    maxLines: 2, style: TextStyle(color: AppColors.textMain)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (textCtrl.text.trim().isEmpty) return;
                try {
                  if (question != null) {
                    await widget.backend.put('/admin/questions/${question.id}', body: {
                      'questionText': textCtrl.text.trim(),
                      'optionA': aCtrl.text.trim(),
                      'optionB': bCtrl.text.trim(),
                      'optionC': cCtrl.text.trim(),
                      'optionD': dCtrl.text.trim(),
                      'correctOption': correctOpt,
                      'explanation': explCtrl.text.trim().isEmpty ? null : explCtrl.text.trim(),
                    });
                  } else {
                    await widget.backend.post('/admin/questions', body: {
                      'lessonId': widget.lesson.id,
                      'questionText': textCtrl.text.trim(),
                      'optionA': aCtrl.text.trim(),
                      'optionB': bCtrl.text.trim(),
                      'optionC': cCtrl.text.trim(),
                      'optionD': dCtrl.text.trim(),
                      'correctOption': correctOpt,
                      'explanation': explCtrl.text.trim().isEmpty ? null : explCtrl.text.trim(),
                    });
                  }
                  Navigator.pop(ctx);
                  _refresh();
                } catch (e) {
                  debugPrint('Question save error: $e');
                }
              },
              child: Text(question != null ? 'Lưu' : 'Thêm'),
            ),
          ],
        ),
      ),
    );
  }
}
