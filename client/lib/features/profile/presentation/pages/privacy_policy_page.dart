// 🔒 개인정보처리방침 페이지
// 개인정보 수집 및 이용에 관한 정책을 표시하는 화면
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인정보처리방침'),
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 정책 헤더
          _buildHeader(),
          const SizedBox(height: 24),

          // 정책 내용
          _buildPolicyContent(),
        ],
      ),
    );
  }

  // 정책 헤더
  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.privacy_tip,
              size: 48,
              color: Color(0xFF6750A4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Routine Quest 개인정보처리방침',
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

  // 정책 내용
  Widget _buildPolicyContent() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '제1조 (개인정보의 처리목적)',
              'Routine Quest는 다음의 목적을 위하여 개인정보를 처리합니다:\n\n1. 서비스 제공\n   - 루틴 관리 및 진행 상황 추적\n   - 사용자 맞춤형 알림 서비스 제공\n\n2. 서비스 개선\n   - 사용자 경험 향상을 위한 데이터 분석\n   - 서비스 품질 개선 및 신기능 개발',
            ),
            _buildSection(
              '제2조 (처리하는 개인정보의 항목)',
              'Routine Quest는 다음의 개인정보를 처리합니다:\n\n1. 필수항목\n   - 사용자 프로필 정보 (이름, 나이, 성별)\n   - 루틴 데이터 (생성한 루틴, 완료 기록)\n   - 진행 상황 데이터 (경험치, 레벨, 연속 일수)\n   - 앱 사용 통계 (앱스토어 요구사항)\n\n2. 선택항목\n   - 관심사 및 목표 설정\n   - 알림 설정 정보\n   - 사용자 피드백 (선택적 제공)\n\n3. 자동 수집 정보\n   - 앱 크래시 로그 (앱 안정성 개선용)\n   - 성능 데이터 (앱 최적화용)',
            ),
            _buildSection(
              '제3조 (개인정보의 처리 및 보유기간)',
              '1. 처리기간\n   - 서비스 이용기간 중\n   - 서비스 해지 시까지\n\n2. 보유기간\n   - 서비스 해지 후 30일간 (관련 법령에 의한 보존의무가 있는 경우 제외)\n   - 법령에 의해 보존의무가 있는 경우 해당 기간까지 보유',
            ),
            _buildSection(
              '제4조 (개인정보의 제3자 제공)',
              'Routine Quest는 원칙적으로 이용자의 개인정보를 외부에 제공하지 않습니다.\n\n단, 다음의 경우에는 예외로 합니다:\n1. 이용자가 사전에 동의한 경우\n2. 법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우\n3. 앱스토어 정책에 따른 앱 사용 통계 제공 (개인 식별 불가능한 형태)\n4. 앱 안정성 개선을 위한 크래시 로그 분석 (개인 식별 불가능한 형태)',
            ),
            _buildSection(
              '제5조 (개인정보의 안전성 확보조치)',
              'Routine Quest는 개인정보의 안전성 확보를 위해 다음과 같은 조치를 취하고 있습니다:\n\n1. 관리적 조치\n   - 개인정보보호를 위한 내부관리계획 수립\n   - 개인정보보호책임자 지정\n\n2. 기술적 조치\n   - 개인정보처리시스템 등의 접근권한 관리\n   - 접근통제시스템 설치 및 운영\n   - 개인정보의 암호화',
            ),
            _buildSection(
              '제6조 (개인정보 자동 수집 장치의 설치·운영 및 거부)',
              '1. 쿠키의 사용\n   - Routine Quest는 서비스 제공을 위해 쿠키를 사용할 수 있습니다.\n   - 쿠키는 웹사이트를 방문할 때 자동으로 생성되어 저장됩니다.\n\n2. 쿠키의 목적\n   - 사용자 설정 저장\n   - 서비스 이용 통계 분석\n\n3. 쿠키 거부 방법\n   - 브라우저 설정에서 쿠키를 차단할 수 있습니다.',
            ),
            _buildSection(
              '제7조 (개인정보보호책임자)',
              'Routine Quest는 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 이용자의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보보호책임자를 지정하고 있습니다:\n\n개인정보보호책임자\n- 성명: Routine Quest Team\n- 연락처: support@routinequest.app',
            ),
            _buildSection(
              '제8조 (권익침해 구제방법)',
              '개인정보주체는 개인정보침해신고센터, 개인정보 분쟁조정위원회 등에 분쟁해결이나 상담 등을 신청할 수 있습니다:\n\n1. 개인정보침해신고센터 (privacy.go.kr / 국번없이 182)\n2. 개인정보 분쟁조정위원회 (www.kopico.go.kr / 국번없이 1833-6972)\n3. 대검찰청 사이버범죄수사단 (www.spo.go.kr / 02-3480-3571)',
            ),
            _buildSection(
              '제9조 (개인정보처리방침의 변경)',
              '이 개인정보처리방침은 시행일로부터 적용되며, 법령 및 방침에 따른 변경내용의 추가, 삭제 및 정정이 있는 경우에는 변경사항의 시행 7일 전부터 공지사항을 통하여 고지할 것입니다.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '개인정보 보호를 위한 노력',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Routine Quest는 이용자의 개인정보를 소중히 여기며, 개인정보보호법에 따라 안전하게 관리하고 있습니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
