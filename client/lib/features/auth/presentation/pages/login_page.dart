// 🔐 로그인 페이지
// 사용자 인증을 위한 로그인 화면
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 로고
            const Icon(
              Icons.rocket_launch,
              size: 80,
              color: Color(0xFF6750A4),
            ),
            const SizedBox(height: 32),

            // 환영 메시지
            const Text(
              'Routine Quest에\n오신 것을 환영합니다!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            const Text(
              '루틴을 통해 작은 변화를 만들어보세요',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // 로그인 버튼들
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // 구글 로그인 (준비 중)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('구글 로그인 기능 준비 중')),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    '구글로 로그인',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // 애플 로그인 (준비 중)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('애플 로그인 기능 준비 중')),
                  );
                },
                icon: const Icon(Icons.apple),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    '애플로 로그인',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 게스트 로그인
            TextButton(
              onPressed: () {
                // 게스트로 시작
                context.go('/');
              },
              child: const Text(
                '게스트로 시작하기',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
