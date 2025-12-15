import 'package:flutter/foundation.dart';
import 'package:muzzfund_admin/models/admin_user.dart';
import 'package:muzzfund_admin/network/admin_client.dart';

class UsersProvider extends ChangeNotifier {
  final AdminClient _client = AdminClient();

  List<AdminUser> _users = [];
  AdminUser? _selectedUser;
  List<UserActivity> _userActivity = [];
  List<UserInvestment> _userInvestments = [];
  List<ListeningHistoryItem> _listeningHistory = [];

  bool _isLoading = false;
  bool _isLoadingDetail = false;
  String? _error;

  int _currentPage = 1;
  int _pageSize = 20;
  String _searchQuery = '';
  String? _statusFilter;
  String? _sortBy;
  bool _sortDescending = false;

  List<AdminUser> get users => _users;
  AdminUser? get selectedUser => _selectedUser;
  List<UserActivity> get userActivity => _userActivity;
  List<UserInvestment> get userInvestments => _userInvestments;
  List<ListeningHistoryItem> get listeningHistory => _listeningHistory;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get error => _error;
  int get currentPage => _currentPage;
  String get searchQuery => _searchQuery;

  Future<void> loadUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _client.getUsers(
        page: _currentPage,
        pageSize: _pageSize,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        status: _statusFilter,
        sortBy: _sortBy,
        sortDescending: _sortDescending,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load users: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserDetail(int userId) async {
    _isLoadingDetail = true;
    _error = null;
    notifyListeners();

    try {
      _selectedUser = await _client.getUserById(userId);

      // Load related data in parallel
      final results = await Future.wait([
        _client.getUserActivity(userId),
        _client.getUserInvestments(userId),
        _client.getUserListeningHistory(userId),
      ]);

      _userActivity = results[0] as List<UserActivity>;
      _userInvestments = results[1] as List<UserInvestment>;
      _listeningHistory = results[2] as List<ListeningHistoryItem>;

      _isLoadingDetail = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user details: ${e.toString()}';
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserStatus(int userId, bool isActive) async {
    try {
      final success = await _client.updateUserStatus(userId, isActive);
      if (success) {
        // Update local data
        final index = _users.indexWhere((u) => u.id == userId);
        if (index != -1) {
          _users[index] = AdminUser(
            id: _users[index].id,
            name: _users[index].name,
            email: _users[index].email,
            role: _users[index].role,
            created: _users[index].created,
            verifiedAt: _users[index].verifiedAt,
            isActive: isActive,
            totalPlays: _users[index].totalPlays,
            totalInvestments: _users[index].totalInvestments,
            artistsCount: _users[index].artistsCount,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = 'Failed to update user status: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      final success = await _client.deleteUser(userId);
      if (success) {
        _users.removeWhere((u) => u.id == userId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to delete user: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadUsers(refresh: true);
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    loadUsers(refresh: true);
  }

  void setSort(String? sortBy, bool descending) {
    _sortBy = sortBy;
    _sortDescending = descending;
    loadUsers(refresh: true);
  }

  void nextPage() {
    _currentPage++;
    loadUsers();
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      loadUsers();
    }
  }

  void clearSelectedUser() {
    _selectedUser = null;
    _userActivity = [];
    _userInvestments = [];
    _listeningHistory = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
