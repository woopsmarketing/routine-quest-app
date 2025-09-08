// 🔔 웹 전용 알림 서비스
// 브라우저 네이티브 알림 API를 사용하여 웹에서 알림을 구현하는 서비스
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'notification_settings_service.dart';

class WebNotificationService {
  static bool _isInitialized = false;
  static bool _hasPermission = false;

  // 웹 알림 서비스 초기화
  static Future<void> initialize() async {
    if (!kIsWeb) {
      print('⚠️ WebNotificationService는 웹 플랫폼에서만 사용할 수 있습니다.');
      return;
    }

    if (_isInitialized) return;

    try {
      // 브라우저가 알림을 지원하는지 확인
      if (!html.Notification.supported) {
        print('❌ 이 브라우저는 알림을 지원하지 않습니다.');
        _isInitialized = true;
        return;
      }

      // 알림 권한 확인 및 요청
      await _requestPermission();

      _isInitialized = true;
      print('🔔 웹 알림 서비스 초기화 완료 (권한: ${_hasPermission ? "허용" : "거부"})');
    } catch (e) {
      print('❌ 웹 알림 서비스 초기화 오류: $e');
      _isInitialized = true; // 오류가 발생해도 초기화 완료로 처리
    }
  }

  // 알림 권한 요청
  static Future<void> _requestPermission() async {
    if (!kIsWeb) return;

    try {
      final currentPermission = html.Notification.permission;
      print('🔔 현재 알림 권한: $currentPermission');

      if (currentPermission == 'granted') {
        _hasPermission = true;
        return;
      }

      if (currentPermission == 'denied') {
        _hasPermission = false;
        print('❌ 알림 권한이 거부되었습니다. 브라우저 설정에서 수동으로 허용해주세요.');
        return;
      }

      // 권한이 'default' 상태인 경우 요청
      if (currentPermission == 'default') {
        print('🔔 알림 권한을 요청합니다...');
        final permission = await html.Notification.requestPermission();
        _hasPermission = (permission == 'granted');
        print('🔔 알림 권한 결과: $permission');
      }
    } catch (e) {
      print('❌ 알림 권한 요청 오류: $e');
      _hasPermission = false;
    }
  }

  // 권한 상태 확인
  static bool get hasPermission => _hasPermission;

  // 권한 수동 재요청
  static Future<bool> requestPermission() async {
    if (!kIsWeb) return false;

    await _requestPermission();
    return _hasPermission;
  }

  // 즉시 알림 표시 (테스트용)
  static Future<void> showTestNotification() async {
    if (!kIsWeb) {
      print('⚠️ 웹이 아닌 환경에서는 WebNotificationService를 사용할 수 없습니다.');
      return;
    }

    if (!_hasPermission) {
      print('❌ 알림 권한이 없습니다. 권한을 먼저 허용해주세요.');
      throw Exception('알림 권한이 필요합니다.');
    }

    try {
      final notification = html.Notification(
        '🔔 루틴 퀘스트',
        body: '웹 알림 기능이 정상적으로 작동합니다!',
        icon: '/favicon.png',
        tag: 'test_notification',
      );

      // 3초 후 자동으로 닫기
      Future.delayed(const Duration(seconds: 3), () {
        notification.close();
      });

      print('🔔 웹 테스트 알림 표시 완료');
    } catch (e) {
      print('❌ 웹 알림 표시 오류: $e');
      throw Exception('알림 표시에 실패했습니다: $e');
    }
  }

  // 루틴 완료 알림 표시
  static Future<void> showRoutineCompleteNotification({
    required String routineName,
    required int experienceGained,
  }) async {
    final settings = NotificationSettingsService.currentSettings;
    if (!settings.isNotificationEnabled ||
        !settings.routineCompleteNotification) {
      return;
    }

    if (!kIsWeb || !_hasPermission) return;

    try {
      final notification = html.Notification(
        '🎉 루틴 완료!',
        body: '$routineName을 완료했습니다! +$experienceGained EXP',
        icon: '/favicon.png',
        tag: 'routine_complete',
      );

      // 5초 후 자동으로 닫기
      Future.delayed(const Duration(seconds: 5), () {
        notification.close();
      });

      print('🔔 루틴 완료 웹 알림 표시: $routineName');
    } catch (e) {
      print('❌ 루틴 완료 웹 알림 오류: $e');
    }
  }

  // 연속 달성 알림 표시
  static Future<void> showStreakNotification({
    required int streakDays,
  }) async {
    final settings = NotificationSettingsService.currentSettings;
    if (!settings.isNotificationEnabled || !settings.streakNotification) {
      return;
    }

    if (!kIsWeb || !_hasPermission) return;

    try {
      final notification = html.Notification(
        '🔥 연속 달성!',
        body: '${streakDays}일 연속으로 루틴을 달성했습니다!',
        icon: '/favicon.png',
        tag: 'streak_notification',
      );

      Future.delayed(const Duration(seconds: 5), () {
        notification.close();
      });

      print('🔔 연속 달성 웹 알림 표시: ${streakDays}일');
    } catch (e) {
      print('❌ 연속 달성 웹 알림 오류: $e');
    }
  }

