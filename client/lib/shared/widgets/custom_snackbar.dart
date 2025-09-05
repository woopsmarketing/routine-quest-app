// 🎨 커스텀 스낵바 위젯
// 화면 중앙에 나타나는 정사각형 메시지 박스
import 'package:flutter/material.dart';

class CustomSnackbar {
  // 성공 메시지 (초록색)
  static void showSuccess(BuildContext context, String message) {
    _showCustomSnackbar(
      context,
      message,
      Colors.green,
      Icons.check_circle,
    );
  }

  // 정보 메시지 (파란색)
  static void showInfo(BuildContext context, String message) {
    _showCustomSnackbar(
      context,
      message,
      Colors.blue,
      Icons.info,
    );
  }

  // 경고 메시지 (주황색)
  static void showWarning(BuildContext context, String message) {
    _showCustomSnackbar(
      context,
      message,
      Colors.orange,
      Icons.warning,
    );
  }

  // 오류 메시지 (빨간색)
  static void showError(BuildContext context, String message) {
    _showCustomSnackbar(
      context,
      message,
      Colors.red,
      Icons.error,
    );
  }

  // 기본 커스텀 스낵바 표시
  static void _showCustomSnackbar(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _CustomSnackbarWidget(
        message: message,
        color: color,
        icon: icon,
        onDismiss: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
        },
      ),
    );

    overlay.insert(overlayEntry);
  }
}

// 커스텀 스낵바 위젯
class _CustomSnackbarWidget extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;
  final VoidCallback onDismiss;

  const _CustomSnackbarWidget({
    required this.message,
    required this.color,
    required this.icon,
    required this.onDismiss,
  });

  @override
  State<_CustomSnackbarWidget> createState() => _CustomSnackbarWidgetState();
}

class _CustomSnackbarWidgetState extends State<_CustomSnackbarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300), // 0.3초 애니메이션
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0, // 완전 불투명
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    // 등장 애니메이션
    _animationController.forward();

    // 2초 후 서서히 사라짐 (0.3초 페이드아웃)
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (mounted) {
      _animationController.reverse().then((_) {
        widget.onDismiss();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.45, // 화면 중앙
      left:
          MediaQuery.of(context).size.width * 0.5 - 75, // 중앙 정렬 (150px 너비의 절반)
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    width: 150, // 정사각형에 가까운 크기
                    height: 150,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20), // 둥근 모서리
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 48, // 큰 아이콘
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
