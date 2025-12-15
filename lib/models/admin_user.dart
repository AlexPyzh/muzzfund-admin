class AdminUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final DateTime created;
  final DateTime? verifiedAt;
  final bool isActive;
  final int totalPlays;
  final int totalInvestments;
  final int artistsCount;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.created,
    this.verifiedAt,
    this.isActive = true,
    this.totalPlays = 0,
    this.totalInvestments = 0,
    this.artistsCount = 0,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'User',
      created: json['created'] != null
          ? DateTime.parse(json['created'])
          : DateTime.now(),
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
      isActive: json['isActive'] ?? true,
      totalPlays: json['totalPlays'] ?? 0,
      totalInvestments: json['totalInvestments'] ?? 0,
      artistsCount: json['artistsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'created': created.toIso8601String(),
        'verifiedAt': verifiedAt?.toIso8601String(),
        'isActive': isActive,
        'totalPlays': totalPlays,
        'totalInvestments': totalInvestments,
        'artistsCount': artistsCount,
      };

  bool get isVerified => verifiedAt != null;
}

class UserActivity {
  final int id;
  final String action;
  final String details;
  final DateTime timestamp;

  UserActivity({
    required this.id,
    required this.action,
    required this.details,
    required this.timestamp,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      id: json['id'] ?? 0,
      action: json['action'] ?? '',
      details: json['details'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}

class UserInvestment {
  final int id;
  final int trackId;
  final String trackName;
  final String artistName;
  final double boughtPercent;
  final DateTime? investedAt;

  UserInvestment({
    required this.id,
    required this.trackId,
    required this.trackName,
    required this.artistName,
    required this.boughtPercent,
    this.investedAt,
  });

  factory UserInvestment.fromJson(Map<String, dynamic> json) {
    return UserInvestment(
      id: json['id'] ?? 0,
      trackId: json['trackId'] ?? 0,
      trackName: json['trackName'] ?? json['track']?['name'] ?? '',
      artistName: json['artistName'] ?? json['track']?['artist']?['name'] ?? '',
      boughtPercent: (json['boughtPercent'] ?? 0).toDouble(),
      investedAt: json['investedAt'] != null
          ? DateTime.parse(json['investedAt'])
          : null,
    );
  }
}

class ListeningHistoryItem {
  final int trackId;
  final String trackName;
  final String artistName;
  final DateTime playedAt;
  final int listenedSeconds;
  final bool completed;

  ListeningHistoryItem({
    required this.trackId,
    required this.trackName,
    required this.artistName,
    required this.playedAt,
    required this.listenedSeconds,
    required this.completed,
  });

  factory ListeningHistoryItem.fromJson(Map<String, dynamic> json) {
    return ListeningHistoryItem(
      trackId: json['trackId'] ?? 0,
      trackName: json['trackName'] ?? json['track']?['name'] ?? '',
      artistName: json['artistName'] ?? json['track']?['artist']?['name'] ?? '',
      playedAt: json['playedAt'] != null || json['startedAt'] != null
          ? DateTime.parse(json['playedAt'] ?? json['startedAt'])
          : DateTime.now(),
      listenedSeconds: json['listenedSeconds'] ?? json['listenedDurationSeconds'] ?? 0,
      completed: json['completed'] ?? json['completedPlay'] ?? false,
    );
  }
}
