// ✅ 완료 요약 위젯
// 체인 완료 시 보상과 다음 행동 제안을 표시
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/routine_provider.dart';

class CompletionSummary extends ConsumerWidget {
  const CompletionSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 실시간 완료 상태 체크
    final isChainCompleted = ref.watch(isRoutineCompletedProvider);
    final xp = ref.watch(currentXPProvider);
    final streak = ref.watch(currentStreakProvider);
    
    if (!isChainCompleted) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.celebration,
            color: Colors.green,
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            '🎉 루틴 완료!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '오늘 하루도 성공적으로 마무리했어요!',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRewardChip('💰 ${xp}XP'),
              _buildRewardChip('🔥 ${streak}일 스트릭'),
              _buildRewardChip('⭐ 시즌 +1'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRewardChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}