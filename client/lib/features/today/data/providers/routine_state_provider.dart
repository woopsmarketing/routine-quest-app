// 🌍 루틴 상태 전역 관리 프로바이더
// 페이지 간 이동 시에도 루틴 진행 상태를 유지하는 프로바이더
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/user_progress_service.dart';

// 스텝 수행 결과 모델
class StepResult {
  final String stepTitle;
  final String stepDescription;
  final int targetSeconds; // 목표 시간
  final int actualSeconds; // 실제 소요 시간
  final StepStatus status; // 완료/건너뛰기 상태
  final DateTime completedAt; // 완료 시각
  final int xpReward; // 획득한 경험치
  final bool isCompleted; // 완료 여부 (UI용)

  const StepResult({
    required this.stepTitle,
    required this.stepDescription,
    required this.targetSeconds,
    required this.actualSeconds,
    required this.status,
    required this.completedAt,
    required this.xpReward,
    this.isCompleted = false,
  });

  // Map으로 변환 (UI에서 사용)
  Map<String, dynamic> toMap() {
    return {
      'title': stepTitle,
      'description': stepDescription,
      'targetSeconds': targetSeconds,
      'elapsedSeconds': actualSeconds,
      'isCompleted': status == StepStatus.completed,
      'xpReward': xpReward,
      'completedAt': completedAt,
    };
  }
}

// 스텝 상태 열거형
enum StepStatus {
  completed, // 완료
  skipped, // 건너뛰기
}

// 루틴 진행 상태 모델
class RoutineProgressState {
  final Map<String, dynamic>? currentRoutine;
  final List<dynamic> currentSteps;
  final int currentStepIndex;
  final bool isRoutineStarted;
  final DateTime? routineStartedAt; // 루틴 시작 시각
  final DateTime? routineCompletedAt; // 루틴 완료 시각
  final List<StepResult> stepResults; // 각 스텝 수행 결과
  final int expGained; // 획득한 경험치

  const RoutineProgressState({
    this.currentRoutine,
    this.currentSteps = const [],
    this.currentStepIndex = 0,
    this.isRoutineStarted = false,
    this.routineStartedAt,
    this.routineCompletedAt,
    this.stepResults = const [],
    this.expGained = 0,
  });

  // 상태 복사 메서드
  RoutineProgressState copyWith({
    Map<String, dynamic>? currentRoutine,
    List<dynamic>? currentSteps,
    int? currentStepIndex,
    bool? isRoutineStarted,
    DateTime? routineStartedAt,
    DateTime? routineCompletedAt,
    List<StepResult>? stepResults,
    int? expGained,
  }) {
    return RoutineProgressState(
      currentRoutine: currentRoutine ?? this.currentRoutine,
      currentSteps: currentSteps ?? this.currentSteps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isRoutineStarted: isRoutineStarted ?? this.isRoutineStarted,
      routineStartedAt: routineStartedAt ?? this.routineStartedAt,
      routineCompletedAt: routineCompletedAt ?? this.routineCompletedAt,
      stepResults: stepResults ?? this.stepResults,
      expGained: expGained ?? this.expGained,
    );
  }

  // 진행률 계산
  double get progress {
    if (currentSteps.isEmpty) return 0.0;
    return currentStepIndex / currentSteps.length;
  }

  // 완료 여부
  bool get isCompleted => currentStepIndex >= currentSteps.length;

  // 현재 스텝 가져오기
  Map<String, dynamic>? get currentStep {
    if (isCompleted || currentSteps.isEmpty) return null;
    return currentSteps[currentStepIndex];
  }

  // 총 수행 시간 계산 (초)
  int get totalElapsedSeconds {
    if (routineStartedAt == null) return 0;
    final endTime = routineCompletedAt ?? DateTime.now();
    return endTime.difference(routineStartedAt!).inSeconds;
  }

  // 완료된 스텝 목록
  List<StepResult> get completedSteps {
    return stepResults
        .where((step) => step.status == StepStatus.completed)
        .toList();
  }

  // 건너뛴 스텝 목록
  List<StepResult> get skippedSteps {
    return stepResults
        .where((step) => step.status == StepStatus.skipped)
        .toList();
  }

  // 각 스텝별 소요 시간 합계
  int get totalStepTime {
    return stepResults.fold(0, (sum, step) => sum + step.actualSeconds);
  }
}

// 루틴 상태 프로바이더
class RoutineProgressNotifier extends StateNotifier<RoutineProgressState> {
  RoutineProgressNotifier() : super(const RoutineProgressState());

  // 루틴 설정 (첫 로드 시)
  void setRoutine(Map<String, dynamic> routine, List<dynamic> steps) {
    // 이미 진행 중인 루틴이 있고 같은 루틴이면 상태 유지
    if (state.currentRoutine != null &&
        state.currentRoutine!['id'] == routine['id'] &&
        state.isRoutineStarted) {
      return;
    }

    state = RoutineProgressState(
      currentRoutine: routine,
      currentSteps: steps,
      currentStepIndex: 0,
      isRoutineStarted: false,
    );
  }

  // 루틴 시작
  void startRoutine() {
    if (state.currentRoutine == null || state.currentSteps.isEmpty) return;

    state = state.copyWith(
      isRoutineStarted: true,
      currentStepIndex: 0,
      routineStartedAt: DateTime.now(),
      stepResults: [], // 결과 초기화
    );
  }

