import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:muzzfund_admin/models/admin_investment.dart';
import 'package:muzzfund_admin/network/admin_client.dart';

class InvestmentsProvider extends ChangeNotifier {
  final AdminClient _client = AdminClient();

  // Dashboard data
  InvestmentOverview _overview = InvestmentOverview();
  List<InvestmentTimeSeries> _timeSeriesData = [];
  List<TopInvestedTrack> _topTracks = [];
  List<TopInvestor> _topInvestors = [];
  InvestmentDistribution _distribution = InvestmentDistribution();
  List<RecentInvestment> _recentActivity = [];

  // Table data
  List<AdminInvestment> _investments = [];
  int _totalCount = 0;
  int _totalPages = 1;

  // Detail data
  TrackInvestmentDetail? _trackDetail;
  UserInvestmentPortfolio? _userPortfolio;

  // Pagination state
  int _currentPage = 1;
  int _pageSize = 20;

  // Filter state
  String _searchQuery = '';
  String? _statusFilter;
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;

  // Sort state
  String _sortBy = 'date';
  bool _sortDescending = true;

  // Period for charts
  String _selectedPeriod = '30d';

  // Loading states
  bool _isLoading = false;
  bool _isLoadingTable = false;
  bool _isLoadingDetail = false;
  String? _error;

  // Auto-refresh
  Timer? _autoRefreshTimer;
  bool _autoRefreshEnabled = false;
  int _autoRefreshInterval = 60; // seconds
  DateTime? _lastUpdated;

  // Getters
  InvestmentOverview get overview => _overview;
  List<InvestmentTimeSeries> get timeSeriesData => _timeSeriesData;
  List<TopInvestedTrack> get topTracks => _topTracks;
  List<TopInvestor> get topInvestors => _topInvestors;
  InvestmentDistribution get distribution => _distribution;
  List<RecentInvestment> get recentActivity => _recentActivity;

  List<AdminInvestment> get investments => _investments;
  int get totalCount => _totalCount;
  int get totalPages => _totalPages;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  TrackInvestmentDetail? get trackDetail => _trackDetail;
  UserInvestmentPortfolio? get userPortfolio => _userPortfolio;

  String get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  double? get minAmount => _minAmount;
  double? get maxAmount => _maxAmount;
  String get sortBy => _sortBy;
  bool get sortDescending => _sortDescending;
  String get selectedPeriod => _selectedPeriod;

  bool get isLoading => _isLoading;
  bool get isLoadingTable => _isLoadingTable;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get error => _error;

  bool get autoRefreshEnabled => _autoRefreshEnabled;
  int get autoRefreshInterval => _autoRefreshInterval;
  DateTime? get lastUpdated => _lastUpdated;

