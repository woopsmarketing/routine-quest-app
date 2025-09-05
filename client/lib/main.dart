// 📱 Flutter 앱의 진입점 (Entry Point)
// MVP 버전: Firebase 없이 로컬 데이터로 시작
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/app.dart';

void main() async {
  // Flutter 프레임워크 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 로케일 데이터 초기화
  await initializeDateFormatting('ko_KR', null);

  // 앱 실행 - Riverpod 상태관리 래퍼로 감싸기
  runApp(
    const ProviderScope(
      child: RoutineQuestApp(),
    ),
  );
}
