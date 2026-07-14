import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/backend_service.dart';
import '../theme.dart';

class LessonSearchDelegate extends SearchDelegate<Lesson?> {
  final BackendService _backend = BackendService();

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDarker,
        foregroundColor: AppColors.textMain,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.textMuted),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
            icon: Icon(Icons.clear, color: AppColors.textMuted),
            onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: AppColors.textMain),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchList(context);

  Future<List<Lesson>> _searchLessons(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final data = await _backend.getList('/lessons/search?q=${Uri.encodeComponent(query)}');
      return data.map((j) => Lesson.fromJson(Map<String, dynamic>.from(j))).toList();
    } catch (e) {
      debugPrint('Search error: $e');
      return [];
    }
  }

  Widget _buildSearchList(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.textDim),
            const SizedBox(height: 16),
            Text('Nhập tên bài học để tìm kiếm',
                style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return FutureBuilder<List<Lesson>>(
      future: _searchLessons(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: AppColors.textDim),
                const SizedBox(height: 16),
                Text('Không tìm thấy bài học nào',
                    style: TextStyle(color: AppColors.textMuted)),
              ],
            ),
          );
        }

        return Container(
          color: AppColors.bgDarker,
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (_, i) {
              final lesson = results[i];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgDark.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: AppColors.gradientPrimary,
                    ),
                    child: const Icon(Icons.menu_book,
                        color: Colors.white, size: 20),
                  ),
                  title: Text(lesson.title,
                      style: TextStyle(color: AppColors.textMain)),
                  subtitle: Text('Bài ${lesson.orderIndex} - ${lesson.estimatedMinutes} phút',
                      style: TextStyle(color: AppColors.textMuted)),
                  trailing: Icon(Icons.chevron_right,
                      color: AppColors.textMuted),
                  onTap: () => close(context, lesson),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search),
      onPressed: () async {
        final result = await showSearch<Lesson?>(
          context: context,
          delegate: LessonSearchDelegate(),
        );
        if (result != null && context.mounted) {
          Navigator.of(context)
              .pushNamed('/lesson-detail', arguments: result);
        }
      },
    );
  }
}
