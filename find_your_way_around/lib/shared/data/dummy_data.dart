import '../models/event.dart';
import '../models/teacher.dart';

/// Dummy teachers for local testing.
/// Room numbers match the rooms defined in map/room_data.dart.
const List<Map<String, String>> kDummyTeachers = [
  {
    'name': 'Ms. Sarah Johnson',
    'subject': 'Mathematics',
    'roomNumber': '101',
    'email': 'sjohnson@pegasusschool.edu',
    'photoUrl': '',
  },
  {
    'name': 'Mr. David Chen',
    'subject': 'Science',
    'roomNumber': 'Science Lab',
    'email': 'dchen@pegasusschool.edu',
    'photoUrl': '',
  },
  {
    'name': 'Mrs. Emily Rodriguez',
    'subject': 'English Language Arts',
    'roomNumber': '102',
    'email': 'erodriguez@pegasusschool.edu',
    'photoUrl': '',
  },
  {
    'name': 'Mr. James Williams',
    'subject': 'History',
    'roomNumber': '103',
    'email': 'jwilliams@pegasusschool.edu',
    'photoUrl': '',
  },
  {
    'name': 'Ms. Linda Park',
    'subject': 'Art',
    'roomNumber': 'Art Room',
    'email': 'lpark@pegasusschool.edu',
    'photoUrl': '',
  },
  {
    'name': 'Mr. Kevin Thompson',
    'subject': 'Physical Education',
    'roomNumber': 'Gymnasium',
    'email': 'kthompson@pegasusschool.edu',
    'photoUrl': '',
  },
  {
    'name': 'Mrs. Angela Davis',
    'subject': 'Music',
    'roomNumber': 'Music Room',
    'email': 'adavis@pegasusschool.edu',
    'photoUrl': '',
  },
  {
    'name': 'Ms. Rachel Kim',
    'subject': 'Spanish',
    'roomNumber': '201',
    'email': 'rkim@pegasusschool.edu',
    'photoUrl': '',
  },
  {
    'name': 'Mr. Brian Martinez',
    'subject': 'Computer Science',
    'roomNumber': '202',
    'email': 'bmartinez@pegasusschool.edu',
    'photoUrl': '',
  },
  {
    'name': 'Mrs. Susan Patel',
    'subject': 'Library & Media',
    'roomNumber': 'Library',
    'email': 'spatel@pegasusschool.edu',
    'photoUrl': '',
  },
];

/// Converts [kDummyTeachers] into [Teacher] objects with placeholder IDs.
List<Teacher> get dummyTeacherList => kDummyTeachers
    .asMap()
    .entries
    .map(
      (e) => Teacher(
        id: 'dummy_${e.key}',
        name: e.value['name']!,
        subject: e.value['subject']!,
        roomNumber: e.value['roomNumber']!,
        email: e.value['email']!,
        photoUrl: e.value['photoUrl']!,
      ),
    )
    .toList();

/// Dummy school calendar events for testing the Calendar page.
/// Spread across the current month so the interactive calendar shows
/// highlighted days and multiple events per day.
List<Event> get dummyEventList {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Helper: day offset at a specific hour
  DateTime at(int dayOffset, [int hour = 0, int minute = 0]) =>
      today.add(Duration(days: dayOffset, hours: hour, minutes: minute));

  return [
    // ── Past events (visible on calendar) ────────────────────────────────
    Event(
      id: 'dummy_evt_past_1',
      title: 'Picture Retake Day',
      start: at(-5, 9),
      end: at(-5, 11),
      location: 'Main Hall',
      description: 'Students who missed the original picture day can get their photos taken.',
    ),
    Event(
      id: 'dummy_evt_past_2',
      title: 'Spring Book Fair',
      start: at(-2),
      isAllDay: true,
      location: 'Library',
      description: 'One-day pop-up book fair in the library. Bring your book list!',
    ),

    // ── Today ────────────────────────────────────────────────────────────
    Event(
      id: 'dummy_evt_today_1',
      title: "Principal's Monthly Newsletter",
      start: today,
      isAllDay: true,
      description: "This month's newsletter has been emailed to all families.",
    ),
    Event(
      id: 'dummy_evt_today_2',
      title: 'Student Council Meeting',
      start: at(0, 15, 30),
      end: at(0, 16, 30),
      location: 'Room 103',
      description: 'Monthly meeting — agenda posted outside Room 103.',
    ),

    // ── Upcoming ─────────────────────────────────────────────────────────
    Event(
      id: 'dummy_evt_1',
      title: 'Spring Science Fair',
      start: at(3, 9),
      end: at(3, 12),
      location: 'Gymnasium',
      description:
          'Students present their science projects to judges and fellow students. '
          'Parents and guardians are welcome.',
    ),
    Event(
      id: 'dummy_evt_1b',
      title: 'Robotics Club Demo Night',
      start: at(3, 18),
      end: at(3, 19, 30),
      location: 'Room 202',
      description: 'The Robotics Club shows off their end-of-year builds. Open to all students.',
    ),
    Event(
      id: 'dummy_evt_2',
      title: 'Parent-Teacher Conference',
      start: at(5, 17),
      end: at(5, 20),
      location: 'Main Office',
      description: 'Schedule your appointment in advance via the school portal.',
    ),
    Event(
      id: 'dummy_evt_3',
      title: 'Drama Club: "Into the Woods"',
      start: at(8, 19),
      end: at(8, 21, 30),
      location: 'Auditorium',
      description:
          'The Drama Club presents their spring musical. Tickets available at the door.',
    ),
    Event(
      id: 'dummy_evt_4',
      title: 'No School — Staff Development Day',
      start: at(10),
      isAllDay: true,
    ),
    Event(
      id: 'dummy_evt_5',
      title: 'Art Show Opening',
      start: at(12, 15),
      end: at(12, 17),
      location: 'Art Room',
      description:
          'Celebrate student artwork from the spring semester. Light refreshments served.',
    ),
    Event(
      id: 'dummy_evt_5b',
      title: 'Yearbook Orders Due',
      start: at(12),
      isAllDay: true,
      description: 'Last day to order a yearbook online at yearbookordercenter.com.',
    ),
    Event(
      id: 'dummy_evt_6',
      title: 'Spring Band Concert',
      start: at(15, 18, 30),
      end: at(15, 20),
      location: 'Auditorium',
      description: 'The Pegasus School Band performs pieces practiced throughout the semester.',
    ),
    Event(
      id: 'dummy_evt_7',
      title: 'Field Day',
      start: at(18),
      isAllDay: true,
      location: 'Athletic Field',
      description: 'Annual outdoor games and activities for all grade levels.',
    ),
    Event(
      id: 'dummy_evt_8',
      title: 'End-of-Year Awards Assembly',
      start: at(22, 9),
      end: at(22, 10, 30),
      location: 'Auditorium',
      description:
          'Recognizing student achievements in academics, arts, athletics, and citizenship.',
    ),
  ];
}