  /// Load all dashboard data in parallel
  Future<void> loadAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _client.getInvestmentsOverview(),
        _client.getInvestmentsTimeSeries(period: _selectedPeriod),
        _client.getTopInvestedTracks(limit: 10),
        _client.getTopInvestors(limit: 10),
        _client.getInvestmentDistribution(groupBy: 'status'),
        _client.getRecentInvestments(limit: 20),
      ]);

      _overview = results[0] as InvestmentOverview;
      _timeSeriesData = results[1] as List<InvestmentTimeSeries>;
      _topTracks = results[2] as List<TopInvestedTrack>;
      _topInvestors = results[3] as List<TopInvestor>;
      _distribution = results[4] as InvestmentDistribution;
      _recentActivity = results[5] as List<RecentInvestment>;

      _lastUpdated = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load investment data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load investments table with current filters
  Future<void> loadInvestments() async {
    _isLoadingTable = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _client.getInvestments(
        page: _currentPage,
        pageSize: _pageSize,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        status: _statusFilter,
        startDate: _startDate,
        endDate: _endDate,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
        sortBy: _sortBy,
        sortDescending: _sortDescending,
      );

      _investments = result['investments'] as List<AdminInvestment>;
      _totalCount = result['totalCount'] as int;
      _totalPages = result['totalPages'] as int;

      _isLoadingTable = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load investments: ${e.toString()}';
      _isLoadingTable = false;
      notifyListeners();
    }
  }

  /// Load overview only
  Future<void> loadOverview() async {
    try {
      _overview = await _client.getInvestmentsOverview();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load overview: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Load time series data for charts
  Future<void> loadTimeSeries() async {
    try {
      _timeSeriesData = await _client.getInvestmentsTimeSeries(
        period: _selectedPeriod,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load time series: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Load top tracks ranking
  Future<void> loadTopTracks({int limit = 10}) async {
    try {
      _topTracks = await _client.getTopInvestedTracks(limit: limit);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load top tracks: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Load top investors ranking
  Future<void> loadTopInvestors({int limit = 10}) async {
    try {
      _topInvestors = await _client.getTopInvestors(limit: limit);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load top investors: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Load distribution data
  Future<void> loadDistribution({String groupBy = 'status'}) async {
    try {
      _distribution = await _client.getInvestmentDistribution(groupBy: groupBy);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load distribution: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Load recent activity feed
  Future<void> loadRecentActivity({int limit = 20}) async {
    try {
      _recentActivity = await _client.getRecentInvestments(limit: limit);
      _lastUpdated = DateTime.now();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load recent activity: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Load track investment detail
  Future<void> loadTrackDetail(int trackId) async {
    _isLoadingDetail = true;
    _error = null;
    _trackDetail = null;
    notifyListeners();

    try {
      _trackDetail = await _client.getTrackInvestmentDetail(trackId);
      _isLoadingDetail = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load track detail: ${e.toString()}';
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  /// Load user investment portfolio
  Future<void> loadUserPortfolio(int userId) async {
    _isLoadingDetail = true;
    _error = null;
    _userPortfolio = null;
    notifyListeners();

    try {
      _userPortfolio = await _client.getUserInvestmentPortfolio(userId);
      _isLoadingDetail = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user portfolio: ${e.toString()}';
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  /// Export investments data
  Future<String?> exportData({
    String format = 'csv',
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    try {
      return await _client.exportInvestments(
        format: format,
        startDate: startDate ?? _startDate,
        endDate: endDate ?? _endDate,
        status: status ?? _statusFilter,
      );
    } catch (e) {
      _error = 'Failed to export data: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Update investment status
  Future<bool> updateInvestmentStatus(int id, String status) async {
    try {
      final success = await _client.updateInvestmentStatus(id, status);
      if (success) {
        // Refresh the investments list
        await loadInvestments();
      }
      return success;
    } catch (e) {
      _error = 'Failed to update status: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // ==================== Filter & Sort Methods ====================

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    loadInvestments();
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    _currentPage = 1;
    loadInvestments();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _currentPage = 1;
    loadInvestments();
  }

  void setAmountRange(double? min, double? max) {
    _minAmount = min;
    _maxAmount = max;
    _currentPage = 1;
    loadInvestments();
  }

  void setSort(String sortBy, {bool? descending}) {
    _sortBy = sortBy;
    if (descending != null) {
      _sortDescending = descending;
    } else {
      // Toggle if same column
      if (_sortBy == sortBy) {
        _sortDescending = !_sortDescending;
      } else {
        _sortDescending = true;
      }
    }
    loadInvestments();
  }

  void setPeriod(String period) {
    _selectedPeriod = period;
    loadTimeSeries();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _startDate = null;
    _endDate = null;
    _minAmount = null;
    _maxAmount = null;
    _currentPage = 1;
    loadInvestments();
  }

  // ==================== Pagination Methods ====================

  void setPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      _currentPage = page;
      loadInvestments();
    }
  }

  void nextPage() {
    if (_currentPage < _totalPages) {
      _currentPage++;
      loadInvestments();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      loadInvestments();
    }
  }

  void setPageSize(int size) {
    _pageSize = size;
    _currentPage = 1;
    loadInvestments();
  }

  // ==================== Auto-refresh Methods ====================

  void startAutoRefresh({int? intervalSeconds}) {
    if (intervalSeconds != null) {
      _autoRefreshInterval = intervalSeconds;
    }

    _autoRefreshTimer?.cancel();
    _autoRefreshEnabled = true;

    _autoRefreshTimer = Timer.periodic(
      Duration(seconds: _autoRefreshInterval),
      (_) => _autoRefresh(),
    );

    notifyListeners();
  }

  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
    _autoRefreshEnabled = false;
    notifyListeners();
  }

  void toggleAutoRefresh() {
    if (_autoRefreshEnabled) {
      stopAutoRefresh();
    } else {
      startAutoRefresh();
    }
  }

  void setAutoRefreshInterval(int seconds) {
    _autoRefreshInterval = seconds;
    if (_autoRefreshEnabled) {
      startAutoRefresh(intervalSeconds: seconds);
    }
  }

  Future<void> _autoRefresh() async {
    // Only refresh if not currently loading
    if (!_isLoading && !_isLoadingTable) {
      await loadRecentActivity();
      await loadOverview();
    }
  }

  /// Manual refresh all data
  Future<void> refresh() async {
    await loadAllData();
    await loadInvestments();
  }

  // ==================== Utility Methods ====================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearTrackDetail() {
    _trackDetail = null;
    notifyListeners();
  }

  void clearUserPortfolio() {
    _userPortfolio = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
