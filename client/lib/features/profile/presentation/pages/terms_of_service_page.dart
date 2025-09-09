// 📄 이용약관 페이지
// 서비스 이용에 관한 약관을 표시하는 화면
import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이용약관'),
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 약관 헤더
          _buildHeader(),
          const SizedBox(height: 24),

          // 약관 내용
          _buildTermsContent(),
        ],
      ),
    );
  }

  // 약관 헤더
  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.description,
              size: 48,
              color: Color(0xFF6750A4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Routine Quest 이용약관',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6750A4),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '시행일: 2025년 1월 2일',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 약관 내용
  Widget _buildTermsContent() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '제1조 (목적)',
              '이 약관은 Routine Quest 서비스(이하 "서비스")의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.',
            ),
            _buildSection(
              '제2조 (정의)',
              '1. "서비스"란 Routine Quest 앱을 통해 제공되는 루틴 관리 서비스를 의미합니다.\n2. "이용자"란 서비스에 접속하여 이 약관에 따라 서비스를 이용하는 회원을 의미합니다.',
            ),
            _buildSection(
              '제3조 (약관의 효력 및 변경)',
              '1. 이 약관은 서비스 화면에 게시하거나 기타의 방법으로 이용자에게 공지함으로써 효력이 발생합니다.\n2. 회사는 필요하다고 인정되는 경우 이 약관을 변경할 수 있으며, 변경된 약관은 서비스 화면에 공지함으로써 효력이 발생합니다.',
            ),
            _buildSection(
              '제4조 (서비스의 제공)',
              '1. 회사는 다음과 같은 서비스를 제공합니다:\n   - 루틴 생성 및 관리\n   - 루틴 진행 상황 추적\n   - 경험치 및 레벨 시스템\n   - 알림 서비스\n   - 달력 히스토리\n   - 프로필 관리\n2. 서비스는 연중무휴, 1일 24시간 제공함을 원칙으로 합니다.\n3. 현재 모든 기능이 무료로 제공됩니다.',
            ),
            _buildSection(
              '제5조 (이용자의 의무)',
              '1. 이용자는 다음 행위를 하여서는 안 됩니다:\n   - 서비스의 안정적 운영을 방해하는 행위\n   - 다른 이용자의 서비스 이용을 방해하는 행위\n   - 회사의 서비스에 해를 끼치는 행위\n2. 이용자는 이 약관 및 관련 법령을 준수해야 합니다.',
            ),
            _buildSection(
              '제6조 (개인정보보호)',
              '1. 회사는 이용자의 개인정보를 보호하기 위해 개인정보처리방침을 수립하여 시행합니다.\n2. 개인정보처리방침은 서비스 화면에 게시하여 이용자가 언제든지 확인할 수 있도록 합니다.',
            ),
            _buildSection(
              '제7조 (서비스의 중단)',
              '1. 회사는 컴퓨터 등 정보통신설비의 보수점검, 교체 및 고장, 통신의 두절 등의 사유가 발생한 경우에는 서비스의 제공을 일시적으로 중단할 수 있습니다.\n2. 회사는 서비스의 제공을 중단하는 경우에는 사전에 공지합니다.',
            ),
            _buildSection(
              '제8조 (면책조항)',
              '1. 회사는 천재지변 또는 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 서비스 제공에 관한 책임이 면제됩니다.\n2. 회사는 이용자의 귀책사유로 인한 서비스 이용의 장애에 대하여는 책임을 지지 않습니다.',
            ),
            _buildSection(
              '제9조 (준거법 및 관할법원)',
              '1. 이 약관은 대한민국 법률에 따라 규율되고 해석됩니다.\n2. 서비스 이용과 관련하여 회사와 이용자 간에 발생한 분쟁에 관한 소송은 민사소송법상의 관할법원에 제기합니다.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '이 약관에 동의하시면 서비스를 이용하실 수 있습니다.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6750A4),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 섹션 위젯
  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6750A4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
