import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfmanager/controllers/folder_controller.dart';
import 'package:pdfmanager/logic/logic.dart';
import 'package:pdfmanager/screens/files_list_view/file_view.dart';

class LibraryScreen extends StatelessWidget {
  final folderController = Get.put(FolderController());
  String _folderName;
  String _imageStr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Library"),
        actions: <Widget>[],
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: GetX<FolderController>(
              builder: (controller) {
                return GridView.builder(
                  itemCount: controller.folders.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: MediaQuery.of(context).size.width / 800,
                  ),
                  itemBuilder: (context, index) {
                    var _byteImage;
                    bool imageAvaible = false;
                    if (folderController.folders[index].imageStr != null) {
                      String base64Image = folderController.folders[index].imageStr;
                      print(folderController.folders[index].imageStr);
                      _byteImage = Base64Decoder().convert(base64Image);
                      imageAvaible = true;
                    }
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FilesScreen(
                                folderController.folders[index], folderController),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 100,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    imageAvaible
                                        ? Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image:
                                                      MemoryImage(_byteImage),
                                                  fit: BoxFit.fill),
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.blueAccent),
                                            ),
                                            child: Icon(Icons.photo_library),
                                          ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                                child: AutoSizeText(
                                  controller.folders[index].name ?? "Error",
                                  maxLines: 2,
                                  minFontSize: 11,
                                  maxFontSize: 20,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
                    Icons.create_new_folder,
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
                            child: addFolderWidget(context),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  addFolderWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 12),
          Text('Create new folder',
              style: Theme.of(context).textTheme.headline1),
          Container(height: 2, color: Colors.white),
          SizedBox(height: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                cursorColor: Colors.red,
                onChanged: (folderName) {
                  _folderName = folderName;
                },
                decoration: new InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2.0),
                  ),
                  labelStyle: new TextStyle(color: Colors.white),
                  labelText: 'Folder Name',
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Add Image (Optional)"),
                  RaisedButton(
                    color: Colors.red,
                    onPressed: () {
                      LogicHandler.getImage(context).then((value) => {
                            if (value.isNotEmpty) {_imageStr = value}
                          });
                    },
                    child: Icon(Icons.add_a_photo),
                  ),
                ],
              ),
              SizedBox(height: 30.0),
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
                      "Create",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    onPressed: () {
                      if (_folderName != null && _folderName.isNotEmpty) {
                        LogicHandler.addFolder(
                            _folderName, _imageStr, folderController);
                        Navigator.pop(context);
                      } else {
                        showDialog(
                          context: context,
                          builder: (con) => AlertDialog(
                            title: Text("Folder Name Empty"),
                            content:
                                Text("Please add a folder name."),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop();
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
