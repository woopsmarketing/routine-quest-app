// 👤 프로필 페이지
// 사용자 설정과 앱 정보를 관리하는 화면
import 'package:flutter/material.dart';

// 더미 사용자 데이터
class DummyUserData {
  static const String name = '김루틴';
  static const String email = 'routine@example.com';
  static const String avatar = '👨‍💻';
  static const int totalRoutines = 4;
  static const int completedToday = 3;
  static const int streakDays = 7;
  static const int totalCompleted = 45;
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 사용자 정보 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF6750A4),
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '사용자',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '루틴 퀘스트 사용자',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 통계 정보
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '나의 통계',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatItem('총 루틴', '3개'),
                  _buildStatItem('완료한 스텝', '12개'),
                  _buildStatItem('연속 달성', '5일'),
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
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('알림 설정 기능 준비 중')),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  icon: Icons.dark_mode,
                  title: '다크 모드',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('다크 모드 기능 준비 중')),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  icon: Icons.language,
                  title: '언어 설정',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('언어 설정 기능 준비 중')),
                    );
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('앱 정보 화면 준비 중')),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  icon: Icons.help,
                  title: '도움말',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('도움말 화면 준비 중')),
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

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6750A4),
            ),
          ),
        ],
      ),
    );
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
