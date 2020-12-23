import 'package:get/get.dart';
import 'package:pdfmanager/database/hive_database_service.dart';
import 'package:pdfmanager/db_models/book.dart';

class BooksController extends GetxController {

HiveDatabase _database = HiveDatabase.getInstance();
var books = new List<Book>().obs;

@override
void onInit() {
    super.onInit();
    fetchBooks();
  }


  void fetchBooks() async {
    List<Book> bookResult = await _database.getAllBooks();
    books.value = bookResult;
  }
}


