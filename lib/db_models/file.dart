import 'package:hive/hive.dart';

part 'file.g.dart';

@HiveType(typeId: 1)
class CustomFile {

  @HiveField(0)
  String timeStamp;

  @HiveField(1)
  String fileName;

  @HiveField(2)
  String fileUrl;

  @HiveField(3)
  bool completed;

  @HiveField(4)
  int currentPage;

  @HiveField(5)
  String filePath;

  CustomFile(
      {
      this.timeStamp,
      this.fileName,
      this.fileUrl,
      this.completed,
      this.currentPage,
      this.filePath});
}
