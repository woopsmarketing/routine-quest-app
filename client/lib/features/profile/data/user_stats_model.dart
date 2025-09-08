// 📊 사용자 통계 데이터 모델
// 루틴 퀘스트 앱의 사용자 성취도와 통계를 관리하는 모델
class UserStatsModel {
  // 기본 통계
  final int totalRoutines; // 총 루틴 수
  final int totalCompletedSteps; // 완료한 총 스텝 수
  final int currentStreak; // 현재 연속 달성 일수
  final int longestStreak; // 최고 연속 달성 일수

  // 레벨 시스템
  final int currentLevel; // 현재 레벨
  final int totalExperience; // 총 경험치
  final int experienceToNextLevel; // 다음 레벨까지 필요한 경험치

  // 기간별 통계
  final int weeklyCompletedRoutines; // 이번 주 완료한 루틴 수
  final int weeklyGoal; // 이번 주 목표 루틴 수
  final int monthlyCompletedRoutines; // 이번 달 완료한 루틴 수
  final int monthlyGoal; // 이번 달 목표 루틴 수

  // 성취도
  final double weeklyCompletionRate; // 이번 주 완료율 (0.0 ~ 1.0)
  final double monthlyCompletionRate; // 이번 달 완료율 (0.0 ~ 1.0)
  final int totalDaysActive; // 총 활동 일수
  final int totalDaysSinceStart; // 시작한 지 총 일수

  const UserStatsModel({
    required this.totalRoutines,
    required this.totalCompletedSteps,
    required this.currentStreak,
    required this.longestStreak,
    required this.currentLevel,
    required this.totalExperience,
    required this.experienceToNextLevel,
    required this.weeklyCompletedRoutines,
    required this.weeklyGoal,
    required this.monthlyCompletedRoutines,
    required this.monthlyGoal,
    required this.weeklyCompletionRate,
    required this.monthlyCompletionRate,
    required this.totalDaysActive,
    required this.totalDaysSinceStart,
  });

  // 기본 통계 (실제 데이터는 DashboardDataService에서 동적으로 가져옴)
  static const UserStatsModel defaultStats = UserStatsModel(
    totalRoutines: 0, // 실제 데이터로 동기화됨
    totalCompletedSteps: 0, // 실제 데이터로 동기화됨
    currentStreak: 0, // 실제 데이터로 동기화됨
    longestStreak: 0, // 실제 데이터로 동기화됨
    currentLevel: 1, // 실제 데이터로 동기화됨
    totalExperience: 0, // 실제 데이터로 동기화됨
    experienceToNextLevel: 1000, // 실제 데이터로 동기화됨
    weeklyCompletedRoutines: 0, // 실제 데이터로 동기화됨
    weeklyGoal: 5,
    monthlyCompletedRoutines: 0, // 실제 데이터로 동기화됨
    monthlyGoal: 20,
    weeklyCompletionRate: 0.0, // 실제 데이터로 동기화됨
    monthlyCompletionRate: 0.0, // 실제 데이터로 동기화됨
    totalDaysActive: 0, // 실제 데이터로 동기화됨
    totalDaysSinceStart: 30,
  );

  // 10단계 레벨 시스템: 각 레벨마다 1000 XP 필요
  static int calculateLevelFromExperience(int totalExperience) {
    if (totalExperience < 1000) return 1;
    if (totalExperience < 2000) return 2;
    if (totalExperience < 3000) return 3;
    if (totalExperience < 4000) return 4;
    if (totalExperience < 5000) return 5;
    if (totalExperience < 6000) return 6;
    if (totalExperience < 7000) return 7;
    if (totalExperience < 8000) return 8;
    if (totalExperience < 9000) return 9;
    return 10; // 최대 레벨
  }

  // 10단계 레벨별 칭호 시스템
  static String getLevelTitle(int level) {
    switch (level) {
      case 1:
        return '루틴 초보자';
      case 2:
        return '루틴 적응자';
      case 3:
        return '루틴 실천자';
      case 4:
        return '루틴 마스터';
      case 5:
        return '루틴 달인';
      case 6:
        return '루틴 전문가';
      case 7:
        return '루틴 고수';
      case 8:
        return '루틴 전설';
      case 9:
        return '루틴 제왕';
      case 10:
        return '루틴 신';
      default:
        return '루틴 초보자';
    }
  }

  // 현재 레벨의 칭호 가져오기
  String get currentLevelTitle {
    return getLevelTitle(currentLevel);
  }

