// 📊 대시보드 페이지
// 사용자의 루틴 통계와 전체적인 진행 상황을 보여주는 화면
// RPG 경험치 시스템과 캘린더 기반 히스토리 제공
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../shared/services/user_progress_service.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // RPG 데이터 (실제 데이터로 동기화됨)
  int _currentLevel = 1;
  int _currentExp = 0;
  String _userTitle = "루틴 초보자";

  // 오늘의 통계
  int _todayExp = 270;
  int _streakDays = 7;
  int _completionRate = 85;
  int _totalTimeSeconds = 0;

  // 임시 캘린더 이벤트 데이터
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};

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

      setState(() {
        _events.addAll(events);
      });

      // 데이터가 없으면 더미 데이터로 대체
      if (events.isEmpty) {
        _loadDummyEvents();
      }
    } catch (e) {
      // 에러 시 더미 데이터로 대체
      _loadDummyEvents();
    }
  }

  void _loadDummyEvents() {
    // 임시 이벤트 데이터 생성 (실제 데이터가 없을 때)
    final today = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);

      if (i % 3 == 0) {
        // 3일마다 루틴 완료
        _events[dateKey] = [
          {
            'routine': '생산적인 아침 루틴',
            'exp': 150,
            'completed_steps': 4,
            'total_steps': 4,
            'time_taken': '25분',
          },
        ];
      }
      if (i % 4 == 0) {
        // 4일마다 추가 루틴
        _events[dateKey] = [
          ...(_events[dateKey] ?? []),
          {
            'routine': '건강한 저녁 루틴',
            'exp': 120,
            'completed_steps': 3,
            'total_steps': 3,
            'time_taken': '18분',
          },
        ];
      }
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
        _totalTimeSeconds = todayStats['totalTimeSeconds'] ?? 0;
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDaySummaryItem(
                      '완료 루틴',
                      '${dayEvents.length}개',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildDaySummaryItem(
                      '총 획득 EXP',
                      '+${dayEvents.fold(0, (sum, event) => sum + (event['exp'] as int))}',
                      Icons.star,
                      Colors.amber,
                    ),
                    _buildDaySummaryItem(
                      '총 소요시간',
                      _formatTime(_totalTimeSeconds),
                      Icons.timer,
                      Colors.blue,
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
    final completionRate =
        (event['completed_steps'] as int) / (event['total_steps'] as int);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.task_alt, color: Colors.blue[700], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['routine'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event['completed_steps']}/${event['total_steps']} 스텝 완료 • ${event['time_taken']} 소요',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: completionRate,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              completionRate >= 1.0 ? Colors.green : Colors.orange,
            ),
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
