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
import '../../features/today/data/providers/routine_state_provider.dart';

// 🎯 라우터 프로바이더
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding', // 첫 실행 시 온보딩으로
    redirect: (context, state) {
      // 루틴 진행 중인지 확인
      final routineState = ref.read(routineProgressProvider);
      if (routineState.isRoutineStarted && !routineState.isCompleted) {
        // 루틴 진행 중이면 오늘 페이지로 리다이렉트
        if (state.uri.path != '/') {
          return '/';
        }
      }
      return null; // 리다이렉트 없음
    },
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
class MainNavigation extends ConsumerWidget {
  final Widget child;

  const MainNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 루틴 진행 상태 확인
    final routineState = ref.watch(routineProgressProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.today),
            label: '오늘',
          ),
          NavigationDestination(
            icon: Stack(
              children: [
                const Icon(Icons.list),
                if (routineState.isRoutineStarted && !routineState.isCompleted)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            label: '루틴',
          ),
          NavigationDestination(
            icon: Stack(
              children: [
                const Icon(Icons.dashboard),
                if (routineState.isRoutineStarted && !routineState.isCompleted)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            label: '대시보드',
          ),
          NavigationDestination(
            icon: Stack(
              children: [
                const Icon(Icons.person),
                if (routineState.isRoutineStarted && !routineState.isCompleted)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            label: '프로필',
          ),
        ],
        onDestinationSelected: (index) {
          // 루틴 진행 중인지 확인
          final routineState = ref.read(routineProgressProvider);
          if (routineState.isRoutineStarted && !routineState.isCompleted) {
            // 루틴 진행 중이면 오늘 페이지로만 이동 가능
            if (index != 0) {
              // 다른 탭 클릭 시 경고 메시지 표시
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('루틴 진행 중에는 다른 페이지로 이동할 수 없습니다'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
          }

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
