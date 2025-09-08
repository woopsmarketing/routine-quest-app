// 🔧 사용자 통계 서비스
// 사용자의 루틴 통계와 성취도를 관리하는 서비스
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/user_stats_model.dart';

class UserStatsService {
  static const String _statsKey = 'user_stats';
  static UserStatsModel _currentStats = UserStatsModel.defaultStats;

  // 현재 통계 가져오기
  static UserStatsModel get currentStats => _currentStats;

  // 통계 초기화 (앱 시작 시 호출)
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);

      if (statsJson != null) {
        final statsData = json.decode(statsJson);
        _currentStats = UserStatsModel.fromJson(statsData);
      } else {
        // 기본 통계로 초기화
        _currentStats = UserStatsModel.defaultStats;
        await saveStats(_currentStats);
      }
    } catch (e) {
      print('통계 초기화 오류: $e');
      _currentStats = UserStatsModel.defaultStats;
    }
  }

  // 통계 저장
  static Future<bool> saveStats(UserStatsModel stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = json.encode(stats.toJson());
      final success = await prefs.setString(_statsKey, statsJson);

      if (success) {
        _currentStats = stats;
      }

      return success;
    } catch (e) {
      print('통계 저장 오류: $e');
      return false;
    }
  }

  // 루틴 완료 시 통계 업데이트
  static Future<bool> updateStatsOnRoutineComplete({
    required int stepsCompleted,
    required int experienceGained,
  }) async {
    try {
      // 경험치 추가 및 레벨 체크
      int newTotalExperience = _currentStats.totalExperience + experienceGained;
      int newCurrentLevel =
          UserStatsModel.calculateLevelFromExperience(newTotalExperience);
      int newExperienceToNextLevel = 1000 - (newTotalExperience % 1000);

      // 연속 달성 일수 업데이트 (실제로는 날짜 체크 로직이 필요)
      int newCurrentStreak = _currentStats.currentStreak + 1;
      int newLongestStreak = _currentStats.longestStreak;
      if (newCurrentStreak > newLongestStreak) {
        newLongestStreak = newCurrentStreak;
      }

      // 주간/월간 통계 업데이트 (실제로는 날짜 체크 로직이 필요)
      int newWeeklyCompleted = _currentStats.weeklyCompletedRoutines + 1;
      int newMonthlyCompleted = _currentStats.monthlyCompletedRoutines + 1;

      // 새로운 통계 생성
      final updatedStats = _currentStats.copyWith(
        totalCompletedSteps: _currentStats.totalCompletedSteps + stepsCompleted,
        currentStreak: newCurrentStreak,
        longestStreak: newLongestStreak,
        currentLevel: newCurrentLevel,
        totalExperience: newTotalExperience,
        experienceToNextLevel: newExperienceToNextLevel,
        weeklyCompletedRoutines: newWeeklyCompleted,
        monthlyCompletedRoutines: newMonthlyCompleted,
        totalDaysActive: _currentStats.totalDaysActive + 1,
      );

      return await saveStats(updatedStats);
    } catch (e) {
      print('루틴 완료 통계 업데이트 오류: $e');
      return false;
    }
  }

  // 루틴 추가 시 통계 업데이트
  static Future<bool> updateStatsOnRoutineAdded() async {
    try {
      final updatedStats = _currentStats.copyWith(
        totalRoutines: _currentStats.totalRoutines + 1,
      );

      return await saveStats(updatedStats);
    } catch (e) {
      print('루틴 추가 통계 업데이트 오류: $e');
      return false;
    }
  }

  // 연속 달성 리셋 (루틴을 하루 놓쳤을 때)
  static Future<bool> resetStreak() async {
    try {
      final updatedStats = _currentStats.copyWith(
        currentStreak: 0,
      );

      return await saveStats(updatedStats);
    } catch (e) {
      print('연속 달성 리셋 오류: $e');
      return false;
    }
  }

  // 주간 목표 설정
  static Future<bool> setWeeklyGoal(int goal) async {
    try {
      final updatedStats = _currentStats.copyWith(
        weeklyGoal: goal,
      );

      return await saveStats(updatedStats);
    } catch (e) {
      print('주간 목표 설정 오류: $e');
      return false;
    }
  }

  // 월간 목표 설정
  static Future<bool> setMonthlyGoal(int goal) async {
    try {
      final updatedStats = _currentStats.copyWith(
        monthlyGoal: goal,
      );

      return await saveStats(updatedStats);
    } catch (e) {
      print('월간 목표 설정 오류: $e');
      return false;
    }
  }

  // 통계 리셋 (새로 시작할 때)
  static Future<void> resetStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_statsKey);
      _currentStats = UserStatsModel.defaultStats;
    } catch (e) {
      print('통계 리셋 오류: $e');
    }
  }

  // 통계 백업
  static String exportStats() {
    return json.encode(_currentStats.toJson());
  }

  // 통계 복원
  static Future<bool> importStats(String statsJson) async {
    try {
      final statsData = json.decode(statsJson);
      final stats = UserStatsModel.fromJson(statsData);
      return await saveStats(stats);
    } catch (e) {
      print('통계 복원 오류: $e');
      return false;
    }
  }

  // 레벨별 경험치 계산 (루틴 완료 시)
  static int calculateExperienceForRoutine({
    required int stepsCompleted,
    required int streakBonus,
    required double difficultyMultiplier,
  }) {
    int baseExperience = stepsCompleted * 10; // 스텝당 10 경험치
    int streakBonusExp = streakBonus * 5; // 연속 달성 보너스
    int totalExperience =
        (baseExperience + streakBonusExp * difficultyMultiplier).round();

    return totalExperience;
  }

  // 다음 레벨까지 필요한 경험치 계산
  static int calculateExperienceToNextLevel(
      int currentLevel, int currentExperience) {
    if (currentExperience < 1000) {
      // 레벨 1일 때: 1000 - 현재 경험치
      return 1000 - currentExperience;
    } else {
      // 레벨 2 이상일 때: 1000 - (현재 경험치 % 1000)
      return 1000 - (currentExperience % 1000);
    }
  }
}
