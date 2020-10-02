import 'package:floor/floor.dart';
import 'package:simple_pdf_scanner/db/entity/protopdf.dart';

@dao
abstract class ProtoPdfDao {
  @update
  Future<void> updateProtoPdf(ProtoPdf pdf);

  @delete
  Future<void> deleteProtoPdfById(ProtoPdf pdf);

  @insert
  Future<void> insertProtoPdf(ProtoPdf pdf);

  @Query('SELECT * FROM ProtoPdf ORDER BY ProtoPdf.creation ASC')
  Stream<List<ProtoPdf>> findAllProtoPdfsAsStream();
}