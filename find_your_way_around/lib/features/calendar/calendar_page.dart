import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../shared/models/event.dart';
import 'calendar_service.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(eventsProvider.future),
        child: eventsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorView(message: e.toString(), onRetry: () => ref.refresh(eventsProvider.future)),
          data: (events) => events.isEmpty
              ? const _EmptyView()
              : _EventList(events: events),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _EventList extends StatelessWidget {
  final List<Event> events;
  const _EventList({required this.events});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _EventCard(event: events[i]),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  const _EventCard({required this.event});

  String _formatDate(DateTime dt) => DateFormat('EEE, MMM d').format(dt.toLocal());
  String _formatTime(DateTime dt) => DateFormat('h:mm a').format(dt.toLocal());

  bool _isAllDay(Event e) {
    // All-day events from Google Calendar have midnight UTC start with no time component
    return e.start.hour == 0 && e.start.minute == 0 && e.start.second == 0;
  }

  @override
  Widget build(BuildContext context) {
    final allDay = _isAllDay(event);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                allDay
                    ? _formatDate(event.start)
                    : '${_formatDate(event.start)}  •  ${_formatTime(event.start)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(event.title, style: Theme.of(context).textTheme.titleLarge),
            if (event.location != null && event.location!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF666666)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(event.location!, style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
            ],
            if (event.description != null && event.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                event.description!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
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
          Icon(Icons.event_busy, size: 64, color: Color(0xFFBDBDBD)),
          SizedBox(height: 16),
          Text('No upcoming events', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Color(0xFFBDBDBD)),
            const SizedBox(height: 16),
            const Text('Could not load events', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
