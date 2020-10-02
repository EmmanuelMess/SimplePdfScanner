import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_pdf_scanner/db/entity/protopdf.dart';

import 'animation.dart';
import 'db/dao/image_dao.dart';
import 'db/entity/image.dart';
import 'image_editor.dart';

class TakePicturePage extends StatefulWidget {
  final ImageDao imageDao;
  final ProtoPdf pdf;

  const TakePicturePage({
    Key key,
    @required this.imageDao,
    @required this.pdf,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TakePicturePageState(imageDao, pdf);

}

class TakePicturePageState extends State<TakePicturePage> with WidgetsBindingObserver {
  final ImageDao imageDao;
  final ProtoPdf pdf;

  Future<void> promisedActivity;

  TakePicturePageState(this.imageDao, this.pdf);

  String _path;
  bool _resumed = false;

  @override
  void initState() {
    super.initState();

    promisedActivity = _startActivity();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _startActivity() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    setState(() {
      _path = join(documentsDir.path, '${DateTime.now()}.jpg');
    });

    final _activity = AndroidIntent(
        action: 'android.intent.action.default',
        package: 'com.emmanuelmess.simple_pdf_scanner',
        componentName: 'com.emmanuelmess.simple_pdf_scanner.PhotoActivity',
        arguments: {"file_path": _path}
    );
    return _activity.launch();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed) {
      setState(() {
        _resumed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_resumed) {
      _saveImageToDatabase(context);
    }

    return Scaffold(
      body: Center(child: CircularProgressIndicator())
    );
  }

  Future<void> _saveImageToDatabase(BuildContext context) async {
    if(! await File(_path).exists()) {
      Navigator.pop(context);
      return;
    }

    final lastPositionImage = await imageDao.lastPosition(pdf.id);
    final lastPosition = lastPositionImage == null? 0 : lastPositionImage.position;

    await imageDao.insertImage(PdfImage(
      null,
      pdf.id,
      _path,
      lastPosition + 1,
    ));

    Navigator.pushReplacement(
      context,
      AnimationHelper.slideRouteAnimation(
            (_, __, ___) => ImageEditorPage(_path),
      ),
    );
  }
}