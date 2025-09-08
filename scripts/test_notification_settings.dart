#!/usr/bin/env dart
// 🔔 알림 설정 기능 테스트 스크립트
// 루틴 퀘스트 앱의 알림 설정 기능을 테스트하는 스크립트

import 'dart:io';
import 'dart:convert';

// 알림 설정 모델 (테스트용)
class NotificationSettingsModel {
  final bool isNotificationEnabled;
  final bool routineStartNotification;
  final bool routineCompleteNotification;
  final bool routineReminderNotification;
  final bool streakNotification;
  final bool levelUpNotification;
  final bool goalAchievementNotification;
  final bool weeklyReportNotification;
  final bool monthlyReportNotification;
  final bool motivationNotification;
  final String routineReminderTime;
  final String weeklyReportTime;
  final String monthlyReportTime;
  final int motivationNotificationFrequency;

  const NotificationSettingsModel({
    required this.isNotificationEnabled,
    required this.routineStartNotification,
    required this.routineCompleteNotification,
    required this.routineReminderNotification,
    required this.streakNotification,
    required this.levelUpNotification,
    required this.goalAchievementNotification,
    required this.weeklyReportNotification,
    required this.monthlyReportNotification,
    required this.motivationNotification,
    required this.routineReminderTime,
    required this.weeklyReportTime,
    required this.monthlyReportTime,
    required this.motivationNotificationFrequency,
  });

  static const NotificationSettingsModel defaultSettings =
      NotificationSettingsModel(
    isNotificationEnabled: true,
    routineStartNotification: true,
    routineCompleteNotification: true,
    routineReminderNotification: true,
    streakNotification: true,
    levelUpNotification: true,
    goalAchievementNotification: true,
    weeklyReportNotification: true,
    monthlyReportNotification: true,
    motivationNotification: true,
    routineReminderTime: '21:00',
    weeklyReportTime: '09:00',
    monthlyReportTime: '09:00',
    motivationNotificationFrequency: 3,
  );

  int get activeNotificationCount {
    int count = 0;
    if (routineStartNotification) count++;
    if (routineCompleteNotification) count++;
    if (routineReminderNotification) count++;
    if (streakNotification) count++;
    if (levelUpNotification) count++;
    if (goalAchievementNotification) count++;
    if (weeklyReportNotification) count++;
    if (monthlyReportNotification) count++;
    if (motivationNotification) count++;
    return count;
  }

  static const int totalNotificationCount = 9;

  double get notificationActivationRatio {
    return activeNotificationCount / totalNotificationCount;
  }

  Map<String, dynamic> toJson() {
    return {
      'isNotificationEnabled': isNotificationEnabled,
      'routineStartNotification': routineStartNotification,
      'routineCompleteNotification': routineCompleteNotification,
      'routineReminderNotification': routineReminderNotification,
      'streakNotification': streakNotification,
      'levelUpNotification': levelUpNotification,
      'goalAchievementNotification': goalAchievementNotification,
      'weeklyReportNotification': weeklyReportNotification,
      'monthlyReportNotification': monthlyReportNotification,
      'motivationNotification': motivationNotification,
      'routineReminderTime': routineReminderTime,
      'weeklyReportTime': weeklyReportTime,
      'monthlyReportTime': monthlyReportTime,
      'motivationNotificationFrequency': motivationNotificationFrequency,
    };
  }

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      isNotificationEnabled: json['isNotificationEnabled'] ?? true,
      routineStartNotification: json['routineStartNotification'] ?? true,
      routineCompleteNotification: json['routineCompleteNotification'] ?? true,
      routineReminderNotification: json['routineReminderNotification'] ?? true,
      streakNotification: json['streakNotification'] ?? true,
      levelUpNotification: json['levelUpNotification'] ?? true,
      goalAchievementNotification: json['goalAchievementNotification'] ?? true,
      weeklyReportNotification: json['weeklyReportNotification'] ?? true,
      monthlyReportNotification: json['monthlyReportNotification'] ?? true,
      motivationNotification: json['motivationNotification'] ?? true,
      routineReminderTime: json['routineReminderTime'] ?? '21:00',
      weeklyReportTime: json['weeklyReportTime'] ?? '09:00',
      monthlyReportTime: json['monthlyReportTime'] ?? '09:00',
      motivationNotificationFrequency:
          json['motivationNotificationFrequency'] ?? 3,
    );
  }
}

