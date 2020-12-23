import 'package:hive/hive.dart';
import 'package:pdfmanager/db_models/chapter.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book {
  @HiveField(0)
  String name;

  @HiveField(1)
  String timeStamp;

  @HiveField(2)
  String imageStr;

  @HiveField(3)
  List<Chapter> files;

  Book({this.name, this.timeStamp, this.imageStr, this.files});
}
