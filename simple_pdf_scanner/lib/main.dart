import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:simple_pdf_scanner/db/database.dart';
import 'package:simple_pdf_scanner/pdflist.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db')
      .build();

  await EasyLocalization.ensureInitialized();

  final cameras = await availableCameras();

  runApp(
      EasyLocalization(
        supportedLocales: [Locale('en'), Locale('es')],
        path: 'lib/l10n',
        fallbackLocale: Locale('en'),
        useOnlyLangCode: true,
        child: SimplePdfScannerApp(database, cameras),
      )
  );
}
class SimplePdfScannerApp extends StatelessWidget {

  final AppDatabase database;
  final List<CameraDescription> cameras;

  const SimplePdfScannerApp(this.database, this.cameras, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (BuildContext context) => 'SimplePdfScanner'.tr(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PdfListPage(cameras, database.protoPdfDao, database.imageDao),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
