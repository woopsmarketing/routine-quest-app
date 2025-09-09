// 📱 앱 생명주기 관리 서비스
// 포그라운드/백그라운드 상태를 감지하고 타이머 상태를 관리하는 서비스
import 'package:flutter/material.dart';
import 'dart:async';

class AppLifecycleService extends WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  Timer? _backgroundTimer;
  DateTime? _backgroundStartTime;
  bool _isInBackground = false;

  // 초기화
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  // 정리
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundTimer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.inactive:
        // 앱이 비활성화됨 (전화 수신 등)
        break;
      case AppLifecycleState.detached:
        // 앱이 완전히 종료됨
        _onAppDetached();
        break;
      case AppLifecycleState.hidden:
        // 앱이 숨겨짐
        _onAppPaused();
        break;
    }
  }

  // 앱이 포그라운드로 돌아옴
  void _onAppResumed() {
    print('🔄 앱이 포그라운드로 돌아옴');
    _isInBackground = false;
    _backgroundTimer?.cancel();

    // 백그라운드에서 경과한 시간을 타이머에 반영
    _updateTimerAfterBackground();
  }

  // 앱이 백그라운드로 감
  void _onAppPaused() {
    print('⏸️ 앱이 백그라운드로 감');
    _isInBackground = true;
    _backgroundStartTime = DateTime.now();

    // 백그라운드 타이머 시작
    _startBackgroundTimer();
  }

  // 앱이 완전히 종료됨
  void _onAppDetached() {
    print('🔚 앱이 완전히 종료됨');
    _backgroundTimer?.cancel();
  }

  // 백그라운드 타이머 시작
  void _startBackgroundTimer() {
    _backgroundTimer?.cancel();

    _backgroundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // 백그라운드에서도 타이머 상태 업데이트
      _updateBackgroundTimer();
    });
  }

  // 백그라운드에서 타이머 업데이트
  void _updateBackgroundTimer() {
    // Provider를 직접 사용할 수 없으므로, 이벤트 스트림을 통해 알림
    // 실제 구현에서는 ProviderContainer를 사용하거나 다른 방법 필요
    print('⏰ 백그라운드 타이머 업데이트');
  }

  // 포그라운드 복귀 후 타이머 업데이트
  void _updateTimerAfterBackground() {
    if (_backgroundStartTime == null) return;

    final backgroundDuration = DateTime.now().difference(_backgroundStartTime!);
    final backgroundSeconds = backgroundDuration.inSeconds;

    print('⏱️ 백그라운드에서 경과한 시간: ${backgroundSeconds}초');

    // TODO: Provider를 통해 타이머 상태 업데이트
    // ref.read(routineProgressProvider.notifier).addBackgroundTime(backgroundSeconds);
  }

  // 현재 백그라운드 상태 확인
  bool get isInBackground => _isInBackground;
}
