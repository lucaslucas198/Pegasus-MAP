/// A room entry on the campus map.
/// [x] and [y] are normalized coordinates in the range [0.0, 1.0] relative to
/// the map image size. Multiply by the rendered image size to get pixel position.
/// Update these values once the real floor-plan image is available.
class RoomEntry {
  final String name;
  final String label; // short display label
  final double x;
  final double y;

  const RoomEntry({
    required this.name,
    required this.label,
    required this.x,
    required this.y,
  });
}

/// Placeholder room data — replace coordinates when real floor plan arrives.
const List<RoomEntry> kRooms = [
  RoomEntry(name: 'main office', label: 'Main Office', x: 0.50, y: 0.15),
  RoomEntry(name: 'library', label: 'Library', x: 0.20, y: 0.30),
  RoomEntry(name: 'gymnasium', label: 'Gymnasium', x: 0.75, y: 0.50),
  RoomEntry(name: 'cafeteria', label: 'Cafeteria', x: 0.50, y: 0.60),
  RoomEntry(name: 'room 101', label: 'Room 101', x: 0.25, y: 0.55),
  RoomEntry(name: 'room 102', label: 'Room 102', x: 0.35, y: 0.55),
  RoomEntry(name: 'room 103', label: 'Room 103', x: 0.45, y: 0.55),
  RoomEntry(name: 'room 201', label: 'Room 201', x: 0.25, y: 0.75),
  RoomEntry(name: 'room 202', label: 'Room 202', x: 0.35, y: 0.75),
  RoomEntry(name: 'science lab', label: 'Science Lab', x: 0.65, y: 0.35),
  RoomEntry(name: 'art room', label: 'Art Room', x: 0.80, y: 0.25),
  RoomEntry(name: 'music room', label: 'Music Room', x: 0.80, y: 0.75),
  RoomEntry(name: 'counselor', label: "Counselor's Office", x: 0.60, y: 0.15),
  RoomEntry(name: 'nurse', label: "Nurse's Office", x: 0.40, y: 0.15),
  RoomEntry(name: 'auditorium', label: 'Auditorium', x: 0.50, y: 0.85),
];

/// Returns all rooms whose name contains [query] (case-insensitive).
List<RoomEntry> searchRooms(String query) {
  if (query.trim().isEmpty) return [];
  final q = query.toLowerCase().trim();
  return kRooms.where((r) => r.name.contains(q) || r.label.toLowerCase().contains(q)).toList();
}
