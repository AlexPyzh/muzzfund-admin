import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:muzzfund_admin/providers/tracks_provider.dart';
import 'package:muzzfund_admin/models/admin_track.dart';
import 'package:muzzfund_admin/config/theme.dart';
import 'package:muzzfund_admin/widgets/loading_overlay.dart';

class TracksScreen extends StatefulWidget {
  const TracksScreen({super.key});

  @override
  State<TracksScreen> createState() => _TracksScreenState();
}

class _TracksScreenState extends State<TracksScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TracksProvider>().loadTracks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TracksProvider>();

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
                  'Tracks Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  children: [
                    // Bulk actions (when items selected)
                    if (provider.hasSelection) ...[
                      Text('${provider.selectionCount} selected'),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _bulkApprove(provider),
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTheme.successColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _bulkReject(provider),
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTheme.warningColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _bulkDelete(provider),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTheme.errorColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: provider.clearSelection,
                        child: const Text('Clear'),
                      ),
                      const SizedBox(width: 24),
                    ],
                    // Search
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search tracks...',
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
                    PopupMenuButton<TrackApprovalStatus?>(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.filter_list),
                            const SizedBox(width: 8),
                            Text(provider.statusFilter?.displayName ?? 'All'),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: null, child: Text('All')),
                        const PopupMenuItem(
                          value: TrackApprovalStatus.pending,
                          child: Text('Pending'),
                        ),
                        const PopupMenuItem(
                          value: TrackApprovalStatus.approved,
                          child: Text('Approved'),
                        ),
                        const PopupMenuItem(
                          value: TrackApprovalStatus.rejected,
                          child: Text('Rejected'),
                        ),
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
                child: provider.tracks.isEmpty
                    ? const Center(child: Text('No tracks found'))
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Header row
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: AdminTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 48,
                                  child: Checkbox(
                                    value: provider.selectedTrackIds.length == provider.tracks.length &&
                                        provider.tracks.isNotEmpty,
                                    onChanged: (value) {
                                      if (value == true) {
                                        provider.selectAllTracks();
                                      } else {
                                        provider.clearSelection();
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 60, child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                const Expanded(flex: 2, child: Text('Track', style: TextStyle(fontWeight: FontWeight.bold))),
                                const Expanded(flex: 1, child: Text('Artist', style: TextStyle(fontWeight: FontWeight.bold))),
                                const SizedBox(width: 80, child: Text('Duration', style: TextStyle(fontWeight: FontWeight.bold))),
                                const SizedBox(width: 90, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                const SizedBox(width: 60, child: Text('Plays', style: TextStyle(fontWeight: FontWeight.bold))),
                                const SizedBox(width: 60, child: Text('Likes', style: TextStyle(fontWeight: FontWeight.bold))),
                                const SizedBox(width: 70, child: Text('Featured', style: TextStyle(fontWeight: FontWeight.bold))),
                                const SizedBox(width: 150, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Data rows
                          ...provider.tracks.map((track) => _buildTrackListRow(track, provider)),
                        ],
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
                  onPressed: provider.tracks.length >= 20 ? provider.nextPage : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildTrackRow(AdminTrack track, TracksProvider provider) {
    return DataRow(
      selected: provider.selectedTrackIds.contains(track.id),
      cells: [
        DataCell(
          Checkbox(
            value: provider.selectedTrackIds.contains(track.id),
            onChanged: (_) => provider.toggleTrackSelection(track.id),
          ),
        ),
        DataCell(Text('#${track.id}')),
        DataCell(
          InkWell(
            onTap: () => context.go('/tracks/${track.id}'),
            child: Row(
              children: [
                if (track.imageUrl != null)
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: NetworkImage(track.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    track.name,
                    style: TextStyle(
                      color: AdminTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(Text(track.artistName ?? '-')),
        DataCell(Text(track.durationFormatted)),
        DataCell(_buildStatusChip(track.approvalStatus)),
        DataCell(Text(NumberFormat.compact().format(track.totalPlays))),
        DataCell(
          IconButton(
            icon: Icon(
              track.featured ? Icons.star : Icons.star_border,
              color: track.featured ? AdminTheme.warningColor : Colors.grey,
            ),
            onPressed: () => _toggleFeatured(track, provider),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 20),
                onPressed: () => context.go('/tracks/${track.id}'),
                tooltip: 'View Details',
              ),
              if (track.approvalStatus == TrackApprovalStatus.pending) ...[
                IconButton(
                  icon: const Icon(Icons.check, size: 20, color: AdminTheme.successColor),
                  onPressed: () => _approveTrack(track, provider),
                  tooltip: 'Approve',
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AdminTheme.warningColor),
                  onPressed: () => _rejectTrack(track, provider),
                  tooltip: 'Reject',
                ),
              ],
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => _showDeleteDialog(track, provider),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(TrackApprovalStatus status) {
    Color color;
    switch (status) {
      case TrackApprovalStatus.approved:
        color = AdminTheme.successColor;
        break;
      case TrackApprovalStatus.pending:
        color = AdminTheme.warningColor;
        break;
      case TrackApprovalStatus.rejected:
        color = AdminTheme.errorColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  Widget _buildTrackListRow(AdminTrack track, TracksProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: provider.selectedTrackIds.contains(track.id)
            ? AdminTheme.primaryColor.withOpacity(0.1)
            : null,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Checkbox(
              value: provider.selectedTrackIds.contains(track.id),
              onChanged: (_) => provider.toggleTrackSelection(track.id),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text('#${track.id}', style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => context.go('/tracks/${track.id}'),
              child: Row(
                children: [
                  if (track.imageUrl != null)
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        image: DecorationImage(
                          image: NetworkImage(track.imageUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      track.name,
                      style: const TextStyle(
                        color: AdminTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              track.artistName ?? '-',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(track.durationFormatted),
          ),
          SizedBox(
            width: 90,
            child: _buildStatusChip(track.approvalStatus),
          ),
          SizedBox(
            width: 60,
            child: Text(NumberFormat.compact().format(track.totalPlays)),
          ),
          SizedBox(
            width: 60,
            child: Text(NumberFormat.compact().format(track.likesCount)),
          ),
          SizedBox(
            width: 70,
            child: IconButton(
              icon: Icon(
                track.featured ? Icons.star : Icons.star_border,
                color: track.featured ? AdminTheme.warningColor : Colors.grey,
              ),
              onPressed: () => _toggleFeatured(track, provider),
            ),
          ),
          SizedBox(
            width: 150,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, size: 20),
                  onPressed: () => context.go('/tracks/${track.id}'),
                  tooltip: 'View Details',
                ),
                if (track.approvalStatus == TrackApprovalStatus.pending) ...[
                  IconButton(
                    icon: const Icon(Icons.check, size: 20, color: AdminTheme.successColor),
                    onPressed: () => _approveTrack(track, provider),
                    tooltip: 'Approve',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AdminTheme.warningColor),
                    onPressed: () => _rejectTrack(track, provider),
                    tooltip: 'Reject',
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _showDeleteDialog(track, provider),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFeatured(AdminTrack track, TracksProvider provider) async {
    final success = await provider.setTrackFeatured(track.id, !track.featured);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            track.featured ? 'Track unfeatured' : 'Track featured',
          ),
        ),
      );
    }
  }

  Future<void> _approveTrack(AdminTrack track, TracksProvider provider) async {
    final success = await provider.approveTrack(track.id);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Track approved')),
      );
    }
  }

  Future<void> _rejectTrack(AdminTrack track, TracksProvider provider) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Reject Track'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    if (reason != null) {
      final success = await provider.rejectTrack(
        track.id,
        reason: reason.isNotEmpty ? reason : null,
      );
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Track rejected')),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(AdminTrack track, TracksProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Track'),
        content: Text('Are you sure you want to delete "${track.name}"? This action cannot be undone.'),
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
      final success = await provider.deleteTrack(track.id);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Track deleted')),
        );
      }
    }
  }

  Future<void> _bulkApprove(TracksProvider provider) async {
    final count = await provider.bulkApprove();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count tracks approved')),
      );
    }
  }

  Future<void> _bulkReject(TracksProvider provider) async {
    final count = await provider.bulkReject();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count tracks rejected')),
      );
    }
  }

  Future<void> _bulkDelete(TracksProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tracks'),
        content: Text('Are you sure you want to delete ${provider.selectionCount} tracks? This action cannot be undone.'),
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
      final count = await provider.bulkDelete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$count tracks deleted')),
        );
      }
    }
  }
}
