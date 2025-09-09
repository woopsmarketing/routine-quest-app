// 📊 대시보드 페이지
// 사용자의 루틴 통계와 전체적인 진행 상황을 보여주는 화면
// RPG 경험치 시스템과 캘린더 기반 히스토리 제공
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/api/api_client.dart';
import '../../../../shared/services/user_progress_service.dart';
import '../../../today/data/providers/routine_completion_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 페이지가 다시 포커스될 때마다 데이터 새로고침
    _refreshData();
  }

  // RPG 데이터 (실제 데이터로 동기화됨)
  int _currentLevel = 1;
  int _currentExp = 0;
  String _userTitle = "루틴 초보자";

  // 오늘의 통계
  int _todayExp = 270;
  int _streakDays = 7;
  int _completionRate = 85;
  int _completedSteps = 0;
  int _skippedSteps = 0;
  int _skippedRoutines = 0;

  // 임시 캘린더 이벤트 데이터
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};
  // 오늘 날짜 기준 대기(미시작) 루틴 리스트
  List<Map<String, dynamic>> _pendingRoutinesToday = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadCalendarEvents();
    _loadUserStats();
  }

  void _loadCalendarEvents() {
    // 실제 루틴 완료 기록을 불러와서 캘린더에 표시
    _loadRoutineHistory();
  }

  // 데이터 새로고침 (다른 페이지에서 루틴 완료 시 호출됨)
  Future<void> _refreshData() async {
    await _loadRoutineHistory();
    await _loadUserStats();
  }

  Future<void> _loadRoutineHistory() async {
    try {
      // SharedPreferences에서 루틴 완료 기록 불러오기
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('routine_history') ?? '{}';
      final historyData = json.decode(historyJson) as Map<String, dynamic>;

      final Map<DateTime, List<Map<String, dynamic>>> events = {};

      historyData.forEach((dateString, routines) {
        final date = DateTime.parse(dateString);
        final dateKey = DateTime(date.year, date.month, date.day);
        events[dateKey] = List<Map<String, dynamic>>.from(routines);
      });

      // 오늘 날짜의 대기 루틴(아직 시작하지 않은 루틴) 계산 (실제 API 목록 기반)
      await _loadPendingRoutines(events);

      setState(() {
        _events.clear(); // 기존 데이터 클리어하고 새로 로드
        _events.addAll(events);
      });

      // 데이터가 없으면 빈 상태로 유지
      if (events.isEmpty) {
        print('히스토리 데이터가 없습니다.');
      }
    } catch (e) {
      print('히스토리 로드 오류: $e');
    }
  }

  // 오늘 대기 중인 루틴들 로드
  Future<void> _loadPendingRoutines(
      Map<DateTime, List<Map<String, dynamic>>> events) async {
    try {
      final today = DateTime.now();
      final todayKey = DateTime(today.year, today.month, today.day);

      // 오늘 완료된 루틴들 (히스토리 + 실시간 완료 상태)
      final todayEvents = events[todayKey] ?? [];
      final completedRoutineNames =
          todayEvents.map((e) => e['routine'] as String).toSet();

      // 실시간 완료 상태도 확인
      final completionState = ref.read(routineCompletionProvider);

      // 실제 API에서 전체 루틴 목록 취득
      final apiRoutines = await ApiClient.getRoutines();
      final pending = <Map<String, dynamic>>[];

      for (final routine in apiRoutines) {
        final routineTitle = routine['title'] ?? routine['name'] ?? '루틴';
        final routineId = routine['id']?.toString() ?? '';
        final isTodayDisplay = routine['today_display'] ?? false;

        // 오늘 노출이 활성화된 루틴만 확인
        if (!isTodayDisplay) continue;

        // 완료되지 않은 루틴만 대기 목록에 추가 (히스토리 + 실시간 상태 둘 다 확인)
        final isCompletedInHistory =
            completedRoutineNames.contains(routineTitle);
        final isCompletedRealtime =
            completionState.isRoutineCompleted(routineId);

        if (!isCompletedInHistory && !isCompletedRealtime) {
          pending.add({
            'routine': routineTitle,
            'total_steps': (routine['steps'] as List?)?.length ?? 0,
            'id': routine['id'],
          });
        }
      }

      _pendingRoutinesToday = pending;
      print('오늘 대기 중인 루틴: ${pending.length}개');
    } catch (e) {
      print('대기 루틴 로드 오류: $e');
      _pendingRoutinesToday = [];
    }
  }

  Future<void> _loadUserStats() async {
    try {
      // UserProgressService에서 실제 데이터 가져오기
      final userStats = await UserProgressService.getUserStats();
      final todayStats = await UserProgressService.getTodayStats();
      final streakDays = await UserProgressService.getStreakDays();

      setState(() {
        _currentLevel = userStats['level'] as int;
        _currentExp = userStats['exp'] as int;
        // 실제 레벨에 따른 칭호로 동기화
        _userTitle = _getLevelTitle(_currentLevel);

        // 오늘의 통계 업데이트
        _todayExp = todayStats['todayExp'] ?? 0;
        _streakDays = streakDays; // 실제 연속 일수
        _completionRate = todayStats['completionRate'] ?? 0;
        _completedSteps = todayStats['completedSteps'] ?? 0;
        _skippedSteps = todayStats['skippedSteps'] ?? 0;
        _skippedRoutines = todayStats['skippedRoutines'] ?? 0;
      });
    } catch (e) {
      print('대시보드 사용자 통계 로드 오류: $e');
      // 에러 시 기본값 유지
    }
  }

  // 레벨에 따른 칭호 가져오기 (UserStatsModel과 동일한 로직)
  String _getLevelTitle(int level) {
    switch (level) {
      case 1:
        return '루틴 초보자';
      case 2:
        return '루틴 적응자';
      case 3:
        return '루틴 실천자';
      case 4:
        return '루틴 마스터';
      case 5:
        return '루틴 달인';
      case 6:
        return '루틴 전문가';
      case 7:
        return '루틴 고수';
      case 8:
        return '루틴 전설';
      case 9:
        return '루틴 제왕';
      case 10:
        return '루틴 신';
      default:
        return '루틴 초보자';
    }
  }

  // 더 이상 사용하지 않음 - 1000 XP당 레벨업으로 통일

  // 초를 분:초 형식으로 포맷
  String _formatTime(int totalSeconds) {
    if (totalSeconds == 0) return '0초';

    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    if (minutes > 0 && seconds > 0) {
      return '${minutes}분 ${seconds}초';
    } else if (minutes > 0) {
      return '${minutes}분';
    } else {
      return '${seconds}초';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대시보드'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // 알림 페이지로 이동
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RPG 프로필 섹션
            _buildRPGProfile(),
            const SizedBox(height: 24),

            // 캘린더 섹션
            _buildCalendarSection(),
            const SizedBox(height: 24),

            // 선택된 날짜의 루틴 내역
            _buildSelectedDayDetails(),
          ],
        ),
      ),
    );
  }

  // RPG 프로필 섹션
  Widget _buildRPGProfile() {
    final currentLevelExp = _currentExp % 1000;
    final expProgress = currentLevelExp / 1000;
    final expRemaining = 1000 - currentLevelExp;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.8),
            Colors.deepPurple.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 아바타
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),

              // 레벨과 타이틀
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Lv.$_currentLevel',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _userTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 경험치 바
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'EXP ${_currentExp % 1000} / 1000',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '$expRemaining EXP 남음',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: expProgress,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.amber),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 오늘의 성취
          Row(
            children: [
              _buildAchievementStat(
                  '오늘 EXP', '+$_todayExp', Icons.star, Colors.amber),
              const SizedBox(width: 16),
              _buildAchievementStat('연속 일수', '${_streakDays}일',
                  Icons.local_fire_department, Colors.orange),
              const SizedBox(width: 16),
              _buildAchievementStat(
                  '완료율', '$_completionRate%', Icons.trending_up, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementStat(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 캘린더 섹션
  Widget _buildCalendarSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  '루틴 히스토리',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TableCalendar<Map<String, dynamic>>(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) {
                final dateKey = DateTime(day.year, day.month, day.day);
                return _events[dateKey] ?? [];
              },
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: Colors.red[400]),
                holidayTextStyle: TextStyle(color: Colors.red[400]),
                markerDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(Icons.chevron_left),
                rightChevronIcon: Icon(Icons.chevron_right),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ],
        ),
      ),
    );
  }

  // 선택된 날짜의 루틴 상세 정보
  Widget _buildSelectedDayDetails() {
    if (_selectedDay == null) return const SizedBox.shrink();

    final dateKey =
        DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final dayEvents = _events[dateKey] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_note, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  '${_selectedDay!.month}월 ${_selectedDay!.day}일 루틴 결과',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (dayEvents.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      '이 날에는 완료한 루틴이 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else
              ...dayEvents.map((event) => _buildRoutineResultCard(event)),

            const SizedBox(height: 16),

            // 아직 시작하지 않은 루틴 섹션
            if (_pendingRoutinesToday.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.pending_actions, color: Colors.deepPurple[700]),
                  const SizedBox(width: 8),
                  const Text(
                    '아직 시작하지 않은 루틴',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._pendingRoutinesToday.map((r) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.deepPurple.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.hourglass_bottom,
                              color: Colors.deepPurple[700], size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            r['routine'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text('총 ${r['total_steps']} 스텝',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
            ],

            // 일일 총계
            if (dayEvents.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.1),
                      Colors.purple.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // 첫 번째 행: 루틴 통계
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDaySummaryItem(
                          '완료 루틴',
                          '${dayEvents.length}개',
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _buildDaySummaryItem(
                          '건너뛴 루틴',
                          '$_skippedRoutines개',
                          Icons.skip_next,
                          Colors.orange,
                        ),
                        _buildDaySummaryItem(
                          '총 획득 EXP',
                          '+${dayEvents.fold(0, (sum, event) => sum + (event['exp'] as int))}',
                          Icons.star,
                          Colors.amber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 두 번째 행: 스텝 통계
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDaySummaryItem(
                          '완료 스텝',
                          '$_completedSteps개',
                          Icons.check,
                          Colors.green,
                        ),
                        _buildDaySummaryItem(
                          '건너뛴 스텝',
                          '$_skippedSteps개',
                          Icons.skip_next,
                          Colors.orange,
                        ),
                        _buildDaySummaryItem(
                          '완료율',
                          '$_completionRate%',
                          Icons.trending_up,
                          Colors.blue,
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
  }

  Widget _buildRoutineResultCard(Map<String, dynamic> event) {
    final completedSteps = event['completed_steps'] as int;
    final totalSteps = event['total_steps'] as int;
    final skippedSteps = event['skipped_steps'] as int? ?? 0;
    final isSkipped = event['is_skipped'] as bool? ?? false;
    final completionRate = totalSteps > 0 ? completedSteps / totalSteps : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSkipped ? Colors.orange.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSkipped
              ? Colors.orange.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSkipped
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(isSkipped ? Icons.skip_next : Icons.task_alt,
                    color: isSkipped ? Colors.orange[700] : Colors.blue[700],
                    size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['routine'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSkipped ? Colors.orange[800] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSkipped
                          ? '${totalSteps}개 스텝 모두 건너뛰기 • ${event['time_taken']} 소요'
                          : skippedSteps > 0
                              ? '${completedSteps}/${totalSteps} 스텝 완료 (${skippedSteps}개 건너뛰기) • ${event['time_taken']} 소요'
                              : '${completedSteps}/${totalSteps} 스텝 완료 • ${event['time_taken']} 소요',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSkipped)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${event['exp']} EXP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800],
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: completionRate,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySummaryItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
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

  // 주간 통계
  Widget _buildWeeklyStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.purple[700]),
                const SizedBox(width: 8),
                const Text(
                  '이번 주 통계',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 간단한 주간 진행률 바
            Column(
              children: [
                _buildWeeklyProgressBar('월', 0.8, Colors.green),
                _buildWeeklyProgressBar('화', 1.0, Colors.green),
                _buildWeeklyProgressBar('수', 0.6, Colors.orange),
                _buildWeeklyProgressBar('목', 0.9, Colors.green),
                _buildWeeklyProgressBar('금', 0.7, Colors.orange),
                _buildWeeklyProgressBar('토', 0.3, Colors.red),
                _buildWeeklyProgressBar('일', 0.0, Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressBar(String day, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              day,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 최근 완료한 루틴
  Widget _buildRecentCompletions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.grey[700]),
                const SizedBox(width: 8),
                const Text(
                  '최근 완료한 루틴',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 최근 완료 항목들
            _buildRecentItem('생산적인 아침 루틴', '오늘 오전 9:30', Colors.green),
            _buildRecentItem('건강한 점심 루틴', '어제 오후 12:15', Colors.blue),
            _buildRecentItem('편안한 저녁 루틴', '어제 오후 8:45', Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItem(String title, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: color,
            size: 20,
          ),
        ],
      ),
    );
  }
}
