// 📅 오늘 페이지 (메인 화면)
// 현재 진행 중인 루틴과 다음 스텝을 보여주는 핵심 화면
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/routine_state_provider.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
import '../../../routine/data/providers/routine_list_provider.dart';

class TodayPage extends ConsumerStatefulWidget {
  const TodayPage({super.key});

  @override
  ConsumerState<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends ConsumerState<TodayPage> {
  int _currentElapsedSeconds = 0; // 현재 스텝의 경과 시간 저장

  @override
  void initState() {
    super.initState();
    // 루틴 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(routineListProvider.notifier).loadRoutines();
    });
  }

  // 📊 오늘의 진행 상황 계산 (전역 상태 사용)

  // 루틴 시작 (전역 상태 사용)
  void _startRoutine() {
    final routineState = ref.read(routineProgressProvider);

    if (routineState.currentRoutine == null ||
        routineState.currentSteps.isEmpty) {
      CustomSnackbar.showError(context, '시작할 루틴이 없습니다');
      return;
    }

    ref.read(routineProgressProvider.notifier).startRoutine();

    CustomSnackbar.showSuccess(
        context, '${routineState.currentRoutine!['title']} 시작! 🚀');
  }

  // 스텝 완료 처리 (소요 시간과 함께)
  void _completeCurrentStep(int elapsedSeconds) {
    final routineState = ref.read(routineProgressProvider);

    if (!routineState.isCompleted) {
      ref
          .read(routineProgressProvider.notifier)
          .completeCurrentStep(elapsedSeconds);

      final newState = ref.read(routineProgressProvider);
      if (newState.isCompleted) {
        CustomSnackbar.showSuccess(context, '🎉 모든 스텝을 완료했습니다! 훌륭해요!');
      } else {
        CustomSnackbar.showSuccess(context, '완료! 다음 스텝으로 이동합니다 🎉');
      }
    }
  }

  // 스텝 건너뛰기 처리 (소요 시간과 함께)
  void _skipCurrentStep(int elapsedSeconds) {
    final routineState = ref.read(routineProgressProvider);

    if (!routineState.isCompleted) {
      ref
          .read(routineProgressProvider.notifier)
          .skipCurrentStep(elapsedSeconds);

      final newState = ref.read(routineProgressProvider);
      if (newState.isCompleted) {
        CustomSnackbar.showInfo(context, '루틴을 완료했습니다');
      } else {
        CustomSnackbar.showWarning(context, '⏭️ 다음 스텝으로 넘어갑니다');
      }
    }
  }

  // 루틴 리셋 (다시 시작) - 전역 상태 사용
  void _resetRoutine() {
    ref.read(routineProgressProvider.notifier).resetRoutine();
  }

  @override
  Widget build(BuildContext context) {
    final routineState = ref.watch(routineListProvider);
    final todayRoutines = ref.watch(todayDisplayRoutinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(routineListProvider.notifier).loadRoutines(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 설정 화면으로 이동
            },
          ),
        ],
      ),
      body: routineState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : routineState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('오류가 발생했습니다',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(routineState.error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(routineListProvider.notifier)
                            .loadRoutines(),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : _buildTodayContent(todayRoutines),
    );
  }

  // 오늘 페이지 콘텐츠 빌드
  Widget _buildTodayContent(List<Map<String, dynamic>> todayRoutines) {
    // 🔄 루틴 진행 상태 확인
    final progressState = ref.watch(routineProgressProvider);
    final isRoutineInProgress =
        progressState.isRoutineStarted && progressState.currentStep != null;

    // 🎯 루틴 진행 상태 관리 (UI 표시와 완전 분리)
    // 이 로직은 루틴 진행 상태 관리용이므로, UI 표시와는 별개로 처리
    // 오늘 페이지에서는 모든 활성화된 루틴을 표시해야 함

    // 🎯 진행 중인 루틴이 있으면 전체 화면 스텝 진행 화면 표시
    if (isRoutineInProgress) {
      return _buildFullScreenStepProgress(progressState);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📅 오늘 날짜 표시
          Text(
            '오늘은 ${DateTime.now().month}월 ${DateTime.now().day}일입니다',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          // 🏠 오늘 활성화된 루틴들 표시
          if (todayRoutines.isEmpty)
            // 루틴이 없는 경우
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.home_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '오늘 활성화된 루틴이 없습니다',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '루틴 페이지에서 오늘 노출을 활성화해보세요!',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // 루틴 페이지로 이동
                        DefaultTabController.of(context).animateTo(1);
                      },
                      icon: const Icon(Icons.list),
                      label: const Text('루틴 관리하기'),
                    ),
                  ],
                ),
              ),
            )
          else
            // 🎯 활성화된 루틴들 목록
            Expanded(
              child: ListView.builder(
                itemCount: todayRoutines.length,
                itemBuilder: (context, index) {
                  final routine = todayRoutines[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildTodayRoutineCard(context, routine),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // 🏠 오늘 루틴 카드 생성
  Widget _buildTodayRoutineCard(
      BuildContext context, Map<String, dynamic> routine) {
    final steps = routine['steps'] as List<dynamic>? ?? [];

    // 🎨 색상 파싱 (안전하게 처리)
    Color color;
    try {
      final colorStr = routine['color']?.toString() ?? '#6366F1';
      final hexColor =
          colorStr.startsWith('#') ? colorStr.substring(1) : colorStr;
      color = Color(int.parse(hexColor, radix: 16) + 0xFF000000);
    } catch (e) {
      color = const Color(0xFF6366F1);
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 루틴 헤더
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Text(
                    routine['icon'] ?? '🎯',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routine['title'] ?? '루틴',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (routine['description'] != null &&
                          routine['description'].toString().isNotEmpty)
                        Text(
                          routine['description'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                // 시작 버튼
                ElevatedButton.icon(
                  onPressed: () => _startSpecificRoutine(routine),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('시작'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 스텝 요약 표시
            if (steps.isNotEmpty) ...[
              Text(
                '총 ${steps.length}개 스텝',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              // 처음 3개 스텝 미리보기
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  ...steps.take(3).map((step) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Text(
                          step['title'] ?? '스텝',
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )),
                  if (steps.length > 3)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${steps.length - 3}개',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '스텝이 없습니다',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 🎯 전체 화면 스텝 진행 위젯
  Widget _buildFullScreenStepProgress(RoutineProgressState progressState) {
    final currentStep = progressState.currentStep;
    if (currentStep == null) return Container();

    final targetSeconds = (currentStep['t_ref_sec'] as int? ?? 120);
    final stepIndex = progressState.currentStepIndex + 1;
    final totalSteps = progressState.currentSteps.length;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🎯 루틴 제목과 진행률
          Text(
            progressState.currentRoutine?['title'] ?? '루틴',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$stepIndex / $totalSteps 스텝',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),

          // 🎯 현재 스텝 제목 (큰 글씨)
          Text(
            currentStep['title'] ?? '',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // 🎯 스텝 설명
          if (currentStep['description'] != null &&
              currentStep['description'].toString().isNotEmpty)
            Text(
              currentStep['description'],
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 48),

          // 🕐 타이머 표시 (큰 원형)
          _buildCircularTimer(targetSeconds),
          const SizedBox(height: 48),

          // 🎯 액션 버튼들 (완료, 건너뛰기만)
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _completeCurrentStepWithTimer(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '완료',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _skipCurrentStepWithTimer(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '건너뛰기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🕐 원형 타이머 위젯
  Widget _buildCircularTimer(int targetSeconds) {
    return StreamBuilder<int>(
      stream: _timerStream(targetSeconds),
      builder: (context, snapshot) {
        final elapsedSeconds = snapshot.data ?? 0;
        final remainingSeconds =
            (targetSeconds - elapsedSeconds).clamp(0, targetSeconds);
        final progress = elapsedSeconds / targetSeconds;

        // 현재 경과 시간을 상태에 저장 (정확한 시간 계산을 위해)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _currentElapsedSeconds = elapsedSeconds;
        });

        // 시간 초과 시 자동으로 다음 스텝으로
        if (remainingSeconds == 0 && elapsedSeconds > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _skipCurrentStepWithTimer(); // 시간 초과는 건너뛰기로 처리
          });
        }

        return Container(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 배경 원
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.1),
                  border:
                      Border.all(color: Colors.grey.withOpacity(0.3), width: 4),
                ),
              ),
              // 진행률 원
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    remainingSeconds > 10 ? Colors.blue : Colors.red,
                  ),
                ),
              ),
              // 시간 표시
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(remainingSeconds),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: remainingSeconds > 10 ? Colors.blue : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '남은 시간',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 🕐 타이머 스트림 (1초마다 업데이트)
  Stream<int> _timerStream(int targetSeconds) async* {
    int elapsedSeconds = 0;
    while (elapsedSeconds <= targetSeconds) {
      yield elapsedSeconds;
      await Future.delayed(const Duration(seconds: 1));
      elapsedSeconds++;
    }
  }

  // 🕐 시간 포맷팅 (MM:SS)
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // 🎯 현재 스텝 완료 (타이머 포함)
  void _completeCurrentStepWithTimer() {
    final progressState = ref.read(routineProgressProvider);
    final currentStep = progressState.currentStep;
    if (currentStep == null) return;

    final targetSeconds = (currentStep['t_ref_sec'] as int? ?? 120);
    final elapsedSeconds = _getCurrentElapsedSeconds(targetSeconds);

    ref
        .read(routineProgressProvider.notifier)
        .completeCurrentStep(elapsedSeconds);

    // 타이머 리셋 (다음 스텝을 위해)
    _currentElapsedSeconds = 0;

    // 중간 팝업 표시
    _showStepCompletionPopup(
        true, currentStep['title'] ?? '스텝', elapsedSeconds);

    _checkRoutineCompletion();
  }

  // 🎯 현재 스텝 건너뛰기 (타이머 포함)
  void _skipCurrentStepWithTimer() {
    final progressState = ref.read(routineProgressProvider);
    final currentStep = progressState.currentStep;
    if (currentStep == null) return;

    final targetSeconds = (currentStep['t_ref_sec'] as int? ?? 120);
    final elapsedSeconds = _getCurrentElapsedSeconds(targetSeconds);

    ref.read(routineProgressProvider.notifier).skipCurrentStep(elapsedSeconds);

    // 타이머 리셋 (다음 스텝을 위해)
    _currentElapsedSeconds = 0;

    // 중간 팝업 표시
    _showStepCompletionPopup(
        false, currentStep['title'] ?? '스텝', elapsedSeconds);

    _checkRoutineCompletion();
  }

  // 🕐 현재 경과 시간 계산 (타이머 스트림에서 가져오기)
  int _getCurrentElapsedSeconds(int targetSeconds) {
    // 타이머에서 저장된 현재 경과 시간 사용
    return _currentElapsedSeconds.clamp(0, targetSeconds);
  }

  // 🎉 스텝 완료/건너뛰기 안내 메시지 오버레이 표시
  void _showStepCompletionPopup(
      bool isCompleted, String stepTitle, int elapsedSeconds) {
    // 응원/위로 메시지 배열 (next_step_card.dart에서 가져옴)
    final encouragementMessages = [
      '🎉 훌륭해요! 다음 단계로 넘어갑니다!',
      '🌟 잘했어요! 계속 화이팅!',
      '💪 멋져요! 다음 스텝도 화이팅!',
      '✨ 완벽해요! 다음 단계로!',
      '🏆 대단해요! 계속 이어가세요!',
      '🎯 좋아요! 다음 스텝으로!',
      '⭐ 훌륭한 진행이에요!',
      '🔥 잘하고 있어요! 계속!',
    ];

    final skipMessages = [
      '⏭️ 괜찮아요! 다음 스텝으로 넘어갑니다',
      '💫 아쉽지만 다음에 도전해보세요!',
      '🌟 다음 스텝으로 넘어갑니다',
      '💪 괜찮아요! 다음에 더 잘할 수 있어요',
      '✨ 다음 스텝으로 넘어가요',
      '🎯 다음에 도전해보세요!',
      '⭐ 괜찮아요! 다음 스텝으로!',
      '🔥 다음에 더 잘할 수 있어요!',
    ];

    // 랜덤 메시지 선택
    final messages = isCompleted ? encouragementMessages : skipMessages;
    final randomMessage =
        messages[DateTime.now().millisecondsSinceEpoch % messages.length];

    // 오버레이 표시
    _showAnimatedOverlay(
      context: context,
      isCompleted: isCompleted,
      message: randomMessage,
      stepTitle: stepTitle,
      elapsedSeconds: elapsedSeconds,
    );
  }

  // 🎨 애니메이션 오버레이 표시
  void _showAnimatedOverlay({
    required BuildContext context,
    required bool isCompleted,
    required String message,
    required String stepTitle,
    required int elapsedSeconds,
  }) {
    // 오버레이 위젯 생성
    late OverlayEntry overlay;
    overlay = OverlayEntry(
      builder: (context) => _StepCompletionOverlay(
        isCompleted: isCompleted,
        message: message,
        stepTitle: stepTitle,
        elapsedSeconds: elapsedSeconds,
        onComplete: () {
          // 2초 후 오버레이 제거
          Future.delayed(const Duration(milliseconds: 2000), () {
            overlay.remove();
          });
        },
      ),
    );

    // 오버레이 추가
    Overlay.of(context).insert(overlay);
  }

  // 🎯 루틴 완료 확인 및 완료 페이지 이동
  void _checkRoutineCompletion() {
    final progressState = ref.read(routineProgressProvider);
    if (progressState.isCompleted) {
      // 완료 위젯을 다이얼로그로 표시
      _showCompletionDialog(progressState);
    }
  }

  // 🎉 완료 다이얼로그 표시 (개선된 버전)
  void _showCompletionDialog(RoutineProgressState progressState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95, // 화면에 거의 꽉차게
          height: MediaQuery.of(context).size.height * 0.85, // 화면 높이의 85%
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 완료 아이콘
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.celebration,
                    size: 60,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 24),

                // 완료 메시지
                Text(
                  '${progressState.currentRoutine?['title'] ?? '루틴'} 완료!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '🎉 훌륭한 하루를 보내셨네요!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // 전체 통계 정보
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            '완료한 스텝',
                            '${progressState.completedSteps.length}개',
                            Icons.check_circle,
                            Colors.green,
                          ),
                          _buildStatItem(
                            '건너뛴 스텝',
                            '${progressState.skippedSteps.length}개',
                            Icons.skip_next,
                            Colors.orange,
                          ),
                          _buildStatItem(
                            '총 소요 시간',
                            _formatTime(progressState.totalElapsedSeconds),
                            Icons.timer,
                            Colors.blue,
                          ),
                          _buildStatItem(
                            '획득한 EXP',
                            '${progressState.expGained}XP',
                            Icons.star,
                            Colors.amber,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 스텝별 상세 정보
                if (progressState.completedSteps.isNotEmpty ||
                    progressState.skippedSteps.isNotEmpty) ...[
                  const Text(
                    '스텝별 상세 정보',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 완료한 스텝들
                  if (progressState.completedSteps.isNotEmpty) ...[
                    _buildStepDetailSection(
                      '✅ 완료한 스텝들',
                      progressState.completedSteps,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 건너뛴 스텝들
                  if (progressState.skippedSteps.isNotEmpty) ...[
                    _buildStepDetailSection(
                      '⏭️ 건너뛴 스텝들',
                      progressState.skippedSteps,
                      Colors.orange,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],

                const SizedBox(height: 24),

                // 확인 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 다이얼로그 닫기
                      ref
                          .read(routineProgressProvider.notifier)
                          .clearRoutine(); // 루틴 상태 초기화
                      // 대시보드로 이동
                      DefaultTabController.of(context).animateTo(2);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📊 통계 아이템 위젯
  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // 📋 스텝 상세 정보 섹션
  Widget _buildStepDetailSection(
      String title, List<StepResult> steps, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          ...steps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      step.status == StepStatus.completed
                          ? Icons.check_circle
                          : Icons.skip_next,
                      color: color,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        step.stepTitle,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      _formatTime(step.actualSeconds),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: step.xpReward > 0
                            ? Colors.amber.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        step.xpReward > 0 ? '+${step.xpReward}XP' : '0XP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: step.xpReward > 0 ? Colors.amber : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // 🚀 특정 루틴 시작
  void _startSpecificRoutine(Map<String, dynamic> routine) {
    final steps = routine['steps'] as List<dynamic>? ?? [];

    if (steps.isEmpty) {
      CustomSnackbar.showWarning(context, '이 루틴에는 스텝이 없습니다.\n먼저 스텝을 추가해주세요.');
      return;
    }

    try {
      // 🔄 루틴 진행 상태 초기화 및 시작
      ref.read(routineProgressProvider.notifier).setRoutine(routine, steps);
      ref.read(routineProgressProvider.notifier).startRoutine();

      // 타이머 초기화
      _currentElapsedSeconds = 0;

      // ✅ 성공 메시지 표시
      CustomSnackbar.showSuccess(context, '${routine['title']} 시작! 🚀');
    } catch (e) {
      print('루틴 시작 오류: $e');
      CustomSnackbar.showError(context, '루틴 시작에 실패했습니다');
    }
  }
}

// 🎨 스텝 완료/건너뛰기 오버레이 위젯
class _StepCompletionOverlay extends StatefulWidget {
  final bool isCompleted;
  final String message;
  final String stepTitle;
  final int elapsedSeconds;
  final VoidCallback onComplete;

  const _StepCompletionOverlay({
    required this.isCompleted,
    required this.message,
    required this.stepTitle,
    required this.elapsedSeconds,
    required this.onComplete,
  });

  @override
  State<_StepCompletionOverlay> createState() => _StepCompletionOverlayState();
}

class _StepCompletionOverlayState extends State<_StepCompletionOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _celebrationController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();

    // 페이드 애니메이션 (2초)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 스케일 애니메이션 (0.5초)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // 폭죽 애니메이션 (완료 시에만)
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeOut,
    ));

    // 애니메이션 시작
    _startAnimations();
  }

  void _startAnimations() {
    // 페이드 인 (0.3초)
    _fadeController.forward();

    // 스케일 애니메이션 (0.5초)
    _scaleController.forward();

    // 완료 시 폭죽 애니메이션 (1.2초)
    if (widget.isCompleted) {
      _celebrationController.forward();
    }

    // 2초 후 페이드 아웃 시작 (점점 투명해지면서)
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _fadeController.reverse().then((_) {
          widget.onComplete();
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset:
                    Offset(0, -20 * (1 - _fadeAnimation.value)), // 위로 올라가는 효과
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 폭죽 애니메이션 (완료 시에만)
                    if (widget.isCompleted)
                      AnimatedBuilder(
                        animation: _celebrationAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _celebrationAnimation.value,
                            child: Opacity(
                              opacity: _celebrationAnimation.value,
                              child: Container(
                                width: 100,
                                height: 60,
                                child: Stack(
                                  children: [
                                    // 폭죽 아이콘들 - 더 자연스럽게 배치
                                    Positioned(
                                      top: 5,
                                      left: 15,
                                      child: Text(
                                        '🎉',
                                        style: TextStyle(
                                          fontSize:
                                              24 * _celebrationAnimation.value,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 20,
                                      child: Text(
                                        '✨',
                                        style: TextStyle(
                                          fontSize:
                                              20 * _celebrationAnimation.value,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 5,
                                      left: 25,
                                      child: Text(
                                        '🌟',
                                        style: TextStyle(
                                          fontSize:
                                              18 * _celebrationAnimation.value,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 15,
                                      child: Text(
                                        '⭐',
                                        style: TextStyle(
                                          fontSize:
                                              16 * _celebrationAnimation.value,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 16),

                    // 메인 메시지 - 더 큰 폰트와 그림자 효과
                    Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.isCompleted
                            ? Colors.green[700]
                            : Colors.orange[700],
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // 스텝 제목 - 작은 폰트로
                    Text(
                      widget.stepTitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 4),

                    // 소요시간 - 가장 작은 폰트로
                    Text(
                      '소요시간: ${_formatTime(widget.elapsedSeconds)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 시간 포맷팅 헬퍼
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
