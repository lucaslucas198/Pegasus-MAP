import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/home_page.dart';
import '../../features/map/map_page.dart';
import '../../features/calendar/calendar_page.dart';
import '../../features/teachers/teachers_page.dart';
import '../../features/teachers/teacher_detail_page.dart';
import '../../features/admin/admin_login_page.dart';
import '../../features/admin/admin_dashboard_page.dart';
import '../../shared/widgets/scaffold_with_nav.dart';
import '../../shared/models/teacher.dart';

final routerProvider = Provider<GoRouter>((ref) => _router);

final _router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithNav(child: child),
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/map',
          name: 'map',
          builder: (context, state) => const MapPage(),
        ),
        GoRoute(
          path: '/calendar',
          name: 'calendar',
          builder: (context, state) => const CalendarPage(),
        ),
        GoRoute(
          path: '/teachers',
          name: 'teachers',
          builder: (context, state) => const TeachersPage(),
          routes: [
            GoRoute(
              path: ':id',
              name: 'teacher-detail',
              builder: (context, state) {
                final teacher = state.extra as Teacher;
                return TeacherDetailPage(teacher: teacher);
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/admin',
      name: 'admin-login',
      builder: (context, state) => const AdminLoginPage(),
    ),
    GoRoute(
      path: '/admin/dashboard',
      name: 'admin-dashboard',
      builder: (context, state) => const AdminDashboardPage(),
    ),
  ],
);
