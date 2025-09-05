// 🎯 메인 앱 위젯
// Material3 테마, 라우팅, 글로벌 설정을 담당하는 최상위 위젯
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/theme.dart';
import 'router/app_router.dart';

class RoutineQuestApp extends ConsumerWidget {
  const RoutineQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 라우터 인스턴스 가져오기
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      // 앱 기본 정보
      title: 'Routine Quest',
      debugShowCheckedModeBanner: false,

      // Material3 테마 적용
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // 시스템 설정 따라가기

      // 라우팅 설정
      routerConfig: router,

      // 국제화 설정 - 한국어로 설정
      locale: const Locale('ko', 'KR'), // 한국어로 설정

      // 디버그 관련 모든 배너 비활성화
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}
