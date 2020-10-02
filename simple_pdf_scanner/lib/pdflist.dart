import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:simple_pdf_scanner/db/dao/image_dao.dart';
import 'package:simple_pdf_scanner/db/dao/protopdf_dao.dart';
import 'package:simple_pdf_scanner/db/entity/protopdf.dart';
import 'package:simple_pdf_scanner/pdfitem.dart';

import 'animation.dart';

class PdfListPage extends StatelessWidget {
  PdfListPage(this.protoPdfDao, this.imageDao, {Key key}) : super(key: key);

  final ProtoPdfDao protoPdfDao;
  final ImageDao imageDao;

  Widget _createItem(final BuildContext context, final ProtoPdf pdf) {
    return PdfListItem(
      protoPdfDao: protoPdfDao,
      protoPdf: pdf,
      onPressed: () => Navigator.push(
        context,
        AnimationHelper.slideRouteAnimation((_, __, ___) => ImageListPage(pdf, imageDao)),
      ),
    );
  }

  Widget _createItems(BuildContext context) {
    return StreamBuilder<List<ProtoPdf>>(
      stream: protoPdfDao.findAllDeadlinesAsStream(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return ListView();

        final tasks = snapshot.data;

        return ListView.builder(
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
          await protoPdfDao.insertProtoPdf(ProtoPdf(
            null,
            "Untitled".tr(),
            DateTime.now().millisecondsSinceEpoch,
          ));
        },
        tooltip: 'Increment'.tr(),
        child: Icon(Icons.add),
      ),
    );
  }
}

class PdfListItem extends StatelessWidget {
  const PdfListItem({
    Key key,
    @required this.protoPdfDao,
    @required this.protoPdf,
    @required this.onPressed
  }) : super(key: key);

  final ProtoPdfDao protoPdfDao;
  final ProtoPdf protoPdf;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return  ListTile(
      title: Text(protoPdf.title),
      onTap: onPressed,
    );
  }
}
