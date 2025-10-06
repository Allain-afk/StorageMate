import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_stats_service.dart';

/// Provider for storage statistics service
final storageStatsServiceProvider = Provider<StorageStatsService>((ref) {
  return StorageStatsService();
});

/// Provider for device storage information
final deviceStorageInfoProvider = FutureProvider<DeviceStorageInfo>((ref) async {
  final service = ref.watch(storageStatsServiceProvider);
  return await service.getStorageStats();
});

/// Provider for category breakdown
final categoryBreakdownProvider = FutureProvider<CategoryBreakdown>((ref) async {
  final service = ref.watch(storageStatsServiceProvider);
  return await service.getCategoryBreakdown();
});

/// Provider for combined storage statistics (primary storage)
final primaryStorageStatsProvider = FutureProvider<StorageStats>((ref) async {
  final deviceInfo = await ref.watch(deviceStorageInfoProvider.future);
  // Return external storage as primary (where user files are stored)
  return deviceInfo.external;
});

/// Provider for storage stats with refresh capability using AsyncNotifier
class StorageStatsNotifier extends AsyncNotifier<DeviceStorageInfo> {
  @override
  Future<DeviceStorageInfo> build() async {
    final service = ref.watch(storageStatsServiceProvider);
    return await service.getStorageStats();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final service = ref.read(storageStatsServiceProvider);
    state = await AsyncValue.guard(() => service.getStorageStats());
  }
}

final storageStatsNotifierProvider = AsyncNotifierProvider<StorageStatsNotifier, DeviceStorageInfo>(() {
  return StorageStatsNotifier();
});

/// Provider for category breakdown with refresh capability using AsyncNotifier
class CategoryBreakdownNotifier extends AsyncNotifier<CategoryBreakdown> {
  @override
  Future<CategoryBreakdown> build() async {
    final service = ref.watch(storageStatsServiceProvider);
    return await service.getCategoryBreakdown();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final service = ref.read(storageStatsServiceProvider);
    state = await AsyncValue.guard(() => service.getCategoryBreakdown());
  }
}

final categoryBreakdownNotifierProvider = AsyncNotifierProvider<CategoryBreakdownNotifier, CategoryBreakdown>(() {
  return CategoryBreakdownNotifier();
});

