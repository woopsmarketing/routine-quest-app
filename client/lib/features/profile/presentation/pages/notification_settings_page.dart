// 🔔 알림 설정 페이지
// 루틴 퀘스트 앱의 알림 설정을 관리하는 화면
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/notification_settings_service.dart';
import '../../services/unified_notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // 설정 로드
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await NotificationSettingsService.initialize();
      await UnifiedNotificationService.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('설정 로드 오류: $e')),
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('알림 설정')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final settings = NotificationSettingsService.currentSettings;
    final summary = NotificationSettingsService.getSettingsSummary();

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
        actions: [
          // 설정 초기화 버튼
          IconButton(
            onPressed: _showResetDialog,
            icon: const Icon(Icons.refresh),
            tooltip: '설정 초기화',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 전체 알림 활성화/비활성화
          _buildMainToggleCard(settings, summary),

          const SizedBox(height: 24),

          // 알림 설정 요약
          _buildSummaryCard(summary),

          const SizedBox(height: 24),

          // 루틴 관련 알림
          _buildSectionCard(
            title: '루틴 알림',
            icon: Icons.schedule,
            children: [
              _buildNotificationSwitch(
                title: '루틴 시작 알림',
                subtitle: '설정한 시간에 루틴 시작 알림',
                value: settings.routineStartNotification,
                onChanged: (value) => _updateSetting(
                  () => NotificationSettingsService.setRoutineStartNotification(
                      value),
                ),
              ),
              _buildNotificationSwitch(
                title: '루틴 완료 알림',
                subtitle: '루틴 완료 시 축하 메시지',
                value: settings.routineCompleteNotification,
                onChanged: (value) => _updateSetting(
                  () => NotificationSettingsService
                      .setRoutineCompleteNotification(value),
                ),
              ),
              _buildNotificationSwitch(
                title: '루틴 리마인더',
                subtitle: '루틴을 놓쳤을 때 알림',
                value: settings.routineReminderNotification,
                onChanged: (value) => _updateSetting(
                  () => NotificationSettingsService
                      .setRoutineReminderNotification(value),
                ),
              ),
              if (settings.routineReminderNotification) ...[
                const SizedBox(height: 8),
                _buildTimeSelector(
                  title: '리마인더 시간',
                  value: settings.routineReminderTime,
                  onChanged: (time) => _updateSetting(
                    () => NotificationSettingsService.setRoutineReminderTime(
                        time),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // 성취 관련 알림
          _buildSectionCard(
            title: '성취 알림',
            icon: Icons.emoji_events,
            children: [
              _buildNotificationSwitch(
                title: '연속 달성 알림',
                subtitle: '연속 달성 기록 갱신 시',
                value: settings.streakNotification,
                onChanged: (value) => _updateSetting(
                  () =>
                      NotificationSettingsService.setStreakNotification(value),
                ),
              ),
              _buildNotificationSwitch(
                title: '레벨업 알림',
                subtitle: '레벨 상승 시 축하 메시지',
                value: settings.levelUpNotification,
                onChanged: (value) => _updateSetting(
                  () =>
                      NotificationSettingsService.setLevelUpNotification(value),
                ),
              ),
              _buildNotificationSwitch(
                title: '목표 달성 알림',
                subtitle: '주간/월간 목표 달성 시',
                value: settings.goalAchievementNotification,
                onChanged: (value) => _updateSetting(
                  () => NotificationSettingsService
                      .setGoalAchievementNotification(value),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 리포트 관련 알림
          _buildSectionCard(
            title: '리포트 알림',
            icon: Icons.analytics,
            children: [
              _buildNotificationSwitch(
                title: '주간 리포트',
                subtitle: '주간 성과 요약 알림',
                value: settings.weeklyReportNotification,
                onChanged: (value) => _updateSetting(
                  () => NotificationSettingsService.setWeeklyReportNotification(
                      value),
                ),
              ),
              if (settings.weeklyReportNotification) ...[
                const SizedBox(height: 8),
                _buildTimeSelector(
                  title: '주간 리포트 시간',
                  value: settings.weeklyReportTime,
                  onChanged: (time) => _updateSetting(
                    () => NotificationSettingsService.setWeeklyReportTime(time),
                  ),
                ),
              ],
              _buildNotificationSwitch(
                title: '월간 리포트',
                subtitle: '월간 성과 요약 알림',
                value: settings.monthlyReportNotification,
                onChanged: (value) => _updateSetting(
                  () =>
                      NotificationSettingsService.setMonthlyReportNotification(
                          value),
                ),
              ),
              if (settings.monthlyReportNotification) ...[
                const SizedBox(height: 8),
                _buildTimeSelector(
                  title: '월간 리포트 시간',
                  value: settings.monthlyReportTime,
                  onChanged: (time) => _updateSetting(
                    () =>
                        NotificationSettingsService.setMonthlyReportTime(time),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // 동기부여 알림
          _buildSectionCard(
            title: '동기부여 알림',
            icon: Icons.favorite,
            children: [
              _buildNotificationSwitch(
                title: '동기부여 메시지',
                subtitle: '격려 및 동기부여 알림',
                value: settings.motivationNotification,
                onChanged: (value) => _updateSetting(
                  () => NotificationSettingsService.setMotivationNotification(
                      value),
                ),
              ),
              if (settings.motivationNotification) ...[
                const SizedBox(height: 8),
                _buildFrequencySelector(
                  title: '알림 빈도',
                  value: settings.motivationNotificationFrequency,
                  onChanged: (frequency) => _updateSetting(
                    () => NotificationSettingsService
                        .setMotivationNotificationFrequency(frequency),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 32),

          // 알림 테스트 카드
          _buildTestNotificationCard(),

          const SizedBox(height: 16),

          // 간단한 적용하기 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _applySettings,
              icon: const Icon(Icons.check),
              label: const Text('설정 적용'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6750A4),
                side: const BorderSide(color: Color(0xFF6750A4)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 메인 토글 카드 (전체 알림 활성화/비활성화)
  Widget _buildMainToggleCard(settings, summary) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: settings.isNotificationEnabled
                        ? const Color(0xFF6750A4).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: settings.isNotificationEnabled
                        ? const Color(0xFF6750A4)
                        : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '알림 활성화',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: settings.isNotificationEnabled
                              ? const Color(0xFF6750A4)
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${summary['activeCount']}/${summary['totalCount']}개 알림 활성화',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: settings.isNotificationEnabled,
                  onChanged: (value) => _toggleMainNotification(value),
                  activeColor: const Color(0xFF6750A4),
                ),
              ],
            ),
            if (settings.isNotificationEnabled) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: summary['activationRatio'],
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF6750A4)),
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              Text(
                '${(summary['activationRatio'] * 100).toInt()}% 알림 활성화',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 요약 카드
  Widget _buildSummaryCard(summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '알림 설정 요약',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    '활성 알림',
                    '${summary['activeCount']}개',
                    Icons.notifications_active,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    '리마인더 시간',
                    summary['routineReminderTime'],
                    Icons.schedule,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    '주간 리포트',
                    summary['weeklyReportTime'],
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    '동기부여 빈도',
                    '${summary['motivationFrequency']}일마다',
                    Icons.favorite,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 요약 아이템
  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 섹션 카드
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF6750A4)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  // 알림 스위치
  Widget _buildNotificationSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final settings = NotificationSettingsService.currentSettings;
    final isMainDisabled = !settings.isNotificationEnabled;

    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isMainDisabled ? Colors.grey[400] : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: isMainDisabled ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      value: value, // 실제 값 표시 (메인이 꺼져도 개별 설정값 유지)
      onChanged: isMainDisabled ? null : onChanged, // 메인이 비활성화되면 터치 불가
      activeColor: const Color(0xFF6750A4),
      contentPadding: EdgeInsets.zero,
    );
  }

  // 시간 선택기
  Widget _buildTimeSelector({
    required String title,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    final settings = NotificationSettingsService.currentSettings;
    final isMainDisabled = !settings.isNotificationEnabled;

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isMainDisabled ? Colors.grey[400] : null,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isMainDisabled ? Colors.grey[400] : const Color(0xFF6750A4),
        ),
      ),
      trailing: Icon(
        Icons.access_time,
        color: isMainDisabled ? Colors.grey[400] : null,
      ),
      onTap: isMainDisabled ? null : () => _showTimePicker(value, onChanged),
      contentPadding: EdgeInsets.zero,
    );
  }

  // 빈도 선택기
  Widget _buildFrequencySelector({
    required String title,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    final settings = NotificationSettingsService.currentSettings;
    final isMainDisabled = !settings.isNotificationEnabled;

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isMainDisabled ? Colors.grey[400] : null,
        ),
      ),
      subtitle: Text(
        '$value일마다',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isMainDisabled ? Colors.grey[400] : const Color(0xFF6750A4),
        ),
      ),
      trailing: Icon(
        Icons.tune,
        color: isMainDisabled ? Colors.grey[400] : null,
      ),
      onTap:
          isMainDisabled ? null : () => _showFrequencyPicker(value, onChanged),
      contentPadding: EdgeInsets.zero,
    );
  }

  // 알림 테스트 카드
  Widget _buildTestNotificationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '알림 테스트',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '실제 알림이 정상적으로 작동하는지 테스트해보세요.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: UnifiedNotificationService.hasPermission
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: UnifiedNotificationService.hasPermission
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    UnifiedNotificationService.hasPermission
                        ? Icons.check_circle
                        : Icons.warning,
                    size: 16,
                    color: UnifiedNotificationService.hasPermission
                        ? Colors.green
                        : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${UnifiedNotificationService.platformInfo} - ${UnifiedNotificationService.hasPermission ? "권한 허용됨" : "권한 필요"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: UnifiedNotificationService.hasPermission
                            ? Colors.green[700]
                            : Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testNotification,
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('테스트 알림'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6750A4),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showPendingNotifications,
                    icon: const Icon(Icons.schedule),
                    label: const Text('예약된 알림'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!UnifiedNotificationService.hasPermission) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _requestPermission,
                      icon: const Icon(Icons.notifications),
                      label: const Text('권한 요청'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _cancelAllNotifications,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('모든 알림 취소'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 설정 업데이트 (스케줄링은 적용하기 버튼에서만 실행)
  Future<void> _updateSetting(Future<void> Function() updateFunction) async {
    try {
      await updateFunction();
      // 화면 새로고침만 하고 스케줄링 업데이트는 적용하기 버튼에서 실행
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('설정 업데이트 오류: $e')),
        );
      }
    }
  }

  // 시간 선택기 표시
  Future<void> _showTimePicker(
      String currentTime, ValueChanged<String> onChanged) async {
    final timeParts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      final timeString =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      onChanged(timeString);
    }
  }

  // 빈도 선택기 표시
  Future<void> _showFrequencyPicker(
      int currentValue, ValueChanged<int> onChanged) async {
    final frequencies = [1, 2, 3, 5, 7, 10, 14, 21, 30];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림 빈도 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: frequencies.map((frequency) {
            return RadioListTile<int>(
              title: Text('$frequency일마다'),
              value: frequency,
              groupValue: currentValue,
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // 설정 초기화 다이얼로그
  Future<void> _showResetDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('설정 초기화'),
        content: const Text('모든 알림 설정을 기본값으로 초기화하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('초기화'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _updateSetting(() => NotificationSettingsService.resetToDefault());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정이 초기화되었습니다.')),
        );
      }
    }
  }

  // 테스트 알림 표시
  Future<void> _testNotification() async {
    // 메인 알림이 비활성화된 경우 테스트 알림도 차단
    final settings = NotificationSettingsService.currentSettings;
    if (!settings.isNotificationEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ 전체 알림이 비활성화되어 있습니다. 먼저 알림을 활성화해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await UnifiedNotificationService.showTestNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔔 테스트 알림을 표시했습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 테스트 알림 오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 예약된 알림 목록 표시
  Future<void> _showPendingNotifications() async {
    try {
      final pendingNotifications =
          await UnifiedNotificationService.getPendingNotifications();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('예약된 알림'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: pendingNotifications.length,
                itemBuilder: (context, index) {
                  final notification = pendingNotifications[index];
                  return ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(notification['title'] ?? '알림'),
                    subtitle: Text(notification['body'] ?? ''),
                    trailing: Text('ID: ${notification['id']}'),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 예약된 알림 조회 오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 모든 알림 취소
  Future<void> _cancelAllNotifications() async {
    try {
      await UnifiedNotificationService.cancelAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 모든 예약된 알림을 취소했습니다.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 알림 취소 오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 알림 권한 요청
  Future<void> _requestPermission() async {
    try {
      final granted =
          await UnifiedNotificationService.requestNotificationPermission();
      if (mounted) {
        setState(() {}); // 권한 상태 업데이트를 위해 화면 새로고침

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(granted ? '✅ 알림 권한이 허용되었습니다!' : '❌ 알림 권한이 거부되었습니다.'),
            backgroundColor: granted ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 권한 요청 오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 메인 알림 토글 (전체 알림 활성화/비활성화)
  Future<void> _toggleMainNotification(bool value) async {
    try {
      await NotificationSettingsService.setNotificationEnabled(value);

      // 메인 토글은 단순히 전체 알림 ON/OFF만 담당
      // 하위 설정값들은 변경하지 않고, UI만 비활성화/활성화 표시

      // 알림 스케줄링 업데이트는 적용하기 버튼을 눌렀을 때만 실행
      if (mounted) {
        setState(() {});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value ? '✅ 전체 알림이 활성화되었습니다.' : '❌ 전체 알림이 비활성화되었습니다.'),
            backgroundColor: value ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 알림 설정 오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 설정 적용하기 (간단한 버전)
  Future<void> _applySettings() async {
    try {
      // 웹에서는 간단하게 즉시 처리
      await UnifiedNotificationService.updateAllScheduledNotifications();

      // 성공 메시지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 알림 설정이 적용되었습니다!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // 2초 후 프로필 페이지로 돌아가기
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop(); // 알림 설정 페이지 닫기
          }
        });
      }
    } catch (e) {
      print('❌ 설정 적용 오류: $e');

      // 오류 메시지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 설정 적용 오류: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
