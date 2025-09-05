// 🔄 루틴 상태 관리 프로바이더 (Riverpod) - 단순화 버전
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dummy_data.dart';
import '../../domain/models/step.dart';

// 현재 스텝 프로바이더 (StateNotifier 방식)
class CurrentStepNotifier extends StateNotifier<Step?> {
  CurrentStepNotifier() : super(DummyRoutineData.getNextStep());
  
  // 스텝 완료
  void complete() {
    DummyRoutineData.completeCurrentStep();
    state = DummyRoutineData.getNextStep();
  }
  
  // 스텝 스킵
  void skip() {
    DummyRoutineData.skipCurrentStep();
    state = DummyRoutineData.getNextStep();
  }
  
  // 루틴 리셋 (테스트용)
  void reset() {
    DummyRoutineData.reset();
    state = DummyRoutineData.getNextStep();
  }
}

// 프로바이더들
final currentStepProvider = StateNotifierProvider<CurrentStepNotifier, Step?>(
  (ref) => CurrentStepNotifier(),
);

// 루틴 진행률 프로바이더
final routineProgressProvider = Provider<double>((ref) {
  ref.watch(currentStepProvider); // 변경 감지
  return DummyRoutineData.getProgress();
});

// 완료된 스텝 수 프로바이더
final completedStepsCountProvider = Provider<int>((ref) {
  ref.watch(currentStepProvider);
  return DummyRoutineData.getCompletedCount();
});

// 전체 스텝 수 프로바이더
final totalStepsCountProvider = Provider<int>((ref) {
  return DummyRoutineData.getTotalSteps();
});

// 루틴 완료 상태 프로바이더
final isRoutineCompletedProvider = Provider<bool>((ref) {
  ref.watch(currentStepProvider);
  return DummyRoutineData.isRoutineCompleted();
});

// XP 계산 프로바이더 (더미)
final currentXPProvider = Provider<int>((ref) {
  final completedCount = ref.watch(completedStepsCountProvider);
  return 250 + (completedCount * 10); // 기본 250 + 완료당 10XP
});

// 스트릭 프로바이더 (더미)
final currentStreakProvider = Provider<int>((ref) {
  return 7; // 고정값
});