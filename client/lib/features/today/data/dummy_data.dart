// 🎭 더미 데이터 - MVP용 하드코딩된 루틴 데이터
import '../domain/models/step.dart';

class DummyRoutineData {
  static final List<Step> morningRoutineSteps = [
    const Step(
      id: '1',
      title: '물 한 잔 마시기',
      description: '미지근한 물 200ml를 천천히 마셔보세요.\n몸이 깨어나는 것을 느낄 수 있어요.',
      estimatedMinutes: 2,
      type: StepType.habit,
    ),
    const Step(
      id: '2',
      title: '창문 열고 심호흡',
      description: '창문을 열고 신선한 공기를 마시며\n깊게 5번 심호흡해보세요.',
      estimatedMinutes: 3,
      type: StepType.mindfulness,
    ),
    const Step(
      id: '3',
      title: '간단한 스트레칭',
      description: '목, 어깨, 허리를 가볍게 풀어주며\n몸을 깨워보세요.',
      estimatedMinutes: 5,
      type: StepType.exercise,
    ),
    const Step(
      id: '4',
      title: '오늘의 목표 3가지 적기',
      description: '오늘 꼭 해야 할 중요한 일 3가지를\n메모장에 적어보세요.',
      estimatedMinutes: 3,
      type: StepType.action,
    ),
    const Step(
      id: '5',
      title: '감사 인사하기',
      description: '가족이나 동료에게 감사한 마음을\n표현해보세요.',
      estimatedMinutes: 2,
      type: StepType.mindfulness,
    ),
  ];

  // 현재 진행중인 스텝 인덱스 (정적으로 관리)
  static int currentStepIndex = 0;

  // 완료된 스텝 목록
  static final Set<String> completedStepIds = {};

  // 다음 스텝 가져오기
  static Step? getNextStep() {
    if (currentStepIndex >= morningRoutineSteps.length) {
      return null; // 모든 스텝 완료
    }
    return morningRoutineSteps[currentStepIndex];
  }

  // 스텝 완료 처리
  static void completeCurrentStep() {
    if (currentStepIndex < morningRoutineSteps.length) {
      final currentStep = morningRoutineSteps[currentStepIndex];
      completedStepIds.add(currentStep.id);
      currentStepIndex++;
    }
  }

  // 스텝 스킵 처리
  static void skipCurrentStep() {
    if (currentStepIndex < morningRoutineSteps.length) {
      currentStepIndex++;
    }
  }

  // 루틴 리셋 (테스트용)
  static void reset() {
    currentStepIndex = 0;
    completedStepIds.clear();
  }

  // 진행률 계산
  static double getProgress() {
    return currentStepIndex / morningRoutineSteps.length;
  }

  // 완료된 스텝 수
  static int getCompletedCount() {
    return completedStepIds.length;
  }

  // 전체 스텝 수
  static int getTotalSteps() {
    return morningRoutineSteps.length;
  }

  // 루틴 완료 여부
  static bool isRoutineCompleted() {
    return currentStepIndex >= morningRoutineSteps.length;
  }
}
