
import 'package:isar/isar.dart';

part 'example_model.g.dart';

@Collection()
class ExampleModel{
  Id? id;
  late String text;
  late String? updatedAt;
  late String? createdAt;

  late String? syncedAt;

  ExampleModel(
      {this.id,
      required this.text,
      this.updatedAt,
      this.createdAt,
      this.syncedAt});
}