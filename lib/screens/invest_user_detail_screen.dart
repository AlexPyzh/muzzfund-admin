import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:muzzfund_admin/providers/investments_provider.dart';
import 'package:muzzfund_admin/models/admin_investment.dart';
import 'package:muzzfund_admin/config/theme.dart';
import 'package:muzzfund_admin/widgets/loading_overlay.dart';

class InvestUserDetailScreen extends StatefulWidget {
  final int userId;

  const InvestUserDetailScreen({super.key, required this.userId});

  @override
  State<InvestUserDetailScreen> createState() => _InvestUserDetailScreenState();
}

class _InvestUserDetailScreenState extends State<InvestUserDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvestmentsProvider>().loadUserPortfolio(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvestmentsProvider>();
    final portfolio = provider.userPortfolio;

    return LoadingOverlay(
      isLoading: provider.isLoadingDetail,
      child: portfolio == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('User investment portfolio not found'),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => context.go('/invests'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Invests'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  TextButton.icon(
                    onPressed: () => context.go('/invests'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Invests'),
                  ),
                  const SizedBox(height: 16),

                  // User Header Card
                  _buildHeaderCard(context, portfolio),
                  const SizedBox(height: 24),

                  // Portfolio Metrics Row
                  _buildMetricsRow(context, portfolio),
                  const SizedBox(height: 24),

                  // Portfolio Distribution
                  _buildPortfolioDistribution(context, portfolio),
                  const SizedBox(height: 24),

                  // Tabs for Track Investments and Transactions
                  _buildTabSection(context, portfolio),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, UserInvestmentPortfolio portfolio) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AdminTheme.primaryColor,
              child: Text(
                portfolio.userName.isNotEmpty
                    ? portfolio.userName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 24),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    portfolio.userName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (portfolio.email != null)
                    Text(
                      portfolio.email!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        Icons.music_note,
                        '${portfolio.uniqueTracksCount} tracks',
                      ),
                      _buildInfoChip(
                        Icons.receipt_long,
                        '${portfolio.investmentCount} investments',
                      ),
                      if (portfolio.firstInvestmentDate != null)
                        _buildInfoChip(
                          Icons.calendar_today,
                          'Since ${DateFormat('MMM dd, yyyy').format(portfolio.firstInvestmentDate!)}',
                        ),
                      if (portfolio.lastInvestmentDate != null)
                        _buildInfoChip(
                          Icons.update,
                          'Last: ${DateFormat('MMM dd, yyyy').format(portfolio.lastInvestmentDate!)}',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quick Actions
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => context.go('/users/${portfolio.userId}'),
                        icon: const Icon(Icons.person),
                        label: const Text('View User Profile'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Total Invested Stats
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AdminTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Invested',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${NumberFormat('#,##0.00').format(portfolio.totalInvested)}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AdminTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context, UserInvestmentPortfolio portfolio) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Total Invested',
            '\$${NumberFormat('#,##0.00').format(portfolio.totalInvested)}',
            Icons.attach_money,
            AdminTheme.successColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'Total Ownership',
            '${portfolio.totalPercent.toStringAsFixed(2)}%',
            Icons.pie_chart,
            AdminTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'Unique Tracks',
            portfolio.uniqueTracksCount.toString(),
            Icons.music_note,
            AdminTheme.secondaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'Avg per Track',
            '\$${NumberFormat('#,##0.00').format(portfolio.uniqueTracksCount > 0 ? portfolio.totalInvested / portfolio.uniqueTracksCount : 0)}',
            Icons.analytics,
            AdminTheme.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
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

  Widget _buildPortfolioDistribution(
      BuildContext context, UserInvestmentPortfolio portfolio) {
    if (portfolio.trackInvestments.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate distribution for pie chart
    final total = portfolio.trackInvestments.fold<double>(
      0,
      (sum, t) => sum + t.totalInvested,
    );

    final colors = [
      AdminTheme.primaryColor,
      AdminTheme.secondaryColor,
      AdminTheme.successColor,
      AdminTheme.warningColor,
      Colors.purple,
      Colors.pink,
      Colors.indigo,
      Colors.teal,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Pie Chart
                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        sections: portfolio.trackInvestments
                            .asMap()
                            .entries
                            .take(8)
                            .map((entry) {
                          final idx = entry.key;
                          final track = entry.value;
                          final percentage =
                              total > 0 ? (track.totalInvested / total * 100) : 0.0;
                          return PieChartSectionData(
                            value: track.totalInvested,
                            color: colors[idx % colors.length],
                            title: percentage >= 10
                                ? '${percentage.toStringAsFixed(0)}%'
                                : '',
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            radius: 50,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                // Legend
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: portfolio.trackInvestments
                        .asMap()
                        .entries
                        .take(8)
                        .map((entry) {
                      final idx = entry.key;
                      final track = entry.value;
                      final percentage =
                          total > 0 ? (track.totalInvested / total * 100) : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors[idx % colors.length],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                track.trackName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSection(BuildContext context, UserInvestmentPortfolio portfolio) {
    return Card(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Track Holdings (${portfolio.trackInvestments.length})'),
              Tab(text: 'Transactions (${portfolio.transactions.length})'),
            ],
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTrackHoldingsTab(context, portfolio.trackInvestments),
                _buildTransactionsTab(context, portfolio.transactions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackHoldingsTab(
      BuildContext context, List<UserTrackInvestment> tracks) {
    if (tracks.isEmpty) {
      return const Center(child: Text('No track investments yet'));
    }

    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Track')),
          DataColumn(label: Text('Artist')),
          DataColumn(label: Text('Ownership'), numeric: true),
          DataColumn(label: Text('Invested'), numeric: true),
          DataColumn(label: Text('Transactions'), numeric: true),
          DataColumn(label: Text('Last Investment')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: tracks.map((track) {
          return DataRow(
            cells: [
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (track.imageUrl != null)
                      Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          image: DecorationImage(
                            image: NetworkImage(track.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Flexible(
                      child: InkWell(
                        onTap: () => context.go('/invests/track/${track.trackId}'),
                        child: Text(
                          track.trackName,
                          style: TextStyle(color: AdminTheme.primaryColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(Text(track.artistName)),
              DataCell(Text('${track.percentOwned.toStringAsFixed(2)}%')),
              DataCell(Text('\$${NumberFormat('#,##0.00').format(track.totalInvested)}')),
              DataCell(Text(track.transactionCount.toString())),
              DataCell(Text(DateFormat('MMM dd, yyyy').format(track.lastInvestment))),
              DataCell(_buildStatusChip(track.lastStatus)),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.open_in_new, size: 18),
                  onPressed: () => context.go('/tracks/${track.trackId}'),
                  tooltip: 'View track details',
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionsTab(
      BuildContext context, List<InvestmentTransaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions yet'));
    }

    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Track')),
          DataColumn(label: Text('Artist')),
          DataColumn(label: Text('Percent'), numeric: true),
          DataColumn(label: Text('Amount'), numeric: true),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: transactions.map((tx) {
          return DataRow(
            cells: [
              DataCell(Text(DateFormat('MMM dd, yyyy HH:mm').format(tx.date))),
              DataCell(
                tx.trackId != null
                    ? InkWell(
                        onTap: () => context.go('/invests/track/${tx.trackId}'),
                        child: Text(
                          tx.trackName ?? 'Unknown',
                          style: TextStyle(color: AdminTheme.primaryColor),
                        ),
                      )
                    : Text(tx.trackName ?? 'Unknown'),
              ),
              DataCell(Text(tx.artistName ?? '-')),
              DataCell(Text('${tx.percentPurchased.toStringAsFixed(2)}%')),
              DataCell(Text('\$${NumberFormat('#,##0.00').format(tx.amountPaid)}')),
              DataCell(_buildStatusChip(tx.status)),
              DataCell(
                tx.trackId != null
                    ? IconButton(
                        icon: const Icon(Icons.open_in_new, size: 18),
                        onPressed: () => context.go('/tracks/${tx.trackId}'),
                        tooltip: 'View track',
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = AdminTheme.successColor;
        break;
      case 'pending':
        color = AdminTheme.warningColor;
        break;
      case 'failed':
        color = AdminTheme.errorColor;
        break;
      case 'refunded':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}
