import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:muzzfund_admin/providers/users_provider.dart';
import 'package:muzzfund_admin/models/admin_user.dart';
import 'package:muzzfund_admin/config/theme.dart';
import 'package:muzzfund_admin/widgets/loading_overlay.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UsersProvider>();

    return LoadingOverlay(
      isLoading: provider.isLoading,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Users Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  children: [
                    // Search
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.setSearchQuery('');
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) => provider.setSearchQuery(value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Status filter
                    PopupMenuButton<String>(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.filter_list),
                            SizedBox(width: 8),
                            Text('Filter'),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: null, child: Text('All')),
                        const PopupMenuItem(value: 'active', child: Text('Active')),
                        const PopupMenuItem(value: 'inactive', child: Text('Inactive')),
                        const PopupMenuItem(value: 'verified', child: Text('Verified')),
                        const PopupMenuItem(value: 'unverified', child: Text('Unverified')),
                      ],
                      onSelected: provider.setStatusFilter,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Error message
            if (provider.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AdminTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: AdminTheme.errorColor),
                    const SizedBox(width: 8),
                    Expanded(child: Text(provider.error!)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: provider.clearError,
                    ),
                  ],
                ),
              ),

            // Data Table
            Expanded(
              child: Card(
                child: provider.users.isEmpty
                    ? const Center(child: Text('No users found'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: DataTable(
                              columnSpacing: 24,
                              horizontalMargin: 12,
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Role')),
                                DataColumn(label: Text('Created')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: provider.users.map((user) => _buildUserRow(user, provider)).toList(),
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            // Pagination
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: provider.currentPage > 1 ? provider.previousPage : null,
                ),
                Text('Page ${provider.currentPage}'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: provider.users.length >= 20 ? provider.nextPage : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildUserRow(AdminUser user, UsersProvider provider) {
    return DataRow(
      cells: [
        DataCell(Text('#${user.id}')),
        DataCell(
          InkWell(
            onTap: () => context.go('/users/${user.id}'),
            child: Text(
              user.name,
              style: TextStyle(
                color: AdminTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        DataCell(Text(user.email)),
        DataCell(_buildRoleChip(user.role)),
        DataCell(Text(DateFormat('MMM dd, yyyy').format(user.created))),
        DataCell(_buildStatusChip(user)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 20),
                onPressed: () => context.go('/users/${user.id}'),
                tooltip: 'View Details',
              ),
              IconButton(
                icon: Icon(
                  user.isActive ? Icons.block : Icons.check_circle,
                  size: 20,
                ),
                onPressed: () => _toggleUserStatus(user, provider),
                tooltip: user.isActive ? 'Deactivate' : 'Activate',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => _showDeleteDialog(user, provider),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleChip(String role) {
    Color color;
    switch (role.toLowerCase()) {
      case 'admin':
        color = AdminTheme.primaryColor;
        break;
      case 'artist':
        color = AdminTheme.secondaryColor;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  Widget _buildStatusChip(AdminUser user) {
    final isActive = user.isActive && user.isVerified;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AdminTheme.successColor.withOpacity(0.1)
            : AdminTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isActive ? 'Active' : (user.isVerified ? 'Inactive' : 'Unverified'),
        style: TextStyle(
          color: isActive ? AdminTheme.successColor : AdminTheme.errorColor,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _toggleUserStatus(AdminUser user, UsersProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.isActive ? 'Deactivate User' : 'Activate User'),
        content: Text(
          user.isActive
              ? 'Are you sure you want to deactivate ${user.name}?'
              : 'Are you sure you want to activate ${user.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.updateUserStatus(user.id, !user.isActive);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User ${user.isActive ? 'deactivated' : 'activated'} successfully'),
          ),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(AdminUser user, UsersProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.deleteUser(user.id);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      }
    }
  }
}
