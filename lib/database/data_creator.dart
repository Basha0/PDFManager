import 'package:pdfmanager/database/boxes.dart';
import 'package:pdfmanager/database/hive_service.dart';
import 'package:pdfmanager/db_models/folder.dart';
import 'package:pdfmanager/db_models/file.dart';

abstract class DataCreatingLogic {
  Future addFolder(Folder folder);
  Future addFile(Folder folder, CustomFile customFile);
}

class DataCreator implements DataCreatingLogic {
  HiveService _hiveService = HiveService.getInstance();

  @override
  Future addFolder(Folder folder) async {
    final folderBox = await _hiveService.open(Boxes.folderBox);
    await folderBox.put(folder.timeStamp, folder);
  }

  @override
  Future addFile(Folder folder, CustomFile customFile) async {
    final folderBox = await _hiveService.open(Boxes.folderBox);
    Folder existingFolder = folderBox.get(folder.timeStamp);
    existingFolder.files.add(customFile);
    await folderBox.put(folder.timeStamp, folder);
  }
}
