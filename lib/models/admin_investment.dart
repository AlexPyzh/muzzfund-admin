/// Investment transaction model for admin panel
class AdminInvestment {
  final int id;
  final String? transactionId;
  final int userId;
  final String userName;
  final String? userEmail;
  final int? trackId;
  final String trackName;
  final String? trackImageUrl;
  final int? artistId;
  final String artistName;
  final double boughtPercent;
  final double? amountInDollars;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AdminInvestment({
    required this.id,
    this.transactionId,
    required this.userId,
    required this.userName,
    this.userEmail,
    this.trackId,
    required this.trackName,
    this.trackImageUrl,
    this.artistId,
    required this.artistName,
    required this.boughtPercent,
    this.amountInDollars,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory AdminInvestment.fromJson(Map<String, dynamic> json) {
    return AdminInvestment(
      id: json['id'] ?? 0,
      transactionId: json['transactionId'],
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? 'Unknown',
      userEmail: json['userEmail'],
      trackId: json['trackId'],
      trackName: json['trackName'] ?? 'Unknown',
      trackImageUrl: json['trackImageUrl'],
      artistId: json['artistId'],
      artistName: json['artistName'] ?? 'Unknown',
      boughtPercent: (json['boughtPercent'] ?? 0).toDouble(),
      amountInDollars: json['amountInDollars']?.toDouble(),
      status: json['status'] ?? 'Unknown',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'trackId': trackId,
      'trackName': trackName,
      'trackImageUrl': trackImageUrl,
      'artistId': artistId,
      'artistName': artistName,
      'boughtPercent': boughtPercent,
      'amountInDollars': amountInDollars,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }

  String get formattedAmount {
    if (amountInDollars == null) return '-';
    return '\$${amountInDollars!.toStringAsFixed(2)}';
  }

  String get formattedPercent {
    return '${boughtPercent.toStringAsFixed(2)}%';
  }
}

/// Investment overview statistics for dashboard
class InvestmentOverview {
  final int totalInvestments;
  final int investmentsToday;
  final int investmentsThisWeek;
  final double totalVolume;
  final double volumeToday;
  final double volumeThisWeek;
  final int activeInvestors;
  final int newInvestorsToday;
  final int newInvestorsThisWeek;
  final int tracksWithInvestments;
  final int totalTracks;
  final double tracksPercentage;
  final double averageInvestment;
  final double revenueDistributed;
  final double lastMonthDistributed;
  final int pendingInvestments;

  InvestmentOverview({
    this.totalInvestments = 0,
    this.investmentsToday = 0,
    this.investmentsThisWeek = 0,
    this.totalVolume = 0,
    this.volumeToday = 0,
    this.volumeThisWeek = 0,
    this.activeInvestors = 0,
    this.newInvestorsToday = 0,
    this.newInvestorsThisWeek = 0,
    this.tracksWithInvestments = 0,
    this.totalTracks = 0,
    this.tracksPercentage = 0,
    this.averageInvestment = 0,
    this.revenueDistributed = 0,
    this.lastMonthDistributed = 0,
    this.pendingInvestments = 0,
  });

  factory InvestmentOverview.fromJson(Map<String, dynamic> json) {
    return InvestmentOverview(
      totalInvestments: json['totalInvestments'] ?? 0,
      investmentsToday: json['investmentsToday'] ?? 0,
      investmentsThisWeek: json['investmentsThisWeek'] ?? 0,
      totalVolume: (json['totalVolume'] ?? 0).toDouble(),
      volumeToday: (json['volumeToday'] ?? 0).toDouble(),
      volumeThisWeek: (json['volumeThisWeek'] ?? 0).toDouble(),
      activeInvestors: json['activeInvestors'] ?? 0,
      newInvestorsToday: json['newInvestorsToday'] ?? 0,
      newInvestorsThisWeek: json['newInvestorsThisWeek'] ?? 0,
      tracksWithInvestments: json['tracksWithInvestments'] ?? 0,
      totalTracks: json['totalTracks'] ?? 0,
      tracksPercentage: (json['tracksPercentage'] ?? 0).toDouble(),
      averageInvestment: (json['averageInvestment'] ?? 0).toDouble(),
      revenueDistributed: (json['revenueDistributed'] ?? 0).toDouble(),
      lastMonthDistributed: (json['lastMonthDistributed'] ?? 0).toDouble(),
      pendingInvestments: json['pendingInvestments'] ?? 0,
    );
  }
}

/// Time series data point for investment charts
class InvestmentTimeSeries {
  final DateTime date;
  final int transactionCount;
  final double totalAmount;
  final int uniqueInvestors;
  final int uniqueTracks;

  InvestmentTimeSeries({
    required this.date,
    this.transactionCount = 0,
    this.totalAmount = 0,
    this.uniqueInvestors = 0,
    this.uniqueTracks = 0,
  });

  factory InvestmentTimeSeries.fromJson(Map<String, dynamic> json) {
    return InvestmentTimeSeries(
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      transactionCount: json['transactionCount'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      uniqueInvestors: json['uniqueInvestors'] ?? 0,
      uniqueTracks: json['uniqueTracks'] ?? 0,
    );
  }
}

/// Top invested track ranking entry
class TopInvestedTrack {
  final int rank;
  final int trackId;
  final String trackName;
  final int? artistId;
  final String artistName;
  final String? imageUrl;
  final double totalInvestmentAmount;
  final int investorCount;
  final double percentSold;
  final double percentAvailable;
  final int transactionCount;

  TopInvestedTrack({
    required this.rank,
    required this.trackId,
    required this.trackName,
    this.artistId,
    required this.artistName,
    this.imageUrl,
    required this.totalInvestmentAmount,
    required this.investorCount,
    required this.percentSold,
    required this.percentAvailable,
    required this.transactionCount,
  });

  factory TopInvestedTrack.fromJson(Map<String, dynamic> json) {
    return TopInvestedTrack(
      rank: json['rank'] ?? 0,
      trackId: json['trackId'] ?? 0,
      trackName: json['trackName'] ?? 'Unknown',
      artistId: json['artistId'],
      artistName: json['artistName'] ?? 'Unknown',
      imageUrl: json['imageUrl'],
      totalInvestmentAmount: (json['totalInvestmentAmount'] ?? 0).toDouble(),
      investorCount: json['investorCount'] ?? 0,
      percentSold: (json['percentSold'] ?? 0).toDouble(),
      percentAvailable: (json['percentAvailable'] ?? 0).toDouble(),
      transactionCount: json['transactionCount'] ?? 0,
    );
  }
}

/// Top investor ranking entry
class TopInvestor {
  final int rank;
  final int userId;
  final String userName;
  final String? email;
  final double totalInvestmentAmount;
  final int investmentCount;
  final int uniqueTracksCount;
  final DateTime firstInvestmentDate;
  final DateTime lastInvestmentDate;

  TopInvestor({
    required this.rank,
    required this.userId,
    required this.userName,
    this.email,
    required this.totalInvestmentAmount,
    required this.investmentCount,
    required this.uniqueTracksCount,
    required this.firstInvestmentDate,
    required this.lastInvestmentDate,
  });

  factory TopInvestor.fromJson(Map<String, dynamic> json) {
    return TopInvestor(
      rank: json['rank'] ?? 0,
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? 'Unknown',
      email: json['email'],
      totalInvestmentAmount: (json['totalInvestmentAmount'] ?? 0).toDouble(),
      investmentCount: json['investmentCount'] ?? 0,
      uniqueTracksCount: json['uniqueTracksCount'] ?? 0,
      firstInvestmentDate: json['firstInvestmentDate'] != null
          ? DateTime.parse(json['firstInvestmentDate'])
          : DateTime.now(),
      lastInvestmentDate: json['lastInvestmentDate'] != null
          ? DateTime.parse(json['lastInvestmentDate'])
          : DateTime.now(),
    );
  }
}

/// Distribution segment for pie chart
class InvestmentDistributionSegment {
  final String label;
  final int count;
  final double amount;
  final double percentage;

  InvestmentDistributionSegment({
    required this.label,
    required this.count,
    required this.amount,
    required this.percentage,
  });

  factory InvestmentDistributionSegment.fromJson(Map<String, dynamic> json) {
    return InvestmentDistributionSegment(
      label: json['label'] ?? 'Unknown',
      count: json['count'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

/// Investment distribution response
class InvestmentDistribution {
  final List<InvestmentDistributionSegment> segments;
  final int totalCount;
  final double totalAmount;

  InvestmentDistribution({
    this.segments = const [],
    this.totalCount = 0,
    this.totalAmount = 0,
  });

  factory InvestmentDistribution.fromJson(Map<String, dynamic> json) {
    return InvestmentDistribution(
      segments: (json['segments'] as List?)
              ?.map((s) => InvestmentDistributionSegment.fromJson(s))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}

/// Track investment detail with investors and transactions
class TrackInvestmentDetail {
  final int trackId;
  final String trackName;
  final int? artistId;
  final String artistName;
  final String? imageUrl;
  final double totalInvestmentAmount;
  final int investorCount;
  final double percentSold;
  final double percentAvailable;
  final double percentForSale;
  final int transactionCount;
  final DateTime? firstInvestmentDate;
  final DateTime? lastInvestmentDate;
  final List<TrackInvestor> investors;
  final List<InvestmentTransaction> transactions;

  TrackInvestmentDetail({
    required this.trackId,
    required this.trackName,
    this.artistId,
    required this.artistName,
    this.imageUrl,
    required this.totalInvestmentAmount,
    required this.investorCount,
    required this.percentSold,
    required this.percentAvailable,
    required this.percentForSale,
    required this.transactionCount,
    this.firstInvestmentDate,
    this.lastInvestmentDate,
    this.investors = const [],
    this.transactions = const [],
  });

  factory TrackInvestmentDetail.fromJson(Map<String, dynamic> json) {
    return TrackInvestmentDetail(
      trackId: json['trackId'] ?? 0,
      trackName: json['trackName'] ?? 'Unknown',
      artistId: json['artistId'],
      artistName: json['artistName'] ?? 'Unknown',
      imageUrl: json['imageUrl'],
      totalInvestmentAmount: (json['totalInvestmentAmount'] ?? 0).toDouble(),
      investorCount: json['investorCount'] ?? 0,
      percentSold: (json['percentSold'] ?? 0).toDouble(),
      percentAvailable: (json['percentAvailable'] ?? 0).toDouble(),
      percentForSale: (json['percentForSale'] ?? 100).toDouble(),
      transactionCount: json['transactionCount'] ?? 0,
      firstInvestmentDate: json['firstInvestmentDate'] != null
          ? DateTime.parse(json['firstInvestmentDate'])
          : null,
      lastInvestmentDate: json['lastInvestmentDate'] != null
          ? DateTime.parse(json['lastInvestmentDate'])
          : null,
      investors: (json['investors'] as List?)
              ?.map((i) => TrackInvestor.fromJson(i))
              .toList() ??
          [],
      transactions: (json['transactions'] as List?)
              ?.map((t) => InvestmentTransaction.fromJson(t))
              .toList() ??
          [],
    );
  }
}

/// Investor in a specific track
class TrackInvestor {
  final int userId;
  final String userName;
  final String? email;
  final double percentOwned;
  final double totalInvested;
  final int transactionCount;
  final DateTime firstInvestment;
  final DateTime lastInvestment;

  TrackInvestor({
    required this.userId,
    required this.userName,
    this.email,
    required this.percentOwned,
    required this.totalInvested,
    required this.transactionCount,
    required this.firstInvestment,
    required this.lastInvestment,
  });

  factory TrackInvestor.fromJson(Map<String, dynamic> json) {
    return TrackInvestor(
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? 'Unknown',
      email: json['email'],
      percentOwned: (json['percentOwned'] ?? 0).toDouble(),
      totalInvested: (json['totalInvested'] ?? 0).toDouble(),
      transactionCount: json['transactionCount'] ?? 0,
      firstInvestment: json['firstInvestment'] != null
          ? DateTime.parse(json['firstInvestment'])
          : DateTime.now(),
      lastInvestment: json['lastInvestment'] != null
          ? DateTime.parse(json['lastInvestment'])
          : DateTime.now(),
    );
  }
}

/// Investment transaction for timeline
class InvestmentTransaction {
  final int id;
  final int? userId;
  final String? userName;
  final int? trackId;
  final String? trackName;
  final String? artistName;
  final double percentPurchased;
  final double amountPaid;
  final String status;
  final DateTime date;

  InvestmentTransaction({
    required this.id,
    this.userId,
    this.userName,
    this.trackId,
    this.trackName,
    this.artistName,
    required this.percentPurchased,
    required this.amountPaid,
    required this.status,
    required this.date,
  });

  factory InvestmentTransaction.fromJson(Map<String, dynamic> json) {
    return InvestmentTransaction(
      id: json['id'] ?? 0,
      userId: json['userId'],
      userName: json['userName'],
      trackId: json['trackId'],
      trackName: json['trackName'],
      artistName: json['artistName'],
      percentPurchased: (json['percentPurchased'] ?? 0).toDouble(),
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      status: json['status'] ?? 'Unknown',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
    );
  }
}

/// User investment portfolio detail
class UserInvestmentPortfolio {
  final int userId;
  final String userName;
  final String? email;
  final double totalInvested;
  final double totalPercent;
  final int investmentCount;
  final int uniqueTracksCount;
  final DateTime? firstInvestmentDate;
  final DateTime? lastInvestmentDate;
  final List<UserTrackInvestment> trackInvestments;
  final List<InvestmentTransaction> transactions;

  UserInvestmentPortfolio({
    required this.userId,
    required this.userName,
    this.email,
    required this.totalInvested,
    required this.totalPercent,
    required this.investmentCount,
    required this.uniqueTracksCount,
    this.firstInvestmentDate,
    this.lastInvestmentDate,
    this.trackInvestments = const [],
    this.transactions = const [],
  });

  factory UserInvestmentPortfolio.fromJson(Map<String, dynamic> json) {
    return UserInvestmentPortfolio(
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? 'Unknown',
      email: json['email'],
      totalInvested: (json['totalInvested'] ?? 0).toDouble(),
      totalPercent: (json['totalPercent'] ?? 0).toDouble(),
      investmentCount: json['investmentCount'] ?? 0,
      uniqueTracksCount: json['uniqueTracksCount'] ?? 0,
      firstInvestmentDate: json['firstInvestmentDate'] != null
          ? DateTime.parse(json['firstInvestmentDate'])
          : null,
      lastInvestmentDate: json['lastInvestmentDate'] != null
          ? DateTime.parse(json['lastInvestmentDate'])
          : null,
      trackInvestments: (json['trackInvestments'] as List?)
              ?.map((t) => UserTrackInvestment.fromJson(t))
              .toList() ??
          [],
      transactions: (json['transactions'] as List?)
              ?.map((t) => InvestmentTransaction.fromJson(t))
              .toList() ??
          [],
    );
  }
}

/// User's investment in a specific track
class UserTrackInvestment {
  final int trackId;
  final String trackName;
  final String artistName;
  final String? imageUrl;
  final double percentOwned;
  final double totalInvested;
  final int transactionCount;
  final DateTime firstInvestment;
  final DateTime lastInvestment;
  final String lastStatus;

  UserTrackInvestment({
    required this.trackId,
    required this.trackName,
    required this.artistName,
    this.imageUrl,
    required this.percentOwned,
    required this.totalInvested,
    required this.transactionCount,
    required this.firstInvestment,
    required this.lastInvestment,
    required this.lastStatus,
  });

  factory UserTrackInvestment.fromJson(Map<String, dynamic> json) {
    return UserTrackInvestment(
      trackId: json['trackId'] ?? 0,
      trackName: json['trackName'] ?? 'Unknown',
      artistName: json['artistName'] ?? 'Unknown',
      imageUrl: json['imageUrl'],
      percentOwned: (json['percentOwned'] ?? 0).toDouble(),
      totalInvested: (json['totalInvested'] ?? 0).toDouble(),
      transactionCount: json['transactionCount'] ?? 0,
      firstInvestment: json['firstInvestment'] != null
          ? DateTime.parse(json['firstInvestment'])
          : DateTime.now(),
      lastInvestment: json['lastInvestment'] != null
          ? DateTime.parse(json['lastInvestment'])
          : DateTime.now(),
      lastStatus: json['lastStatus'] ?? 'Unknown',
    );
  }
}

/// Recent investment for activity feed
class RecentInvestment {
  final int id;
  final int userId;
  final String userName;
  final int? trackId;
  final String trackName;
  final String artistName;
  final double percentPurchased;
  final double amountPaid;
  final String status;
  final DateTime createdAt;

  RecentInvestment({
    required this.id,
    required this.userId,
    required this.userName,
    this.trackId,
    required this.trackName,
    required this.artistName,
    required this.percentPurchased,
    required this.amountPaid,
    required this.status,
    required this.createdAt,
  });

  factory RecentInvestment.fromJson(Map<String, dynamic> json) {
    return RecentInvestment(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? 'Unknown',
      trackId: json['trackId'],
      trackName: json['trackName'] ?? 'Unknown',
      artistName: json['artistName'] ?? 'Unknown',
      percentPurchased: (json['percentPurchased'] ?? 0).toDouble(),
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      status: json['status'] ?? 'Unknown',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Investment status enum helper
enum InvestmentStatus {
  pending,
  completed,
  failed,
  refunded;

  String get label {
    switch (this) {
      case InvestmentStatus.pending:
        return 'Pending';
      case InvestmentStatus.completed:
        return 'Completed';
      case InvestmentStatus.failed:
        return 'Failed';
      case InvestmentStatus.refunded:
        return 'Refunded';
    }
  }

  static InvestmentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return InvestmentStatus.pending;
      case 'completed':
        return InvestmentStatus.completed;
      case 'failed':
        return InvestmentStatus.failed;
      case 'refunded':
        return InvestmentStatus.refunded;
      default:
        return InvestmentStatus.completed;
    }
  }
}
