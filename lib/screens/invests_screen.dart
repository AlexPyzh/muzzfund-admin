import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:muzzfund_admin/providers/investments_provider.dart';
import 'package:muzzfund_admin/config/theme.dart';
import 'package:muzzfund_admin/widgets/stat_card.dart';
import 'package:muzzfund_admin/widgets/loading_overlay.dart';

class InvestsScreen extends StatefulWidget {
  const InvestsScreen({super.key});

  @override
  State<InvestsScreen> createState() => _InvestsScreenState();
}

class _InvestsScreenState extends State<InvestsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showActivityFeed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<InvestmentsProvider>();
      provider.loadAllData();
      provider.loadInvestments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvestmentsProvider>();

    return LoadingOverlay(
      isLoading: provider.isLoading,
      child: Row(
        children: [
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with controls
                  _buildHeader(provider),
                  const SizedBox(height: 24),

                  // Stats Cards Row
                  _buildStatsCards(provider),
                  const SizedBox(height: 24),

                  // Charts Row
                  _buildChartsRow(provider),
                  const SizedBox(height: 24),

                  // Rankings Row
                  _buildRankingsRow(provider),
                  const SizedBox(height: 24),

                  // Transactions Table
                  _buildTransactionsSection(provider),
                ],
              ),
            ),
          ),

          // Activity Feed Sidebar
          if (_showActivityFeed) _buildActivityFeedSidebar(provider),
        ],
      ),
    );
  }

  Widget _buildHeader(InvestmentsProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Dashboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (provider.lastUpdated != null)
              Text(
                'Last updated: ${DateFormat('HH:mm:ss').format(provider.lastUpdated!)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
        Row(
          children: [
            // Period selector
            _buildPeriodSelector(provider),
            const SizedBox(width: 16),
            // Auto-refresh toggle
            _buildAutoRefreshToggle(provider),
            const SizedBox(width: 8),
            // Manual refresh
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: provider.refresh,
              tooltip: 'Refresh data',
            ),
            const SizedBox(width: 8),
            // Activity feed toggle
            IconButton(
              icon: Icon(_showActivityFeed ? Icons.close : Icons.timeline),
              onPressed: () => setState(() => _showActivityFeed = !_showActivityFeed),
              tooltip: _showActivityFeed ? 'Hide activity feed' : 'Show activity feed',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(InvestmentsProvider provider) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: '7d', label: Text('7D')),
        ButtonSegment(value: '30d', label: Text('30D')),
        ButtonSegment(value: '90d', label: Text('90D')),
      ],
      selected: {provider.selectedPeriod},
      onSelectionChanged: (selection) {
        provider.setPeriod(selection.first);
      },
    );
  }

  Widget _buildAutoRefreshToggle(InvestmentsProvider provider) {
    return Row(
      children: [
        Icon(
          Icons.autorenew,
          size: 16,
          color: provider.autoRefreshEnabled ? AdminTheme.successColor : Colors.grey,
        ),
        const SizedBox(width: 4),
        Switch(
          value: provider.autoRefreshEnabled,
          onChanged: (_) => provider.toggleAutoRefresh(),
          activeColor: AdminTheme.successColor,
        ),
      ],
    );
  }

  Widget _buildStatsCards(InvestmentsProvider provider) {
    final overview = provider.overview;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        StatCard(
          title: 'Total Investments',
          value: NumberFormat.compact().format(overview.totalInvestments),
          subtitle: '+${overview.investmentsToday} today',
          icon: Icons.receipt_long,
          color: AdminTheme.primaryColor,
        ),
        StatCard(
          title: 'Total Volume',
          value: currencyFormat.format(overview.totalVolume),
          subtitle: '+${currencyFormat.format(overview.volumeToday)} today',
          icon: Icons.attach_money,
          color: AdminTheme.successColor,
        ),
        StatCard(
          title: 'Active Investors',
          value: NumberFormat.compact().format(overview.activeInvestors),
          subtitle: '+${overview.newInvestorsThisWeek} this week',
          icon: Icons.people,
          color: AdminTheme.secondaryColor,
        ),
        StatCard(
          title: 'Tracks Invested',
          value: '${overview.tracksWithInvestments}/${overview.totalTracks}',
          subtitle: '${overview.tracksPercentage.toStringAsFixed(1)}% of catalog',
          icon: Icons.music_note,
          color: AdminTheme.warningColor,
        ),
        StatCard(
          title: 'Avg Investment',
          value: currencyFormat.format(overview.averageInvestment),
          subtitle: 'per transaction',
          icon: Icons.analytics,
          color: Colors.purple,
        ),
        StatCard(
          title: 'Revenue Distributed',
          value: currencyFormat.format(overview.revenueDistributed),
          subtitle: '${currencyFormat.format(overview.lastMonthDistributed)} last month',
          icon: Icons.payments,
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildChartsRow(InvestmentsProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Volume Chart (2/3 width)
        Expanded(
          flex: 2,
          child: _buildVolumeChart(provider),
        ),
        const SizedBox(width: 24),
        // Distribution Chart (1/3 width)
        Expanded(
          child: _buildDistributionChart(provider),
        ),
      ],
    );
  }

  Widget _buildVolumeChart(InvestmentsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Volume Over Time',
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
                              reservedSize: 60,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '\$${NumberFormat.compact().format(value)}',
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
                              return FlSpot(e.key.toDouble(), e.value.totalAmount);
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

  Widget _buildDistributionChart(InvestmentsProvider provider) {
    final segments = provider.distribution.segments;
    final colors = [
      AdminTheme.successColor,
      AdminTheme.warningColor,
      AdminTheme.errorColor,
      AdminTheme.secondaryColor,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: segments.isEmpty
                  ? const Center(child: Text('No data available'))
                  : PieChart(
                      PieChartData(
                        sections: segments.asMap().entries.map((e) {
                          final segment = e.value;
                          final color = colors[e.key % colors.length];
                          return PieChartSectionData(
                            value: segment.percentage,
                            title: '${segment.percentage.toStringAsFixed(0)}%',
                            color: color,
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: segments.asMap().entries.map((e) {
                final segment = e.value;
                final color = colors[e.key % colors.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${segment.label} (${segment.count})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingsRow(InvestmentsProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildTopTracksCard(provider)),
        const SizedBox(width: 24),
        Expanded(child: _buildTopInvestorsCard(provider)),
      ],
    );
  }

  Widget _buildTopTracksCard(InvestmentsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Invested Tracks',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    // Could show a full list modal
                  },
                  child: const Text('View All'),
                ),
              ],
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
                        '${track.rank}',
                        style: TextStyle(
                          color: AdminTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: InkWell(
                      onTap: () => context.push('/invests/track/${track.trackId}'),
                      child: Text(
                        track.trackName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AdminTheme.primaryColor),
                      ),
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
                          '\$${NumberFormat.compact().format(track.totalInvestmentAmount)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${track.investorCount} investors',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  Widget _buildTopInvestorsCard(InvestmentsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Investors',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    // Could show a full list modal
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.topInvestors.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No data available')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.topInvestors.take(5).length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final investor = provider.topInvestors[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AdminTheme.secondaryColor.withOpacity(0.1),
                      child: Text(
                        '${investor.rank}',
                        style: TextStyle(
                          color: AdminTheme.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: InkWell(
                      onTap: () => context.push('/invests/user/${investor.userId}'),
                      child: Text(
                        investor.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AdminTheme.primaryColor),
                      ),
                    ),
                    subtitle: Text(
                      '${investor.uniqueTracksCount} tracks',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${NumberFormat.compact().format(investor.totalInvestmentAmount)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${investor.investmentCount} investments',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  Widget _buildTransactionsSection(InvestmentsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Transactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Search and Filters
            _buildFiltersBar(provider),
            const SizedBox(height: 16),

            // Error display
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
                    Icon(Icons.error_outline, color: AdminTheme.errorColor),
                    const SizedBox(width: 8),
                    Expanded(child: Text(provider.error!)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: provider.clearError,
                    ),
                  ],
                ),
              ),

            // Table
            _buildTransactionsTable(provider),

            // Pagination
            const SizedBox(height: 16),
            _buildPagination(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersBar(InvestmentsProvider provider) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Search
        SizedBox(
          width: 300,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search investor, track, artist...',
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
              isDense: true,
            ),
            onChanged: provider.setSearchQuery,
          ),
        ),

        // Status filter
        PopupMenuButton<String>(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.filter_list, size: 18),
                const SizedBox(width: 8),
                Text(provider.statusFilter ?? 'All Status'),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 18),
              ],
            ),
          ),
          itemBuilder: (_) => [
            const PopupMenuItem(value: '', child: Text('All Status')),
            const PopupMenuItem(value: 'Completed', child: Text('Completed')),
            const PopupMenuItem(value: 'Pending', child: Text('Pending')),
            const PopupMenuItem(value: 'Failed', child: Text('Failed')),
            const PopupMenuItem(value: 'Refunded', child: Text('Refunded')),
          ],
          onSelected: (value) => provider.setStatusFilter(value.isEmpty ? null : value),
        ),

        // Date range (simplified - could be a date picker)
        PopupMenuButton<String>(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.date_range, size: 18),
                SizedBox(width: 8),
                Text('Date Range'),
                SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, size: 18),
              ],
            ),
          ),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'all', child: Text('All Time')),
            const PopupMenuItem(value: '7d', child: Text('Last 7 Days')),
            const PopupMenuItem(value: '30d', child: Text('Last 30 Days')),
            const PopupMenuItem(value: '90d', child: Text('Last 90 Days')),
          ],
          onSelected: (value) {
            DateTime? start;
            if (value == '7d') {
              start = DateTime.now().subtract(const Duration(days: 7));
            } else if (value == '30d') {
              start = DateTime.now().subtract(const Duration(days: 30));
            } else if (value == '90d') {
              start = DateTime.now().subtract(const Duration(days: 90));
            }
            provider.setDateRange(start, null);
          },
        ),

        // Clear filters
        if (provider.searchQuery.isNotEmpty ||
            provider.statusFilter != null ||
            provider.startDate != null)
          TextButton.icon(
            onPressed: () {
              _searchController.clear();
              provider.clearFilters();
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear Filters'),
          ),

        const Spacer(),

        // Export button
        OutlinedButton.icon(
          onPressed: () => _showExportDialog(provider),
          icon: const Icon(Icons.download),
          label: const Text('Export'),
        ),
      ],
    );
  }

  Widget _buildTransactionsTable(InvestmentsProvider provider) {
    if (provider.isLoadingTable) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.investments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Text('No investments found'),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        horizontalMargin: 12,
        columns: [
          DataColumn(
            label: const Text('ID'),
            onSort: (_, __) => provider.setSort('id'),
          ),
          DataColumn(
            label: const Text('Date'),
            onSort: (_, __) => provider.setSort('date'),
          ),
          const DataColumn(label: Text('Investor')),
          const DataColumn(label: Text('Track')),
          const DataColumn(label: Text('Artist')),
          DataColumn(
            label: const Text('%'),
            numeric: true,
            onSort: (_, __) => provider.setSort('percent'),
          ),
          DataColumn(
            label: const Text('Amount'),
            numeric: true,
            onSort: (_, __) => provider.setSort('amount'),
          ),
          const DataColumn(label: Text('Status')),
        ],
        rows: provider.investments.map((investment) {
          return DataRow(
            cells: [
              DataCell(
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: investment.id.toString()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ID copied to clipboard')),
                    );
                  },
                  child: Text(
                    '#${investment.id}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              DataCell(Text(DateFormat('MM/dd/yy HH:mm').format(investment.createdAt))),
              DataCell(
                InkWell(
                  onTap: () => context.push('/invests/user/${investment.userId}'),
                  child: Text(
                    investment.userName,
                    style: TextStyle(color: AdminTheme.primaryColor),
                  ),
                ),
              ),
              DataCell(
                InkWell(
                  onTap: investment.trackId != null
                      ? () => context.push('/invests/track/${investment.trackId}')
                      : null,
                  child: Text(
                    investment.trackName,
                    style: TextStyle(
                      color: investment.trackId != null ? AdminTheme.primaryColor : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(Text(investment.artistName)),
              DataCell(Text(investment.formattedPercent)),
              DataCell(Text(investment.formattedAmount)),
              DataCell(_buildStatusChip(investment.status)),
            ],
          );
        }).toList(),
      ),
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
        color = Colors.grey;
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
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPagination(InvestmentsProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing ${provider.investments.length} of ${provider.totalCount} results',
          style: const TextStyle(color: Colors.grey),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: provider.currentPage > 1 ? provider.previousPage : null,
            ),
            Text('Page ${provider.currentPage} of ${provider.totalPages}'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: provider.currentPage < provider.totalPages ? provider.nextPage : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityFeedSidebar(InvestmentsProvider provider) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerTheme.color ?? Colors.grey,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: () => provider.loadRecentActivity(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: provider.recentActivity.isEmpty
                ? const Center(child: Text('No recent activity'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.recentActivity.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final activity = provider.recentActivity[index];
                      return ListTile(
                        dense: true,
                        title: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: activity.userName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AdminTheme.primaryColor,
                                ),
                              ),
                              const TextSpan(text: ' invested '),
                              TextSpan(
                                text: '${activity.percentPurchased.toStringAsFixed(2)}%',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: ' in '),
                              TextSpan(
                                text: activity.trackName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              '\$${activity.amountPaid.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: AdminTheme.successColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(' - '),
                            Text(
                              activity.timeAgo,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () => context.push('/invests/user/${activity.userId}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(InvestmentsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Investments'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV'),
              subtitle: const Text('Export as spreadsheet'),
              onTap: () async {
                Navigator.pop(context);
                final url = await provider.exportData(format: 'csv');
                if (mounted && url != null) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Export ready: $url')),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
