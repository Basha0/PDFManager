import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:pdfmanager/db_models/file.dart';
import 'package:pdfmanager/db_models/folder.dart';

class HiveService {
  static final HiveService _singleton = new HiveService._internal();
  HiveService._internal();

  static HiveService getInstance() => _singleton;

  void init() async {
    await initHive();
  }

  initHive() async {
    final applicationSupportDirectory =
        await path.getApplicationSupportDirectory();
    Hive.init(applicationSupportDirectory.path);
    registerAdapter();
  }

  Future<Box> open(String boxName) async {
    return await Hive.openBox(boxName);
  }

  Future<Box> close(Box box) {
    return box.close();
  }

  registerAdapter() {
    Hive.registerAdapter(FolderAdapter());
    Hive.registerAdapter(CustomFileAdapter());
  }
}
