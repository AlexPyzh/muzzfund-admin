import 'package:flutter/foundation.dart';
import 'package:muzzfund_admin/models/admin_track.dart';
import 'package:muzzfund_admin/network/admin_client.dart';

class TracksProvider extends ChangeNotifier {
  final AdminClient _client = AdminClient();

  List<AdminTrack> _tracks = [];
  AdminTrack? _selectedTrack;
  Set<int> _selectedTrackIds = {};

  bool _isLoading = false;
  bool _isLoadingDetail = false;
  String? _error;

  int _currentPage = 1;
  int _pageSize = 20;
  String _searchQuery = '';
  TrackApprovalStatus? _statusFilter;
  String? _sortBy;
  bool _sortDescending = false;
  bool _includePending = true;
  bool _includeDeleted = false;

  List<AdminTrack> get tracks => _tracks;
  AdminTrack? get selectedTrack => _selectedTrack;
  Set<int> get selectedTrackIds => _selectedTrackIds;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get error => _error;
  int get currentPage => _currentPage;
  String get searchQuery => _searchQuery;
  TrackApprovalStatus? get statusFilter => _statusFilter;
  bool get hasSelection => _selectedTrackIds.isNotEmpty;
  int get selectionCount => _selectedTrackIds.length;

  Future<void> loadTracks({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tracks = await _client.getTracks(
        page: _currentPage,
        pageSize: _pageSize,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        status: _statusFilter,
        sortBy: _sortBy,
        sortDescending: _sortDescending,
        includePending: _includePending,
        includeDeleted: _includeDeleted,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load tracks: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTrackDetail(int trackId) async {
    _isLoadingDetail = true;
    _error = null;
    notifyListeners();

    try {
      _selectedTrack = await _client.getTrackById(trackId);
      _isLoadingDetail = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load track details: ${e.toString()}';
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<bool> approveTrack(int trackId) async {
    try {
      final success = await _client.approveTrack(trackId);
      if (success) {
        _updateTrackStatus(trackId, TrackApprovalStatus.approved);
      }
      return success;
    } catch (e) {
      _error = 'Failed to approve track: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectTrack(int trackId, {String? reason}) async {
    try {
      final success = await _client.rejectTrack(trackId, reason: reason);
      if (success) {
        _updateTrackStatus(trackId, TrackApprovalStatus.rejected);
      }
      return success;
    } catch (e) {
      _error = 'Failed to reject track: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> setTrackFeatured(int trackId, bool featured) async {
    try {
      final success = await _client.setTrackFeatured(trackId, featured);
      if (success) {
        final index = _tracks.indexWhere((t) => t.id == trackId);
        if (index != -1) {
          _tracks[index] = _tracks[index].copyWith(featured: featured);
          notifyListeners();
        }
        if (_selectedTrack?.id == trackId) {
          _selectedTrack = _selectedTrack!.copyWith(featured: featured);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = 'Failed to update featured status: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTrack(int trackId) async {
    try {
      final success = await _client.deleteTrack(trackId);
      if (success) {
        _tracks.removeWhere((t) => t.id == trackId);
        _selectedTrackIds.remove(trackId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to delete track: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTrack(AdminTrack track) async {
    try {
      final success = await _client.updateTrack(track);
      if (success) {
        final index = _tracks.indexWhere((t) => t.id == track.id);
        if (index != -1) {
          _tracks[index] = track;
        }
        if (_selectedTrack?.id == track.id) {
          _selectedTrack = track;
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to update track: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<int> bulkApprove() async {
    if (_selectedTrackIds.isEmpty) return 0;

    int successCount = 0;
    for (final id in _selectedTrackIds.toList()) {
      if (await approveTrack(id)) {
        successCount++;
      }
    }
    _selectedTrackIds.clear();
    notifyListeners();
    return successCount;
  }

  Future<int> bulkReject({String? reason}) async {
    if (_selectedTrackIds.isEmpty) return 0;

    int successCount = 0;
    for (final id in _selectedTrackIds.toList()) {
      if (await rejectTrack(id, reason: reason)) {
        successCount++;
      }
    }
    _selectedTrackIds.clear();
    notifyListeners();
    return successCount;
  }

  Future<int> bulkDelete() async {
    if (_selectedTrackIds.isEmpty) return 0;

    int successCount = 0;
    for (final id in _selectedTrackIds.toList()) {
      if (await deleteTrack(id)) {
        successCount++;
      }
    }
    _selectedTrackIds.clear();
    notifyListeners();
    return successCount;
  }

  void _updateTrackStatus(int trackId, TrackApprovalStatus status) {
    final index = _tracks.indexWhere((t) => t.id == trackId);
    if (index != -1) {
      _tracks[index] = _tracks[index].copyWith(approvalStatus: status);
      notifyListeners();
    }
    if (_selectedTrack?.id == trackId) {
      _selectedTrack = _selectedTrack!.copyWith(approvalStatus: status);
      notifyListeners();
    }
  }

  void toggleTrackSelection(int trackId) {
    if (_selectedTrackIds.contains(trackId)) {
      _selectedTrackIds.remove(trackId);
    } else {
      _selectedTrackIds.add(trackId);
    }
    notifyListeners();
  }

  void selectAllTracks() {
    _selectedTrackIds = _tracks.map((t) => t.id).toSet();
    notifyListeners();
  }

  void clearSelection() {
    _selectedTrackIds.clear();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadTracks(refresh: true);
  }

  void setStatusFilter(TrackApprovalStatus? status) {
    _statusFilter = status;
    loadTracks(refresh: true);
  }

  void setSort(String? sortBy, bool descending) {
    _sortBy = sortBy;
    _sortDescending = descending;
    loadTracks(refresh: true);
  }

  void setIncludePending(bool include) {
    _includePending = include;
    loadTracks(refresh: true);
  }

  void setIncludeDeleted(bool include) {
    _includeDeleted = include;
    loadTracks(refresh: true);
  }

  void nextPage() {
    _currentPage++;
    loadTracks();
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      loadTracks();
    }
  }

  void clearSelectedTrack() {
    _selectedTrack = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
