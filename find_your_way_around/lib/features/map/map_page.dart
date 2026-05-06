import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'room_data.dart';

// Canvas dimensions — InteractiveViewer will let users pan/zoom
const _kCanvasW = 1000.0;
const _kCanvasH = 760.0;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _searchController = TextEditingController();
  RoomEntry? _selected;
  List<RoomEntry> _suggestions = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _suggestions = searchRooms(query);
      if (_suggestions.length == 1) {
        _selected = _suggestions.first;
        _suggestions = [];
      } else if (query.trim().isEmpty) {
        _selected = null;
      }
    });
  }

  void _selectRoom(RoomEntry room) {
    setState(() {
      _selected = room;
      _suggestions = [];
      _searchController.text = room.label;
    });
    FocusScope.of(context).unfocus();
    _showRoomDetail(room);
  }

  void _showRoomDetail(RoomEntry room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RoomDetailSheet(room: room),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: AppColors.secondary),
        ),
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            onChanged: _onSearch,
            suggestions: _suggestions,
            onSuggestionTap: _selectRoom,
            onClear: () {
              _searchController.clear();
              _onSearch('');
            },
          ),
          Expanded(
            child: InteractiveViewer(
              minScale: 0.3,
              maxScale: 6.0,
              constrained: false,
              child: SizedBox(
                width: _kCanvasW,
                height: _kCanvasH,
                child: Stack(
                  children: [
                    // Ground & paths (non-interactive painter)
                    const Positioned.fill(
                      child: CustomPaint(painter: _BackgroundPainter()),
                    ),
                    // Rooms (interactive widgets)
                    ...kRooms.map((room) => _RoomWidget(
                          room: room,
                          isSelected: _selected?.name == room.name,
                          onTap: () {
                            setState(() => _selected = room);
                            _showRoomDetail(room);
                          },
                        )),
                    // Overlay: compass, legend, title (non-interactive)
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(painter: _OverlayPainter()),
                      ),
                    ),
                    // Hint text
                    if (_selected == null)
                      const Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: _HintBadge(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search bar
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final List<RoomEntry> suggestions;
  final ValueChanged<RoomEntry> onSuggestionTap;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.suggestions,
    required this.onSuggestionTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Search for a room or building…',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 22),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: onClear,
                    )
                  : null,
            ),
          ),
        ),
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
              boxShadow: const [
                BoxShadow(color: AppColors.cardShadow, blurRadius: 10)
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: suggestions.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, indent: 52),
              itemBuilder: (context, i) {
                final room = suggestions[i];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: _zoneBorder(room.zone).withAlpha(30),
                    child: Icon(_zoneIcon(room.zone),
                        color: _zoneBorder(room.zone), size: 16),
                  ),
                  title: Text(room.label,
                      style: GoogleFonts.openSans(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Text(_zoneLabel(room.zone),
                      style: GoogleFonts.openSans(
                          fontSize: 11, color: AppColors.subtleText)),
                  onTap: () => onSuggestionTap(room),
                );
              },
            ),
          ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Background painter — ground, paths, grass, sports field
// ---------------------------------------------------------------------------

class _BackgroundPainter extends CustomPainter {
  const _BackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const w = _kCanvasW;
    const h = _kCanvasH;

