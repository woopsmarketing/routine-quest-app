// 🔄 루틴 상태 관리 프로바이더 (Riverpod) - 실제 API 연동
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/step.dart';
import '../../../../core/api/api_client.dart';

// 현재 스텝 프로바이더 (StateNotifier 방식)
class CurrentStepNotifier extends StateNotifier<Step?> {
  CurrentStepNotifier() : super(null);

  List<Step> _currentRoutineSteps = [];
  int _currentStepIndex = 0;
  final Set<String> _completedStepIds = {};

  // 루틴 로드
  Future<void> loadRoutine(int routineId) async {
    try {
      final routine = await ApiClient.getRoutine(routineId);
      final stepsData = routine['steps'] as List<dynamic>;

      _currentRoutineSteps = stepsData
          .map((stepData) => Step(
                id: stepData['id'].toString(),
                title: stepData['title'],
                description: stepData['description'],
                estimatedMinutes: (stepData['t_ref_sec'] as int) ~/ 60,
                type: _mapStepType(stepData['type']),
              ))
          .toList();

      _currentStepIndex = 0;
      _completedStepIds.clear();

      state = _currentRoutineSteps.isNotEmpty ? _currentRoutineSteps[0] : null;
    } catch (e) {
      print('루틴 로드 오류: $e');
      state = null;
    }
  }

  // 스텝 타입 매핑
  StepType _mapStepType(String type) {
    switch (type) {
      case 'habit':
        return StepType.habit;
      case 'exercise':
        return StepType.exercise;
      case 'mindfulness':
        return StepType.mindfulness;
      case 'action':
        return StepType.action;
      default:
        return StepType.habit;
    }
  }

  // 스텝 완료
  void complete() {
    if (state != null) {
      _completedStepIds.add(state!.id);
      _currentStepIndex++;
      state = _currentStepIndex < _currentRoutineSteps.length
          ? _currentRoutineSteps[_currentStepIndex]
          : null;
    }
  }

  // 스텝 스킵
  void skip() {
    _currentStepIndex++;
    state = _currentStepIndex < _currentRoutineSteps.length
        ? _currentRoutineSteps[_currentStepIndex]
        : null;
  }

  // 루틴 리셋
  void reset() {
    _currentStepIndex = 0;
    _completedStepIds.clear();
    state = _currentRoutineSteps.isNotEmpty ? _currentRoutineSteps[0] : null;
  }

  // 진행률 계산
  double getProgress() {
    if (_currentRoutineSteps.isEmpty) return 0.0;
    return _currentStepIndex / _currentRoutineSteps.length;
  }

  // 완료된 스텝 수
  int getCompletedCount() {
    return _completedStepIds.length;
  }

  // 전체 스텝 수
  int getTotalSteps() {
    return _currentRoutineSteps.length;
  }

  // 루틴 완료 여부
  bool isRoutineCompleted() {
    return _currentStepIndex >= _currentRoutineSteps.length;
  }
}

// 프로바이더들
final currentStepProvider = StateNotifierProvider<CurrentStepNotifier, Step?>(
  (ref) => CurrentStepNotifier(),
);

// 루틴 진행률 프로바이더
final routineProgressProvider = Provider<double>((ref) {
  final notifier = ref.watch(currentStepProvider.notifier);
  return notifier.getProgress();
});

// 완료된 스텝 수 프로바이더
final completedStepsCountProvider = Provider<int>((ref) {
  final notifier = ref.watch(currentStepProvider.notifier);
  return notifier.getCompletedCount();
});

// 전체 스텝 수 프로바이더
final totalStepsCountProvider = Provider<int>((ref) {
  final notifier = ref.watch(currentStepProvider.notifier);
  return notifier.getTotalSteps();
});

// 🚨 이 프로바이더는 제거됨 - routine_completion_provider.dart의 isRoutineCompletedProvider 사용
// final isRoutineCompletedProvider = Provider<bool>((ref) {
//   final notifier = ref.watch(currentStepProvider.notifier);
//   return notifier.isRoutineCompleted();
// });

// XP 계산 프로바이더 (실제 데이터 기반)
final currentXPProvider = Provider<int>((ref) {
  final completedCount = ref.watch(completedStepsCountProvider);
  return 250 + (completedCount * 10); // 기본 250 + 완료당 10XP
});

// 스트릭 프로바이더 (실제 데이터 기반)
final currentStreakProvider = Provider<int>((ref) {
  // TODO: 실제 사용자 통계에서 스트릭 데이터 가져오기
  return 0; // 기본값
});
