// 🔔 실제 알림 서비스
// 플랫폼별로 다른 알림 시스템을 사용하여 실제 알림을 구현하는 서비스
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'notification_settings_service.dart';
import 'dart:html' as html; // 웹 전용

class RealNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  // 알림 ID 상수들
  static const int _routineStartId = 1000;
  static const int _routineCompleteId = 2000;
  static const int _routineReminderId = 3000;
  static const int _streakId = 4000;
  static const int _levelUpId = 5000;
  static const int _goalAchievementId = 6000;
  static const int _weeklyReportId = 7000;
  static const int _monthlyReportId = 8000;
  static const int _motivationId = 9000;

  // 알림 서비스 초기화
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 타임존 초기화
      tz.initializeTimeZones();

      // Android 초기화 설정
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS 초기화 설정
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // 초기화 설정
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // 알림 플러그인 초기화
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Android 알림 채널 생성
      await _createNotificationChannels();

      _isInitialized = true;
      print('🔔 실제 알림 서비스 초기화 완료');
    } catch (e) {
      print('❌ 알림 서비스 초기화 오류: $e');
      throw Exception('알림 서비스 초기화에 실패했습니다.');
    }
  }

  // Android 알림 채널 생성
  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel routineChannel =
        AndroidNotificationChannel(
      'routine_notifications',
      '루틴 알림',
      description: '루틴 시작, 완료, 리마인더 알림',
      importance: Importance.high,
      playSound: true,
    );

    const AndroidNotificationChannel achievementChannel =
        AndroidNotificationChannel(
      'achievement_notifications',
      '성취 알림',
      description: '연속 달성, 레벨업, 목표 달성 알림',
      importance: Importance.high,
      playSound: true,
    );

    const AndroidNotificationChannel reportChannel = AndroidNotificationChannel(
      'report_notifications',
      '리포트 알림',
      description: '주간/월간 리포트 알림',
      importance: Importance.defaultImportance,
      playSound: true,
    );

    const AndroidNotificationChannel motivationChannel =
        AndroidNotificationChannel(
      'motivation_notifications',
      '동기부여 알림',
      description: '동기부여 메시지 알림',
      importance: Importance.defaultImportance,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(routineChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(achievementChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(reportChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(motivationChannel);
  }

  // 알림 탭 이벤트 처리
  static void _onNotificationTapped(NotificationResponse response) {
    print('🔔 알림 탭됨: ${response.payload}');
    // TODO: 알림 탭 시 앱으로 이동하는 로직 구현
  }

  // 모든 예약된 알림 취소
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('🔔 모든 예약된 알림 취소 완료');
  }

  // 특정 알림 취소
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    print('🔔 알림 취소 완료: ID $id');
  }

  // 즉시 알림 표시 (테스트용)
  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'routine_notifications',
      '루틴 알림',
      channelDescription: '루틴 시작, 완료, 리마인더 알림',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      9999, // 테스트용 ID
      '🔔 루틴 퀘스트',
      '알림 기능이 정상적으로 작동합니다!',
      details,
    );

    print('🔔 테스트 알림 표시 완료');
  }

  // 루틴 시작 알림 스케줄링
  static Future<void> scheduleRoutineStartNotification({
    required String routineName,
    required DateTime scheduledTime,
  }) async {
    final settings = NotificationSettingsService.currentSettings;
    if (!settings.isNotificationEnabled || !settings.routineStartNotification) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'routine_notifications',
      '루틴 알림',
      channelDescription: '루틴 시작, 완료, 리마인더 알림',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _routineStartId,
      '🚀 루틴 시작 시간!',
      '$routineName을 시작할 시간입니다.',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'routine_start:$routineName',
    );

    print('🔔 루틴 시작 알림 스케줄링: $routineName at ${scheduledTime.toString()}');
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

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'routine_notifications',
      '루틴 알림',
      channelDescription: '루틴 시작, 완료, 리마인더 알림',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _routineCompleteId,
      '🎉 루틴 완료!',
      '$routineName을 완료했습니다! +$experienceGained EXP',
      details,
      payload: 'routine_complete:$routineName',
    );

    print('🔔 루틴 완료 알림 표시: $routineName');
  }

  // 루틴 리마인더 알림 스케줄링
  static Future<void> scheduleRoutineReminderNotification({
    required String routineName,
  }) async {
    final settings = NotificationSettingsService.currentSettings;
    if (!settings.isNotificationEnabled ||
        !settings.routineReminderNotification) {
      return;
    }

    // 설정된 리마인더 시간으로 오늘 알림 스케줄링
    final reminderTime = settings.getRoutineReminderDateTime();
    final now = DateTime.now();

    // 이미 지난 시간이면 내일로 설정
    DateTime scheduledTime = reminderTime;
    if (reminderTime.isBefore(now)) {
      scheduledTime = reminderTime.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'routine_notifications',
      '루틴 알림',
      channelDescription: '루틴 시작, 완료, 리마인더 알림',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _routineReminderId,
      '⏰ 루틴 리마인더',
      '$routineName을 아직 완료하지 않았습니다. 지금 시작해보세요!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'routine_reminder:$routineName',
    );

    print('🔔 루틴 리마인더 알림 스케줄링: $routineName at ${scheduledTime.toString()}');
  }

  // 연속 달성 알림 표시
  static Future<void> showStreakNotification({
    required int streakDays,
  }) async {
    final settings = NotificationSettingsService.currentSettings;
    if (!settings.isNotificationEnabled || !settings.streakNotification) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'achievement_notifications',
      '성취 알림',
      channelDescription: '연속 달성, 레벨업, 목표 달성 알림',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _streakId,
      '🔥 연속 달성!',
      '${streakDays}일 연속으로 루틴을 달성했습니다!',
      details,
      payload: 'streak:$streakDays',
    );

    print('🔔 연속 달성 알림 표시: ${streakDays}일');
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

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'achievement_notifications',
      '성취 알림',
      channelDescription: '연속 달성, 레벨업, 목표 달성 알림',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _levelUpId,
      '⭐ 레벨업!',
      '레벨 $newLevel 달성! $levelTitle',
      details,
      payload: 'level_up:$newLevel',
    );

    print('🔔 레벨업 알림 표시: 레벨 $newLevel');
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

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'achievement_notifications',
      '성취 알림',
      channelDescription: '연속 달성, 레벨업, 목표 달성 알림',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _goalAchievementId,
      '🎯 목표 달성!',
      '$goalType 목표를 달성했습니다! ($achieved/$target)',
      details,
      payload: 'goal_achievement:$goalType',
    );

    print('🔔 목표 달성 알림 표시: $goalType');
  }

  // 주간 리포트 알림 스케줄링
  static Future<void> scheduleWeeklyReportNotification() async {
    final settings = NotificationSettingsService.currentSettings;
    if (!settings.isNotificationEnabled || !settings.weeklyReportNotification) {
      return;
    }

    // 매주 월요일 설정된 시간에 알림
    final reportTime = settings.getWeeklyReportDateTime();
    final now = DateTime.now();

    // 다음 월요일 계산
    int daysUntilMonday = (8 - now.weekday) % 7;
    if (daysUntilMonday == 0) daysUntilMonday = 7;

    DateTime scheduledTime = reportTime.add(Duration(days: daysUntilMonday));

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'report_notifications',
      '리포트 알림',
      channelDescription: '주간/월간 리포트 알림',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _weeklyReportId,
      '📊 주간 리포트',
      '이번 주 루틴 성과를 확인해보세요!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'weekly_report',
    );

    print('🔔 주간 리포트 알림 스케줄링: ${scheduledTime.toString()}');
  }

  // 월간 리포트 알림 스케줄링
  static Future<void> scheduleMonthlyReportNotification() async {
    final settings = NotificationSettingsService.currentSettings;
    if (!settings.isNotificationEnabled ||
        !settings.monthlyReportNotification) {
      return;
    }

    // 매월 1일 설정된 시간에 알림
    final reportTime = settings.getMonthlyReportDateTime();
    final now = DateTime.now();

    // 다음 달 1일 계산
    DateTime nextMonth = DateTime(now.year, now.month + 1, 1);
    DateTime scheduledTime = DateTime(
      nextMonth.year,
      nextMonth.month,
      nextMonth.day,
      reportTime.hour,
      reportTime.minute,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'report_notifications',
      '리포트 알림',
      channelDescription: '주간/월간 리포트 알림',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _monthlyReportId,
      '📈 월간 리포트',
      '이번 달 루틴 성과를 확인해보세요!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'monthly_report',
    );

    print('🔔 월간 리포트 알림 스케줄링: ${scheduledTime.toString()}');
  }

  // 동기부여 알림 스케줄링
  static Future<void> scheduleMotivationNotification() async {
    final settings = NotificationSettingsService.currentSettings;
    if (!settings.isNotificationEnabled || !settings.motivationNotification) {
      return;
    }

    // 설정된 빈도에 따라 알림 스케줄링
    final frequency = settings.motivationNotificationFrequency;
    final scheduledTime = DateTime.now().add(Duration(days: frequency));

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'motivation_notifications',
      '동기부여 알림',
      channelDescription: '동기부여 메시지 알림',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

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

    await _notifications.zonedSchedule(
      _motivationId,
      '💝 응원 메시지',
      randomMessage,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'motivation',
    );

    print('🔔 동기부여 알림 스케줄링: ${scheduledTime.toString()}');
  }

  // 모든 알림 스케줄링 업데이트
  static Future<void> updateAllScheduledNotifications() async {
    try {
      // 기존 알림 모두 취소
      await cancelAllNotifications();

      final settings = NotificationSettingsService.currentSettings;
      if (!settings.isNotificationEnabled) {
        print('🔔 알림이 비활성화되어 스케줄링을 건너뜁니다.');
        return;
      }

      // 각 알림 타입별로 스케줄링
      if (settings.weeklyReportNotification) {
        await scheduleWeeklyReportNotification();
      }

      if (settings.monthlyReportNotification) {
        await scheduleMonthlyReportNotification();
      }

      if (settings.motivationNotification) {
        await scheduleMotivationNotification();
      }

      print('🔔 모든 알림 스케줄링 업데이트 완료');
    } catch (e) {
      print('❌ 알림 스케줄링 업데이트 오류: $e');
    }
  }

  // 알림 권한 요청
  static Future<bool> requestNotificationPermission() async {
    try {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      return result ?? true;
    } catch (e) {
      print('❌ 알림 권한 요청 오류: $e');
      return false;
    }
  }

  // 예약된 알림 목록 조회
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
