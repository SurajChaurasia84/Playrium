class TaskModel {
  final String id;
  final String title;
  final String description;
  final int rewardCoins;
  final String type; // daily, streak, profile, quiz, game, social
  final bool isCompleted;
  final bool isClaimed;
  final int progress;
  final int maxProgress;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardCoins,
    required this.type,
    this.isCompleted = false,
    this.isClaimed = false,
    this.progress = 0,
    this.maxProgress = 1,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    int? rewardCoins,
    String? type,
    bool? isCompleted,
    bool? isClaimed,
    int? progress,
    int? maxProgress,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
      progress: progress ?? this.progress,
      maxProgress: maxProgress ?? this.maxProgress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'rewardCoins': rewardCoins,
      'type': type,
      'isCompleted': isCompleted,
      'isClaimed': isClaimed,
      'progress': progress,
      'maxProgress': maxProgress,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      rewardCoins: map['rewardCoins'] ?? 0,
      type: map['type'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      isClaimed: map['isClaimed'] ?? false,
      progress: map['progress'] ?? 0,
      maxProgress: map['maxProgress'] ?? 1,
    );
  }
}
