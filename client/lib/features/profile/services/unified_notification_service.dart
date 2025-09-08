// 🔔 통합 알림 서비스
// 웹과 모바일을 자동으로 감지하여 적절한 알림 시스템을 사용하는 서비스
import 'package:flutter/foundation.dart';
import 'web_notification_service.dart';
import 'real_notification_service.dart';

class UnifiedNotificationService {
  // 플랫폼별 초기화
  static Future<void> initialize() async {
    try {
      if (kIsWeb) {
        await WebNotificationService.initialize();
      } else {
        await RealNotificationService.initialize();
      }
      print('🔔 통합 알림 서비스 초기화 완료 (${kIsWeb ? "웹" : "모바일"})');
    } catch (e) {
      print('❌ 통합 알림 서비스 초기화 오류: $e');
      // 오류가 발생해도 앱이 중단되지 않도록 함
    }
  }

  // 테스트 알림 표시
  static Future<void> showTestNotification() async {
    try {
      if (kIsWeb) {
        await WebNotificationService.showTestNotification();
      } else {
        await RealNotificationService.showTestNotification();
      }
    } catch (e) {
      print('❌ 테스트 알림 오류: $e');
      rethrow;
    }
  }

  // 루틴 완료 알림 표시
  static Future<void> showRoutineCompleteNotification({
    required String routineName,
    required int experienceGained,
  }) async {
    try {
      if (kIsWeb) {
        await WebNotificationService.showRoutineCompleteNotification(
          routineName: routineName,
          experienceGained: experienceGained,
        );
      } else {
        await RealNotificationService.showRoutineCompleteNotification(
          routineName: routineName,
          experienceGained: experienceGained,
        );
      }
    } catch (e) {
      print('❌ 루틴 완료 알림 오류: $e');
    }
  }

  // 연속 달성 알림 표시
  static Future<void> showStreakNotification({
    required int streakDays,
  }) async {
    try {
      if (kIsWeb) {
        await WebNotificationService.showStreakNotification(
          streakDays: streakDays,
        );
      } else {
        await RealNotificationService.showStreakNotification(
          streakDays: streakDays,
        );
      }
    } catch (e) {
      print('❌ 연속 달성 알림 오류: $e');
    }
  }

  // 레벨업 알림 표시
  static Future<void> showLevelUpNotification({
    required int newLevel,
    required String levelTitle,
  }) async {
    try {
      if (kIsWeb) {
        await WebNotificationService.showLevelUpNotification(
          newLevel: newLevel,
          levelTitle: levelTitle,
        );
      } else {
        await RealNotificationService.showLevelUpNotification(
          newLevel: newLevel,
          levelTitle: levelTitle,
        );
      }
    } catch (e) {
      print('❌ 레벨업 알림 오류: $e');
    }
  }

  // 목표 달성 알림 표시
  static Future<void> showGoalAchievementNotification({
    required String goalType,
    required int achieved,
    required int target,
  }) async {
    try {
      if (kIsWeb) {
        await WebNotificationService.showGoalAchievementNotification(
          goalType: goalType,
          achieved: achieved,
          target: target,
        );
      } else {
        await RealNotificationService.showGoalAchievementNotification(
          goalType: goalType,
          achieved: achieved,
          target: target,
        );
      }
    } catch (e) {
      print('❌ 목표 달성 알림 오류: $e');
    }
  }

  // 동기부여 알림 표시
  static Future<void> showMotivationNotification() async {
    try {
      if (kIsWeb) {
        await WebNotificationService.showMotivationNotification();
      } else {
        await RealNotificationService.scheduleMotivationNotification();
      }
    } catch (e) {
      print('❌ 동기부여 알림 오류: $e');
    }
  }

  // 예약된 알림 목록 조회
  static Future<List<Map<String, dynamic>>> getPendingNotifications() async {
    try {
      if (kIsWeb) {
        return await WebNotificationService.getPendingNotifications();
      } else {
        final notifications =
            await RealNotificationService.getPendingNotifications();
        return notifications
            .map((notification) => {
                  'id': notification.id,
                  'title': notification.title ?? '알림',
                  'body': notification.body ?? '',
                })
            .toList();
      }
    } catch (e) {
      print('❌ 예약된 알림 조회 오류: $e');
      return [
        {
          'id': 0,
          'title': '오류',
          'body': '예약된 알림을 조회할 수 없습니다: $e',
        }
      ];
    }
  }

  // 모든 알림 취소
  static Future<void> cancelAllNotifications() async {
    try {
      if (kIsWeb) {
        await WebNotificationService.cancelAllNotifications();
      } else {
        await RealNotificationService.cancelAllNotifications();
      }
    } catch (e) {
      print('❌ 알림 취소 오류: $e');
      rethrow;
    }
  }

  // 알림 설정 업데이트
  static Future<void> updateAllScheduledNotifications() async {
    try {
      if (kIsWeb) {
        await WebNotificationService.updateAllScheduledNotifications();
      } else {
        await RealNotificationService.updateAllScheduledNotifications();
      }
    } catch (e) {
      print('❌ 알림 스케줄링 업데이트 오류: $e');
    }
  }

  // 알림 권한 요청
  static Future<bool> requestNotificationPermission() async {
    try {
      if (kIsWeb) {
        return await WebNotificationService.requestPermission();
      } else {
        return await RealNotificationService.requestNotificationPermission();
      }
    } catch (e) {
      print('❌ 알림 권한 요청 오류: $e');
      return false;
    }
  }

  // 알림 지원 여부 확인
  static bool get isSupported {
    if (kIsWeb) {
      return WebNotificationService.isSupported;
    } else {
      return true; // 모바일에서는 항상 지원
    }
  }

  // 알림 권한 상태 확인
  static bool get hasPermission {
    if (kIsWeb) {
      return WebNotificationService.hasPermission;
    } else {
      return true; // 모바일에서는 초기화 시 권한 요청됨
    }
  }

  // 현재 플랫폼 정보
  static String get platformInfo {
    return kIsWeb ? '웹 (브라우저 알림)' : '모바일 (로컬 알림)';
  }

  // 권한 상태 문자열
  static String get permissionStatus {
    if (kIsWeb) {
      return WebNotificationService.permissionStatus;
    } else {
      return 'mobile_app';
    }
  }
}