    // Ground
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h),
        Paint()..color = const Color(0xFFEDE8E0));

    // Walkway — horizontal central corridor
    canvas.drawRect(Rect.fromLTWH(0, h * 0.50, w, h * 0.055),
        Paint()..color = const Color(0xFFD4CFC7));

    // Walkway — vertical left
    canvas.drawRect(Rect.fromLTWH(w * 0.275, 0, w * 0.045, h * 0.555),
        Paint()..color = const Color(0xFFD4CFC7));

    // Walkway — vertical right
    canvas.drawRect(Rect.fromLTWH(w * 0.68, 0, w * 0.045, h * 0.555),
        Paint()..color = const Color(0xFFD4CFC7));

    // Walkway — bottom horizontal
    canvas.drawRect(Rect.fromLTWH(0, h * 0.78, w, h * 0.04),
        Paint()..color = const Color(0xFFD4CFC7));

    // Courtyard / central green
    final courtyard = Rect.fromLTWH(w * 0.32, h * 0.27, w * 0.36, h * 0.23);
    canvas.drawRRect(
      RRect.fromRectAndRadius(courtyard, const Radius.circular(8)),
      Paint()..color = const Color(0xFFC8E6C9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(courtyard, const Radius.circular(8)),
      Paint()
        ..color = const Color(0xFF81C784)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _text(canvas, 'Courtyard', courtyard.center, 11, const Color(0xFF388E3C),
        italic: true);

    // Sports field — bottom left
    final field =
        Rect.fromLTWH(w * 0.04, h * 0.555, w * 0.22, h * 0.21);
    canvas.drawRRect(
      RRect.fromRectAndRadius(field, const Radius.circular(8)),
      Paint()..color = const Color(0xFFBBDFBB),
    );
    // Field stripes
    for (var i = 1; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
            field.left + field.width * i / 4 - 0.5, field.top, 1, field.height),
        Paint()..color = const Color(0xFF81C784).withAlpha(100),
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(field, const Radius.circular(8)),
      Paint()
        ..color = const Color(0xFF66BB6A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _text(canvas, 'Sports Field', field.center, 11, const Color(0xFF2E7D32),
        italic: true);

    // Entrance arrow indicator at top center
    _drawEntrance(canvas, Offset(w * 0.5, 6));
  }

  void _drawEntrance(Canvas canvas, Offset pos) {
    final paint = Paint()..color = AppColors.secondary;
    final path = Path()
      ..moveTo(pos.dx - 16, pos.dy)
      ..lineTo(pos.dx + 16, pos.dy)
      ..lineTo(pos.dx + 16, pos.dy + 14)
      ..lineTo(pos.dx + 24, pos.dy + 14)
      ..lineTo(pos.dx, pos.dy + 30)
      ..lineTo(pos.dx - 24, pos.dy + 14)
      ..lineTo(pos.dx - 16, pos.dy + 14)
      ..close();
    canvas.drawPath(path, paint);
    _text(canvas, 'ENTRANCE', Offset(pos.dx, pos.dy + 38), 9,
        AppColors.primary);
  }

  void _text(Canvas canvas, String s, Offset center, double size, Color color,
      {bool italic = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w700,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 120);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ---------------------------------------------------------------------------
// Overlay painter — compass, legend, title
// ---------------------------------------------------------------------------

class _OverlayPainter extends CustomPainter {
  const _OverlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const w = _kCanvasW;
    const h = _kCanvasH;
    _drawTitle(canvas);
    _drawCompass(canvas, w - 52, 58);
    _drawLegend(canvas, w, h);
  }

  void _drawTitle(Canvas canvas) {
    final tp = TextPainter(
      text: const TextSpan(
        text: 'THE PEGASUS SCHOOL — CAMPUS MAP',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 8, tp.width + 20, tp.height + 12),
        const Radius.circular(6),
      ),
      Paint()..color = Colors.white.withAlpha(230),
    );
    tp.paint(canvas, const Offset(18, 14));
  }

  void _drawCompass(Canvas canvas, double cx, double cy) {
    const r = 22.0;
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = Colors.white.withAlpha(230));
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = const Color(0xFFBBBBBB)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    final north = Path()
      ..moveTo(cx, cy - r + 5)
      ..lineTo(cx - 5, cy + 2)
      ..lineTo(cx + 5, cy + 2)
      ..close();
    canvas.drawPath(north, Paint()..color = const Color(0xFFD32F2F));

    final south = Path()
      ..moveTo(cx, cy + r - 5)
      ..lineTo(cx - 5, cy - 2)
      ..lineTo(cx + 5, cy - 2)
      ..close();
    canvas.drawPath(
        south, Paint()..color = const Color(0xFFBBBBBB).withAlpha(160));

    final tp = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(
            color: Color(0xFFD32F2F),
            fontSize: 10,
            fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - r - 14));
  }

  void _drawLegend(Canvas canvas, double w, double h) {
    const zones = RoomZone.values;
    const itemH = 20.0;
    const pad = 10.0;
    const swatchW = 14.0;
    final legendH = zones.length * itemH + pad * 2 + 18;
    const legendW = 160.0;
    final left = w - legendW - 10;
    final top = h - legendH - 10;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, legendW, legendH),
          const Radius.circular(8)),
      Paint()..color = Colors.white.withAlpha(230),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, legendW, legendH),
          const Radius.circular(8)),
      Paint()
        ..color = const Color(0xFFCCCCCC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Legend header
    final hdr = TextPainter(
      text: const TextSpan(
        text: 'LEGEND',
        style: TextStyle(
            color: AppColors.primary,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    hdr.paint(canvas,
        Offset(left + legendW / 2 - hdr.width / 2, top + pad - 2));

    for (var i = 0; i < zones.length; i++) {
      final z = zones[i];
      final y = top + pad + 16 + i * itemH;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(left + pad, y + 3, swatchW, swatchW),
            const Radius.circular(3)),
        Paint()..color = _zoneFill(z),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(left + pad, y + 3, swatchW, swatchW),
            const Radius.circular(3)),
        Paint()
          ..color = _zoneBorder(z)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      final lbl = TextPainter(
        text: TextSpan(
          text: _zoneLabel(z),
          style: const TextStyle(
              color: Color(0xFF333333), fontSize: 9.5, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      lbl.paint(
          canvas, Offset(left + pad + swatchW + 7, y + 3));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ---------------------------------------------------------------------------
// Room widget — interactive, animated, tappable
// ---------------------------------------------------------------------------

class _RoomWidget extends StatelessWidget {
  final RoomEntry room;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoomWidget({
    required this.room,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final left = room.x * _kCanvasW - (room.rw * _kCanvasW) / 2;
    final top = room.y * _kCanvasH - (room.rh * _kCanvasH) / 2;
    final w = room.rw * _kCanvasW;
    final h = room.rh * _kCanvasH;

    return Positioned(
      left: left,
      top: top,
      width: w,
      height: h,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [
                      _zoneFill(room.zone),
                      _zoneBorder(room.zone).withAlpha(60),
                    ]
                  : [
                      _zoneFill(room.zone),
                      _zoneFill(room.zone),
                    ],
            ),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? AppColors.primary : _zoneBorder(room.zone),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(80),
                      blurRadius: 16,
                      spreadRadius: 2,
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 4,
                      offset: const Offset(1, 2),
                    )
                  ],
          ),
          child: Stack(
            children: [
              // Selected overlay
              if (isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: AppColors.primary.withAlpha(10),
                    ),
                  ),
                ),
              // Label
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    room.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : _zoneBorder(room.zone).withAlpha(220),
                      fontSize: _fontSize(room),
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              // Pin icon when selected
              if (isSelected)
                const Positioned(
                  top: 2,
                  right: 4,
                  child: Icon(Icons.location_pin,
                      color: AppColors.primary, size: 14),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _fontSize(RoomEntry r) {
    final area = r.rw * r.rh;
    if (area > 0.025) return 12;
    if (area > 0.015) return 10;
    if (area > 0.008) return 8.5;
    return 7.5;
  }
}

class _HintBadge extends StatelessWidget {
  const _HintBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(25), blurRadius: 8)
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app,
                size: 16, color: AppColors.primary.withAlpha(180)),
            const SizedBox(width: 6),
            Text(
              'Tap any room to see details & directions',
              style: GoogleFonts.openSans(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Room detail bottom sheet
// ---------------------------------------------------------------------------

class _RoomDetailSheet extends StatelessWidget {
  final RoomEntry room;
  const _RoomDetailSheet({required this.room});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.58,
      minChildSize: 0.38,
      maxChildSize: 0.88,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Photo header with gradient overlay
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: room.photoUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        height: 180,
                        color: _zoneFill(room.zone),
                        child: Center(
                          child: Icon(_zoneIcon(room.zone),
                              color: _zoneBorder(room.zone), size: 48),
                        ),
                      ),
                      errorWidget: (_, _, _) => Container(
                        height: 180,
                        color: _zoneFill(room.zone),
                        child: Center(
                          child: Icon(_zoneIcon(room.zone),
                              color: _zoneBorder(room.zone), size: 48),
                        ),
                      ),
                    ),
                    // Gradient overlay on photo
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(180),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Room name + zone badge over photo
                    Positioned(
                      bottom: 12,
                      left: 16,
                      right: 16,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              room.label,
                              style: GoogleFonts.merriweather(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _zoneBorder(room.zone),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_zoneIcon(room.zone),
                                    color: Colors.white, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  _zoneLabel(room.zone),
                                  style: GoogleFonts.openSans(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Scrollable content
            Expanded(
              child: ListView(
                controller: controller,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Description
                  Text(
                    room.description,
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: AppColors.onBackground,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Directions section
                  Row(
                    children: [
                      const Icon(Icons.directions_walk,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Directions from Main Entrance',
                        style: GoogleFonts.merriweather(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 12),
                    height: 2,
                    color: AppColors.secondary,
                  ),
                  ...room.directions.asMap().entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${e.key + 1}',
                                    style: GoogleFonts.openSans(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    e.value,
                                    style: GoogleFonts.openSans(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: AppColors.onBackground,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Zone helpers (shared between painter and widgets)
// ---------------------------------------------------------------------------

Color _zoneFill(RoomZone z) {
  switch (z) {
    case RoomZone.admin:
      return const Color(0xFFFFF8DC);
    case RoomZone.classroom:
      return const Color(0xFFE3F2FD);
    case RoomZone.science:
      return const Color(0xFFF3E5F5);
    case RoomZone.arts:
      return const Color(0xFFFCE4EC);
    case RoomZone.athletics:
      return const Color(0xFFE8F5E9);
    case RoomZone.dining:
      return const Color(0xFFFFF3E0);
    case RoomZone.performing:
      return const Color(0xFFE0F7FA);
    case RoomZone.library:
      return const Color(0xFFFFFDE7);
  }
}

Color _zoneBorder(RoomZone z) {
  switch (z) {
    case RoomZone.admin:
      return const Color(0xFFF9A825);
    case RoomZone.classroom:
      return const Color(0xFF1565C0);
    case RoomZone.science:
      return const Color(0xFF6A1B9A);
    case RoomZone.arts:
      return const Color(0xFFC62828);
    case RoomZone.athletics:
      return const Color(0xFF2E7D32);
    case RoomZone.dining:
      return const Color(0xFFE65100);
    case RoomZone.performing:
      return const Color(0xFF00838F);
    case RoomZone.library:
      return const Color(0xFFF57F17);
  }
}

String _zoneLabel(RoomZone z) {
  switch (z) {
    case RoomZone.admin:
      return 'Administration';
    case RoomZone.classroom:
      return 'Classroom';
    case RoomZone.science:
      return 'Science & Tech';
    case RoomZone.arts:
      return 'Visual Arts';
    case RoomZone.athletics:
      return 'Athletics';
    case RoomZone.dining:
      return 'Dining';
    case RoomZone.performing:
      return 'Performing Arts';
    case RoomZone.library:
      return 'Library';
  }
}

IconData _zoneIcon(RoomZone z) {
  switch (z) {
    case RoomZone.admin:
      return Icons.business;
    case RoomZone.classroom:
      return Icons.school;
    case RoomZone.science:
      return Icons.science;
    case RoomZone.arts:
      return Icons.palette;
    case RoomZone.athletics:
      return Icons.sports_basketball;
    case RoomZone.dining:
      return Icons.restaurant;
    case RoomZone.performing:
      return Icons.theater_comedy;
    case RoomZone.library:
      return Icons.menu_book;
  }
}
