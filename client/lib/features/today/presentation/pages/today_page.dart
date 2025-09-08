// 📅 오늘 페이지 (메인 화면)
// 현재 진행 중인 루틴과 다음 스텝을 보여주는 핵심 화면
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/routine_state_provider.dart';
import '../../data/providers/routine_completion_provider.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
import '../../../routine/data/providers/routine_list_provider.dart';
import '../../../../shared/services/user_progress_service.dart';

class TodayPage extends ConsumerStatefulWidget {
  const TodayPage({super.key});

  @override
  ConsumerState<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends ConsumerState<TodayPage> {
  int _currentElapsedSeconds = 0; // 현재 스텝의 경과 시간 저장

  // 사용자 통계 데이터
  int _todayExp = 0;
  int _streakDays = 0;
  int _completionRate = 0;

  @override
  void initState() {
    super.initState();
    // 루틴 목록 로드
    _loadUserStats();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(routineListProvider.notifier).loadRoutines();
    });
  }

  // 사용자 통계 로드
  Future<void> _loadUserStats() async {
    try {
      final todayStats = await UserProgressService.getTodayStats();
      final streakDays = await UserProgressService.getStreakDays();

      setState(() {
        _todayExp = todayStats['todayExp'] ?? 0;
        _streakDays = streakDays;
        _completionRate = todayStats['completionRate'] ?? 0;
      });
    } catch (e) {
      print('Today 페이지 사용자 통계 로드 오류: $e');
    }
  }

  // 오늘의 통계 섹션 빌드
  Widget _buildTodayStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade100,
            Colors.purple.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 성과',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTodayStatItem(
                '오늘 EXP',
                '+$_todayExp',
                Icons.star,
                Colors.amber,
              ),
              _buildTodayStatItem(
                '연속 일수',
                '${_streakDays}일',
                Icons.local_fire_department,
                Colors.orange,
              ),
              _buildTodayStatItem(
                '완료율',
                '${_completionRate}%',
                Icons.check_circle,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 오늘 통계 아이템 빌드
  Widget _buildTodayStatItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
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

  // 🎯 루틴 완료 처리 (로컬 스토리지에 저장)
  void _markRoutineAsCompleted(String routineId) {
    ref
        .read(routineCompletionProvider.notifier)
        .markRoutineAsCompleted(routineId);
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
          // 🧪 테스트용: 완료 상태 초기화 버튼
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('완료 상태 초기화'),
                  content: const Text('오늘 완료된 모든 루틴 상태를 초기화하시겠습니까?\n(테스트용 기능)'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ref
                            .read(routineCompletionProvider.notifier)
                            .clearTodayCompletions();
                        CustomSnackbar.showInfo(context, '완료 상태가 초기화되었습니다');
                      },
                      child: const Text('초기화'),
                    ),
                  ],
                ),
              );
            },
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
          // 📊 오늘의 통계 섹션
          _buildTodayStatsSection(),
          const SizedBox(height: 24),

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
    final routineId = routine['id']?.toString() ?? '';

    // 🎯 루틴 완료 상태 확인
    final isCompleted = ref.watch(isRoutineCompletedProvider(routineId));

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
      elevation: isCompleted ? 2 : 4,
      color: isCompleted ? Colors.green.withOpacity(0.05) : null,
      child: Container(
        decoration: isCompleted
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 2,
                ),
              )
            : null,
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
                  // 시작 버튼 또는 완료 표시
                  if (isCompleted)
                    // ✅ 완료 표시
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '완료',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // ▶️ 시작 버튼
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
                            color: isCompleted
                                ? Colors.green.withOpacity(0.1)
                                : color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: isCompleted
                                    ? Colors.green.withOpacity(0.3)
                                    : color.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCompleted)
                                const Icon(
                                  Icons.check_circle,
                                  size: 12,
                                  color: Colors.green,
                                ),
                              if (isCompleted) const SizedBox(width: 4),
                              Text(
                                step['title'] ?? '스텝',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isCompleted ? Colors.green : color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    // 🎨 개선된 응원 메시지 배열 - 애니메이션 오버레이용 더 임팩트 있는 메시지들
    final encouragementMessages = [
      '🎊 완벽한 실행이에요!\n다음 도전을 향해!',
      '🚀 놀라운 집중력이네요!\n계속 이어가세요!',
      '💎 정말 멋진 모습이에요!\n다음 스텝도 화이팅!',
      '🌟 환상적인 진행이에요!\n당신은 정말 대단해요!',
      '🎯 완벽한 타이밍이에요!\n다음 목표로!',
      '⚡ 엄청난 에너지네요!\n계속 이 기세로!',
      '🏆 진정한 챔피언이에요!\n다음 도전 준비됐나요?',
      '✨ 마법같은 순간이에요!\n계속 이어가세요!',
      '🔥 불꽃같은 열정이에요!\n다음 스텝도 완벽하게!',
      '💫 별처럼 빛나는 모습이에요!\n계속 화이팅!',
      '🎪 서커스처럼 멋진 실행이에요!\n다음은 뭘까요?',
      '🌈 무지개처럼 아름다운 진행이에요!\n계속해요!',
      '🎭 연기처럼 자연스러운 완성도예요!\n대단해요!',
      '🎨 예술작품 같은 완벽함이에요!\n다음 걸작을 위해!',
      '🎵 음악처럼 리드미컬한 진행이에요!\n계속 연주하세요!',
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
          // ⚡ 1.5초 후 빠른 오버레이 제거 - 반짝이듯이!
          Future.delayed(const Duration(milliseconds: 1500), () {
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
      // 루틴 완료 상태를 로컬 스토리지에 저장
      final routineId = progressState.currentRoutine?['id']?.toString();
      if (routineId != null) {
        _markRoutineAsCompleted(routineId);
      }

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

    // ⚡ 빠른 페이드 애니메이션 (1.5초로 단축 - 반짝이듯이!)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // ⚡ 빠른 스케일 애니메이션 (0.3초로 단축)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // ⚡ 빠른 폭죽 애니메이션 (0.8초로 단축)
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut, // 더 빠르고 반짝이듯이
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.3, // 더 작게 시작해서 더 임팩트 있게
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut, // 탄성 효과로 반짝이듯이
    ));

    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.bounceOut, // 바운스 효과로 더 반짝이듯이
    ));

    // 애니메이션 시작
    _startAnimations();
  }

  void _startAnimations() {
    // ⚡ 빠른 페이드 인 (0.2초)
    _fadeController.forward();

    // ⚡ 빠른 스케일 애니메이션 (0.3초)
    _scaleController.forward();

    // ⚡ 빠른 폭죽 애니메이션 (0.8초)
    if (widget.isCompleted) {
      _celebrationController.forward();
    }

    // ⚡ 1.5초 후 빠른 페이드 아웃 - 반짝이듯이 나타나고 사라지기
    Future.delayed(const Duration(milliseconds: 1500), () {
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

                    // 🎨 개선된 메인 메시지 - 더 임팩트 있고 시각적으로 매력적인 디자인
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white, // 깔끔한 흰색 배경
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey[300]!, // 연한 회색 테두리
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15), // 검은색 그림자
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                            spreadRadius: 2, // 그림자 확산 효과
                          ),
                        ],
                      ),
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800], // 깔끔한 진한 회색
                          height: 1.3, // 줄 간격 조정
                          shadows: [
                            Shadow(
                              color:
                                  Colors.black.withOpacity(0.1), // 미묘한 검은색 그림자
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 🎨 개선된 스텝 정보 표시 - 더 깔끔하고 정보가 풍부한 디자인
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50], // 더 밝은 회색 배경
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[200]!, // 더 연한 회색 테두리
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // 스텝 제목
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.stepTitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // 소요시간
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '소요시간: ${_formatTime(widget.elapsedSeconds)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
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
