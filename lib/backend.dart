import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:isar/isar.dart';
import 'package:offline_support_for_db/example_model/example_model.dart';
import 'package:offline_support_for_db/pending_model/pending_model.dart';

class Backend {
  static final Backend instance = Backend();

  late final Isar _isar;
  final Client _client = Client(
          endPoint:
              'http://8080-appwrite-integrationfor-52tyj68ojp0.ws-eu71.gitpod.io/v1')
      .setProject('632da69f3cc14b8f209c')
      .setSelfSigned(status: true);
  late final Functions _functions = Functions(_client);
  late final Realtime _realtime = Realtime(_client);
  late final Account _account = Account(_client);
  late final Databases _databases = Databases(_client);

  init() async {
      _isar = await Isar.open([ExampleModelSchema, PendingModelSchema]);
      openNetworkWatcher();
  }

  openNetworkWatcher() {
    StreamSubscription test = _isar.exampleModels.where().watch().listen((event) async {
      await syncExamplesToServer();
    });
    test.pause();
    InternetConnectionCheckerPlus().onStatusChange.listen((status) async {
      print(status);
      if(status == InternetConnectionStatus.connected){
        await syncExamplesToServer();
        await appwriteWatchExamples();
        test.resume();
      }else{
        test.pause();
      }
    });
  }

  createExample() async {
    String now = DateTime.now().toIso8601String();
    int id = Random().hashCode;
    ExampleModel example = ExampleModel(text: id.toString());
    example
      ..id = id
      ..updatedAt = now
      ..createdAt = now;

    
    await _isar.writeTxn(() async {
      _isar.pendingModels.put(PendingModel(id: example.id!, action: Action.create.toString(), data: {}));
      _isar.exampleModels.put(example);
    });
  }

  updateExample(ExampleModel example) {
    String now = DateTime.now().toIso8601String();
    example
      ..text = Random().hashCode.toString()
      ..updatedAt = now;
    _isar.writeTxn(() async {
      _isar.pendingModels.put(PendingModel(id: example.id!, action: Action.update.toString(), data: {}));
      _isar.exampleModels.put(example);
    });
  }

  deleteExample(int id) {
    _isar.writeTxn(() async {
      _isar.pendingModels.put(PendingModel(id: id, action: Action.delete.toString(), data: null));
      _isar.exampleModels.delete(id);
    });
  }

  clearDatabase() {
    /*_isar.writeTxn(() async {
      _isar.exampleModels.clear();
    });*/
  }

  Stream watchExamples() {
    return _isar.exampleModels.where().watch();
  }

  /*appwriteWatchExamples() async {
    await Databases(_client)
        .listDocuments(databaseId: 'ExampleDatabase', collectionId: 'Examples')
        .then((value) async {
      List<ExampleModel> exampleList = [];

      for (var element in value.documents) {
        ExampleModel exampleModel = ExampleModel(text: element.data['text'])
          ..id = int.tryParse(element.$id)
          ..updatedAt = element.$updatedAt
          ..createdAt = element.$createdAt
          ..syncedAt = DateTime.now().toIso8601String();
          exampleList.add(exampleModel);
      }

      await _isar.writeTxn(() async {
        _isar.exampleModels.clear();
        _isar.exampleModels.putAll(exampleList);
      });
    }, onError: (e) {
      print(e);
    });


    StreamSubscription<RealtimeMessage> examplesRealtimeSubscription;
    examplesRealtimeSubscription = _realtime
        .subscribe(['databases.ExampleDatabase.collections.Examples.documents'])
        .stream
        .listen((event) {
          print(event.events.first);

          final payload = event.payload;
          ExampleModel exampleModel = ExampleModel(text: payload['text']);
          exampleModel
            ..id = int.tryParse(payload['\$id'])
            ..updatedAt = payload['\$updatedAt']
            ..createdAt = payload['\$createdAt']
            ..syncedAt = DateTime.now().toIso8601String();
          _isar.writeTxn(() async {
            _isar.exampleModels.put(exampleModel);
          });

        })..onError((e){
      print(e);
      
      // Todo Reopen or pending
    })..onDone(() {print('test');});
  }*/

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
              }).then((value) async {
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
            .then((value) async {
          print('DeleteSuccess');
          _isar.pendingModels.delete(pendingDelete.id!);
        }, onError: (e) {
          print(e.code);
          if(e.code == 404){
            _isar.pendingModels.delete(pendingDelete.id!);
          }
        });
      }
    });
  }

  pushPendingUpdates() async {
    await _isar.writeTxn(() async {
      List<PendingModel> pendingList =
      await _isar.pendingModels.filter().actionEqualTo(Action.update.toString()).findAll();

      for (var example in pendingList) {
        await Databases(_client).updateDocument(
            databaseId: example.database,
            collectionId: example.collection,
            documentId: example.id.toString(),
            data: example.data
        ).then((value) async {
          print('UpdateSuccess');
          _isar.pendingModels.delete(example.id);
        }, onError: (e) {
          print('offline update');
        });
      }
    });
  }

  pushPendingCreates() async {
    await _isar.writeTxn(() async {
      List<PendingModel> pendingList =
      await _isar.pendingModels.filter().actionEqualTo(Action.create.toString()).findAll();

      for (var example in pendingList) {
        await Databases(_client).createDocument(
            databaseId: example.database,
            collectionId: example.collection,
            documentId: example.id.toString(),
            data: example.data!
        ).then((value) async {
          print('UpdateSuccess');
          _isar.pendingModels.delete(example.id);
        }, onError: (e) {
          print('offline update');
        });
      }
    });
  }

  pushPendingDeletes() async {
    await _isar.writeTxn(() async {
      List<PendingModel> pendingList =
      await _isar.pendingModels.filter().actionEqualTo('delete').findAll();

      for (var pendingDelete in pendingList) {
        await Databases(_client)
            .deleteDocument(
          databaseId: 'ExampleDatabase',
          collectionId: 'Examples',
          documentId: pendingDelete.id.toString(),
        )
            .then((value) async {
          print('DeleteSuccess');
          _isar.pendingModels.delete(pendingDelete.id!);
        }, onError: (e) {
          print(e.code);
          if(e.code == 404){
            _isar.pendingModels.delete(pendingDelete.id!);
          }
        });
      }
    });
  }

  pushPendingFunctionCalls() async {
    await _isar.writeTxn(() async {

    });
  }

  syncFunctionCall() {}

  executeFunction(){
    Future result = _functions.createExecution(
      functionId: '[FUNCTION_ID]',
    );

    result
        .then((response) {
      print(response);
    }).catchError((error) {
      print(error.response);
    });
  }
}

//offline
// nickname
// name
// Bio

// online
// name

// result
// name

// save changes

//offline
// nickname
// name
// Bio

// online
// name

// result
// nameNewer
// nickname
// Bio