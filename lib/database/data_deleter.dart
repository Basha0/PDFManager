import 'package:pdfmanager/database/boxes.dart';
import 'package:pdfmanager/database/hive_service.dart';
import 'package:pdfmanager/db_models/book.dart';
import 'package:pdfmanager/db_models/chapter.dart';

abstract class DataDeletingLogic {
  Future deleteBook(String bookId);
  Future deleteChapter(String bookId,  String chapterUrl);
}

class DataDeleter implements DataDeletingLogic {
  HiveService _hiveService = HiveService.getInstance();

  @override
  Future deleteBook(String bookId) async {
    final bookBox = await _hiveService.open(Boxes.bookBox);
    await bookBox.delete(bookId);
    return null;
  }

  @override
  Future deleteChapter(String bookId, String chapterUrl) async {
    final bookBox = await _hiveService.open(Boxes.bookBox);
    Book existingBook = bookBox.get(bookId);
    Chapter chapterToDelete =
        existingBook.files.firstWhere((chap) => chap.fileUrl == chapterUrl);
    existingBook.files.remove(chapterToDelete);
    bookBox.put(bookId, existingBook);
    return null;
  }
}
