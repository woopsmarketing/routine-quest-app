// 🔔 알림 설정 데이터 모델
// 루틴 퀘스트 앱의 알림 설정을 관리하는 모델
class NotificationSettingsModel {
  // 전체 알림 활성화/비활성화
  final bool isNotificationEnabled;

  // 루틴 관련 알림
  final bool routineStartNotification; // 루틴 시작 알림
  final bool routineCompleteNotification; // 루틴 완료 알림
  final bool routineReminderNotification; // 루틴 미완료 리마인더

  // 성취 관련 알림
  final bool streakNotification; // 연속 달성 알림
  final bool levelUpNotification; // 레벨업 알림
  final bool goalAchievementNotification; // 목표 달성 알림

  // 리포트 관련 알림
  final bool weeklyReportNotification; // 주간 리포트 알림
  final bool monthlyReportNotification; // 월간 리포트 알림

  // 동기부여 알림
  final bool motivationNotification; // 동기부여 메시지 알림

  // 알림 시간 설정
  final String routineReminderTime; // 루틴 리마인더 시간 (HH:mm 형식)
  final String weeklyReportTime; // 주간 리포트 시간 (HH:mm 형식)
  final String monthlyReportTime; // 월간 리포트 시간 (HH:mm 형식)

  // 알림 빈도 설정
  final int motivationNotificationFrequency; // 동기부여 알림 빈도 (일 단위)

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

  // 기본 알림 설정 (모든 알림 활성화)
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
    routineReminderTime: '21:00', // 오후 9시
    weeklyReportTime: '09:00', // 오전 9시
    monthlyReportTime: '09:00', // 오전 9시
    motivationNotificationFrequency: 3, // 3일마다
  );

  // 알림 설정 복사본 생성
  NotificationSettingsModel copyWith({
    bool? isNotificationEnabled,
    bool? routineStartNotification,
    bool? routineCompleteNotification,
    bool? routineReminderNotification,
    bool? streakNotification,
    bool? levelUpNotification,
    bool? goalAchievementNotification,
    bool? weeklyReportNotification,
    bool? monthlyReportNotification,
    bool? motivationNotification,
    String? routineReminderTime,
    String? weeklyReportTime,
    String? monthlyReportTime,
    int? motivationNotificationFrequency,
  }) {
    return NotificationSettingsModel(
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      routineStartNotification:
          routineStartNotification ?? this.routineStartNotification,
      routineCompleteNotification:
          routineCompleteNotification ?? this.routineCompleteNotification,
      routineReminderNotification:
          routineReminderNotification ?? this.routineReminderNotification,
      streakNotification: streakNotification ?? this.streakNotification,
      levelUpNotification: levelUpNotification ?? this.levelUpNotification,
      goalAchievementNotification:
          goalAchievementNotification ?? this.goalAchievementNotification,
      weeklyReportNotification:
          weeklyReportNotification ?? this.weeklyReportNotification,
      monthlyReportNotification:
          monthlyReportNotification ?? this.monthlyReportNotification,
      motivationNotification:
          motivationNotification ?? this.motivationNotification,
      routineReminderTime: routineReminderTime ?? this.routineReminderTime,
      weeklyReportTime: weeklyReportTime ?? this.weeklyReportTime,
      monthlyReportTime: monthlyReportTime ?? this.monthlyReportTime,
      motivationNotificationFrequency: motivationNotificationFrequency ??
          this.motivationNotificationFrequency,
    );
  }

  // 활성화된 알림 개수 계산
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

  // 전체 알림 개수
  static const int totalNotificationCount = 9;

  // 알림 활성화 비율 (0.0 ~ 1.0)
  double get notificationActivationRatio {
    return activeNotificationCount / totalNotificationCount;
  }

  // 시간 문자열을 DateTime으로 변환 (오늘 날짜 기준)
  DateTime getRoutineReminderDateTime() {
    final timeParts = routineReminderTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  DateTime getWeeklyReportDateTime() {
    final timeParts = weeklyReportTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  DateTime getMonthlyReportDateTime() {
    final timeParts = monthlyReportTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // JSON 변환
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

  // JSON에서 객체 생성
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

  @override
  String toString() {
    return 'NotificationSettingsModel(isNotificationEnabled: $isNotificationEnabled, activeNotifications: $activeNotificationCount/$totalNotificationCount)';
  }
}
