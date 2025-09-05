// ⏱️ 스텝 타이머 위젯
// 스텝별 타이머와 완료 기능을 제공하는 위젯
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/step.dart' as routine_step;

class StepTimerWidget extends StatefulWidget {
  final routine_step.Step step;
  final Function(int elapsedSeconds) onCompleted; // 소요 시간 전달
  final Function(int elapsedSeconds) onSkipped; // 소요 시간 전달
  final bool isStarted;

  const StepTimerWidget({
    super.key,
    required this.step,
    required this.onCompleted,
    required this.onSkipped,
    required this.isStarted,
  });

  @override
  State<StepTimerWidget> createState() => _StepTimerWidgetState();
}

class _StepTimerWidgetState extends State<StepTimerWidget> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.isStarted) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(StepTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 스텝이 변경되면 타이머 리셋
    if (widget.step.title != oldWidget.step.title) {
      _timer?.cancel();
      setState(() {
        _elapsedSeconds = 0;
        _isRunning = false;
        _isCompleted = false;
      });

      // 루틴이 시작된 상태라면 새 스텝의 타이머 시작
      if (widget.isStarted) {
        _startTimer();
      }
    } else if (widget.isStarted && !oldWidget.isStarted) {
      _startTimer();
    } else if (!widget.isStarted && oldWidget.isStarted) {
      _stopTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _elapsedSeconds = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _completeStep() {
    _stopTimer();
    setState(() {
      _isCompleted = true;
    });

    // 하프틱 피드백
    HapticFeedback.lightImpact();

    // 잠시 완료 상태를 보여준 후 다음 스텝으로 이동
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        widget.onCompleted(_elapsedSeconds); // 소요 시간 전달
      }
    });
  }

  void _skipStep() {
    _stopTimer();
    widget.onSkipped(_elapsedSeconds); // 소요 시간 전달
  }

  // 시간을 분:초 형식으로 포맷
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // 진행률 계산 (목표 시간 대비)
  double _getProgress() {
    if (widget.step.estimatedMinutes == null) return 0.0;
    final targetSeconds = widget.step.estimatedMinutes! * 60;
    return (_elapsedSeconds / targetSeconds).clamp(0.0, 1.0);
  }

  // 시간 초과 여부
  bool _isOverTime() {
    if (widget.step.estimatedMinutes == null) return false;
    final targetSeconds = widget.step.estimatedMinutes! * 60;
    return _elapsedSeconds > targetSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final targetMinutes = widget.step.estimatedMinutes ?? 0;
    // 타겟 시간 계산 (분을 초로 변환)
    // final targetSeconds = targetMinutes * 60;
    final progress = _getProgress();
    final isOverTime = _isOverTime();

    return Card(
      elevation: 8,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 스텝 타입 아이콘과 제목
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getStepTypeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _getStepTypeEmoji(),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.step.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.step.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.step.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 타이머 디스플레이
            if (widget.isStarted) ...[
              // 원형 프로그레스와 시간
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    // 배경 원
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.grey[300]!),
                      ),
                    ),
                    // 진행률 원
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOverTime ? Colors.red : _getStepTypeColor(),
                        ),
                      ),
                    ),
                    // 중앙 시간 텍스트
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatTime(_elapsedSeconds),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isOverTime ? Colors.red : Colors.black87,
                            ),
                          ),
                          if (targetMinutes > 0) ...[
                            const SizedBox(height: 2),
                            Text(
                              '/ ${targetMinutes}분',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 시간 상태 메시지
              if (isOverTime)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '⏰ 목표 시간을 초과했습니다',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else if (targetMinutes > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStepTypeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '⏱️ 목표: ${targetMinutes}분',
                    style: TextStyle(
                      color: _getStepTypeColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ] else ...[
              // 시작 전 상태
              Icon(
                Icons.timer_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                '시작 버튼을 눌러 타이머를 시작하세요',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              if (targetMinutes > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '목표 시간: ${targetMinutes}분',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ],

            const SizedBox(height: 32),

            // 액션 버튼들
            if (widget.isStarted && !_isCompleted) ...[
              Row(
                children: [
                  // 스킵 버튼
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _skipStep,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('건너뛰기'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 완료 버튼
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _completeStep,
                      icon: const Icon(Icons.check),
                      label: const Text('완료!'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _getStepTypeColor(),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (_isCompleted) ...[
              // 완료 상태
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '완료!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '소요 시간: ${_formatTime(_elapsedSeconds)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 스텝 타입별 색상
  Color _getStepTypeColor() {
    switch (widget.step.type) {
      case routine_step.StepType.exercise:
        return Colors.orange;
      case routine_step.StepType.mindfulness:
        return Colors.blue;
      case routine_step.StepType.habit:
        return Colors.green;
      case routine_step.StepType.action:
        return Colors.purple;
      case routine_step.StepType.learning:
        return Colors.teal;
    }
  }

  // 스텝 타입별 이모지
  String _getStepTypeEmoji() {
    switch (widget.step.type) {
      case routine_step.StepType.exercise:
        return '💪';
      case routine_step.StepType.mindfulness:
        return '🧘';
      case routine_step.StepType.habit:
        return '✅';
      case routine_step.StepType.action:
        return '🎯';
      case routine_step.StepType.learning:
        return '📚';
    }
  }
}
