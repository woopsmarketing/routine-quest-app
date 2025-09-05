// 🌐 API 클라이언트
// 백엔드 API와 통신하기 위한 HTTP 클라이언트 설정
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://localhost:8000/api/v1';

  // 📋 루틴 관련 API 호출
  static Future<List<Map<String, dynamic>>> getRoutines() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/routines/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('루틴 목록을 가져오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('API 오류: $e');
      // 오류 발생 시 더미 데이터 반환
      return _getDummyRoutines();
    }
  }

  // 📋 특정 루틴 조회
  static Future<Map<String, dynamic>> getRoutine(int routineId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/routines/$routineId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('루틴을 가져오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('API 오류: $e');
      throw Exception('루틴을 가져오는데 실패했습니다');
    }
  }

  // ➕ 새 루틴 생성
  static Future<Map<String, dynamic>> createRoutine(
      Map<String, dynamic> routineData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/routines/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
        body: utf8.encode(json.encode(routineData)),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('루틴 생성에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('API 오류: $e');
      throw Exception('루틴 생성에 실패했습니다');
    }
  }

  // ✏️ 루틴 수정
  static Future<Map<String, dynamic>> updateRoutine(
      int routineId, Map<String, dynamic> routineData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/routines/$routineId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
        body: utf8.encode(json.encode(routineData)),
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('루틴 수정에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('API 오류: $e');
      throw Exception('루틴 수정에 실패했습니다');
    }
  }

  // 🗑️ 루틴 삭제
  static Future<void> deleteRoutine(int routineId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/routines/$routineId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('루틴 삭제에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('API 오류: $e');
      throw Exception('루틴 삭제에 실패했습니다');
    }
  }

  // 🔄 루틴 활성화/비활성화
  static Future<Map<String, dynamic>> toggleRoutine(int routineId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/routines/$routineId/toggle'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('루틴 상태 변경에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('API 오류: $e');
      throw Exception('루틴 상태 변경에 실패했습니다');
    }
  }

  // 📊 루틴 통계 조회
  static Future<Map<String, dynamic>> getRoutineStats(int routineId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/routines/$routineId/stats'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('루틴 통계를 가져오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('API 오류: $e');
      throw Exception('루틴 통계를 가져오는데 실패했습니다');
    }
  }

  // 🎭 더미 데이터 (API 연결 실패 시 사용)
  static List<Map<String, dynamic>> _getDummyRoutines() {
    return [
      {
        'id': 1,
        'title': '생산적인 아침 루틴',
        'description': '아침에 일어나자마자 하는 루틴',
        'icon': '🌅',
        'color': '#6750A4',
        'is_active': true,
        'today_display': false, // 기본적으로 숨김
        'total_completions': 15,
        'success_rate': 85,
        'steps': [
          {
            'id': 1,
            'title': '물마시기',
            'description': '미지근한 물 200ml를 천천히 마셔보세요',
            'order': 1,
            'type': 'habit',
            'difficulty': 'easy',
            't_ref_sec': 120,
          },
          {
            'id': 2,
            'title': '기지개',
            'description': '목, 어깨, 허리를 가볍게 풀어주세요',
            'order': 2,
            'type': 'exercise',
            'difficulty': 'medium',
            't_ref_sec': 300,
          },
          {
            'id': 3,
            'title': '줄넘기',
            'description': '5분간 가벼운 줄넘기',
            'order': 3,
            'type': 'exercise',
            'difficulty': 'medium',
            't_ref_sec': 300,
          },
          {
            'id': 4,
            'title': '명상',
            'description': '5분간 마음의 평정을 찾아보세요',
            'order': 4,
            'type': 'habit',
            'difficulty': 'easy',
            't_ref_sec': 300,
          },
        ]
      },
      {
        'id': 2,
        'title': '저녁 휴식 루틴',
        'description': '휴식을 위한루틴',
        'icon': '🌙',
        'color': '#2196F3',
        'is_active': true,
        'today_display': false, // 기본적으로 숨김
        'total_completions': 12,
        'success_rate': 90,
        'steps': [
          {
            'id': 5,
            'title': '독서',
            'description': '교양 쌓기',
            'order': 1,
            'type': 'habit',
            'difficulty': 'easy',
            't_ref_sec': 1200,
          },
          {
            'id': 6,
            'title': '샤워하기',
            'description': '깨끗이 씻기',
            'order': 2,
            'type': 'action',
            'difficulty': 'easy',
            't_ref_sec': 600,
          },
        ]
      },
      {
        'id': 3,
        'title': '점심루틴',
        'description': '점심',
        'icon': '🍽️',
        'color': '#FF9800',
        'is_active': true,
        'today_display': true, // 기본적으로 표시
        'total_completions': 5,
        'success_rate': 80,
        'steps': [
          {
            'id': 7,
            'title': '점심먹기',
            'description': '건강한 점심 식사',
            'order': 1,
            'type': 'action',
            'difficulty': 'easy',
            't_ref_sec': 900,
          },
        ]
      },
    ];
  }

  // 🎯 오늘 페이지 표시 토글
  static Future<Map<String, dynamic>> toggleTodayDisplay(int routineId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/routines/$routineId/today-display'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('오늘 표시 설정에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('API 오류: $e');
      throw Exception('오늘 표시 설정에 실패했습니다');
    }
  }

  // ➕ 루틴에 스텝 추가
  static Future<Map<String, dynamic>> addStepToRoutine(
      int routineId, Map<String, dynamic> stepData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/routines/$routineId/steps'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
        body: utf8.encode(json.encode(stepData)),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('스텝 추가에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('API 오류: $e');
      throw Exception('스텝 추가에 실패했습니다');
    }
  }

  // ✏️ 스텝 수정
  static Future<Map<String, dynamic>> updateStep(
      int routineId, int stepId, Map<String, dynamic> stepData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/routines/$routineId/steps/$stepId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
        body: utf8.encode(json.encode(stepData)),
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('스텝 수정에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('API 오류: $e');
      throw Exception('스텝 수정에 실패했습니다');
    }
  }

  // 🗑️ 스텝 삭제
  static Future<void> deleteStep(int routineId, int stepId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/routines/$routineId/steps/$stepId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('스텝 삭제에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('API 오류: $e');
      throw Exception('스텝 삭제에 실패했습니다');
    }
  }

  // 🔄 스텝 순서 변경
  static Future<Map<String, dynamic>> reorderStep(
      int routineId, int stepId, int newOrder) async {
    try {
      final response = await http.patch(
        Uri.parse(
            '$baseUrl/routines/$routineId/steps/$stepId/reorder?new_order=$newOrder'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('스텝 순서 변경에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('API 오류: $e');
      throw Exception('스텝 순서 변경에 실패했습니다');
    }
  }
}
