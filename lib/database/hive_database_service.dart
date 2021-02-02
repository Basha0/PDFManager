import 'package:pdfmanager/database/data_creator.dart';
import 'package:pdfmanager/database/data_deleter.dart';
import 'package:pdfmanager/database/data_fetcher.dart';
import 'package:pdfmanager/database/data_updater.dart';
import 'package:pdfmanager/db_models/folder.dart';
import 'package:pdfmanager/db_models/file.dart';

abstract class HiveDatabaseLogic {
  //Fetch
  Future<List<Folder>> getAllFolders();

  //Create
  Future addFolder(Folder folder);
  Future addFile(Folder folder, CustomFile file);

  //Update
  Future updateFolder(Folder folder);

  //Delete
  Future deleteFolder(String folderId);
  Future deleteFile(String folderId, String fileUrl);
  Future deleteAllFolderFiles(String folderId);
}

class HiveDatabase implements HiveDatabaseLogic {
  static final HiveDatabase _singleton = new HiveDatabase._internal();
  HiveDatabase._internal();
  static HiveDatabase getInstance() => _singleton;

  DataCreatingLogic _dataCreator = DataCreator();
  DataFetchingLogic _dataFetcher = DataFetcher();
  DataDeletingLogic _dataDeleter = DataDeleter();
  DataUpdatingLogic _dataUpdater = DataUpdater();

  // Fetch
  @override
  Future<List<Folder>> getAllFolders() async {
    return _dataFetcher.getAllFolders();
  }

  //Create
  @override
  Future addFolder(Folder folder) async {
    return _dataCreator.addFolder(folder);
  }

  @override
  Future addFile(Folder folder, CustomFile file) async {
    return _dataCreator.addFile(folder, file);
  }

  //Update
  @override
  Future updateFolder(Folder folder) async {
    return _dataUpdater.updateFolder(folder);
  }

  // Delete
  @override
  Future deleteFolder(String folderId) async {
    return _dataDeleter.deleteFolder(folderId);
  }

  @override
  Future deleteFile(String folderId, String fileUrl) async {
    return _dataDeleter.deleteFile(folderId, fileUrl);
  }

  @override
  Future deleteAllFolderFiles(String folderId) async {
    return _dataDeleter.deleteAllFolderFiles(folderId);
  }
}