  // 레벨업 알림 표시
  static Future<void> showLevelUpNotification({
    required int newLevel,
    required String levelTitle,
  }) async {
    final settings = NotificationSettingsService.currentSettings;
    if (!settings.isNotificationEnabled || !settings.levelUpNotification) {
      return;
    }

    if (!kIsWeb || !_hasPermission) return;

    try {
      final notification = html.Notification(
        '⭐ 레벨업!',
        body: '레벨 $newLevel 달성! $levelTitle',
        icon: '/favicon.png',
        tag: 'level_up',
      );

      Future.delayed(const Duration(seconds: 5), () {
        notification.close();
      });

      print('🔔 레벨업 웹 알림 표시: 레벨 $newLevel');
    } catch (e) {
      print('❌ 레벨업 웹 알림 오류: $e');
    }
  }

  // 목표 달성 알림 표시
  static Future<void> showGoalAchievementNotification({
    required String goalType,
    required int achieved,
    required int target,
  }) async {
    final settings = NotificationSettingsService.currentSettings;
    if (!settings.isNotificationEnabled ||
        !settings.goalAchievementNotification) {
      return;
    }

    if (!kIsWeb || !_hasPermission) return;

    try {
      final notification = html.Notification(
        '🎯 목표 달성!',
        body: '$goalType 목표를 달성했습니다! ($achieved/$target)',
        icon: '/favicon.png',
        tag: 'goal_achievement',
      );

      Future.delayed(const Duration(seconds: 5), () {
        notification.close();
      });

      print('🔔 목표 달성 웹 알림 표시: $goalType');
    } catch (e) {
      print('❌ 목표 달성 웹 알림 오류: $e');
    }
  }

  // 동기부여 알림 표시
  static Future<void> showMotivationNotification() async {
    final settings = NotificationSettingsService.currentSettings;
    if (!settings.isNotificationEnabled || !settings.motivationNotification) {
      return;
    }

    if (!kIsWeb || !_hasPermission) return;

    try {
      // 동기부여 메시지 목록
      final motivationMessages = [
        '💪 오늘도 화이팅! 작은 실천이 큰 변화를 만듭니다.',
        '🌟 당신의 노력이 빛나고 있어요! 계속해서 도전해보세요.',
        '🎯 목표를 향해 한 걸음씩 나아가고 있습니다. 멋져요!',
        '🔥 루틴의 힘을 믿어보세요. 당신은 할 수 있습니다!',
        '⭐ 매일의 작은 성취가 모여 큰 성공을 만듭니다.',
      ];

      final randomMessage =
          motivationMessages[DateTime.now().day % motivationMessages.length];

      final notification = html.Notification(
        '💝 응원 메시지',
        body: randomMessage,
        icon: '/favicon.png',
        tag: 'motivation',
      );

      Future.delayed(const Duration(seconds: 7), () {
        notification.close();
      });

      print('🔔 동기부여 웹 알림 표시');
    } catch (e) {
      print('❌ 동기부여 웹 알림 오류: $e');
    }
  }

  // 웹에서는 예약된 알림 목록이 없으므로 빈 목록 반환
  static Future<List<Map<String, dynamic>>> getPendingNotifications() async {
    if (!kIsWeb) return [];

    // 웹에서는 브라우저 네이티브 알림이므로 예약된 알림 목록을 조회할 수 없음
    return [
      {
        'id': 0,
        'title': '웹 알림 정보',
        'body': '웹에서는 즉시 알림만 지원됩니다. 예약된 알림은 모바일 앱에서 사용할 수 있습니다.',
      }
    ];
  }

  // 웹에서는 예약된 알림이 없으므로 취소할 것이 없음
  static Future<void> cancelAllNotifications() async {
    if (!kIsWeb) return;

    print('🔔 웹에서는 예약된 알림이 없습니다. (즉시 알림만 지원)');
  }

  // 알림 설정 업데이트 (웹에서는 별도 처리 불필요)
  static Future<void> updateAllScheduledNotifications() async {
    if (!kIsWeb) return;

    print('🔔 웹에서는 알림 스케줄링이 지원되지 않습니다.');
  }

  // 브라우저 알림 지원 여부 확인
  static bool get isSupported => kIsWeb && html.Notification.supported;

  // 현재 권한 상태 문자열 반환
  static String get permissionStatus {
    if (!kIsWeb) return 'not_web';
    if (!html.Notification.supported) return 'not_supported';
    return html.Notification.permission ?? 'unknown';
  }
}
