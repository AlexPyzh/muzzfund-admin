class AdminTrack {
  final int id;
  final String name;
  final String? about;
  final String? imageUrl;
  final int? artistId;
  final String? artistName;
  final int? albumId;
  final String? albumName;
  final bool featured;
  final String? streamingUrl;
  final bool isSingle;
  final int? year;
  final bool visible;
  final bool deleted;
  final DateTime? created;
  final int? durationSeconds;
  final TrackApprovalStatus approvalStatus;
  final int totalPlays;
  final int likesCount;
  final double investmentPercent;

  AdminTrack({
    required this.id,
    required this.name,
    this.about,
    this.imageUrl,
    this.artistId,
    this.artistName,
    this.albumId,
    this.albumName,
    this.featured = false,
    this.streamingUrl,
    this.isSingle = false,
    this.year,
    this.visible = true,
    this.deleted = false,
    this.created,
    this.durationSeconds,
    this.approvalStatus = TrackApprovalStatus.approved,
    this.totalPlays = 0,
    this.likesCount = 0,
    this.investmentPercent = 0,
  });

  factory AdminTrack.fromJson(Map<String, dynamic> json) {
    return AdminTrack(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      about: json['about'],
      imageUrl: json['imageUrl'],
      artistId: json['artistId'],
      artistName: json['artistName'] ?? json['artist']?['name'],
      albumId: json['albumId'],
      albumName: json['albumName'] ?? json['album']?['name'],
      featured: json['featured'] ?? false,
      streamingUrl: json['streamingUrl'],
      isSingle: json['isSingle'] ?? false,
      year: json['year'],
      visible: json['visible'] ?? true,
      deleted: json['deleted'] ?? false,
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      durationSeconds: json['durationSeconds'],
      approvalStatus: _parseApprovalStatus(json['approvalStatus']),
      totalPlays: json['totalPlays'] ?? json['stats']?['totalPlays'] ?? 0,
      likesCount: json['likesCount'] ?? json['userReactions']?.length ?? 0,
      investmentPercent: (json['investmentPercent'] ??
          json['finInfo']?['soldPercent'] ?? 0).toDouble(),
    );
  }

  static TrackApprovalStatus _parseApprovalStatus(dynamic status) {
    if (status == null) return TrackApprovalStatus.approved;
    if (status is int) {
      return TrackApprovalStatus.values[status];
    }
    if (status is String) {
      return TrackApprovalStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == status.toLowerCase(),
        orElse: () => TrackApprovalStatus.approved,
      );
    }
    return TrackApprovalStatus.approved;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'about': about,
        'imageUrl': imageUrl,
        'artistId': artistId,
        'artistName': artistName,
        'albumId': albumId,
        'albumName': albumName,
        'featured': featured,
        'streamingUrl': streamingUrl,
        'isSingle': isSingle,
        'year': year,
        'visible': visible,
        'deleted': deleted,
        'created': created?.toIso8601String(),
        'durationSeconds': durationSeconds,
        'approvalStatus': approvalStatus.index,
        'totalPlays': totalPlays,
        'likesCount': likesCount,
        'investmentPercent': investmentPercent,
      };

  AdminTrack copyWith({
    int? id,
    String? name,
    String? about,
    String? imageUrl,
    int? artistId,
    String? artistName,
    int? albumId,
    String? albumName,
    bool? featured,
    String? streamingUrl,
    bool? isSingle,
    int? year,
    bool? visible,
    bool? deleted,
    DateTime? created,
    int? durationSeconds,
    TrackApprovalStatus? approvalStatus,
    int? totalPlays,
    int? likesCount,
    double? investmentPercent,
  }) {
    return AdminTrack(
      id: id ?? this.id,
      name: name ?? this.name,
      about: about ?? this.about,
      imageUrl: imageUrl ?? this.imageUrl,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      albumId: albumId ?? this.albumId,
      albumName: albumName ?? this.albumName,
      featured: featured ?? this.featured,
      streamingUrl: streamingUrl ?? this.streamingUrl,
      isSingle: isSingle ?? this.isSingle,
      year: year ?? this.year,
      visible: visible ?? this.visible,
      deleted: deleted ?? this.deleted,
      created: created ?? this.created,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      totalPlays: totalPlays ?? this.totalPlays,
      likesCount: likesCount ?? this.likesCount,
      investmentPercent: investmentPercent ?? this.investmentPercent,
    );
  }

  String get durationFormatted {
    if (durationSeconds == null) return '--:--';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

enum TrackApprovalStatus {
  pending,
  approved,
  rejected,
}

extension TrackApprovalStatusExtension on TrackApprovalStatus {
  String get displayName {
    switch (this) {
      case TrackApprovalStatus.pending:
        return 'Pending';
      case TrackApprovalStatus.approved:
        return 'Approved';
      case TrackApprovalStatus.rejected:
        return 'Rejected';
    }
  }
}
