// 🔧 프로필 서비스
// 프로필 데이터를 관리하는 서비스 클래스
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/profile_model.dart';

class ProfileService {
  static const String _profileKey = 'user_profile';
  static ProfileModel _currentProfile = ProfileModel.defaultProfile;

  // 현재 프로필 가져오기
  static ProfileModel get currentProfile => _currentProfile;

  // 프로필 초기화 (앱 시작 시 호출)
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);

      if (profileJson != null) {
        final profileData = json.decode(profileJson);
        _currentProfile = ProfileModel.fromJson(profileData);
      } else {
        // 기본 프로필로 초기화
        _currentProfile = ProfileModel.defaultProfile;
        await saveProfile(_currentProfile);
      }
    } catch (e) {
      print('프로필 초기화 오류: $e');
      _currentProfile = ProfileModel.defaultProfile;
    }
  }

  // 프로필 저장
  static Future<bool> saveProfile(ProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = json.encode(profile.toJson());
      final success = await prefs.setString(_profileKey, profileJson);

      if (success) {
        _currentProfile = profile;
      }

      return success;
    } catch (e) {
      print('프로필 저장 오류: $e');
      return false;
    }
  }

  // 프로필 업데이트
  static Future<bool> updateProfile({
    String? name,
    String? email,
    String? emoji,
    String? bio,
    String? gender,
    String? age,
    String? goal,
    List<String>? interests,
    String? activityLevel,
    String? wakeUpTime,
    String? sleepTime,
  }) async {
    final updatedProfile = _currentProfile.copyWith(
      name: name,
      email: email,
      emoji: emoji,
      bio: bio,
      gender: gender,
      age: age,
      goal: goal,
      interests: interests,
      activityLevel: activityLevel,
      wakeUpTime: wakeUpTime,
      sleepTime: sleepTime,
    );

    return await saveProfile(updatedProfile);
  }

  // 프로필 삭제 (로그아웃 시)
  static Future<void> clearProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
      _currentProfile = ProfileModel.defaultProfile;
    } catch (e) {
      print('프로필 삭제 오류: $e');
    }
  }

  // 프로필 백업 (JSON 문자열로)
  static String exportProfile() {
    return json.encode(_currentProfile.toJson());
  }

  // 프로필 복원 (JSON 문자열에서)
  static Future<bool> importProfile(String profileJson) async {
    try {
      final profileData = json.decode(profileJson);
      final profile = ProfileModel.fromJson(profileData);
      return await saveProfile(profile);
    } catch (e) {
      print('프로필 복원 오류: $e');
      return false;
    }
  }
}
