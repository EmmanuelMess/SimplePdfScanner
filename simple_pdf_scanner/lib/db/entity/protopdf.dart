import 'package:floor/floor.dart';

@entity
class ProtoPdf {
  @primaryKey
  final int id;

  final String title;

  final int creation;

  ProtoPdf(this.id, this.title, this.creation);
}