import 'package:flutter/foundation.dart';
import 'package:muzzfund_admin/models/statistics.dart';
import 'package:muzzfund_admin/network/admin_client.dart';

class StatisticsProvider extends ChangeNotifier {
  final AdminClient _client = AdminClient();

  DashboardStatistics _overview = DashboardStatistics();
  List<TopTrackStats> _topTracks = [];
  UserEngagement _userEngagement = UserEngagement();
  List<TimeSeriesData> _timeSeriesData = [];

  bool _isLoading = false;
  String? _error;
  String _selectedPeriod = '7d';

  DashboardStatistics get overview => _overview;
  List<TopTrackStats> get topTracks => _topTracks;
  UserEngagement get userEngagement => _userEngagement;
  List<TimeSeriesData> get timeSeriesData => _timeSeriesData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedPeriod => _selectedPeriod;

  Future<void> loadAllStatistics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load all statistics in parallel
      final results = await Future.wait([
        _client.getStatisticsOverview(),
        _client.getTopTracks(limit: 10, period: _selectedPeriod),
        _client.getUserEngagement(),
        _client.getTimeSeriesData(period: _selectedPeriod, metric: 'plays'),
      ]);

      _overview = results[0] as DashboardStatistics;
      _topTracks = results[1] as List<TopTrackStats>;
      _userEngagement = results[2] as UserEngagement;
      _timeSeriesData = results[3] as List<TimeSeriesData>;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load statistics: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOverview() async {
    try {
      _overview = await _client.getStatisticsOverview();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load overview: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> loadTopTracks({int limit = 10}) async {
    try {
      _topTracks = await _client.getTopTracks(limit: limit, period: _selectedPeriod);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load top tracks: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> loadUserEngagement() async {
    try {
      _userEngagement = await _client.getUserEngagement();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user engagement: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> loadTimeSeriesData({String metric = 'plays'}) async {
    try {
      _timeSeriesData = await _client.getTimeSeriesData(
        period: _selectedPeriod,
        metric: metric,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load time series data: ${e.toString()}';
      notifyListeners();
    }
  }

  void setPeriod(String period) {
    _selectedPeriod = period;
    loadAllStatistics();
  }

  Future<String?> exportReport({
    required String format,
    required String reportType,
  }) async {
    try {
      return await _client.exportReport(
        format: format,
        reportType: reportType,
        period: _selectedPeriod,
      );
    } catch (e) {
      _error = 'Failed to export report: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
