import 'dart:async';
import 'package:floor/floor.dart';
import 'package:simple_pdf_scanner/db/entity/protopdf.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [ProtoPdf])
abstract class AppDatabase extends FloorDatabase {
}