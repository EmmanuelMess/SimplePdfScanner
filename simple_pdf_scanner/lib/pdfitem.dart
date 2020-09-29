import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:simple_pdf_scanner/db/dao/protopdf_dao.dart';
import 'package:simple_pdf_scanner/db/entity/protopdf.dart';

class ImageListPage extends StatelessWidget {
  ImageListPage(this.protoPdfDao, {Key key}) : super(key: key);

  final ProtoPdfDao protoPdfDao;

  Widget _createItem(final BuildContext context, final String image) {
    return Center(
        child: ImageListItem(image, () => {}),
    );
  }

  final Stream<List<String>> _images = (() async* {
    yield ["sfs", "fsf"];
  })();

  Widget _createItems(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: _images,
      builder: (_, snapshot) {
        if (!snapshot.hasData) return ListView();

        final tasks = snapshot.data;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
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

  final String image;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return  ListTile(
      title: Text(this.image),
      onTap: onPressed,
    );
  }
}
