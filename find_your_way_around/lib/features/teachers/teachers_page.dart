import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../shared/models/teacher.dart';
import 'teachers_repository.dart';

class TeachersPage extends ConsumerWidget {
  const TeachersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(teachersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Teachers')),
      body: teachersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (teachers) => teachers.isEmpty
            ? const _EmptyView()
            : _TeacherGrid(teachers: teachers),
      ),
    );
  }
}

class _TeacherGrid extends StatelessWidget {
  final List<Teacher> teachers;
  const _TeacherGrid({required this.teachers});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: teachers.length,
      itemBuilder: (context, i) => _TeacherCard(teacher: teachers[i]),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  final Teacher teacher;
  const _TeacherCard({required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/teachers/${teacher.id}', extra: teacher),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: _TeacherAvatar(photoUrl: teacher.photoUrl, name: teacher.name),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      teacher.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher.subject,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherAvatar extends StatelessWidget {
  final String photoUrl;
  final String name;
  const _TeacherAvatar({required this.photoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (photoUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photoUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (_, _) => const _AvatarPlaceholder(),
        errorWidget: (_, _, _) => _AvatarInitials(name: name),
      );
    }
    return _AvatarInitials(name: name);
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEEEEEE),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _AvatarInitials extends StatelessWidget {
  final String name;
  const _AvatarInitials({required this.name});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withAlpha(26),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 64, color: Color(0xFFBDBDBD)),
          SizedBox(height: 16),
          Text('No teachers yet', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16)),
        ],
      ),
    );
  }
}