  // 스텝 완료 (소요 시간과 함께)
  void completeCurrentStep(int elapsedSeconds) {
    if (state.currentStepIndex < state.currentSteps.length) {
      final currentStep = state.currentSteps[state.currentStepIndex];

      // 스텝별 경험치 계산 (기본 10XP, 시간에 따라 보너스)
      final baseXP = 10;
      final timeBonus = _calculateTimeBonus(
          elapsedSeconds, (currentStep['t_ref_sec'] ?? 120) as int);
      final totalXP = baseXP + timeBonus;

      final stepResult = StepResult(
        stepTitle: currentStep['title'] ?? '',
        stepDescription: currentStep['description'] ?? '',
        targetSeconds: (currentStep['t_ref_sec'] ?? 120) as int,
        actualSeconds: elapsedSeconds,
        status: StepStatus.completed,
        completedAt: DateTime.now(),
        xpReward: totalXP,
        isCompleted: true,
      );

      final newResults = [...state.stepResults, stepResult];
      final newIndex = state.currentStepIndex + 1;
      final isCompleted = newIndex >= state.currentSteps.length;

      state = state.copyWith(
        currentStepIndex: newIndex,
        stepResults: newResults,
        expGained: state.expGained + totalXP,
        // 모든 스텝 완료 시 루틴 완료 시각 기록
        routineCompletedAt: isCompleted ? DateTime.now() : null,
      );

      // 루틴 완료 시 경험치 및 기록 저장
      if (isCompleted) {
        _saveRoutineCompletion().then((exp) {
          state = state.copyWith(expGained: exp);
        });
      }
    }
  }

  // 스텝 건너뛰기 (소요 시간과 함께)
  void skipCurrentStep(int elapsedSeconds) {
    if (state.currentStepIndex < state.currentSteps.length) {
      final currentStep = state.currentSteps[state.currentStepIndex];

      // 건너뛰기 시에는 경험치 없음 (0XP)
      final stepResult = StepResult(
        stepTitle: currentStep['title'] ?? '',
        stepDescription: currentStep['description'] ?? '',
        targetSeconds: (currentStep['t_ref_sec'] ?? 120) as int,
        actualSeconds: elapsedSeconds,
        status: StepStatus.skipped,
        completedAt: DateTime.now(),
        xpReward: 0,
        isCompleted: false,
      );

      final newResults = [...state.stepResults, stepResult];
      final newIndex = state.currentStepIndex + 1;

      state = state.copyWith(
        currentStepIndex: newIndex,
        stepResults: newResults,
        // 모든 스텝 완료 시 루틴 완료 시각 기록
        routineCompletedAt:
            newIndex >= state.currentSteps.length ? DateTime.now() : null,
      );
    }
  }

  // 루틴 리셋
  void resetRoutine() {
    state = state.copyWith(
      currentStepIndex: 0,
      isRoutineStarted: false,
      routineStartedAt: null,
      routineCompletedAt: null,
      stepResults: [],
    );
  }

  // 루틴 클리어 (완전 초기화)
  void clearRoutine() {
    state = const RoutineProgressState();
  }

  // 루틴 완료 시 경험치 및 기록 저장
  Future<int> _saveRoutineCompletion() async {
    if (state.currentRoutine == null) return 0;

    final routineName = state.currentRoutine!['title'] ?? '루틴';

    // 하루 한 번 제한 체크
    final hasCompleted =
        await UserProgressService.hasCompletedRoutineToday(routineName);
    if (hasCompleted) {
      print('오늘 이미 완료한 루틴입니다: $routineName');
      return 0; // 경험치 없음
    }

    final completedSteps = state.completedSteps.length;
    final totalSteps = state.currentSteps.length;
    final timeTakenSeconds = state.totalElapsedSeconds;

    // 목표 시간 계산 (모든 스텝의 목표 시간 합계)
    final targetTimeSeconds = state.currentSteps
        .fold<int>(0, (sum, step) => sum + ((step['t_ref_sec'] ?? 120) as int));

    // 스텝 결과를 Map 형태로 변환
    final stepResultsMap = state.stepResults
        .map((result) => {
              'status': result.status == StepStatus.completed
                  ? 'completed'
                  : 'skipped',
              'actualSeconds': result.actualSeconds,
            })
        .toList();

    // 경험치 계산 (새로운 방식)
    final expGained = UserProgressService.calculateRoutineExp(
      steps: List<Map<String, dynamic>>.from(state.currentSteps),
      stepResults: stepResultsMap,
      timeTakenSeconds: timeTakenSeconds,
      targetTimeSeconds: targetTimeSeconds,
    );

    try {
      // 경험치 추가 및 레벨업 체크
      await UserProgressService.addExperience(expGained);

      // 루틴 완료 기록 저장
      await UserProgressService.saveRoutineCompletion(
        routineName: routineName,
        completedSteps: completedSteps,
        totalSteps: totalSteps,
        timeTakenSeconds: timeTakenSeconds,
        expGained: expGained,
      );

      return expGained;
    } catch (e) {
      print('루틴 완료 기록 저장 실패: $e');
      return 0;
    }
  }

  // 시간 보너스 계산 (목표 시간보다 빠르게 완료하면 보너스)
  int _calculateTimeBonus(int actualSeconds, int targetSeconds) {
    if (actualSeconds <= targetSeconds) {
      // 목표 시간보다 빠르게 완료하면 보너스 (최대 5XP)
      final timeRatio = actualSeconds / targetSeconds;
      final bonus = ((1 - timeRatio) * 5).round();
      return bonus.clamp(0, 5);
    }
    return 0; // 목표 시간을 초과하면 보너스 없음
  }
}

// 프로바이더 인스턴스
final routineProgressProvider =
    StateNotifierProvider<RoutineProgressNotifier, RoutineProgressState>(
  (ref) => RoutineProgressNotifier(),
);
