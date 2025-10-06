class FileItem {
  final String id;
  final String path;
  final String name;
  final int size;
  final String? mimeType;
  final DateTime lastModified;
  final DateTime? lastAccessed;
  final String? hash;
  final String? pHash;

  const FileItem({
    required this.id,
    required this.path,
    required this.name,
    required this.size,
    this.mimeType,
    required this.lastModified,
    this.lastAccessed,
    this.hash,
    this.pHash,
  });
}


