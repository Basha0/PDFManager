import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:ext_storage/ext_storage.dart';
import 'package:http/http.dart' as http;
import 'package:bmprogresshud/bmprogresshud.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfmanager/controllers/books_controller.dart';
import 'package:pdfmanager/database/hive_database_service.dart';
import 'package:pdfmanager/db_models/book.dart';
import 'package:pdfmanager/db_models/chapter.dart';
import 'package:pdfmanager/screens/chapterview/chapter_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class LogicHandler {
  static HiveDatabase _hiveDatabase = HiveDatabase.getInstance();

  static void addBook(String folderName, String imageString,
      BooksController bookController) async {
    List<Chapter> chapterList = new List<Chapter>();
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    Book newBook = new Book(
        name: folderName,
        imageStr: imageString,
        timeStamp: timeStamp,
        files: chapterList);

    bookController.books.add(newBook);
    await _hiveDatabase.addBook(newBook);
  }

  static updateBook(Book book) async {
    await _hiveDatabase.updateBook(book);
  }

  static deleteFile(Book book, String fileUrl, String fileName,
      BooksController booksController) async {
    deleteChapter(book.timeStamp, fileUrl, booksController);

    try {
      io.File file = await getFilePath(fileName);

      if (await file.exists()) {
        await file.delete();
      } else {
        print("file doesn't exist.");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static void deleteChapter(String timeStamp, String chapterUrl,
      BooksController bookController) async {
    await _hiveDatabase.deleteChapter(timeStamp, chapterUrl);
    bookController.books.forEach((oldBook) {
      if (oldBook.timeStamp == timeStamp) {
        int bookIndex = bookController.books.indexOf(oldBook);
        oldBook.files.forEach((file) {
          if (file.fileUrl == chapterUrl) {
            bookController.books[bookIndex].files.remove(file);
          }
        });
      }
    });
  }

  static String convertTimpeStampToDate(String timeStamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp));
    return date.day.toString() +
        "." +
        date.month.toString() +
        "." +
        date.year.toString();
  }

  // Image Picker from Gallary
  static Future<String> getImage(BuildContext context) async {
    bool storagePermissionGranted = await checkStoragePermissions();

    if (storagePermissionGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = io.File(pickedFile.path).readAsBytesSync();
        String img64 = base64Encode(bytes);
        return img64;
      } else {
        showDialog(
          context: context,
          builder: (con) => AlertDialog(
            title: Text("Failed to load Image"),
            content: Text("Couldn't load selected Image. Please try again"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Ok"),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (con) => AlertDialog(
          title: Text("Permission Error"),
          content:
              Text("In order to add a Picture, storage permissions is needed."),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Ok"),
            ),
          ],
        ),
      );
    }

    return "";
  }

  static sendMail(String fileUrl) async {
    String url = 'mailto:?subject=lost url&body=' + fileUrl;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static Future<bool> checkStoragePermissions() async {
    var status = await Permission.storage.status;
    if (status.isUndetermined || status.isDenied) {
      status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }
      return false;
    } else {
      return true;
    }
  }

  static Future<String> loadLocalFile(String fileName) async {
    var fileExists = await checkIfFileExists(fileName);
    if (fileExists) {
      String pdfPath = "";
      await Permission.storage.request();
      var status = await Permission.storage.status;
      if (status.isGranted) {
        String name = await getPath();
        final script = new io.File(name);
        final fileByte = await script.readAsBytes();
        io.File file = await writeCounter(fileByte, fileName);
        print("load: " + fileName);
        if (await file.exists()) {
          print("yes it does");
          pdfPath = file.path;
          return pdfPath;
        } else {
          print("no it doesn't");
          return "cancle";
        }
      } else {
        return "cancle";
      }
    } else {
      return "cancle";
    }
  }

  static Future<bool> downloadFile(Book book, BooksController controller,
      String urlPath, String fileName, bool isGoogleDrive) async {
    if (await checkIfFileExists(fileName)) {
      showDialog(
        context: scaffoldKey.currentContext,
        builder: (con) => AlertDialog(
          title: Text("File Name already exists."),
          content: Text(
              "Please try another Name. You can also for example add a number at the End. (File Name 1)"),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.of(scaffoldKey.currentContext).pop();
              },
              child: Text("Ok"),
            ),
          ],
        ),
      );
      return false;
    }
    String fieldID = "";
    if (isGoogleDrive) {
      if (urlPath.contains("https://drive.google.com/file/d/")) {
        List<String> splitedDriveUrl = urlPath.split("/d/");
        fieldID = splitedDriveUrl.last.split("/").first;
        urlPath = "https://drive.google.com/u/0/uc?id=" +
            fieldID +
            "&export=download";
      } else {
        if (!urlPath.contains(".pdf")) {
          showDialog(
            context: scaffoldKey.currentContext,
            builder: (con) => AlertDialog(
              title: Text("Wrong URL format!"),
              content: Text(
                  "The given Url has to be as shown in the example. 'YOURFieldID' is a random String. Something like that: '1KnDlG2RrQAgG0VvYpfUJLkS9ee6y'."),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.of(scaffoldKey.currentContext).pop();
                  },
                  child: Text("Ok"),
                ),
              ],
            ),
          );
          return false;
        }
      }
    } else {
      if (!urlPath.contains(".pdf")) {
        showDialog(
          context: scaffoldKey.currentContext,
          builder: (con) => AlertDialog(
            title: Text("Invalid File Type"),
            content: Text(
                "The file has to be a PDF File. It is also Possible to download from Google Drive, but please follow the Example."),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(scaffoldKey.currentContext).pop();
                },
                child: Text("Ok"),
              ),
            ],
          ),
        );
        return false;
      }
    }

    ProgressHud.showLoading();
    String dirPath = await getPath();

    final response = await http.get(Uri.parse(urlPath));
    writeCounter(response.bodyBytes, fileName);

    print('$dirPath/$fileName');
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    Chapter newChapter = new Chapter(
        timeStamp: timeStamp,
        completed: false,
        fileName: fileName,
        fileUrl: urlPath,
        currentPage: 0);

    controller.books
        .firstWhere(
          (bk) => bk.name == book.name,
        )
        .files
        .add(newChapter);

    updateBook(book);
    ProgressHud.dismiss();

    return true;
  }

  static Future<io.File> getFilePath(String fileName) async {
    String path = '';
    path = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
    path = '$path/$fileName';

    return io.File(path);
  }

  static Future<io.File> writeCounter(Uint8List stream, String fileName) async {
    final file = await getFilePath(fileName);
    return file.writeAsBytes(stream);
  }

  static Future<String> getPath() async {
    return (await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS));
  }

  static Future<bool> checkIfFileExists(String fileName) async {
    String dirPath = await getPath();
    if (io.File('$dirPath/$fileName').existsSync()) {
      return true;
    }
    return false;
  }
}
