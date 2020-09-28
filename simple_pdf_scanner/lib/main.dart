import 'package:flutter/material.dart';
import 'package:simple_pdf_scanner/pdflist.dart';

void main() {
  runApp(SimplePdfScannerApp());
}

class SimplePdfScannerApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PdfListPage(title: 'Flutter Demo Home Page'),
    );
  }
}
