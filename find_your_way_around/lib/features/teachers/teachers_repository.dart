import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/teacher.dart';

final teachersRepositoryProvider = Provider<TeachersRepository>(
  (_) => TeachersRepository(FirebaseFirestore.instance),
);

final teachersStreamProvider = StreamProvider.autoDispose<List<Teacher>>((ref) {
  return ref.watch(teachersRepositoryProvider).watchAll();
});

class TeachersRepository {
  final FirebaseFirestore _db;
  TeachersRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('teachers');

  Stream<List<Teacher>> watchAll() {
    return _col.orderBy('name').snapshots().map((snap) {
      if (snap.docs.isEmpty) return _demoTeachers();
      return snap.docs.map(Teacher.fromFirestore).toList();
    });
  }

  Future<void> add(Teacher teacher) => _col.add(teacher.toFirestore());
  Future<void> update(Teacher teacher) =>
      _col.doc(teacher.id).update(teacher.toFirestore());
  Future<void> delete(String id) => _col.doc(id).delete();

  static List<Teacher> _demoTeachers() => [
        const Teacher(
          id: 'demo_1',
          name: 'Ms. Sarah Anderson',
          subject: 'English Language Arts',
          roomNumber: '101',
          email: 's.anderson@pegasusschool.org',
          photoUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
        ),
        const Teacher(
          id: 'demo_2',
          name: 'Mr. David Chen',
          subject: 'Mathematics',
          roomNumber: '203',
          email: 'd.chen@pegasusschool.org',
          photoUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
        ),
        const Teacher(
          id: 'demo_3',
          name: 'Ms. Emily Rodriguez',
          subject: 'Science',
          roomNumber: 'Science Lab',
          email: 'e.rodriguez@pegasusschool.org',
          photoUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
        ),
        const Teacher(
          id: 'demo_4',
          name: 'Mr. James Okafor',
          subject: 'Social Studies & History',
          roomNumber: '102',
          email: 'j.okafor@pegasusschool.org',
          photoUrl: 'https://randomuser.me/api/portraits/men/75.jpg',
        ),
        const Teacher(
          id: 'demo_5',
          name: 'Ms. Linda Park',
          subject: 'Visual Arts',
          roomNumber: 'Art Room',
          email: 'l.park@pegasusschool.org',
          photoUrl: 'https://randomuser.me/api/portraits/women/22.jpg',
        ),
        const Teacher(
          id: 'demo_6',
          name: 'Mr. Thomas Wright',
          subject: 'Physical Education',
          roomNumber: 'Gymnasium',
          email: 't.wright@pegasusschool.org',
          photoUrl: 'https://randomuser.me/api/portraits/men/51.jpg',
        ),
        const Teacher(
          id: 'demo_7',
          name: 'Ms. Maria Gonzalez',
          subject: 'Spanish & World Languages',
          roomNumber: '201',
          email: 'm.gonzalez@pegasusschool.org',
          photoUrl: 'https://randomuser.me/api/portraits/women/10.jpg',
        ),
        const Teacher(
          id: 'demo_8',
          name: 'Mr. Kevin Nakamura',
          subject: 'Computer Science & Technology',
          roomNumber: 'Computer Lab',
          email: 'k.nakamura@pegasusschool.org',
          photoUrl: 'https://randomuser.me/api/portraits/men/18.jpg',
        ),
        const Teacher(
          id: 'demo_9',
          name: 'Ms. Rachel Thompson',
          subject: 'Music & Performing Arts',
          roomNumber: 'Music Room',
          email: 'r.thompson@pegasusschool.org',
          photoUrl: 'https://randomuser.me/api/portraits/women/56.jpg',
        ),
        const Teacher(
          id: 'demo_10',
          name: 'Dr. William Foster',
          subject: 'Advanced Sciences',
          roomNumber: 'Science Lab',
          email: 'w.foster@pegasusschool.org',
          photoUrl: 'https://randomuser.me/api/portraits/men/62.jpg',
        ),
        const Teacher(
          id: 'demo_11',
          name: 'Ms. Angela Kim',
          subject: 'Grade 3 Homeroom',
          roomNumber: '103',
          email: 'a.kim@pegasusschool.org',
          photoUrl: 'https://randomuser.me/api/portraits/women/84.jpg',
        ),
        const Teacher(
          id: 'demo_12',
          name: 'Mr. Marcus Davis',
          subject: 'Grade 5 Homeroom',
          roomNumber: '104',
          email: 'm.davis@pegasusschool.org',
          photoUrl: 'https://randomuser.me/api/portraits/men/41.jpg',
        ),
      ];
}
