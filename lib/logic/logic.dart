import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:ext_storage/ext_storage.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:http/http.dart' as http;
import 'package:bmprogresshud/bmprogresshud.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdfmanager/controllers/folder_controller.dart';
import 'package:pdfmanager/database/hive_database_service.dart';
import 'package:pdfmanager/db_models/folder.dart';
import 'package:pdfmanager/db_models/file.dart';
import 'package:pdfmanager/resources.dart/Strings.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dialog.dart';

class LogicHandler {
  static HiveDatabase _hiveDatabase = HiveDatabase.getInstance();
  static CustomDiaglog _customDialog = CustomDiaglog.getInstance();

  static void addFolder(String folderName, String imageString,
      FolderController folderController) async {
    List<CustomFile> fileList = new List<CustomFile>();
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    Folder newFolder = new Folder(
        name: folderName,
        imageStr: imageString,
        timeStamp: timeStamp,
        files: fileList);

    folderController.folders.add(newFolder);
    await _hiveDatabase.addFolder(newFolder);
  }

  static updateFolder(Folder folder) async {
    await _hiveDatabase.updateFolder(folder);
  }

  static deleteFolderFile(Folder folder, String fileUrl, String fileName,
      FolderController folderController) async {
    deleteFile(folder.timeStamp, fileUrl, folderController);

    try {
      io.File file = await getFilePath(fileName  + Strings.pdfType);

      if (await file.exists()) {
        await file.delete();
      } else {
        print("file doesn't exist.");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static deleteAllFilesInFolder(
      String folderId, FolderController folderController) async {
    await _hiveDatabase.deleteAllFolderFiles(folderId);
    folderController.folders.forEach((oldFolder) {
      if (oldFolder.timeStamp == folderId) {
        var files = oldFolder.files;

        files.forEach((f) async {
          try {
            io.File file = await getFilePath(f.fileName + Strings.pdfType);

            if (await file.exists()) {
              await file.delete();
            } else {
              print("file doesn't exist.");
            }
          } catch (e) {
            print(e.toString());
          }
        });
        oldFolder.files.removeWhere((file) => files.contains(file));
      }
    });
  }

  static void deleteFile(String timeStamp, String fileUrl,
      FolderController folderController) async {
    await _hiveDatabase.deleteFile(timeStamp, fileUrl);
    folderController.folders.forEach((oldFolder) {
      if (oldFolder.timeStamp == timeStamp) {
        int folderIndex = folderController.folders.indexOf(oldFolder);
        oldFolder.files.forEach((file) {
          if (file.fileUrl == fileUrl) {
            folderController.folders[folderIndex].files.remove(file);
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
        _customDialog.showOkDialoge(
          context,
          Strings.failedToLoadImage,
          Strings.failedToLoadImageMessage,
        );
      }
    } else {
      _customDialog.showOkDialoge(
          context, Strings.permissionError, Strings.storagePermissionMessage);
    }

    return "";
  }

  static sendEmailWithAttachments(List<CustomFile> fileAttachments) {
    List<String> attachmentPaths = new List<String>();
    String body = "";

    fileAttachments.forEach((f) {
      attachmentPaths.add(f.filePath);
      body = body + f.fileUrl + "\n";
    });

    sendMail(attachmentPaths: attachmentPaths, body: body);
  }

  static sendMail(
      {String body = "",
      String subject = "",
      List<String> attachmentPaths = const []}) async {
    final Email email = Email(
      body: body,
      subject: subject,
      recipients: [],
      cc: [],
      bcc: [],
      attachmentPaths: attachmentPaths,
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
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
    var fileExists = await checkIfFileExists(fileName  + Strings.pdfType);
    if (fileExists) {
      String pdfPath = "";
      await Permission.storage.request();
      var status = await Permission.storage.status;
      if (status.isGranted) {
        String name = await getDownloadFolderPath();
        final script = new io.File(name);
        final fileByte = await script.readAsBytes();
        io.File file = await writeCounter(fileByte, fileName  + Strings.pdfType);
        print("load: " + fileName);
        if (await file.exists()) {
          print("yes it does");
          pdfPath = file.path;
          return pdfPath;
        } else {
          print("no it doesn't");
          return Strings.cancel;
        }
      } else {
        return Strings.cancel;
      }
    } else {
      return Strings.cancel;
    }
  }

  static Future<bool> downloadFile(
      Folder folder,
      FolderController controller,
      String urlPath,
      String fileName,
      bool isGoogleDrive,
      BuildContext context) async {
    if (await checkIfFileExists(fileName + Strings.pdfType)) {
      _customDialog.showOkDialoge(context, Strings.fileNameAllreadyExists,
          Strings.fileNameAllreadyExistsMessage);
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
        if (!urlPath.contains(Strings.pdfType)) {
          _customDialog.showOkDialoge(
              context, Strings.wrongURLFormat, Strings.wrongURLFormatMessage);
          return false;
        }
      }
    } else {
      if (!urlPath.contains(Strings.pdfType)) {
        _customDialog.showOkDialoge(
            context, Strings.invalidFileType, Strings.invalidFileTypeMessage);
        return false;
      }
    }

    ProgressHud.showLoading();
    String dirPath = await getDownloadFolderPath();
    try {
      final response = await http.get(Uri.parse(urlPath));
      writeCounter(response.bodyBytes, fileName + Strings.pdfType);
    } catch (e) {
      sendMail(body: e.toString());
    }

    print('$dirPath/$fileName');
    String filePath = dirPath + "/" + fileName + Strings.pdfType;
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    CustomFile newFile = new CustomFile(
        timeStamp: timeStamp,
        completed: false,
        fileName: fileName,
        fileUrl: urlPath,
        currentPage: 0,
        filePath: filePath);

    controller.folders
        .firstWhere(
          (bk) => bk.name == folder.name,
        )
        .files
        .add(newFile);

    updateFolder(folder);
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

  static Future<String> getDownloadFolderPath() async {
    return (await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS));
  }

  static Future<bool> checkIfFileExists(String fileName) async {
    io.File file = await getFilePath(fileName);
    if (file.existsSync()) {
      return true;
    }
    return false;
  }
}
