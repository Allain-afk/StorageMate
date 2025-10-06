import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReviewAndConfirmView extends StatelessWidget {
  const ReviewAndConfirmView({super.key, this.count = 0, this.bytesLabel = '0 B'});
  final int count;
  final String bytesLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Confirm'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: Text('$count items · $bytesLabel')),
              FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.delete_outline), label: const Text('Clean')),
            ],
          ),
        ),
      ),
      body: const Center(child: Text('Selection review coming soon')),
    );
  }
}


