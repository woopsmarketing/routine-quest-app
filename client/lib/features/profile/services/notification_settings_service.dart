// 🔔 알림 설정 서비스
// 루틴 퀘스트 앱의 알림 설정을 관리하는 서비스
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/notification_settings_model.dart';

class NotificationSettingsService {
  static const String _storageKey = 'notification_settings';

  // 현재 알림 설정 (싱글톤 패턴)
  static NotificationSettingsModel _currentSettings =
      NotificationSettingsModel.defaultSettings;

  // 현재 설정 getter
  static NotificationSettingsModel get currentSettings => _currentSettings;

  // 서비스 초기화
  static Future<void> initialize() async {
    try {
      await _loadSettings();
      print('알림 설정 서비스 초기화 완료');
    } catch (e) {
      print('알림 설정 서비스 초기화 오류: $e');
      // 오류 발생 시 기본 설정 사용
      _currentSettings = NotificationSettingsModel.defaultSettings;
    }
  }

  // 설정 로드
  static Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_storageKey);

    if (settingsJson != null) {
      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      _currentSettings = NotificationSettingsModel.fromJson(settingsMap);
      print('알림 설정 로드 완료: ${_currentSettings.activeNotificationCount}개 활성화');
    } else {
      // 저장된 설정이 없으면 기본 설정 사용
      _currentSettings = NotificationSettingsModel.defaultSettings;
      await _saveSettings();
      print('기본 알림 설정 적용 및 저장 완료');
    }
  }

  // 설정 저장
  static Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(_currentSettings.toJson());
      await prefs.setString(_storageKey, settingsJson);
      print('알림 설정 저장 완료');
    } catch (e) {
      print('알림 설정 저장 오류: $e');
      throw Exception('알림 설정 저장에 실패했습니다.');
    }
  }

  // 전체 알림 활성화/비활성화
  static Future<void> setNotificationEnabled(bool enabled) async {
    _currentSettings =
        _currentSettings.copyWith(isNotificationEnabled: enabled);
    await _saveSettings();
    print('전체 알림 ${enabled ? "활성화" : "비활성화"} 완료');
  }

  // 루틴 시작 알림 설정
  static Future<void> setRoutineStartNotification(bool enabled) async {
    _currentSettings =
        _currentSettings.copyWith(routineStartNotification: enabled);
    await _saveSettings();
    print('루틴 시작 알림 ${enabled ? "활성화" : "비활성화"} 완료');
  }

  // 루틴 완료 알림 설정
  static Future<void> setRoutineCompleteNotification(bool enabled) async {
    _currentSettings =
        _currentSettings.copyWith(routineCompleteNotification: enabled);
    await _saveSettings();
    print('루틴 완료 알림 ${enabled ? "활성화" : "비활성화"} 완료');
  }

  // 루틴 리마인더 알림 설정
  static Future<void> setRoutineReminderNotification(bool enabled) async {
    _currentSettings =
        _currentSettings.copyWith(routineReminderNotification: enabled);
    await _saveSettings();
    print('루틴 리마인더 알림 ${enabled ? "활성화" : "비활성화"} 완료');
  }

  // 연속 달성 알림 설정
  static Future<void> setStreakNotification(bool enabled) async {
    _currentSettings = _currentSettings.copyWith(streakNotification: enabled);
    await _saveSettings();
    print('연속 달성 알림 ${enabled ? "활성화" : "비활성화"} 완료');
  }

  // 레벨업 알림 설정
  static Future<void> setLevelUpNotification(bool enabled) async {
    _currentSettings = _currentSettings.copyWith(levelUpNotification: enabled);
    await _saveSettings();
    print('레벨업 알림 ${enabled ? "활성화" : "비활성화"} 완료');
  }

  // 목표 달성 알림 설정
  static Future<void> setGoalAchievementNotification(bool enabled) async {
    _currentSettings =
        _currentSettings.copyWith(goalAchievementNotification: enabled);
    await _saveSettings();
    print('목표 달성 알림 ${enabled ? "활성화" : "비활성화"} 완료');
  }

  // 주간 리포트 알림 설정
  static Future<void> setWeeklyReportNotification(bool enabled) async {
    _currentSettings =
        _currentSettings.copyWith(weeklyReportNotification: enabled);
    await _saveSettings();
    print('주간 리포트 알림 ${enabled ? "활성화" : "비활성화"} 완료');
  }

  // 월간 리포트 알림 설정
  static Future<void> setMonthlyReportNotification(bool enabled) async {
    _currentSettings =
        _currentSettings.copyWith(monthlyReportNotification: enabled);
    await _saveSettings();
    print('월간 리포트 알림 ${enabled ? "활성화" : "비활성화"} 완료');
  }

  // 동기부여 알림 설정
  static Future<void> setMotivationNotification(bool enabled) async {
    _currentSettings =
        _currentSettings.copyWith(motivationNotification: enabled);
    await _saveSettings();
    print('동기부여 알림 ${enabled ? "활성화" : "비활성화"} 완료');
  }

  // 루틴 리마인더 시간 설정
  static Future<void> setRoutineReminderTime(String time) async {
    _currentSettings = _currentSettings.copyWith(routineReminderTime: time);
    await _saveSettings();
    print('루틴 리마인더 시간 설정: $time');
  }

  // 주간 리포트 시간 설정
  static Future<void> setWeeklyReportTime(String time) async {
    _currentSettings = _currentSettings.copyWith(weeklyReportTime: time);
    await _saveSettings();
    print('주간 리포트 시간 설정: $time');
  }

  // 월간 리포트 시간 설정
  static Future<void> setMonthlyReportTime(String time) async {
    _currentSettings = _currentSettings.copyWith(monthlyReportTime: time);
    await _saveSettings();
    print('월간 리포트 시간 설정: $time');
  }

  // 동기부여 알림 빈도 설정
  static Future<void> setMotivationNotificationFrequency(int frequency) async {
    _currentSettings =
        _currentSettings.copyWith(motivationNotificationFrequency: frequency);
    await _saveSettings();
    print('동기부여 알림 빈도 설정: $frequency일마다');
  }

  // 설정 초기화 (기본값으로 리셋)
  static Future<void> resetToDefault() async {
    _currentSettings = NotificationSettingsModel.defaultSettings;
    await _saveSettings();
    print('알림 설정을 기본값으로 초기화 완료');
  }

  // 설정 백업 (JSON 문자열로 반환)
  static String exportSettings() {
    return json.encode(_currentSettings.toJson());
  }

  // 설정 복원 (JSON 문자열에서 복원)
  static Future<void> importSettings(String settingsJson) async {
    try {
      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      _currentSettings = NotificationSettingsModel.fromJson(settingsMap);
      await _saveSettings();
      print('알림 설정 복원 완료');
    } catch (e) {
      print('알림 설정 복원 오류: $e');
      throw Exception('잘못된 설정 형식입니다.');
    }
  }

  // 알림 설정 요약 정보
  static Map<String, dynamic> getSettingsSummary() {
    return {
      'isEnabled': _currentSettings.isNotificationEnabled,
      'activeCount': _currentSettings.activeNotificationCount,
      'totalCount': NotificationSettingsModel.totalNotificationCount,
      'activationRatio': _currentSettings.notificationActivationRatio,
      'routineReminderTime': _currentSettings.routineReminderTime,
      'weeklyReportTime': _currentSettings.weeklyReportTime,
      'monthlyReportTime': _currentSettings.monthlyReportTime,
      'motivationFrequency': _currentSettings.motivationNotificationFrequency,
    };
  }

  // 특정 알림이 활성화되어 있는지 확인
  static bool isNotificationActive(String notificationType) {
    switch (notificationType) {
      case 'routineStart':
        return _currentSettings.routineStartNotification;
      case 'routineComplete':
        return _currentSettings.routineCompleteNotification;
      case 'routineReminder':
        return _currentSettings.routineReminderNotification;
      case 'streak':
        return _currentSettings.streakNotification;
      case 'levelUp':
        return _currentSettings.levelUpNotification;
      case 'goalAchievement':
        return _currentSettings.goalAchievementNotification;
      case 'weeklyReport':
        return _currentSettings.weeklyReportNotification;
      case 'monthlyReport':
        return _currentSettings.monthlyReportNotification;
      case 'motivation':
        return _currentSettings.motivationNotification;
      default:
        return false;
    }
  }

  // 알림 설정 유효성 검사
  static bool validateSettings() {
    // 시간 형식 검사 (HH:mm)
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');

    if (!timeRegex.hasMatch(_currentSettings.routineReminderTime)) {
      print('잘못된 루틴 리마인더 시간 형식: ${_currentSettings.routineReminderTime}');
      return false;
    }

    if (!timeRegex.hasMatch(_currentSettings.weeklyReportTime)) {
      print('잘못된 주간 리포트 시간 형식: ${_currentSettings.weeklyReportTime}');
      return false;
    }

    if (!timeRegex.hasMatch(_currentSettings.monthlyReportTime)) {
      print('잘못된 월간 리포트 시간 형식: ${_currentSettings.monthlyReportTime}');
      return false;
    }

    // 동기부여 알림 빈도 검사 (1-30일)
    if (_currentSettings.motivationNotificationFrequency < 1 ||
        _currentSettings.motivationNotificationFrequency > 30) {
      print(
          '잘못된 동기부여 알림 빈도: ${_currentSettings.motivationNotificationFrequency}');
      return false;
    }

    return true;
  }
}
