// 📱 루틴 완료 상태 로컬 스토리지 관리
// SharedPreferences를 사용하여 앱 재시작 시에도 완료 상태 유지
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RoutineCompletionStorage {
  static const String _completedRoutinesKey = 'completed_routines';

  // 🎯 오늘 완료된 루틴 ID 목록 가져오기
  static Future<Set<String>> getTodayCompletedRoutines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayString();

      // 오늘 날짜의 완료 데이터 가져오기
      final completionData = prefs.getString('${_completedRoutinesKey}_$today');
      if (completionData != null) {
        final List<dynamic> completedList = json.decode(completionData);
        return completedList.map((e) => e.toString()).toSet();
      }

      return <String>{};
    } catch (e) {
      print('완료된 루틴 목록 가져오기 오류: $e');
      return <String>{};
    }
  }

  // ✅ 루틴 완료 상태 저장
  static Future<void> markRoutineAsCompleted(String routineId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayString();

      // 현재 완료된 루틴 목록 가져오기
      final completedRoutines = await getTodayCompletedRoutines();
      completedRoutines.add(routineId);

      // 오늘 날짜로 저장
      final completionData = json.encode(completedRoutines.toList());
      await prefs.setString('${_completedRoutinesKey}_$today', completionData);

      print('루틴 완료 저장: $routineId (날짜: $today)');
    } catch (e) {
      print('루틴 완료 저장 오류: $e');
    }
  }

  // 🔄 루틴 완료 상태 초기화 (테스트용)
  static Future<void> clearTodayCompletions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayString();
      await prefs.remove('${_completedRoutinesKey}_$today');
      print('오늘 완료 상태 초기화 완료');
    } catch (e) {
      print('완료 상태 초기화 오류: $e');
    }
  }

  // 📅 특정 루틴이 오늘 완료되었는지 확인
  static Future<bool> isRoutineCompletedToday(String routineId) async {
    final completedRoutines = await getTodayCompletedRoutines();
    return completedRoutines.contains(routineId);
  }

  // 🕛 하루가 지났는지 확인 (자정 이후인지 체크)
  static Future<bool> isNewDay() async {
    final now = DateTime.now();
    final lastReset = await _getLastResetTime();

    // 마지막 리셋 시간이 없으면 오늘을 첫 날로 설정하고 false 반환
    if (lastReset == null) {
      // 첫 실행이므로 오늘을 리셋 시간으로 설정
      await setLastResetTime();
      return false; // 새로운 하루가 아님
    }

    final today = DateTime(now.year, now.month, now.day);
    final lastResetDay =
        DateTime(lastReset.year, lastReset.month, lastReset.day);

    // 날짜가 다르면 새로운 하루
    return today.isAfter(lastResetDay);
  }

  // 🕛 마지막 리셋 시간 가져오기
  static Future<DateTime?> _getLastResetTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastResetString = prefs.getString('last_reset_time');
      if (lastResetString != null) {
        return DateTime.parse(lastResetString);
      }
    } catch (e) {
      print('마지막 리셋 시간 가져오기 오류: $e');
    }
    return null; // 첫 실행으로 간주
  }

  // 🕛 마지막 리셋 시간 저장
  static Future<void> setLastResetTime() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString('last_reset_time', now.toIso8601String());
  }

  // 🗓️ 오늘 날짜 문자열 생성 (YYYY-MM-DD 형식)
  static String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // 📊 오늘 완료 통계 가져오기
  static Future<Map<String, dynamic>> getTodayStats() async {
    try {
      final completedRoutines = await getTodayCompletedRoutines();
      return {
        'completedCount': completedRoutines.length,
        'completedRoutines': completedRoutines.toList(),
        'date': _getTodayString(),
      };
    } catch (e) {
      print('오늘 통계 가져오기 오류: $e');
      return {
        'completedCount': 0,
        'completedRoutines': <String>[],
        'date': _getTodayString(),
      };
    }
  }

  // 🧹 오래된 완료 데이터 정리 (영구 보관 - 자동 삭제 안함)
  // 대시보드 캘린더에서 과거 루틴 기록을 계속 볼 수 있도록 영구 보관
  static Future<void> cleanupOldCompletions() async {
    // 영구 보관하므로 아무것도 삭제하지 않음
    print('완료 데이터 영구 보관 - 자동 삭제 비활성화');
  }
}
