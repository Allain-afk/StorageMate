import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storagemate/main.dart';

void main() {
  testWidgets('Settings golden', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: StorageMateApp()));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/settings.png'),
    );
  });
}


