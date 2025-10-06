import '../../models/file_item.dart';
import '../../models/recommendation.dart';

abstract class JunkClassifier {
  List<Recommendation> classify(List<FileItem> files);
}

class HeuristicJunkClassifier implements JunkClassifier {
  @override
  List<Recommendation> classify(List<FileItem> files) {
    final List<Recommendation> recs = <Recommendation>[];
    for (final f in files) {
      final path = f.path.toLowerCase();
      // High confidence: obvious cache/temp/log leftovers
      if (path.contains('/cache/') || path.endsWith('.tmp') || path.endsWith('.log')) {
        recs.add(Recommendation(
          id: f.id,
          type: 'junk',
          confidence: 0.95,
          reason: 'File appears to be cache/temp/log',
          bytesReclaimable: f.size,
        ));
        continue;
      }
      // APKs older than 60 days
      if (path.endsWith('.apk')) {
        final ageDays = DateTime.now().difference(f.lastModified).inDays;
        if (ageDays > 60) {
          recs.add(Recommendation(
            id: f.id,
            type: 'junk',
            confidence: 0.9,
            reason: 'APK older than 60 days',
            bytesReclaimable: f.size,
          ));
          continue;
        }
      }

      // Medium: media under Downloads older than 90 days
      if (path.contains('/download/') && (path.endsWith('.jpg') || path.endsWith('.mp4') || path.endsWith('.png'))) {
        final ageDays = DateTime.now().difference(f.lastModified).inDays;
        if (ageDays > 90) {
          recs.add(Recommendation(
            id: f.id,
            type: 'junk',
            confidence: 0.6,
            reason: 'Old media under Downloads',
            bytesReclaimable: f.size,
          ));
          continue;
        }
      }

      // Low: very large files > 200MB without recent access
      if (f.size > 200 * 1024 * 1024) {
        final access = f.lastAccessed ?? f.lastModified;
        if (DateTime.now().difference(access).inDays > 120) {
          recs.add(Recommendation(
            id: f.id,
            type: 'junk',
            confidence: 0.35,
            reason: 'Large file with no recent activity',
            bytesReclaimable: f.size,
          ));
        }
      }
    }
    return recs;
  }
}


