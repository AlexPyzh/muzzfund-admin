import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:muzzfund_admin/providers/comments_provider.dart';
import 'package:muzzfund_admin/models/admin_comment.dart';
import 'package:muzzfund_admin/config/theme.dart';
import 'package:muzzfund_admin/widgets/loading_overlay.dart';
import 'package:muzzfund_admin/widgets/stat_card.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CommentsProvider>();
      provider.loadComments();
      provider.loadReports();
      provider.loadStats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommentsProvider>();

    return LoadingOverlay(
      isLoading: provider.isLoading || provider.isLoadingReports,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Comments Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Stats cards
            _buildStatsRow(provider.stats),
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

            // Tabs
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.comment),
                      const SizedBox(width: 8),
                      Text('All Comments (${provider.totalCount})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flag),
                      const SizedBox(width: 8),
                      Text('Reports (${provider.stats.pendingReports})'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCommentsTab(provider),
                  _buildReportsTab(provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(AdminCommentsStats stats) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total Comments',
            value: stats.totalComments.toString(),
            icon: Icons.comment,
            color: AdminTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Pending',
            value: stats.pendingComments.toString(),
            icon: Icons.pending,
            color: AdminTheme.warningColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Pending Reports',
            value: stats.pendingReports.toString(),
            icon: Icons.flag,
            color: AdminTheme.errorColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Today',
            value: stats.commentsToday.toString(),
            icon: Icons.today,
            color: AdminTheme.successColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsTab(CommentsProvider provider) {
    return Column(
      children: [
        // Filters
        Row(
          children: [
            // Search
            Expanded(
              flex: 2,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search comments...',
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
            _buildStatusFilter(provider),
            const SizedBox(width: 16),
            // Has reports filter
            _buildHasReportsFilter(provider),
            const SizedBox(width: 16),
            // Sort
            _buildSortDropdown(provider),
          ],
        ),
        const SizedBox(height: 16),

        // Comments table
        Expanded(
          child: Card(
            child: provider.comments.isEmpty
                ? const Center(child: Text('No comments found'))
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
                            DataColumn(label: Text('User')),
                            DataColumn(label: Text('Content')),
                            DataColumn(label: Text('Track')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Reports')),
                            DataColumn(label: Text('Likes')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: provider.comments
                              .map((c) => _buildCommentRow(c, provider))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
          ),
        ),

        // Pagination
        const SizedBox(height: 16),
        _buildPagination(
          currentPage: provider.currentPage,
          hasMore: provider.comments.length >= 20,
          onPrevious: provider.previousPage,
          onNext: provider.nextPage,
        ),
      ],
    );
  }

  Widget _buildReportsTab(CommentsProvider provider) {
    return Column(
      children: [
        // Filters
        Row(
          children: [
            const Spacer(),
            _buildReportStatusFilter(provider),
          ],
        ),
        const SizedBox(height: 16),

        // Reports table
        Expanded(
          child: Card(
            child: provider.reports.isEmpty
                ? const Center(child: Text('No reports found'))
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
                            DataColumn(label: Text('Comment')),
                            DataColumn(label: Text('Author')),
                            DataColumn(label: Text('Reported By')),
                            DataColumn(label: Text('Reason')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: provider.reports
                              .map((r) => _buildReportRow(r, provider))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
          ),
        ),

        // Pagination
        const SizedBox(height: 16),
        _buildPagination(
          currentPage: provider.reportsPage,
          hasMore: provider.reports.length >= 20,
          onPrevious: provider.previousReportsPage,
          onNext: provider.nextReportsPage,
        ),
      ],
    );
  }

  Widget _buildStatusFilter(CommentsProvider provider) {
    return PopupMenuButton<CommentStatus?>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_list),
            const SizedBox(width: 8),
            Text(provider.statusFilter != null
                ? _getStatusLabel(provider.statusFilter!)
                : 'All Status'),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: null, child: Text('All Status')),
        const PopupMenuItem(
            value: CommentStatus.pending, child: Text('Pending')),
        const PopupMenuItem(
            value: CommentStatus.approved, child: Text('Approved')),
        const PopupMenuItem(
            value: CommentStatus.rejected, child: Text('Rejected')),
        const PopupMenuItem(
            value: CommentStatus.autoApproved, child: Text('Auto-Approved')),
      ],
      onSelected: provider.setStatusFilter,
    );
  }

  Widget _buildHasReportsFilter(CommentsProvider provider) {
    return PopupMenuButton<bool?>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.flag),
            const SizedBox(width: 8),
            Text(provider.hasReportsFilter == true ? 'Reported' : 'All'),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: null, child: Text('All Comments')),
        const PopupMenuItem(value: true, child: Text('Has Reports')),
      ],
      onSelected: provider.setHasReportsFilter,
    );
  }

  Widget _buildSortDropdown(CommentsProvider provider) {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.sort),
            const SizedBox(width: 8),
            Text(_getSortLabel(provider.sortBy)),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'newest', child: Text('Newest')),
        const PopupMenuItem(value: 'oldest', child: Text('Oldest')),
        const PopupMenuItem(value: 'mostreported', child: Text('Most Reported')),
        const PopupMenuItem(value: 'mostliked', child: Text('Most Liked')),
      ],
      onSelected: provider.setSortBy,
    );
  }

  Widget _buildReportStatusFilter(CommentsProvider provider) {
    return PopupMenuButton<ReportStatus?>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_list),
            const SizedBox(width: 8),
            Text(provider.reportStatusFilter != null
                ? _getReportStatusLabel(provider.reportStatusFilter!)
                : 'All Reports'),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: null, child: Text('All Reports')),
        const PopupMenuItem(
            value: ReportStatus.pending, child: Text('Pending')),
        const PopupMenuItem(
            value: ReportStatus.dismissed, child: Text('Dismissed')),
        const PopupMenuItem(
            value: ReportStatus.actionTaken, child: Text('Action Taken')),
      ],
      onSelected: provider.setReportStatusFilter,
    );
  }

  DataRow _buildCommentRow(AdminComment comment, CommentsProvider provider) {
    return DataRow(
      cells: [
        DataCell(Text('#${comment.id}')),
        DataCell(Text(comment.userName ?? 'Unknown')),
        DataCell(
          SizedBox(
            width: 200,
            child: Text(
              comment.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  comment.trackName ?? 'Unknown',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (comment.artistName != null)
                  Text(
                    comment.artistName!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
        DataCell(_buildStatusChip(comment.status)),
        DataCell(
          comment.reportsCount > 0
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AdminTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${comment.reportsCount}',
                    style: TextStyle(color: AdminTheme.errorColor),
                  ),
                )
              : const Text('0'),
        ),
        DataCell(Text('${comment.likesCount}')),
        DataCell(Text(DateFormat('MMM dd, yyyy').format(comment.createdAt))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (comment.status == CommentStatus.pending) ...[
                IconButton(
                  icon: const Icon(Icons.check_circle, size: 20),
                  color: AdminTheme.successColor,
                  onPressed: () => _approveComment(comment.id, provider),
                  tooltip: 'Approve',
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, size: 20),
                  color: AdminTheme.errorColor,
                  onPressed: () => _rejectComment(comment.id, provider),
                  tooltip: 'Reject',
                ),
              ],
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => _showDeleteCommentDialog(comment, provider),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildReportRow(AdminReport report, CommentsProvider provider) {
    return DataRow(
      cells: [
        DataCell(Text('#${report.id}')),
        DataCell(
          SizedBox(
            width: 200,
            child: Text(
              report.commentContent ?? '[Deleted]',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(report.commentUserName ?? 'Unknown')),
        DataCell(Text(report.reporterUserName ?? 'Unknown')),
        DataCell(_buildReasonChip(report.reason)),
        DataCell(_buildReportStatusChip(report.status)),
        DataCell(Text(DateFormat('MMM dd, yyyy').format(report.createdAt))),
        DataCell(
          report.status == ReportStatus.pending
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => _dismissReport(report.id, provider),
                      tooltip: 'Dismiss',
                    ),
                    IconButton(
                      icon: const Icon(Icons.gavel, size: 20),
                      color: AdminTheme.errorColor,
                      onPressed: () =>
                          _showHandleReportDialog(report, provider),
                      tooltip: 'Take Action',
                    ),
                  ],
                )
              : const Text('-'),
        ),
      ],
    );
  }

  Widget _buildStatusChip(CommentStatus status) {
    Color color;
    String label;
    switch (status) {
      case CommentStatus.pending:
        color = AdminTheme.warningColor;
        label = 'Pending';
        break;
      case CommentStatus.approved:
        color = AdminTheme.successColor;
        label = 'Approved';
        break;
      case CommentStatus.rejected:
        color = AdminTheme.errorColor;
        label = 'Rejected';
        break;
      case CommentStatus.autoApproved:
        color = AdminTheme.secondaryColor;
        label = 'Auto';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Widget _buildReasonChip(ReportReason reason) {
    final labels = {
      ReportReason.spam: 'Spam',
      ReportReason.harassment: 'Harassment',
      ReportReason.hateSpeech: 'Hate Speech',
      ReportReason.violence: 'Violence',
      ReportReason.misinformation: 'Misinfo',
      ReportReason.copyright: 'Copyright',
      ReportReason.other: 'Other',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(labels[reason] ?? 'Unknown', style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildReportStatusChip(ReportStatus status) {
    Color color;
    String label;
    switch (status) {
      case ReportStatus.pending:
        color = AdminTheme.warningColor;
        label = 'Pending';
        break;
      case ReportStatus.dismissed:
        color = Colors.grey;
        label = 'Dismissed';
        break;
      case ReportStatus.actionTaken:
        color = AdminTheme.successColor;
        label = 'Resolved';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Widget _buildPagination({
    required int currentPage,
    required bool hasMore,
    required VoidCallback onPrevious,
    required VoidCallback onNext,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1 ? onPrevious : null,
        ),
        Text('Page $currentPage'),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: hasMore ? onNext : null,
        ),
      ],
    );
  }

  String _getStatusLabel(CommentStatus status) {
    switch (status) {
      case CommentStatus.pending:
        return 'Pending';
      case CommentStatus.approved:
        return 'Approved';
      case CommentStatus.rejected:
        return 'Rejected';
      case CommentStatus.autoApproved:
        return 'Auto-Approved';
    }
  }

  String _getReportStatusLabel(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.dismissed:
        return 'Dismissed';
      case ReportStatus.actionTaken:
        return 'Action Taken';
    }
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'newest':
        return 'Newest';
      case 'oldest':
        return 'Oldest';
      case 'mostreported':
        return 'Most Reported';
      case 'mostliked':
        return 'Most Liked';
      default:
        return 'Newest';
    }
  }

  Future<void> _approveComment(int id, CommentsProvider provider) async {
    final success =
        await provider.updateCommentStatus(id, CommentStatus.approved);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment approved')),
      );
    }
  }

  Future<void> _rejectComment(int id, CommentsProvider provider) async {
    final success =
        await provider.updateCommentStatus(id, CommentStatus.rejected);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment rejected')),
      );
    }
  }

  Future<void> _showDeleteCommentDialog(
      AdminComment comment, CommentsProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this comment?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                comment.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
      final success = await provider.deleteComment(comment.id);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted')),
        );
      }
    }
  }

  Future<void> _dismissReport(int reportId, CommentsProvider provider) async {
    final success = await provider.handleReport(reportId, dismiss: true);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report dismissed')),
      );
    }
  }

  Future<void> _showHandleReportDialog(
      AdminReport report, CommentsProvider provider) async {
    String? action;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Handle Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Report reason: ${_getReasonLabel(report.reason)}'),
              if (report.details != null && report.details!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Details: ${report.details}'),
              ],
              const SizedBox(height: 16),
              const Text('Comment:'),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.commentContent ?? '[Deleted]',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Action:'),
              RadioListTile<String>(
                title: const Text('Reject comment'),
                value: 'reject',
                groupValue: action,
                onChanged: (v) => setState(() => action = v),
              ),
              RadioListTile<String>(
                title: const Text('Delete comment'),
                value: 'delete',
                groupValue: action,
                onChanged: (v) => setState(() => action = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: action != null
                  ? () => Navigator.pop(context, true)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.errorColor,
              ),
              child: const Text('Take Action'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && action != null) {
      final success = await provider.handleReport(
        report.id,
        dismiss: false,
        deleteComment: action == 'delete',
        rejectComment: action == 'reject',
      );
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Action taken on report')),
        );
      }
    }
  }

  String _getReasonLabel(ReportReason reason) {
    switch (reason) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.harassment:
        return 'Harassment';
      case ReportReason.hateSpeech:
        return 'Hate Speech';
      case ReportReason.violence:
        return 'Violence';
      case ReportReason.misinformation:
        return 'Misinformation';
      case ReportReason.copyright:
        return 'Copyright';
      case ReportReason.other:
        return 'Other';
    }
  }
}
