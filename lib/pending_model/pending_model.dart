
import 'package:isar/isar.dart';

part 'pending_model.g.dart';

@Collection()
class PendingModel{
  Id? id;
  late String action;

  PendingModel(
      {this.id});
}