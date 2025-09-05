// 🧪 Routine Quest 앱 위젯 테스트
// 기본적인 앱 로드 및 네비게이션 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../lib/core/app.dart';

void main() {
  testWidgets('앱이 정상적으로 로드되는지 테스트', (WidgetTester tester) async {
    // Riverpod과 함께 앱 빌드
    await tester.pumpWidget(
      const ProviderScope(
        child: RoutineQuestApp(),
      ),
    );

    // 앱이 정상적으로 로드되었는지 확인
    expect(find.byType(MaterialApp), findsOneWidget);

    // 첫 렌더링 완료까지 대기
    await tester.pumpAndSettle();
  });

  testWidgets('네비게이션 바가 표시되는지 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RoutineQuestApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 하단 네비게이션 바 확인
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
