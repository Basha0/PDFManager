import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdfmanager/controllers/folder_controller.dart';
import 'package:pdfmanager/db_models/file.dart';
import 'package:pdfmanager/db_models/folder.dart';
import 'package:pdfmanager/logic/dialog.dart';
import 'package:pdfmanager/logic/logic.dart';
import 'package:pdfmanager/screens/files_list_view/widgets/add_file_widget.dart';
import 'package:pdfmanager/screens/pdfreader_screen/pdf_reader_view.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

class FilesScreen extends StatefulWidget {
  final Folder folder;
  final FolderController folderController;

  FilesScreen(this.folder, this.folderController);

  @override
  _FilesScreenState createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  static CustomDiaglog _customDialog = CustomDiaglog.getInstance();
  List<CustomFile> selectedItems = new List<CustomFile>();
  var _byteImage;
  bool userAddedImage = false;

  @override
  void initState() {
    super.initState();
    String base64Image = widget.folder.imageStr;
    if (base64Image != null) {
      _byteImage = Base64Decoder().convert(base64Image);
      setState(() {
        userAddedImage = true;
      });
    }
  }

  handleClick(String value) {
    switch (value) {
      case "Remove all":
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Delete Files"),
              content: Text(
                  "Are you sure you want to delete all File in this folder?"),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.of(scaffoldKey.currentContext).pop();
                  },
                  child: Text("Cancel"),
                ),
                FlatButton(
                  onPressed: () {
                    LogicHandler.deleteAllFilesInFolder(
                        widget.folder.timeStamp, widget.folderController);
                    refresh();
                    Navigator.of(scaffoldKey.currentContext).pop();
                  },
                  child: Text("Delete"),
                ),
              ],
            );
          },
        );
        break;
      default:
        if (selectedItems.isNotEmpty) {
          LogicHandler.sendEmailWithAttachments(selectedItems);
          selectedItems.clear();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("File List"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Remove all', 'Share selected'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(children: [
        Container(
            height: MediaQuery.of(context).size.height / 5,
            decoration: userAddedImage
                ? BoxDecoration(
                    color: const Color(0xFF0E3311).withOpacity(0.5),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        colorFilter: new ColorFilter.mode(
                            Colors.black12.withOpacity(0.6), BlendMode.darken),
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
                      Text("Title: " + widget.folder.name,
                          style: TextStyle(fontSize: 24)),
                      SizedBox(height: 8),
                      Text(
                          "Added: " +
                              LogicHandler.convertTimpeStampToDate(
                                  widget.folder.timeStamp),
                          style: TextStyle(fontSize: 20)),
                      SizedBox(height: 8),
                      Text(
                          "Files Count: " +
                              widget.folder.files.length.toString(),
                          style: TextStyle(fontSize: 18)),
                    ],
                  ),
                )
              ],
            )),
        Expanded(
          child: ListView.builder(
            itemCount: widget.folder.files?.length ?? 0,
            itemBuilder: (contx, index) {
              return GestureDetector(
                onTap: () {
                  checkIfFileExists(index);
                },
                onLongPress: () {
                  if (selectedItems.contains(widget.folder.files[index])) {
                    selectedItems.remove(widget.folder.files[index]);
                  } else {
                    selectedItems.add(widget.folder.files[index]);
                  }

                  refresh();
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color:
                            selectedItems.contains(widget.folder.files[index])
                                ? Colors.white.withOpacity(0.2)
                                : Colors.black26,
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
                                  widget.folder.files[index].fileName ?? "",
                                  style: TextStyle(fontSize: 24),
                                ),
                                SizedBox(height: 5),
                                Text(
                                    "Current Page: " +
                                        widget.folder.files[index].currentPage
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
                                          LogicHandler.deleteFolderFile(
                                              widget.folder,
                                              widget
                                                  .folder.files[index].fileUrl,
                                              widget
                                                  .folder.files[index].fileName,
                                              widget.folderController);
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
        Container(
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
                        child: AddFileDialoge(
                            widget.folder, widget.folderController, refresh),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        )
      ]),
    );
  }

  checkIfFileExists(int index) async {
    var permissionGranted = await LogicHandler.checkStoragePermissions();
    if (permissionGranted) {
      bool exists = await LogicHandler.checkIfFileExists(
          widget.folder.files[index].fileName);
      if (exists) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFReaderView(
                widget.folder.files[index].fileName,
                widget.folder.files[index].fileUrl,
                widget.folder,
                widget.folderController,
                refresh),
          ),
        );
      } else {
        showFileLostDialog(index);
      }
    } else {
      _customDialog.showOkDialoge(context, "Permission Error",
          "In order to add a Picture, storage permissions is needed.");
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
                "File was not found. Either it was deleted or moved. File will now not be shown anymore. If you want to have the URL we can send it via mail."),
            actions: [
              FlatButton(
                onPressed: () {
                  LogicHandler.deleteFile(
                      widget.folder.timeStamp,
                      widget.folder.files[index].fileUrl,
                      widget.folderController);
                  refresh();
                  Navigator.pop(context);
                },
                child: Text("Ok"),
              ),
              FlatButton(
                onPressed: () {
                  LogicHandler.sendMail(
                      body: widget.folder.files[index].fileUrl);
                  LogicHandler.deleteFile(
                      widget.folder.timeStamp,
                      widget.folder.files[index].fileUrl,
                      widget.folderController);
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
