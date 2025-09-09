// 👤 프로필 페이지
// 사용자 설정과 앱 정보를 관리하는 화면
import 'package:flutter/material.dart';
import 'profile_edit_page.dart';
import 'goal_setting_page.dart';
import 'notification_settings_page.dart';
import 'app_info_page.dart';
import 'help_page.dart';
import '../../services/profile_service.dart';
import '../../services/user_stats_service.dart';
import '../../services/dashboard_data_service.dart';
import '../../services/notification_settings_service.dart';
import '../../services/unified_notification_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isStatsExpanded = false; // 통계 섹션 펼침/접힘 상태

  @override
  void initState() {
    super.initState();
    // 서비스 초기화
    ProfileService.initialize();
    UserStatsService.initialize();
    NotificationSettingsService.initialize();
    UnifiedNotificationService.initialize();
    // 대시보드 데이터와 통계 동기화
    _syncWithDashboard();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 페이지가 다시 포커스될 때마다 데이터 동기화
    _syncWithDashboard();
  }

  @override
  void didUpdateWidget(ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 위젯이 업데이트될 때마다 데이터 동기화
    _syncWithDashboard();
  }

  // 대시보드 데이터와 통계 동기화
  Future<void> _syncWithDashboard() async {
    try {
      final success = await DashboardDataService.syncStatsWithDashboard();
      if (success && mounted) {
        setState(() {}); // 화면 새로고침
        print('프로필 페이지 데이터 동기화 완료');
      }
    } catch (e) {
      print('프로필 페이지 동기화 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 사용자 정보 카드 (확대된 버전)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단: 이모지, 이름, 수정 버튼
                  Row(
                    children: [
                      // 이모지 프로필
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6750A4).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF6750A4),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            ProfileService.currentProfile.emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // 사용자 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ProfileService.currentProfile.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6750A4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${ProfileService.currentProfile.gender} • ${ProfileService.currentProfile.age}세',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ProfileService.currentProfile.bio,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 프로필 수정 버튼
                      IconButton(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ProfileEditPage(),
                            ),
                          );
                          // 프로필이 수정되었으면 화면 새로고침
                          if (result == true) {
                            setState(() {});
                          }
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Color(0xFF6750A4),
                          size: 28,
                        ),
                        tooltip: '프로필 수정',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 목표 섹션
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6750A4).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF6750A4).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.flag,
                          color: Color(0xFF6750A4),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '주요 목표',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6750A4),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ProfileService.currentProfile.goal,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 관심사 섹션
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Color(0xFF6750A4),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '관심사: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          children: ProfileService.currentProfile.interests
                              .map((interest) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6750A4).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      const Color(0xFF6750A4).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                interest,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6750A4),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 통계 정보 (확장된 버전)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 통계 제목과 레벨
                  Row(
                    children: [
                      const Text(
                        '나의 통계',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6750A4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF6750A4).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'Lv.${UserStatsService.currentStats.currentLevel}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6750A4),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 기본 통계 (항상 표시)
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildCompactStatItem(
                              '총 루틴',
                              '${UserStatsService.currentStats.totalRoutines}개',
                              Icons.list_alt)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildCompactStatItem(
                              '활동 일수',
                              '${UserStatsService.currentStats.totalDaysActive}일',
                              Icons.calendar_today)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildCompactStatItem(
                              '연속 달성',
                              '${UserStatsService.currentStats.currentStreak}일',
                              Icons.local_fire_department)),
                    ],
                  ),

                  // 합계 경험치 표시 (새로 추가)
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.withOpacity(0.1),
                          Colors.orange.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '합계 경험치',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${UserStatsService.currentStats.totalExperience} EXP',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Lv.${UserStatsService.currentStats.currentLevel}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 확장된 통계 (펼쳤을 때만 표시)
                  if (_isStatsExpanded) ...[
                    const SizedBox(height: 20),
                    _buildExpandedStats(),
                  ],

                  // 펼치기 버튼 (하단)
                  const SizedBox(height: 16),
                  Center(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isStatsExpanded = !_isStatsExpanded;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6750A4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF6750A4).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isStatsExpanded ? '간단히 보기' : '자세히 보기',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6750A4),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _isStatsExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: const Color(0xFF6750A4),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 설정 메뉴
          Card(
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.notifications,
                  title: '알림 설정',
                  subtitle: _getNotificationSubtitleText(),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationSettingsPage(),
                      ),
                    );
                    // 알림 설정 후 화면 새로고침
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 앱 정보
          Card(
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.info,
                  title: '앱 정보',
                  subtitle: '버전 1.0.0',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AppInfoPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  icon: Icons.help,
                  title: '도움말',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HelpPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 컴팩트한 통계 아이템
  Widget _buildCompactStatItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF6750A4).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF6750A4).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6750A4),
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6750A4),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 확장된 통계 섹션
  Widget _buildExpandedStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 레벨 정보
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6750A4).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF6750A4).withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                UserStatsService.currentStats.currentLevelTitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              _buildLevelProgress(),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 추가 통계는 제거 (이미 기본 통계에 포함됨)

        const SizedBox(height: 16),

        // 목표 진행률
        _buildGoalProgress(),
      ],
    );
  }

  // 레벨 진행률 표시
  Widget _buildLevelProgress() {
    final stats = UserStatsService.currentStats;
    final progress = stats.levelProgress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6750A4).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6750A4).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '레벨 진행률',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${stats.totalExperience % 1000} / 1000 XP',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6750A4),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6750A4)),
            minHeight: 8,
          ),
          const SizedBox(height: 4),
          Text(
            '다음 레벨까지 ${stats.experienceToNextLevel} XP',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 통계 카드
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6750A4).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6750A4).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6750A4),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6750A4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 목표 진행률 표시
  Widget _buildGoalProgress() {
    final stats = UserStatsService.currentStats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '목표 진행률',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GoalSettingPage(),
                  ),
                );
                // 목표 설정 후 화면 새로고침
                setState(() {});
              },
              icon: const Icon(Icons.settings, size: 16),
              label: const Text('설정'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 주간 목표 (실제 데이터 반영)
        _buildProgressItem(
          '이번 주',
          '${stats.weeklyCompletedRoutines} / ${stats.weeklyGoal}',
          stats.weeklyGoalProgress.clamp(0.0, 1.0), // 100% 초과시 100%로 제한
          Icons.calendar_today,
        ),

        const SizedBox(height: 12),

        // 월간 목표 (실제 데이터 반영)
        _buildProgressItem(
          '이번 달',
          '${stats.monthlyCompletedRoutines} / ${stats.monthlyGoal}',
          stats.monthlyGoalProgress,
          Icons.calendar_month,
        ),
      ],
    );
  }

  // 진행률 아이템
  Widget _buildProgressItem(
      String title, String subtitle, double progress, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6750A4),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF6750A4)),
                  minHeight: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6750A4),
            ),
          ),
        ],
      ),
    );
  }

  // 알림 설정 서브타이틀 텍스트 생성
  String _getNotificationSubtitleText() {
    try {
      final settings = NotificationSettingsService.currentSettings;
      final summary = NotificationSettingsService.getSettingsSummary();

      if (!settings.isNotificationEnabled) {
        return '알림 비활성화';
      }

      return '${summary['activeCount']}/${summary['totalCount']}개 활성화';
    } catch (e) {
      return '설정 로드 중...';
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6750A4)),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
