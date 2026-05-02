import 'package:cloud_firestore/cloud_firestore.dart';

class Teacher {
  final String id;
  final String name;
  final String subject;
  final String roomNumber;
  final String email;
  final String photoUrl;

  const Teacher({
    required this.id,
    required this.name,
    required this.subject,
    required this.roomNumber,
    required this.email,
    required this.photoUrl,
  });

  factory Teacher.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Teacher(
      id: doc.id,
      name: data['name'] as String? ?? '',
      subject: data['subject'] as String? ?? '',
      roomNumber: data['roomNumber'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'subject': subject,
        'roomNumber': roomNumber,
        'email': email,
        'photoUrl': photoUrl,
      };

  Teacher copyWith({
    String? id,
    String? name,
    String? subject,
    String? roomNumber,
    String? email,
    String? photoUrl,
  }) =>
      Teacher(
        id: id ?? this.id,
        name: name ?? this.name,
        subject: subject ?? this.subject,
        roomNumber: roomNumber ?? this.roomNumber,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
      );
}
