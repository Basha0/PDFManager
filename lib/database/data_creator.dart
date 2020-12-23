import 'package:pdfmanager/database/boxes.dart';
import 'package:pdfmanager/database/hive_service.dart';
import 'package:pdfmanager/db_models/book.dart';
import 'package:pdfmanager/db_models/chapter.dart';

abstract class DataCreatingLogic {
  Future addBook(Book book);
  Future addChapter(Book book, Chapter chapter);
}

class DataCreator implements DataCreatingLogic {
  HiveService _hiveService = HiveService.getInstance();

  @override
  Future addBook(Book book) async {
    final bookBox = await _hiveService.open(Boxes.bookBox);
    await bookBox.put(book.timeStamp, book);
  }

  @override
  Future addChapter(Book book, Chapter chapter) async {
    final bookBox = await _hiveService.open(Boxes.bookBox);
    Book existingBook = bookBox.get(book.timeStamp);
    existingBook.files.add(chapter);
    await bookBox.put(book.timeStamp, book);
  }
}
