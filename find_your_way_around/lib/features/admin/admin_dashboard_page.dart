import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../shared/models/teacher.dart';
import '../teachers/teachers_repository.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Guard: redirect to login if not authenticated
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/admin'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final teachersAsync = ref.watch(teachersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin — Teachers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/admin');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTeacherForm(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Add Teacher'),
      ),
      body: teachersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (teachers) => teachers.isEmpty
            ? const Center(child: Text('No teachers yet. Tap + to add one.'))
            : _TeacherList(teachers: teachers),
      ),
    );
  }

  void _showTeacherForm(BuildContext context, WidgetRef ref, Teacher? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _TeacherForm(existing: existing, ref: ref),
    );
  }
}

// ---------------------------------------------------------------------------
// Teacher list
// ---------------------------------------------------------------------------

class _TeacherList extends ConsumerWidget {
  final List<Teacher> teachers;
  const _TeacherList({required this.teachers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: teachers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _TeacherTile(
        teacher: teachers[i],
        onEdit: () => _showForm(context, ref, teachers[i]),
        onDelete: () => _confirmDelete(context, ref, teachers[i]),
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, Teacher teacher) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _TeacherForm(existing: teacher, ref: ref),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Teacher teacher) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete teacher?'),
        content: Text('Remove ${teacher.name} from the directory?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(teachersRepositoryProvider).delete(teacher.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _TeacherTile extends StatelessWidget {
  final Teacher teacher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _TeacherTile({required this.teacher, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(26),
          child: Text(
            teacher.name.isNotEmpty ? teacher.name[0].toUpperCase() : '?',
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(teacher.name),
        subtitle: Text('${teacher.subject} • Room ${teacher.roomNumber}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add / Edit form
// ---------------------------------------------------------------------------

class _TeacherForm extends StatefulWidget {
  final Teacher? existing;
  final WidgetRef ref;
  const _TeacherForm({this.existing, required this.ref});

  @override
  State<_TeacherForm> createState() => _TeacherFormState();
}

class _TeacherFormState extends State<_TeacherForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _subject;
  late final TextEditingController _room;
  late final TextEditingController _email;
  bool _saving = false;
  XFile? _pickedImage;
  String _photoUrl = '';

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _name    = TextEditingController(text: t?.name ?? '');
    _subject = TextEditingController(text: t?.subject ?? '');
    _room    = TextEditingController(text: t?.roomNumber ?? '');
    _email   = TextEditingController(text: t?.email ?? '');
    _photoUrl = t?.photoUrl ?? '';
  }

  @override
  void dispose() {
    _name.dispose(); _subject.dispose(); _room.dispose(); _email.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (file != null) setState(() => _pickedImage = file);
  }

  Future<String> _uploadPhoto(String teacherId) async {
    if (_pickedImage == null) return _photoUrl;
    final ref = FirebaseStorage.instance.ref('teachers/$teacherId.jpg');
    await ref.putFile(File(_pickedImage!.path));
    return await ref.getDownloadURL();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repo = widget.ref.read(teachersRepositoryProvider);
      final isNew = widget.existing == null;
      // For new teachers we need to create the doc first to get an ID for the photo path
      if (isNew) {
        // Add with empty photoUrl then update with real URL
        final tempTeacher = Teacher(
          id: '',
          name: _name.text.trim(),
          subject: _subject.text.trim(),
          roomNumber: _room.text.trim(),
          email: _email.text.trim(),
          photoUrl: '',
        );
        await repo.add(tempTeacher);
        // The stream will pick up the new doc; photo upload not blocking here
        // for simplicity. Photo can be updated via Edit.
      } else {
        final id = widget.existing!.id;
        final uploadedUrl = await _uploadPhoto(id);
        final updated = widget.existing!.copyWith(
          name: _name.text.trim(),
          subject: _subject.text.trim(),
          roomNumber: _room.text.trim(),
          email: _email.text.trim(),
          photoUrl: uploadedUrl,
        );
        await repo.update(updated);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.existing == null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 24,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(isNew ? 'Add Teacher' : 'Edit Teacher',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            // Photo picker (only for editing existing teachers — we need an ID first)
            if (!isNew) ...[
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: _pickedImage != null
                        ? FileImage(File(_pickedImage!.path))
                        : (_photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null) as ImageProvider?,
                    child: _pickedImage == null && _photoUrl.isEmpty
                        ? const Icon(Icons.camera_alt, size: 32)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Center(child: Text('Tap to change photo', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)))),
              const SizedBox(height: 16),
            ],
            _field(_name, 'Name', Icons.person_outline),
            const SizedBox(height: 12),
            _field(_subject, 'Subject', Icons.book_outlined),
            const SizedBox(height: 12),
            _field(_room, 'Room Number', Icons.door_front_door_outlined),
            const SizedBox(height: 12),
            _field(_email, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isNew ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }
}
