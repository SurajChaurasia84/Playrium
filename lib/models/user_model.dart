import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String avatarUrl;
  final int level;
  final int xp;
  final int coins;
  final String lastCheckInDate;
  final int streak;
  final bool profileCompleted;
  final bool hasProfilePhoto;
  final DateTime? lastUpdated;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.avatarUrl,
    this.level = 1,
    this.xp = 0,
    this.coins = 0,
    this.lastCheckInDate = '',
    this.streak = 0,
    this.profileCompleted = false,
    this.hasProfilePhoto = false,
    this.lastUpdated,
  });

  // Calculate XP required for next level: level * 100
  int get xpForNextLevel => level * 100;
  double get xpProgressRatio => xp / xpForNextLevel;

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? avatarUrl,
    int? level,
    int? xp,
    int? coins,
    String? lastCheckInDate,
    int? streak,
    bool? profileCompleted,
    bool? hasProfilePhoto,
    DateTime? lastUpdated,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
      streak: streak ?? this.streak,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      hasProfilePhoto: hasProfilePhoto ?? this.hasProfilePhoto,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'level': level,
      'xp': xp,
      'coins': coins,
      'lastCheckInDate': lastCheckInDate,
      'streak': streak,
      'profileCompleted': profileCompleted,
      'hasProfilePhoto': hasProfilePhoto,
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime? lastUpdatedTime;
    if (map['lastUpdated'] is Timestamp) {
      lastUpdatedTime = (map['lastUpdated'] as Timestamp).toDate();
    } else if (map['lastUpdated'] is String) {
      lastUpdatedTime = DateTime.tryParse(map['lastUpdated']);
    }

    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? 'Anonymous Gamer',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      level: map['level'] ?? 1,
      xp: map['xp'] ?? 0,
      coins: map['coins'] ?? 0,
      lastCheckInDate: map['lastCheckInDate'] ?? '',
      streak: map['streak'] ?? 0,
      profileCompleted: map['profileCompleted'] ?? false,
      hasProfilePhoto: map['hasProfilePhoto'] ?? false,
      lastUpdated: lastUpdatedTime,
    );
  }
}
