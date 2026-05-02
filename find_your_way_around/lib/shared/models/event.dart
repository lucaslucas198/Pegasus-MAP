class Event {
  final String id;
  final String title;
  final DateTime start;
  final DateTime? end;
  final String? location;
  final String? description;

  const Event({
    required this.id,
    required this.title,
    required this.start,
    this.end,
    this.location,
    this.description,
  });
}
