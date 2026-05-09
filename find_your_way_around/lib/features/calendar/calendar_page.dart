import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/event.dart';
import 'calendar_service.dart';

// ─── helpers ─────────────────────────────────────────────────────────────────

DateTime _norm(DateTime d) => DateTime(d.year, d.month, d.day);

Map<DateTime, List<Event>> _groupByDate(List<Event> events) {
  final map = <DateTime, List<Event>>{};
  for (final e in events) {
    (map[_norm(e.start)] ??= []).add(e);
  }
  return map;
}

List<Event> _upcoming(List<Event> all, int max) {
  final today = _norm(DateTime.now());
  return (all.where((e) => !_norm(e.start).isBefore(today)).toList()
        ..sort((a, b) => a.start.compareTo(b.start)))
      .take(max)
      .toList();
}

// ─── page ────────────────────────────────────────────────────────────────────

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  // _focusedDay drives the calendar header (which month is displayed).
  // It lives in local state because it is purely UI navigation and
  // does not need to survive page transitions.
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    final selectedDay = ref.watch(selectedDayProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Academic Calendar')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(eventsProvider.future),
        color: AppColors.primary,
        child: eventsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorView(
            message: e.toString(),
            onRetry: () => ref.refresh(eventsProvider.future),
          ),
          data: (events) {
            final byDate = _groupByDate(events);
            final dayEvents = byDate[_norm(selectedDay)] ?? [];
            final upcomingEvents = _upcoming(events, 5);

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Interactive month calendar ────────────────────────────
                SliverToBoxAdapter(
                  child: _CalendarCard(
                    focusedDay: _focusedDay,
                    selectedDay: selectedDay,
                    eventLoader: (day) => byDate[_norm(day)] ?? [],
                    onDaySelected: (selected, focused) {
                      ref.read(selectedDayProvider.notifier).state = selected;
                      setState(() => _focusedDay = focused);
                    },
                    onPageChanged: (focused) =>
                        setState(() => _focusedDay = focused),
                  ),
                ),

                // ── Events for selected day ───────────────────────────────
                SliverToBoxAdapter(
                  child: _DayPanel(
                    selectedDay: selectedDay,
                    events: dayEvents,
                  ),
                ),

                // ── Upcoming highlights ───────────────────────────────────
                if (upcomingEvents.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _UpcomingPanel(events: upcomingEvents),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── calendar card ───────────────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<Event> Function(DateTime) eventLoader;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(DateTime) onPageChanged;

  const _CalendarCard({
    required this.focusedDay,
    required this.selectedDay,
    required this.eventLoader,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TableCalendar<Event>(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2028, 12, 31),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(day, selectedDay),
          eventLoader: eventLoader,
          onDaySelected: onDaySelected,
          onPageChanged: onPageChanged,
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.sunday,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.3,
            ),
            headerPadding: EdgeInsets.symmetric(vertical: 8),
            leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primary, size: 20),
            rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
            leftChevronMargin: EdgeInsets.zero,
            rightChevronMargin: EdgeInsets.zero,
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(fontSize: 12, color: AppColors.subtleText),
            weekendStyle: TextStyle(fontSize: 12, color: AppColors.subtleText),
          ),
          calendarStyle: CalendarStyle(
            cellMargin: const EdgeInsets.all(4),
            todayDecoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(35),
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            defaultTextStyle: const TextStyle(fontSize: 13, color: AppColors.onBackground),
            weekendTextStyle: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
            outsideTextStyle: const TextStyle(fontSize: 13, color: Color(0xFFCCCCCC)),
            markerDecoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
            markerSize: 5,
            markerMargin: const EdgeInsets.symmetric(horizontal: 1.5),
            markersAnchor: 0.75,
          ),
        ),
      ),
    );
  }
}

// ─── day panel ───────────────────────────────────────────────────────────────

class _DayPanel extends StatelessWidget {
  final DateTime selectedDay;
  final List<Event> events;

  const _DayPanel({required this.selectedDay, required this.events});

  @override
  Widget build(BuildContext context) {
    final isToday = isSameDay(selectedDay, DateTime.now());
    final label = isToday
        ? 'Today'
        : DateFormat('EEEE, MMMM d').format(selectedDay);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label),
          const SizedBox(height: 12),
          if (events.isEmpty)
            const _NoEventsBanner()
          else
            ...events.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _EventCard(event: e),
              ),
            ),
        ],
      ),
    );
  }
}

class _NoEventsBanner extends StatelessWidget {
  const _NoEventsBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        children: [
          Icon(Icons.event_available, size: 32, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            'No events on this day',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── upcoming panel ──────────────────────────────────────────────────────────

class _UpcomingPanel extends StatelessWidget {
  final List<Event> events;

  const _UpcomingPanel({required this.events});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Upcoming Events'),
          const SizedBox(height: 12),
          ...events.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _EventCard(event: e),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── shared widgets ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final local = event.start.toLocal();

    return Card(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accent sidebar with time
            Container(
              width: 64,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Text(
                event.isAllDay
                    ? 'All\nDay'
                    : '${DateFormat('h:mm').format(local)}\n${DateFormat('a').format(local)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),

            // Event details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onBackground,
                      ),
                    ),
                    if (event.location != null &&
                        event.location!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.subtleText,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.subtleText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (event.description != null &&
                        event.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        event.description!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.subtleText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

// ─── error view ───────────────────────────────────────────────────────────────

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
            Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Could not load events',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
