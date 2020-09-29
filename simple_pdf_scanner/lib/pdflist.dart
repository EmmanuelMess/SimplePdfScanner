import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:simple_pdf_scanner/db/dao/protopdf_dao.dart';
import 'package:simple_pdf_scanner/db/entity/protopdf.dart';
import 'package:simple_pdf_scanner/pdfitem.dart';

class PdfListPage extends StatelessWidget {
  PdfListPage(this.protoPdfDao, {Key key}) : super(key: key);

  final ProtoPdfDao protoPdfDao;

  Widget _createItem(final BuildContext context, final ProtoPdf pdf) {
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(pdf.creation);

    return PdfListItem(
      protoPdfDao: protoPdfDao,
      protoPdf: pdf,
      onPressed: () => Navigator.push(
        context,
        _slideRouteAnimation((_, __, ___) => ImageListPage(protoPdfDao)),
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

  static Route _slideRouteAnimation(final RoutePageBuilder pageBuilder) {
    return PageRouteBuilder(
      pageBuilder: pageBuilder,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween(
              begin: Offset(1.0, 0.0),
              end: Offset.zero,
            ).chain(
              CurveTween(curve: Curves.ease),
            ),
          ),
          child: child,
        );
      },
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
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(
        protoPdf.creation);

    return  ListTile(
      title: Text(protoPdf.title),
      onTap: onPressed,
    );
  }
}
