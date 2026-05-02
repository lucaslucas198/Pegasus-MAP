import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'room_data.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Map')),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            onChanged: _onSearch,
            suggestions: _suggestions,
            onSuggestionTap: _selectRoom,
          ),
          Expanded(
            child: _MapView(selected: _selected),
          ),
          if (_selected != null) _RoomBanner(room: _selected!),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search bar + autocomplete suggestions
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final List<RoomEntry> suggestions;
  final ValueChanged<RoomEntry> onSuggestionTap;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Search for a room…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
        ),
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: suggestions.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final room = suggestions[i];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(room.label),
                  onTap: () => onSuggestionTap(room),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Map canvas with optional room pin
// ---------------------------------------------------------------------------

class _MapView extends StatelessWidget {
  final RoomEntry? selected;
  const _MapView({this.selected});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 5.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(
            children: [
              // Placeholder map background — swap for Image.asset or SvgPicture
              // once the real floor plan is provided.
              _PlaceholderMap(width: w, height: h),
              if (selected != null)
                Positioned(
                  left: selected!.x * w - 16,
                  top: selected!.y * h - 36,
                  child: const _Pin(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PlaceholderMap extends StatelessWidget {
  final double width;
  final double height;
  const _PlaceholderMap({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    // Simple placeholder grid that resembles a floor plan.
    return CustomPaint(
      size: Size(width, height),
      painter: _FloorPlanPainter(),
    );
  }
}

class _FloorPlanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFEEEEEE);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final wall = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final room = Paint()..color = const Color(0xFFFFFFFF);

    // Outer boundary
    final outer = Rect.fromLTWH(20, 20, size.width - 40, size.height - 40);
    canvas.drawRect(outer, room);
    canvas.drawRect(outer, wall);

    // A few interior walls to give a floor-plan feel
    final midX = size.width / 2;
    final midY = size.height / 2;
    canvas.drawLine(Offset(midX, 20), Offset(midX, size.height - 20), wall);
    canvas.drawLine(Offset(20, midY), Offset(size.width - 20, midY), wall);

    // Label
    final tp = TextPainter(
      text: const TextSpan(
        text: 'Placeholder Floor Plan\n(Real map coming soon)',
        style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    tp.paint(canvas, Offset(midX - tp.width / 2, midY - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Pin extends StatelessWidget {
  const _Pin();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.location_pin, color: Colors.red, size: 32);
  }
}

// ---------------------------------------------------------------------------
// Bottom banner showing selected room name
// ---------------------------------------------------------------------------

class _RoomBanner extends StatelessWidget {
  final RoomEntry room;
  const _RoomBanner({required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            room.label,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
