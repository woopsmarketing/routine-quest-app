// 🏆 루틴 완료 결과 표시 위젯
// 루틴 완료 후 상세한 수행 결과를 보여주는 위젯
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/providers/routine_state_provider.dart';

class RoutineCompletionWidget extends StatelessWidget {
  final RoutineProgressState routineState;
  final VoidCallback onNewRoutine;
  final int expGained;

  const RoutineCompletionWidget({
    super.key,
    required this.routineState,
    required this.onNewRoutine,
    required this.expGained,
  });

  // 시간을 분:초 형식으로 포맷
  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    if (minutes > 0) {
      return '${minutes}분 ${seconds}초';
    } else {
      return '${seconds}초';
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalMinutes = (routineState.totalElapsedSeconds / 60).round();
    final completedSteps = routineState.completedSteps;
    final skippedSteps = routineState.skippedSteps;
    final startTime = routineState.routineStartedAt!;
    final endTime = routineState.routineCompletedAt!;

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎉 완료 헤더
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.1),
                    Colors.blue.withOpacity(0.1)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.celebration,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '🎉 ${routineState.currentRoutine!['title']} 완료!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '훌륭하게 해내셨습니다!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ⏰ 시간 정보
            _buildTimeInfoSection(startTime, endTime, totalMinutes),
            const SizedBox(height: 24),

            // ✅ 완료한 스텝들
            if (completedSteps.isNotEmpty) ...[
              _buildSectionHeader(
                '✅ 완료한 스텝 (${completedSteps.length}개)',
                Colors.green,
              ),
              const SizedBox(height: 12),
              ...completedSteps.map((step) => _buildStepResultCard(step, true)),
              const SizedBox(height: 20),
            ],

            // ⏭️ 건너뛴 스텝들
            if (skippedSteps.isNotEmpty) ...[
              _buildSectionHeader(
                '⏭️ 건너뛴 스텝 (${skippedSteps.length}개)',
                Colors.orange,
              ),
              const SizedBox(height: 12),
              ...skippedSteps.map((step) => _buildStepResultCard(step, false)),
              const SizedBox(height: 20),
            ],

            // 📊 통계 요약
            _buildStatsSummary(completedSteps, skippedSteps),
            const SizedBox(height: 24),

            // ✅ 확인 버튼 (대시보드로 이동)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // 대시보드 페이지로 이동
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/dashboard',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('확인'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⏰ 시간 정보 섹션
  Widget _buildTimeInfoSection(
      DateTime startTime, DateTime endTime, int totalMinutes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                '시간 정보',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeInfoItem(
                '시작',
                DateFormat('a h:mm:ss', 'ko_KR').format(startTime),
                Icons.play_arrow,
              ),
              _buildTimeInfoItem(
                '완료',
                DateFormat('a h:mm:ss', 'ko_KR').format(endTime),
                Icons.stop,
              ),
              _buildTimeInfoItem(
                '총 소요',
                _formatDuration(routineState.totalElapsedSeconds),
                Icons.timer,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 시간 정보 아이템
  Widget _buildTimeInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[600], size: 16),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 섹션 헤더
  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // 스텝 결과 카드
  Widget _buildStepResultCard(StepResult step, bool isCompleted) {
    final targetMinutes = (step.targetSeconds / 60).round();
    final actualMinutes = (step.actualSeconds / 60).round();
    final actualSeconds = step.actualSeconds % 60;
    final isOverTime = step.actualSeconds > step.targetSeconds;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.05)
            : Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.2)
              : Colors.orange.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // 스텝 아이콘
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.skip_next,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // 스텝 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.stepTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (step.stepDescription.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.stepDescription,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 시간 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${actualMinutes}분 ${actualSeconds.toString().padLeft(2, '0')}초',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isOverTime ? Colors.red : Colors.black87,
                ),
              ),
              Text(
                '목표: ${targetMinutes}분',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              if (isOverTime)
                Text(
                  '+${((step.actualSeconds - step.targetSeconds) / 60).round()}분 초과',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 📊 통계 요약
  Widget _buildStatsSummary(
      List<StepResult> completed, List<StepResult> skipped) {
    final totalSteps = completed.length + skipped.length;
    final completionRate =
        totalSteps > 0 ? (completed.length / totalSteps * 100).round() : 0;
    final totalStepTime =
        completed.fold(0, (sum, step) => sum + step.actualSeconds) +
            skipped.fold(0, (sum, step) => sum + step.actualSeconds);
    final avgTimePerStep =
        totalSteps > 0 ? (totalStepTime / totalSteps / 60).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.grey[700], size: 20),
              const SizedBox(width: 8),
              Text(
                '📊 통계 요약',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('완료율', '$completionRate%', Colors.green),
              _buildStatItem('총 스텝', '$totalSteps개', Colors.blue),
              _buildStatItem('평균 시간', '${avgTimePerStep}분', Colors.orange),
              _buildStatItem('획득 EXP', '+${expGained}', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  // 통계 아이템
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
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
}
