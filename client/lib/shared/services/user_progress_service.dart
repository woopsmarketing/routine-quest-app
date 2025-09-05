// 🎮 사용자 진행 상황 관리 서비스
// RPG 시스템의 경험치, 레벨, 루틴 기록 관리
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProgressService {
  static const String _userLevelKey = 'user_level';
  static const String _userExpKey = 'user_exp';
  static const String _userTitleKey = 'user_title';
  static const String _routineHistoryKey = 'routine_history';

  // 레벨별 타이틀 정의
  static const Map<int, String> _levelTitles = {
    1: '루틴 초보자',
    5: '루틴 학습자',
    10: '루틴 실행자',
    15: '루틴 전문가',
    20: '루틴 마스터',
    30: '라이프스타일 구루',
    50: '루틴의 신',
  };

  // 경험치 획득 및 레벨업 처리
  static Future<Map<String, dynamic>> addExperience(int exp) async {
    final prefs = await SharedPreferences.getInstance();

    final currentLevel = prefs.getInt(_userLevelKey) ?? 1;
    final currentExp = prefs.getInt(_userExpKey) ?? 0;

    final newExp = currentExp + exp;
    final expForNextLevel = _calculateExpForLevel(currentLevel + 1);

    int newLevel = currentLevel;
    bool leveledUp = false;

    // 레벨업 체크
    if (newExp >= expForNextLevel) {
      newLevel = currentLevel + 1;
      leveledUp = true;

      // 새 타이틀 설정
      final newTitle = _getTitleForLevel(newLevel);
      await prefs.setString(_userTitleKey, newTitle);
    }

    // 데이터 저장
    await prefs.setInt(_userLevelKey, newLevel);
    await prefs.setInt(_userExpKey, newExp);

    return {
      'leveledUp': leveledUp,
      'oldLevel': currentLevel,
      'newLevel': newLevel,
      'currentExp': newExp,
      'expForNextLevel': _calculateExpForLevel(newLevel + 1),
      'title': _getTitleForLevel(newLevel),
    };
  }

  // 오늘 이미 완료한 루틴인지 확인
  static Future<bool> hasCompletedRoutineToday(String routineName) async {
    final prefs = await SharedPreferences.getInstance();

    // 오늘 날짜 키
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // 기존 기록 불러오기
    final historyJson = prefs.getString(_routineHistoryKey) ?? '{}';
    final historyData = Map<String, dynamic>.from(json.decode(historyJson));

    // 오늘 기록 확인
    final todayRecords =
        List<Map<String, dynamic>>.from(historyData[dateKey] ?? []);

    // 같은 루틴이 이미 완료되었는지 확인
    return todayRecords.any((record) => record['routine'] == routineName);
  }

  // 루틴 완료 기록 저장
  static Future<void> saveRoutineCompletion({
    required String routineName,
    required int completedSteps,
    required int totalSteps,
    required int timeTakenSeconds,
    required int expGained,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // 오늘 날짜 키
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // 기존 기록 불러오기
    final historyJson = prefs.getString(_routineHistoryKey) ?? '{}';
    final historyData = Map<String, dynamic>.from(json.decode(historyJson));

    // 오늘 기록 가져오기 또는 생성
    final todayRecords =
        List<Map<String, dynamic>>.from(historyData[dateKey] ?? []);

    // 새 기록 추가
    todayRecords.add({
      'routine': routineName,
      'exp': expGained,
      'completed_steps': completedSteps,
      'total_steps': totalSteps,
      'time_taken': '${(timeTakenSeconds / 60).round()}분',
      'completed_at': DateTime.now().toIso8601String(),
    });

    // 업데이트된 기록 저장
    historyData[dateKey] = todayRecords;
    await prefs.setString(_routineHistoryKey, json.encode(historyData));
  }

  // 사용자 통계 불러오기
  static Future<Map<String, dynamic>> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();

    final level = prefs.getInt(_userLevelKey) ?? 1;
    final exp = prefs.getInt(_userExpKey) ?? 0;
    final title = prefs.getString(_userTitleKey) ?? _getTitleForLevel(level);

    return {
      'level': level,
      'exp': exp,
      'title': title,
      'expForNextLevel': _calculateExpForLevel(level + 1),
      'expRemaining': _calculateExpForLevel(level + 1) - exp,
    };
  }

  // 오늘의 통계 계산
  static Future<Map<String, dynamic>> getTodayStats() async {
    final prefs = await SharedPreferences.getInstance();

    // 오늘 날짜 키
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // 기록 불러오기
    final historyJson = prefs.getString(_routineHistoryKey) ?? '{}';
    final historyData = Map<String, dynamic>.from(json.decode(historyJson));
    final todayRecords =
        List<Map<String, dynamic>>.from(historyData[dateKey] ?? []);

    // 통계 계산
    int totalExp = 0;
    int completedRoutines = todayRecords.length;
    int totalSteps = 0;
    int completedSteps = 0;
    int totalTimeSeconds = 0;

    for (final record in todayRecords) {
      totalExp += record['exp'] as int;
      totalSteps += record['total_steps'] as int;
      completedSteps += record['completed_steps'] as int;

      // 시간 파싱 (예: "25분" -> 1500초)
      final timeStr = record['time_taken'] as String;
      totalTimeSeconds += _parseTimeToSeconds(timeStr);
    }

    final completionRate =
        totalSteps > 0 ? (completedSteps / totalSteps * 100).round() : 0;

    return {
      'todayExp': totalExp,
      'completedRoutines': completedRoutines,
      'completionRate': completionRate,
      'totalTimeSeconds': totalTimeSeconds,
    };
  }

  // 연속 일수 계산
  static Future<int> getStreakDays() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_routineHistoryKey) ?? '{}';
    final historyData = Map<String, dynamic>.from(json.decode(historyJson));

    int streak = 0;
    final today = DateTime.now();

    // 어제부터 거슬러 올라가며 연속 일수 계산
    for (int i = 0; i < 365; i++) {
      // 최대 1년
      final checkDate = today.subtract(Duration(days: i));
      final dateKey =
          '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';

      if (historyData.containsKey(dateKey) &&
          (historyData[dateKey] as List).isNotEmpty) {
        streak++;
      } else {
        break; // 연속이 끊어짐
      }
    }

    return streak;
  }

  // 레벨별 필요 경험치 계산
  static int _calculateExpForLevel(int level) {
    return level * 200 + 800; // Lv.1=1000, Lv.2=1200, Lv.3=1400...
  }

  // 레벨에 맞는 타이틀 반환
  static String _getTitleForLevel(int level) {
    // 가장 가까운 레벨의 타이틀 찾기
    String title = _levelTitles[1]!; // 기본값

    for (final entry in _levelTitles.entries) {
      if (level >= entry.key) {
        title = entry.value;
      } else {
        break;
      }
    }

    return title;
  }

  // 스텝 타입별 기본 경험치 정의
  static const Map<String, int> _stepTypeExpMap = {
    'exercise': 50, // 운동 - 높은 경험치
    'learning': 40, // 학습 - 중간 경험치
    'meditation': 35, // 명상 - 중간 경험치
    'hygiene': 25, // 위생 - 기본 경험치
    'nutrition': 30, // 영양 - 기본 경험치
    'social': 35, // 소셜 - 중간 경험치
    'productivity': 45, // 생산성 - 높은 경험치
    'creativity': 40, // 창의성 - 중간 경험치
    'relaxation': 30, // 휴식 - 기본 경험치
  };

  // 루틴 완료 시 경험치 계산 (스텝별 상세 계산)
  static int calculateRoutineExp({
    required List<Map<String, dynamic>> steps,
    required List<Map<String, dynamic>> stepResults,
    required int timeTakenSeconds,
    required int targetTimeSeconds,
  }) {
    int totalExp = 0;

    // 각 완료된 스텝별로 경험치 계산
    for (int i = 0; i < stepResults.length; i++) {
      final stepResult = stepResults[i];
      final step = i < steps.length ? steps[i] : null;

      if (stepResult['status'] == 'completed' && step != null) {
        final stepType = step['step_type'] ?? 'hygiene';
        final targetTime = step['t_ref_sec'] ?? 120;
        final actualTime = stepResult['actualSeconds'] ?? 0;

        // 기본 경험치 (스텝 타입별)
        int stepExp = _stepTypeExpMap[stepType] ?? 25;

        // 시간 효율 보너스/페널티
        if (actualTime <= targetTime * 0.8) {
          stepExp = (stepExp * 1.2).round().toInt(); // 20% 보너스
        } else if (actualTime > targetTime * 1.5) {
          stepExp = (stepExp * 0.8).round().toInt(); // 20% 페널티
        }

        // 스텝 소요시간에 따른 추가 경험치 (긴 스텝일수록 더 많은 EXP)
        final int timeBonus = (targetTime / 60).round(); // 1분당 1 EXP
        stepExp += timeBonus;

        totalExp += stepExp;
      }
    }

    // 완벽 완료 보너스
    final completedCount =
        stepResults.where((r) => r['status'] == 'completed').length;
    if (completedCount == steps.length && steps.isNotEmpty) {
      totalExp += 50; // 완벽 완료 보너스
    }

    // 전체 루틴 시간 보너스
    if (timeTakenSeconds <= targetTimeSeconds) {
      totalExp += 30; // 시간 내 완료 보너스
    }

    return totalExp;
  }

  // 시간 문자열을 초로 변환 (예: "25분" -> 1500)
  static int _parseTimeToSeconds(String timeStr) {
    try {
      if (timeStr.contains('분')) {
        final minutes = int.parse(timeStr.replaceAll('분', ''));
        return minutes * 60;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
