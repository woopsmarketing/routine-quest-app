// ✏️ 프로필 수정 페이지
// 사용자 정보를 수정할 수 있는 화면
import 'package:flutter/material.dart';
import '../../services/profile_service.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  // 폼 키와 컨트롤러들
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _ageController;
  late final TextEditingController _goalController;
  late final TextEditingController _bioController;

  // 선택 가능한 옵션들
  String _selectedEmoji = '👨‍💻';
  String _selectedGender = '남성';
  String _selectedActivityLevel = '보통';
  String _selectedWakeUpTime = '07:00';
  String _selectedSleepTime = '23:00';
  List<String> _selectedInterests = ['운동', '독서'];

  final List<String> _emojiOptions = [
    '👨‍💻',
    '👩‍💻',
    '🧑‍💻',
    '👨‍🎨',
    '👩‍🎨',
    '🧑‍🎨',
    '👨‍🍳',
    '👩‍🍳',
    '🧑‍🍳',
    '👨‍🏫',
    '👩‍🏫',
    '🧑‍🏫',
    '👨‍⚕️',
    '👩‍⚕️',
    '🧑‍⚕️',
    '👨‍🚀',
    '👩‍🚀',
    '🧑‍🚀',
    '👨‍🎓',
    '👩‍🎓',
    '🧑‍🎓',
    '👨‍💼',
    '👩‍💼',
    '🧑‍💼',
    '😊',
    '😄',
    '🤔',
    '😎',
    '🥳',
    '🤗'
  ];
  final List<String> _genderOptions = ['남성', '여성', '기타'];
  final List<String> _activityLevels = ['낮음', '보통', '높음', '매우 높음'];
  final List<String> _wakeUpTimes = [
    '06:00',
    '06:30',
    '07:00',
    '07:30',
    '08:00',
    '08:30',
    '09:00'
  ];
  final List<String> _sleepTimes = [
    '22:00',
    '22:30',
    '23:00',
    '23:30',
    '00:00',
    '00:30',
    '01:00'
  ];
  final List<String> _interestOptions = [
    '운동',
    '독서',
    '요리',
    '음악',
    '영화',
    '게임',
    '여행',
    '사진',
    '그림',
    '코딩'
  ];

  @override
  void initState() {
    super.initState();
    // 현재 프로필 데이터로 컨트롤러 초기화
    final profile = ProfileService.currentProfile;
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _ageController = TextEditingController(text: profile.age);
    _goalController = TextEditingController(text: profile.goal);
    _bioController = TextEditingController(text: profile.bio);

    // 선택된 옵션들 초기화
    _selectedEmoji = profile.emoji;
    _selectedGender = profile.gender;
    _selectedActivityLevel = profile.activityLevel;
    _selectedWakeUpTime = profile.wakeUpTime;
    _selectedSleepTime = profile.sleepTime;
    _selectedInterests = List.from(profile.interests);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _goalController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
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
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 프로필 이미지 섹션
            _buildProfileImageSection(),
            const SizedBox(height: 24),

            // 기본 정보 섹션
            _buildSectionTitle('기본 정보'),
            _buildTextField(
              controller: _nameController,
              label: '이름',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이름을 입력해주세요';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _emailController,
              label: '이메일',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이메일을 입력해주세요';
                }
                if (!value.contains('@')) {
                  return '올바른 이메일 형식을 입력해주세요';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _ageController,
              label: '나이',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '나이를 입력해주세요';
                }
                final age = int.tryParse(value);
                if (age == null || age < 1 || age > 120) {
                  return '올바른 나이를 입력해주세요';
                }
                return null;
              },
            ),
            _buildDropdownField(
              label: '성별',
              icon: Icons.wc,
              value: _selectedGender,
              items: _genderOptions,
              onChanged: (value) => setState(() => _selectedGender = value!),
            ),

            const SizedBox(height: 24),

            // 루틴 목표 섹션
            _buildSectionTitle('루틴 목표'),
            _buildTextField(
              controller: _goalController,
              label: '주요 목표',
              icon: Icons.flag,
              hintText: '예: 건강한 생활 습관 만들기',
            ),
            _buildTextField(
              controller: _bioController,
              label: '자기소개',
              icon: Icons.description,
              maxLines: 3,
              hintText: '자신에 대해 간단히 소개해주세요',
            ),

            const SizedBox(height: 24),

            // 생활 패턴 섹션
            _buildSectionTitle('생활 패턴'),
            _buildDropdownField(
              label: '활동 수준',
              icon: Icons.fitness_center,
              value: _selectedActivityLevel,
              items: _activityLevels,
              onChanged: (value) =>
                  setState(() => _selectedActivityLevel = value!),
            ),
            _buildDropdownField(
              label: '기상 시간',
              icon: Icons.wb_sunny,
              value: _selectedWakeUpTime,
              items: _wakeUpTimes,
              onChanged: (value) =>
                  setState(() => _selectedWakeUpTime = value!),
            ),
            _buildDropdownField(
              label: '취침 시간',
              icon: Icons.bedtime,
              value: _selectedSleepTime,
              items: _sleepTimes,
              onChanged: (value) => setState(() => _selectedSleepTime = value!),
            ),

            const SizedBox(height: 24),

            // 관심사 섹션
            _buildSectionTitle('관심사'),
            _buildInterestChips(),

            const SizedBox(height: 32),

            // 저장 버튼
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6750A4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '프로필 저장',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // 프로필 이모지 섹션
  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
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
                _selectedEmoji,
                style: const TextStyle(fontSize: 50),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '프로필 이모지 선택',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6750A4),
            ),
          ),
          const SizedBox(height: 12),
          _buildEmojiSelector(),
        ],
      ),
    );
  }

  // 이모지 선택기
  Widget _buildEmojiSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _emojiOptions.map((emoji) {
          final isSelected = _selectedEmoji == emoji;
          return GestureDetector(
            onTap: () => setState(() => _selectedEmoji = emoji),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6750A4).withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFF6750A4) : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 섹션 제목
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6750A4),
        ),
      ),
    );
  }

  // 텍스트 필드
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: const Color(0xFF6750A4)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6750A4), width: 2),
          ),
        ),
      ),
    );
  }

  // 드롭다운 필드
  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF6750A4)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6750A4), width: 2),
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // 관심사 칩
  Widget _buildInterestChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _interestOptions.map((interest) {
        final isSelected = _selectedInterests.contains(interest);
        return FilterChip(
          label: Text(interest),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedInterests.add(interest);
              } else {
                _selectedInterests.remove(interest);
              }
            });
          },
          selectedColor: const Color(0xFF6750A4).withOpacity(0.2),
          checkmarkColor: const Color(0xFF6750A4),
          side: BorderSide(
            color: isSelected ? const Color(0xFF6750A4) : Colors.grey,
          ),
        );
      }).toList(),
    );
  }

  // 프로필 저장
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        // 프로필 데이터 업데이트
        final success = await ProfileService.updateProfile(
          name: _nameController.text,
          email: _emailController.text,
          emoji: _selectedEmoji,
          bio: _bioController.text,
          gender: _selectedGender,
          age: _ageController.text,
          goal: _goalController.text,
          interests: _selectedInterests,
          activityLevel: _selectedActivityLevel,
          wakeUpTime: _selectedWakeUpTime,
          sleepTime: _selectedSleepTime,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('프로필이 저장되었습니다!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // 성공적으로 저장됨을 알림
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('프로필 저장에 실패했습니다. 다시 시도해주세요.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
