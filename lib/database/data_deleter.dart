import 'package:pdfmanager/database/boxes.dart';
import 'package:pdfmanager/database/hive_service.dart';
import 'package:pdfmanager/db_models/folder.dart';
import 'package:pdfmanager/db_models/file.dart';

abstract class DataDeletingLogic {
  Future deleteFolder(String folderId);
  Future deleteFile(String folderId, String fileUrl);
  Future deleteAllFolderFiles(String folderId);
}

class DataDeleter implements DataDeletingLogic {
  HiveService _hiveService = HiveService.getInstance();

  @override
  Future deleteFolder(String folderId) async {
    final folderBox = await _hiveService.open(Boxes.folderBox);
    await folderBox.delete(folderId);
    return null;
  }

  @override
  Future deleteFile(String folderId, String fileUrl) async {
    final folderBox = await _hiveService.open(Boxes.folderBox);
    Folder existingFolder = folderBox.get(folderId);
    CustomFile fileToDelete =
        existingFolder.files.firstWhere((chap) => chap.fileUrl == fileUrl);
    existingFolder.files.remove(fileToDelete);
    folderBox.put(folderId, existingFolder);
    return null;
  }

  @override
  Future deleteAllFolderFiles(String folderId) async {
    final folderBox = await _hiveService.open(Boxes.folderBox);
    Folder existingFolder = folderBox.get(folderId);
    var files = existingFolder.files;

    files.forEach((file) {
      existingFolder.files.firstWhere((fl) => fl.fileUrl == file.fileUrl);
    });
    folderBox.put(folderId, existingFolder);
    return null;
  }
}
