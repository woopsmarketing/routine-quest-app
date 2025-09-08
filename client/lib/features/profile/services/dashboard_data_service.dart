// 📊 대시보드 데이터 서비스
// 실제 대시보드에서 사용하는 데이터를 가져와서 통계에 반영하는 서비스
import 'user_stats_service.dart';
import '../data/user_stats_model.dart';
import '../../../../shared/services/user_progress_service.dart';
import '../../../../core/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DashboardDataService {
  // 실제 대시보드 데이터에서 통계 업데이트
  static Future<bool> updateStatsFromDashboard({
    required int totalRoutines,
    required int totalCompletedSteps,
    required int currentStreak,
    required int totalExperience,
    required int weeklyCompleted,
    required int monthlyCompleted,
    required int totalDaysActive,
  }) async {
    try {
      // 현재 통계 가져오기
      final currentStats = UserStatsService.currentStats;

      // 새로운 레벨 계산
      final newLevel =
          UserStatsModel.calculateLevelFromExperience(totalExperience);
      final newExperienceToNextLevel = 1000 - (totalExperience % 1000);

      // 통계 업데이트
      final updatedStats = currentStats.copyWith(
        totalRoutines: totalRoutines,
        totalCompletedSteps: totalCompletedSteps,
        currentStreak: currentStreak,
        currentLevel: newLevel,
        totalExperience: totalExperience,
        experienceToNextLevel: newExperienceToNextLevel,
        weeklyCompletedRoutines: weeklyCompleted,
        monthlyCompletedRoutines: monthlyCompleted,
        totalDaysActive: totalDaysActive,
      );

      return await UserStatsService.saveStats(updatedStats);
    } catch (e) {
      print('대시보드 데이터 통계 업데이트 오류: $e');
      return false;
    }
  }

  // 실제 대시보드에서 데이터 가져오기
  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      // UserProgressService에서 실제 데이터 가져오기
      final userStats = await UserProgressService.getUserStats();
      final todayStats = await UserProgressService.getTodayStats();
      final streakDays = await UserProgressService.getStreakDays();

      // 현재 활성 루틴 개수 가져오기 (백엔드 API에서)
      final currentRoutines = await _getCurrentRoutineCount();

      // SharedPreferences에서 루틴 히스토리 가져오기
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('routine_history') ?? '{}';
      final historyData = Map<String, dynamic>.from(json.decode(historyJson));

      // 히스토리에서 통계 계산 (총 루틴 수는 현재 루틴 개수 사용)
      int totalCompletedSteps = 0;
      int totalDaysActive = 0;

      for (final dateKey in historyData.keys) {
        final dayRecords =
            List<Map<String, dynamic>>.from(historyData[dateKey] ?? []);
        if (dayRecords.isNotEmpty) {
          totalDaysActive++;
        }

        for (final record in dayRecords) {
          totalCompletedSteps += record['completed_steps'] as int;
        }
      }

      // 이번 주/월 완료 루틴 수 계산
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);

      int weeklyCompleted = 0;
      int monthlyCompleted = 0;

      for (final dateKey in historyData.keys) {
        final date = DateTime.parse(dateKey);
        final dayRecords =
            List<Map<String, dynamic>>.from(historyData[dateKey] ?? []);

        if (date.isAfter(weekStart.subtract(Duration(days: 1)))) {
          weeklyCompleted += dayRecords.length;
        }

        if (date.isAfter(monthStart.subtract(Duration(days: 1)))) {
          monthlyCompleted += dayRecords.length;
        }
      }

      return {
        'totalRoutines': currentRoutines, // 현재 활성 루틴 수 (실시간 연동)
        'totalCompletedSteps': totalCompletedSteps, // 실제 완료 스텝 수
        'currentStreak': streakDays, // 실제 연속 달성 일수
        'totalExperience': userStats['exp'] as int, // 실제 총 경험치
        'weeklyCompleted': weeklyCompleted, // 이번 주 완료한 루틴 수
        'monthlyCompleted': monthlyCompleted, // 이번 달 완료한 루틴 수
        'totalDaysActive': totalDaysActive, // 실제 활동 일수
        'longestStreak': streakDays, // 최고 연속도 (현재는 현재 연속과 동일)
        'weeklyGoal': UserStatsService.currentStats.weeklyGoal, // 사용자 설정 주간 목표
        'monthlyGoal':
            UserStatsService.currentStats.monthlyGoal, // 사용자 설정 월간 목표
        'todayExp': todayStats['todayExp'] as int, // 오늘 획득 EXP
        'completionRate': todayStats['completionRate'] as int, // 완료율
      };
    } catch (e) {
      print('대시보드 데이터 가져오기 오류: $e');
      return {};
    }
  }

  // 대시보드 데이터로 통계 동기화
  static Future<bool> syncStatsWithDashboard() async {
    try {
      final dashboardData = await getDashboardData();

      if (dashboardData.isEmpty) {
        return false;
      }

      final result = await updateStatsFromDashboard(
        totalRoutines: dashboardData['totalRoutines'] ?? 0,
        totalCompletedSteps: dashboardData['totalCompletedSteps'] ?? 0,
        currentStreak: dashboardData['currentStreak'] ?? 0,
        totalExperience: dashboardData['totalExperience'] ?? 0,
        weeklyCompleted: dashboardData['weeklyCompleted'] ?? 0,
        monthlyCompleted: dashboardData['monthlyCompleted'] ?? 0,
        totalDaysActive: dashboardData['totalDaysActive'] ?? 0,
      );

      if (result) {
        print(
            '대시보드 데이터 동기화 완료: ${dashboardData['totalRoutines']}개 루틴, ${dashboardData['totalExperience']} XP');
      }

      return result;
    } catch (e) {
      print('대시보드 통계 동기화 오류: $e');
      return false;
    }
  }

  // 루틴 완료 시 대시보드 데이터 업데이트
  static Future<bool> onRoutineCompleted({
    required int stepsCompleted,
    required int experienceGained,
  }) async {
    try {
      // 대시보드 데이터 가져오기
      final dashboardData = await getDashboardData();

      // 완료된 스텝과 경험치 추가
      final newTotalSteps =
          (dashboardData['totalCompletedSteps'] ?? 0) + stepsCompleted;
      final newTotalExperience =
          (dashboardData['totalExperience'] ?? 0) + experienceGained;
      final newWeeklyCompleted = (dashboardData['weeklyCompleted'] ?? 0) + 1;
      final newMonthlyCompleted = (dashboardData['monthlyCompleted'] ?? 0) + 1;
      final newTotalDaysActive = (dashboardData['totalDaysActive'] ?? 0) + 1;

      // 연속 달성 체크 (실제로는 날짜 로직 필요)
      final newCurrentStreak = (dashboardData['currentStreak'] ?? 0) + 1;
      // final newLongestStreak = (dashboardData['longestStreak'] ?? 0); // 향후 longestStreak 업데이트에 사용 예정

      return await updateStatsFromDashboard(
        totalRoutines: dashboardData['totalRoutines'] ?? 0,
        totalCompletedSteps: newTotalSteps,
        currentStreak: newCurrentStreak,
        totalExperience: newTotalExperience,
        weeklyCompleted: newWeeklyCompleted,
        monthlyCompleted: newMonthlyCompleted,
        totalDaysActive: newTotalDaysActive,
      );
    } catch (e) {
      print('루틴 완료 대시보드 업데이트 오류: $e');
      return false;
    }
  }

  // 현재 활성 루틴 개수 가져오기 (백엔드 API에서)
  static Future<int> _getCurrentRoutineCount() async {
    try {
      // 백엔드 API에서 현재 루틴 목록 가져오기
      final routines = await ApiClient.getRoutines();
      return routines.length;
    } catch (e) {
      print('현재 루틴 개수 가져오기 오류: $e');
      // API 오류 시 기본값 반환
      return 0;
    }
  }
}
