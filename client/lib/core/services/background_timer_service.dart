// ⏰ 백그라운드 타이머 서비스
// 앱이 백그라운드에 있어도 시간이 흐르는 타이머를 관리하는 서비스
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';

class BackgroundTimerService {
  static final BackgroundTimerService _instance =
      BackgroundTimerService._internal();
  factory BackgroundTimerService() => _instance;
  BackgroundTimerService._internal();

  Timer? _backgroundTimer;
  DateTime? _timerStartTime;
  bool _isRunning = false;
  int _currentElapsedSeconds = 0;
  int _targetSeconds = 0;
  String? _currentRoutineId;
  int _currentStepIndex = 0;
  String? _currentStepTitle;

  // 알림 플러그인
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _notificationsInitialized = false;

  // 타이머 상태 저장 키
  static const String _timerStateKey = 'background_timer_state';
  static const String _timerStartTimeKey = 'timer_start_time';

  // 알림 초기화
  Future<void> initializeNotifications() async {
    if (_notificationsInitialized) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(initSettings);
      _notificationsInitialized = true;
      print('🔔 백그라운드 타이머 알림 초기화 완료');
    } catch (e) {
      print('🔔 알림 초기화 실패: $e');
    }
  }

  // 타이머 시작
  Future<void> startTimer({
    required String routineId,
    required int stepIndex,
    required int targetSeconds,
    String? stepTitle,
  }) async {
    print('⏰ 백그라운드 타이머 시작: $routineId, 스텝 $stepIndex, 목표 ${targetSeconds}초');

    // 알림 초기화
    await initializeNotifications();

    _currentRoutineId = routineId;
    _currentStepIndex = stepIndex;
    _targetSeconds = targetSeconds;
    _currentStepTitle = stepTitle;
    _timerStartTime = DateTime.now();
    _currentElapsedSeconds = 0;
    _isRunning = true;

    // 상태를 로컬 저장소에 저장
    await _saveTimerState();

    // 백그라운드 타이머 시작
    _startBackgroundTimer();
  }

  // 백그라운드 타이머 시작
  void _startBackgroundTimer() {
    _backgroundTimer?.cancel();

    _backgroundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }

      _currentElapsedSeconds++;

      // 상태 저장 (1초마다)
      _saveTimerState();

      // 목표 시간 도달 시 알림
      if (_currentElapsedSeconds >= _targetSeconds) {
        _onTimerComplete();
      }

      print('⏰ 백그라운드 타이머: ${_currentElapsedSeconds}/${_targetSeconds}초');
    });
  }

  // 타이머 정지
  Future<void> pauseTimer() async {
    print('⏸️ 백그라운드 타이머 정지');
    _isRunning = false;
    _backgroundTimer?.cancel();
    await _saveTimerState();
  }

  // 타이머 재시작
  Future<void> resumeTimer() async {
    print('▶️ 백그라운드 타이머 재시작');
    _isRunning = true;
    _startBackgroundTimer();
  }

  // 타이머 완료 처리
  void _onTimerComplete() {
    print('🎉 백그라운드 타이머 완료!');
    _isRunning = false;
    _backgroundTimer?.cancel();

    // 완료 알림 표시
    _showCompletionNotification();

    // 상태 초기화
    _clearTimerState();
  }

  // 완료 알림 표시
  Future<void> _showCompletionNotification() async {
    if (!_notificationsInitialized) return;

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'routine_timer',
        '루틴 타이머',
        channelDescription: '루틴 스텝 타이머 완료 알림',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final stepTitle = _currentStepTitle ?? '스텝';
      final routineName = _currentRoutineId ?? '루틴';

      await _notifications.show(
        1001, // 타이머 완료 알림 ID
        '🎉 $stepTitle 완료!',
        '$routineName의 $stepTitle이 완료되었습니다.',
        details,
      );

      print('🔔 타이머 완료 알림 표시: $stepTitle');
    } catch (e) {
      print('🔔 알림 표시 실패: $e');
    }
  }

  // 타이머 상태 저장
  Future<void> _saveTimerState() async {
    if (!kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            _timerStateKey,
            jsonEncode({
              'isRunning': _isRunning,
              'currentElapsedSeconds': _currentElapsedSeconds,
              'targetSeconds': _targetSeconds,
              'routineId': _currentRoutineId,
              'stepIndex': _currentStepIndex,
            }));

        if (_timerStartTime != null) {
          await prefs.setString(
              _timerStartTimeKey, _timerStartTime!.toIso8601String());
        }
      } catch (e) {
        print('타이머 상태 저장 실패: $e');
      }
    }
  }

  // 타이머 상태 복원
  Future<void> restoreTimerState() async {
    if (kIsWeb) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString(_timerStateKey);

      if (stateJson != null) {
        final state = jsonDecode(stateJson);
        _isRunning = state['isRunning'] ?? false;
        _currentElapsedSeconds = state['currentElapsedSeconds'] ?? 0;
        _targetSeconds = state['targetSeconds'] ?? 0;
        _currentRoutineId = state['routineId'];
        _currentStepIndex = state['stepIndex'] ?? 0;

        final startTimeStr = prefs.getString(_timerStartTimeKey);
        if (startTimeStr != null) {
          _timerStartTime = DateTime.parse(startTimeStr);
        }

        // 타이머가 실행 중이었다면 재시작
        if (_isRunning && _currentElapsedSeconds < _targetSeconds) {
          _startBackgroundTimer();
        }

        print('🔄 타이머 상태 복원: ${_currentElapsedSeconds}/${_targetSeconds}초');
      }
    } catch (e) {
      print('타이머 상태 복원 실패: $e');
    }
  }

  // 타이머 상태 초기화
  Future<void> _clearTimerState() async {
    if (!kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_timerStateKey);
        await prefs.remove(_timerStartTimeKey);
      } catch (e) {
        print('타이머 상태 초기화 실패: $e');
      }
    }

    _isRunning = false;
    _currentElapsedSeconds = 0;
    _targetSeconds = 0;
    _currentRoutineId = null;
    _currentStepIndex = 0;
    _timerStartTime = null;
    _backgroundTimer?.cancel();
  }

  // 현재 경과 시간 가져오기
  int get currentElapsedSeconds => _currentElapsedSeconds;

  // 목표 시간 가져오기
  int get targetSeconds => _targetSeconds;

  // 타이머 실행 상태
  bool get isRunning => _isRunning;

  // 현재 루틴 ID
  String? get currentRoutineId => _currentRoutineId;

  // 현재 스텝 인덱스
  int get currentStepIndex => _currentStepIndex;

  // 남은 시간 계산
  int get remainingSeconds =>
      (_targetSeconds - _currentElapsedSeconds).clamp(0, _targetSeconds);

  // 진행률 계산 (0.0 ~ 1.0)
  double get progress => _targetSeconds > 0
      ? (_currentElapsedSeconds / _targetSeconds).clamp(0.0, 1.0)
      : 0.0;

  // 정리
  void dispose() {
    _backgroundTimer?.cancel();
  }
}
