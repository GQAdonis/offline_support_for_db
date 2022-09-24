import 'dart:math';
import 'dart:ui';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:isar/isar.dart';
import 'package:offline_support_for_db/example_model/example_model.dart';
import 'package:offline_support_for_db/pending_model/pending_model.dart';

class Backend {
  static final Backend instance = Backend();

  late final Isar _isar;
  final Client _client = Client(
          endPoint:
              'https://8080-appwrite-integrationfor-52tyj68ojp0.ws-eu67.gitpod.io/v1')
      .setProject('632da69f3cc14b8f209c')
      .setSelfSigned(status: true);

  init() async {
    _isar = await Isar.open([ExampleModelSchema, PendingModelSchema]);
  }

  createExample() async {
    String now = DateTime.now().toIso8601String();
    int id = Random().hashCode;
    ExampleModel example = ExampleModel(text: id.toString());
    example
      ..id = id
      ..syncedAt = null
      ..updatedAt = now
      ..createdAt = now;
    await _isar.writeTxn(() async {
      _isar.exampleModels.put(example);
      final tst = await _isar.exampleModels.where().findAll();
    });
  }


  updateExample(ExampleModel example) {
    String now = DateTime.now().toIso8601String();
        example..text = Random().hashCode.toString()
      ..syncedAt = null
      ..updatedAt = now;
    _isar.writeTxn(() async {
      _isar.exampleModels.put(example);
    });
  }

  deleteExample(int id) {
    _isar.writeTxn(() async {
      ExampleModel? exampleModel = await _isar.exampleModels.get(id);
      if(exampleModel!.createdAt != exampleModel.updatedAt || exampleModel.syncedAt != null){
        _isar.pendingModels.put(PendingModel(id: id)..action = 'delete');
      }
      _isar.exampleModels.delete(id);
    });
  }

  clearDatabase(){
    /*_isar.writeTxn(() async {
      _isar.exampleModels.clear();
    });*/
  }

  Stream watchExamples(){
    return _isar.exampleModels.where().watch();
  }

  appwriteWatchExamples(){
    Realtime(_client).subscribe([]).stream.listen((event) {
      
    });
  }

  syncExamplesToServer() async {
    await _isar.writeTxn(() async {
      List<ExampleModel> exampleList =
          await _isar.exampleModels.filter().syncedAtIsNull().findAll();

      List<PendingModel> pendingList =
          await _isar.pendingModels.filter().actionEqualTo('delete').findAll();

      print(exampleList);
      print(pendingList);

      for (var example in exampleList) {
        if (example.updatedAt == example.createdAt) {
          await Databases(_client).createDocument(
              databaseId: 'ExampleDatabase',
              collectionId: 'Examples',
              documentId: example.id.toString(),
              data: {
                'text': example.text,
                '\$updatedAt': example.updatedAt,
                '\$createdAt': example.createdAt
              }).then((value) {
            print('CreateSuccess');
            example.syncedAt = DateTime.now().toIso8601String();
            _isar.exampleModels.put(example);
          }, onError: (e) {
            print('offline create');
          });
        } else if (example.updatedAt != example.createdAt) {
          await Databases(_client).updateDocument(
              databaseId: 'ExampleDatabase',
              collectionId: 'Examples',
              documentId: example.id.toString(),
              data: {
                'text': example.text,
                '\$updatedAt': example.updatedAt
              }).then((value) {
            print('UpdateSuccess');
            example.syncedAt = DateTime.now().toIso8601String();
            _isar.exampleModels.put(example);
          }, onError: (e) {
            print('offline update');
          });
        }
      }

      for (var pendingDelete in pendingList) {
        await Databases(_client)
            .deleteDocument(
          databaseId: 'ExampleDatabase',
          collectionId: 'Examples',
          documentId: pendingDelete.id.toString(),
        )
            .then((value) {
          print('DeleteSuccess');
          _isar.pendingModels.delete(pendingDelete.id!);
        }, onError: (e) {
          print('offline update');
        });
      }
    });
  }

  syncFunctionCall(){

  }
}