  // 다음 레벨까지의 진행률 (0.0 ~ 1.0)
  double get levelProgress {
    if (currentLevel >= 10) {
      // 최대 레벨 도달 시 100% 완료
      return 1.0;
    }

    // 현재 레벨에서의 경험치 (0~1000)
    final currentLevelExp = totalExperience % 1000;
    return (currentLevelExp / 1000).clamp(0.0, 1.0);
  }

  // 이번 주 목표 달성률 (0.0 ~ 1.0)
  double get weeklyGoalProgress {
    if (weeklyGoal == 0) return 0.0;
    return (weeklyCompletedRoutines / weeklyGoal).clamp(0.0, 1.0);
  }

  // 이번 달 목표 달성률 (0.0 ~ 1.0)
  double get monthlyGoalProgress {
    if (monthlyGoal == 0) return 0.0;
    return (monthlyCompletedRoutines / monthlyGoal).clamp(0.0, 1.0);
  }

  // 전체 활동률 (0.0 ~ 1.0)
  double get overallActivityRate {
    if (totalDaysSinceStart == 0) return 0.0;
    return (totalDaysActive / totalDaysSinceStart).clamp(0.0, 1.0);
  }

  // 통계 복사본 생성
  UserStatsModel copyWith({
    int? totalRoutines,
    int? totalCompletedSteps,
    int? currentStreak,
    int? longestStreak,
    int? currentLevel,
    int? totalExperience,
    int? experienceToNextLevel,
    int? weeklyCompletedRoutines,
    int? weeklyGoal,
    int? monthlyCompletedRoutines,
    int? monthlyGoal,
    double? weeklyCompletionRate,
    double? monthlyCompletionRate,
    int? totalDaysActive,
    int? totalDaysSinceStart,
  }) {
    return UserStatsModel(
      totalRoutines: totalRoutines ?? this.totalRoutines,
      totalCompletedSteps: totalCompletedSteps ?? this.totalCompletedSteps,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      currentLevel: currentLevel ?? this.currentLevel,
      totalExperience: totalExperience ?? this.totalExperience,
      experienceToNextLevel:
          experienceToNextLevel ?? this.experienceToNextLevel,
      weeklyCompletedRoutines:
          weeklyCompletedRoutines ?? this.weeklyCompletedRoutines,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      monthlyCompletedRoutines:
          monthlyCompletedRoutines ?? this.monthlyCompletedRoutines,
      monthlyGoal: monthlyGoal ?? this.monthlyGoal,
      weeklyCompletionRate: weeklyCompletionRate ?? this.weeklyCompletionRate,
      monthlyCompletionRate:
          monthlyCompletionRate ?? this.monthlyCompletionRate,
      totalDaysActive: totalDaysActive ?? this.totalDaysActive,
      totalDaysSinceStart: totalDaysSinceStart ?? this.totalDaysSinceStart,
    );
  }

  // JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'totalRoutines': totalRoutines,
      'totalCompletedSteps': totalCompletedSteps,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'currentLevel': currentLevel,
      'totalExperience': totalExperience,
      'experienceToNextLevel': experienceToNextLevel,
      'weeklyCompletedRoutines': weeklyCompletedRoutines,
      'weeklyGoal': weeklyGoal,
      'monthlyCompletedRoutines': monthlyCompletedRoutines,
      'monthlyGoal': monthlyGoal,
      'weeklyCompletionRate': weeklyCompletionRate,
      'monthlyCompletionRate': monthlyCompletionRate,
      'totalDaysActive': totalDaysActive,
      'totalDaysSinceStart': totalDaysSinceStart,
    };
  }

  // JSON에서 객체 생성
  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalRoutines: json['totalRoutines'] ?? 0,
      totalCompletedSteps: json['totalCompletedSteps'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      totalExperience: json['totalExperience'] ?? 0,
      experienceToNextLevel: json['experienceToNextLevel'] ?? 100,
      weeklyCompletedRoutines: json['weeklyCompletedRoutines'] ?? 0,
      weeklyGoal: json['weeklyGoal'] ?? 0,
      monthlyCompletedRoutines: json['monthlyCompletedRoutines'] ?? 0,
      monthlyGoal: json['monthlyGoal'] ?? 0,
      weeklyCompletionRate: (json['weeklyCompletionRate'] ?? 0.0).toDouble(),
      monthlyCompletionRate: (json['monthlyCompletionRate'] ?? 0.0).toDouble(),
      totalDaysActive: json['totalDaysActive'] ?? 0,
      totalDaysSinceStart: json['totalDaysSinceStart'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'UserStatsModel(totalRoutines: $totalRoutines, totalCompletedSteps: $totalCompletedSteps, currentStreak: $currentStreak, longestStreak: $longestStreak, currentLevel: $currentLevel, totalExperience: $totalExperience)';
  }
}