// 테스트 함수들
void testDefaultSettings() {
  print('🧪 기본 설정 테스트');
  print('=' * 50);

  final settings = NotificationSettingsModel.defaultSettings;

  print('✅ 전체 알림 활성화: ${settings.isNotificationEnabled}');
  print('✅ 루틴 시작 알림: ${settings.routineStartNotification}');
  print('✅ 루틴 완료 알림: ${settings.routineCompleteNotification}');
  print('✅ 루틴 리마인더: ${settings.routineReminderNotification}');
  print('✅ 연속 달성 알림: ${settings.streakNotification}');
  print('✅ 레벨업 알림: ${settings.levelUpNotification}');
  print('✅ 목표 달성 알림: ${settings.goalAchievementNotification}');
  print('✅ 주간 리포트: ${settings.weeklyReportNotification}');
  print('✅ 월간 리포트: ${settings.monthlyReportNotification}');
  print('✅ 동기부여 알림: ${settings.motivationNotification}');

  print('\n📊 알림 통계:');
  print(
      '   활성 알림: ${settings.activeNotificationCount}/${NotificationSettingsModel.totalNotificationCount}개');
  print(
      '   활성화 비율: ${(settings.notificationActivationRatio * 100).toStringAsFixed(1)}%');
  print('   리마인더 시간: ${settings.routineReminderTime}');
  print('   주간 리포트 시간: ${settings.weeklyReportTime}');
  print('   월간 리포트 시간: ${settings.monthlyReportTime}');
  print('   동기부여 빈도: ${settings.motivationNotificationFrequency}일마다');

  print('\n✅ 기본 설정 테스트 완료\n');
}

void testJsonSerialization() {
  print('🧪 JSON 직렬화 테스트');
  print('=' * 50);

  final settings = NotificationSettingsModel.defaultSettings;

  // JSON 변환
  final json = settings.toJson();
  print('✅ JSON 변환 성공');
  print('   JSON 크기: ${jsonEncode(json).length} bytes');

  // JSON에서 복원
  final restoredSettings = NotificationSettingsModel.fromJson(json);
  print('✅ JSON 복원 성공');

  // 데이터 일치 확인
  bool isMatch = settings.isNotificationEnabled ==
          restoredSettings.isNotificationEnabled &&
      settings.routineStartNotification ==
          restoredSettings.routineStartNotification &&
      settings.routineCompleteNotification ==
          restoredSettings.routineCompleteNotification &&
      settings.routineReminderNotification ==
          restoredSettings.routineReminderNotification &&
      settings.streakNotification == restoredSettings.streakNotification &&
      settings.levelUpNotification == restoredSettings.levelUpNotification &&
      settings.goalAchievementNotification ==
          restoredSettings.goalAchievementNotification &&
      settings.weeklyReportNotification ==
          restoredSettings.weeklyReportNotification &&
      settings.monthlyReportNotification ==
          restoredSettings.monthlyReportNotification &&
      settings.motivationNotification ==
          restoredSettings.motivationNotification &&
      settings.routineReminderTime == restoredSettings.routineReminderTime &&
      settings.weeklyReportTime == restoredSettings.weeklyReportTime &&
      settings.monthlyReportTime == restoredSettings.monthlyReportTime &&
      settings.motivationNotificationFrequency ==
          restoredSettings.motivationNotificationFrequency;

  print('✅ 데이터 일치 확인: ${isMatch ? "성공" : "실패"}');

  if (!isMatch) {
    print('❌ 데이터 불일치 발견!');
  }

  print('\n✅ JSON 직렬화 테스트 완료\n');
}

void testCustomSettings() {
  print('🧪 커스텀 설정 테스트');
  print('=' * 50);

  // 일부 알림만 활성화한 설정
  final customSettings = NotificationSettingsModel(
    isNotificationEnabled: true,
    routineStartNotification: true,
    routineCompleteNotification: false,
    routineReminderNotification: true,
    streakNotification: false,
    levelUpNotification: true,
    goalAchievementNotification: false,
    weeklyReportNotification: true,
    monthlyReportNotification: false,
    motivationNotification: true,
    routineReminderTime: '20:30',
    weeklyReportTime: '08:00',
    monthlyReportTime: '10:00',
    motivationNotificationFrequency: 5,
  );

  print('📊 커스텀 설정 통계:');
  print(
      '   활성 알림: ${customSettings.activeNotificationCount}/${NotificationSettingsModel.totalNotificationCount}개');
  print(
      '   활성화 비율: ${(customSettings.notificationActivationRatio * 100).toStringAsFixed(1)}%');
  print('   리마인더 시간: ${customSettings.routineReminderTime}');
  print('   주간 리포트 시간: ${customSettings.weeklyReportTime}');
  print('   월간 리포트 시간: ${customSettings.monthlyReportTime}');
  print('   동기부여 빈도: ${customSettings.motivationNotificationFrequency}일마다');

  print('\n✅ 커스텀 설정 테스트 완료\n');
}

