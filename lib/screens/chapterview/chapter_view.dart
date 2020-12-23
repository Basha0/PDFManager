import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdfmanager/controllers/books_controller.dart';
import 'package:pdfmanager/db_models/book.dart';
import 'package:pdfmanager/logic/logic.dart';
import 'package:pdfmanager/screens/chapterview/widgets/add_chapter_widget.dart';
import 'package:pdfmanager/screens/pdfreader_screen/pdf_reader_view.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

class ChapterScreen extends StatefulWidget {
  final Book book;
  final BooksController bookController;

  ChapterScreen(this.book, this.bookController);

  @override
  _ChapterScreenState createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  var _byteImage;
  bool userAddedImage = false;

  @override
  void initState() {
    super.initState();
    String base64Image = widget.book.imageStr;
    if (base64Image != null) {
      _byteImage = Base64Decoder().convert(base64Image);
      setState(() {
        userAddedImage = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Chapter"),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(children: [
          Container(
              height: MediaQuery.of(context).size.height / 5,
              decoration: userAddedImage
                  ? BoxDecoration(
                      color: const Color(0xFF0E3311).withOpacity(0.5),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          colorFilter: new ColorFilter.mode(
                              Colors.black12.withOpacity(0.6),
                              BlendMode.darken),
                          image: MemoryImage(_byteImage)),
                    )
                  : BoxDecoration(),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                    child: userAddedImage
                        ? Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E3311).withOpacity(0.5),
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: MemoryImage(_byteImage),
                              ),
                            ),
                          )
                        : Container(
                            height: 100,
                            width: 70,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent),
                            ),
                            child: Icon(Icons.photo_library),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 32, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text("Title: " + widget.book.name,
                            style: TextStyle(fontSize: 24)),
                        SizedBox(height: 8),
                        Text(
                            "Added: " +
                                LogicHandler.convertTimpeStampToDate(
                                    widget.book.timeStamp),
                            style: TextStyle(fontSize: 20)),
                        SizedBox(height: 8),
                        Text(
                            "Files Count: " +
                                widget.book.files.length.toString(),
                            style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  )
                ],
              )),
          Expanded(
            child: ListView.builder(
              itemCount: widget.book.files?.length ?? 0,
              itemBuilder: (contx, index) {
                return GestureDetector(
                  onTap: () {
                    checkIfFileExists(index);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.black26,
                          border: Border.all(color: Colors.redAccent)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.book.files[index].fileName ?? "",
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                      "Current Page: " +
                                          widget.book.files[index].currentPage
                                              .toString(),
                                      style: TextStyle(fontSize: 10))
                                ]),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                size: 30,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Delete File"),
                                      content: Text(
                                          "Are you sure you want to delete this File?"),
                                      actions: [
                                        FlatButton(
                                          onPressed: () {
                                            Navigator.of(
                                                    scaffoldKey.currentContext)
                                                .pop();
                                          },
                                          child: Text("Cancel"),
                                        ),
                                        FlatButton(
                                          onPressed: () {
                                            LogicHandler.deleteFile(
                                                widget.book,
                                                widget
                                                    .book.files[index].fileUrl,
                                                widget
                                                    .book.files[index].fileName,
                                                widget.bookController);
                                            refresh();
                                            Navigator.of(
                                                    scaffoldKey.currentContext)
                                                .pop();
                                          },
                                          child: Text("Delete"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              color: Colors.red,
              width: MediaQuery.of(context).size.width,
              height: 60,
              child: Center(
                child: IconButton(
                  icon: Icon(
                    Icons.picture_as_pdf_sharp,
                    size: 40,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Container(
                            height: 300,
                            width: MediaQuery.of(context).size.width - 100,
                            child: AddChapterDialoge(
                                widget.book, widget.bookController, refresh),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  checkIfFileExists(int index) async {
    bool exists =
        await LogicHandler.checkIfFileExists(widget.book.files[index].fileName);
    if (exists) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFReaderView(
              widget.book.files[index].fileName,
              widget.book.files[index].fileUrl,
              widget.book,
              widget.bookController,
              refresh),
        ),
      );
    } else {
      showFileLostDialog(index);
    }
  }

  refresh() {
    setState(() {});
  }

  showFileLostDialog(int index) {
    return showDialog(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          width: MediaQuery.of(context).size.width - 100,
          child: AlertDialog(
            title: Text("File not found"),
            content: Text(
                "File was not found. Either it was deleted or moved. File will now not be shwon anymore. If you want to have the URL we can send it via mail."),
            actions: [
              FlatButton(
                onPressed: () {
                  LogicHandler.deleteChapter(widget.book.timeStamp,
                      widget.book.files[index].fileUrl, widget.bookController);
                  refresh();
                  Navigator.pop(context);
                },
                child: Text("Ok"),
              ),
              FlatButton(
                onPressed: () {
                  LogicHandler.sendMail(widget.book.files[index].fileUrl);
                  LogicHandler.deleteChapter(widget.book.timeStamp,
                      widget.book.files[index].fileUrl, widget.bookController);
                  refresh();
                  Navigator.pop(context);
                },
                child: Text("Send Mail"),
              ),
            ],
          ),
        );
      },
    );
  }
}
