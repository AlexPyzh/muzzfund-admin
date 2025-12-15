import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:muzzfund_admin/providers/users_provider.dart';
import 'package:muzzfund_admin/config/theme.dart';
import 'package:muzzfund_admin/widgets/loading_overlay.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersProvider>().loadUserDetail(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UsersProvider>();
    final user = provider.selectedUser;

    return LoadingOverlay(
      isLoading: provider.isLoadingDetail,
      child: user == null
          ? const Center(child: Text('User not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  TextButton.icon(
                    onPressed: () => context.go('/users'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Users'),
                  ),
                  const SizedBox(height: 16),

                  // User Header Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AdminTheme.primaryColor,
                            child: Text(
                              user.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      user.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildStatusChip(user.isActive),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user.email,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildInfoChip(Icons.badge, user.role),
                                    const SizedBox(width: 12),
                                    _buildInfoChip(
                                      Icons.calendar_today,
                                      'Joined ${DateFormat('MMM dd, yyyy').format(user.created)}',
                                    ),
                                    if (user.isVerified) ...[
                                      const SizedBox(width: 12),
                                      _buildInfoChip(
                                        Icons.verified,
                                        'Verified',
                                        color: AdminTheme.successColor,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Quick Stats
                          Column(
                            children: [
                              _buildQuickStat('Total Plays', user.totalPlays.toString()),
                              const SizedBox(height: 8),
                              _buildQuickStat('Investments', user.totalInvestments.toString()),
                              const SizedBox(height: 8),
                              _buildQuickStat('Artists', user.artistsCount.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tabs
                  Card(
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Listening History'),
                            Tab(text: 'Investments'),
                            Tab(text: 'Activity Log'),
                          ],
                        ),
                        SizedBox(
                          height: 400,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildListeningHistory(provider),
                              _buildInvestments(provider),
                              _buildActivityLog(provider),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AdminTheme.successColor.withOpacity(0.1)
            : AdminTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? AdminTheme.successColor : AdminTheme.errorColor,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color ?? Colors.grey)),
      ],
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildListeningHistory(UsersProvider provider) {
    if (provider.listeningHistory.isEmpty) {
      return const Center(child: Text('No listening history'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.listeningHistory.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = provider.listeningHistory[index];
        return ListTile(
          leading: const Icon(Icons.music_note),
          title: Text(item.trackName),
          subtitle: Text(item.artistName),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(DateFormat('MMM dd, HH:mm').format(item.playedAt)),
              Text(
                '${item.listenedSeconds}s ${item.completed ? '(completed)' : ''}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () => context.go('/tracks/${item.trackId}'),
        );
      },
    );
  }

  Widget _buildInvestments(UsersProvider provider) {
    if (provider.userInvestments.isEmpty) {
      return const Center(child: Text('No investments'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.userInvestments.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final investment = provider.userInvestments[index];
        return ListTile(
          leading: const Icon(Icons.attach_money),
          title: Text(investment.trackName),
          subtitle: Text(investment.artistName),
          trailing: Text(
            '${investment.boughtPercent.toStringAsFixed(2)}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AdminTheme.successColor,
            ),
          ),
          onTap: () => context.go('/tracks/${investment.trackId}'),
        );
      },
    );
  }

  Widget _buildActivityLog(UsersProvider provider) {
    if (provider.userActivity.isEmpty) {
      return const Center(child: Text('No activity recorded'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.userActivity.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final activity = provider.userActivity[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(activity.action),
          subtitle: Text(activity.details),
          trailing: Text(
            DateFormat('MMM dd, HH:mm').format(activity.timestamp),
            style: const TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }
}
