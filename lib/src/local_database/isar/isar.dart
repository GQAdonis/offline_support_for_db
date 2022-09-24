
import 'package:isar/isar.dart';
import 'package:offline_support_for_db/src/isar_appwrite.dart';
import 'package:offline_support_for_db/src/local_database/isar/collections/example/example_collection.dart';
import 'package:offline_support_for_db/src/online_database/appwrite/appwrite.dart';

class IsarRepository extends BackendMethods{
  late final Isar _isar;
  static final IsarRepository instance = IsarRepository();

  Future<void> init() async{
    _isar = await Isar.open([ExampleSchema]);
    final tst = await _isar.examples.where().findAll();

    print(tst);
  }

  @override
  createExample({required Example example}) {
    print(DateTime.now());
    _isar.examples.put(example);
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

  Stream watchExamples(){
     return _isar.examples.filter().syncedAtIsNotNull().watch();
  }

  Future<List<Example>> getExamples() async {
    return await _isar.examples.filter().syncedAtIsNotNull().findAll();
  }

  watchPendingExamples(){
    _isar.examples.filter().syncedAtIsNull().watch().listen((event) {

      //AppwriteRepository.instance.createExample(example: example);
    });
  }

  updateAllExamples(){

  }

  getExamplesFromServer(){

  }

  syncExamplesToServer() async {
    //perioticly
    final tst = await _isar.examples.filter().syncedAtIsNull().findAll();
    tst.forEach((element) {
      AppwriteRepository.instance.createExample(example: element).then((value)
      {
        element.syncedAt = DateTime.now().toIso8601String();
        _isar.examples.put(element);
      });
    });
  }
}

