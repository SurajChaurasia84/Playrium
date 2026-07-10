class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String iconKey; // Key to match to visual icon widgets
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int coinReward;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    this.isUnlocked = false,
    this.unlockedAt,
    this.coinReward = 10,
  });

  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? iconKey,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? coinReward,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconKey: iconKey ?? this.iconKey,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      coinReward: coinReward ?? this.coinReward,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconKey': iconKey,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'coinReward': coinReward,
    };
  }

  factory AchievementModel.fromMap(Map<String, dynamic> map) {
    return AchievementModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      iconKey: map['iconKey'] ?? '',
      isUnlocked: map['isUnlocked'] ?? false,
      unlockedAt: map['unlockedAt'] != null ? DateTime.tryParse(map['unlockedAt']) : null,
      coinReward: map['coinReward'] ?? 10,
    );
  }
}
