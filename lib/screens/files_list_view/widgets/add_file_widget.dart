import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdfmanager/controllers/folder_controller.dart';
import 'package:pdfmanager/db_models/folder.dart';
import 'package:pdfmanager/logic/dialog.dart';
import 'package:pdfmanager/logic/logic.dart';
import 'package:pdfmanager/resources.dart/Strings.dart';

class AddFileDialoge extends StatefulWidget {
  final Folder folder;
  final FolderController folderController;
  final Function() notifyParent;
  AddFileDialoge(this.folder, this.folderController, this.notifyParent);

  @override
  _AddFileDialogeState createState() => new _AddFileDialogeState();
}

class _AddFileDialogeState extends State<AddFileDialoge> {
  static CustomDiaglog _customDialog = CustomDiaglog.getInstance();
  String _fileURL;
  String _fileName;
  bool _isGoogleDrive = false;
  String googleDriveUrlExample = Strings.googleDriveUrlExample;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 12),
          Text(Strings.downloadFileFromUrl,
              style: Theme.of(context).textTheme.headline1),
          Container(height: 2, color: Colors.white),
          SizedBox(height: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                cursorColor: Colors.red,
                onChanged: (url) {
                  _fileURL = url;
                },
                decoration: new InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2.0),
                  ),
                  hintText: _isGoogleDrive
                      ? googleDriveUrlExample
                      : Strings.pdfUrlExample,
                  hintStyle: TextStyle(fontSize: 8),
                  labelStyle: new TextStyle(color: Colors.white),
                  labelText: Strings.url,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _isGoogleDrive,
                    checkColor: Colors.white,
                    activeColor: Colors.red,
                    onChanged: (val) {
                      setState(() {
                        _isGoogleDrive = val;
                      });
                    },
                  ),
                  Text(Strings.checkIfUrlIsGoogleDriveUrl)
                ],
              ),
              TextField(
                cursorColor: Colors.red,
                onChanged: (fileName) {
                  _fileName = fileName;
                },
                decoration: new InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2.0),
                  ),
                  hintText: Strings.fileNameHint2,
                  labelStyle: new TextStyle(color: Colors.white),
                  labelText: Strings.fileNameHint,
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RaisedButton(
                    color: Colors.red,
                    child: Text(
                      Strings.cancel,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  RaisedButton(
                    color: Colors.red,
                    child: Text(
                      Strings.download,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    onPressed: () {
                      if (_fileName != null && _fileName.isNotEmpty) {
                        downloadFile(context);
                      } else {
                        _customDialog.showOkDialoge(
                            context,
                            Strings.fileNameEmpty,
                            Strings.fileNameEmptyMessage);
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  downloadFile(BuildContext context) async {
    var permissionGranted = await LogicHandler.checkStoragePermissions();
    if (permissionGranted) {
      bool success = await LogicHandler.downloadFile(
          widget.folder,
          widget.folderController,
          _fileURL,
          _fileName,
          _isGoogleDrive,
          context);
      if (success) {
        widget.notifyParent();
        Navigator.pop(context);
      }
    } else {
      _customDialog.showOkDialoge(
          context, Strings.permissionError, Strings.storagePermissionMessage);
    }
  }
}
