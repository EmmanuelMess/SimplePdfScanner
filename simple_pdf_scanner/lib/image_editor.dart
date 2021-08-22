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

  Image _image;

  _ImageEditorState( this.imagePath) : super() {
    _image = Image.file(File(imagePath));
  }

  List<int> _points;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SimplePdfScanner').tr()),
      body: FutureBuilder(
        future: getImage(imagePath),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Stack(children: [
              _image,
              Center(child: CircularProgressIndicator()),
            ]);
          }

          return Container(
            width: 400,
            height: 400,
            child: CustomPaint(
              painter: _PaperDelimitationPainter(snapshot.data, _points),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () async {
          //TODO save points

          Navigator.pop(context);
        },
      ),
    );
  }

  Future<ui.Image> getImage(String imagePath) async {
    Int32List result = await startGetCorners(imagePath);

    _points = [];

    if(result.isEmpty) {
      final doublePoints = [
        _image.width * 1/4, _image.height * 1/4,
        _image.width * 3/4, _image.height * 1/4,
        _image.width * 3/4, _image.height * 3/4,
        _image.width * 1/4, _image.height * 3/4,
      ];

      for(final point in doublePoints) {
        _points.add(point.toInt());
      }
    } else {
      for (var i = 0; i < 4*2; i++) {
        _points.add(result[i]);
      }
    }

    return decodeImageFromList(await File(imagePath).readAsBytes());
  }

  static Future<Int32List> startGetCorners(String imagePath) async {
    final _methodChannel = MethodChannel(CHANNEL);

    return _methodChannel.invokeMethod("getCorners", imagePath);
  }

  static Future<Uint8List> startProcessing(String imagePath) async {
    final _methodChannel = MethodChannel(CHANNEL);

    return await _methodChannel.invokeMethod("process", imagePath);
  }
}

class _PaperDelimitationPainter extends CustomPainter {
  static const LINE_COLOR = Colors.teal;

  final ui.Image image;
  final List<int> coords;

  _PaperDelimitationPainter(this.image, this.coords);

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

    final rX = size.width/image.width;
    final rY = size.height/image.height;
    List<Offset> offsets = [];

    for(var i = 0; i < 4; i++) {
      final offset = Offset(coords[i*2] * rX, coords[i*2+1] * rY);
      offsets.add(offset);
      canvas.drawCircle(offset, 5, paint);
    }

    final paintPoly = Paint()
      ..color = LINE_COLOR
      ..strokeWidth = 3;

    canvas.drawPoints(ui.PointMode.polygon, offsets + [offsets[0]], paintPoly);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}