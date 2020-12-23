import 'package:hive/hive.dart';

part 'chapter.g.dart';

@HiveType(typeId: 1)
class Chapter {

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

  Chapter(
      {
      this.timeStamp,
      this.fileName,
      this.fileUrl,
      this.completed,
      this.currentPage});
}
