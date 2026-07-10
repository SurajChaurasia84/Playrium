class GameModel {
  final String id;
  final String name;
  final String description;
  final String iconPath; // SVG / Image Asset or Icon key
  final int highScore;
  final int coinsEarnedToday;
  final DateTime? lastPlayed;
  final List<String> gradientHex;

  GameModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    this.highScore = 0,
    this.coinsEarnedToday = 0,
    this.lastPlayed,
    this.gradientHex = const ['#6C5CE7', '#00D1FF'],
  });

  GameModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconPath,
    int? highScore,
    int? coinsEarnedToday,
    DateTime? lastPlayed,
    List<String>? gradientHex,
  }) {
    return GameModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      highScore: highScore ?? this.highScore,
      coinsEarnedToday: coinsEarnedToday ?? this.coinsEarnedToday,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      gradientHex: gradientHex ?? this.gradientHex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'highScore': highScore,
      'coinsEarnedToday': coinsEarnedToday,
      'lastPlayed': lastPlayed?.toIso8601String(),
      'gradientHex': gradientHex,
    };
  }

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconPath: map['iconPath'] ?? '',
      highScore: map['highScore'] ?? 0,
      coinsEarnedToday: map['coinsEarnedToday'] ?? 0,
      lastPlayed: map['lastPlayed'] != null ? DateTime.tryParse(map['lastPlayed']) : null,
      gradientHex: List<String>.from(map['gradientHex'] ?? ['#6C5CE7', '#00D1FF']),
    );
  }
}
