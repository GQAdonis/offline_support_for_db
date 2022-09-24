
import 'package:offline_support_for_db/src/local_database/isar/collections/example/example_collection.dart';
import 'package:offline_support_for_db/src/local_database/isar/isar.dart';
import 'package:offline_support_for_db/src/online_database/appwrite/appwrite.dart';

abstract class BackendMethods{
  createExample({required Example example});
  updateExample({required Example example});
  deleteExample({required Example example});
}

class IsarAppwrite extends BackendMethods{

  static final IsarAppwrite instance = IsarAppwrite();
  final IsarRepository _isarRepository = IsarRepository.instance;
  final AppwriteRepository _appwriteRepository = AppwriteRepository.instance;

  Future<void> init() async {
    await _isarRepository.init();
    await _appwriteRepository.init();
    await _appwriteRepository.getExamples();
    await syncWithServer();

  }

  @override
  createExample({required Example example}) async {
    example.createdAt = DateTime.now().toIso8601String();
    example.syncedAt = null;
    _isarRepository.createExample(example: example);
  }

  @override
  deleteExample({required Example example}) {
    // TODO: implement deleteExample
    throw UnimplementedError();
  }

  @override
  updateExample({required Example example}) {
    // TODO: implement updateExample
    throw UnimplementedError();
  }


   updateAllExamples(){

   }

  Stream watchExamples(){
   return _isarRepository.watchExamples();
  }

  Stream watchPendingExamples(){
    return _isarRepository.watchPendingExamples();
  }

  syncWithServer() async {

  }
}

class test{

   init(){
     //Online
     OnlineBackend();

   }
}

class OnlineBackend{

}

class OfflineBackend{

}