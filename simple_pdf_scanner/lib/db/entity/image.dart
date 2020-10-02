import 'package:floor/floor.dart';
import 'package:simple_pdf_scanner/db/entity/protopdf.dart';

@Entity(
  foreignKeys: [
    ForeignKey(
      childColumns: ['proto_pdf'],
      parentColumns: ['id'],
      entity: ProtoPdf,
    )
  ],
)
class PdfImage {
  @primaryKey
  final int id;

  @ColumnInfo(name: 'proto_pdf')
  final int protoPdf;

  final String path;

  final int position;

  PdfImage(this.id, this.protoPdf, this.path, this.position);
}