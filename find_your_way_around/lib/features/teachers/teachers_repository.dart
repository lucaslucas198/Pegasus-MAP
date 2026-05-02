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

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('teachers');

  Stream<List<Teacher>> watchAll() {
    return _col.orderBy('name').snapshots().map(
          (snap) => snap.docs.map(Teacher.fromFirestore).toList(),
        );
  }

  Future<void> add(Teacher teacher) => _col.add(teacher.toFirestore());

  Future<void> update(Teacher teacher) =>
      _col.doc(teacher.id).update(teacher.toFirestore());

  Future<void> delete(String id) => _col.doc(id).delete();
}
