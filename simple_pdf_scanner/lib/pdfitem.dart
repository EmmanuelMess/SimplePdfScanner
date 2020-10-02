import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:simple_pdf_scanner/db/entity/image.dart';
import 'package:simple_pdf_scanner/db/entity/protopdf.dart';

import 'animation.dart';
import 'camera.dart';
import 'db/dao/image_dao.dart';
import 'image_editor.dart';

class ImageListPage extends StatelessWidget {
  ImageListPage(this.pdf, this.imageDao, {Key key}) : super(key: key);

  final ProtoPdf pdf;
  final ImageDao imageDao;

  Widget _addPhotoItem(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: sqrt(2) / 2, //Aspect ratio of A pages
        child: GestureDetector(
          child: Container(
            child: const Icon(Icons.add, size: 48.0,),
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.black12,
            ),
          ),
          onTap: () async {
            final cameras = await availableCameras();

            Navigator.push(
              context,
              AnimationHelper.slideRouteAnimation(
                    (_, __, ___) =>
                    TakePicturePage(imageDao: imageDao,
                        pdf: pdf,
                        camera: cameras.first),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _createItem(final BuildContext context, final PdfImage image) {
    return Center(
      child: ImageListItem(image, () =>
          Navigator.push(
              context,
              AnimationHelper.slideRouteAnimation(
                      (_, __, ___) => ImageEditorPage(image.path)
              )
          ),
      ),
    );
  }

  Widget _createItems(BuildContext context) {
    final delegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 16.0,
    );

    return StreamBuilder<List<PdfImage>>(
      stream: imageDao.findAllImagesAsStream(pdf.id),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return GridView(gridDelegate: delegate);

        final tasks = snapshot.data;

        return GridView.builder(
          gridDelegate: delegate,
          itemCount: tasks.length + 1,
          itemBuilder: (_, index) {
            if (index < tasks.length) {
              return _createItem(context, tasks[index]);
            } else {
              return _addPhotoItem(context);
            }
          }
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

        },
        tooltip: 'CreatePdf'.tr(),
        child: Icon(Icons.picture_as_pdf),
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
