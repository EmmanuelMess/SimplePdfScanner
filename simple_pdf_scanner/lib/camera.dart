import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:simple_pdf_scanner/db/entity/protopdf.dart';

import 'animation.dart';
import 'db/dao/image_dao.dart';
import 'db/entity/image.dart';
import 'image_editor.dart';

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  final ImageDao imageDao;
  final ProtoPdf pdf;

  const TakePictureScreen({
    Key key,
    @required this.imageDao,
    @required this.pdf,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState(imageDao, camera, pdf);
}

class TakePictureScreenState extends State<TakePictureScreen> {
  final ImageDao imageDao;
  final CameraDescription camera;
  final ProtoPdf pdf;

  CameraController _controller;
  Future<void> _initializeControllerFuture;
  Future<Directory> _applicationDocumentsDirectory;

  TakePictureScreenState(this.imageDao, this.camera, this.pdf);

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
    _applicationDocumentsDirectory = getApplicationDocumentsDirectory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            final documentsDir = await _applicationDocumentsDirectory;
            final path = join(documentsDir.path, '${DateTime.now()}.png');

            await _initializeControllerFuture;
            await _controller.takePicture(path);

            final lastPositionImage = await imageDao.lastPosition(pdf.id);
            final lastPosition = lastPositionImage == null? 0 : lastPositionImage.position;

            await imageDao.insertImage(PdfImage(
              null,
              pdf.id,
              path,
              lastPosition + 1,
            ));

            Navigator.push(
              context,
              AnimationHelper.slideRouteAnimation(
                    (_, __, ___) => DisplayPictureScreen(imagePath: path),
              ),
            );
          } catch(e) {
            print(e);
          }
        },
      ),
    );
  }
}