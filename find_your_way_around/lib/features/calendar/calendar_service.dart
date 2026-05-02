import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../shared/models/event.dart';

/// Replace with the real Pegasus School Google Calendar ID and API key.
/// The Calendar ID is typically something like:
///   `school@example.com`  or  `<long-hash>@group.calendar.google.com`
const _calendarId = 'TODO_CALENDAR_ID'; // fill in once school calendar is created
const _apiKey = 'AIzaSyB2xqSwDgPNzCyHBu4x_i78vVbOW2kLp0c';

final calendarServiceProvider = Provider<CalendarService>((_) => CalendarService());

final eventsProvider = FutureProvider.autoDispose<List<Event>>((ref) async {
  return ref.watch(calendarServiceProvider).fetchUpcomingEvents();
});

class CalendarService {
  Future<List<Event>> fetchUpcomingEvents() async {
    final now = DateTime.now().toUtc().toIso8601String();
    final url = Uri.parse(
      'https://www.googleapis.com/calendar/v3/calendars/'
      '${Uri.encodeComponent(_calendarId)}/events'
      '?key=$_apiKey'
      '&timeMin=$now'
      '&orderBy=startTime'
      '&singleEvents=true'
      '&maxResults=50',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load calendar events: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final items = json['items'] as List<dynamic>? ?? [];

    return items.map((item) {
      final map = item as Map<String, dynamic>;
      final startMap = map['start'] as Map<String, dynamic>? ?? {};
      final endMap = map['end'] as Map<String, dynamic>? ?? {};

      // All-day events use 'date'; timed events use 'dateTime'
      final startStr = startMap['dateTime'] as String? ?? startMap['date'] as String? ?? '';
      final endStr = endMap['dateTime'] as String? ?? endMap['date'] as String?;

      return Event(
        id: map['id'] as String? ?? '',
        title: map['summary'] as String? ?? '(No title)',
        start: DateTime.parse(startStr),
        end: endStr != null ? DateTime.parse(endStr) : null,
        location: map['location'] as String?,
        description: map['description'] as String?,
      );
    }).toList();
  }
}
