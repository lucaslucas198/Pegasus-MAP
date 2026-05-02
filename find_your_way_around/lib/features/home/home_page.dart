import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _cards = [
    _CardData(
      icon: Icons.map_outlined,
      label: 'Campus Map',
      description: 'Find any room on campus',
      route: '/map',
      color: Color(0xFF1A3A6B),
    ),
    _CardData(
      icon: Icons.calendar_month_outlined,
      label: 'Calendar',
      description: 'Upcoming school events',
      route: '/calendar',
      color: Color(0xFF2E7D32),
    ),
    _CardData(
      icon: Icons.people_outline,
      label: 'Teachers',
      description: 'Faculty directory',
      route: '/teachers',
      color: Color(0xFF6A1B9A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: _cards
                      .map((c) => Expanded(child: _FeatureCard(data: c)))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Column(
        children: [
          // Placeholder logo — replace with Image.asset('assets/logo.png') once available
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 12),
          const Text(
            'The Pegasus School',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Find Your Way Around',
            style: TextStyle(color: Color(0xFFCFD8DC), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _CardData data;
  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go(data.route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: data.color.withAlpha(26),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(data.icon, color: data.color, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.label,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(data.description,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardData {
  final IconData icon;
  final String label;
  final String description;
  final String route;
  final Color color;

  const _CardData({
    required this.icon,
    required this.label,
    required this.description,
    required this.route,
    required this.color,
  });
}
