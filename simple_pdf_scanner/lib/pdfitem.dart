import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pdf/pdf.dart' as pdfcreator;
import 'package:pdf/widgets.dart' as pdfcreator;
import 'package:printing/printing.dart' as pdfcreator;

import 'package:easy_localization/easy_localization.dart';
import 'package:simple_pdf_scanner/camera.dart';
import 'package:simple_pdf_scanner/db/entity/protopdf.dart';

import 'animation.dart';
import 'db/dao/image_dao.dart';
import 'db/entity/image.dart';
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
            Navigator.push(
              context,
              AnimationHelper.slideRouteAnimation(
                    (_, __, ___) =>
                    TakePicturePage(imageDao: imageDao, pdf: pdf),
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
          final createdpdf = await _createPdf();

          Navigator.push(
            context,
            AnimationHelper.slideRouteAnimation(
                  (_, __, ___) =>
                      ShowPdf(pdf.title, createdpdf),
            ),
          );
        },
        tooltip: 'CreatePdf'.tr(),
        child: Icon(Icons.picture_as_pdf),
      ),
    );
  }

  Future<Uint8List> _createPdf() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final file = File(join(documentsDir.path, '${pdf.title}.pdf'));
    final doc = pdfcreator.Document();
    final images = await imageDao.findAllImages(pdf.id);

    for (final image in images) {
      final pdfimage = pdfcreator.MemoryImage(
        File(image.path).readAsBytesSync(),
      );

      doc.addPage(pdfcreator.Page(
          build: (pdfcreator.Context context) {
            return pdfcreator.Center(
              child: pdfcreator.Image(pdfimage),
            ); // Center
          })); // Page
    }

    if(images.isEmpty) {
      doc.addPage(pdfcreator.Page(
          build: (context) {
            return pdfcreator.Center(
              child: pdfcreator.Text(pdf.title),
            );
          }
      ));
    }

    final finishedpdf = await doc.save();

    file.writeAsBytesSync(finishedpdf);

    return finishedpdf;
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
      title: Image.file(File(this.image.thumb_path)),
      onTap: onPressed,
    );
  }
}

class ShowPdf extends StatelessWidget {
  const ShowPdf(this.title, this.pdf, {Key key}) : super(key: key);

  final String title;
  final Uint8List pdf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: pdfcreator.PdfPreview(
        build: (format) => this.pdf,
      ),
    );
  }
}