import 'package:hive/hive.dart';
import 'package:pdfmanager/db_models/file.dart';

part 'folder.g.dart';

@HiveType(typeId: 0)
class Folder {
  @HiveField(0)
  String name;

  @HiveField(1)
  String timeStamp;

  @HiveField(2)
  String imageStr;

  @HiveField(3)
  List<CustomFile> files;

  Folder({this.name, this.timeStamp, this.imageStr, this.files});
}
