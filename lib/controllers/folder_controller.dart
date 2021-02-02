import 'package:get/get.dart';
import 'package:pdfmanager/database/hive_database_service.dart';
import 'package:pdfmanager/db_models/folder.dart';

class FolderController extends GetxController {

HiveDatabase _database = HiveDatabase.getInstance();
var folders = new List<Folder>().obs;

@override
void onInit() {
    super.onInit();
    fetchFolders();
  }


  void fetchFolders() async {
    List<Folder> folderResult = await _database.getAllFolders();
    folders.value = folderResult;
  }
}


