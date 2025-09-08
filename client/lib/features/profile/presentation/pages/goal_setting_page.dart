// 🎯 목표 설정 페이지
// 사용자가 주간/월간 루틴 완료 목표를 설정할 수 있는 화면
import 'package:flutter/material.dart';
import '../../services/user_stats_service.dart';

class GoalSettingPage extends StatefulWidget {
  const GoalSettingPage({super.key});

  @override
  State<GoalSettingPage> createState() => _GoalSettingPageState();
}

class _GoalSettingPageState extends State<GoalSettingPage> {
  late int _weeklyGoal;
  late int _monthlyGoal;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 현재 설정된 목표값 가져오기
    _weeklyGoal = UserStatsService.currentStats.weeklyGoal;
    _monthlyGoal = UserStatsService.currentStats.monthlyGoal;
  }

  // 주간 목표 저장
  Future<void> _saveWeeklyGoal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await UserStatsService.setWeeklyGoal(_weeklyGoal);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('주간 목표가 ${_weeklyGoal}개로 설정되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('주간 목표 저장 실패');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('목표 설정에 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 월간 목표 저장
  Future<void> _saveMonthlyGoal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await UserStatsService.setMonthlyGoal(_monthlyGoal);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('월간 목표가 ${_monthlyGoal}개로 설정되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('월간 목표 저장 실패');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('목표 설정에 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('목표 설정'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading
                ? null
                : () async {
                    await _saveWeeklyGoal();
                    await _saveMonthlyGoal();
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
            child: Text(
              '저장',
              style: TextStyle(
                color: _isLoading ? Colors.grey : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 설명 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        const Text(
                          '목표 설정 안내',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '주간/월간으로 완료할 루틴의 개수를 설정하세요.\n'
                      '목표를 달성하면 더 많은 경험치를 얻을 수 있습니다!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 주간 목표 설정
            _buildGoalSettingCard(
              title: '주간 목표',
              subtitle: '이번 주에 완료할 루틴 개수',
              icon: Icons.calendar_today,
              currentValue: _weeklyGoal,
              onChanged: (value) {
                setState(() {
                  _weeklyGoal = value;
                });
              },
              minValue: 1,
              maxValue: 50,
              color: Colors.blue,
            ),

            const SizedBox(height: 16),

            // 월간 목표 설정
            _buildGoalSettingCard(
              title: '월간 목표',
              subtitle: '이번 달에 완료할 루틴 개수',
              icon: Icons.calendar_month,
              currentValue: _monthlyGoal,
              onChanged: (value) {
                setState(() {
                  _monthlyGoal = value;
                });
              },
              minValue: 1,
              maxValue: 200,
              color: Colors.purple,
            ),

            const SizedBox(height: 24),

            // 현재 진행 상황
            _buildCurrentProgressCard(),

            const SizedBox(height: 24),

            // 추천 설정
            _buildRecommendationCard(),
          ],
        ),
      ),
    );
  }

  // 목표 설정 카드
  Widget _buildGoalSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required int currentValue,
    required ValueChanged<int> onChanged,
    required int minValue,
    required int maxValue,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 현재 값 표시
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  '$currentValue개',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 슬라이더
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '최소: $minValue개',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '최대: $maxValue개',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: currentValue.toDouble(),
                  min: minValue.toDouble(),
                  max: maxValue.toDouble(),
                  divisions: maxValue - minValue,
                  activeColor: color,
                  inactiveColor: color.withOpacity(0.3),
                  onChanged: (value) {
                    onChanged(value.round());
                  },
                ),
              ],
            ),

            // 빠른 설정 버튼들
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildQuickSetButton('5개', 5, currentValue, onChanged, color),
                _buildQuickSetButton('10개', 10, currentValue, onChanged, color),
                _buildQuickSetButton('15개', 15, currentValue, onChanged, color),
                _buildQuickSetButton('20개', 20, currentValue, onChanged, color),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 빠른 설정 버튼
  Widget _buildQuickSetButton(
    String label,
    int value,
    int currentValue,
    ValueChanged<int> onChanged,
    Color color,
  ) {
    final isSelected = currentValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  // 현재 진행 상황 카드
  Widget _buildCurrentProgressCard() {
    final stats = UserStatsService.currentStats;
    final weeklyProgress = stats.weeklyGoalProgress;
    final monthlyProgress = stats.monthlyGoalProgress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  '현재 진행 상황',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 주간 진행률
            _buildProgressItem(
              '이번 주',
              '${stats.weeklyCompletedRoutines} / ${stats.weeklyGoal}',
              weeklyProgress,
              Colors.blue,
            ),

            const SizedBox(height: 12),

            // 월간 진행률
            _buildProgressItem(
              '이번 달',
              '${stats.monthlyCompletedRoutines} / ${stats.monthlyGoal}',
              monthlyProgress,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  // 진행률 아이템
  Widget _buildProgressItem(
    String title,
    String subtitle,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // 추천 설정 카드
  Widget _buildRecommendationCard() {
    final totalRoutines = UserStatsService.currentStats.totalRoutines;

    // 추천 목표 계산 (주간 5배, 월간 20배)
    final recommendedWeekly = (totalRoutines * 5).clamp(1, 50);
    final recommendedMonthly = (totalRoutines * 20).clamp(1, 200);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
                const SizedBox(width: 8),
                const Text(
                  '추천 설정',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '현재 ${totalRoutines}개의 루틴을 보유하고 계시네요!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '추천 목표: 주간 ${recommendedWeekly}개, 월간 ${recommendedMonthly}개',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _weeklyGoal = recommendedWeekly;
                    _monthlyGoal = recommendedMonthly;
                  });
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('추천 설정 적용'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
