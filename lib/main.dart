import 'package:bmprogresshud/bmprogresshud.dart';
import 'package:flutter/material.dart';
import 'package:pdfmanager/database/hive_service.dart';
import 'package:pdfmanager/screens/library_screen/library_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HiveService _hiveService = HiveService.getInstance();
  await _hiveService.init();

  runApp(ProgressHud(
    isGlobalHud: true,
    child: MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
        fontFamily: 'Arial Black',
        textTheme: TextTheme(
            headline1: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial Black')),
      ),
      home: LibraryScreen(),
    ),
  ));
}
