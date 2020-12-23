import 'package:pdfmanager/database/boxes.dart';
import 'package:pdfmanager/database/hive_service.dart';
import 'package:pdfmanager/db_models/book.dart';

abstract class DataFetchingLogic {
  Future<List<Book>> getAllBooks();
}

class DataFetcher implements DataFetchingLogic {
  HiveService _hiveService = HiveService.getInstance();

  @override
  Future<List<Book>> getAllBooks() async {
    final bookBox = await _hiveService.open(Boxes.bookBox);
    List<Book> books = new List<Book>();
    bookBox.values.forEach((b) {
      Book book = b;
      books.add(book);
    });
    return books;
  }
}
