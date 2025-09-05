// ➕ 새 루틴 생성 페이지
// 사용자가 새로운 루틴을 만들 수 있는 화면
import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';

class CreateRoutinePage extends StatefulWidget {
  const CreateRoutinePage({super.key});

  @override
  State<CreateRoutinePage> createState() => _CreateRoutinePageState();
}

class _CreateRoutinePageState extends State<CreateRoutinePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedIcon = '🎯';
  String _selectedColor = '#6750A4';
  bool _isPublic = false;
  bool _isLoading = false;

  // 아이콘 옵션들
  final List<String> _iconOptions = [
    '🎯',
    '🌅',
    '💪',
    '🌙',
    '📚',
    '🧘',
    '🏃',
    '🍎',
    '💧',
    '🎵',
    '✍️',
    '🧹',
    '🍳',
    '🚿',
    '🛏️',
    '☕'
  ];

  // 색상 옵션들
  final List<Map<String, String>> _colorOptions = [
    {'name': '보라', 'value': '#6750A4'},
    {'name': '초록', 'value': '#4CAF50'},
    {'name': '파랑', 'value': '#2196F3'},
    {'name': '주황', 'value': '#FF9800'},
    {'name': '빨강', 'value': '#F44336'},
    {'name': '핑크', 'value': '#E91E63'},
    {'name': '청록', 'value': '#00BCD4'},
    {'name': '갈색', 'value': '#795548'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 루틴 만들기'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveRoutine,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '저장',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 기본 정보 섹션
              _buildSectionTitle('기본 정보'),
              const SizedBox(height: 16),

              // 루틴 제목
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '루틴 제목',
                  hintText: '예: 아침 운동 루틴',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '루틴 제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 루틴 설명
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '루틴 설명 (선택사항)',
                  hintText: '이 루틴에 대한 간단한 설명을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // 아이콘 선택
              _buildSectionTitle('아이콘 선택'),
              const SizedBox(height: 16),
              _buildIconSelector(),
              const SizedBox(height: 24),

              // 색상 선택
              _buildSectionTitle('색상 선택'),
              const SizedBox(height: 16),
              _buildColorSelector(),
              const SizedBox(height: 24),

              // 공개 설정
              _buildSectionTitle('공개 설정'),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('공개 루틴'),
                subtitle: const Text('다른 사용자들이 이 루틴을 볼 수 있습니다'),
                value: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
                activeColor: const Color(0xFF6750A4),
              ),
              const SizedBox(height: 32),

              // 미리보기
              _buildSectionTitle('미리보기'),
              const SizedBox(height: 16),
              _buildPreviewCard(),
              const SizedBox(height: 32),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveRoutine,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('저장 중...'),
                          ],
                        )
                      : const Text(
                          '루틴 저장하기',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6750A4),
      ),
    );
  }

  Widget _buildIconSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 현재 선택된 아이콘
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(int.parse(_selectedColor.substring(1), radix: 16) +
                      0xFF000000)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _selectedIcon,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 아이콘 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _iconOptions.length,
            itemBuilder: (context, index) {
              final icon = _iconOptions[index];
              final isSelected = icon == _selectedIcon;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(int.parse(_selectedColor.substring(1),
                                    radix: 16) +
                                0xFF000000)
                            .withOpacity(0.2)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(
                            color: Color(int.parse(_selectedColor.substring(1),
                                    radix: 16) +
                                0xFF000000),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 현재 선택된 색상
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(int.parse(_selectedColor.substring(1), radix: 16) +
                  0xFF000000),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _selectedIcon,
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 색상 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _colorOptions.length,
            itemBuilder: (context, index) {
              final colorOption = _colorOptions[index];
              final color = Color(
                  int.parse(colorOption['value']!.substring(1), radix: 16) +
                      0xFF000000);
              final isSelected = colorOption['value'] == _selectedColor;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = colorOption['value']!;
                  });
                },
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 3)
                            : Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      colorOption['name']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(
                            int.parse(_selectedColor.substring(1), radix: 16) +
                                0xFF000000)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _selectedIcon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleController.text.isEmpty
                            ? '루틴 제목'
                            : _titleController.text,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_descriptionController.text.isNotEmpty)
                        Text(
                          _descriptionController.text,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_isPublic)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '공개',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '스텝을 추가하려면 루틴을 저장한 후 편집하세요.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final routineData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'icon': _selectedIcon,
        'color': _selectedColor,
        'is_public': _isPublic,
        'steps': [], // 스텝은 나중에 추가
      };

      await ApiClient.createRoutine(routineData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('루틴이 성공적으로 생성되었습니다! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // 성공적으로 생성됨을 알림
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('루틴 생성에 실패했습니다: $e'),
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
