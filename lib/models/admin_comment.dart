/// Comment status enum matching backend CommentStatus
enum CommentStatus {
  pending,
  approved,
  rejected,
  autoApproved,
}

/// Report reason enum matching backend ReportReason
enum ReportReason {
  spam,
  harassment,
  hateSpeech,
  violence,
  misinformation,
  copyright,
  other,
}

/// Report status enum matching backend ReportStatus
enum ReportStatus {
  pending,
  dismissed,
  actionTaken,
}

/// Admin comment DTO for list view
class AdminComment {
  final int id;
  final int trackId;
  final String? trackName;
  final String? artistName;
  final int userId;
  final String? userName;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final CommentStatus status;
  final int likesCount;
  final int reportsCount;
  final bool isReply;

  AdminComment({
    required this.id,
    required this.trackId,
    this.trackName,
    this.artistName,
    required this.userId,
    this.userName,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    required this.likesCount,
    required this.reportsCount,
    required this.isReply,
  });

  factory AdminComment.fromJson(Map<String, dynamic> json) {
    return AdminComment(
      id: json['id'],
      trackId: json['trackId'],
      trackName: json['trackName'],
      artistName: json['artistName'],
      userId: json['userId'],
      userName: json['userName'],
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      status: CommentStatus.values[json['status'] ?? 0],
      likesCount: json['likesCount'] ?? 0,
      reportsCount: json['reportsCount'] ?? 0,
      isReply: json['isReply'] ?? false,
    );
  }
}

/// Admin comment detail DTO with reports
class AdminCommentDetail extends AdminComment {
  final String? userEmail;
  final int? parentCommentId;
  final int repliesCount;
  final List<AdminCommentReport>? reports;

  AdminCommentDetail({
    required super.id,
    required super.trackId,
    super.trackName,
    super.artistName,
    required super.userId,
    super.userName,
    this.userEmail,
    required super.content,
    required super.createdAt,
    super.updatedAt,
    required super.status,
    required super.likesCount,
    required super.reportsCount,
    required super.isReply,
    this.parentCommentId,
    required this.repliesCount,
    this.reports,
  });

  factory AdminCommentDetail.fromJson(Map<String, dynamic> json) {
    return AdminCommentDetail(
      id: json['id'],
      trackId: json['trackId'],
      trackName: json['trackName'],
      artistName: json['artistName'],
      userId: json['userId'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      status: CommentStatus.values[json['status'] ?? 0],
      likesCount: json['likesCount'] ?? 0,
      reportsCount: json['reportsCount'] ?? 0,
      isReply: json['isReply'] ?? false,
      parentCommentId: json['parentCommentId'],
      repliesCount: json['repliesCount'] ?? 0,
      reports: json['reports'] != null
          ? (json['reports'] as List).map((r) => AdminCommentReport.fromJson(r)).toList()
          : null,
    );
  }
}

/// Comment report DTO
class AdminCommentReport {
  final int id;
  final int reporterUserId;
  final String? reporterUserName;
  final ReportReason reason;
  final String? details;
  final DateTime createdAt;
  final ReportStatus status;

  AdminCommentReport({
    required this.id,
    required this.reporterUserId,
    this.reporterUserName,
    required this.reason,
    this.details,
    required this.createdAt,
    required this.status,
  });

  factory AdminCommentReport.fromJson(Map<String, dynamic> json) {
    return AdminCommentReport(
      id: json['id'],
      reporterUserId: json['reporterUserId'],
      reporterUserName: json['reporterUserName'],
      reason: ReportReason.values[json['reason'] ?? 0],
      details: json['details'],
      createdAt: DateTime.parse(json['createdAt']),
      status: ReportStatus.values[json['status'] ?? 0],
    );
  }
}

/// Report with comment info for reports list view
class AdminReport {
  final int id;
  final int commentId;
  final String? commentContent;
  final int commentUserId;
  final String? commentUserName;
  final String? trackName;
  final int reporterUserId;
  final String? reporterUserName;
  final ReportReason reason;
  final String? details;
  final DateTime createdAt;
  final ReportStatus status;

  AdminReport({
    required this.id,
    required this.commentId,
    this.commentContent,
    required this.commentUserId,
    this.commentUserName,
    this.trackName,
    required this.reporterUserId,
    this.reporterUserName,
    required this.reason,
    this.details,
    required this.createdAt,
    required this.status,
  });

  factory AdminReport.fromJson(Map<String, dynamic> json) {
    return AdminReport(
      id: json['id'],
      commentId: json['commentId'],
      commentContent: json['commentContent'],
      commentUserId: json['commentUserId'],
      commentUserName: json['commentUserName'],
      trackName: json['trackName'],
      reporterUserId: json['reporterUserId'],
      reporterUserName: json['reporterUserName'],
      reason: ReportReason.values[json['reason'] ?? 0],
      details: json['details'],
      createdAt: DateTime.parse(json['createdAt']),
      status: ReportStatus.values[json['status'] ?? 0],
    );
  }
}

/// Comments statistics DTO
class AdminCommentsStats {
  final int totalComments;
  final int pendingComments;
  final int approvedComments;
  final int rejectedComments;
  final int pendingReports;
  final int commentsToday;
  final int commentsThisWeek;

  AdminCommentsStats({
    this.totalComments = 0,
    this.pendingComments = 0,
    this.approvedComments = 0,
    this.rejectedComments = 0,
    this.pendingReports = 0,
    this.commentsToday = 0,
    this.commentsThisWeek = 0,
  });

  factory AdminCommentsStats.fromJson(Map<String, dynamic> json) {
    return AdminCommentsStats(
      totalComments: json['totalComments'] ?? 0,
      pendingComments: json['pendingComments'] ?? 0,
      approvedComments: json['approvedComments'] ?? 0,
      rejectedComments: json['rejectedComments'] ?? 0,
      pendingReports: json['pendingReports'] ?? 0,
      commentsToday: json['commentsToday'] ?? 0,
      commentsThisWeek: json['commentsThisWeek'] ?? 0,
    );
  }
}
