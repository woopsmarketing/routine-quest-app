// ❓ 도움말 페이지
// FAQ, 사용법 가이드, 연락처 정보를 제공하는 화면
import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final List<FAQItem> _faqItems = [
    // 기본 사용법
    FAQItem(
      question: '루틴을 어떻게 만들 수 있나요?',
      answer:
          '메인 화면에서 "루틴 추가" 버튼을 눌러 새로운 루틴을 만들 수 있습니다. 각 루틴은 여러 단계로 구성할 수 있으며, 각 단계마다 소요 시간을 설정할 수 있습니다. 루틴 이름, 설명, 카테고리를 설정하고 단계별로 세부 내용을 추가하세요.',
    ),
    FAQItem(
      question: '루틴을 어떻게 실행하나요?',
      answer:
          '대시보드에서 시작하고 싶은 루틴을 선택하고 "시작하기" 버튼을 누르세요. 루틴은 단계별로 진행되며, 각 단계를 완료한 후 "다음 단계" 버튼을 눌러 진행하세요. 모든 단계를 완료하면 루틴이 완료됩니다.',
    ),
    FAQItem(
      question: '루틴을 중간에 멈출 수 있나요?',
      answer:
          '네, 루틴 실행 중 언제든지 "일시정지" 또는 "중단" 버튼을 눌러 멈출 수 있습니다. 일시정지한 루틴은 나중에 이어서 진행할 수 있고, 중단한 루틴은 처음부터 다시 시작해야 합니다.',
    ),

    // 경험치 및 레벨 시스템
    FAQItem(
      question: '루틴을 완료하면 어떤 혜택이 있나요?',
      answer:
          '루틴을 완료하면 경험치(EXP)를 획득할 수 있습니다. 경험치가 쌓이면 레벨이 올라가며, 연속 완료 일수도 기록됩니다. 레벨이 올라갈수록 새로운 칭호를 얻을 수 있고, 이를 통해 루틴 수행에 대한 동기부여를 받을 수 있습니다.',
    ),
    FAQItem(
      question: '레벨 시스템은 어떻게 작동하나요?',
      answer:
          '루틴을 완료할 때마다 경험치를 획득합니다. 경험치가 일정 수준에 도달하면 레벨이 올라갑니다. 레벨이 올라갈수록 더 많은 경험치가 필요하며, 새로운 칭호를 얻을 수 있습니다. 현재 레벨과 다음 레벨까지 필요한 경험치는 프로필 페이지에서 확인할 수 있습니다.',
    ),
    FAQItem(
      question: '경험치는 어떻게 계산되나요?',
      answer:
          '경험치는 루틴의 복잡도와 완료 시간에 따라 달라집니다. 기본적으로 루틴의 단계 수가 많을수록, 소요 시간이 길수록 더 많은 경험치를 획득할 수 있습니다. 연속으로 완료할 경우 보너스 경험치도 받을 수 있습니다.',
    ),

    // 알림 설정
    FAQItem(
      question: '알림을 어떻게 설정하나요?',
      answer:
          '프로필 페이지의 "알림 설정"에서 각 루틴별로 알림 시간을 설정할 수 있습니다. 오전/오후 알림을 개별적으로 설정할 수 있으며, 알림을 끄고 켤 수도 있습니다. 또한 알림 소리, 진동 등도 설정할 수 있습니다.',
    ),
    FAQItem(
      question: '알림이 오지 않아요. 어떻게 해결하나요?',
      answer:
          '브라우저의 알림 권한이 허용되어 있는지 확인해주세요. Chrome의 경우 주소창 옆의 자물쇠 아이콘을 클릭하여 알림을 허용할 수 있습니다. 또한 알림 설정에서 해당 루틴의 알림이 활성화되어 있는지 확인해주세요.',
    ),

    // 데이터 관리
    FAQItem(
      question: '데이터는 어디에 저장되나요?',
      answer:
          '앱 내 로컬 저장소에 데이터가 저장됩니다. iOS와 Android에서는 앱 전용 저장공간에, 웹에서는 브라우저의 로컬 스토리지에 저장됩니다. 향후 클라우드 동기화 기능을 통해 여러 기기에서 동일한 데이터를 사용할 수 있도록 개발 예정입니다.',
    ),
    FAQItem(
      question: '데이터를 백업할 수 있나요?',
      answer:
          '현재는 자동 백업 기능이 없습니다. iOS와 Android에서는 앱이 삭제되면 데이터가 함께 삭제되므로 주의해주세요. 향후 iCloud, Google Drive 연동을 통한 자동 백업 기능을 추가할 예정입니다.',
    ),
    FAQItem(
      question: '데이터를 삭제하고 싶어요.',
      answer:
          '프로필 페이지에서 "데이터 초기화" 옵션을 통해 모든 데이터를 삭제할 수 있습니다. 이 작업은 되돌릴 수 없으므로 신중하게 결정해주세요. 개별 루틴만 삭제하고 싶다면 루틴 관리 페이지에서 해당 루틴을 삭제할 수 있습니다.',
    ),

    // 히스토리 및 통계
    FAQItem(
      question: '루틴 히스토리는 어떻게 확인하나요?',
      answer:
          '대시보드의 달력에서 각 날짜별로 완료한 루틴을 확인할 수 있습니다. 파란색 점으로 표시된 날짜를 클릭하면 해당 날의 상세한 루틴 완료 기록을 볼 수 있습니다. 완료한 루틴의 소요 시간, 획득한 경험치 등도 확인할 수 있습니다.',
    ),
    FAQItem(
      question: '통계는 어떻게 확인하나요?',
      answer:
          '프로필 페이지의 "나의 통계" 섹션에서 총 루틴 수, 활동 일수, 연속 달성 일수, 총 경험치 등을 확인할 수 있습니다. "자세히 보기" 버튼을 누르면 더 상세한 통계를 볼 수 있습니다.',
    ),

    // 문제 해결
    FAQItem(
      question: '앱이 느리게 작동해요. 어떻게 해결하나요?',
      answer:
          '브라우저의 캐시를 삭제하거나 페이지를 새로고침해보세요. 또한 다른 탭이나 프로그램을 닫아서 메모리를 확보해보세요. 문제가 지속되면 개발자에게 문의해주세요.',
    ),
    FAQItem(
      question: '화면이 제대로 표시되지 않아요.',
      answer:
          '브라우저를 최신 버전으로 업데이트해보세요. 또한 브라우저의 확장 프로그램을 비활성화해보세요. 문제가 지속되면 다른 브라우저에서 시도해보시기 바랍니다.',
    ),
    FAQItem(
      question: '로그인이 안 돼요.',
      answer:
          '현재는 계정 시스템이 없으며, 모든 데이터는 앱 내 로컬에 저장됩니다. iOS와 Android에서는 앱이 정상적으로 설치되어 있으면 바로 사용할 수 있습니다. 향후 Apple ID, Google 계정 연동을 통한 로그인 기능을 추가할 예정입니다.',
    ),

    // 기타 기능
    FAQItem(
      question: '루틴을 공유할 수 있나요?',
      answer:
          '현재는 루틴 공유 기능이 없습니다. 향후 루틴을 다른 사용자와 공유하거나, 인기 루틴을 탐색할 수 있는 기능을 추가할 예정입니다.',
    ),
    FAQItem(
      question: '다크 모드를 사용할 수 있나요?',
      answer: '현재는 다크 모드 기능이 없습니다. 향후 다크 모드와 라이트 모드를 선택할 수 있는 기능을 추가할 예정입니다.',
    ),
    FAQItem(
      question: '모바일 앱은 언제 출시되나요?',
      answer:
          'iOS와 Android 앱이 현재 출시되었습니다! App Store와 Google Play Store에서 다운로드할 수 있습니다. 웹 버전과 동일한 기능을 제공하며, 향후 모바일 전용 기능들도 추가될 예정입니다.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('도움말'),
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 환영 메시지
          _buildWelcomeCard(),
          const SizedBox(height: 24),

          // 빠른 시작 가이드
          _buildQuickStartGuide(),
          const SizedBox(height: 24),

          // 사용법 가이드
          _buildUsageGuide(),
          const SizedBox(height: 24),

          // FAQ 섹션
          _buildFAQSection(),
          const SizedBox(height: 24),

          // 연락처 정보
          _buildContactInfo(),
          const SizedBox(height: 24),

          // 앱 업데이트 정보
          _buildUpdateInfo(),
        ],
      ),
    );
  }

  // 환영 메시지 카드
  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.help_outline,
              size: 48,
              color: Color(0xFF6750A4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Routine Quest에 오신 것을 환영합니다!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6750A4),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '습관 형성을 위한 단계별 루틴 관리 앱입니다.\n이 가이드를 통해 앱의 모든 기능을 활용하는 방법을 알아보세요.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 빠른 시작 가이드
  Widget _buildQuickStartGuide() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '🚀 빠른 시작 가이드',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6750A4),
              ),
            ),
          ),
          _buildGuideStep('1', '프로필 설정', '프로필 페이지에서 이름, 목표, 관심사를 설정하세요.'),
          _buildGuideStep('2', '루틴 만들기', '루틴 페이지에서 첫 번째 루틴을 만들어보세요.'),
          _buildGuideStep('3', '루틴 실행', '대시보드에서 루틴을 시작하고 단계별로 완료하세요.'),
          _buildGuideStep('4', '진행 확인', '달력에서 완료 기록을 확인하고 경험치를 획득하세요.'),
          _buildGuideStep('5', '알림 설정', '알림 설정에서 루틴 알림을 활성화하세요.'),
        ],
      ),
    );
  }

  // 사용법 가이드
  Widget _buildUsageGuide() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '📖 상세 사용법 가이드',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6750A4),
              ),
            ),
          ),
          _buildGuideItem(
            '루틴 생성하기',
            '루틴 페이지에서 "추가" 버튼을 눌러 새로운 루틴을 만드세요. 루틴 이름, 설명, 카테고리를 설정하고 단계별로 세부 내용을 추가할 수 있습니다.',
            Icons.add_circle_outline,
          ),
          _buildGuideItem(
            '루틴 실행하기',
            '대시보드에서 원하는 루틴을 선택하고 "시작하기" 버튼을 누르세요. 각 단계를 완료한 후 "다음 단계"를 눌러 진행하세요.',
            Icons.play_circle_outline,
          ),
          _buildGuideItem(
            '진행 상황 확인하기',
            '대시보드의 달력에서 완료한 루틴을 확인할 수 있습니다. 프로필 페이지에서 총 경험치와 레벨을 확인하세요.',
            Icons.analytics_outlined,
          ),
          _buildGuideItem(
            '알림 설정하기',
            '프로필 페이지의 "알림 설정"에서 각 루틴별로 알림 시간을 설정할 수 있습니다. 오전/오후 알림을 개별적으로 관리하세요.',
            Icons.notifications_outlined,
          ),
        ],
      ),
    );
  }

  // FAQ 섹션
  Widget _buildFAQSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '❓ 자주 묻는 질문',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6750A4),
              ),
            ),
          ),
          ..._faqItems.map((item) => _buildFAQItem(item)),
        ],
      ),
    );
  }

  // 연락처 정보
  Widget _buildContactInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📞 문의 및 지원',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6750A4),
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              Icons.email,
              '이메일',
              'support@routinequest.app',
              () => _showContactDialog('이메일'),
            ),
            _buildContactItem(
              Icons.bug_report,
              '버그 신고',
              '버그를 발견하셨나요?',
              () => _showContactDialog('버그 신고'),
            ),
            _buildContactItem(
              Icons.lightbulb,
              '기능 제안',
              '새로운 기능을 제안해주세요',
              () => _showContactDialog('기능 제안'),
            ),
            _buildContactItem(
              Icons.feedback,
              '피드백',
              '앱에 대한 의견을 들려주세요',
              () => _showContactDialog('피드백'),
            ),
          ],
        ),
      ),
    );
  }

  // 앱 업데이트 정보
  Widget _buildUpdateInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔄 앱 업데이트',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6750A4),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '현재 버전: 1.0.0',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '최신 업데이트: 2025년 1월 2일',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '지원 플랫폼: iOS 12.0+, Android 7.0+, Web',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('최신 버전을 사용 중입니다!')),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('업데이트 확인'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6750A4),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 가이드 단계 위젯
  Widget _buildGuideStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF6750A4),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6750A4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 가이드 아이템 위젯
  Widget _buildGuideItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF6750A4), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6750A4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FAQ 아이템 위젯
  Widget _buildFAQItem(FAQItem item) {
    return ExpansionTile(
      title: Text(
        item.question,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          child: Text(
            item.answer,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // 연락처 아이템 위젯
  Widget _buildContactItem(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6750A4)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // 연락처 다이얼로그 표시
  void _showContactDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$type 문의'),
        content: Text(
            '$type을 위한 문의 양식을 준비 중입니다.\n\n임시로 이메일로 문의해주세요:\nsupport@routinequest.app'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

// FAQ 아이템 데이터 클래스
class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}
