// 🎯 루틴 완료 상태 관리 Provider
// 오늘 완료된 루틴들을 추적하고 UI에 반영
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../routine_completion_storage.dart';

// 📊 루틴 완료 상태 모델
class RoutineCompletionState {
  final Set<String> completedRoutineIds;
  final bool isLoading;
  final String? error;

  const RoutineCompletionState({
    this.completedRoutineIds = const {},
    this.isLoading = false,
    this.error,
  });

  RoutineCompletionState copyWith({
    Set<String>? completedRoutineIds,
    bool? isLoading,
    String? error,
  }) {
    return RoutineCompletionState(
      completedRoutineIds: completedRoutineIds ?? this.completedRoutineIds,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // 특정 루틴이 완료되었는지 확인
  bool isRoutineCompleted(String routineId) {
    return completedRoutineIds.contains(routineId);
  }

  // 완료된 루틴 수
  int get completedCount => completedRoutineIds.length;
}

// 🎯 루틴 완료 상태 Provider
class RoutineCompletionNotifier extends StateNotifier<RoutineCompletionState> {
  RoutineCompletionNotifier() : super(const RoutineCompletionState()) {
    _loadTodayCompletions();
  }

  // 📱 오늘 완료된 루틴 목록 로드
  Future<void> _loadTodayCompletions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final completedRoutines =
          await RoutineCompletionStorage.getTodayCompletedRoutines();
      state = state.copyWith(
        completedRoutineIds: completedRoutines,
        isLoading: false,
      );
      print('오늘 완료된 루틴 로드 완료: ${completedRoutines.length}개');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '완료된 루틴을 불러오는데 실패했습니다: $e',
      );
      print('완료된 루틴 로드 오류: $e');
    }
  }

  // ✅ 루틴 완료 처리
  Future<void> markRoutineAsCompleted(String routineId) async {
    try {
      // 로컬 스토리지에 저장
      await RoutineCompletionStorage.markRoutineAsCompleted(routineId);

      // 상태 업데이트
      final newCompletedIds = Set<String>.from(state.completedRoutineIds);
      newCompletedIds.add(routineId);

      state = state.copyWith(completedRoutineIds: newCompletedIds);

      print('루틴 완료 처리: $routineId');
    } catch (e) {
      state = state.copyWith(error: '루틴 완료 처리 실패: $e');
      print('루틴 완료 처리 오류: $e');
    }
  }

  // 🔄 완료 상태 새로고침
  Future<void> refresh() async {
    await _loadTodayCompletions();
  }

  // 🧹 오늘 완료 상태 초기화 (테스트용)
  Future<void> clearTodayCompletions() async {
    try {
      await RoutineCompletionStorage.clearTodayCompletions();
      state = state.copyWith(completedRoutineIds: {});
      print('오늘 완료 상태 초기화 완료');
    } catch (e) {
      state = state.copyWith(error: '완료 상태 초기화 실패: $e');
      print('완료 상태 초기화 오류: $e');
    }
  }

  // 📊 오늘 통계 가져오기
  Future<Map<String, dynamic>> getTodayStats() async {
    return await RoutineCompletionStorage.getTodayStats();
  }
}

// 🎯 Provider 정의
final routineCompletionProvider =
    StateNotifierProvider<RoutineCompletionNotifier, RoutineCompletionState>(
        (ref) {
  return RoutineCompletionNotifier();
});

// 🎯 특정 루틴 완료 여부 확인 Provider
final isRoutineCompletedProvider =
    Provider.family<bool, String>((ref, routineId) {
  final completionState = ref.watch(routineCompletionProvider);
  return completionState.isRoutineCompleted(routineId);
});

// 🎯 오늘 완료 통계 Provider
final todayCompletionStatsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final notifier = ref.read(routineCompletionProvider.notifier);
  return await notifier.getTodayStats();
});