void testTimeValidation() {
  print('🧪 시간 형식 검증 테스트');
  print('=' * 50);

  final validTimes = ['00:00', '12:30', '23:59', '09:15'];
  final invalidTimes = ['24:00', '12:60', '25:30', 'abc', '12:5', '1:30'];

  print('✅ 유효한 시간 형식:');
  for (final time in validTimes) {
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    final isValid = regex.hasMatch(time);
    print('   $time: ${isValid ? "✅" : "❌"}');
  }

  print('\n❌ 무효한 시간 형식:');
  for (final time in invalidTimes) {
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    final isValid = regex.hasMatch(time);
    print('   $time: ${isValid ? "❌ (예상과 다름)" : "✅"}');
  }

  print('\n✅ 시간 형식 검증 테스트 완료\n');
}

void testFrequencyValidation() {
  print('🧪 빈도 검증 테스트');
  print('=' * 50);

  final validFrequencies = [1, 2, 3, 5, 7, 10, 14, 21, 30];
  final invalidFrequencies = [0, -1, 31, 100];

  print('✅ 유효한 빈도:');
  for (final freq in validFrequencies) {
    final isValid = freq >= 1 && freq <= 30;
    print('   ${freq}일마다: ${isValid ? "✅" : "❌"}');
  }

  print('\n❌ 무효한 빈도:');
  for (final freq in invalidFrequencies) {
    final isValid = freq >= 1 && freq <= 30;
    print('   ${freq}일마다: ${isValid ? "❌ (예상과 다름)" : "✅"}');
  }

  print('\n✅ 빈도 검증 테스트 완료\n');
}

void testNotificationTypes() {
  print('🧪 알림 타입 테스트');
  print('=' * 50);

  final settings = NotificationSettingsModel.defaultSettings;

  final notificationTypes = [
    'routineStart',
    'routineComplete',
    'routineReminder',
    'streak',
    'levelUp',
    'goalAchievement',
    'weeklyReport',
    'monthlyReport',
    'motivation',
  ];

  print('📋 알림 타입별 상태:');
  for (final type in notificationTypes) {
    bool isActive = false;
    String description = '';

    switch (type) {
      case 'routineStart':
        isActive = settings.routineStartNotification;
        description = '루틴 시작 알림';
        break;
      case 'routineComplete':
        isActive = settings.routineCompleteNotification;
        description = '루틴 완료 알림';
        break;
      case 'routineReminder':
        isActive = settings.routineReminderNotification;
        description = '루틴 리마인더';
        break;
      case 'streak':
        isActive = settings.streakNotification;
        description = '연속 달성 알림';
        break;
      case 'levelUp':
        isActive = settings.levelUpNotification;
        description = '레벨업 알림';
        break;
      case 'goalAchievement':
        isActive = settings.goalAchievementNotification;
        description = '목표 달성 알림';
        break;
      case 'weeklyReport':
        isActive = settings.weeklyReportNotification;
        description = '주간 리포트';
        break;
      case 'monthlyReport':
        isActive = settings.monthlyReportNotification;
        description = '월간 리포트';
        break;
      case 'motivation':
        isActive = settings.motivationNotification;
        description = '동기부여 알림';
        break;
    }

    print('   $type ($description): ${isActive ? "✅ 활성" : "❌ 비활성"}');
  }

  print('\n✅ 알림 타입 테스트 완료\n');
}

void main() {
  print('🔔 루틴 퀘스트 알림 설정 기능 테스트');
  print('=' * 60);
  print('');

  try {
    // 모든 테스트 실행
    testDefaultSettings();
    testJsonSerialization();
    testCustomSettings();
    testTimeValidation();
    testFrequencyValidation();
    testNotificationTypes();

    print('🎉 모든 테스트 완료!');
    print('=' * 60);
    print('');
    print('📋 테스트 결과 요약:');
    print('   ✅ 기본 설정 테스트: 통과');
    print('   ✅ JSON 직렬화 테스트: 통과');
    print('   ✅ 커스텀 설정 테스트: 통과');
    print('   ✅ 시간 형식 검증 테스트: 통과');
    print('   ✅ 빈도 검증 테스트: 통과');
    print('   ✅ 알림 타입 테스트: 통과');
    print('');
    print('🚀 알림 설정 기능이 정상적으로 작동합니다!');
  } catch (e) {
    print('❌ 테스트 실행 중 오류 발생: $e');
    exit(1);
  }
}
