import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdfmanager/controllers/books_controller.dart';
import 'package:pdfmanager/db_models/book.dart';
import 'package:pdfmanager/logic/logic.dart';

class AddChapterDialoge extends StatefulWidget {
  final Book book;
  final BooksController bookController;
  final Function() notifyParent;
  AddChapterDialoge(this.book, this.bookController, this.notifyParent);

  @override
  _AddChapterDialogeState createState() => new _AddChapterDialogeState();
}

class _AddChapterDialogeState extends State<AddChapterDialoge> {
  String _chapterURL;
  String _fileName;
  bool _isGoogleDrive = false;
  String googleDriveUrlExample =
      "Example: https://drive.google.com/file/d/YOURFieldID/view";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 12),
          Text('Download file from URL.',
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
                  _chapterURL = url;
                },
                decoration: new InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2.0),
                  ),
                  hintText:_isGoogleDrive ? googleDriveUrlExample : "Example: https://MyWebsite.com/file.pdf",
                  hintStyle: TextStyle(fontSize: 8),
                  labelStyle: new TextStyle(color: Colors.white),
                  labelText: 'Url',
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
                  Text("Check if URL is Google Drive Url")
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
                  hintText: "File name 12",
                  labelStyle: new TextStyle(color: Colors.white),
                  labelText: 'File Name',
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RaisedButton(
                    color: Colors.red,
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  RaisedButton(
                    color: Colors.red,
                    child: Text(
                      "Download",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    onPressed: () {
                      if (_fileName != null && _fileName.isNotEmpty) {
                        LogicHandler.downloadFile(
                                widget.book,
                                widget.bookController,
                                _chapterURL,
                                _fileName,
                                _isGoogleDrive)
                            .then((value) {
                          if (value) {
                            widget.notifyParent();
                          }
                        });

                        Navigator.pop(context);
                      } else {
                        showDialog(
                          context: context,
                          builder: (con) => AlertDialog(
                            title: Text("File Name Empty"),
                            content: Text("Please add a file name."),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Ok"),
                              ),
                            ],
                          ),
                        );
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
}
