# 🔔 자동 시작 기능 구현 가이드

## 현재 상태 vs 완전한 구현

### 📱 **현재 구현 (MVP 단계)**
- ✅ 설정 저장/불러오기
- ✅ UI 표시
- ❌ 실제 알림/자동 시작 없음

### 🚀 **완전한 구현 (서비스 단계)**

#### **1. 로컬 알림 (Local Notifications)**
```dart
// flutter_local_notifications 패키지 사용
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // 매일 반복 알림 설정
  static Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required List<int> weekdays, // 1=월요일, 7=일요일
  }) async {
    // 각 요일별로 알림 설정
    for (int weekday in weekdays) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id + weekday,
        title,
        body,
        _nextInstanceOfWeekday(weekday, time),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'routine_channel',
            'Routine Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }
}
```

#### **2. 백그라운드 처리**
```dart
// workmanager 패키지 사용
import 'package:workmanager/workmanager.dart';

class BackgroundTaskService {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }
  
  static Future<void> scheduleRoutineCheck() async {
    await Workmanager().registerPeriodicTask(
      "routine-check",
      "checkScheduledRoutines",
      frequency: Duration(minutes: 15), // 15분마다 체크
    );
  }
}

// 백그라운드 콜백
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // 예정된 루틴 체크 및 알림 발송
    await checkAndTriggerRoutines();
    return Future.value(true);
  });
}
```

#### **3. 서버 기반 푸시 알림**
```dart
// Firebase Cloud Messaging
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  // 서버에서 시간 기반 푸시 알림 발송
  static Future<void> scheduleServerNotification({
    required String userId,
    required int routineId,
    required DateTime scheduledTime,
  }) async {
    // 서버 API 호출
    await ApiClient.scheduleNotification({
      'user_id': userId,
      'routine_id': routineId,
      'scheduled_time': scheduledTime.toIso8601String(),
      'type': 'routine_reminder',
    });
  }
}
```

## 📊 **실제 서비스 앱들의 구현 방식**

### **습관 관리 앱들 (Habitica, Streaks, Way of Life)**
1. **로컬 알림**: 기본적인 시간 알림
2. **푸시 알림**: 서버에서 관리하는 스마트 알림
3. **백그라운드 동기화**: 오프라인 데이터 동기화
4. **위젯**: 홈화면 위젯으로 빠른 체크

### **피트니스 앱들 (Nike Training, Adidas Training)**
1. **적응형 알림**: 사용자 패턴 학습
2. **위치 기반**: GPS 기반 운동 알림
3. **소셜 알림**: 친구들과의 경쟁/격려
4. **웨어러블 연동**: Apple Watch, Galaxy Watch

## 🏗️ **단계별 구현 로드맵**

### **Phase 1: MVP (현재)**
- ✅ 설정 저장/불러오기
- ✅ UI 표시
- ✅ 기본 기능

### **Phase 2: 로컬 알림**
```bash
flutter pub add flutter_local_notifications
flutter pub add timezone
flutter pub add permission_handler
```

### **Phase 3: 백그라운드 처리**
```bash
flutter pub add workmanager
flutter pub add shared_preferences
```

### **Phase 4: 서버 연동**
```bash
flutter pub add firebase_messaging
flutter pub add firebase_core
```

### **Phase 5: 고급 기능**
- 스마트 알림 (사용자 패턴 학습)
- 위젯 지원
- 웨어러블 연동
- 소셜 기능

## 💡 **개발 우선순위 제안**

1. **지금**: 대시보드 완성 (사용자 경험 개선)
2. **다음**: 로컬 알림 구현 (기본 기능 완성)
3. **이후**: 서버 연동 (확장성)
4. **마지막**: 고급 기능 (차별화)

## 🎯 **현재 JSON 저장 방식의 적절성**

### **개발 단계에서는 적절함**
- 빠른 프로토타이핑
- 로컬 테스트 용이
- 복잡한 서버 설정 불필요

### **서비스 단계에서는 확장 필요**
- 사용자 계정 연동
- 클라우드 백업
- 다기기 동기화
- 분석 데이터 수집

현재 방식은 MVP로는 완벽하고, 추후 서버 연동 시에도 호환 가능한 구조입니다!
