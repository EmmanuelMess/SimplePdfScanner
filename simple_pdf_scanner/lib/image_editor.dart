import 'dart:io';

import 'package:flutter/material.dart';

class ImageEditorScreen extends StatelessWidget {
  final String imagePath;

  const ImageEditorScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: Image.file(File(imagePath)),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () async {
          Navigator.pop(context);
        },
      ),
    );
  }
}