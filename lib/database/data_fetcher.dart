import 'package:pdfmanager/database/boxes.dart';
import 'package:pdfmanager/database/hive_service.dart';
import 'package:pdfmanager/db_models/folder.dart';

abstract class DataFetchingLogic {
  Future<List<Folder>> getAllFolders();
}

class DataFetcher implements DataFetchingLogic {
  HiveService _hiveService = HiveService.getInstance();

  @override
  Future<List<Folder>> getAllFolders() async {
    final folderBox = await _hiveService.open(Boxes.folderBox);
    List<Folder> folders = new List<Folder>();
    folderBox.values.forEach((b) {
      Folder folder = b;
      folders.add(folder);
    });
    return folders;
  }
}
