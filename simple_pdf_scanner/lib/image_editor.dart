import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageEditorPage extends StatefulWidget {
  final String imagePath;

  const ImageEditorPage( this.imagePath, {Key key}) : super(key: key);

  @override
  _ImageEditorState createState() => _ImageEditorState(imagePath);
}

class _ImageEditorState extends State<ImageEditorPage> {
  static final String CHANNEL = "com.emmanuelmess.simple_pdf_scanner/MAIN";

  final String imagePath;

  _ImageEditorState( this.imagePath) : super();

  @override
  Widget build(BuildContext context) {
    final Future<Uint8List> processFuture = startProcessing(imagePath);

    return Scaffold(
      appBar: AppBar(title: Text('SimplePdfScanner').tr()),
      body: FutureBuilder(
        future: getImage(imagePath),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Stack(children: [
              Image.file(File(imagePath)),
              Center(child: CircularProgressIndicator()),
            ]);
          }

          return Container(
            width: 400,
            height: 400,
            child: CustomPaint(
              painter: _PaperDelimitationPainter(snapshot.data),
            ),
          );
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

  static Future<ui.Image> getImage(String imagePath) async {
    return decodeImageFromList(await File(imagePath).readAsBytes());
  }

  static Future<Uint8List> startProcessing(String imagePath) async {
    final _methodChannel = MethodChannel(CHANNEL);

    return await _methodChannel.invokeMethod("process", imagePath);
  }
}

class _PaperDelimitationPainter extends CustomPainter {
  static const LINE_COLOR = Colors.teal;

  final ui.Image image;

  _PaperDelimitationPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {

    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      ui.Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );

    final paint = Paint()
      ..color = LINE_COLOR
      ..strokeWidth = 10;

    //list of points
    final points = [Offset(50, 50),
      Offset(80, 70),
      Offset(80, 30),
      Offset(380, 175)];

    for(final point in points) {
      canvas.drawCircle(point, 5, paint);
    }

    final paintPoly = Paint()
      ..color = LINE_COLOR
      ..strokeWidth = 3;

    canvas.drawPoints(ui.PointMode.polygon, points + [points[0]], paintPoly);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}