// 🔗 루틴 통계 연동 서비스
// 실제 루틴 데이터와 사용자 통계를 연동하는 서비스
import 'user_stats_service.dart';

class RoutineStatsIntegration {
  // 루틴 완료 시 통계 업데이트 (실제 루틴 서비스에서 호출)
  static Future<bool> onRoutineCompleted({
    required String routineId,
    required int stepsCompleted,
    required double difficulty,
    required bool isStreakMaintained,
  }) async {
    try {
      // 난이도에 따른 경험치 배수 계산
      double difficultyMultiplier = 1.0;
      if (difficulty >= 0.8) {
        difficultyMultiplier = 1.5; // 어려운 루틴
      } else if (difficulty >= 0.5) {
        difficultyMultiplier = 1.2; // 보통 루틴
      }

      // 연속 달성 보너스 계산
      int streakBonus = isStreakMaintained ? 1 : 0;

      // 경험치 계산
      int experienceGained = UserStatsService.calculateExperienceForRoutine(
        stepsCompleted: stepsCompleted,
        streakBonus: streakBonus,
        difficultyMultiplier: difficultyMultiplier,
      );

      // 통계 업데이트
      return await UserStatsService.updateStatsOnRoutineComplete(
        stepsCompleted: stepsCompleted,
        experienceGained: experienceGained,
      );
    } catch (e) {
      print('루틴 완료 통계 연동 오류: $e');
      return false;
    }
  }

  // 루틴 추가 시 통계 업데이트
  static Future<bool> onRoutineAdded() async {
    try {
      return await UserStatsService.updateStatsOnRoutineAdded();
    } catch (e) {
      print('루틴 추가 통계 연동 오류: $e');
      return false;
    }
  }

  // 루틴 삭제 시 통계 업데이트
  static Future<bool> onRoutineDeleted() async {
    try {
      final currentStats = UserStatsService.currentStats;
      final updatedStats = currentStats.copyWith(
        totalRoutines:
            (currentStats.totalRoutines - 1).clamp(0, double.infinity).toInt(),
      );
      return await UserStatsService.saveStats(updatedStats);
    } catch (e) {
      print('루틴 삭제 통계 연동 오류: $e');
      return false;
    }
  }

  // 연속 달성 리셋 (루틴을 하루 놓쳤을 때)
  static Future<bool> onStreakBroken() async {
    try {
      return await UserStatsService.resetStreak();
    } catch (e) {
      print('연속 달성 리셋 오류: $e');
      return false;
    }
  }

  // 주간 목표 설정
  static Future<bool> setWeeklyGoal(int goal) async {
    try {
      return await UserStatsService.setWeeklyGoal(goal);
    } catch (e) {
      print('주간 목표 설정 오류: $e');
      return false;
    }
  }

  // 월간 목표 설정
  static Future<bool> setMonthlyGoal(int goal) async {
    try {
      return await UserStatsService.setMonthlyGoal(goal);
    } catch (e) {
      print('월간 목표 설정 오류: $e');
      return false;
    }
  }

  // 실제 루틴 데이터에서 통계 계산 (예시)
  static Future<Map<String, dynamic>> calculateStatsFromRoutines() async {
    try {
      // 실제 루틴 데이터베이스에서 데이터 가져오기 (구현 예정)
      // 임시 예시 데이터
      final routineData = {
        'totalRoutines': 5,
        'totalSteps': 127,
        'completedToday': 3,
        'currentStreak': 7,
        'longestStreak': 15,
        'weeklyCompleted': 12,
        'monthlyCompleted': 45,
        'totalDaysActive': 25,
        'totalDaysSinceStart': 30,
      };

      return routineData;
    } catch (e) {
      print('루틴 데이터 통계 계산 오류: $e');
      return {};
    }
  }

  // 통계 동기화 (실제 루틴 데이터와 통계 데이터 동기화)
  static Future<bool> syncStatsWithRoutines() async {
    try {
      final routineData = await calculateStatsFromRoutines();

      if (routineData.isEmpty) {
        return false;
      }

      // 현재 통계 가져오기
      final currentStats = UserStatsService.currentStats;

      // 새로운 통계 생성
      final updatedStats = currentStats.copyWith(
        totalRoutines:
            routineData['totalRoutines'] ?? currentStats.totalRoutines,
        totalCompletedSteps:
            routineData['totalSteps'] ?? currentStats.totalCompletedSteps,
        currentStreak:
            routineData['currentStreak'] ?? currentStats.currentStreak,
        longestStreak:
            routineData['longestStreak'] ?? currentStats.longestStreak,
        weeklyCompletedRoutines: routineData['weeklyCompleted'] ??
            currentStats.weeklyCompletedRoutines,
        monthlyCompletedRoutines: routineData['monthlyCompleted'] ??
            currentStats.monthlyCompletedRoutines,
        totalDaysActive:
            routineData['totalDaysActive'] ?? currentStats.totalDaysActive,
        totalDaysSinceStart: routineData['totalDaysSinceStart'] ??
            currentStats.totalDaysSinceStart,
      );

      return await UserStatsService.saveStats(updatedStats);
    } catch (e) {
      print('통계 동기화 오류: $e');
      return false;
    }
  }

  // 일일 통계 리셋 (매일 자정에 호출)
  static Future<bool> resetDailyStats() async {
    try {
      // TODO: 실제로는 날짜 체크 로직이 필요
      // 연속 달성이 끊어졌는지 확인하고 리셋
      return true;
    } catch (e) {
      print('일일 통계 리셋 오류: $e');
      return false;
    }
  }

  // 주간 통계 리셋 (매주 월요일에 호출)
  static Future<bool> resetWeeklyStats() async {
    try {
      final currentStats = UserStatsService.currentStats;
      final updatedStats = currentStats.copyWith(
        weeklyCompletedRoutines: 0,
      );
      return await UserStatsService.saveStats(updatedStats);
    } catch (e) {
      print('주간 통계 리셋 오류: $e');
      return false;
    }
  }

  // 월간 통계 리셋 (매월 1일에 호출)
  static Future<bool> resetMonthlyStats() async {
    try {
      final currentStats = UserStatsService.currentStats;
      final updatedStats = currentStats.copyWith(
        monthlyCompletedRoutines: 0,
      );
      return await UserStatsService.saveStats(updatedStats);
    } catch (e) {
      print('월간 통계 리셋 오류: $e');
      return false;
    }
  }
}
