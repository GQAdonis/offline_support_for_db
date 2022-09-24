
import 'dart:core';
import 'package:isar/isar.dart';

part 'example_collection.g.dart';


@Collection()
class Example {
  Id? id;
  late String text;
  String? syncedAt;
  String? updatedAt;
  String? createdAt;

  Example(
  {
    required this.text
  });
}
