// 📱 앱 정보 페이지
// 앱 버전, 이용약관, 개인정보처리방침을 표시하는 간단한 화면
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'terms_of_service_page.dart';
import 'privacy_policy_page.dart';

class AppInfoPage extends StatefulWidget {
  const AppInfoPage({super.key});

  @override
  State<AppInfoPage> createState() => _AppInfoPageState();
}

class _AppInfoPageState extends State<AppInfoPage> {
  PackageInfo? _packageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  // 앱 패키지 정보 로드
  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _packageInfo = packageInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('앱 정보'),
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 앱 기본 정보
                _buildAppHeader(),
                const SizedBox(height: 24),

                // 법적 문서
                _buildLegalDocuments(),
                const SizedBox(height: 24),

                // 앱 정보
                _buildAppDetails(),
              ],
            ),
    );
  }

  // 앱 헤더 (아이콘, 이름, 버전)
  Widget _buildAppHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 앱 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF6750A4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF6750A4),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.task_alt,
                size: 40,
                color: Color(0xFF6750A4),
              ),
            ),
            const SizedBox(height: 16),

            // 앱 이름
            const Text(
              'Routine Quest',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6750A4),
              ),
            ),
            const SizedBox(height: 8),

            // 앱 설명
            Text(
              '습관 형성을 위한 단계별 루틴 관리 앱',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            // 버전 정보
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6750A4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '버전 ${_packageInfo?.version ?? '1.0.0'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6750A4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 법적 문서 섹션
  Widget _buildLegalDocuments() {
    return Card(
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.description,
            title: '이용약관',
            subtitle: '서비스 이용에 관한 약관',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TermsOfServicePage(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.privacy_tip,
            title: '개인정보처리방침',
            subtitle: '개인정보 수집 및 이용에 관한 정책',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 앱 상세 정보 (간소화)
  Widget _buildAppDetails() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '앱 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6750A4),
              ),
            ),
          ),
          _buildInfoRow('앱 이름', 'Routine Quest'),
          _buildInfoRow('버전', _packageInfo?.version ?? '1.0.0'),
          _buildInfoRow('빌드 번호', _packageInfo?.buildNumber ?? '1'),
          _buildInfoRow('플랫폼', 'iOS, Android, Web'),
          _buildInfoRow('개발사', 'Routine Quest Inc.'),
          _buildInfoRow('카테고리', '생산성'),
          _buildInfoRow('연령 등급', '4+ (모든 연령)'),
          _buildInfoRow('언어', '한국어'),
          _buildInfoRow('최소 요구사항', 'iOS 12.0+ / Android 7.0+'),
        ],
      ),
    );
  }

  // 정보 행 위젯
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 메뉴 아이템 위젯
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6750A4)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
