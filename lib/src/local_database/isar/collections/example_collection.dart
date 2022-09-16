/*
import 'dart:core';
import 'package:appwrite/models.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:isar/isar.dart';
*/

/*

part 'example_collection.g.dart';

@JsonSerializable()
@Collection()
class UserModel {
  @Id()
  int? id;
  late String example_text;

  factory UserModel.fromJson({required Map<String, dynamic> json}) {
    UserModel userModel = _$UserModelFromJson(json);
    return userModel;
  }

  factory UserModel.fromDocument({required Document document}) {
    UserModel userModel = _$UserModelFromJson(document.data)
      ..id = int.tryParse(document.$id);
    return userModel;
  }

  factory UserModel.fromPayload({required Map<String, dynamic> payload}) {
    UserModel userModel = _$UserModelFromJson(payload)
      ..id = payload['\$id'];
    return userModel;
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  Map<String, dynamic> toServer() {
    Map<String, dynamic> userJson = _$UserModelToJson(this);
    userJson
      ..remove('id');
    return userJson;
  }
}
*/