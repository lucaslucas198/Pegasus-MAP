import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/teacher.dart';

class TeacherDetailPage extends StatelessWidget {
  final Teacher teacher;
  const TeacherDetailPage({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(teacher.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PhotoHeader(teacher: teacher),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(icon: Icons.book_outlined, label: 'Subject', value: teacher.subject),
                  const SizedBox(height: 12),
                  _InfoRow(icon: Icons.door_front_door_outlined, label: 'Room', value: teacher.roomNumber),
                  const SizedBox(height: 12),
                  _InfoRow(icon: Icons.email_outlined, label: 'Email', value: teacher.email),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoHeader extends StatelessWidget {
  final Teacher teacher;
  const _PhotoHeader({required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      color: AppColors.primary,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (teacher.photoUrl.isNotEmpty)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: teacher.photoUrl,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withAlpha(160)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (teacher.photoUrl.isEmpty)
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.secondary,
                    child: Text(
                      _initials(teacher.name),
                      style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  teacher.name,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 2),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ],
    );
  }
}
