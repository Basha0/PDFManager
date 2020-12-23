import 'package:pdfmanager/database/boxes.dart';
import 'package:pdfmanager/database/hive_service.dart';
import 'package:pdfmanager/db_models/book.dart';

abstract class DataUpdatingLogic {
  void updateBook(Book book);
}

class DataUpdater implements DataUpdatingLogic {
  HiveService _hiveService = HiveService.getInstance();

  @override
  void updateBook(Book book) async {
    final bookBox = await _hiveService.open(Boxes.bookBox);
    await bookBox.put(book.timeStamp, book);
  }
}
