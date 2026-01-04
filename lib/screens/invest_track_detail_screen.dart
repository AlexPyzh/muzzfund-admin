import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:muzzfund_admin/providers/investments_provider.dart';
import 'package:muzzfund_admin/models/admin_investment.dart';
import 'package:muzzfund_admin/config/theme.dart';
import 'package:muzzfund_admin/widgets/loading_overlay.dart';

class InvestTrackDetailScreen extends StatefulWidget {
  final int trackId;

  const InvestTrackDetailScreen({super.key, required this.trackId});

  @override
  State<InvestTrackDetailScreen> createState() => _InvestTrackDetailScreenState();
}

class _InvestTrackDetailScreenState extends State<InvestTrackDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvestmentsProvider>().loadTrackDetail(widget.trackId);
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
    final detail = provider.trackDetail;

    return LoadingOverlay(
      isLoading: provider.isLoadingDetail,
      child: detail == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Track investment data not found'),
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

                  // Track Header Card
                  _buildHeaderCard(context, detail),
                  const SizedBox(height: 24),

                  // Investment Metrics Row
                  _buildMetricsRow(context, detail),
                  const SizedBox(height: 24),

                  // Progress Visualization
                  _buildInvestmentProgress(context, detail),
                  const SizedBox(height: 24),

                  // Tabs for Investors and Transactions
                  _buildTabSection(context, detail),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, TrackInvestmentDetail detail) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album Art
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[800],
                image: detail.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(detail.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: detail.imageUrl == null
                  ? const Icon(Icons.music_note, size: 64, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 24),
            // Track Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.trackName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: detail.artistId != null
                        ? () => context.go('/users/${detail.artistId}')
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          detail.artistName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AdminTheme.primaryColor,
                              ),
                        ),
                        if (detail.artistId != null) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.open_in_new,
                            size: 16,
                            color: AdminTheme.primaryColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        Icons.people,
                        '${detail.investorCount} investors',
                      ),
                      _buildInfoChip(
                        Icons.receipt_long,
                        '${detail.transactionCount} transactions',
                      ),
                      if (detail.firstInvestmentDate != null)
                        _buildInfoChip(
                          Icons.calendar_today,
                          'Since ${DateFormat('MMM dd, yyyy').format(detail.firstInvestmentDate!)}',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quick Actions
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => context.go('/tracks/${detail.trackId}'),
                        icon: const Icon(Icons.info_outline),
                        label: const Text('View Track Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Total Amount
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AdminTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Raised',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${NumberFormat('#,##0.00').format(detail.totalInvestmentAmount)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AdminTheme.successColor,
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

  Widget _buildMetricsRow(BuildContext context, TrackInvestmentDetail detail) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Percent Sold',
            '${detail.percentSold.toStringAsFixed(2)}%',
            Icons.pie_chart,
            AdminTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'Available',
            '${detail.percentAvailable.toStringAsFixed(2)}%',
            Icons.pie_chart_outline,
            AdminTheme.secondaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'For Sale',
            '${detail.percentForSale.toStringAsFixed(2)}%',
            Icons.sell,
            AdminTheme.warningColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'Avg per Investor',
            '\$${NumberFormat('#,##0.00').format(detail.investorCount > 0 ? detail.totalInvestmentAmount / detail.investorCount : 0)}',
            Icons.attach_money,
            AdminTheme.successColor,
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

  Widget _buildInvestmentProgress(BuildContext context, TrackInvestmentDetail detail) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Progress Bar
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: detail.percentSold / 100,
                          minHeight: 24,
                          backgroundColor: Colors.grey[700],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AdminTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${detail.percentSold.toStringAsFixed(1)}% sold',
                            style: TextStyle(color: AdminTheme.primaryColor),
                          ),
                          Text(
                            '${detail.percentAvailable.toStringAsFixed(1)}% available',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                // Pie Chart
                Expanded(
                  child: SizedBox(
                    height: 150,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: [
                          PieChartSectionData(
                            value: detail.percentSold,
                            color: AdminTheme.primaryColor,
                            title: 'Sold',
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                            radius: 40,
                          ),
                          PieChartSectionData(
                            value: detail.percentAvailable,
                            color: AdminTheme.secondaryColor,
                            title: 'Available',
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                            radius: 40,
                          ),
                          if ((100 - detail.percentForSale) > 0)
                            PieChartSectionData(
                              value: 100 - detail.percentForSale,
                              color: Colors.grey[600]!,
                              title: 'Reserved',
                              titleStyle: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                              radius: 40,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSection(BuildContext context, TrackInvestmentDetail detail) {
    return Card(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Investors (${detail.investors.length})'),
              Tab(text: 'Transactions (${detail.transactions.length})'),
            ],
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInvestorsTab(context, detail.investors),
                _buildTransactionsTab(context, detail.transactions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestorsTab(BuildContext context, List<TrackInvestor> investors) {
    if (investors.isEmpty) {
      return const Center(child: Text('No investors yet'));
    }

    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Investor')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Ownership'), numeric: true),
          DataColumn(label: Text('Invested'), numeric: true),
          DataColumn(label: Text('Transactions'), numeric: true),
          DataColumn(label: Text('First Investment')),
          DataColumn(label: Text('Actions')),
        ],
        rows: investors.map((investor) {
          return DataRow(
            cells: [
              DataCell(
                InkWell(
                  onTap: () => context.go('/invests/user/${investor.userId}'),
                  child: Text(
                    investor.userName,
                    style: TextStyle(color: AdminTheme.primaryColor),
                  ),
                ),
              ),
              DataCell(Text(investor.email ?? '-')),
              DataCell(Text('${investor.percentOwned.toStringAsFixed(2)}%')),
              DataCell(Text('\$${NumberFormat('#,##0.00').format(investor.totalInvested)}')),
              DataCell(Text(investor.transactionCount.toString())),
              DataCell(Text(DateFormat('MMM dd, yyyy').format(investor.firstInvestment))),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.open_in_new, size: 18),
                  onPressed: () => context.go('/users/${investor.userId}'),
                  tooltip: 'View user profile',
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
          DataColumn(label: Text('Investor')),
          DataColumn(label: Text('Percent'), numeric: true),
          DataColumn(label: Text('Amount'), numeric: true),
          DataColumn(label: Text('Status')),
        ],
        rows: transactions.map((tx) {
          return DataRow(
            cells: [
              DataCell(Text(DateFormat('MMM dd, yyyy HH:mm').format(tx.date))),
              DataCell(
                tx.userId != null
                    ? InkWell(
                        onTap: () => context.go('/invests/user/${tx.userId}'),
                        child: Text(
                          tx.userName ?? 'Unknown',
                          style: TextStyle(color: AdminTheme.primaryColor),
                        ),
                      )
                    : Text(tx.userName ?? 'Unknown'),
              ),
              DataCell(Text('${tx.percentPurchased.toStringAsFixed(2)}%')),
              DataCell(Text('\$${NumberFormat('#,##0.00').format(tx.amountPaid)}')),
              DataCell(_buildStatusChip(tx.status)),
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
