import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/file_item.dart';
import '../../../core/services/file_cleanup_service.dart';
import '../../../core/utils/format.dart';

class ReviewAndConfirmView extends StatefulWidget {
  const ReviewAndConfirmView({
    super.key,
    this.count = 0,
    this.bytesLabel = '0 B',
    this.filesToDelete = const [],
  });
  
  final int count;
  final String bytesLabel;
  final List<FileItem> filesToDelete;

  @override
  State<ReviewAndConfirmView> createState() => _ReviewAndConfirmViewState();
}

class _ReviewAndConfirmViewState extends State<ReviewAndConfirmView> {
  bool _isDeleting = false;
  final _cleanupService = FileCleanupService();

  Future<void> _performCleanup() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Cleanup'),
        content: Text(
          'Are you sure you want to delete ${widget.count} files (${widget.bytesLabel})?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final result = await _cleanupService.deleteFileItems(widget.filesToDelete);

      if (!mounted) return;

      // Show result dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                result.isComplete ? Icons.check_circle : Icons.warning,
                color: result.isComplete ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 12),
              const Text('Cleanup Complete'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✓ Deleted: ${result.successCount} files'),
              Text('✓ Space freed: ${formatBytes(result.bytesFreed)}'),
              if (result.hasFailures) ...[
                const SizedBox(height: 8),
                Text(
                  '✗ Failed: ${result.failCount} files',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close review screen
                Navigator.pop(context); // Close category screen
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during cleanup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Confirm'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: Text('${widget.count} items · ${widget.bytesLabel}')),
              FilledButton.icon(
                onPressed: _isDeleting || widget.count == 0 ? null : _performCleanup,
                icon: _isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.delete_outline),
                label: Text(_isDeleting ? 'Deleting...' : 'Clean'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
      body: widget.filesToDelete.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No files selected for cleanup',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: widget.filesToDelete.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final file = widget.filesToDelete[index];
                return ListTile(
                  leading: Icon(
                    _getFileIcon(file.mimeType),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(formatBytes(file.size)),
                  trailing: const Icon(Icons.delete_outline, color: Colors.red),
                );
              },
            ),
    );
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;
    
    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.startsWith('video/')) return Icons.video_file;
    if (mimeType.startsWith('audio/')) return Icons.audio_file;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('zip') || mimeType.contains('rar')) return Icons.folder_zip;
    if (mimeType.contains('apk')) return Icons.android;
    
    return Icons.insert_drive_file;
  }
}


