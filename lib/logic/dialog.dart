import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdfmanager/resources.dart/Strings.dart';

class CustomDiaglog {
   static final CustomDiaglog _singleton = new CustomDiaglog._internal();
  CustomDiaglog._internal();
  static CustomDiaglog getInstance() => _singleton;

  showOkDialoge(BuildContext context, String title, String message,) {
    showDialog(
      context: context,
      builder: (con) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(Strings.ok),
          ),
        ],
      ),
    );
  }
}
