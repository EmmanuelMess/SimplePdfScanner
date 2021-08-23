import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:touchable/touchable.dart';

import 'package:easy_localization/easy_localization.dart';

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
  File _imageFile;
  double _imageRatio;

  _ImageEditorState(this.imagePath) : super() {
    _imageFile = File(imagePath);
  }

  ValueNotifier<List<int>> _points;

  @override
  void initState() {
    super.initState();
    _points = ValueNotifier([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SimplePdfScanner').tr()),
      body: FutureBuilder(
        future: _getImage(imagePath),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Stack(children: [
              Image.file(_imageFile),
              const Center(child: CircularProgressIndicator()),
            ]);
          }

          final canvasBuilder = (context) =>
              CustomPaint(
                painter: _PaperDelimitationPainter(
                  context,
                  snapshot.data,
                  _points,
                ),
              );

          return Center(
            child: AspectRatio(
              aspectRatio: _imageRatio,
              child: CanvasTouchDetector(builder: canvasBuilder),
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

  Future<ui.Image> _getImage(String imagePath) async {
    Int32List result = await _startGetCorners(imagePath);

    final imageAsBytes = _imageFile.readAsBytesSync();

    final decodedImage = await decodeImageFromList(imageAsBytes);
    _imageRatio = decodedImage.width / decodedImage.height;

    _points.value = [];

    if(result.isEmpty) {
      final doublePoints = [
        decodedImage.width * 1/4, decodedImage.height * 1/4,
        decodedImage.width * 3/4, decodedImage.height * 1/4,
        decodedImage.width * 3/4, decodedImage.height * 3/4,
        decodedImage.width * 1/4, decodedImage.height * 3/4,
      ];

      for(final point in doublePoints) {
        _points.value.add(point.toInt());
      }
    } else {
      for (var i = 0; i < 4*2; i++) {
        _points.value.add(result[i]);
      }
    }

    return decodedImage;
  }

  static Future<Int32List> _startGetCorners(String imagePath) async {
    final _methodChannel = MethodChannel(CHANNEL);

    return _methodChannel.invokeMethod("getCorners", imagePath);
  }

  static Future<Uint8List> _startProcessing(String imagePath) async {
    final _methodChannel = MethodChannel(CHANNEL);

    return await _methodChannel.invokeMethod("process", imagePath);
  }
}

class _PaperDelimitationPainter extends CustomPainter {
  static const LINE_COLOR = Colors.teal;

  final BuildContext context;
  final ui.Image image;
  final ValueNotifier<List<int>> coords;

  _PaperDelimitationPainter(this.context, this.image, this.coords)
      : super(repaint: coords);

  int _selectedIndex;
  List<Offset> offsets = [];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      ui.Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );

    final rX = size.width/image.width;
    final rY = size.height/image.height;

    final myCanvas = TouchyCanvas(context, canvas);
    final transparentPaint = Paint()
      ..color = Colors.transparent;

    myCanvas.drawRect(
        Rect.fromLTWH(0,0, size.width, size.height),
        transparentPaint,
        onPanUpdate: (details) {
          if(_selectedIndex == null) {
            return;
          }

          coords.value[_selectedIndex * 2] = (details.localPosition.dx * 1/rX).toInt();
          coords.value[_selectedIndex * 2 + 1] = (details.localPosition.dy * 1/rY).toInt();
          coords.notifyListeners();
        },
        onTapUp: (details) {
          _selectedIndex = null;
        }
    );

    final paint = Paint()
      ..color = LINE_COLOR
      ..strokeWidth = 10;

    offsets = [];

    for(var i = 0; i < 4; i++) {
      final offset = Offset(
          coords.value[i * 2] * rX, coords.value[i * 2 + 1] * rY);
      offsets.add(offset);
      canvas.drawCircle(offset, 10, paint);

      myCanvas.drawCircle(
        offset,
        50,
        transparentPaint,
        hitTestBehavior: HitTestBehavior.translucent,
        onTapDown: (details) {
          //TODO show section in detail with magnifying glass
          coords.notifyListeners();

          _selectedIndex = i;
        },
      );
    }

    final paintPoly = Paint()
      ..color = LINE_COLOR
      ..strokeWidth = 3;

    canvas.drawPoints(ui.PointMode.polygon, offsets + [offsets[0]], paintPoly);
  }

  @override
  bool shouldRepaint(_PaperDelimitationPainter oldDelegate) {
    return listEquals(offsets, oldDelegate.offsets);
  }
}