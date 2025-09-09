// 📋 루틴 목록 페이지
// 사용자가 만든 루틴들을 관리하는 화면
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'create_routine_page.dart';
import 'routine_detail_page.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
import '../../data/providers/routine_list_provider.dart';

// 더미 루틴 데이터
class DummyRoutine {
  final String id;
  final String title;
  final String description;
  final int totalSteps;
  final int completedSteps;
  final String icon;
  final Color color;
  final bool isActive;

  const DummyRoutine({
    required this.id,
    required this.title,
    required this.description,
    required this.totalSteps,
    required this.completedSteps,
    required this.icon,
    required this.color,
    this.isActive = false,
  });
}

class RoutineListPage extends ConsumerStatefulWidget {
  const RoutineListPage({super.key});

  @override
  ConsumerState<RoutineListPage> createState() => _RoutineListPageState();
}

class _RoutineListPageState extends ConsumerState<RoutineListPage> {
  @override
  void initState() {
    super.initState();
    // 루틴 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(routineListProvider.notifier).loadRoutines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final routineState = ref.watch(routineListProvider);
    final todayRoutines = ref.watch(todayDisplayRoutinesProvider);
    final hiddenRoutines = ref.watch(hiddenRoutinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('루틴'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateRoutinePage(),
                ),
              );

              // 루틴이 생성되었으면 목록 새로고침
              if (result == true) {
                ref.read(routineListProvider.notifier).loadRoutines();
              }
            },
          ),
        ],
      ),
      body: routineState.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : routineState.routines.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '아직 루틴이 없습니다',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '새 루틴을 만들어보세요!',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CreateRoutinePage(),
                            ),
                          );

                          if (result == true) {
                            ref
                                .read(routineListProvider.notifier)
                                .loadRoutines();
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('첫 루틴 만들기'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(routineListProvider.notifier).loadRoutines(),
                  child:
                      _buildGroupedRoutineList(todayRoutines, hiddenRoutines),
                ),
    );
  }

  // 📂 활성화/비활성화 루틴을 그룹으로 나누어 표시
  Widget _buildGroupedRoutineList(List<Map<String, dynamic>> todayRoutines,
      List<Map<String, dynamic>> hiddenRoutines) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ 활성화된 루틴 섹션
          if (todayRoutines.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.home, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  '오늘 페이지에 표시 (${todayRoutines.length}개)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...todayRoutines.map((routine) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildRoutineCardFromApi(context, routine),
                )),
            const SizedBox(height: 24),
          ],

          // 📋 비활성화된 루틴 섹션
          if (hiddenRoutines.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.home_outlined, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  '오늘 페이지에 숨김 (${hiddenRoutines.length}개)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...hiddenRoutines.map((routine) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Opacity(
                    opacity: 0.7, // 비활성화된 루틴은 약간 투명하게
                    child: _buildRoutineCardFromApi(context, routine),
                  ),
                )),
          ],

          // 빈 상태 처리
          if (todayRoutines.isEmpty && hiddenRoutines.isEmpty)
            const Center(
              child: Text(
                '루틴이 없습니다',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoutineCardFromApi(
      BuildContext context, Map<String, dynamic> routine) {
    final steps = routine['steps'] as List<dynamic>? ?? [];
    final completed = routine['total_completions'] ?? 0;
    // 🎨 색상 파싱 (안전하게 처리)
    Color color;
    try {
      final colorStr = routine['color']?.toString() ?? '#6366F1';
      final hexColor =
          colorStr.startsWith('#') ? colorStr.substring(1) : colorStr;
      color = Color(int.parse(hexColor, radix: 16) + 0xFF000000);
    } catch (e) {
      // 파싱 실패 시 기본 색상 사용
      color = const Color(0xFF6366F1);
    }

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            routine['icon'] ?? '🎯',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(routine['title'] ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (routine['description'] != null &&
                routine['description'].toString().isNotEmpty)
              Text(routine['description']),
            const SizedBox(height: 8),

            // 🎯 오늘 노출 토글과 자동 시작 정보를 구분해서 표시
            Row(
              children: [
                // 🏠 오늘 노출 토글 (터치 가능)
                GestureDetector(
                  onTap: () => _handleTodayDisplayToggle(context, routine),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: routine['today_display'] == true
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: routine['today_display'] == true
                            ? Colors.green.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          routine['today_display'] == true
                              ? Icons.home
                              : Icons.home_outlined,
                          size: 14,
                          color: routine['today_display'] == true
                              ? Colors.green[700]
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          routine['today_display'] == true ? '오늘 노출' : '오늘 숨김',
                          style: TextStyle(
                            fontSize: 12,
                            color: routine['today_display'] == true
                                ? Colors.green[700]
                                : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 자동 시작 시간 표시 (별도 구분)
                Expanded(child: _buildAutoStartInfo(routine['id'] as int)),
              ],
            ),
            const SizedBox(height: 8),

            // 스텝 요약 표시
            _buildStepsSummary(steps),
            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: steps.isNotEmpty ? completed / steps.length : 0,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'today',
              child: Row(
                children: [
                  Icon(routine['today_display'] == true
                      ? Icons.home
                      : Icons.home_outlined),
                  const SizedBox(width: 8),
                  Text(routine['today_display'] == true ? '오늘 숨기기' : '오늘 표시'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(routine['is_active'] == true
                      ? Icons.pause
                      : Icons.play_arrow),
                  const SizedBox(width: 8),
                  Text(routine['is_active'] == true ? '비활성화' : '활성화'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('삭제', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) =>
              _handleRoutineAction(context, routine, value.toString()),
        ),
        onTap: () async {
          // 루틴 상세 화면으로 이동
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RoutineDetailPage(
                routineId: routine['id'] as int,
                routineTitle: routine['title'] ?? '루틴',
              ),
            ),
          );

          // 적용하기 버튼을 눌렀으면 목록 새로고침
          if (result == true) {
            ref.read(routineListProvider.notifier).loadRoutines();
          }
        },
      ),
    );
  }

  // 🏠 오늘 노출 토글 처리 (간단한 터치 액션)
  Future<void> _handleTodayDisplayToggle(
      BuildContext context, Map<String, dynamic> routine) async {
    final routineId = routine['id'] as int;
    final currentDisplayStatus = routine['today_display'] ?? false;

    try {
      // 프로바이더를 통한 토글
      await ref
          .read(routineListProvider.notifier)
          .toggleTodayDisplay(routineId);

      // 간단한 피드백 (수정된 로직)
      if (!currentDisplayStatus) {
        CustomSnackbar.showSuccess(context, '${routine['title']}\n오늘 화면에 표시');
      } else {
        CustomSnackbar.showWarning(context, '${routine['title']}\n오늘 화면에서 숨김');
      }
    } catch (e) {
      CustomSnackbar.showError(context, '설정 변경에\n실패했습니다');
    }
  }

  Future<void> _handleRoutineAction(
      BuildContext context, Map<String, dynamic> routine, String action) async {
    final routineId = routine['id'] as int;

    switch (action) {
      case 'today':
        try {
          await ref
              .read(routineListProvider.notifier)
              .toggleTodayDisplay(routineId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${routine['title']} 설정이 변경되었습니다'),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('설정 변경에 실패했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;
      case 'toggle':
        try {
          await ref.read(routineListProvider.notifier).toggleRoutine(routineId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${routine['title']}이(가) ${routine['is_active'] == true ? '비활성화' : '활성화'}되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('상태 변경에 실패했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;

      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('루틴 삭제'),
            content:
                Text('${routine['title']}을(를) 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('삭제'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          try {
            await ref
                .read(routineListProvider.notifier)
                .deleteRoutine(routineId);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${routine['title']}이(가) 삭제되었습니다'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('삭제에 실패했습니다: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        break;
    }
  }

  // 자동 시작 정보 표시
  Widget _buildAutoStartInfo(int routineId) {
    return FutureBuilder<Widget>(
      future: _getAutoStartWidget(routineId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        return const SizedBox.shrink(); // 로딩 중이거나 설정이 없으면 숨김
      },
    );
  }

  // 자동 시작 위젯 생성
  Future<Widget> _getAutoStartWidget(int routineId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsKey = 'auto_start_$routineId';
      final settingsJson = prefs.getString(settingsKey);

      if (settingsJson != null) {
        final settingsData = json.decode(settingsJson) as Map<String, dynamic>;
        final enabled = settingsData['enabled'] ?? false;

        if (enabled) {
          final timeString = settingsData['time'] ?? '09:00';
          final timeParts = timeString.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          // 시간 포맷팅 (오전/오후)
          final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
          final period = hour < 12 ? '오전' : '오후';
          final formattedTime =
              '$period $displayHour:${minute.toString().padLeft(2, '0')}';

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.orange[700]),
                const SizedBox(width: 4),
                Text(
                  '자동시작 설정됨 ($formattedTime)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
      }

      return const SizedBox.shrink(); // 자동 시작이 설정되지 않은 경우
    } catch (e) {
      return const SizedBox.shrink(); // 에러 시 숨김
    }
  }

  // 스텝 요약 표시
  Widget _buildStepsSummary(List<dynamic> steps) {
    if (steps.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '스텝이 없습니다',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }

    // 처음 3개 스텝만 표시
    final displaySteps = steps.take(3).toList();
    final hasMore = steps.length > 3;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...displaySteps.map((step) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Text(
                step['title'] ?? '스텝',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            )),
        if (hasMore)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
    );
  }
}
