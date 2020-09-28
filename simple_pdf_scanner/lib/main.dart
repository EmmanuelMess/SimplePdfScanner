import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:simple_pdf_scanner/db/database.dart';
import 'package:flutter/material.dart';
import 'package:simple_pdf_scanner/pdflist.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db')
      .build();

  runApp(
      EasyLocalization(
        supportedLocales: [Locale('en'), Locale('es')],
        path: 'lib/l10n',
        fallbackLocale: Locale('en'),
        useOnlyLangCode: true,
        child: SimplePdfScannerApp(),
      )
  );
}
class SimplePdfScannerApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (BuildContext context) => 'SimplePdfScanner'.tr(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PdfListPage(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
