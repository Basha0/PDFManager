import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pdfmanager/controllers/folder_controller.dart';
import 'package:pdfmanager/db_models/folder.dart';
import 'package:pdfmanager/logic/logic.dart';
import 'package:pdfmanager/resources.dart/Strings.dart';

class PDFReaderView extends StatefulWidget {
  final String fileName;
  final String fileUrl;
  final Folder folder;
  final FolderController folderController;
  final Function notifyParent;
  PDFReaderView(this.fileName, this.fileUrl, this.folder, this.folderController,
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
    currentPage = widget.folder.files
        .firstWhere((file) => file.fileUrl == widget.fileUrl)
        .currentPage;
    loadFile();
  }

  void loadFile() async {
    File file = await LogicHandler.getFilePath(widget.fileName + Strings.pdfType);
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
        title: Text(Strings.pdfReader),
        centerTitle: true,
      ),
      body: Center(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : PDFView(
                preventLinkNavigation: true,
                defaultPage: currentPage,
                filePath: pdfPath,
                onRender: (_pages) {
                  setState(() {});
                },
                onError: (error) {
                  print(error.toString());
                  LogicHandler.sendMail(body: error.toString());
                },
                onPageError: (page, error) {
                  print('$page: ${error.toString()}');
                  LogicHandler.sendMail(body: error.toString());
                },
                onPageChanged: (int page, int total) {
                  print('page change: $page/$total');
                  currentPage = page;
                  widget.folderController.folders.forEach((oldFolder) {
                    if (oldFolder.timeStamp == widget.folder.timeStamp) {
                      int folderIndex =
                          widget.folderController.folders.indexOf(oldFolder);
                      oldFolder.files.forEach((file) {
                        if (file.fileUrl == widget.fileUrl) {
                          int fileIndex = oldFolder.files.indexOf(file);
                          widget.folderController.folders[folderIndex]
                              .files[fileIndex].currentPage = currentPage;
                          LogicHandler.updateFolder(
                              widget.folderController.folders[folderIndex]);
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
