import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String avatarUrl;
  final int coins;
  final String lastCheckInDate;
  final int streak;
  final bool hasProfilePhoto;
  final DateTime? lastUpdated;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.avatarUrl,
    this.coins = 0,
    this.lastCheckInDate = '',
    this.streak = 0,
    this.hasProfilePhoto = false,
    this.lastUpdated,
  });

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? avatarUrl,
    int? coins,
    String? lastCheckInDate,
    int? streak,
    bool? hasProfilePhoto,
    DateTime? lastUpdated,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coins: coins ?? this.coins,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
      streak: streak ?? this.streak,
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
      'coins': coins,
      'lastCheckInDate': lastCheckInDate,
      'streak': streak,
      'hasProfilePhoto': hasProfilePhoto,
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toJsonMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'coins': coins,
      'lastCheckInDate': lastCheckInDate,
      'streak': streak,
      'hasProfilePhoto': hasProfilePhoto,
      'lastUpdated': (lastUpdated ?? DateTime.now()).toIso8601String(),
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
      coins: map['coins'] ?? 0,
      lastCheckInDate: map['lastCheckInDate'] ?? '',
      streak: map['streak'] ?? 0,
      hasProfilePhoto: map['hasProfilePhoto'] ?? false,
      lastUpdated: lastUpdatedTime,
    );
  }
}
