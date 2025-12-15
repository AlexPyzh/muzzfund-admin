class ApiConfig {
  // Use relative path in production (nginx proxies to backend)
  // Use absolute URL for local development
  static const bool _isProduction = bool.fromEnvironment('dart.vm.product');

  // In production, use relative path (nginx proxy handles it)
  // In development, connect directly to backend
  static String get baseUrl => _isProduction ? '' : 'http://localhost:5001';
  static const String apiPath = '/api';

  // Admin endpoints
  static const String adminAuth = '$apiPath/AdminAuth';
  static const String adminUsers = '$apiPath/AdminUsers';
  static const String adminTracks = '$apiPath/AdminTracks';
  static const String adminStatistics = '$apiPath/AdminStatistics';

  // Full URLs
  static String get fullBaseUrl => baseUrl;
  static String get loginUrl => '$fullBaseUrl$adminAuth/login';
  static String get refreshTokenUrl => '$fullBaseUrl$adminAuth/refresh';

  // Users
  static String get usersUrl => '$fullBaseUrl$adminUsers';
  static String userByIdUrl(int id) => '$fullBaseUrl$adminUsers/$id';
  static String userStatusUrl(int id) => '$fullBaseUrl$adminUsers/$id/status';
  static String userActivityUrl(int id) => '$fullBaseUrl$adminUsers/$id/activity';
  static String userInvestmentsUrl(int id) => '$fullBaseUrl$adminUsers/$id/investments';
  static String userListeningHistoryUrl(int id) => '$fullBaseUrl$adminUsers/$id/listening-history';

  // Tracks
  static String get tracksUrl => '$fullBaseUrl$adminTracks';
  static String trackByIdUrl(int id) => '$fullBaseUrl$adminTracks/$id';
  static String trackApproveUrl(int id) => '$fullBaseUrl$adminTracks/$id/approve';
  static String trackRejectUrl(int id) => '$fullBaseUrl$adminTracks/$id/reject';
  static String trackFeatureUrl(int id) => '$fullBaseUrl$adminTracks/$id/feature';
  static String get tracksBulkUrl => '$fullBaseUrl$adminTracks/bulk';

  // Statistics
  static String get statisticsOverviewUrl => '$fullBaseUrl$adminStatistics/overview';
  static String get statisticsTopTracksUrl => '$fullBaseUrl$adminStatistics/top-tracks';
  static String get statisticsUserEngagementUrl => '$fullBaseUrl$adminStatistics/user-engagement';
  static String get statisticsTimeSeriesUrl => '$fullBaseUrl$adminStatistics/time-series';
  static String get statisticsExportUrl => '$fullBaseUrl$adminStatistics/export';
}
