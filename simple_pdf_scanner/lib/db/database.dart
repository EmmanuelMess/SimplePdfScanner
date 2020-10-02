import 'dart:async';
import 'package:floor/floor.dart';
import 'package:simple_pdf_scanner/db/dao/protopdf_dao.dart';
import 'package:simple_pdf_scanner/db/entity/protopdf.dart';
import 'package:simple_pdf_scanner/db/entity/image.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/image_dao.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [ProtoPdf, PdfImage])
abstract class AppDatabase extends FloorDatabase {
  ProtoPdfDao get protoPdfDao;
  ImageDao get imageDao;
}