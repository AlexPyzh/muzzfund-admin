import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:muzzfund_admin/providers/statistics_provider.dart';
import 'package:muzzfund_admin/config/theme.dart';
import 'package:muzzfund_admin/widgets/stat_card.dart';
import 'package:muzzfund_admin/widgets/loading_overlay.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsProvider>().loadAllStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatisticsProvider>();

    return LoadingOverlay(
      isLoading: provider.isLoading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with period selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dashboard Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                _buildPeriodSelector(provider),
              ],
            ),
            const SizedBox(height: 24),

            // Stats Cards Row
            _buildStatsCards(provider),
            const SizedBox(height: 24),

            // Charts Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plays Chart
                Expanded(
                  flex: 2,
                  child: _buildPlaysChart(provider),
                ),
                const SizedBox(width: 24),
                // Top Tracks
                Expanded(
                  child: _buildTopTracksCard(provider),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // User Engagement Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildUserEngagementCard(provider)),
                const SizedBox(width: 24),
                Expanded(child: _buildExportCard(provider)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(StatisticsProvider provider) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: '24h', label: Text('24h')),
        ButtonSegment(value: '7d', label: Text('7 Days')),
        ButtonSegment(value: '30d', label: Text('30 Days')),
        ButtonSegment(value: '90d', label: Text('90 Days')),
      ],
      selected: {provider.selectedPeriod},
      onSelectionChanged: (selection) {
        provider.setPeriod(selection.first);
      },
    );
  }

  Widget _buildStatsCards(StatisticsProvider provider) {
    final overview = provider.overview;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        StatCard(
          title: 'Total Users',
          value: NumberFormat.compact().format(overview.totalUsers),
          subtitle: '+${overview.newUsersToday} today',
          icon: Icons.people,
          color: AdminTheme.primaryColor,
        ),
        StatCard(
          title: 'Active Users',
          value: NumberFormat.compact().format(overview.activeUsers),
          subtitle: '${((overview.activeUsers / (overview.totalUsers == 0 ? 1 : overview.totalUsers)) * 100).toStringAsFixed(1)}% of total',
          icon: Icons.person_outline,
          color: AdminTheme.successColor,
        ),
        StatCard(
          title: 'Total Tracks',
          value: NumberFormat.compact().format(overview.totalTracks),
          subtitle: '${overview.pendingTracks} pending',
          icon: Icons.music_note,
          color: AdminTheme.secondaryColor,
        ),
        StatCard(
          title: 'Total Plays',
          value: NumberFormat.compact().format(overview.totalPlays),
          subtitle: '${NumberFormat.compact().format(overview.playsToday)} today',
          icon: Icons.play_circle,
          color: AdminTheme.warningColor,
        ),
      ],
    );
  }

  Widget _buildPlaysChart(StatisticsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plays Over Time',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: provider.timeSeriesData.isEmpty
                  ? const Center(child: Text('No data available'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  NumberFormat.compact().format(value),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: (provider.timeSeriesData.length / 5).ceil().toDouble(),
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < provider.timeSeriesData.length) {
                                  return Text(
                                    DateFormat('MM/dd').format(
                                      provider.timeSeriesData[index].date,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: provider.timeSeriesData.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value.plays.toDouble());
                            }).toList(),
                            isCurved: true,
                            color: AdminTheme.primaryColor,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AdminTheme.primaryColor.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTracksCard(StatisticsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Tracks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (provider.topTracks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No data available')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.topTracks.take(5).length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final track = provider.topTracks[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AdminTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AdminTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      track.trackName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      track.artistName,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat.compact().format(track.totalPlays),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'plays',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserEngagementCard(StatisticsProvider provider) {
    final engagement = provider.userEngagement;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Engagement',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _buildEngagementRow('Daily Active Users', engagement.dailyActiveUsers.toString()),
            _buildEngagementRow('Weekly Active Users', engagement.weeklyActiveUsers.toString()),
            _buildEngagementRow('Monthly Active Users', engagement.monthlyActiveUsers.toString()),
            const Divider(),
            _buildEngagementRow('Avg Session Duration', '${engagement.averageSessionDuration.toStringAsFixed(1)} min'),
            _buildEngagementRow('Avg Tracks/Session', engagement.averageTracksPerSession.toStringAsFixed(1)),
            const Divider(),
            _buildEngagementRow('Total Likes', NumberFormat.compact().format(engagement.totalLikes)),
            _buildEngagementRow('Total Investors', engagement.totalInvestors.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildExportCard(StatisticsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Reports',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _buildExportButton(
              'User Report',
              'Export user statistics and activity data',
              Icons.people,
              () => _exportReport(provider, 'users'),
            ),
            const SizedBox(height: 12),
            _buildExportButton(
              'Tracks Report',
              'Export track performance and play data',
              Icons.music_note,
              () => _exportReport(provider, 'tracks'),
            ),
            const SizedBox(height: 12),
            _buildExportButton(
              'Full Report',
              'Export comprehensive platform analytics',
              Icons.analytics,
              () => _exportReport(provider, 'full'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.download),
        ],
      ),
    );
  }

  Future<void> _exportReport(StatisticsProvider provider, String reportType) async {
    // Show format selection dialog
    final format = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Export Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV'),
              onTap: () => Navigator.pop(context, 'csv'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              onTap: () => Navigator.pop(context, 'pdf'),
            ),
          ],
        ),
      ),
    );

    if (format != null) {
      final url = await provider.exportReport(
        format: format,
        reportType: reportType,
      );

      if (mounted) {
        if (url != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Report exported: $url')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to export report')),
          );
        }
      }
    }
  }
}
