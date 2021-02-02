import 'package:pdfmanager/database/boxes.dart';
import 'package:pdfmanager/database/hive_service.dart';
import 'package:pdfmanager/db_models/folder.dart';

abstract class DataUpdatingLogic {
  void updateFolder(Folder folder);
}

class DataUpdater implements DataUpdatingLogic {
  HiveService _hiveService = HiveService.getInstance();

  @override
  void updateFolder(Folder folder) async {
    final folderBox = await _hiveService.open(Boxes.folderBox);
    await folderBox.put(folder.timeStamp, folder);
  }
}
