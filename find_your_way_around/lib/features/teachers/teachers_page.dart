import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/teacher.dart';
import 'teachers_repository.dart';

class TeachersPage extends ConsumerWidget {
  const TeachersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(teachersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Faculty Directory')),
      body: teachersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to load faculty information.\n$e',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(color: AppColors.subtleText),
            ),
          ),
        ),
        data: (teachers) =>
            teachers.isEmpty ? const _EmptyView() : _TeacherGrid(teachers: teachers),
      ),
    );
  }
}

class _TeacherGrid extends StatelessWidget {
  final List<Teacher> teachers;
  const _TeacherGrid({required this.teachers});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.80,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Navy header bar
            Container(height: 4, color: AppColors.primary),
            Expanded(
              flex: 3,
              child: _TeacherAvatar(
                photoUrl: teacher.photoUrl,
                name: teacher.name,
              ),
            ),
            // Name + subject info
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                children: [
                  Text(
                    teacher.name,
                    style: GoogleFonts.merriweather(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onBackground,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    teacher.subject,
                    style: GoogleFonts.openSans(
                      fontSize: 11,
                      color: AppColors.subtleText,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Room ${teacher.roomNumber}',
                      style: GoogleFonts.openSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
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
      color: AppColors.background,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
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
      color: AppColors.primary.withAlpha(14),
      child: Center(
        child: Text(
          _initials,
          style: GoogleFonts.merriweather(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No Faculty Listed',
            style: GoogleFonts.merriweather(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Faculty profiles will appear here once added',
            style: GoogleFonts.openSans(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
