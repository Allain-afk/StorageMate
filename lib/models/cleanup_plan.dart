class Selection {
  final String id; // file or group id
  final bool isGroup;
  const Selection({required this.id, required this.isGroup});
}

class CleanupPlan {
  final List<Selection> selections;
  final int totalBytes;
  const CleanupPlan({required this.selections, required this.totalBytes});
}


