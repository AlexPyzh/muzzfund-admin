import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:muzzfund_admin/config/api_config.dart';
import 'package:muzzfund_admin/models/admin_user.dart';
import 'package:muzzfund_admin/models/admin_track.dart';
import 'package:muzzfund_admin/models/admin_comment.dart';
import 'package:muzzfund_admin/models/admin_investment.dart';
import 'package:muzzfund_admin/models/statistics.dart';

class AdminClient {
  static final AdminClient _instance = AdminClient._internal();
  factory AdminClient() => _instance;
  AdminClient._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  String? get authToken => _authToken;

  // ==================== Auth ====================

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.loginUrl,
        data: {'username': username, 'password': password},
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) print('Login error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final response = await _dio.post(ApiConfig.refreshTokenUrl);
      return response.data;
    } catch (e) {
      if (kDebugMode) print('Refresh token error: $e');
      rethrow;
    }
  }

  // ==================== Users ====================

  Future<List<AdminUser>> getUsers({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
    String? sortBy,
    bool sortDescending = false,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.usersUrl,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null) 'status': status,
          if (sortBy != null) 'sortBy': sortBy,
          'sortDescending': sortDescending,
        },
      );
      final data = response.data['data'] ?? response.data;
      if (data is List) {
        return data.map((json) => AdminUser.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Get users error: $e');
      rethrow;
    }
  }

  Future<AdminUser> getUserById(int id) async {
    try {
      final response = await _dio.get(ApiConfig.userByIdUrl(id));
      final data = response.data['data'] ?? response.data;
      return AdminUser.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('Get user by id error: $e');
      rethrow;
    }
  }

  Future<bool> updateUserStatus(int id, bool isActive) async {
    try {
      await _dio.put(
        ApiConfig.userStatusUrl(id),
        data: {'isActive': isActive},
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Update user status error: $e');
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      await _dio.delete(ApiConfig.userByIdUrl(id));
      return true;
    } catch (e) {
      if (kDebugMode) print('Delete user error: $e');
      return false;
    }
  }

  Future<List<UserActivity>> getUserActivity(int id, {int limit = 50}) async {
    try {
      final response = await _dio.get(
        ApiConfig.userActivityUrl(id),
        queryParameters: {'limit': limit},
      );
      final data = response.data['data'] ?? response.data;
      if (data is List) {
        return data.map((json) => UserActivity.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Get user activity error: $e');
      return [];
    }
  }

  Future<List<UserInvestment>> getUserInvestments(int id) async {
    try {
      final response = await _dio.get(ApiConfig.userInvestmentsUrl(id));
      final data = response.data['data'] ?? response.data;
      if (data is List) {
        return data.map((json) => UserInvestment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Get user investments error: $e');
      return [];
    }
  }

  Future<List<ListeningHistoryItem>> getUserListeningHistory(int id, {int limit = 50}) async {
    try {
      final response = await _dio.get(
        ApiConfig.userListeningHistoryUrl(id),
        queryParameters: {'limit': limit},
      );
      final data = response.data['data'] ?? response.data;
      if (data is List) {
        return data.map((json) => ListeningHistoryItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Get user listening history error: $e');
      return [];
    }
  }

  // ==================== Tracks ====================

  Future<List<AdminTrack>> getTracks({
    int page = 1,
    int pageSize = 20,
    String? search,
    TrackApprovalStatus? status,
    String? sortBy,
    bool sortDescending = false,
    bool includePending = true,
    bool includeDeleted = false,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.tracksUrl,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null) 'status': status.index,
          if (sortBy != null) 'sortBy': sortBy,
          'sortDescending': sortDescending,
          'includePending': includePending,
          'includeDeleted': includeDeleted,
        },
      );
      final data = response.data['data'] ?? response.data;
      if (data is List) {
        return data.map((json) => AdminTrack.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Get tracks error: $e');
      rethrow;
    }
  }

  Future<AdminTrack> getTrackById(int id) async {
    try {
      final response = await _dio.get(ApiConfig.trackByIdUrl(id));
      final data = response.data['data'] ?? response.data;
      return AdminTrack.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('Get track by id error: $e');
      rethrow;
    }
  }

  Future<bool> approveTrack(int id) async {
    try {
      await _dio.post(ApiConfig.trackApproveUrl(id));
      return true;
    } catch (e) {
      if (kDebugMode) print('Approve track error: $e');
      return false;
    }
  }

  Future<bool> rejectTrack(int id, {String? reason}) async {
    try {
      await _dio.post(
        ApiConfig.trackRejectUrl(id),
        data: reason != null ? {'reason': reason} : null,
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Reject track error: $e');
      return false;
    }
  }

  Future<bool> setTrackFeatured(int id, bool featured) async {
    try {
      await _dio.put(
        ApiConfig.trackFeatureUrl(id),
        data: {'featured': featured},
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Set track featured error: $e');
      return false;
    }
  }

  Future<bool> deleteTrack(int id) async {
    try {
      await _dio.delete(ApiConfig.trackByIdUrl(id));
      return true;
    } catch (e) {
      if (kDebugMode) print('Delete track error: $e');
      return false;
    }
  }

  Future<bool> updateTrack(AdminTrack track) async {
    try {
      await _dio.put(
        ApiConfig.trackByIdUrl(track.id),
        data: track.toJson(),
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Update track error: $e');
      return false;
    }
  }

  Future<Map<String, bool>> bulkTrackOperation(
    List<int> trackIds,
    String operation,
  ) async {
    try {
      final response = await _dio.post(
        ApiConfig.tracksBulkUrl,
        data: {
          'trackIds': trackIds,
          'operation': operation,
        },
      );
      final data = response.data['data'] ?? response.data;
      return Map<String, bool>.from(data);
    } catch (e) {
      if (kDebugMode) print('Bulk track operation error: $e');
      return {};
    }
  }

  // ==================== Statistics ====================

  Future<DashboardStatistics> getStatisticsOverview() async {
    try {
      final response = await _dio.get(ApiConfig.statisticsOverviewUrl);
      final data = response.data['data'] ?? response.data;
      return DashboardStatistics.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('Get statistics overview error: $e');
      return DashboardStatistics();
    }
  }

  Future<List<TopTrackStats>> getTopTracks({
    int limit = 10,
    String period = '7d',
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.statisticsTopTracksUrl,
        queryParameters: {
          'limit': limit,
          'period': period,
        },
      );
      final data = response.data['data'] ?? response.data;
      if (data is List) {
        return data.map((json) => TopTrackStats.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Get top tracks error: $e');
      return [];
    }
  }

  Future<UserEngagement> getUserEngagement() async {
    try {
      final response = await _dio.get(ApiConfig.statisticsUserEngagementUrl);
      final data = response.data['data'] ?? response.data;
      return UserEngagement.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('Get user engagement error: $e');
      return UserEngagement();
    }
  }

  Future<List<TimeSeriesData>> getTimeSeriesData({
    String period = '30d',
    String metric = 'plays',
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.statisticsTimeSeriesUrl,
        queryParameters: {
          'period': period,
          'metric': metric,
        },
      );
      final data = response.data['data'] ?? response.data;
      if (data is List) {
        return data.map((json) => TimeSeriesData.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Get time series data error: $e');
      return [];
    }
  }

  Future<String?> exportReport({
    required String format,
    required String reportType,
    String? period,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.statisticsExportUrl,
        queryParameters: {
          'format': format,
          'reportType': reportType,
          if (period != null) 'period': period,
        },
      );
      return response.data['data']?['url'] ?? response.data['url'];
    } catch (e) {
      if (kDebugMode) print('Export report error: $e');
      return null;
    }
  }

  // ==================== Comments ====================

  Future<Map<String, dynamic>> getComments({
    int page = 1,
    int pageSize = 20,
    String? search,
    CommentStatus? status,
    int? trackId,
    int? userId,
    bool? hasReports,
    String sortBy = 'newest',
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.commentsUrl,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null) 'status': status.index,
          if (trackId != null) 'trackId': trackId,
          if (userId != null) 'userId': userId,
          if (hasReports != null) 'hasReports': hasReports,
          'sortBy': sortBy,
        },
      );
      final data = response.data['data'] ?? response.data;
      final comments = (data['comments'] as List?)
              ?.map((json) => AdminComment.fromJson(json))
              .toList() ??
          [];
      return {
        'comments': comments,
        'totalCount': data['totalCount'] ?? 0,
        'page': data['page'] ?? page,
        'pageSize': data['pageSize'] ?? pageSize,
      };
    } catch (e) {
      if (kDebugMode) print('Get comments error: $e');
      rethrow;
    }
  }

  Future<AdminCommentDetail> getCommentById(int id) async {
    try {
      final response = await _dio.get(ApiConfig.commentByIdUrl(id));
      final data = response.data['data'] ?? response.data;
      return AdminCommentDetail.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('Get comment by id error: $e');
      rethrow;
    }
  }

  Future<bool> updateCommentStatus(int id, CommentStatus status) async {
    try {
      await _dio.put(
        ApiConfig.commentStatusUrl(id),
        data: {'status': status.index},
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Update comment status error: $e');
      return false;
    }
  }

  Future<bool> deleteComment(int id, {bool permanent = false}) async {
    try {
      await _dio.delete(
        ApiConfig.commentByIdUrl(id),
        queryParameters: {'permanent': permanent},
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Delete comment error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getReports({
    int page = 1,
    int pageSize = 20,
    ReportStatus? status,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.reportsUrl,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (status != null) 'status': status.index,
        },
      );
      final data = response.data['data'] ?? response.data;
      final reports = (data['reports'] as List?)
              ?.map((json) => AdminReport.fromJson(json))
              .toList() ??
          [];
      return {
        'reports': reports,
        'totalCount': data['totalCount'] ?? 0,
        'page': data['page'] ?? page,
        'pageSize': data['pageSize'] ?? pageSize,
      };
    } catch (e) {
      if (kDebugMode) print('Get reports error: $e');
      rethrow;
    }
  }

  Future<bool> handleReport(
    int reportId, {
    required bool dismiss,
    bool deleteComment = false,
    bool rejectComment = false,
  }) async {
    try {
      await _dio.post(
        ApiConfig.handleReportUrl(reportId),
        data: {
          'dismiss': dismiss,
          'deleteComment': deleteComment,
          'rejectComment': rejectComment,
        },
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Handle report error: $e');
      return false;
    }
  }

  Future<AdminCommentsStats> getCommentsStats() async {
    try {
      final response = await _dio.get(ApiConfig.commentsStatsUrl);
      final data = response.data['data'] ?? response.data;
      return AdminCommentsStats.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('Get comments stats error: $e');
      return AdminCommentsStats();
    }
  }

  // ==================== Investments ====================

  Future<Map<String, dynamic>> getInvestments({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    int? trackId,
    int? userId,
    String sortBy = 'date',
    bool sortDescending = true,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.investmentsUrl,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null) 'status': status,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
          if (minAmount != null) 'minAmount': minAmount,
          if (maxAmount != null) 'maxAmount': maxAmount,
          if (trackId != null) 'trackId': trackId,
          if (userId != null) 'userId': userId,
          'sortBy': sortBy,
          'sortDescending': sortDescending,
        },
      );
      final data = response.data['data'] ?? response.data;
      final investments = (data['investments'] as List?)
              ?.map((json) => AdminInvestment.fromJson(json))
              .toList() ??
          [];
      return {
        'investments': investments,
        'totalCount': data['totalCount'] ?? 0,
        'page': data['page'] ?? page,
        'pageSize': data['pageSize'] ?? pageSize,
        'totalPages': data['totalPages'] ?? 1,
      };
    } catch (e) {
      if (kDebugMode) print('Get investments error: $e');
      rethrow;
    }
  }

  Future<AdminInvestment> getInvestmentById(int id) async {
    try {
      final response = await _dio.get(ApiConfig.investmentByIdUrl(id));
      final data = response.data['data'] ?? response.data;
      return AdminInvestment.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('Get investment by id error: $e');
      rethrow;
    }
  }

  Future<InvestmentOverview> getInvestmentsOverview() async {
    try {
      final response = await _dio.get(ApiConfig.investmentsOverviewUrl);
      final data = response.data['data'] ?? response.data;
      return InvestmentOverview.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('Get investments overview error: $e');
      return InvestmentOverview();
    }
  }

  Future<List<InvestmentTimeSeries>> getInvestmentsTimeSeries({
    String period = '30d',
    String granularity = 'daily',
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.investmentsTimeSeriesUrl,
        queryParameters: {
          'period': period,
          'granularity': granularity,
        },
      );
      final data = response.data['data'] ?? response.data;
      if (data is List) {
        return data.map((json) => InvestmentTimeSeries.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Get investments time series error: $e');
      return [];
    }
  }

  Future<List<TopInvestedTrack>> getTopInvestedTracks({
    int limit = 10,
    String period = 'all',
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.investmentsTopTracksUrl,
        queryParameters: {
          'limit': limit,
          'period': period,
        },
      );
      final data = response.data['data'] ?? response.data;
      if (data is List) {
        return data.map((json) => TopInvestedTrack.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Get top invested tracks error: $e');
      return [];
    }
  }

  Future<List<TopInvestor>> getTopInvestors({
    int limit = 10,
    String period = 'all',
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.investmentsTopInvestorsUrl,
        queryParameters: {
          'limit': limit,
          'period': period,
        },
      );
      final data = response.data['data'] ?? response.data;
      if (data is List) {
        return data.map((json) => TopInvestor.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Get top investors error: $e');
      return [];
    }
  }

  Future<InvestmentDistribution> getInvestmentDistribution({
    String groupBy = 'status',
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.investmentsDistributionUrl,
        queryParameters: {
          'groupBy': groupBy,
        },
      );
      final data = response.data['data'] ?? response.data;
      return InvestmentDistribution.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('Get investment distribution error: $e');
      return InvestmentDistribution();
    }
  }

  Future<TrackInvestmentDetail> getTrackInvestmentDetail(int trackId) async {
    try {
      final response = await _dio.get(ApiConfig.investmentsTrackDetailUrl(trackId));
      final data = response.data['data'] ?? response.data;
      return TrackInvestmentDetail.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('Get track investment detail error: $e');
      rethrow;
    }
  }

  Future<UserInvestmentPortfolio> getUserInvestmentPortfolio(int userId) async {
    try {
      final response = await _dio.get(ApiConfig.investmentsUserDetailUrl(userId));
      final data = response.data['data'] ?? response.data;
      return UserInvestmentPortfolio.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('Get user investment portfolio error: $e');
      rethrow;
    }
  }

  Future<List<RecentInvestment>> getRecentInvestments({int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiConfig.investmentsRecentUrl,
        queryParameters: {'limit': limit},
      );
      final data = response.data['data'] ?? response.data;
      if (data is List) {
        return data.map((json) => RecentInvestment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Get recent investments error: $e');
      return [];
    }
  }

  Future<String?> exportInvestments({
    String format = 'csv',
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.investmentsExportUrl,
        queryParameters: {
          'format': format,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
          if (status != null) 'status': status,
        },
      );
      return response.data['data']?['url'] ?? response.data['url'];
    } catch (e) {
      if (kDebugMode) print('Export investments error: $e');
      return null;
    }
  }

  Future<bool> updateInvestmentStatus(int id, String status) async {
    try {
      await _dio.put(
        ApiConfig.investmentStatusUrl(id),
        data: {'status': status},
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Update investment status error: $e');
      return false;
    }
  }
}
