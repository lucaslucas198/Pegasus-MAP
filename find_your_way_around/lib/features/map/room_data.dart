enum RoomZone {
  admin,
  classroom,
  science,
  arts,
  athletics,
  dining,
  performing,
  library,
}

class RoomEntry {
  final String name;
  final String label;
  final double x;   // normalized center x [0..1]
  final double y;   // normalized center y [0..1]
  final double rw;  // normalized width
  final double rh;  // normalized height
  final RoomZone zone;
  final String photoUrl;
  final String description;
  final List<String> directions;

  const RoomEntry({
    required this.name,
    required this.label,
    required this.x,
    required this.y,
    this.rw = 0.10,
    this.rh = 0.08,
    required this.zone,
    required this.photoUrl,
    required this.description,
    required this.directions,
  });
}

const List<RoomEntry> kRooms = [
  // ── Administration ─────────────────────────────────────────────
  RoomEntry(
    name: 'main office',
    label: 'Main Office',
    x: 0.50, y: 0.11,
    rw: 0.14, rh: 0.09,
    zone: RoomZone.admin,
    photoUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=80',
    description: 'The administrative heart of The Pegasus School. Stop here for attendance, visitor sign-in, messages, and general school information.',
    directions: [
      'Enter through the main front entrance on Sycamore Avenue.',
      'Walk straight ahead through the lobby.',
      'The Main Office is directly in front of you.',
    ],
  ),
  RoomEntry(
    name: 'nurse',
    label: "Nurse's Office",
    x: 0.37, y: 0.11,
    rw: 0.10, rh: 0.07,
    zone: RoomZone.admin,
    photoUrl: 'https://images.unsplash.com/photo-1631217868264-e5b90bb7e133?w=800&q=80',
    description: 'Our school nurse is available during all school hours. Students who feel unwell or are injured should come here first.',
    directions: [
      'Enter through the main front entrance.',
      'Turn left at the lobby.',
      "The Nurse's Office is the second door on your left.",
    ],
  ),
  RoomEntry(
    name: 'counselor',
    label: "Counselor's Office",
    x: 0.63, y: 0.11,
    rw: 0.10, rh: 0.07,
    zone: RoomZone.admin,
    photoUrl: 'https://images.unsplash.com/photo-1573497491765-dccce02b29df?w=800&q=80',
    description: 'Our school counselor supports student wellbeing, social-emotional learning, and academic guidance. Drop-ins welcome.',
    directions: [
      'Enter through the main front entrance.',
      'Turn right at the lobby past the Main Office.',
      "The Counselor's Office is at the end of the short hallway on your right.",
    ],
  ),

  // ── Library ────────────────────────────────────────────────────
  RoomEntry(
    name: 'library',
    label: 'Library',
    x: 0.14, y: 0.14,
    rw: 0.18, rh: 0.14,
    zone: RoomZone.library,
    photoUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800&q=80',
    description: 'A welcoming space for reading, research, and quiet study. Houses over 12,000 volumes and provides access to digital resources and e-books.',
    directions: [
      'Enter through the main front entrance.',
      'Turn left and walk down the west corridor.',
      'The Library is at the end of the corridor — you will see the large glass doors.',
    ],
  ),

  // ── Gymnasium ──────────────────────────────────────────────────
  RoomEntry(
    name: 'gymnasium',
    label: 'Gymnasium',
    x: 0.84, y: 0.20,
    rw: 0.20, rh: 0.22,
    zone: RoomZone.athletics,
    photoUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80',
    description: 'Full-size gymnasium used for Physical Education, basketball, volleyball, and school assemblies. Bleacher seating for 300.',
    directions: [
      'Enter through the main front entrance.',
      'Turn right and walk to the end of the main hallway.',
      'Go through the double doors at the end.',
      'The Gymnasium entrance is immediately on your left.',
    ],
  ),

  // ── Classrooms — Left Wing ─────────────────────────────────────
  RoomEntry(
    name: 'room 101',
    label: 'Room 101',
    x: 0.14, y: 0.35,
    rw: 0.10, rh: 0.08,
    zone: RoomZone.classroom,
    photoUrl: 'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=800&q=80',
    description: 'Grades 1–2 homeroom classroom. Features flexible seating, reading corners, and a SmartBoard for interactive lessons.',
    directions: [
      'Enter through the main entrance and turn left.',
      'Walk down the west wing corridor.',
      'Room 101 is the first classroom on your right after the Library.',
    ],
  ),
  RoomEntry(
    name: 'room 102',
    label: 'Room 102',
    x: 0.14, y: 0.44,
    rw: 0.10, rh: 0.08,
    zone: RoomZone.classroom,
    photoUrl: 'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=800&q=80',
    description: 'Grades 2–3 homeroom classroom. Collaborative group tables and a dedicated reading nook.',
    directions: [
      'Enter through the main entrance and turn left.',
      'Walk down the west wing corridor.',
      'Room 102 is the second classroom on your right, directly below Room 101.',
    ],
  ),
  RoomEntry(
    name: 'room 103',
    label: 'Room 103',
    x: 0.22, y: 0.35,
    rw: 0.10, rh: 0.08,
    zone: RoomZone.classroom,
    photoUrl: 'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=800&q=80',
    description: 'Grades 3–4 homeroom classroom. Features a project wall and student gallery display area.',
    directions: [
      'Enter through the main entrance and turn left.',
      'Walk down the west wing corridor.',
      'Room 103 is across the hall from Room 101.',
    ],
  ),
  RoomEntry(
    name: 'room 104',
    label: 'Room 104',
    x: 0.22, y: 0.44,
    rw: 0.10, rh: 0.08,
    zone: RoomZone.classroom,
    photoUrl: 'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=800&q=80',
    description: 'Grades 4–5 homeroom classroom. Equipped with individual Chromebooks and a maker-space corner.',
    directions: [
      'Enter through the main entrance and turn left.',
      'Walk down the west wing corridor.',
      'Room 104 is across from Room 102, at the south end of the wing.',
    ],
  ),

  // ── Science & Tech ─────────────────────────────────────────────
  RoomEntry(
    name: 'science lab',
    label: 'Science Lab',
    x: 0.50, y: 0.38,
    rw: 0.12, rh: 0.09,
    zone: RoomZone.science,
    photoUrl: 'https://images.unsplash.com/photo-1532094349884-543559373f5a?w=800&q=80',
    description: 'Fully equipped laboratory for hands-on science experiments for grades 5–8. Features lab benches, safety equipment, and specimen collections.',
    directions: [
      'Enter through the main entrance.',
      'Walk straight and continue past the Main Office.',
      'Turn left at the central hallway junction.',
      'The Science Lab is midway down the hall on your left.',
    ],
  ),
  RoomEntry(
    name: 'computer lab',
    label: 'Computer Lab',
    x: 0.50, y: 0.45,
    rw: 0.12, rh: 0.08,
    zone: RoomZone.science,
    photoUrl: 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800&q=80',
    description: '30-station computer lab with high-speed internet, coding software, and 3D printing access. Available for class sessions and open lab periods.',
    directions: [
      'Enter through the main entrance.',
      'Walk straight past the Main Office.',
      'Turn left at the central hallway junction.',
      'The Computer Lab is directly below the Science Lab.',
    ],
  ),

  // ── Classrooms — Right Wing ────────────────────────────────────
  RoomEntry(
    name: 'room 201',
    label: 'Room 201',
    x: 0.76, y: 0.35,
    rw: 0.10, rh: 0.08,
    zone: RoomZone.classroom,
    photoUrl: 'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=800&q=80',
    description: 'Grades 5–6 homeroom classroom. Large windows, collaborative seating, and a presentation stage area.',
    directions: [
      'Enter through the main entrance and turn right.',
      'Walk to the end of the east hallway.',
      'Room 201 is the first classroom on your left.',
    ],
  ),
  RoomEntry(
    name: 'room 202',
    label: 'Room 202',
    x: 0.76, y: 0.44,
    rw: 0.10, rh: 0.08,
    zone: RoomZone.classroom,
    photoUrl: 'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=800&q=80',
    description: 'Grades 6–7 homeroom. Flexible furniture configuration supports both individual and group learning modes.',
    directions: [
      'Enter through the main entrance and turn right.',
      'Walk to the end of the east hallway.',
      'Room 202 is the second classroom on your left, below Room 201.',
    ],
  ),
  RoomEntry(
    name: 'room 203',
    label: 'Room 203',
    x: 0.84, y: 0.44,
    rw: 0.10, rh: 0.08,
    zone: RoomZone.classroom,
    photoUrl: 'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=800&q=80',
    description: 'Grades 7–8 homeroom and math specialist room. Features a mathematics resource wall and graphing tools.',
    directions: [
      'Enter through the main entrance and turn right.',
      'Walk past the Gymnasium entrance.',
      'Room 203 is at the far end of the east wing on your left.',
    ],
  ),

  // ── Arts Wing ──────────────────────────────────────────────────
  RoomEntry(
    name: 'art room',
    label: 'Art Room',
    x: 0.84, y: 0.64,
    rw: 0.14, rh: 0.10,
    zone: RoomZone.arts,
    photoUrl: 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=800&q=80',
    description: 'A vibrant studio space for drawing, painting, sculpture, ceramics, and mixed media. Student artwork is displayed throughout the school.',
    directions: [
      'Enter through the main entrance and turn right.',
      'Walk through the east hallway past the Gymnasium.',
      'Continue through the connecting door to the Arts Wing.',
      'The Art Room is on your right.',
    ],
  ),
  RoomEntry(
    name: 'music room',
    label: 'Music Room',
    x: 0.84, y: 0.75,
    rw: 0.14, rh: 0.10,
    zone: RoomZone.arts,
    photoUrl: 'https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=800&q=80',
    description: 'Acoustically treated music room for band, choir, and individual instrument instruction. Houses a full set of percussion, string, and wind instruments.',
    directions: [
      'Enter through the main entrance and turn right.',
      'Walk through the east hallway past the Gymnasium.',
      'Continue through the Arts Wing connecting door.',
      'The Music Room is at the end of the Arts Wing, just past the Art Room.',
    ],
  ),

  // ── Dining ─────────────────────────────────────────────────────
  RoomEntry(
    name: 'cafeteria',
    label: 'Cafeteria',
    x: 0.50, y: 0.68,
    rw: 0.18, rh: 0.12,
    zone: RoomZone.dining,
    photoUrl: 'https://images.unsplash.com/photo-1567521464027-f127ff144326?w=800&q=80',
    description: 'Bright, open cafeteria serving hot lunch daily. Features a salad bar, allergen-free zone, and outdoor patio seating. Open 7:30 AM–3:30 PM.',
    directions: [
      'From the main entrance, walk straight through the building.',
      'Exit through the rear double doors into the central quad.',
      'The Cafeteria is the large building directly across the quad.',
    ],
  ),

  // ── Performing Arts ────────────────────────────────────────────
  RoomEntry(
    name: 'auditorium',
    label: 'Auditorium',
    x: 0.16, y: 0.72,
    rw: 0.20, rh: 0.16,
    zone: RoomZone.performing,
    photoUrl: 'https://images.unsplash.com/photo-1549421263-5ec394a5ad4c?w=800&q=80',
    description: 'A 450-seat performing arts auditorium with professional stage lighting and sound. Home to school plays, ceremonies, and all-school assemblies.',
    directions: [
      'From the main entrance, walk down the west corridor.',
      'Pass the Library and continue to the rear of the building.',
      'Exit through the south doors into the quad.',
      'The Auditorium is the large building on your left with the double glass doors.',
    ],
  ),
];

List<RoomEntry> searchRooms(String query) {
  if (query.trim().isEmpty) return [];
  final q = query.toLowerCase().trim();
  return kRooms
      .where((r) => r.name.contains(q) || r.label.toLowerCase().contains(q))
      .toList();
}
