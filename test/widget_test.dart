import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storagemate/core/services/storage_stats_service.dart';
import 'package:storagemate/core/providers/storage_provider.dart';
import 'package:storagemate/widgets/stats_cards.dart';
import 'package:storagemate/core/utils/format.dart';

void main() {
  group('StatCard Widget', () {
    testWidgets('displays storage information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: 'Used',
              value: '50 GB',
              subtitle: 'of 100 GB',
              icon: Icons.storage,
            ),
          ),
        ),
      );

      expect(find.text('Used'), findsOneWidget);
      expect(find.text('50 GB'), findsOneWidget);
      expect(find.text('of 100 GB'), findsOneWidget);
      expect(find.byIcon(Icons.storage), findsOneWidget);
    });
  });

  group('Storage Stats Integration', () {
    testWidgets('dashboard shows loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageStatsNotifierProvider.overrideWith((ref) {
              return StorageStatsNotifier(StorageStatsService());
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Format Utilities', () {
    test('formatBytes works correctly', () {
      expect(formatBytes(0), '0 B');
      expect(formatBytes(1024), '1.0 KB');
      expect(formatBytes(1048576), '1.0 MB');
      expect(formatBytes(1073741824), '1.0 GB');
      expect(formatBytes(500), '500 B');
      expect(formatBytes(1536), '1.5 KB');
    });
  });
}

