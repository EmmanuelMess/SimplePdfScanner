import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageEditorPage extends StatelessWidget {
  static final String CHANNEL = "com.emmanuelmess.simple_pdf_scanner/MAIN";

  final String imagePath;

  const ImageEditorPage( this.imagePath, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Future<Uint8List> processFuture = startProcessing(imagePath);

    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: FutureBuilder(
        future: processFuture,
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Stack(children: [
              Image.file(File(imagePath)),
              Center(child: CircularProgressIndicator()),
            ]);
          }

          return Image.memory(snapshot.data);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () async {
          Navigator.pop(context);
        },
      ),
    );
  }

  static Future<Uint8List> startProcessing(String imagePath) async {
    final _methodChannel = MethodChannel(CHANNEL);

    return await _methodChannel.invokeMethod("process", imagePath);
  }
}