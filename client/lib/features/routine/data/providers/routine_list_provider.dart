// 📋 루틴 목록 전역 상태 관리 프로바이더
// 모든 페이지에서 동일한 루틴 데이터를 공유하기 위한 프로바이더
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';

// 루틴 목록 상태 모델
class RoutineListState {
  final List<Map<String, dynamic>> routines;
  final bool isLoading;
  final String? error;

  const RoutineListState({
    this.routines = const [],
    this.isLoading = false,
    this.error,
  });

  RoutineListState copyWith({
    List<Map<String, dynamic>>? routines,
    bool? isLoading,
    String? error,
  }) {
    return RoutineListState(
      routines: routines ?? this.routines,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// 루틴 목록 상태 관리 노티파이어
class RoutineListNotifier extends StateNotifier<RoutineListState> {
  RoutineListNotifier() : super(const RoutineListState());

  // 루틴 목록 로드
  Future<void> loadRoutines() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final routines = await ApiClient.getRoutines();
      state = state.copyWith(
        routines: routines,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 오늘 표시 토글
  Future<void> toggleTodayDisplay(int routineId) async {
    try {
      // 로컬 상태에서 먼저 토글
      final updatedRoutines = state.routines.map((routine) {
        if (routine['id'] == routineId) {
          return {
            ...routine,
            'today_display': !(routine['today_display'] ?? false),
          };
        }
        return routine;
      }).toList();

      state = state.copyWith(routines: updatedRoutines);

      // 백엔드 API 호출 (백그라운드에서)
      ApiClient.toggleTodayDisplay(routineId).catchError((e) {
        print('백엔드 API 호출 실패: $e');
        // 실패 시 원래 상태로 되돌리기
        loadRoutines();
        return <String, dynamic>{}; // 빈 맵 반환
      });
    } catch (e) {
      print('토글 실패: $e');
    }
  }

  // 루틴 활성화/비활성화 토글
  Future<void> toggleRoutine(int routineId) async {
    try {
      // 로컬 상태에서 먼저 토글
      final updatedRoutines = state.routines.map((routine) {
        if (routine['id'] == routineId) {
          return {
            ...routine,
            'is_active': !(routine['is_active'] ?? false),
          };
        }
        return routine;
      }).toList();

      state = state.copyWith(routines: updatedRoutines);

      // 백엔드 API 호출 (백그라운드에서)
      ApiClient.toggleRoutine(routineId).catchError((e) {
        print('백엔드 API 호출 실패: $e');
        // 실패 시 원래 상태로 되돌리기
        loadRoutines();
        return <String, dynamic>{}; // 빈 맵 반환
      });
    } catch (e) {
      print('토글 실패: $e');
    }
  }

  // 루틴 삭제
  Future<void> deleteRoutine(int routineId) async {
    try {
      // 로컬 상태에서 먼저 제거
      final updatedRoutines = state.routines
          .where((routine) => routine['id'] != routineId)
          .toList();

      state = state.copyWith(routines: updatedRoutines);

      // 백엔드 API 호출 (백그라운드에서)
      ApiClient.deleteRoutine(routineId).catchError((e) {
        print('백엔드 API 호출 실패: $e');
        // 실패 시 원래 상태로 되돌리기
        loadRoutines();
      });
    } catch (e) {
      print('삭제 실패: $e');
    }
  }

  // 오늘 표시 루틴들만 필터링
  List<Map<String, dynamic>> get todayDisplayRoutines {
    return state.routines
        .where((routine) => routine['today_display'] == true)
        .toList();
  }

  // 숨김 루틴들만 필터링
  List<Map<String, dynamic>> get hiddenRoutines {
    return state.routines
        .where((routine) => routine['today_display'] != true)
        .toList();
  }
}

// 프로바이더 인스턴스
final routineListProvider =
    StateNotifierProvider<RoutineListNotifier, RoutineListState>(
  (ref) => RoutineListNotifier(),
);

// 편의 프로바이더들
final todayDisplayRoutinesProvider =
    Provider<List<Map<String, dynamic>>>((ref) {
  return ref
      .watch(routineListProvider)
      .routines
      .where((routine) => routine['today_display'] == true)
      .toList();
});

final hiddenRoutinesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref
      .watch(routineListProvider)
      .routines
      .where((routine) => routine['today_display'] != true)
      .toList();
});
