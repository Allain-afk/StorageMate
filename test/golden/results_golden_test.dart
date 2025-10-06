import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storagemate/main.dart';

void main() {
  testWidgets('Results golden', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: StorageMateApp()));
    // Navigate to results
    // For placeholder, directly check app shell
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/results.png'),
    );
  });
}


