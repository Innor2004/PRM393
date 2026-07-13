import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chapter.dart';
import '../../models/lesson.dart';
import '../../models/question.dart';
import '../../services/api_service.dart';
import '../../theme.dart';
import '../../providers/auth_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}


class _AdminDashboardState extends State<AdminDashboard> {
  final _api = ApiService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final screens = [
      _buildOverview(),
      _buildChapterManager(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(user?.name ?? '',
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
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
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
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
        ],
      ),
    );
  }

  Widget _buildOverview() {
    final chapters = _api.getChapters();
    final totalLessons = chapters.fold<int>(0, (sum, c) => sum + _api.getLessons(c.id).length);
    final totalQuestions = chapters.fold<int>(0, (sum, c) {
      final lessons = _api.getLessons(c.id);
      return sum + lessons.fold<int>(0, (s, l) => s + _api.getQuestions(l.id).length);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tổng quan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textMain)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _statCard('Chương', '${chapters.length}', Icons.library_books, AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('Bài học', '$totalLessons', Icons.menu_book, AppColors.accent)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _statCard('Câu hỏi', '$totalQuestions', Icons.quiz, AppColors.warning)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('Học sinh', '1', Icons.people, AppColors.success)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgDark.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: AppColors.gradientAccent,
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chuyển đến tab "Quản lý" để thêm/sửa/xóa nội dung.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tổng cộng $totalLessons bài học và $totalQuestions câu hỏi.',
                        style: TextStyle(color: AppColors.textDim, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildChapterManager() {
    final chapters = _api.getChapters();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              const Text('Danh sách chương',
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
            itemCount: chapters.length,
            itemBuilder: (_, i) => _buildChapterCard(chapters[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildChapterCard(Chapter chapter) {
    final lessons = _api.getLessons(chapter.id);
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: AppColors.gradientPrimary,
            ),
            child: Center(
              child: Text('${chapter.orderIndex}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
          title: Text(chapter.title,
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMain)),
          subtitle: Text('${lessons.length} bài học',
              style: const TextStyle(color: AppColors.textMuted)),
          iconColor: AppColors.textMuted,
          collapsedIconColor: AppColors.textMuted,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showChapterDialog(chapter: chapter),
                  icon: const Icon(Icons.edit, size: 16, color: AppColors.accent),
                  label: const Text('Sửa', style: TextStyle(color: AppColors.accent, fontSize: 13)),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDeleteChapter(chapter),
                  icon: const Icon(Icons.delete, size: 16, color: Colors.redAccent),
                  label: const Text('Xóa', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                ),
                TextButton.icon(
                  onPressed: () => _showLessonDialog(chapter.id),
                  icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                  label: const Text('Thêm bài', style: TextStyle(color: AppColors.primary, fontSize: 13)),
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
                      style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w500)),
                  Text('${lesson.estimatedMinutes} phút',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
            color: AppColors.bgDark,
            onSelected: (v) {
              if (v == 'edit') _showLessonDialog(chapterId, lesson: lesson);
              if (v == 'questions') _showQuestionManager(lesson);
              if (v == 'delete') _confirmDeleteLesson(chapterId, lesson);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Sửa', style: TextStyle(color: AppColors.textMain))),
              const PopupMenuItem(value: 'questions', child: Text('Quản lý câu hỏi', style: TextStyle(color: AppColors.textMain))),
              const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.redAccent))),
            ],
          ),
        ],
      ),
    );
  }

  void _showChapterDialog({Chapter? chapter}) {
    final titleCtrl = TextEditingController(text: chapter?.title ?? '');
    final descCtrl = TextEditingController(text: chapter?.description ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgDark,
        title: Text(chapter != null ? 'Sửa chương' : 'Thêm chương', style: const TextStyle(color: AppColors.textMain)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Tên chương'),
              style: const TextStyle(color: AppColors.textMain),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 2,
              style: const TextStyle(color: AppColors.textMain),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              if (chapter != null) {
                _api.updateChapter(chapter.id, titleCtrl.text.trim(), descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim());
              } else {
                _api.addChapter(titleCtrl.text.trim(), descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim());
              }
              Navigator.pop(ctx);
              setState(() {});
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
        backgroundColor: AppColors.bgDark,
        title: const Text('Xóa chương', style: TextStyle(color: AppColors.textMain)),
        content: Text('Xóa "${chapter.title}" và tất cả bài học bên trong?', style: const TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              _api.deleteChapter(chapter.id);
              Navigator.pop(ctx);
              setState(() {});
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
        backgroundColor: AppColors.bgDark,
        title: Text(lesson != null ? 'Sửa bài học' : 'Thêm bài học', style: const TextStyle(color: AppColors.textMain)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Tên bài học'),
                style: const TextStyle(color: AppColors.textMain),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: minCtrl,
                decoration: const InputDecoration(labelText: 'Số phút'),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textMain),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                decoration: const InputDecoration(labelText: 'Nội dung (Markdown)'),
                maxLines: 5,
                style: const TextStyle(color: AppColors.textMain),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              final minutes = int.tryParse(minCtrl.text.trim()) ?? 15;
              if (lesson != null) {
                _api.updateLesson(lesson.id, chapterId, titleCtrl.text.trim(),
                    estimatedMinutes: minutes, contentBody: contentCtrl.text.trim().isEmpty ? null : contentCtrl.text.trim());
              } else {
                _api.addLesson(chapterId, titleCtrl.text.trim(),
                    estimatedMinutes: minutes, contentBody: contentCtrl.text.trim().isEmpty ? null : contentCtrl.text.trim());
              }
              Navigator.pop(ctx);
              setState(() {});
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
        backgroundColor: AppColors.bgDark,
        title: const Text('Xóa bài học', style: TextStyle(color: AppColors.textMain)),
        content: Text('Xóa "${lesson.title}"?', style: const TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              _api.deleteLesson(chapterId, lesson.id);
              Navigator.pop(ctx);
              setState(() {});
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
      builder: (ctx) => _QuestionManagerSheet(api: _api, lesson: lesson, onChanged: () {}),
    );
  }
}

class _QuestionManagerSheet extends StatefulWidget {
  final ApiService api;
  final Lesson lesson;
  final VoidCallback onChanged;
  const _QuestionManagerSheet({required this.api, required this.lesson, required this.onChanged});

  @override
  State<_QuestionManagerSheet> createState() => _QuestionManagerSheetState();
}

class _QuestionManagerSheetState extends State<_QuestionManagerSheet> {
  late List<Question> questions;

  @override
  void initState() {
    super.initState();
    questions = widget.api.getQuestions(widget.lesson.id);
  }

  void _refresh() {
    setState(() {
      questions = widget.api.getQuestions(widget.lesson.id);
    });
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
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMain)),
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
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.glassBorder),
          Expanded(
            child: questions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.quiz_outlined, size: 48, color: AppColors.textDim),
                        const SizedBox(height: 8),
                        const Text('Chưa có câu hỏi nào', style: TextStyle(color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () => _showQuestionDialog(),
                          child: const Text('Thêm câu hỏi đầu tiên'),
                        ),
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
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.gradientPrimary,
                ),
                child: Center(
                  child: Text('${q.id}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.questionText,
                        style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    _optionRow('A', q.optionA, q.correctOption == 'A'),
                    _optionRow('B', q.optionB, q.correctOption == 'B'),
                    _optionRow('C', q.optionC, q.correctOption == 'C'),
                    _optionRow('D', q.optionD, q.correctOption == 'D'),
                    if (q.explanation != null && q.explanation!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('Giải thích: ${q.explanation}',
                          style: const TextStyle(color: AppColors.textDim, fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: AppColors.accent),
                    onPressed: () => _showQuestionDialog(question: q),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                    onPressed: () {
                      widget.api.deleteQuestion(widget.lesson.id, q.id);
                      _refresh();
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
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: correct ? Colors.green.withValues(alpha: 0.2) : Colors.transparent,
              border: Border.all(color: correct ? Colors.green : AppColors.textDim),
            ),
            child: Center(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: correct ? Colors.green : AppColors.textDim,
                  )),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                  fontSize: 13,
                  color: correct ? Colors.green : AppColors.textMuted,
                  fontWeight: correct ? FontWeight.w600 : FontWeight.normal,
                )),
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
          backgroundColor: AppColors.bgDark,
          title: Text(question != null ? 'Sửa câu hỏi' : 'Thêm câu hỏi',
              style: const TextStyle(color: AppColors.textMain)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textCtrl,
                  decoration: const InputDecoration(labelText: 'Câu hỏi'),
                  maxLines: 2,
                  style: const TextStyle(color: AppColors.textMain),
                ),
                const SizedBox(height: 10),
                TextField(controller: aCtrl, decoration: const InputDecoration(labelText: 'Đáp án A'),
                    style: const TextStyle(color: AppColors.textMain)),
                const SizedBox(height: 8),
                TextField(controller: bCtrl, decoration: const InputDecoration(labelText: 'Đáp án B'),
                    style: const TextStyle(color: AppColors.textMain)),
                const SizedBox(height: 8),
                TextField(controller: cCtrl, decoration: const InputDecoration(labelText: 'Đáp án C'),
                    style: const TextStyle(color: AppColors.textMain)),
                const SizedBox(height: 8),
                TextField(controller: dCtrl, decoration: const InputDecoration(labelText: 'Đáp án D'),
                    style: const TextStyle(color: AppColors.textMain)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: correctOpt,
                  dropdownColor: AppColors.bgDark,
                  decoration: const InputDecoration(labelText: 'Đáp án đúng'),
                  items: ['A', 'B', 'C', 'D'].map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(color: AppColors.textMain)))).toList(),
                  onChanged: (v) => setDialogState(() => correctOpt = v!),
                  style: const TextStyle(color: AppColors.textMain),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: explCtrl,
                  decoration: const InputDecoration(labelText: 'Giải thích (không bắt buộc)'),
                  maxLines: 2,
                  style: const TextStyle(color: AppColors.textMain),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                if (textCtrl.text.trim().isEmpty) return;
                if (question != null) {
                  widget.api.updateQuestion(question.id, widget.lesson.id,
                      textCtrl.text.trim(), aCtrl.text.trim(), bCtrl.text.trim(), cCtrl.text.trim(), dCtrl.text.trim(),
                      correctOpt, explanation: explCtrl.text.trim().isEmpty ? null : explCtrl.text.trim());
                } else {
                  widget.api.addQuestion(widget.lesson.id,
                      textCtrl.text.trim(), aCtrl.text.trim(), bCtrl.text.trim(), cCtrl.text.trim(), dCtrl.text.trim(),
                      correctOpt, explanation: explCtrl.text.trim().isEmpty ? null : explCtrl.text.trim());
                }
                Navigator.pop(ctx);
                _refresh();
              },
              child: Text(question != null ? 'Lưu' : 'Thêm'),
            ),
          ],
        ),
      ),
    );
  }
}