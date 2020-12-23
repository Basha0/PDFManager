import 'package:pdfmanager/database/data_creator.dart';
import 'package:pdfmanager/database/data_deleter.dart';
import 'package:pdfmanager/database/data_fetcher.dart';
import 'package:pdfmanager/database/data_updater.dart';
import 'package:pdfmanager/db_models/book.dart';
import 'package:pdfmanager/db_models/chapter.dart';

abstract class HiveDatabaseLogic {
  //Fetch
  Future<List<Book>> getAllBooks();

  //Create
  Future addBook(Book book);
  Future addChapter(Book book, Chapter chapter);

  //Update
  Future updateBook(Book book);

  //Delete
  Future deleteBook(String bookId);
  Future deleteChapter(String bookId, String chapterUrl);
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
  Future<List<Book>> getAllBooks() async {
    return _dataFetcher.getAllBooks();
  }

  //Create
  @override
  Future addBook(Book book) async {
    return _dataCreator.addBook(book);
  }

  @override
  Future addChapter(Book book, Chapter chapter) async {
    return _dataCreator.addChapter(book, chapter);
  }

  //Update
  @override
  Future updateBook(Book book) async {
    return _dataUpdater.updateBook(book);
  }

  // Delete
  @override
  Future deleteBook(String bookId) async {
    return _dataDeleter.deleteBook(bookId);
  }

  @override
  Future deleteChapter(String bookId, String chapterUrl) async {
    return _dataDeleter.deleteChapter(bookId, chapterUrl);
  }
}
