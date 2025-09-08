// 🏆 성취도 모델
// 사용자의 성취와 배지를 관리하는 모델
class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementType type;
  final int requirement;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int experienceReward;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.requirement,
    required this.isUnlocked,
    this.unlockedAt,
    required this.experienceReward,
  });

  // 성취도 복사본 생성
  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    AchievementType? type,
    int? requirement,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? experienceReward,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      requirement: requirement ?? this.requirement,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      experienceReward: experienceReward ?? this.experienceReward,
    );
  }

  // JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type.toString(),
      'requirement': requirement,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'experienceReward': experienceReward,
    };
  }

  // JSON에서 객체 생성
  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AchievementType.streak,
      ),
      requirement: json['requirement'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      experienceReward: json['experienceReward'] ?? 0,
    );
  }
}

// 성취도 타입
enum AchievementType {
  streak, // 연속 달성
  total, // 총 완료
  level, // 레벨 달성
  weekly, // 주간 목표
  monthly, // 월간 목표
  special, // 특별 성취
}

// 기본 성취도 목록
class DefaultAchievements {
  static const List<AchievementModel> achievements = [
    // 연속 달성 성취도
    AchievementModel(
      id: 'streak_3',
      title: '첫 걸음',
      description: '3일 연속 루틴 완료',
      icon: '🔥',
      type: AchievementType.streak,
      requirement: 3,
      isUnlocked: false,
      experienceReward: 50,
    ),
    AchievementModel(
      id: 'streak_7',
      title: '일주일의 기적',
      description: '7일 연속 루틴 완료',
      icon: '🌟',
      type: AchievementType.streak,
      requirement: 7,
      isUnlocked: false,
      experienceReward: 100,
    ),
    AchievementModel(
      id: 'streak_30',
      title: '한 달의 달인',
      description: '30일 연속 루틴 완료',
      icon: '👑',
      type: AchievementType.streak,
      requirement: 30,
      isUnlocked: false,
      experienceReward: 500,
    ),

    // 총 완료 성취도
    AchievementModel(
      id: 'total_50',
      title: '루틴 초보자',
      description: '총 50개 스텝 완료',
      icon: '🎯',
      type: AchievementType.total,
      requirement: 50,
      isUnlocked: false,
      experienceReward: 75,
    ),
    AchievementModel(
      id: 'total_200',
      title: '루틴 마스터',
      description: '총 200개 스텝 완료',
      icon: '🏆',
      type: AchievementType.total,
      requirement: 200,
      isUnlocked: false,
      experienceReward: 200,
    ),
    AchievementModel(
      id: 'total_500',
      title: '루틴 전설',
      description: '총 500개 스텝 완료',
      icon: '💎',
      type: AchievementType.total,
      requirement: 500,
      isUnlocked: false,
      experienceReward: 500,
    ),

    // 레벨 성취도
    AchievementModel(
      id: 'level_5',
      title: '성장하는 루틴러',
      description: '레벨 5 달성',
      icon: '⭐',
      type: AchievementType.level,
      requirement: 5,
      isUnlocked: false,
      experienceReward: 100,
    ),
    AchievementModel(
      id: 'level_10',
      title: '루틴의 달인',
      description: '레벨 10 달성',
      icon: '🌟',
      type: AchievementType.level,
      requirement: 10,
      isUnlocked: false,
      experienceReward: 300,
    ),

    // 주간 목표 성취도
    AchievementModel(
      id: 'weekly_perfect',
      title: '완벽한 한 주',
      description: '주간 목표 100% 달성',
      icon: '🎊',
      type: AchievementType.weekly,
      requirement: 100,
      isUnlocked: false,
      experienceReward: 150,
    ),

    // 월간 목표 성취도
    AchievementModel(
      id: 'monthly_perfect',
      title: '완벽한 한 달',
      description: '월간 목표 100% 달성',
      icon: '🎉',
      type: AchievementType.monthly,
      requirement: 100,
      isUnlocked: false,
      experienceReward: 400,
    ),

    // 특별 성취도
    AchievementModel(
      id: 'early_bird',
      title: '일찍 일어나는 새',
      description: '아침 6시 이전에 루틴 완료',
      icon: '🐦',
      type: AchievementType.special,
      requirement: 1,
      isUnlocked: false,
      experienceReward: 50,
    ),
    AchievementModel(
      id: 'night_owl',
      title: '올빼미',
      description: '밤 11시 이후에 루틴 완료',
      icon: '🦉',
      type: AchievementType.special,
      requirement: 1,
      isUnlocked: false,
      experienceReward: 50,
    ),
  ];

  // 성취도 잠금 해제 체크
  static List<AchievementModel> checkAchievements({
    required int currentStreak,
    required int totalCompletedSteps,
    required int currentLevel,
    required double weeklyProgress,
    required double monthlyProgress,
    required List<AchievementModel> currentAchievements,
  }) {
    List<AchievementModel> updatedAchievements = List.from(currentAchievements);

    for (int i = 0; i < updatedAchievements.length; i++) {
      final achievement = updatedAchievements[i];

      if (achievement.isUnlocked) continue; // 이미 잠금 해제된 성취도는 스킵

      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.streak:
          shouldUnlock = currentStreak >= achievement.requirement;
          break;
        case AchievementType.total:
          shouldUnlock = totalCompletedSteps >= achievement.requirement;
          break;
        case AchievementType.level:
          shouldUnlock = currentLevel >= achievement.requirement;
          break;
        case AchievementType.weekly:
          shouldUnlock = (weeklyProgress * 100) >= achievement.requirement;
          break;
        case AchievementType.monthly:
          shouldUnlock = (monthlyProgress * 100) >= achievement.requirement;
          break;
        case AchievementType.special:
          // 특별 성취도는 별도 로직 필요
          shouldUnlock = false;
          break;
      }

      if (shouldUnlock) {
        updatedAchievements[i] = achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
      }
    }

    return updatedAchievements;
  }
}
