import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:muzzfund_admin/providers/auth_provider.dart';
import 'package:muzzfund_admin/config/theme.dart';

class DashboardShell extends StatefulWidget {
  final Widget child;

  const DashboardShell({super.key, required this.child});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.dashboard,
      label: 'Statistics',
      path: '/statistics',
    ),
    _NavItem(
      icon: Icons.people,
      label: 'Users',
      path: '/users',
    ),
    _NavItem(
      icon: Icons.music_note,
      label: 'Tracks',
      path: '/tracks',
    ),
    _NavItem(
      icon: Icons.comment,
      label: 'Comments',
      path: '/comments',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].path)) {
        if (_selectedIndex != i) {
          setState(() => _selectedIndex = i);
        }
        break;
      }
    }
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
    context.go(_navItems[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AdminAuthProvider>();
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail / Sidebar
          Container(
            width: isWideScreen ? 240 : 80,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerTheme.color ?? Colors.grey,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Logo
                Container(
                  height: 80,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment:
                        isWideScreen ? MainAxisAlignment.start : MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        color: AdminTheme.primaryColor,
                        size: 32,
                      ),
                      if (isWideScreen) ...[
                        const SizedBox(width: 12),
                        const Text(
                          'MuzzFund',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _navItems.length,
                    itemBuilder: (context, index) {
                      final item = _navItems[index];
                      final isSelected = _selectedIndex == index;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: Material(
                          color: isSelected
                              ? AdminTheme.primaryColor.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () => _onNavItemTapped(index),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 48,
                              padding: EdgeInsets.symmetric(
                                horizontal: isWideScreen ? 16 : 0,
                              ),
                              child: Row(
                                mainAxisAlignment: isWideScreen
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    item.icon,
                                    color: isSelected
                                        ? AdminTheme.primaryColor
                                        : Colors.grey,
                                  ),
                                  if (isWideScreen) ...[
                                    const SizedBox(width: 12),
                                    Text(
                                      item.label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AdminTheme.primaryColor
                                            : Colors.grey,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // User Profile / Logout
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: isWideScreen
                      ? ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AdminTheme.primaryColor,
                            child: Text(
                              (authProvider.username ?? 'A')[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(authProvider.username ?? 'Admin'),
                          subtitle: Text(authProvider.role ?? 'Administrator'),
                          trailing: IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: () => _showLogoutDialog(context),
                            tooltip: 'Logout',
                          ),
                        )
                      : Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: AdminTheme.primaryColor,
                              child: Text(
                                (authProvider.username ?? 'A')[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 8),
                            IconButton(
                              icon: const Icon(Icons.logout),
                              onPressed: () => _showLogoutDialog(context),
                              tooltip: 'Logout',
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Breadcrumb / Header
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerTheme.color ?? Colors.grey,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Breadcrumb
                      _buildBreadcrumb(context),
                      const Spacer(),
                      // Quick actions
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          // Trigger refresh based on current page
                        },
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                ),

                // Page Content
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final segments = location.split('/').where((s) => s.isNotEmpty).toList();

    return Row(
      children: [
        for (int i = 0; i < segments.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            ),
          Text(
            _formatBreadcrumb(segments[i]),
            style: TextStyle(
              color: i == segments.length - 1 ? Colors.white : Colors.grey,
              fontWeight: i == segments.length - 1 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ],
    );
  }

  String _formatBreadcrumb(String segment) {
    // Capitalize first letter
    if (segment.isEmpty) return segment;
    return segment[0].toUpperCase() + segment.substring(1);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminAuthProvider>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;

  _NavItem({
    required this.icon,
    required this.label,
    required this.path,
  });
}
