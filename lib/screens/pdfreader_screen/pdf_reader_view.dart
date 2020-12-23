import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pdfmanager/controllers/books_controller.dart';
import 'package:pdfmanager/db_models/book.dart';
import 'package:pdfmanager/logic/logic.dart';

class PDFReaderView extends StatefulWidget {
  final String fileName;
  final String fileUrl;
  final Book book;
  final BooksController booksController;
  final Function notifyParent;
  PDFReaderView(this.fileName, this.fileUrl, this.book, this.booksController,
      this.notifyParent);

  @override
  _PDFReaderViewState createState() => _PDFReaderViewState();
}

class _PDFReaderViewState extends State<PDFReaderView> {
  bool _isLoading = true;
  String pdfPath;
  int currentPage;

  @override
  void initState() {
    super.initState();
    currentPage = widget.book.files
        .firstWhere((file) => file.fileUrl == widget.fileUrl)
        .currentPage;
    loadFile();
  }

  void loadFile() async {
    File file = await LogicHandler.getFilePath(widget.fileName);
    setState(() {
      pdfPath = file.path;

      print(pdfPath);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Reader"),
        centerTitle: true,
      ),
      body: Center(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : PDFView(
                defaultPage: currentPage,
                filePath: pdfPath,
                onRender: (_pages) {
                  setState(() {});
                },
                onError: (error) {
                  print(error.toString());
                },
                onPageError: (page, error) {
                  print('$page: ${error.toString()}');
                },
                onPageChanged: (int page, int total) {
                  print('page change: $page/$total');
                  currentPage = page;
                  widget.booksController.books.forEach((oldBook) {
                    if (oldBook.timeStamp == widget.book.timeStamp) {
                      int bookIndex =
                          widget.booksController.books.indexOf(oldBook);
                      oldBook.files.forEach((file) {
                        if (file.fileUrl == widget.fileUrl) {
                          int chapterIndex = oldBook.files.indexOf(file);
                          widget.booksController.books[bookIndex]
                              .files[chapterIndex].currentPage = currentPage;
                          LogicHandler.updateBook(
                              widget.booksController.books[bookIndex]);
                        }
                      });
                    }
                  });
                  widget.notifyParent();
                },
                onViewCreated: (val) {},
              ),
      ),
    );
  }
}
