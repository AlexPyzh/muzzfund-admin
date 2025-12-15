class DashboardStatistics {
  final int totalUsers;
  final int activeUsers;
  final int totalTracks;
  final int pendingTracks;
  final int totalPlays;
  final int playsToday;
  final int playsThisWeek;
  final double totalInvestments;
  final int newUsersToday;
  final int newUsersThisWeek;

  DashboardStatistics({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.totalTracks = 0,
    this.pendingTracks = 0,
    this.totalPlays = 0,
    this.playsToday = 0,
    this.playsThisWeek = 0,
    this.totalInvestments = 0,
    this.newUsersToday = 0,
    this.newUsersThisWeek = 0,
  });

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) {
    return DashboardStatistics(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      totalTracks: json['totalTracks'] ?? 0,
      pendingTracks: json['pendingTracks'] ?? 0,
      totalPlays: json['totalPlays'] ?? 0,
      playsToday: json['playsToday'] ?? 0,
      playsThisWeek: json['playsThisWeek'] ?? 0,
      totalInvestments: (json['totalInvestments'] ?? 0).toDouble(),
      newUsersToday: json['newUsersToday'] ?? 0,
      newUsersThisWeek: json['newUsersThisWeek'] ?? 0,
    );
  }
}

class TopTrackStats {
  final int trackId;
  final String trackName;
  final String artistName;
  final String? imageUrl;
  final int totalPlays;
  final int uniqueListeners;
  final int completedPlays;
  final double averageListenPercent;
  final int playsLast24Hours;
  final int playsLast7Days;

  TopTrackStats({
    required this.trackId,
    required this.trackName,
    required this.artistName,
    this.imageUrl,
    this.totalPlays = 0,
    this.uniqueListeners = 0,
    this.completedPlays = 0,
    this.averageListenPercent = 0,
    this.playsLast24Hours = 0,
    this.playsLast7Days = 0,
  });

  factory TopTrackStats.fromJson(Map<String, dynamic> json) {
    return TopTrackStats(
      trackId: json['trackId'] ?? 0,
      trackName: json['trackName'] ?? json['track']?['name'] ?? '',
      artistName: json['artistName'] ?? json['track']?['artist']?['name'] ?? '',
      imageUrl: json['imageUrl'] ?? json['track']?['imageUrl'],
      totalPlays: json['totalPlays'] ?? 0,
      uniqueListeners: json['uniqueListeners'] ?? 0,
      completedPlays: json['completedPlays'] ?? 0,
      averageListenPercent: (json['averageListenPercent'] ?? 0).toDouble(),
      playsLast24Hours: json['playsLast24Hours'] ?? 0,
      playsLast7Days: json['playsLast7Days'] ?? 0,
    );
  }
}

class UserEngagement {
  final int totalActiveUsers;
  final int dailyActiveUsers;
  final int weeklyActiveUsers;
  final int monthlyActiveUsers;
  final double averageSessionDuration;
  final double averageTracksPerSession;
  final int totalLikes;
  final int totalInvestors;

  UserEngagement({
    this.totalActiveUsers = 0,
    this.dailyActiveUsers = 0,
    this.weeklyActiveUsers = 0,
    this.monthlyActiveUsers = 0,
    this.averageSessionDuration = 0,
    this.averageTracksPerSession = 0,
    this.totalLikes = 0,
    this.totalInvestors = 0,
  });

  factory UserEngagement.fromJson(Map<String, dynamic> json) {
    return UserEngagement(
      totalActiveUsers: json['totalActiveUsers'] ?? 0,
      dailyActiveUsers: json['dailyActiveUsers'] ?? 0,
      weeklyActiveUsers: json['weeklyActiveUsers'] ?? 0,
      monthlyActiveUsers: json['monthlyActiveUsers'] ?? 0,
      averageSessionDuration: (json['averageSessionDuration'] ?? 0).toDouble(),
      averageTracksPerSession: (json['averageTracksPerSession'] ?? 0).toDouble(),
      totalLikes: json['totalLikes'] ?? 0,
      totalInvestors: json['totalInvestors'] ?? 0,
    );
  }
}

class TimeSeriesData {
  final DateTime date;
  final int plays;
  final int newUsers;
  final int likes;
  final double investments;

  TimeSeriesData({
    required this.date,
    this.plays = 0,
    this.newUsers = 0,
    this.likes = 0,
    this.investments = 0,
  });

  factory TimeSeriesData.fromJson(Map<String, dynamic> json) {
    return TimeSeriesData(
      date: DateTime.parse(json['date']),
      plays: json['plays'] ?? 0,
      newUsers: json['newUsers'] ?? 0,
      likes: json['likes'] ?? 0,
      investments: (json['investments'] ?? 0).toDouble(),
    );
  }
}
