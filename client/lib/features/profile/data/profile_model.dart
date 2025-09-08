// 📊 프로필 데이터 모델
// 사용자 프로필 정보를 관리하는 데이터 클래스
class ProfileModel {
  final String name;
  final String email;
  final String emoji;
  final String bio;
  final String gender;
  final String age;
  final String goal;
  final List<String> interests;
  final String activityLevel;
  final String wakeUpTime;
  final String sleepTime;

  const ProfileModel({
    required this.name,
    required this.email,
    required this.emoji,
    required this.bio,
    required this.gender,
    required this.age,
    required this.goal,
    required this.interests,
    required this.activityLevel,
    required this.wakeUpTime,
    required this.sleepTime,
  });

  // 기본 프로필 데이터
  static const ProfileModel defaultProfile = ProfileModel(
    name: '김루틴',
    email: 'routine@example.com',
    emoji: '👨‍💻',
    bio: '루틴을 통해 더 나은 나를 만들어가고 있어요!',
    gender: '남성',
    age: '28',
    goal: '건강한 생활 습관 만들기',
    interests: ['운동', '독서'],
    activityLevel: '보통',
    wakeUpTime: '07:00',
    sleepTime: '23:00',
  );

  // 프로필 복사본 생성 (일부 필드만 업데이트)
  ProfileModel copyWith({
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
  }) {
    return ProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      emoji: emoji ?? this.emoji,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      goal: goal ?? this.goal,
      interests: interests ?? this.interests,
      activityLevel: activityLevel ?? this.activityLevel,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      sleepTime: sleepTime ?? this.sleepTime,
    );
  }

  // JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'emoji': emoji,
      'bio': bio,
      'gender': gender,
      'age': age,
      'goal': goal,
      'interests': interests,
      'activityLevel': activityLevel,
      'wakeUpTime': wakeUpTime,
      'sleepTime': sleepTime,
    };
  }

  // JSON에서 객체 생성
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emoji: json['emoji'] ?? '👨‍💻',
      bio: json['bio'] ?? '',
      gender: json['gender'] ?? '남성',
      age: json['age'] ?? '28',
      goal: json['goal'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      activityLevel: json['activityLevel'] ?? '보통',
      wakeUpTime: json['wakeUpTime'] ?? '07:00',
      sleepTime: json['sleepTime'] ?? '23:00',
    );
  }

  @override
  String toString() {
    return 'ProfileModel(name: $name, email: $email, emoji: $emoji, bio: $bio, gender: $gender, age: $age, goal: $goal, interests: $interests, activityLevel: $activityLevel, wakeUpTime: $wakeUpTime, sleepTime: $sleepTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileModel &&
        other.name == name &&
        other.email == email &&
        other.emoji == emoji &&
        other.bio == bio &&
        other.gender == gender &&
        other.age == age &&
        other.goal == goal &&
        other.interests.toString() == interests.toString() &&
        other.activityLevel == activityLevel &&
        other.wakeUpTime == wakeUpTime &&
        other.sleepTime == sleepTime;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        email.hashCode ^
        emoji.hashCode ^
        bio.hashCode ^
        gender.hashCode ^
        age.hashCode ^
        goal.hashCode ^
        interests.hashCode ^
        activityLevel.hashCode ^
        wakeUpTime.hashCode ^
        sleepTime.hashCode;
  }
}
