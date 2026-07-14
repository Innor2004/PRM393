import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final progress = context.watch<ProgressProvider>();
    final badges = progress.earnedBadges;

    return Container(
      decoration: BoxDecoration(gradient: AppColors.gradientSurface),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hồ sơ & Thành tích'),
          actions: [
            IconButton(
              icon: Icon(context.watch<ThemeProvider>().isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => context.read<ThemeProvider>().toggleTheme(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.gradientPrimary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.bgDark,
                      backgroundImage: _getAvatarImage(user?.avatarUrl),
                      child: _hasAvatar(user?.avatarUrl)
                          ? null
                          : Icon(Icons.person, size: 44, color: AppColors.textMain),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Material(
                      color: AppColors.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: auth.isLoading
                            ? null
                            : () => _pickAndUploadAvatar(context),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                user?.name ?? 'Người dùng',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: auth.isLoading
                          ? null
                          : () => _showEditNameDialog(context),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Sửa tên'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: auth.isLoading
                          ? null
                          : () => _showChangePasswordDialog(context),
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('Đổi mật khẩu'),
                    ),
                  ),
                ],
              ),
              if (auth.isLoading) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
              const SizedBox(height: 28),
              _buildGlassCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildIconBadge(
                            gradient: AppColors.gradientPrimary,
                            icon: Icons.trending_up),
                        const SizedBox(width: 12),
                        Text('Tiến độ học tập',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMain)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                            '${progress.overallPercent.toInt()}%', 'Hoàn thành'),
                        _buildStatItem(
                            '${progress.progressList.length}', 'Bài đã học'),
                        _buildStatItem('${badges.length}', 'Huy hiệu'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  _buildIconBadge(
                      gradient: LinearGradient(colors: [
                        AppColors.warning,
                        Color(0xFFFCD34D),
                      ]),
                      icon: Icons.emoji_events),
                  const SizedBox(width: 12),
                  Text('Huy hiệu đạt được',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain)),
                ],
              ),
              const SizedBox(height: 16),
              badges.isEmpty
                  ? _buildGlassCard(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.emoji_events_outlined,
                              size: 48, color: AppColors.textDim),
                          SizedBox(height: 12),
                          Text(
                            'Chưa có huy hiệu. Hãy học tập để đạt huy hiệu!',
                            style: TextStyle(color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: badges
                          .map((badge) => _buildBadgeCard(
                                badge.name,
                                badge.iconUrl ?? '🏆',
                                badge.description ?? '',
                              ))
                          .toList(),
                    ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: child,
    );
  }

  Widget _buildIconBadge({required Gradient gradient, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: gradient,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  bool _hasAvatar(String? avatarUrl) {
    return avatarUrl != null && avatarUrl.trim().isNotEmpty;
  }

  ImageProvider<Object>? _getAvatarImage(String? avatarUrl) {
    if (!_hasAvatar(avatarUrl)) return null;
    return NetworkImage(avatarUrl!);
  }

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
      );
      if (image == null || !context.mounted) return;
      List<int>? imageBytes;
      if (kIsWeb) {
        imageBytes = await image.readAsBytes();
        if (imageBytes.isEmpty) {
          throw Exception('Không đọc được dữ liệu ảnh');
        }
      }
      if (!context.mounted) return;
      final auth = context.read<AuthProvider>();
      final success = await auth.uploadAvatar(
        filePath: image.path,
        bytes: imageBytes,
        fileName: image.name,
      );
      if (!context.mounted) return;
      _showMessage(context,
          success ? 'Đã cập nhật ảnh đại diện' : auth.error ?? 'Cập nhật ảnh thất bại',
          success);
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(
          context, error.toString().replaceFirst('Exception: ', ''), false);
    }
  }

  Future<void> _showEditNameDialog(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final controller = TextEditingController(text: auth.user?.name ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sửa tên hiển thị'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 100,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Họ và tên',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text),
              child: const Text('Lưu')),
        ],
      ),
    );
    controller.dispose();
    if (name == null || !context.mounted) return;
    final success = await auth.updateName(name);
    if (!context.mounted) return;
    _showMessage(context,
        success ? 'Đã cập nhật tên' : auth.error ?? 'Cập nhật tên thất bại', success);
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final values = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu mới',
                  helperText: 'Tối thiểu 6 ký tự',
                  prefixIcon: Icon(Icons.password),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nhập lại mật khẩu mới',
                  prefixIcon: Icon(Icons.password),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, [
                    currentController.text,
                    newController.text,
                    confirmController.text,
                  ]),
              child: const Text('Đổi mật khẩu')),
        ],
      ),
    );
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    if (values == null || !context.mounted) return;
    final currentPassword = values[0];
    final newPassword = values[1];
    final confirmPassword = values[2];
    if (currentPassword.trim().isEmpty) {
      _showMessage(context, 'Vui lòng nhập mật khẩu hiện tại', false);
      return;
    }
    if (newPassword.length < 6) {
      _showMessage(context, 'Mật khẩu mới phải có ít nhất 6 ký tự', false);
      return;
    }
    if (newPassword != confirmPassword) {
      _showMessage(context, 'Mật khẩu nhập lại không khớp', false);
      return;
    }
    if (currentPassword == newPassword) {
      _showMessage(context, 'Mật khẩu mới phải khác mật khẩu hiện tại', false);
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (!context.mounted) return;
    _showMessage(context,
        success ? 'Đổi mật khẩu thành công' : auth.error ?? 'Đổi mật khẩu thất bại',
        success);
  }

  void _showMessage(BuildContext context, String message, bool success) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? AppColors.success : Colors.red,
        ),
      );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.gradientAccent.createShader(bounds),
          child: Text(value,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildBadgeCard(String name, String icon, String description) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(name,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textMain),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(description,
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
