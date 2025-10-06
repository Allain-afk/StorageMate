import '../../models/file_item.dart';
import '../../models/recommendation.dart';

abstract class JunkClassifier {
  List<Recommendation> classify(List<FileItem> files);
}

class HeuristicJunkClassifier implements JunkClassifier {
  @override
  List<Recommendation> classify(List<FileItem> files) {
    return <Recommendation>[];
  }
}


