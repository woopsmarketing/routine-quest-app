// 🧭 앱 라우팅 설정
// Go Router를 사용한 선언적 라우팅
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/today/presentation/pages/today_page.dart';
import '../../features/routine/presentation/pages/routine_list_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';

// 🎯 라우터 프로바이더
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding', // 첫 실행 시 온보딩으로
    routes: [
      // 온보딩 화면
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // 로그인 화면
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      // 메인 화면들 (탭 네비게이션)
      ShellRoute(
        builder: (context, state, child) => MainNavigation(child: child),
        routes: [
          // 오늘 화면 (메인)
          GoRoute(
            path: '/',
            builder: (context, state) => const TodayPage(),
          ),

          // 루틴 목록
          GoRoute(
            path: '/routines',
            builder: (context, state) => const RoutineListPage(),
          ),

          // 대시보드
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),

          // 프로필
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
});

// 📱 메인 네비게이션 (하단 탭바)
class MainNavigation extends StatelessWidget {
  final Widget child;

  const MainNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today),
            label: '오늘',
          ),
          NavigationDestination(
            icon: Icon(Icons.list),
            label: '루틴',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: '대시보드',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/routines');
              break;
            case 2:
              context.go('/dashboard');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
        selectedIndex: _getSelectedIndex(context),
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == '/') return 0;
    if (location == '/routines') return 1;
    if (location == '/dashboard') return 2;
    if (location == '/profile') return 3;
    return 0;
  }
}
