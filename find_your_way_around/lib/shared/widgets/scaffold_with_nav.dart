import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

const _kNavTabs = [
  _NavTab(
    label: 'Home',
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    route: '/home',
  ),
  _NavTab(
    label: 'Campus Map',
    icon: Icons.map_outlined,
    activeIcon: Icons.map,
    route: '/map',
  ),
  _NavTab(
    label: 'Calendar',
    icon: Icons.calendar_month_outlined,
    activeIcon: Icons.calendar_month,
    route: '/calendar',
  ),
  _NavTab(
    label: 'Faculty',
    icon: Icons.people_outline,
    activeIcon: Icons.people,
    route: '/teachers',
  ),
];

class _NavTab {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  const _NavTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNav({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _kNavTabs.length; i++) {
      if (location.startsWith(_kNavTabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;
    final idx = _currentIndex(context);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            _SideNavBar(currentIndex: idx),
            Container(width: 1, color: AppColors.divider),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_kNavTabs[i].route),
        destinations: _kNavTabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon),
                  selectedIcon: Icon(t.activeIcon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}

class _SideNavBar extends StatelessWidget {
  final int currentIndex;
  const _SideNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 228,
      color: AppColors.navDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gold top accent bar
          Container(height: 4, color: AppColors.secondary),
          // School branding
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 54,
                  height: 54,
                ),
                const SizedBox(height: 14),
                Text(
                  'THE PEGASUS SCHOOL',
                  style: GoogleFonts.openSans(
                    color: AppColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Campus Navigator',
                  style: GoogleFonts.merriweather(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            height: 1,
            color: Colors.white.withAlpha(30),
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          const SizedBox(height: 10),
          // Nav items
          ...List.generate(_kNavTabs.length, (i) {
            final tab = _kNavTabs[i];
            final selected = i == currentIndex;
            return _SideNavItem(
              tab: tab,
              selected: selected,
              onTap: () => GoRouter.of(context).go(tab.route),
            );
          }),
        ],
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  final _NavTab tab;
  final bool selected;
  final VoidCallback onTap;
  const _SideNavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: selected ? Colors.white.withAlpha(28) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: selected
                  ? Border(
                      left: BorderSide(color: AppColors.secondary, width: 3),
                    )
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(
                  selected ? tab.activeIcon : tab.icon,
                  color: selected ? AppColors.secondary : Colors.white54,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  tab.label,
                  style: GoogleFonts.openSans(
                    color: selected ? Colors.white : Colors.white60,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
