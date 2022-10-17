
import 'package:isar/isar.dart';

part 'example_model.g.dart';

@Collection()
class ExampleModel{
  Id? id;
  late String text;
  late String? updatedAt;
  late String? createdAt;
  late Map<DateTime,List<Map<String,dynamic>>> changeLog;



  ExampleModel(
      {this.id,
      required this.text,
      this.updatedAt,
      this.createdAt,
    });
}

@Collection()
class LocalDataModel{
  late String database;
  late String collection;
  Id? id;
  late Map<String,dynamic> data;

  LocalDataModel(this.database, this.collection, this.id, this.data);
}