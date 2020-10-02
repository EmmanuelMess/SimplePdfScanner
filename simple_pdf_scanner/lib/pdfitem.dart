import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:simple_pdf_scanner/db/entity/image.dart';
import 'package:simple_pdf_scanner/db/entity/protopdf.dart';

import 'animation.dart';
import 'camera.dart';
import 'db/dao/image_dao.dart';

class ImageListPage extends StatelessWidget {
  ImageListPage(this.pdf, this.imageDao, {Key key}) : super(key: key);

  final ProtoPdf pdf;
  final ImageDao imageDao;

  Widget _createItem(final BuildContext context, final PdfImage image) {
    return Center(
        child: ImageListItem(image, () => {}),
    );
  }

  Widget _createItems(BuildContext context) {
    final delegate = SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3);

    return StreamBuilder<List<PdfImage>>(
      stream: imageDao.findAllImagesAsStream(pdf.id),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return GridView(gridDelegate: delegate);

        final tasks = snapshot.data;

        return GridView.builder(
          gridDelegate: delegate,
          itemCount: tasks.length,
          itemBuilder: (_, index) {
            return _createItem(context, tasks[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PdfListTitle").tr(),
      ),
      body: Builder(
        builder: (context) =>
            Align(
                alignment: Alignment.topCenter,
                child: _createItems(context)
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final cameras = await availableCameras();

          Navigator.push(
            context,
            AnimationHelper.slideRouteAnimation(
                  (_, __, ___) => TakePictureScreen(imageDao: imageDao, pdf: pdf, camera: cameras.first),
            ),
          );
        },
        tooltip: 'TakePhoto'.tr(),
        child: Icon(Icons.photo_camera),
      ),
    );
  }
}

class ImageListItem extends StatelessWidget {
  const ImageListItem(
      this.image,
      this.onPressed,
      {Key key}
  ) : super(key: key);

  final PdfImage image;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return  ListTile(
      title: Image.file(File(this.image.path)),
      onTap: onPressed,
    );
  }
}
