// 📱 Flutter 앱의 진입점 (Entry Point)
// MVP 버전: Firebase 없이 로컬 데이터로 시작
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/app.dart';
import 'core/services/app_lifecycle_service.dart';
import 'core/services/background_timer_service.dart';

void main() async {
  // Flutter 프레임워크 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 로케일 데이터 초기화
  await initializeDateFormatting('ko_KR', null);

  // 백그라운드 타이머 상태 복원
  await BackgroundTimerService().restoreTimerState();

  // 앱 생명주기 서비스 초기화
  AppLifecycleService().initialize();

  // 앱 실행 - Riverpod 상태관리 래퍼로 감싸기
  runApp(
    const ProviderScope(
      child: RoutineQuestApp(),
    ),
  );
}
