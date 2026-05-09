import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../shared/models/event.dart';
import '../../shared/data/dummy_data.dart';

const _calendarId = 'TODO_CALENDAR_ID';
const _apiKey = 'AIzaSyB2xqSwDgPNzCyHBu4x_i78vVbOW2kLp0c';

/// Currently selected day in the calendar UI.
/// Shared between [CalendarPage] and any other widget that needs it.
final selectedDayProvider = StateProvider<DateTime>((_) => DateTime.now());

final calendarServiceProvider = Provider<CalendarService>((_) => CalendarService());

/// All school events. When the Google Calendar ID is configured, swap
/// [CalendarService] for a subclass/implementation that overrides
/// [fetchEventsForDateRange] with a real API call.
final eventsProvider = FutureProvider.autoDispose<List<Event>>((ref) async {
  return ref.watch(calendarServiceProvider).fetchUpcomingEvents();
});

class CalendarService {
  Future<List<Event>> fetchUpcomingEvents() async {
    // Return dummy events while the real Google Calendar ID is not yet configured.
    if (_calendarId == 'TODO_CALENDAR_ID') return dummyEventList;

    final now = DateTime.now().toUtc().toIso8601String();
    final url = Uri.parse(
      'https://www.googleapis.com/calendar/v3/calendars/'
      '${Uri.encodeComponent(_calendarId)}/events'
      '?key=$_apiKey'
      '&timeMin=$now'
      '&orderBy=startTime'
      '&singleEvents=true'
      '&maxResults=100',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to load calendar events: ${response.statusCode}');
    }

    return _parseEvents(response.body);
  }

  /// Fetches events within [start]..[end]. Used by the calendar view when
  /// the user navigates to a different month.
  ///
  /// TODO: replace the fallback below with a real Google Calendar API call
  /// filtered by timeMin=[start] and timeMax=[end] once the Calendar ID is set.
  Future<List<Event>> fetchEventsForDateRange(DateTime start, DateTime end) async {
    if (_calendarId == 'TODO_CALENDAR_ID') {
      return dummyEventList.where((e) {
        return !e.start.isBefore(start) && !e.start.isAfter(end);
      }).toList();
    }

    final url = Uri.parse(
      'https://www.googleapis.com/calendar/v3/calendars/'
      '${Uri.encodeComponent(_calendarId)}/events'
      '?key=$_apiKey'
      '&timeMin=${start.toUtc().toIso8601String()}'
      '&timeMax=${end.toUtc().toIso8601String()}'
      '&orderBy=startTime'
      '&singleEvents=true'
      '&maxResults=250',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load calendar events: ${response.statusCode}');
    }

    return _parseEvents(response.body);
  }

  List<Event> _parseEvents(String body) {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final items = json['items'] as List<dynamic>? ?? [];

    return items.map((item) {
      final map = item as Map<String, dynamic>;
      final startMap = map['start'] as Map<String, dynamic>? ?? {};
      final endMap = map['end'] as Map<String, dynamic>? ?? {};

      // All-day events use 'date'; timed events use 'dateTime'
      final isAllDay = startMap['date'] != null && startMap['dateTime'] == null;
      final startStr = startMap['dateTime'] as String? ?? startMap['date'] as String? ?? '';
      final endStr = endMap['dateTime'] as String? ?? endMap['date'] as String?;

      return Event(
        id: map['id'] as String? ?? '',
        title: map['summary'] as String? ?? '(No title)',
        start: DateTime.parse(startStr),
        end: endStr != null ? DateTime.parse(endStr) : null,
        location: map['location'] as String?,
        description: map['description'] as String?,
        isAllDay: isAllDay,
      );
    }).toList();
  }

  List<Event> _demoEvents() {
    return [
      Event(
        id: 'd1',
        title: '8th Grade Health Education Week',
        start: DateTime(2026, 5, 6),
        end: DateTime(2026, 5, 8),
        location: 'Health Classroom',
        description: 'A week-long health education program for 8th grade students covering wellness, fitness, and life skills.',
      ),
      Event(
        id: 'd2',
        title: 'Faculty PD — Half Day',
        start: DateTime(2026, 5, 6),
        end: null,
        location: 'All Campus',
        description: 'Early dismissal today for faculty professional development. Students dismissed at 12:00 PM.',
      ),
      Event(
        id: 'd3',
        title: 'PK Spring Tea',
        start: DateTime(2026, 5, 7, 10, 0),
        end: DateTime(2026, 5, 7, 11, 30),
        location: 'Pre-K Classrooms',
        description: 'Join our Pre-K students for a special Spring Tea celebration. Families are warmly invited to attend.',
      ),
      Event(
        id: 'd4',
        title: 'Street Sweeping Day',
        start: DateTime(2026, 5, 8),
        end: null,
        location: 'School Parking Areas',
        description: 'Reminder: street sweeping is scheduled today. Please plan accordingly for drop-off and pick-up.',
      ),
      Event(
        id: 'd5',
        title: 'Tech Orientation — Rising Grade 2 Parents',
        start: DateTime(2026, 5, 11, 8, 30),
        end: DateTime(2026, 5, 11, 9, 30),
        location: 'Computer Lab',
        description: 'Pegasus Presents: Technology orientation for parents of students entering 2nd grade. Learn about digital tools, Chromebook policies, and our AI approach to learning.',
      ),
      Event(
        id: 'd6',
        title: 'Tech Orientation — Rising Grade 5 Parents',
        start: DateTime(2026, 5, 12, 8, 30),
        end: DateTime(2026, 5, 12, 9, 30),
        location: 'Computer Lab',
        description: 'Pegasus Presents: Technology orientation for parents of students entering 5th grade. Covers middle school tech expectations, digital citizenship, and research tools.',
      ),
      Event(
        id: 'd7',
        title: 'Community Gathering',
        start: DateTime(2026, 5, 13, 18, 0),
        end: DateTime(2026, 5, 13, 20, 0),
        location: 'Cafeteria & Courtyard',
        description: 'An evening for the entire Pegasus community to come together, connect, and celebrate the remainder of the school year.',
      ),
      Event(
        id: 'd8',
        title: 'Spring Concert',
        start: DateTime(2026, 5, 20, 18, 30),
        end: DateTime(2026, 5, 20, 20, 0),
        location: 'Auditorium',
        description: 'Join us for an evening of music performed by our talented students across all grade levels. Doors open at 6:00 PM.',
      ),
      Event(
        id: 'd9',
        title: 'Memorial Day — No School',
        start: DateTime(2026, 5, 25),
        end: null,
        location: null,
        description: 'School offices are closed in observance of Memorial Day. Enjoy the long weekend!',
      ),
      Event(
        id: 'd10',
        title: 'Science Fair',
        start: DateTime(2026, 6, 2, 9, 0),
        end: DateTime(2026, 6, 2, 13, 0),
        location: 'Gymnasium',
        description: 'Students present their independent research projects. All families are welcome to attend and support our young scientists.',
      ),
      Event(
        id: 'd11',
        title: '8th Grade Farewell Ceremony',
        start: DateTime(2026, 6, 10, 14, 0),
        end: DateTime(2026, 6, 10, 16, 0),
        location: 'Auditorium',
        description: 'A heartfelt celebration honoring our graduating 8th graders as they move on to high school.',
      ),
      Event(
        id: 'd12',
        title: 'Last Day of School',
        start: DateTime(2026, 6, 12),
        end: null,
        location: 'All Campus',
        description: 'Celebrate the end of an amazing year! Fun activities, special lunch, and award presentations for all students.',
      ),
    ];
  }
}
