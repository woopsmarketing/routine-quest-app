// 📋 루틴 상세 페이지
// 루틴의 스텝들을 보고 편집할 수 있는 화면
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/api/api_client.dart';
import '../../../../shared/widgets/custom_snackbar.dart';

class RoutineDetailPage extends StatefulWidget {
  final int routineId;
  final String routineTitle;

  const RoutineDetailPage({
    super.key,
    required this.routineId,
    required this.routineTitle,
  });

  @override
  State<RoutineDetailPage> createState() => _RoutineDetailPageState();
}

class _RoutineDetailPageState extends State<RoutineDetailPage> {
  Map<String, dynamic>? _routine;
  bool _isLoading = true;
  String? _error;

  // 자동 시작 설정
  bool _autoStartEnabled = false;
  TimeOfDay _autoStartTime = const TimeOfDay(hour: 9, minute: 0);
  final List<String> _weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  List<bool> _selectedWeekdays = [true, true, true, true, true, false, false];

  @override
  void initState() {
    super.initState();
    _loadRoutineDetail();
  }

  // 🔄 루틴 상세 정보 로드
  Future<void> _loadRoutineDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final routine = await ApiClient.getRoutine(widget.routineId);
      setState(() {
        _routine = routine;
        _isLoading = false;
      });

      // 자동 시작 설정 불러오기
      await _loadAutoStartSettings();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // 자동 시작 설정 불러오기
  Future<void> _loadAutoStartSettings() async {
    try {
      // 실제 API에서 자동 시작 설정 불러오기 (구현 예정)
      // final autoStartData = await ApiClient.getRoutineAutoStart(widget.routineId);

      // 임시로 SharedPreferences를 사용해서 로컬 저장소에서 불러오기
      final prefs = await SharedPreferences.getInstance();
      final settingsKey = 'auto_start_${widget.routineId}';
      final settingsJson = prefs.getString(settingsKey);

      if (settingsJson != null) {
        final settingsData = json.decode(settingsJson) as Map<String, dynamic>;

        setState(() {
          _autoStartEnabled = settingsData['enabled'] ?? false;

          // 시간 파싱
          if (settingsData['time'] != null) {
            final timeParts = settingsData['time'].toString().split(':');
            if (timeParts.length == 2) {
              _autoStartTime = TimeOfDay(
                hour: int.parse(timeParts[0]),
                minute: int.parse(timeParts[1]),
              );
            }
          }

          // 요일 파싱
          if (settingsData['weekdays'] != null) {
            final savedWeekdays = List<String>.from(settingsData['weekdays']);
            for (int i = 0; i < _weekdays.length; i++) {
              _selectedWeekdays[i] = savedWeekdays.contains(_weekdays[i]);
            }
          }
        });
      }
    } catch (e) {
      print('자동 시작 설정 불러오기 실패: $e');
      // 에러가 발생해도 기본값으로 계속 진행
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routineTitle),
        actions: [
          // 루틴 편집 버튼
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: 루틴 편집 화면으로 이동
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('루틴 편집 기능 준비 중')),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      // 🎯 하단 적용하기 버튼
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _applySettingsAndGoBack,
            icon: const Icon(Icons.check),
            label: const Text('적용하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('오류가 발생했습니다', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRoutineDetail,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_routine == null) {
      return const Center(child: Text('루틴을 찾을 수 없습니다'));
    }

    final steps = (_routine!['steps'] as List<dynamic>?) ?? [];

    return RefreshIndicator(
      onRefresh: _loadRoutineDetail,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 루틴 기본 정보 카드
            _buildRoutineInfoCard(),
            const SizedBox(height: 16),

            // 자동 시작 설정
            _buildAutoStartSettings(),
            const SizedBox(height: 24),

            // 스텝 섹션
            Row(
              children: [
                Text(
                  '스텝 목록',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${steps.length}개',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 스텝이 없는 경우
            if (steps.isEmpty)
              _buildEmptyStepsWidget()
            else
              // 스텝 목록
              ...steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildStepCard(step, index + 1),
                );
              }).toList(),

            // 🎯 스텝 추가 박스 (스텝 목록과 같은 크기)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildAddStepBox(),
            ),

            // 하단 여백
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // 루틴 기본 정보 카드
  Widget _buildRoutineInfoCard() {
    final routine = _routine!;

    // 🎨 색상 파싱 (안전하게 처리)
    Color color;
    try {
      final colorStr = routine['color']?.toString() ?? '#6366F1';
      final hexColor =
          colorStr.startsWith('#') ? colorStr.substring(1) : colorStr;
      color = Color(int.parse(hexColor, radix: 16) + 0xFF000000);
    } catch (e) {
      color = const Color(0xFF6366F1);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      routine['icon'] ?? '🎯',
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routine['title'] ?? '',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (routine['description'] != null &&
                          routine['description'].toString().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          routine['description'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 상태 정보
            Row(
              children: [
                _buildStatusChip(
                  routine['is_active'] == true ? '활성화' : '비활성화',
                  routine['is_active'] == true ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                if (routine['today_display'] == true)
                  _buildStatusChip('오늘 표시', Colors.blue),
                if (routine['is_public'] == true)
                  _buildStatusChip('공개', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 자동 시작 설정 위젯
  Widget _buildAutoStartSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text(
                  '자동 시작 설정',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 자동 시작 활성화 스위치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '자동 시작 활성화',
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: _autoStartEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _autoStartEnabled = value;
                    });
                    // 🔄 토글 변경 시 자동으로 저장
                    await _saveAutoStartSettingsAutomatically();
                  },
                  activeColor: Colors.orange,
                ),
              ],
            ),

            if (_autoStartEnabled) ...[
              const SizedBox(height: 16),
              // 시간 선택
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '시작 시간',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () => _selectAutoStartTime(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Text(
                        _formatTime(_autoStartTime),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 요일 선택
              const SizedBox(height: 16),
              const Text(
                '반복 요일',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _weekdays.asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  final isSelected = _selectedWeekdays[index];

                  return FilterChip(
                    label: Text(
                      day,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.orange[700] : Colors.grey[600],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedWeekdays[index] = selected;
                      });
                    },
                    selectedColor: Colors.orange.withOpacity(0.2),
                    backgroundColor: Colors.grey.withOpacity(0.1),
                    checkmarkColor: Colors.orange[700],
                  );
                }).toList(),
              ),

              // 알림 설명
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '설정한 시간에 알림이 오고 자동으로 루틴이 시작됩니다.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[700],
                        ),
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

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 스텝이 없을 때 위젯
  Widget _buildEmptyStepsWidget() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Icon(
              Icons.playlist_add,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '아직 스텝이 없습니다',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '+ 버튼을 눌러 첫 번째 스텝을 추가해보세요!',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddStepDialog(),
              icon: const Icon(Icons.add),
              label: const Text('첫 스텝 추가하기'),
            ),
          ],
        ),
      ),
    );
  }

  // 📦 스텝 추가 박스 (스텝 카드와 같은 크기)
  Widget _buildAddStepBox() {
    return Card(
      child: InkWell(
        onTap: () => _showAddStepDialog(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 80, // 스텝 카드와 비슷한 높이
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // + 아이콘
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.blue,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // 텍스트
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '스텝 추가',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '새로운 스텝을 추가해보세요',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // 화살표 아이콘
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 스텝 카드
  Widget _buildStepCard(Map<String, dynamic> step, int order) {
    final stepType = step['step_type']?.toString() ?? 'action';
    final difficulty = step['difficulty']?.toString() ?? 'easy';
    final timeInSeconds = step['t_ref_sec'] as int? ?? 120;
    final timeInMinutes = (timeInSeconds / 60).round();

    return Card(
      child: ListTile(
        onTap: () => _showEditStepDialog(step), // 스텝 클릭 시 수정 다이얼로그 열기
        leading: CircleAvatar(
          backgroundColor: _getStepTypeColor(stepType).withOpacity(0.1),
          child: Text(
            '$order',
            style: TextStyle(
              color: _getStepTypeColor(stepType),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(step['title'] ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (step['description'] != null &&
                step['description'].toString().isNotEmpty) ...[
              Text(step['description']),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                _buildStepBadge(
                    _getStepTypeLabel(stepType), _getStepTypeColor(stepType)),
                const SizedBox(width: 8),
                _buildStepBadge(_getDifficultyLabel(difficulty),
                    _getDifficultyColor(difficulty)),
                const SizedBox(width: 8),
                _buildStepBadge('${timeInMinutes}분', Colors.blue),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('수정'),
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
          onSelected: (value) => _handleStepAction(step, value.toString()),
        ),
      ),
    );
  }

  Widget _buildStepBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 스텝 타입별 색상
  Color _getStepTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'action':
        return Colors.green;
      case 'habit':
        return Colors.purple;
      case 'exercise':
        return Colors.orange;
      case 'mindfulness':
        return Colors.blue;
      case 'learning':
        return Colors.indigo;
      case 'hygiene':
        return Colors.teal;
      case 'nutrition':
        return Colors.brown;
      case 'social':
        return Colors.pink;
      case 'productivity':
        return Colors.deepOrange;
      case 'creativity':
        return Colors.deepPurple;
      case 'relaxation':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }

  // 스텝 타입별 라벨
  String _getStepTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'action':
        return '액션';
      case 'habit':
        return '습관';
      case 'exercise':
        return '운동';
      case 'mindfulness':
        return '명상';
      case 'learning':
        return '학습';
      case 'hygiene':
        return '위생';
      case 'nutrition':
        return '영양';
      case 'social':
        return '소셜';
      case 'productivity':
        return '생산성';
      case 'creativity':
        return '창의성';
      case 'relaxation':
        return '휴식';
      default:
        return '기타';
    }
  }

  // 난이도별 색상
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 난이도별 라벨
  String _getDifficultyLabel(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return '쉬움';
      case 'medium':
        return '보통';
      case 'hard':
        return '어려움';
      default:
        return '기타';
    }
  }

  // 스텝 액션 처리
  void _handleStepAction(Map<String, dynamic> step, String action) {
    switch (action) {
      case 'edit':
        _showEditStepDialog(step);
        break;
      case 'delete':
        _showDeleteStepDialog(step);
        break;
    }
  }

  // ⏰ 자동 시작 시간 선택
  Future<void> _selectAutoStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _autoStartTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: Colors.black87,
              dialHandColor: Colors.orange,
              dialBackgroundColor: Colors.orange.withOpacity(0.1),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _autoStartTime) {
      setState(() {
        _autoStartTime = picked;
      });
    }
  }

  // 시간 포맷팅
  String _formatTime(TimeOfDay time) {
    final hour =
        time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final period = time.hour < 12 ? '오전' : '오후';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$period $hour:$minute';
  }

  // 🎯 적용하기 버튼 - 설정 저장 후 루틴 페이지로 이동
  Future<void> _applySettingsAndGoBack() async {
    try {
      // 자동 시작 설정 저장
      await _saveAutoStartSettingsAutomatically();

      if (mounted) {
        // 성공 메시지 표시
        CustomSnackbar.showSuccess(context, '설정이 적용되었습니다! 🎉');

        // 잠시 대기 후 뒤로가기
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.of(context).pop(true); // true를 반환하여 새로고침 신호
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, '설정 적용에\n실패했습니다');
      }
    }
  }

  // 🔄 자동 시작 설정 자동 저장 (토글 변경 시)
  Future<void> _saveAutoStartSettingsAutomatically() async {
    try {
      // 선택된 요일들을 문자열로 변환
      final selectedDays = <String>[];
      for (int i = 0; i < _selectedWeekdays.length; i++) {
        if (_selectedWeekdays[i]) {
          selectedDays.add(_weekdays[i]);
        }
      }

      // 설정 데이터 준비
      final autoStartData = {
        'enabled': _autoStartEnabled,
        'time':
            '${_autoStartTime.hour.toString().padLeft(2, '0')}:${_autoStartTime.minute.toString().padLeft(2, '0')}',
        'weekdays': selectedDays,
      };

      // SharedPreferences에 자동 저장
      final prefs = await SharedPreferences.getInstance();
      final settingsKey = 'auto_start_${widget.routineId}';
      await prefs.setString(settingsKey, json.encode(autoStartData));

      if (mounted) {
        // 간단한 피드백 (토스트 메시지)
        if (_autoStartEnabled) {
          CustomSnackbar.showSuccess(context, '자동 시작\n활성화됨');
        } else {
          CustomSnackbar.showInfo(context, '자동 시작\n비활성화됨');
        }
      }
    } catch (e) {
      print('자동 시작 설정 저장 실패: $e');
      if (mounted) {
        CustomSnackbar.showError(context, '설정 저장에\n실패했습니다');
      }
    }
  }

  // 자동 시작 설정 저장 (기존 저장 버튼용)
  Future<void> _saveAutoStartSettings() async {
    try {
      // 선택된 요일들을 문자열로 변환
      final selectedDays = <String>[];
      for (int i = 0; i < _selectedWeekdays.length; i++) {
        if (_selectedWeekdays[i]) {
          selectedDays.add(_weekdays[i]);
        }
      }

      // 설정 데이터 준비
      final autoStartData = {
        'enabled': _autoStartEnabled,
        'time':
            '${_autoStartTime.hour.toString().padLeft(2, '0')}:${_autoStartTime.minute.toString().padLeft(2, '0')}',
        'weekdays': selectedDays,
      };

      // TODO: 실제 API 호출로 서버에 저장
      // await ApiClient.updateRoutineAutoStart(widget.routineId, autoStartData);

      // 임시로 SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      final settingsKey = 'auto_start_${widget.routineId}';
      await prefs.setString(settingsKey, json.encode(autoStartData));

      if (mounted) {
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  _autoStartEnabled
                      ? '자동 시작이 ${_formatTime(_autoStartTime)}에 설정되었습니다!'
                      : '자동 시작이 비활성화되었습니다.',
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('설정 저장 중 오류가 발생했습니다: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // 스텝 추가 다이얼로그
  void _showAddStepDialog() {
    showDialog(
      context: context,
      builder: (context) => AddStepDialog(
        routineId: widget.routineId,
        onStepAdded: () {
          _loadRoutineDetail(); // 새로고침
        },
      ),
    );
  }

  // 스텝 수정 다이얼로그
  void _showEditStepDialog(Map<String, dynamic> step) {
    showDialog(
      context: context,
      builder: (context) => EditStepDialog(
        step: step,
        routineId: widget.routineId,
        onStepUpdated: () {
          _loadRoutineDetail(); // 새로고침
        },
      ),
    );
  }

  // 스텝 삭제 확인 다이얼로그
  void _showDeleteStepDialog(Map<String, dynamic> step) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('스텝 삭제'),
        content: Text('${step['title']}을(를) 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                // 실제 API 호출
                await ApiClient.deleteStep(widget.routineId, step['id'] as int);
                _loadRoutineDetail(); // 새로고침
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${step['title']}이(가) 삭제되었습니다'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('삭제 실패: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

// 스텝 추가 다이얼로그
class AddStepDialog extends StatefulWidget {
  final int routineId;
  final VoidCallback onStepAdded;

  const AddStepDialog({
    super.key,
    required this.routineId,
    required this.onStepAdded,
  });

  @override
  State<AddStepDialog> createState() => _AddStepDialogState();
}

class _AddStepDialogState extends State<AddStepDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minutesController = TextEditingController();

  String _selectedType = 'action';
  String _selectedDifficulty = 'easy';
  int _estimatedMinutes = 2;
  bool _isOptional = false;
  bool _isLoading = false;

  final List<Map<String, String>> _stepTypes = [
    {'value': 'habit', 'label': '습관', 'description': '일상 습관 (양치질, 세수 등)'},
    {
      'value': 'exercise',
      'label': '운동',
      'description': '신체 활동 (달리기, 헬스, 요가 등)'
    },
    {
      'value': 'mindfulness',
      'label': '명상',
      'description': '마음챙김 활동 (명상, 호흡법 등)'
    },
    {
      'value': 'action',
      'label': '행동',
      'description': '일반적인 행동 (물 마시기, 정리하기 등)'
    },
    {'value': 'learning', 'label': '학습', 'description': '지식 습득 (독서, 강의 듣기 등)'},
    {'value': 'hygiene', 'label': '위생', 'description': '위생 관리 (샤워, 손씻기 등)'},
    {
      'value': 'nutrition',
      'label': '영양',
      'description': '식사 및 영양 관리 (아침식사, 간식 등)'
    },
    {
      'value': 'social',
      'label': '소셜',
      'description': '사회적 활동 (친구 만나기, 전화하기 등)'
    },
    {
      'value': 'productivity',
      'label': '생산성',
      'description': '업무 및 생산성 활동 (작업, 정리 등)'
    },
    {
      'value': 'creativity',
      'label': '창의성',
      'description': '창작 활동 (그림 그리기, 글쓰기 등)'
    },
    {
      'value': 'relaxation',
      'label': '휴식',
      'description': '휴식 및 휴양 활동 (낮잠, 산책 등)'
    },
  ];

  final List<Map<String, String>> _difficulties = [
    {'value': 'easy', 'label': '쉬움', 'description': '30초~2분'},
    {'value': 'medium', 'label': '보통', 'description': '2분~10분'},
    {'value': 'hard', 'label': '어려움', 'description': '10분 이상'},
  ];

  @override
  void initState() {
    super.initState();
    _minutesController.text = _estimatedMinutes.toString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새 스텝 추가'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 스텝 제목
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '스텝 제목',
                  hintText: '예: 물 한 잔 마시기',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '스텝 제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 스텝 설명
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '스텝 설명 (선택사항)',
                  hintText: '이 스텝에 대한 자세한 설명을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // 스텝 타입 선택
              const Text(
                '스텝 타입',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _stepTypes.map((type) {
                  final isSelected = _selectedType == type['value'];
                  return FilterChip(
                    label: Text(type['label']!),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedType = type['value']!;
                        });
                      }
                    },
                    selectedColor: Colors.blue.withOpacity(0.2),
                    checkmarkColor: Colors.blue[700],
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              // 선택된 타입 설명
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _stepTypes.firstWhere(
                      (type) => type['value'] == _selectedType)['description']!,
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16),

              // 난이도 선택
              DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                decoration: const InputDecoration(
                  labelText: '난이도',
                  border: OutlineInputBorder(),
                ),
                items: _difficulties.map((difficulty) {
                  return DropdownMenuItem(
                    value: difficulty['value'],
                    child: Text(difficulty['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value!;
                  });
                },
              ),
              const SizedBox(height: 8),
              // 선택된 난이도 설명
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _difficulties.firstWhere((difficulty) =>
                      difficulty['value'] ==
                      _selectedDifficulty)['description']!,
                  style: const TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 16),

              // 예상 소요 시간
              const Text(
                '예상 소요 시간',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Slider(
                      value: _estimatedMinutes.toDouble(),
                      min: 1,
                      max: 60,
                      divisions: 59,
                      label: '${_estimatedMinutes}분',
                      onChanged: (value) {
                        setState(() {
                          _estimatedMinutes = value.round();
                          _minutesController.text =
                              _estimatedMinutes.toString();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '분',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      controller: _minutesController,
                      onChanged: (value) {
                        final minutes = int.tryParse(value);
                        if (minutes != null && minutes >= 1 && minutes <= 60) {
                          setState(() {
                            _estimatedMinutes = minutes;
                          });
                        }
                      },
                      validator: (value) {
                        final minutes = int.tryParse(value ?? '');
                        if (minutes == null || minutes < 1 || minutes > 60) {
                          return '1-60분';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '슬라이더로 조정하거나 직접 숫자를 입력하세요 (1-60분)',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),

              // 선택적 스텝 여부
              SwitchListTile(
                title: const Text('선택적 스텝'),
                subtitle: const Text('건너뛸 수 있는 스텝으로 설정'),
                value: _isOptional,
                onChanged: (value) {
                  setState(() {
                    _isOptional = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addStep,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('추가'),
        ),
      ],
    );
  }

  Future<void> _addStep() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final stepData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'step_type': _selectedType,
        'difficulty': _selectedDifficulty,
        't_ref_sec': _estimatedMinutes * 60,
        'is_optional': _isOptional,
        'xp_reward': 10, // 기본 XP 보상
      };

      // 실제 API 호출
      await ApiClient.addStepToRoutine(widget.routineId, stepData);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onStepAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('스텝이 추가되었습니다! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('스텝 추가 실패: $e'),
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
}

// 스텝 수정 다이얼로그 (완전 구현)
class EditStepDialog extends StatefulWidget {
  final Map<String, dynamic> step;
  final int routineId;
  final VoidCallback onStepUpdated;

  const EditStepDialog({
    super.key,
    required this.step,
    required this.routineId,
    required this.onStepUpdated,
  });

  @override
  State<EditStepDialog> createState() => _EditStepDialogState();
}

class _EditStepDialogState extends State<EditStepDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _minutesController;
  late int _estimatedMinutes;
  late String _stepType;
  late bool _isOptional;
  bool _isLoading = false;

  // 스텝 타입 옵션
  final List<Map<String, dynamic>> _stepTypes = [
    {'value': 'habit', 'label': '습관', 'icon': Icons.repeat},
    {'value': 'exercise', 'label': '운동', 'icon': Icons.fitness_center},
    {'value': 'mindfulness', 'label': '명상', 'icon': Icons.self_improvement},
    {'value': 'action', 'label': '행동', 'icon': Icons.check_circle},
    {'value': 'learning', 'label': '학습', 'icon': Icons.school},
    {'value': 'hygiene', 'label': '위생', 'icon': Icons.clean_hands},
    {'value': 'nutrition', 'label': '영양', 'icon': Icons.restaurant},
    {'value': 'social', 'label': '소셜', 'icon': Icons.people},
    {'value': 'productivity', 'label': '생산성', 'icon': Icons.work},
    {'value': 'creativity', 'label': '창의성', 'icon': Icons.palette},
    {'value': 'relaxation', 'label': '휴식', 'icon': Icons.spa},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.step['title'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.step['description'] ?? '');
    _estimatedMinutes = (widget.step['t_ref_sec'] ?? 120) ~/ 60; // 초를 분으로 변환
    _minutesController =
        TextEditingController(text: _estimatedMinutes.toString());
    _stepType = widget.step['step_type'] ?? 'habit';
    _isOptional = widget.step['is_optional'] ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('스텝 수정'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 스텝 제목
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '스텝 제목',
                  hintText: '예: 물 한 잔 마시기',
                  border: OutlineInputBorder(),
                ),
                maxLength: 50,
              ),
              const SizedBox(height: 16),

              // 스텝 설명
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '스텝 설명 (선택사항)',
                  hintText: '스텝에 대한 자세한 설명을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 200,
              ),
              const SizedBox(height: 16),

              // 예상 소요 시간
              const Text(
                '예상 소요 시간',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Slider(
                      value: _estimatedMinutes.toDouble(),
                      min: 1,
                      max: 60,
                      divisions: 59,
                      label: '${_estimatedMinutes}분',
                      onChanged: (value) {
                        setState(() {
                          _estimatedMinutes = value.round();
                          _minutesController.text =
                              _estimatedMinutes.toString();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _minutesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '분',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (value) {
                        final minutes = int.tryParse(value);
                        if (minutes != null && minutes >= 1 && minutes <= 60) {
                          setState(() {
                            _estimatedMinutes = minutes;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '슬라이더로 조정하거나 직접 숫자를 입력하세요 (1-60분)',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              // 스텝 타입 선택
              const Text(
                '스텝 타입',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _stepTypes.map((type) {
                  final isSelected = _stepType == type['value'];
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(type['icon'], size: 16),
                        const SizedBox(width: 4),
                        Text(type['label']),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _stepType = type['value'];
                        });
                      }
                    },
                    selectedColor: Colors.blue.withOpacity(0.2),
                    checkmarkColor: Colors.blue[700],
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 선택적 스텝 여부
              SwitchListTile(
                title: const Text('선택적 스텝'),
                subtitle: const Text('건너뛸 수 있는 스텝으로 설정'),
                value: _isOptional,
                onChanged: (value) {
                  setState(() {
                    _isOptional = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveStep,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('저장'),
        ),
      ],
    );
  }

  // 스텝 저장
  Future<void> _saveStep() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('스텝 제목을 입력해주세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final stepData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        't_ref_sec': _estimatedMinutes * 60, // 분을 초로 변환
        'step_type': _stepType,
        'is_optional': _isOptional,
      };

      await ApiClient.updateStep(
        widget.routineId,
        widget.step['id'],
        stepData,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onStepUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('스텝이 성공적으로 수정되었습니다! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('스텝 수정에 실패했습니다: $e'),
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
}
