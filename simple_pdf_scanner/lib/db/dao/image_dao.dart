import 'package:floor/floor.dart';
import 'package:simple_pdf_scanner/db/entity/image.dart';
import 'package:simple_pdf_scanner/db/entity/protopdf.dart';

@dao
abstract class ImageDao {
  @insert
  Future<void> insertImage(PdfImage image);

  @Query('SELECT * FROM PdfImage WHERE :protoPdfId=PdfImage.proto_pdf AND PdfImage.position=(SELECT MAX(PdfImage.position) FROM PdfImage)')
  Future<PdfImage> lastPosition(int protoPdfId);

  @Query('SELECT * FROM PdfImage WHERE :protoPdfId=PdfImage.proto_pdf ORDER BY PdfImage.position ASC')
  Stream<List<PdfImage>> findAllImagesAsStream(int protoPdfId);
}