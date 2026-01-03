import 'package:flutter/foundation.dart';
import 'package:muzzfund_admin/models/admin_comment.dart';
import 'package:muzzfund_admin/network/admin_client.dart';

class CommentsProvider extends ChangeNotifier {
  final AdminClient _client = AdminClient();

  // Comments list
  List<AdminComment> _comments = [];
  int _totalCount = 0;
  AdminCommentDetail? _selectedComment;

  // Reports list
  List<AdminReport> _reports = [];
  int _reportsCount = 0;

  // Stats
  AdminCommentsStats _stats = AdminCommentsStats();

  // State
  bool _isLoading = false;
  bool _isLoadingReports = false;
  bool _isLoadingDetail = false;
  String? _error;

  // Pagination & filters
  int _currentPage = 1;
  int _pageSize = 20;
  String _searchQuery = '';
  CommentStatus? _statusFilter;
  bool? _hasReportsFilter;
  String _sortBy = 'newest';

  int _reportsPage = 1;
  ReportStatus? _reportStatusFilter;

  // Getters
  List<AdminComment> get comments => _comments;
  int get totalCount => _totalCount;
  AdminCommentDetail? get selectedComment => _selectedComment;
  List<AdminReport> get reports => _reports;
  int get reportsCount => _reportsCount;
  AdminCommentsStats get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isLoadingReports => _isLoadingReports;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get error => _error;
  int get currentPage => _currentPage;
  String get searchQuery => _searchQuery;
  CommentStatus? get statusFilter => _statusFilter;
  bool? get hasReportsFilter => _hasReportsFilter;
  String get sortBy => _sortBy;
  int get reportsPage => _reportsPage;
  ReportStatus? get reportStatusFilter => _reportStatusFilter;

  Future<void> loadComments({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _client.getComments(
        page: _currentPage,
        pageSize: _pageSize,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        status: _statusFilter,
        hasReports: _hasReportsFilter,
        sortBy: _sortBy,
      );
      _comments = result['comments'] as List<AdminComment>;
      _totalCount = result['totalCount'] as int;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load comments: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCommentDetail(int commentId) async {
    _isLoadingDetail = true;
    _error = null;
    notifyListeners();

    try {
      _selectedComment = await _client.getCommentById(commentId);
      _isLoadingDetail = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load comment details: ${e.toString()}';
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> loadReports({bool refresh = false}) async {
    if (refresh) {
      _reportsPage = 1;
    }

    _isLoadingReports = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _client.getReports(
        page: _reportsPage,
        pageSize: _pageSize,
        status: _reportStatusFilter,
      );
      _reports = result['reports'] as List<AdminReport>;
      _reportsCount = result['totalCount'] as int;
      _isLoadingReports = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load reports: ${e.toString()}';
      _isLoadingReports = false;
      notifyListeners();
    }
  }

  Future<void> loadStats() async {
    try {
      _stats = await _client.getCommentsStats();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Failed to load stats: $e');
    }
  }

  Future<bool> updateCommentStatus(int commentId, CommentStatus status) async {
    try {
      final success = await _client.updateCommentStatus(commentId, status);
      if (success) {
        // Update local data
        final index = _comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          final old = _comments[index];
          _comments[index] = AdminComment(
            id: old.id,
            trackId: old.trackId,
            trackName: old.trackName,
            artistName: old.artistName,
            userId: old.userId,
            userName: old.userName,
            content: old.content,
            createdAt: old.createdAt,
            updatedAt: old.updatedAt,
            status: status,
            likesCount: old.likesCount,
            reportsCount: old.reportsCount,
            isReply: old.isReply,
          );
          notifyListeners();
        }
        // Reload stats
        loadStats();
      }
      return success;
    } catch (e) {
      _error = 'Failed to update comment status: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteComment(int commentId, {bool permanent = false}) async {
    try {
      final success = await _client.deleteComment(commentId, permanent: permanent);
      if (success) {
        _comments.removeWhere((c) => c.id == commentId);
        _totalCount--;
        notifyListeners();
        // Reload stats
        loadStats();
      }
      return success;
    } catch (e) {
      _error = 'Failed to delete comment: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> handleReport(
    int reportId, {
    required bool dismiss,
    bool deleteComment = false,
    bool rejectComment = false,
  }) async {
    try {
      final success = await _client.handleReport(
        reportId,
        dismiss: dismiss,
        deleteComment: deleteComment,
        rejectComment: rejectComment,
      );
      if (success) {
        // Update local report status
        final index = _reports.indexWhere((r) => r.id == reportId);
        if (index != -1) {
          final old = _reports[index];
          _reports[index] = AdminReport(
            id: old.id,
            commentId: old.commentId,
            commentContent: old.commentContent,
            commentUserId: old.commentUserId,
            commentUserName: old.commentUserName,
            trackName: old.trackName,
            reporterUserId: old.reporterUserId,
            reporterUserName: old.reporterUserName,
            reason: old.reason,
            details: old.details,
            createdAt: old.createdAt,
            status: dismiss ? ReportStatus.dismissed : ReportStatus.actionTaken,
          );
          notifyListeners();
        }
        // Reload stats
        loadStats();
      }
      return success;
    } catch (e) {
      _error = 'Failed to handle report: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadComments(refresh: true);
  }

  void setStatusFilter(CommentStatus? status) {
    _statusFilter = status;
    loadComments(refresh: true);
  }

  void setHasReportsFilter(bool? hasReports) {
    _hasReportsFilter = hasReports;
    loadComments(refresh: true);
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    loadComments(refresh: true);
  }

  void setReportStatusFilter(ReportStatus? status) {
    _reportStatusFilter = status;
    loadReports(refresh: true);
  }

  void nextPage() {
    _currentPage++;
    loadComments();
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      loadComments();
    }
  }

  void nextReportsPage() {
    _reportsPage++;
    loadReports();
  }

  void previousReportsPage() {
    if (_reportsPage > 1) {
      _reportsPage--;
      loadReports();
    }
  }

  void clearSelectedComment() {
    _selectedComment = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
