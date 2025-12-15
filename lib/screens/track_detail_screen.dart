import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:muzzfund_admin/providers/tracks_provider.dart';
import 'package:muzzfund_admin/models/admin_track.dart';
import 'package:muzzfund_admin/config/theme.dart';
import 'package:muzzfund_admin/widgets/loading_overlay.dart';

class TrackDetailScreen extends StatefulWidget {
  final int trackId;

  const TrackDetailScreen({super.key, required this.trackId});

  @override
  State<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends State<TrackDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TracksProvider>().loadTrackDetail(widget.trackId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TracksProvider>();
    final track = provider.selectedTrack;

    return LoadingOverlay(
      isLoading: provider.isLoadingDetail,
      child: track == null
          ? const Center(child: Text('Track not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  TextButton.icon(
                    onPressed: () => context.go('/tracks'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Tracks'),
                  ),
                  const SizedBox(height: 16),

                  // Track Header Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Album Art
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[800],
                              image: track.imageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(track.imageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: track.imageUrl == null
                                ? const Icon(Icons.music_note, size: 64, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 24),
                          // Track Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        track.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    _buildStatusChip(track.approvalStatus),
                                    if (track.featured) ...[
                                      const SizedBox(width: 8),
                                      const Chip(
                                        avatar: Icon(Icons.star, color: AdminTheme.warningColor, size: 18),
                                        label: Text('Featured'),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  track.artistName ?? 'Unknown Artist',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                                if (track.albumName != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Album: ${track.albumName}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 8,
                                  children: [
                                    _buildInfoChip(Icons.timer, track.durationFormatted),
                                    if (track.year != null)
                                      _buildInfoChip(Icons.calendar_today, track.year.toString()),
                                    _buildInfoChip(
                                      Icons.play_circle,
                                      '${NumberFormat.compact().format(track.totalPlays)} plays',
                                    ),
                                    _buildInfoChip(
                                      Icons.favorite,
                                      '${track.likesCount} likes',
                                    ),
                                    _buildInfoChip(
                                      Icons.pie_chart,
                                      '${track.investmentPercent.toStringAsFixed(1)}% invested',
                                    ),
                                  ],
                                ),
                                if (track.about != null && track.about!.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    'Description',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    track.about!,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                // Action buttons
                                Wrap(
                                  spacing: 12,
                                  children: [
                                    if (track.approvalStatus == TrackApprovalStatus.pending) ...[
                                      ElevatedButton.icon(
                                        onPressed: () => _approveTrack(provider),
                                        icon: const Icon(Icons.check),
                                        label: const Text('Approve'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AdminTheme.successColor,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () => _rejectTrack(provider),
                                        icon: const Icon(Icons.close),
                                        label: const Text('Reject'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AdminTheme.warningColor,
                                        ),
                                      ),
                                    ],
                                    OutlinedButton.icon(
                                      onPressed: () => _toggleFeatured(provider),
                                      icon: Icon(track.featured ? Icons.star_border : Icons.star),
                                      label: Text(track.featured ? 'Unfeature' : 'Feature'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => _toggleVisibility(provider),
                                      icon: Icon(track.visible ? Icons.visibility_off : Icons.visibility),
                                      label: Text(track.visible ? 'Hide' : 'Show'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _deleteTrack(provider),
                                      icon: const Icon(Icons.delete),
                                      label: const Text('Delete'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AdminTheme.errorColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Track Details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metadata
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Track Details',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                _buildDetailRow('Track ID', track.id.toString()),
                                _buildDetailRow('Artist ID', track.artistId?.toString() ?? '-'),
                                _buildDetailRow('Album ID', track.albumId?.toString() ?? '-'),
                                _buildDetailRow('Is Single', track.isSingle ? 'Yes' : 'No'),
                                _buildDetailRow('Visible', track.visible ? 'Yes' : 'No'),
                                _buildDetailRow('Deleted', track.deleted ? 'Yes' : 'No'),
                                _buildDetailRow(
                                  'Created',
                                  track.created != null
                                      ? DateFormat('MMM dd, yyyy HH:mm').format(track.created!)
                                      : '-',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Streaming URL
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Streaming',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                if (track.streamingUrl != null) ...[
                                  Text(
                                    'Streaming URL',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  SelectableText(
                                    track.streamingUrl!,
                                    style: TextStyle(
                                      color: AdminTheme.primaryColor,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ] else
                                  const Text('No streaming URL available'),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _approveTrack(TracksProvider provider) async {
    final success = await provider.approveTrack(widget.trackId);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Track approved')),
      );
    }
  }

  Future<void> _rejectTrack(TracksProvider provider) async {
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
        widget.trackId,
        reason: reason.isNotEmpty ? reason : null,
      );
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Track rejected')),
        );
      }
    }
  }

  Future<void> _toggleFeatured(TracksProvider provider) async {
    final track = provider.selectedTrack;
    if (track == null) return;

    final success = await provider.setTrackFeatured(widget.trackId, !track.featured);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(track.featured ? 'Track unfeatured' : 'Track featured')),
      );
    }
  }

  Future<void> _toggleVisibility(TracksProvider provider) async {
    final track = provider.selectedTrack;
    if (track == null) return;

    final updatedTrack = track.copyWith(visible: !track.visible);
    final success = await provider.updateTrack(updatedTrack);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(track.visible ? 'Track hidden' : 'Track visible')),
      );
    }
  }

  Future<void> _deleteTrack(TracksProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Track'),
        content: const Text('Are you sure you want to delete this track? This action cannot be undone.'),
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
      final success = await provider.deleteTrack(widget.trackId);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Track deleted')),
        );
        context.go('/tracks');
      }
    }
  }
}
