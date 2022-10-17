
import 'package:isar/isar.dart';

part 'pending_model.g.dart';

@Collection()
class PendingModel{
  Id id;
  late String database;
  late String collection;
  late String action;
  late Map<String,dynamic>? data;

  PendingModel(
      {required this.id, required this.action, required this.data});
}



@Collection()
class PendingDeleteModel{
  Id id;
  late String action;
  late Map<String,dynamic>? data;

  PendingDeleteModel(
      {required this.id});
}

enum Action{
  delete,
  create,
  update,
  // custom function
}