// 📝 스텝 모델
class Step {
  final String id;
  final String title;
  final String? description;
  final int? estimatedMinutes;
  final StepType type;
  final bool isCompleted;

  const Step({
    required this.id,
    required this.title,
    this.description,
    this.estimatedMinutes,
    required this.type,
    this.isCompleted = false,
  });

  Step copyWith({
    String? id,
    String? title,
    String? description,
    int? estimatedMinutes,
    StepType? type,
    bool? isCompleted,
  }) {
    return Step(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

enum StepType {
  action,
  mindfulness,
  exercise,
  learning,
  habit,
}

extension StepTypeExtension on StepType {
  String get emoji {
    switch (this) {
      case StepType.action:
        return '⚡';
      case StepType.mindfulness:
        return '🧘';
      case StepType.exercise:
        return '💪';
      case StepType.learning:
        return '📚';
      case StepType.habit:
        return '🔄';
    }
  }
}