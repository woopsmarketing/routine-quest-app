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
      // 오류 발생 시 빈 목록 반환
      return [];
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
