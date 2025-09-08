// 🎯 다음 스텝 카드 위젯
// PRD 핵심: 화면에 "다음 1개" 스텝만 표시하는 메인 위젯
// 완료/스킵 버튼, 타이머, 하프틱 피드백 포함
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/routine_provider.dart';
import '../../domain/models/step.dart';

class NextStepCard extends ConsumerWidget {
  const NextStepCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 스텝 데이터 가져오기
    final currentStep = ref.watch(currentStepProvider);
    final isCompleted = ref.watch(isRoutineCompletedProvider);

    // 루틴이 완료된 경우
    if (isCompleted) {
      return _buildCompletionCard(context);
    }

    // 스텝이 없는 경우 (에러 상태)
    if (currentStep == null) {
      return _buildErrorCard(context, ref);
    }

    return Card(
      elevation: 8,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 스텝 타입 아이콘
            Text(
              currentStep.type.emoji,
              style: const TextStyle(fontSize: 32),
            ),

            const SizedBox(height: 16),

            // 📝 스텝 제목
            Text(
              currentStep.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // 📄 스텝 설명 (있는 경우에만)
            if (currentStep.description != null) ...[
              Text(
                currentStep.description!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],

            // ⏱️ 예상 시간 (있는 경우에만)
            if (currentStep.estimatedMinutes != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '⏱️ 약 ${currentStep.estimatedMinutes}분',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 32),

            // 🎮 액션 버튼들
            Row(
              children: [
                // 스킵 버튼
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _onSkip(context, ref),
                    child: const Text('건너뛰기'),
                  ),
                ),

                const SizedBox(width: 16),

                // 완료 버튼 (메인 액션)
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _onComplete(context, ref),
                    child: const Text('완료!'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ 스텝 완료 처리
  void _onComplete(BuildContext context, WidgetRef ref) {
    // 하프틱 피드백 (PRD 요구사항: Light 강도)
    HapticFeedback.lightImpact();

    // Riverpod를 통한 상태 업데이트
    ref.read(currentStepProvider.notifier).complete();

    // XP 계산하여 피드백 표시
    final newXP = ref.read(currentXPProvider);

    // 🎨 개선된 응원 메시지 배열 - 더 감정적이고 동기부여가 되는 메시지들
    final encouragementMessages = [
      '🎊 완벽한 실행이에요! 다음 도전을 향해!',
      '🚀 놀라운 집중력이네요! 계속 이어가세요!',
      '💎 정말 멋진 모습이에요! 다음 스텝도 화이팅!',
      '🌟 환상적인 진행이에요! 당신은 정말 대단해요!',
      '🎯 완벽한 타이밍이에요! 다음 목표로!',
      '⚡ 엄청난 에너지네요! 계속 이 기세로!',
      '🏆 진정한 챔피언이에요! 다음 도전 준비됐나요?',
      '✨ 마법같은 순간이에요! 계속 이어가세요!',
      '🔥 불꽃같은 열정이에요! 다음 스텝도 완벽하게!',
      '💫 별처럼 빛나는 모습이에요! 계속 화이팅!',
      '🎪 서커스처럼 멋진 실행이에요! 다음은 뭘까요?',
      '🌈 무지개처럼 아름다운 진행이에요! 계속해요!',
      '🎭 연기처럼 자연스러운 완성도예요! 대단해요!',
      '🎨 예술작품 같은 완벽함이에요! 다음 걸작을 위해!',
      '🎵 음악처럼 리드미컬한 진행이에요! 계속 연주하세요!',
    ];

    // 랜덤 응원 메시지 선택
    final randomMessage = encouragementMessages[
        DateTime.now().millisecondsSinceEpoch % encouragementMessages.length];

    // 🎨 개선된 SnackBar - 더 시각적으로 매력적이고 정보가 풍부한 피드백
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // 성공 아이콘
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // 메시지와 XP 정보
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    randomMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '+10 XP 획득! (총 ${newXP}XP)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 2000), // 빠르게 표시
        backgroundColor: Colors.grey[900], // 깔끔한 검은색
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16), // 여백 추가
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // 더 둥글게
        ),
        elevation: 8, // 그림자 효과 강화
      ),
    );
  }

  // ⏭️ 스텝 스킵 처리
  void _onSkip(BuildContext context, WidgetRef ref) {
    // Riverpod를 통한 상태 업데이트
    ref.read(currentStepProvider.notifier).skip();

    // 위로/아쉬움 메시지 배열
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

    // 랜덤 위로 메시지 선택
    final randomMessage = skipMessages[
        DateTime.now().millisecondsSinceEpoch % skipMessages.length];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(randomMessage),
        duration: const Duration(milliseconds: 2000),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // 🎉 완료 카드
  Widget _buildCompletionCard(BuildContext context) {
    return Card(
      elevation: 8,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              '🎉 모든 스텝 완료!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '오늘의 루틴을 성공적으로 마무리했어요!\n내일도 함께 해보세요.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 테스트용: 루틴 리셋
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('루틴 리셋'),
                    content: const Text('테스트를 위해 루틴을 처음부터 다시 시작하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // context.read를 사용할 수 없으므로 다른 방법 필요
                        },
                        child: const Text('리셋'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('테스트용: 루틴 리셋'),
            ),
          ],
        ),
      ),
    );
  }

  // ❌ 에러 카드
  Widget _buildErrorCard(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 8,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              '스텝을 불러올 수 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(currentStepProvider.notifier).reset();
              },
              child: const Text('루틴 리셋'),
            ),
          ],
        ),
      ),
    );
  }
}
