class Recommendation {
  final String id; // itemId or groupId
  final String type; // duplicate|junk|rare
  final double confidence; // 0..1
  final String reason;
  final int bytesReclaimable;

  const Recommendation({
    required this.id,
    required this.type,
    required this.confidence,
    required this.reason,
    required this.bytesReclaimable,
  });
}


